package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

type MenuService struct {
	menuRepo *repository.MenuRepository
	logger   *slog.Logger
}

func NewMenuService(menuRepo *repository.MenuRepository, logger *slog.Logger) *MenuService {
	return &MenuService{menuRepo: menuRepo, logger: logger}
}

// ════════════════════════════════════════════════════════════════════
//  Menu CRUD
// ════════════════════════════════════════════════════════════════════

func (s *MenuService) Create(ctx context.Context, m *repository.Menu) error {
	if err := s.menuRepo.Create(ctx, m); err != nil {
		s.logger.Error("create menu", "code", m.Code, "error", err)
		return fmt.Errorf("creating menu: %w", err)
	}
	s.logger.Info("menu created", "id", m.ID, "code", m.Code)
	return nil
}

func (s *MenuService) GetByID(ctx context.Context, id string) (*repository.Menu, error) {
	m, err := s.menuRepo.GetByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get menu", "id", id, "error", err)
		}
		return nil, err
	}
	return m, nil
}

func (s *MenuService) Update(ctx context.Context, m *repository.Menu) error {
	if err := s.menuRepo.Update(ctx, m); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update menu", "id", m.ID, "error", err)
		}
		return err
	}
	return nil
}

func (s *MenuService) Delete(ctx context.Context, id string) error {
	if err := s.menuRepo.Delete(ctx, id); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("delete menu", "id", id, "error", err)
		}
		return err
	}
	return nil
}

// ════════════════════════════════════════════════════════════════════
//  Queries
// ════════════════════════════════════════════════════════════════════

// ListAll returns a paginated flat list of all menus (admin view).
func (s *MenuService) ListAll(ctx context.Context, params model.PaginationParams) ([]repository.Menu, model.PaginationMeta, error) {
	menus, total, err := s.menuRepo.ListAll(ctx, params)
	if err != nil {
		s.logger.Error("list all menus", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return menus, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

// ListByRole returns the menu tree for a given role (active menus only).
func (s *MenuService) ListByRole(ctx context.Context, role string) ([]repository.Menu, error) {
	flatMenus, err := s.menuRepo.ListByRole(ctx, role)
	if err != nil {
		s.logger.Error("list menus by role", "role", role, "error", err)
		return nil, err
	}
	return buildTree(flatMenus), nil
}

// ListTree returns the full tree (all menus, for admin).
func (s *MenuService) ListTree(ctx context.Context) ([]repository.Menu, error) {
	flatMenus, err := s.menuRepo.ListTreeAll(ctx)
	if err != nil {
		s.logger.Error("list menu tree", "error", err)
		return nil, err
	}
	return buildTree(flatMenus), nil
}

// buildTree converts a flat list of menus into a nested tree structure.
func buildTree(flatMenus []repository.Menu) []repository.Menu {
	menuMap := make(map[string]*repository.Menu, len(flatMenus))
	for i := range flatMenus {
		flatMenus[i].Children = nil
		menuMap[flatMenus[i].ID] = &flatMenus[i]
	}

	roots := make([]repository.Menu, 0)
	for i := range flatMenus {
		m := &flatMenus[i]
		if m.ParentID == nil {
			roots = append(roots, *m)
		} else if parent, ok := menuMap[*m.ParentID]; ok {
			parent.Children = append(parent.Children, *m)
		}
	}

	// Copy children back to roots
	for i := range roots {
		if p, ok := menuMap[roots[i].ID]; ok {
			roots[i].Children = p.Children
		}
	}

	return roots
}

// ════════════════════════════════════════════════════════════════════
//  Privileges
// ════════════════════════════════════════════════════════════════════

func (s *MenuService) GetPrivileges(ctx context.Context, menuID string) ([]repository.MenuRolePrivilege, error) {
	privs, err := s.menuRepo.GetPrivilegesByMenuID(ctx, menuID)
	if err != nil {
		s.logger.Error("get menu privileges", "menu_id", menuID, "error", err)
		return nil, err
	}
	return privs, nil
}

func (s *MenuService) GetAllPrivileges(ctx context.Context) ([]repository.MenuRolePrivilege, error) {
	privs, err := s.menuRepo.GetAllPrivileges(ctx)
	if err != nil {
		s.logger.Error("get all privileges", "error", err)
		return nil, err
	}
	return privs, nil
}

func (s *MenuService) UpsertPrivileges(ctx context.Context, menuID string, privileges []repository.MenuRolePrivilege) error {
	if err := s.menuRepo.UpsertPrivileges(ctx, menuID, privileges); err != nil {
		s.logger.Error("upsert menu privileges", "menu_id", menuID, "error", err)
		return fmt.Errorf("upserting privileges: %w", err)
	}
	s.logger.Info("menu privileges updated", "menu_id", menuID)
	return nil
}

func (s *MenuService) BulkUpsertPrivileges(ctx context.Context, menuPrivileges map[string][]repository.MenuRolePrivilege) error {
	if err := s.menuRepo.BulkUpsertPrivileges(ctx, menuPrivileges); err != nil {
		s.logger.Error("bulk upsert privileges", "error", err)
		return fmt.Errorf("bulk upserting privileges: %w", err)
	}
	s.logger.Info("bulk privileges updated", "menu_count", len(menuPrivileges))
	return nil
}

// Reorder updates the sort order and parent of menus.
func (s *MenuService) Reorder(ctx context.Context, items []repository.MenuReorderItem) error {
	if err := s.menuRepo.Reorder(ctx, items); err != nil {
		s.logger.Error("reorder menus", "error", err)
		return fmt.Errorf("reordering menus: %w", err)
	}
	s.logger.Info("menus reordered", "count", len(items))
	return nil
}
