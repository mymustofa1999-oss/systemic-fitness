package repository

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type CustomerSetupRepository struct {
	db *pgxpool.Pool
}

func NewCustomerSetupRepository(db *pgxpool.Pool) *CustomerSetupRepository {
	return &CustomerSetupRepository{db: db}
}

// ═══════════════════════════════════════════════════════════════
//  Trainer/Consultant Assignment
// ═══════════════════════════════════════════════════════════════

type StaffAssignment struct {
	TrainerID      *string `json:"trainer_id,omitempty"`
	TrainerName    *string `json:"trainer_name,omitempty"`
	ConsultantID   *string `json:"consultant_id,omitempty"`
	ConsultantName *string `json:"consultant_name,omitempty"`
	Priority       *string `json:"priority,omitempty"`
}

func (r *CustomerSetupRepository) GetStaffAssignment(ctx context.Context, clientID string) (*StaffAssignment, error) {
	a := &StaffAssignment{}
	// Trainer
	_ = r.db.QueryRow(ctx,
		`SELECT tc.trainer_id, u.full_name FROM trainer_clients tc JOIN users u ON u.id = tc.trainer_id
		 WHERE tc.client_id = $1 AND tc.status = 'active' AND tc.role_type = 'trainer' LIMIT 1`, clientID,
	).Scan(&a.TrainerID, &a.TrainerName)
	// Consultant
	_ = r.db.QueryRow(ctx,
		`SELECT tc.trainer_id, u.full_name FROM trainer_clients tc JOIN users u ON u.id = tc.trainer_id
		 WHERE tc.client_id = $1 AND tc.status = 'active' AND tc.role_type = 'consultant' LIMIT 1`, clientID,
	).Scan(&a.ConsultantID, &a.ConsultantName)
	return a, nil
}

func (r *CustomerSetupRepository) AssignStaff(ctx context.Context, clientID, staffID, roleType string) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	// Deactivate ALL existing assignments of this role_type for this client
	_, _ = tx.Exec(ctx,
		`UPDATE trainer_clients SET status = 'cancelled' WHERE client_id = $1 AND role_type = $2 AND status = 'active'`,
		clientID, roleType)

	// Delete any existing row for this trainer+client combo to avoid PK conflict, then re-insert
	_, _ = tx.Exec(ctx,
		`DELETE FROM trainer_clients WHERE trainer_id = $1 AND client_id = $2`,
		staffID, clientID)

	_, err = tx.Exec(ctx,
		`INSERT INTO trainer_clients (trainer_id, client_id, status, role_type) VALUES ($1, $2, 'active', $3)`,
		staffID, clientID, roleType)
	if err != nil {
		return err
	}

	return tx.Commit(ctx)
}

// ═══════════════════════════════════════════════════════════════
//  Customer HR Zones
// ═══════════════════════════════════════════════════════════════

type CustomerHRZone struct {
	ID          string    `json:"id"`
	CustomerID  string    `json:"customer_id"`
	MaxHRUpper  *int      `json:"max_hr_upper,omitempty"`
	MaxHRLower  *int      `json:"max_hr_lower,omitempty"`
	Zone5Upper  *int      `json:"zone5_upper,omitempty"`
	Zone5Lower  *int      `json:"zone5_lower,omitempty"`
	Zone4Upper  *int      `json:"zone4_upper,omitempty"`
	Zone4Lower  *int      `json:"zone4_lower,omitempty"`
	Zone3Upper  *int      `json:"zone3_upper,omitempty"`
	Zone3Lower  *int      `json:"zone3_lower,omitempty"`
	Zone2Upper  *int      `json:"zone2_upper,omitempty"`
	Zone2Lower  *int      `json:"zone2_lower,omitempty"`
	Zone1Upper  *int      `json:"zone1_upper,omitempty"`
	Zone1Lower  *int      `json:"zone1_lower,omitempty"`
	Notes       *string   `json:"notes,omitempty"`
	Priority    *string   `json:"priority,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

const hrZoneCols = `id, customer_id, max_hr_upper, max_hr_lower,
	zone5_upper, zone5_lower, zone4_upper, zone4_lower,
	zone3_upper, zone3_lower, zone2_upper, zone2_lower,
	zone1_upper, zone1_lower, notes, priority, created_at, updated_at`

func scanHRZone(row pgx.Row) (*CustomerHRZone, error) {
	z := &CustomerHRZone{}
	err := row.Scan(
		&z.ID, &z.CustomerID, &z.MaxHRUpper, &z.MaxHRLower,
		&z.Zone5Upper, &z.Zone5Lower, &z.Zone4Upper, &z.Zone4Lower,
		&z.Zone3Upper, &z.Zone3Lower, &z.Zone2Upper, &z.Zone2Lower,
		&z.Zone1Upper, &z.Zone1Lower, &z.Notes, &z.Priority, &z.CreatedAt, &z.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return z, err
}

func (r *CustomerSetupRepository) GetHRZone(ctx context.Context, customerID string) (*CustomerHRZone, error) {
	return scanHRZone(r.db.QueryRow(ctx, `SELECT `+hrZoneCols+` FROM customer_hr_zones WHERE customer_id = $1`, customerID))
}

func (r *CustomerSetupRepository) UpsertHRZone(ctx context.Context, z *CustomerHRZone) error {
	query := `
		INSERT INTO customer_hr_zones (customer_id, max_hr_upper, max_hr_lower,
			zone5_upper, zone5_lower, zone4_upper, zone4_lower,
			zone3_upper, zone3_lower, zone2_upper, zone2_lower,
			zone1_upper, zone1_lower, notes)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
		ON CONFLICT (customer_id) DO UPDATE SET
			max_hr_upper=$2, max_hr_lower=$3,
			zone5_upper=$4, zone5_lower=$5, zone4_upper=$6, zone4_lower=$7,
			zone3_upper=$8, zone3_lower=$9, zone2_upper=$10, zone2_lower=$11,
			zone1_upper=$12, zone1_lower=$13, notes=$14
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query,
		z.CustomerID, z.MaxHRUpper, z.MaxHRLower,
		z.Zone5Upper, z.Zone5Lower, z.Zone4Upper, z.Zone4Lower,
		z.Zone3Upper, z.Zone3Lower, z.Zone2Upper, z.Zone2Lower,
		z.Zone1Upper, z.Zone1Lower, z.Notes,
	).Scan(&z.ID, &z.CreatedAt, &z.UpdatedAt)
}

// ═══════════════════════════════════════════════════════════════
//  Customer Medicines
// ═══════════════════════════════════════════════════════════════

type CustomerMedicine struct {
	ID           string    `json:"id"`
	CustomerID   string    `json:"customer_id"`
	MedicineID   string    `json:"medicine_id"`
	MedicineName string    `json:"medicine_name,omitempty"`
	Category     *string   `json:"category,omitempty"`
	Notes        *string   `json:"notes,omitempty"`
	IsActive     bool      `json:"is_active"`
	CreatedAt    time.Time `json:"created_at"`
}

func (r *CustomerSetupRepository) ListCustomerMedicines(ctx context.Context, customerID string) ([]CustomerMedicine, error) {
	query := `
		SELECT cm.id, cm.customer_id, cm.medicine_id, m.name, m.category, cm.notes, cm.is_active, cm.created_at
		FROM customer_medicines cm
		JOIN medicines m ON m.id = cm.medicine_id
		WHERE cm.customer_id = $1
		ORDER BY m.name ASC`
	rows, err := r.db.Query(ctx, query, customerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	items := make([]CustomerMedicine, 0)
	for rows.Next() {
		var cm CustomerMedicine
		if err := rows.Scan(&cm.ID, &cm.CustomerID, &cm.MedicineID, &cm.MedicineName, &cm.Category, &cm.Notes, &cm.IsActive, &cm.CreatedAt); err != nil {
			return nil, err
		}
		items = append(items, cm)
	}
	return items, rows.Err()
}

func (r *CustomerSetupRepository) AddCustomerMedicine(ctx context.Context, cm *CustomerMedicine) error {
	query := `
		INSERT INTO customer_medicines (customer_id, medicine_id, notes, is_active)
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (customer_id, medicine_id) DO UPDATE SET notes=$3, is_active=$4
		RETURNING id, created_at`
	return r.db.QueryRow(ctx, query,
		cm.CustomerID, cm.MedicineID, cm.Notes, cm.IsActive,
	).Scan(&cm.ID, &cm.CreatedAt)
}

func (r *CustomerSetupRepository) RemoveCustomerMedicine(ctx context.Context, customerID, medicineID string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM customer_medicines WHERE customer_id = $1 AND medicine_id = $2`, customerID, medicineID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

// ═══════════════════════════════════════════════════════════════
//  Customer Program Assignments
// ═══════════════════════════════════════════════════════════════

type CustomerProgramAssignment struct {
	ID                 string          `json:"id"`
	CustomerID         string          `json:"customer_id"`
	ProgramCategoryID  string          `json:"program_category_id"`
	ProgramCategoryName string         `json:"program_category_name,omitempty"`
	ProgramCategoryCode string         `json:"program_category_code,omitempty"`
	IsActive           bool            `json:"is_active"`
	BPMUpper           *int            `json:"bpm_upper,omitempty"`
	BPMLower           *int            `json:"bpm_lower,omitempty"`
	HasBebanUpper      bool            `json:"has_beban_upper"`
	HasBebanLower      bool            `json:"has_beban_lower"`
	BebanUpperValue    *float64        `json:"beban_upper_value,omitempty"`
	BebanLowerValue    *float64        `json:"beban_lower_value,omitempty"`
	HasResistance      bool            `json:"has_resistance"`
	ParameterNotes     *string         `json:"parameter_notes,omitempty"`
	ParameterTemplate  json.RawMessage `json:"parameter_template,omitempty"`
	CreatedAt          time.Time       `json:"created_at"`
	UpdatedAt          time.Time       `json:"updated_at"`
}

func (r *CustomerSetupRepository) ListCustomerPrograms(ctx context.Context, customerID string) ([]CustomerProgramAssignment, error) {
	// Bootstrap default assignments for active categories if they do not exist
	catRows, err := r.db.Query(ctx, "SELECT id FROM program_categories WHERE is_active = TRUE")
	if err == nil {
		var catIDs []string
		for catRows.Next() {
			var id string
			if err := catRows.Scan(&id); err == nil {
				catIDs = append(catIDs, id)
			}
		}
		catRows.Close()

		for _, cid := range catIDs {
			_, _ = r.db.Exec(ctx,
				`INSERT INTO customer_program_assignments (customer_id, program_category_id, is_active,
					has_beban_upper, has_beban_lower, has_resistance)
				 VALUES ($1, $2, TRUE, FALSE, FALSE, FALSE)
				 ON CONFLICT (customer_id, program_category_id) DO NOTHING`,
				customerID, cid,
			)
		}
	}

	query := `
		SELECT cpa.id, cpa.customer_id, cpa.program_category_id, pc.name, pc.code,
			cpa.is_active, cpa.bpm_upper, cpa.bpm_lower,
			cpa.has_beban_upper, cpa.has_beban_lower, cpa.has_resistance,
			cpa.beban_upper_value, cpa.beban_lower_value,
			cpa.parameter_notes, pc.parameter_template, cpa.created_at, cpa.updated_at
		FROM customer_program_assignments cpa
		JOIN program_categories pc ON pc.id = cpa.program_category_id
		WHERE cpa.customer_id = $1
		ORDER BY pc.display_order ASC`
	rows, err := r.db.Query(ctx, query, customerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	items := make([]CustomerProgramAssignment, 0)
	for rows.Next() {
		var a CustomerProgramAssignment
		if err := rows.Scan(
			&a.ID, &a.CustomerID, &a.ProgramCategoryID, &a.ProgramCategoryName, &a.ProgramCategoryCode,
			&a.IsActive, &a.BPMUpper, &a.BPMLower,
			&a.HasBebanUpper, &a.HasBebanLower, &a.HasResistance,
			&a.BebanUpperValue, &a.BebanLowerValue,
			&a.ParameterNotes, &a.ParameterTemplate, &a.CreatedAt, &a.UpdatedAt,
		); err != nil {
			return nil, err
		}
		items = append(items, a)
	}
	return items, rows.Err()
}

func (r *CustomerSetupRepository) UpsertCustomerProgram(ctx context.Context, a *CustomerProgramAssignment) error {
	query := `
		INSERT INTO customer_program_assignments (customer_id, program_category_id, is_active,
			bpm_upper, bpm_lower, has_beban_upper, has_beban_lower, has_resistance,
			beban_upper_value, beban_lower_value, parameter_notes)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
		ON CONFLICT (customer_id, program_category_id) DO UPDATE SET
			is_active=$3, bpm_upper=$4, bpm_lower=$5,
			has_beban_upper=$6, has_beban_lower=$7, has_resistance=$8,
			beban_upper_value=$9, beban_lower_value=$10, parameter_notes=$11
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query,
		a.CustomerID, a.ProgramCategoryID, a.IsActive,
		a.BPMUpper, a.BPMLower, a.HasBebanUpper, a.HasBebanLower, a.HasResistance,
		a.BebanUpperValue, a.BebanLowerValue, a.ParameterNotes,
	).Scan(&a.ID, &a.CreatedAt, &a.UpdatedAt)
}

func (r *CustomerSetupRepository) RemoveCustomerProgram(ctx context.Context, customerID, programCategoryID string) error {
	tag, err := r.db.Exec(ctx,
		`DELETE FROM customer_program_assignments WHERE customer_id = $1 AND program_category_id = $2`,
		customerID, programCategoryID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

// ═══════════════════════════════════════════════════════════════
//  Customer Priority
// ═══════════════════════════════════════════════════════════════

func (r *CustomerSetupRepository) UpdatePriority(ctx context.Context, customerID, priority string) error {
	query := `
		INSERT INTO customer_hr_zones (customer_id, priority)
		VALUES ($1, $2)
		ON CONFLICT (customer_id) DO UPDATE SET priority = $2, updated_at = now()
		RETURNING id`
	var id string
	return r.db.QueryRow(ctx, query, customerID, priority).Scan(&id)
}

func (r *CustomerSetupRepository) GetPriority(ctx context.Context, customerID string) (*string, error) {
	var priority *string
	err := r.db.QueryRow(ctx,
		`SELECT priority FROM customer_hr_zones WHERE customer_id = $1`, customerID,
	).Scan(&priority)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return priority, err
}

// ═══════════════════════════════════════════════════════════════
//  Full Customer Setup (aggregated)
// ═══════════════════════════════════════════════════════════════

type CustomerSetup struct {
	HRZone   *CustomerHRZone             `json:"hr_zone"`
	Medicines []CustomerMedicine          `json:"medicines"`
	Programs  []CustomerProgramAssignment `json:"programs"`
	Staff    *StaffAssignment             `json:"staff"`
}

func (r *CustomerSetupRepository) GetFullSetup(ctx context.Context, customerID string) (*CustomerSetup, error) {
	setup := &CustomerSetup{}

	hrZone, err := r.GetHRZone(ctx, customerID)
	if err != nil && !errors.Is(err, ErrNotFound) {
		return nil, fmt.Errorf("get hr zone: %w", err)
	}
	setup.HRZone = hrZone

	medicines, err := r.ListCustomerMedicines(ctx, customerID)
	if err != nil {
		return nil, fmt.Errorf("list medicines: %w", err)
	}
	setup.Medicines = medicines

	programs, err := r.ListCustomerPrograms(ctx, customerID)
	if err != nil {
		return nil, fmt.Errorf("list programs: %w", err)
	}
	setup.Programs = programs

	staff, err := r.GetStaffAssignment(ctx, customerID)
	if err != nil {
		return nil, fmt.Errorf("get staff: %w", err)
	}
	// Include priority from hr_zones into staff response
	if hrZone != nil {
		staff.Priority = hrZone.Priority
	} else {
		priority, _ := r.GetPriority(ctx, customerID)
		staff.Priority = priority
	}
	setup.Staff = staff

	return setup, nil
}
