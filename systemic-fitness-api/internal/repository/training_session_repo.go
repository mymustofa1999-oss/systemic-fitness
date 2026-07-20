package repository

import (
	"context"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/fitcoach/api/internal/model"
)

type TrainingSessionRepo interface {
	GetByUserIDAndPeriod(ctx context.Context, userID string, periodName string) ([]model.TrainingSessionLog, error)
	UpsertMany(ctx context.Context, logs []model.TrainingSessionLog) error
}

type trainingSessionRepo struct {
	db *pgxpool.Pool
}

func NewTrainingSessionRepo(db *pgxpool.Pool) TrainingSessionRepo {
	return &trainingSessionRepo{db: db}
}

func (r *trainingSessionRepo) GetByUserIDAndPeriod(ctx context.Context, userID string, periodName string) ([]model.TrainingSessionLog, error) {
	query := `
		SELECT 
			id, user_id, period_name, session_number, date, took_medicine,
			last_meal_hours, last_meal_food, bp_pre_systolic, bp_pre_diastolic, hr_pre,
			bp_post_systolic, bp_post_diastolic, hr_post, created_at, updated_at
		FROM training_session_logs
		WHERE user_id = $1 AND period_name = $2
		ORDER BY session_number ASC
	`
	rows, err := r.db.Query(ctx, query, userID, periodName)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var logs []model.TrainingSessionLog
	for rows.Next() {
		var log model.TrainingSessionLog
		if err := rows.Scan(
			&log.ID, &log.UserID, &log.PeriodName, &log.SessionNumber, &log.Date, &log.TookMedicine,
			&log.LastMealHours, &log.LastMealFood, &log.BPPreSystolic, &log.BPPreDiastolic, &log.HRPre,
			&log.BPPostSystolic, &log.BPPostDiastolic, &log.HRPost, &log.CreatedAt, &log.UpdatedAt,
		); err != nil {
			return nil, err
		}
		logs = append(logs, log)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return logs, nil
}

func (r *trainingSessionRepo) UpsertMany(ctx context.Context, logs []model.TrainingSessionLog) error {
	if len(logs) == 0 {
		return nil
	}

	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	query := `
		INSERT INTO training_session_logs (
			id, user_id, period_name, session_number, date, took_medicine,
			last_meal_hours, last_meal_food, bp_pre_systolic, bp_pre_diastolic, hr_pre,
			bp_post_systolic, bp_post_diastolic, hr_post
		)
		VALUES (
			COALESCE(NULLIF($1, ''), gen_random_uuid()::text)::uuid, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14
		)
		ON CONFLICT (id) DO UPDATE SET
			user_id = EXCLUDED.user_id,
			period_name = EXCLUDED.period_name,
			session_number = EXCLUDED.session_number,
			date = EXCLUDED.date,
			took_medicine = EXCLUDED.took_medicine,
			last_meal_hours = EXCLUDED.last_meal_hours,
			last_meal_food = EXCLUDED.last_meal_food,
			bp_pre_systolic = EXCLUDED.bp_pre_systolic,
			bp_pre_diastolic = EXCLUDED.bp_pre_diastolic,
			hr_pre = EXCLUDED.hr_pre,
			bp_post_systolic = EXCLUDED.bp_post_systolic,
			bp_post_diastolic = EXCLUDED.bp_post_diastolic,
			hr_post = EXCLUDED.hr_post,
			updated_at = NOW()
	`

	// pgx.Batch is better for this, but looping inside a transaction is fine for a small array of 8 items.
	batch := &pgx.Batch{}
	for _, log := range logs {
		batch.Queue(query,
			log.ID, log.UserID, log.PeriodName, log.SessionNumber, log.Date, log.TookMedicine,
			log.LastMealHours, log.LastMealFood, log.BPPreSystolic, log.BPPreDiastolic, log.HRPre,
			log.BPPostSystolic, log.BPPostDiastolic, log.HRPost,
		)
	}

	br := tx.SendBatch(ctx, batch)
	for i := 0; i < len(logs); i++ {
		if _, err := br.Exec(); err != nil {
			br.Close()
			return err
		}
	}
	br.Close()

	return tx.Commit(ctx)
}
