package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

type SchedulingService struct {
	schedulingRepo *repository.SchedulingRepository
	logger         *slog.Logger
}

func NewSchedulingService(sr *repository.SchedulingRepository, logger *slog.Logger) *SchedulingService {
	return &SchedulingService{schedulingRepo: sr, logger: logger}
}

// ─── Event Types ───────────────────────────────────────────────────

func (s *SchedulingService) CreateEventType(ctx context.Context, et *repository.EventType) error {
	if err := s.schedulingRepo.CreateEventType(ctx, et); err != nil {
		s.logger.Error("create event type", "name", et.Name, "error", err)
		return fmt.Errorf("creating event type: %w", err)
	}
	return nil
}

func (s *SchedulingService) GetEventType(ctx context.Context, id string) (*repository.EventType, error) {
	et, err := s.schedulingRepo.GetEventType(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get event type", "id", id, "error", err)
		}
		return nil, err
	}
	return et, nil
}

func (s *SchedulingService) UpdateEventType(ctx context.Context, et *repository.EventType) error {
	if err := s.schedulingRepo.UpdateEventType(ctx, et); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update event type", "id", et.ID, "error", err)
		}
		return err
	}
	return nil
}

func (s *SchedulingService) DeleteEventType(ctx context.Context, id string) error {
	if err := s.schedulingRepo.DeleteEventType(ctx, id); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("delete event type", "id", id, "error", err)
		}
		return err
	}
	return nil
}

func (s *SchedulingService) ListEventTypes(ctx context.Context) ([]repository.EventType, error) {
	types, err := s.schedulingRepo.ListEventTypes(ctx)
	if err != nil {
		s.logger.Error("list event types", "error", err)
		return nil, err
	}
	return types, nil
}

// ─── Calendar Events ───────────────────────────────────────────────

func (s *SchedulingService) CreateEvent(ctx context.Context, e *repository.CalendarEvent) error {
	if err := s.schedulingRepo.CreateEvent(ctx, e); err != nil {
		s.logger.Error("create calendar event", "title", e.Title, "error", err)
		return fmt.Errorf("creating calendar event: %w", err)
	}
	return nil
}

func (s *SchedulingService) GetEvent(ctx context.Context, id string) (*repository.CalendarEvent, error) {
	e, err := s.schedulingRepo.GetEvent(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get calendar event", "id", id, "error", err)
		}
		return nil, err
	}
	return e, nil
}

func (s *SchedulingService) UpdateEvent(ctx context.Context, e *repository.CalendarEvent) error {
	if err := s.schedulingRepo.UpdateEvent(ctx, e); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update calendar event", "id", e.ID, "error", err)
		}
		return err
	}
	return nil
}

func (s *SchedulingService) DeleteEvent(ctx context.Context, id string) error {
	if err := s.schedulingRepo.DeleteEvent(ctx, id); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("delete calendar event", "id", id, "error", err)
		}
		return err
	}
	return nil
}

func (s *SchedulingService) ListEvents(ctx context.Context, params model.PaginationParams, f repository.EventListFilter) ([]repository.CalendarEvent, model.PaginationMeta, error) {
	events, total, err := s.schedulingRepo.ListEvents(ctx, params, f)
	if err != nil {
		s.logger.Error("list calendar events", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return events, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

// ─── Participants ──────────────────────────────────────────────────

func (s *SchedulingService) AddParticipant(ctx context.Context, ep *repository.EventParticipant) error {
	if err := s.schedulingRepo.AddParticipant(ctx, ep); err != nil {
		s.logger.Error("add event participant", "event_id", ep.EventID, "user_id", ep.UserID, "error", err)
		return fmt.Errorf("adding participant: %w", err)
	}
	return nil
}

func (s *SchedulingService) ListParticipants(ctx context.Context, eventID string) ([]repository.EventParticipant, error) {
	p, err := s.schedulingRepo.ListParticipants(ctx, eventID)
	if err != nil {
		s.logger.Error("list event participants", "event_id", eventID, "error", err)
		return nil, err
	}
	return p, nil
}

func (s *SchedulingService) RemoveParticipant(ctx context.Context, eventID, userID string) error {
	return s.schedulingRepo.RemoveParticipant(ctx, eventID, userID)
}

// ─── Availability ──────────────────────────────────────────────────

func (s *SchedulingService) SetAvailability(ctx context.Context, a *repository.TrainerAvailability) error {
	if err := s.schedulingRepo.SetAvailability(ctx, a); err != nil {
		s.logger.Error("set availability", "trainer_id", a.TrainerID, "error", err)
		return fmt.Errorf("setting availability: %w", err)
	}
	return nil
}

func (s *SchedulingService) ListAvailability(ctx context.Context, trainerID string) ([]repository.TrainerAvailability, error) {
	slots, err := s.schedulingRepo.ListAvailability(ctx, trainerID)
	if err != nil {
		s.logger.Error("list availability", "trainer_id", trainerID, "error", err)
		return nil, err
	}
	return slots, nil
}

func (s *SchedulingService) DeleteAvailability(ctx context.Context, id string) error {
	return s.schedulingRepo.DeleteAvailability(ctx, id)
}
