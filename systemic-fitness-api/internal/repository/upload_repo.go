package repository

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/fitcoach/api/internal/model"
)

type UploadRepository struct {
	db *pgxpool.Pool
}

func NewUploadRepository(db *pgxpool.Pool) *UploadRepository {
	return &UploadRepository{db: db}
}

const uploadCols = `id, original_name, stored_name, mime_type, size_bytes,
	width, height, path, url, uploaded_by, entity_type, entity_id, created_at, deleted_at`

func scanUpload(row pgx.Row) (*model.Upload, error) {
	u := &model.Upload{}
	err := row.Scan(
		&u.ID, &u.OriginalName, &u.StoredName, &u.MimeType, &u.SizeBytes,
		&u.Width, &u.Height, &u.Path, &u.URL, &u.UploadedBy,
		&u.EntityType, &u.EntityID, &u.CreatedAt, &u.DeletedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return u, err
}

func (r *UploadRepository) Create(ctx context.Context, u *model.Upload) error {
	query := `
		INSERT INTO uploads (original_name, stored_name, mime_type, size_bytes,
			width, height, path, url, uploaded_by, entity_type, entity_id)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
		RETURNING id, created_at`
	return r.db.QueryRow(ctx, query,
		u.OriginalName, u.StoredName, u.MimeType, u.SizeBytes,
		u.Width, u.Height, u.Path, u.URL, u.UploadedBy,
		u.EntityType, u.EntityID,
	).Scan(&u.ID, &u.CreatedAt)
}

func (r *UploadRepository) GetByID(ctx context.Context, id string) (*model.Upload, error) {
	return scanUpload(r.db.QueryRow(ctx,
		`SELECT `+uploadCols+` FROM uploads WHERE id = $1 AND deleted_at IS NULL`, id))
}

func (r *UploadRepository) Delete(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx,
		`UPDATE uploads SET deleted_at = now() WHERE id = $1 AND deleted_at IS NULL`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (r *UploadRepository) LinkEntity(ctx context.Context, uploadID, entityType, entityID string) error {
	tag, err := r.db.Exec(ctx,
		`UPDATE uploads SET entity_type = $2, entity_id = $3 WHERE id = $1 AND deleted_at IS NULL`,
		uploadID, entityType, entityID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (r *UploadRepository) ListByEntity(ctx context.Context, entityType, entityID string) ([]model.Upload, error) {
	rows, err := r.db.Query(ctx,
		`SELECT `+uploadCols+` FROM uploads WHERE entity_type = $1 AND entity_id = $2 AND deleted_at IS NULL ORDER BY created_at DESC`,
		entityType, entityID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	uploads := make([]model.Upload, 0)
	for rows.Next() {
		var u model.Upload
		if err := rows.Scan(
			&u.ID, &u.OriginalName, &u.StoredName, &u.MimeType, &u.SizeBytes,
			&u.Width, &u.Height, &u.Path, &u.URL, &u.UploadedBy,
			&u.EntityType, &u.EntityID, &u.CreatedAt, &u.DeletedAt,
		); err != nil {
			return nil, err
		}
		uploads = append(uploads, u)
	}
	return uploads, rows.Err()
}

func (r *UploadRepository) ListByUser(ctx context.Context, userID string, params model.PaginationParams) ([]model.Upload, int, error) {
	where := "WHERE uploaded_by = $1 AND deleted_at IS NULL"
	args := []any{userID}

	var total int
	if err := r.db.QueryRow(ctx, "SELECT COUNT(*) FROM uploads "+where, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf("SELECT %s FROM uploads %s ORDER BY created_at DESC LIMIT $2 OFFSET $3", uploadCols, where)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	uploads := make([]model.Upload, 0)
	for rows.Next() {
		var u model.Upload
		if err := rows.Scan(
			&u.ID, &u.OriginalName, &u.StoredName, &u.MimeType, &u.SizeBytes,
			&u.Width, &u.Height, &u.Path, &u.URL, &u.UploadedBy,
			&u.EntityType, &u.EntityID, &u.CreatedAt, &u.DeletedAt,
		); err != nil {
			return nil, 0, err
		}
		uploads = append(uploads, u)
	}
	return uploads, total, rows.Err()
}
