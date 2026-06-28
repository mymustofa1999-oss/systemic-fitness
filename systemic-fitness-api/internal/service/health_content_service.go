package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

type HealthContentService struct {
	healthRepo *repository.HealthContentRepository
	logger     *slog.Logger
}

func NewHealthContentService(hr *repository.HealthContentRepository, logger *slog.Logger) *HealthContentService {
	return &HealthContentService{healthRepo: hr, logger: logger}
}

// ─── Articles ────────────────────────────────────────────────────────

func (s *HealthContentService) CreateArticle(ctx context.Context, a *model.HealthArticle) error {
	if err := s.healthRepo.CreateArticle(ctx, a); err != nil {
		s.logger.Error("create health article", "title", a.Title, "error", err)
		return fmt.Errorf("creating health article: %w", err)
	}
	return nil
}

func (s *HealthContentService) GetArticleByID(ctx context.Context, id string) (*model.HealthArticle, error) {
	a, err := s.healthRepo.GetArticleByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get health article", "id", id, "error", err)
		}
		return nil, err
	}
	return a, nil
}

func (s *HealthContentService) UpdateArticle(ctx context.Context, a *model.HealthArticle) error {
	if err := s.healthRepo.UpdateArticle(ctx, a); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update health article", "id", a.ID, "error", err)
		}
		return err
	}
	return nil
}

func (s *HealthContentService) DeleteArticle(ctx context.Context, id string) error {
	if err := s.healthRepo.DeleteArticle(ctx, id); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("delete health article", "id", id, "error", err)
		}
		return err
	}
	return nil
}

func (s *HealthContentService) ListArticles(ctx context.Context, params model.PaginationParams, search string, publishedOnly bool) ([]model.HealthArticle, model.PaginationMeta, error) {
	articles, total, err := s.healthRepo.ListArticles(ctx, params.Limit, params.Offset(), search, publishedOnly)
	if err != nil {
		s.logger.Error("list health articles", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return articles, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

// ─── Videos ──────────────────────────────────────────────────────────

func (s *HealthContentService) CreateVideo(ctx context.Context, v *model.DoctorVideo) error {
	if err := s.healthRepo.CreateVideo(ctx, v); err != nil {
		s.logger.Error("create doctor video", "title", v.Title, "error", err)
		return fmt.Errorf("creating doctor video: %w", err)
	}
	return nil
}

func (s *HealthContentService) GetVideoByID(ctx context.Context, id string) (*model.DoctorVideo, error) {
	v, err := s.healthRepo.GetVideoByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get doctor video", "id", id, "error", err)
		}
		return nil, err
	}
	return v, nil
}

func (s *HealthContentService) UpdateVideo(ctx context.Context, v *model.DoctorVideo) error {
	if err := s.healthRepo.UpdateVideo(ctx, v); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update doctor video", "id", v.ID, "error", err)
		}
		return err
	}
	return nil
}

func (s *HealthContentService) DeleteVideo(ctx context.Context, id string) error {
	if err := s.healthRepo.DeleteVideo(ctx, id); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("delete doctor video", "id", id, "error", err)
		}
		return err
	}
	return nil
}

func (s *HealthContentService) ListVideos(ctx context.Context, params model.PaginationParams, search string, publishedOnly bool) ([]model.DoctorVideo, model.PaginationMeta, error) {
	videos, total, err := s.healthRepo.ListVideos(ctx, params.Limit, params.Offset(), search, publishedOnly)
	if err != nil {
		s.logger.Error("list doctor videos", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return videos, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}
