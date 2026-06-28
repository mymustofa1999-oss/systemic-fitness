package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

type GroupService struct {
	groupRepo *repository.GroupRepository
	logger    *slog.Logger
}

func NewGroupService(gr *repository.GroupRepository, logger *slog.Logger) *GroupService {
	return &GroupService{groupRepo: gr, logger: logger}
}

func (s *GroupService) Create(ctx context.Context, g *repository.Group) error {
	if err := s.groupRepo.Create(ctx, g); err != nil {
		s.logger.Error("create group", "name", g.Name, "error", err)
		return fmt.Errorf("creating group: %w", err)
	}
	return nil
}

func (s *GroupService) GetByID(ctx context.Context, id string) (*repository.Group, error) {
	g, err := s.groupRepo.GetByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get group", "id", id, "error", err)
		}
		return nil, err
	}
	return g, nil
}

func (s *GroupService) Update(ctx context.Context, g *repository.Group) error {
	if err := s.groupRepo.Update(ctx, g); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update group", "id", g.ID, "error", err)
		}
		return err
	}
	return nil
}

func (s *GroupService) Delete(ctx context.Context, id string) error {
	if err := s.groupRepo.Delete(ctx, id); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("delete group", "id", id, "error", err)
		}
		return err
	}
	return nil
}

func (s *GroupService) List(ctx context.Context, params model.PaginationParams, search string) ([]repository.Group, model.PaginationMeta, error) {
	groups, total, err := s.groupRepo.List(ctx, params, search)
	if err != nil {
		s.logger.Error("list groups", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return groups, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

func (s *GroupService) AddMember(ctx context.Context, gm *repository.GroupMember) error {
	if err := s.groupRepo.AddMember(ctx, gm); err != nil {
		s.logger.Error("add group member", "group_id", gm.GroupID, "user_id", gm.UserID, "error", err)
		return fmt.Errorf("adding member: %w", err)
	}
	return nil
}

func (s *GroupService) RemoveMember(ctx context.Context, groupID, userID string) error {
	return s.groupRepo.RemoveMember(ctx, groupID, userID)
}

func (s *GroupService) ListMembers(ctx context.Context, groupID string) ([]repository.GroupMember, error) {
	members, err := s.groupRepo.ListMembers(ctx, groupID)
	if err != nil {
		s.logger.Error("list group members", "group_id", groupID, "error", err)
		return nil, err
	}
	return members, nil
}
