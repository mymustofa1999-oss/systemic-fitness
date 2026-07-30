package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
	"github.com/xuri/excelize/v2"
)

type ExcelRow struct {
	Sequence     string
	SetTrack     string
	Type         string
	Section      string
	UpperName    string
	LowerName    string
	VideoLink    string
	Status       string
}

func main() {
	godotenv.Load()
	dbURL := os.Getenv("DATABASE_URL")
	pool, err := pgxpool.New(context.Background(), dbURL)
	if err != nil {
		log.Fatal("Error connecting to database", err)
	}
	defer pool.Close()
	ctx := context.Background()

	// 1. Delete existing templates
	fmt.Println("Deleting existing templates...")
	_, err = pool.Exec(ctx, "DELETE FROM trainer_card_templates")
	if err != nil {
		log.Fatal(err)
	}

	files, err := filepath.Glob(`C:\Users\ITBDG\Documents\SystemicFitness-Handover\CLEAN\systemic-fitness-api\movment new\*.xlsx`)
	if err != nil {
		log.Fatal(err)
	}

	for _, file := range files {
		processFile(ctx, pool, file)
	}
	fmt.Println("Done processing all files!")
}

func getOrInsertProgramCategory(ctx context.Context, pool *pgxpool.Pool, code string) string {
	code = strings.TrimSpace(code)
	if code == "" {
		return ""
	}
	dbCode := strings.ToLower(code)
	dbCode = strings.ReplaceAll(dbCode, " ", "-")
	
	var id string
	err := pool.QueryRow(ctx, "SELECT id FROM program_categories WHERE code = $1", dbCode).Scan(&id)
	if err == nil {
		return id
	}

	// Insert
	err = pool.QueryRow(ctx, 
		"INSERT INTO program_categories (name, code, description, is_active) VALUES ($1, $2, $3, true) RETURNING id",
		code, dbCode, "Auto-generated category").Scan(&id)
	if err != nil {
		log.Printf("Error inserting category %s: %v", code, err)
		return ""
	}
	return id
}

func getOrInsertType(ctx context.Context, pool *pgxpool.Pool, name string) string {
	name = strings.TrimSpace(name)
	if name == "" {
		return ""
	}
	var id string
	err := pool.QueryRow(ctx, "SELECT id FROM trainer_card_types WHERE name = $1", name).Scan(&id)
	if err == nil {
		return id
	}

	// Insert
	err = pool.QueryRow(ctx, 
		"INSERT INTO trainer_card_types (name, description, is_active) VALUES ($1, $2, true) RETURNING id",
		name, "Auto-generated type").Scan(&id)
	if err != nil {
		log.Printf("Error inserting type %s: %v", name, err)
		return ""
	}
	return id
}

func getOrInsertMovement(ctx context.Context, pool *pgxpool.Pool, name, videoLink, gender string) string {
	name = strings.TrimSpace(name)
	if name == "" {
		return ""
	}
	var id string
	err := pool.QueryRow(ctx, "SELECT id FROM dl_movements WHERE name = $1", name).Scan(&id)
	if err != nil {
		// Insert basic movement
		err = pool.QueryRow(ctx, 
			"INSERT INTO dl_movements (name, body_part) VALUES ($1, 'upper') RETURNING id",
			name).Scan(&id)
		if err != nil {
			log.Printf("Error inserting movement %s: %v", name, err)
			return ""
		}
	}

	// Update video link if provided
	videoLink = strings.TrimSpace(videoLink)
	if videoLink != "" && videoLink != "-" && videoLink != "waitlist" {
		if gender == "FEMALE" {
			pool.Exec(ctx, "UPDATE dl_movements SET video_url_female = $1 WHERE id = $2", videoLink, id)
		} else {
			pool.Exec(ctx, "UPDATE dl_movements SET video_url_male = $1 WHERE id = $2", videoLink, id)
		}
	}
	return id
}

func processFile(ctx context.Context, pool *pgxpool.Pool, file string) {
	fmt.Printf("Processing %s...\n", filepath.Base(file))
	
	// Determine Level and Gender
	base := filepath.Base(file)
	base = strings.ReplaceAll(base, ".xlsx", "")
	base = strings.ReplaceAll(base, "VIDEO ", "")
	base = strings.ReplaceAll(base, "VIDEO", "")
	base = strings.ReplaceAll(base, "  ", " ")
	base = strings.TrimSpace(base)
	// Example: FEMALE- LEVEL 1 or FEMALE-LEVEL 1
	base = strings.ReplaceAll(base, "- ", "-")
	
	levelStr := base // e.g. FEMALE-LEVEL 1
	gender := "MALE"
	if strings.HasPrefix(levelStr, "FEMALE") {
		gender = "FEMALE"
	}
	
	var templateID string
	err := pool.QueryRow(ctx, "INSERT INTO trainer_card_templates (level) VALUES ($1) ON CONFLICT (level) DO UPDATE SET updated_at = NOW() RETURNING id", levelStr).Scan(&templateID)
	if err != nil {
		log.Printf("Error inserting template %s: %v", levelStr, err)
		return
	}

	f, err := excelize.OpenFile(file)
	if err != nil {
		log.Printf("Error reading file %s: %v", file, err)
		return
	}
	defer f.Close()

	sheets := f.GetSheetList()
	rows, _ := f.GetRows(sheets[0])

	var currentSequenceID string
	var currentSequenceName string
	var currentSetID string
	var currentSetName string
	var seqOrder, setOrder, itemOrder int

	for i, row := range rows {
		if i == 0 || len(row) < 5 {
			continue // skip header or short rows
		}

		if i%10 == 0 {
			fmt.Printf("Processing row %d...\n", i)
		}
		
		seqName := strings.TrimSpace(row[0])
		setName := strings.TrimSpace(row[1])
		typeName := strings.TrimSpace(row[2])
		section := strings.TrimSpace(row[3]) // Upper / Lower
		upperMov := strings.TrimSpace(row[4])
		
		lowerMov := ""
		if len(row) > 5 {
			lowerMov = strings.TrimSpace(row[5])
		}
		
		videoLink := ""
		if len(row) > 6 {
			videoLink = strings.TrimSpace(row[6])
		}
		
		if seqName == "" && setName == "" && upperMov == "" && lowerMov == "" {
			continue
		}

		// Handle Sequence
		if seqName != "" && seqName != currentSequenceName {
			currentSequenceName = seqName
			seqOrder++
			catID := getOrInsertProgramCategory(ctx, pool, seqName)
			
			// Insert sequence
			err = pool.QueryRow(ctx, 
				"INSERT INTO trainer_card_template_sequences (template_id, program_category_id, sort_order) VALUES ($1, $2, $3) ON CONFLICT (template_id, program_category_id) DO UPDATE SET sort_order = $3 RETURNING id",
				templateID, catID, seqOrder).Scan(&currentSequenceID)
			if err != nil {
				log.Printf("Error inserting sequence %s: %v", seqName, err)
				continue
			}
			currentSetName = "" // Reset set when sequence changes
			setOrder = 0
		}

		// Handle Set
		if setName != "" && setName != currentSetName {
			currentSetName = setName
			setOrder++
			typeID := getOrInsertType(ctx, pool, typeName)
			var typeIDPtr *string
			if typeID != "" {
				typeIDPtr = &typeID
			}

			// Insert set
			err = pool.QueryRow(ctx,
				"INSERT INTO trainer_card_template_sets (sequence_id, set_number, type_id, sort_order) VALUES ($1, $2, $3, $4) RETURNING id",
				currentSequenceID, setOrder, typeIDPtr, setOrder).Scan(&currentSetID)
			if err != nil {
				log.Printf("Error inserting set %s: %v", setName, err)
				continue
			}
			itemOrder = 0
		}

		// Handle Items
		if currentSetID == "" {
			continue // cannot insert item without set
		}

		// Body part usually inferred from section, but section can be empty if it's stretching
		bodyPart := "core"
		secLow := strings.ToLower(section)
		if strings.Contains(secLow, "upper") {
			bodyPart = "upper"
		} else if strings.Contains(secLow, "lower") {
			bodyPart = "lower"
		}

		insertItem := func(movName, bPart string) {
			if movName == "" || movName == "-" || movName == "TIDAK ADA" || movName == "TIDAK DITEMUKAN" {
				return
			}
			movID := getOrInsertMovement(ctx, pool, movName, videoLink, gender)
			var movIDPtr *string
			if movID != "" {
				movIDPtr = &movID
			}
			itemOrder++
			
			_, err = pool.Exec(ctx,
				"INSERT INTO trainer_card_template_set_items (set_id, movement_id, movement_name, body_part, sort_order) VALUES ($1, $2, $3, $4, $5)",
				currentSetID, movIDPtr, movName, bPart, itemOrder)
			if err != nil {
				log.Printf("Error inserting item %s: %v", movName, err)
			}
		}

		// Often Excel has Upper in Col 4 and Lower in Col 5 on the SAME ROW.
		// Or sometimes one is blank.
		if upperMov != "" && !strings.Contains(strings.ToLower(upperMov), "tidak ditemukan") {
			// If section is specifically lower but upper column has text (maybe misaligned?), we should just trust the column
			bp := "upper"
			if bodyPart != "upper" && bodyPart != "core" {
				// if section said lower but it's in upper col? Let's just use upper.
			}
			if bodyPart == "core" {
				bp = "core"
			}
			insertItem(upperMov, bp)
		}

		if lowerMov != "" && !strings.Contains(strings.ToLower(lowerMov), "tidak ditemukan") {
			insertItem(lowerMov, "lower")
		}
	}
}
