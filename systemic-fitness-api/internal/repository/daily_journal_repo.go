package repository

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type DailyJournalRepository struct {
	db *pgxpool.Pool
}

func NewDailyJournalRepository(db *pgxpool.Pool) *DailyJournalRepository {
	return &DailyJournalRepository{db: db}
}

// ═══════════════════════════════════════════════════════════════
//  Session
// ═══════════════════════════════════════════════════════════════

type JournalSession struct {
	ID            string    `json:"id"`
	CustomerID    string    `json:"customer_id"`
	SessionNumber int       `json:"session_number"`
	SessionDate   string    `json:"session_date"`
	MonthYear     *string   `json:"month_year"`
	Notes         *string   `json:"notes,omitempty"`
	CreatedBy     *string   `json:"created_by,omitempty"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`

	// Nested
	Medicines []SessionMedicineRow `json:"medicines"`
	Meals     []SessionMealRow     `json:"meals"`
	PreVital  *SessionVitalRow     `json:"pre_vital"`
	PostVital *SessionVitalRow     `json:"post_vital"`
}

type SessionMedicineRow struct {
	ID           string  `json:"id"`
	SessionID    string  `json:"session_id"`
	MedicineID   string  `json:"medicine_id"`
	MedicineName string  `json:"medicine_name"`
	Notes        *string `json:"notes,omitempty"`
}

type SessionMealRow struct {
	ID              string  `json:"id"`
	SessionID       string  `json:"session_id"`
	MealTime        *string `json:"meal_time,omitempty"`
	FoodDescription *string `json:"food_description,omitempty"`
	FoodID          *string `json:"food_id,omitempty"`
	FoodName        *string `json:"food_name,omitempty"`
	Notes           *string `json:"notes,omitempty"`
}

type SessionVitalRow struct {
	ID              string  `json:"id"`
	SessionID       string  `json:"session_id"`
	MeasurementType string  `json:"measurement_type"`
	Systolic        *int    `json:"systolic,omitempty"`
	Diastolic       *int    `json:"diastolic,omitempty"`
	Heartrate       *int    `json:"heartrate,omitempty"`
	Notes           *string `json:"notes,omitempty"`
}

// ListByMonth returns all sessions for a customer in a given month (YYYY-MM)
func (r *DailyJournalRepository) ListByMonth(ctx context.Context, customerID, monthYear string) ([]JournalSession, error) {
	query := `SELECT id, customer_id, session_number, session_date::text, month_year, notes, created_by, created_at, updated_at
		FROM daily_journal_sessions
		WHERE customer_id = $1 AND month_year = $2
		ORDER BY session_number ASC`
	rows, err := r.db.Query(ctx, query, customerID, monthYear)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	sessions := make([]JournalSession, 0)
	for rows.Next() {
		var s JournalSession
		if err := rows.Scan(&s.ID, &s.CustomerID, &s.SessionNumber, &s.SessionDate, &s.MonthYear, &s.Notes, &s.CreatedBy, &s.CreatedAt, &s.UpdatedAt); err != nil {
			return nil, err
		}
		sessions = append(sessions, s)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	// Load nested data for each session
	for i := range sessions {
		if err := r.loadNested(ctx, &sessions[i]); err != nil {
			return nil, fmt.Errorf("load nested for session %s: %w", sessions[i].ID, err)
		}
	}

	return sessions, nil
}

func (r *DailyJournalRepository) loadNested(ctx context.Context, s *JournalSession) error {
	// Medicines
	medRows, err := r.db.Query(ctx,
		`SELECT sm.id, sm.session_id, sm.medicine_id, m.name, sm.notes
		 FROM session_medicines sm JOIN medicines m ON m.id = sm.medicine_id
		 WHERE sm.session_id = $1 ORDER BY m.name`, s.ID)
	if err != nil {
		return err
	}
	defer medRows.Close()
	s.Medicines = make([]SessionMedicineRow, 0)
	for medRows.Next() {
		var m SessionMedicineRow
		if err := medRows.Scan(&m.ID, &m.SessionID, &m.MedicineID, &m.MedicineName, &m.Notes); err != nil {
			return err
		}
		s.Medicines = append(s.Medicines, m)
	}

	// Meals
	mealRows, err := r.db.Query(ctx,
		`SELECT sm.id, sm.session_id, sm.meal_time::text, sm.food_description, sm.food_id, f.name, sm.notes
		 FROM session_meals sm LEFT JOIN foods f ON f.id = sm.food_id
		 WHERE sm.session_id = $1 ORDER BY sm.meal_time NULLS LAST`, s.ID)
	if err != nil {
		return err
	}
	defer mealRows.Close()
	s.Meals = make([]SessionMealRow, 0)
	for mealRows.Next() {
		var ml SessionMealRow
		if err := mealRows.Scan(&ml.ID, &ml.SessionID, &ml.MealTime, &ml.FoodDescription, &ml.FoodID, &ml.FoodName, &ml.Notes); err != nil {
			return err
		}
		s.Meals = append(s.Meals, ml)
	}

	// Vitals
	vitalRows, err := r.db.Query(ctx,
		`SELECT id, session_id, measurement_type, systolic, diastolic, heartrate, notes
		 FROM session_vitals WHERE session_id = $1`, s.ID)
	if err != nil {
		return err
	}
	defer vitalRows.Close()
	for vitalRows.Next() {
		var v SessionVitalRow
		if err := vitalRows.Scan(&v.ID, &v.SessionID, &v.MeasurementType, &v.Systolic, &v.Diastolic, &v.Heartrate, &v.Notes); err != nil {
			return err
		}
		if v.MeasurementType == "pre_workout" {
			s.PreVital = &v
		} else {
			s.PostVital = &v
		}
	}

	return nil
}

// UpsertSession creates or updates a session and all its nested data
func (r *DailyJournalRepository) UpsertSession(ctx context.Context, s *JournalSession) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	// Derive month_year from session_date
	monthYear := s.SessionDate[:7] // "2026-04-02" -> "2026-04"
	s.MonthYear = &monthYear

	// Upsert session
	err = tx.QueryRow(ctx, `
		INSERT INTO daily_journal_sessions (customer_id, session_number, session_date, month_year, notes, created_by)
		VALUES ($1,$2,$3,$4,$5,$6)
		ON CONFLICT (customer_id, session_date) DO UPDATE SET
			session_number=$2, month_year=$4, notes=$5
		RETURNING id, created_at, updated_at`,
		s.CustomerID, s.SessionNumber, s.SessionDate, monthYear, s.Notes, s.CreatedBy,
	).Scan(&s.ID, &s.CreatedAt, &s.UpdatedAt)
	if err != nil {
		return fmt.Errorf("upsert session: %w", err)
	}

	// Replace medicines
	if _, err := tx.Exec(ctx, `DELETE FROM session_medicines WHERE session_id = $1`, s.ID); err != nil {
		return fmt.Errorf("delete medicines: %w", err)
	}
	for i := range s.Medicines {
		m := &s.Medicines[i]
		err := tx.QueryRow(ctx,
			`INSERT INTO session_medicines (session_id, medicine_id, notes) VALUES ($1,$2,$3) RETURNING id`,
			s.ID, m.MedicineID, m.Notes,
		).Scan(&m.ID)
		if err != nil {
			return fmt.Errorf("insert medicine: %w", err)
		}
		m.SessionID = s.ID
	}

	// Replace meals
	if _, err := tx.Exec(ctx, `DELETE FROM session_meals WHERE session_id = $1`, s.ID); err != nil {
		return fmt.Errorf("delete meals: %w", err)
	}
	for i := range s.Meals {
		ml := &s.Meals[i]
		err := tx.QueryRow(ctx,
			`INSERT INTO session_meals (session_id, meal_time, food_description, food_id, notes) VALUES ($1,$2,$3,$4,$5) RETURNING id`,
			s.ID, ml.MealTime, ml.FoodDescription, ml.FoodID, ml.Notes,
		).Scan(&ml.ID)
		if err != nil {
			return fmt.Errorf("insert meal: %w", err)
		}
		ml.SessionID = s.ID
	}

	// Replace vitals
	if _, err := tx.Exec(ctx, `DELETE FROM session_vitals WHERE session_id = $1`, s.ID); err != nil {
		return fmt.Errorf("delete vitals: %w", err)
	}
	for _, v := range []*SessionVitalRow{s.PreVital, s.PostVital} {
		if v == nil {
			continue
		}
		err := tx.QueryRow(ctx,
			`INSERT INTO session_vitals (session_id, measurement_type, systolic, diastolic, heartrate, notes) VALUES ($1,$2,$3,$4,$5,$6) RETURNING id`,
			s.ID, v.MeasurementType, v.Systolic, v.Diastolic, v.Heartrate, v.Notes,
		).Scan(&v.ID)
		if err != nil {
			return fmt.Errorf("insert vital: %w", err)
		}
		v.SessionID = s.ID
	}

	return tx.Commit(ctx)
}

func (r *DailyJournalRepository) DeleteSession(ctx context.Context, sessionID string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM daily_journal_sessions WHERE id = $1`, sessionID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (r *DailyJournalRepository) GetSession(ctx context.Context, sessionID string) (*JournalSession, error) {
	var s JournalSession
	err := r.db.QueryRow(ctx,
		`SELECT id, customer_id, session_number, session_date::text, month_year, notes, created_by, created_at, updated_at
		 FROM daily_journal_sessions WHERE id = $1`, sessionID,
	).Scan(&s.ID, &s.CustomerID, &s.SessionNumber, &s.SessionDate, &s.MonthYear, &s.Notes, &s.CreatedBy, &s.CreatedAt, &s.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	if err != nil {
		return nil, err
	}
	if err := r.loadNested(ctx, &s); err != nil {
		return nil, err
	}
	return &s, nil
}

// ListMonths returns distinct month_year values for a customer
func (r *DailyJournalRepository) ListMonths(ctx context.Context, customerID string) ([]string, error) {
	rows, err := r.db.Query(ctx,
		`SELECT DISTINCT month_year FROM daily_journal_sessions WHERE customer_id = $1 ORDER BY month_year DESC`, customerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	months := make([]string, 0)
	for rows.Next() {
		var m string
		if err := rows.Scan(&m); err != nil {
			return nil, err
		}
		months = append(months, m)
	}
	return months, rows.Err()
}
