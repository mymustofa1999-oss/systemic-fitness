package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"time"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

type AnnouncementService struct {
	announcementRepo *repository.AnnouncementRepository
	logger           *slog.Logger
}

func NewAnnouncementService(ar *repository.AnnouncementRepository, logger *slog.Logger) *AnnouncementService {
	return &AnnouncementService{announcementRepo: ar, logger: logger}
}

func (s *AnnouncementService) Create(ctx context.Context, a *repository.Announcement) error {
	if a.Status == "published" && a.PublishedAt == nil {
		now := time.Now()
		a.PublishedAt = &now
	}
	if err := s.announcementRepo.Create(ctx, a); err != nil {
		s.logger.Error("create announcement", "title", a.Title, "error", err)
		return fmt.Errorf("creating announcement: %w", err)
	}
	return nil
}

func (s *AnnouncementService) GetByID(ctx context.Context, id string) (*repository.Announcement, error) {
	a, err := s.announcementRepo.GetByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get announcement", "id", id, "error", err)
		}
		return nil, err
	}
	return a, nil
}

func (s *AnnouncementService) Update(ctx context.Context, a *repository.Announcement) error {
	if a.Status == "published" && a.PublishedAt == nil {
		now := time.Now()
		a.PublishedAt = &now
	}
	if err := s.announcementRepo.Update(ctx, a); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update announcement", "id", a.ID, "error", err)
		}
		return err
	}
	return nil
}

func (s *AnnouncementService) Delete(ctx context.Context, id string) error {
	if err := s.announcementRepo.Delete(ctx, id); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("delete announcement", "id", id, "error", err)
		}
		return err
	}
	return nil
}

func (s *AnnouncementService) List(ctx context.Context, params model.PaginationParams, f repository.AnnouncementListFilter) ([]repository.Announcement, model.PaginationMeta, error) {
	announcements, total, err := s.announcementRepo.List(ctx, params, f)
	if err != nil {
		s.logger.Error("list announcements", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return announcements, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

func (s *AnnouncementService) ListPublished(ctx context.Context, role string, params model.PaginationParams) ([]repository.Announcement, model.PaginationMeta, error) {
	announcements, total, err := s.announcementRepo.ListPublished(ctx, role, params)
	if err != nil {
		s.logger.Error("list published announcements", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return announcements, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

func (s *AnnouncementService) MarkAsRead(ctx context.Context, announcementID, userID string) error {
	return s.announcementRepo.MarkAsRead(ctx, announcementID, userID)
}
