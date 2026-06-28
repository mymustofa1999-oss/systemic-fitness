package repository

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/fitcoach/api/internal/model"
)

type HealthContentRepository struct {
	db *pgxpool.Pool
}

func NewHealthContentRepository(db *pgxpool.Pool) *HealthContentRepository {
	return &HealthContentRepository{db: db}
}

// ════════════════════════════════════════════════════════════
//  Health Articles Methods
// ════════════════════════════════════════════════════════════

const healthArticleCols = "id, title, content, image_url, source, is_published, created_at, updated_at, title_en, content_en"

func scanHealthArticle(row pgx.Row) (*model.HealthArticle, error) {
	a := &model.HealthArticle{}
	err := row.Scan(&a.ID, &a.Title, &a.Content, &a.ImageURL, &a.Source, &a.IsPublished, &a.CreatedAt, &a.UpdatedAt, &a.TitleEN, &a.ContentEN)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return a, err
}

func (r *HealthContentRepository) CreateArticle(ctx context.Context, a *model.HealthArticle) error {
	query := `
		INSERT INTO health_articles (title, content, image_url, source, is_published, title_en, content_en)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query, a.Title, a.Content, a.ImageURL, a.Source, a.IsPublished, a.TitleEN, a.ContentEN).
		Scan(&a.ID, &a.CreatedAt, &a.UpdatedAt)
}

func (r *HealthContentRepository) GetArticleByID(ctx context.Context, id string) (*model.HealthArticle, error) {
	query := fmt.Sprintf("SELECT %s FROM health_articles WHERE id = $1", healthArticleCols)
	return scanHealthArticle(r.db.QueryRow(ctx, query, id))
}

func (r *HealthContentRepository) UpdateArticle(ctx context.Context, a *model.HealthArticle) error {
	query := `
		UPDATE health_articles SET
			title = $2, content = $3, image_url = $4, source = $5, is_published = $6, title_en = $7, content_en = $8, updated_at = NOW()
		WHERE id = $1 RETURNING updated_at`
	err := r.db.QueryRow(ctx, query, a.ID, a.Title, a.Content, a.ImageURL, a.Source, a.IsPublished, a.TitleEN, a.ContentEN).
		Scan(&a.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r *HealthContentRepository) DeleteArticle(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, "DELETE FROM health_articles WHERE id = $1", id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (r *HealthContentRepository) ListArticles(ctx context.Context, limit, offset int, search string, publishedOnly bool) ([]model.HealthArticle, int, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1

	if publishedOnly {
		where += fmt.Sprintf(" AND is_published = $%d", idx)
		args = append(args, true)
		idx++
	}

	if search != "" {
		where += fmt.Sprintf(" AND (title ILIKE $%d OR content ILIKE $%d)", idx, idx)
		args = append(args, "%"+search+"%")
		idx++
	}

	var total int
	if err := r.db.QueryRow(ctx, "SELECT COUNT(*) FROM health_articles "+where, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf("SELECT %s FROM health_articles %s ORDER BY created_at DESC LIMIT $%d OFFSET $%d",
		healthArticleCols, where, idx, idx+1)
	args = append(args, limit, offset)

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	articles := make([]model.HealthArticle, 0)
	for rows.Next() {
		var a model.HealthArticle
		if err := rows.Scan(&a.ID, &a.Title, &a.Content, &a.ImageURL, &a.Source, &a.IsPublished, &a.CreatedAt, &a.UpdatedAt, &a.TitleEN, &a.ContentEN); err != nil {
			return nil, 0, err
		}
		articles = append(articles, a)
	}
	return articles, total, rows.Err()
}

// ════════════════════════════════════════════════════════════
//  Doctor Videos Methods
// ════════════════════════════════════════════════════════════

const doctorVideoCols = "id, title, description, video_url, thumbnail_url, doctor_name, doctor_specialty, is_published, created_at, updated_at, title_en, description_en"

func scanDoctorVideo(row pgx.Row) (*model.DoctorVideo, error) {
	v := &model.DoctorVideo{}
	err := row.Scan(&v.ID, &v.Title, &v.Description, &v.VideoURL, &v.ThumbnailURL, &v.DoctorName, &v.DoctorSpecialty, &v.IsPublished, &v.CreatedAt, &v.UpdatedAt, &v.TitleEN, &v.DescriptionEN)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return v, err
}

func (r *HealthContentRepository) CreateVideo(ctx context.Context, v *model.DoctorVideo) error {
	query := `
		INSERT INTO doctor_videos (title, description, video_url, thumbnail_url, doctor_name, doctor_specialty, is_published, title_en, description_en)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query, v.Title, v.Description, v.VideoURL, v.ThumbnailURL, v.DoctorName, v.DoctorSpecialty, v.IsPublished, v.TitleEN, v.DescriptionEN).
		Scan(&v.ID, &v.CreatedAt, &v.UpdatedAt)
}

func (r *HealthContentRepository) GetVideoByID(ctx context.Context, id string) (*model.DoctorVideo, error) {
	query := fmt.Sprintf("SELECT %s FROM doctor_videos WHERE id = $1", doctorVideoCols)
	return scanDoctorVideo(r.db.QueryRow(ctx, query, id))
}

func (r *HealthContentRepository) UpdateVideo(ctx context.Context, v *model.DoctorVideo) error {
	query := `
		UPDATE doctor_videos SET
			title = $2, description = $3, video_url = $4, thumbnail_url = $5, doctor_name = $6, doctor_specialty = $7, is_published = $8, title_en = $9, description_en = $10, updated_at = NOW()
		WHERE id = $1 RETURNING updated_at`
	err := r.db.QueryRow(ctx, query, v.ID, v.Title, v.Description, v.VideoURL, v.ThumbnailURL, v.DoctorName, v.DoctorSpecialty, v.IsPublished, v.TitleEN, v.DescriptionEN).
		Scan(&v.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r *HealthContentRepository) DeleteVideo(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, "DELETE FROM doctor_videos WHERE id = $1", id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (r *HealthContentRepository) ListVideos(ctx context.Context, limit, offset int, search string, publishedOnly bool) ([]model.DoctorVideo, int, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1

	if publishedOnly {
		where += fmt.Sprintf(" AND is_published = $%d", idx)
		args = append(args, true)
		idx++
	}

	if search != "" {
		where += fmt.Sprintf(" AND (title ILIKE $%d OR description ILIKE $%d OR doctor_name ILIKE $%d)", idx, idx, idx)
		args = append(args, "%"+search+"%")
		idx++
	}

	var total int
	if err := r.db.QueryRow(ctx, "SELECT COUNT(*) FROM doctor_videos "+where, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf("SELECT %s FROM doctor_videos %s ORDER BY created_at DESC LIMIT $%d OFFSET $%d",
		doctorVideoCols, where, idx, idx+1)
	args = append(args, limit, offset)

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	videos := make([]model.DoctorVideo, 0)
	for rows.Next() {
		var v model.DoctorVideo
		if err := rows.Scan(&v.ID, &v.Title, &v.Description, &v.VideoURL, &v.ThumbnailURL, &v.DoctorName, &v.DoctorSpecialty, &v.IsPublished, &v.CreatedAt, &v.UpdatedAt, &v.TitleEN, &v.DescriptionEN); err != nil {
			return nil, 0, err
		}
		videos = append(videos, v)
	}
	return videos, total, rows.Err()
}
