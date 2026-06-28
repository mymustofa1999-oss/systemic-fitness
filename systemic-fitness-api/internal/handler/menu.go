package handler

import (
	"errors"
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/fitcoach/api/internal/middleware"
	"github.com/fitcoach/api/internal/repository"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

type MenuHandler struct {
	menuService *service.MenuService
}

func NewMenuHandler(ms *service.MenuService) *MenuHandler {
	return &MenuHandler{menuService: ms}
}

// ════════════════════════════════════════════════════════════════════
//  Public: GET /api/menus/my  — menus for the current user's role
// ════════════════════════════════════════════════════════════════════

func (h *MenuHandler) MyMenus(w http.ResponseWriter, r *http.Request) {
	role := string(middleware.GetRole(r.Context()))
	menus, err := h.menuService.ListByRole(r.Context(), role)
	if err != nil {
		slog.Error("[Menu.MyMenus] failed", "role", role, "error", err)
		response.InternalError(w, "Failed to fetch menus")
		return
	}
	response.OK(w, menus)
}

// ════════════════════════════════════════════════════════════════════
//  Admin: Menu CRUD
// ════════════════════════════════════════════════════════════════════

// GET /api/menus — list all menus (admin, paginated flat list)
func (h *MenuHandler) List(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	menus, meta, err := h.menuService.ListAll(r.Context(), params)
	if err != nil {
		slog.Error("[Menu.List] failed", "error", err)
		response.InternalError(w, "Failed to fetch menus")
		return
	}
	response.OKPaginated(w, menus, meta)
}

// GET /api/menus/tree — full menu tree (admin view)
func (h *MenuHandler) Tree(w http.ResponseWriter, r *http.Request) {
	menus, err := h.menuService.ListTree(r.Context())
	if err != nil {
		slog.Error("[Menu.Tree] failed", "error", err)
		response.InternalError(w, "Failed to fetch menu tree")
		return
	}
	response.OK(w, menus)
}

// GET /api/menus/{id}
func (h *MenuHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	m, err := h.menuService.GetByID(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Menu not found")
			return
		}
		slog.Error("[Menu.GetByID] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to fetch menu")
		return
	}
	response.OK(w, m)
}

// POST /api/menus
func (h *MenuHandler) Create(w http.ResponseWriter, r *http.Request) {
	var input struct {
		ParentID  *string `json:"parent_id,omitempty"`
		Code      string  `json:"code"      validate:"required,min=1,max=50"`
		Label     string  `json:"label"     validate:"required,min=1,max=100"`
		Icon      *string `json:"icon,omitempty"`
		Href      *string `json:"href,omitempty"`
		SortOrder int     `json:"sort_order"`
		IsActive  *bool   `json:"is_active,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	isActive := true
	if input.IsActive != nil {
		isActive = *input.IsActive
	}

	m := &repository.Menu{
		ParentID:  input.ParentID,
		Code:      input.Code,
		Label:     input.Label,
		Icon:      input.Icon,
		Href:      input.Href,
		SortOrder: input.SortOrder,
		IsActive:  isActive,
	}

	if err := h.menuService.Create(r.Context(), m); err != nil {
		slog.Error("[Menu.Create] failed", "code", input.Code, "error", err)
		response.InternalError(w, "Failed to create menu")
		return
	}

	slog.Info("[Menu.Create] success", "id", m.ID, "code", m.Code)
	response.Created(w, m)
}

// PUT /api/menus/{id}
func (h *MenuHandler) Update(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var input struct {
		ParentID  *string `json:"parent_id,omitempty"`
		Code      string  `json:"code"      validate:"required,min=1,max=50"`
		Label     string  `json:"label"     validate:"required,min=1,max=100"`
		Icon      *string `json:"icon,omitempty"`
		Href      *string `json:"href,omitempty"`
		SortOrder int     `json:"sort_order"`
		IsActive  *bool   `json:"is_active,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	isActive := true
	if input.IsActive != nil {
		isActive = *input.IsActive
	}

	m := &repository.Menu{
		ID:        id,
		ParentID:  input.ParentID,
		Code:      input.Code,
		Label:     input.Label,
		Icon:      input.Icon,
		Href:      input.Href,
		SortOrder: input.SortOrder,
		IsActive:  isActive,
	}

	if err := h.menuService.Update(r.Context(), m); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Menu not found")
			return
		}
		slog.Error("[Menu.Update] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to update menu")
		return
	}
	response.OK(w, m)
}

// DELETE /api/menus/{id}
func (h *MenuHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.menuService.Delete(r.Context(), id); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Menu not found")
			return
		}
		slog.Error("[Menu.Delete] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to delete menu")
		return
	}
	response.SuccessMessage(w, "Menu deleted")
}

// ════════════════════════════════════════════════════════════════════
//  Privileges
// ════════════════════════════════════════════════════════════════════

// GET /api/menus/privileges — all privileges (admin)
func (h *MenuHandler) ListPrivileges(w http.ResponseWriter, r *http.Request) {
	privs, err := h.menuService.GetAllPrivileges(r.Context())
	if err != nil {
		slog.Error("[Menu.ListPrivileges] failed", "error", err)
		response.InternalError(w, "Failed to fetch privileges")
		return
	}
	response.OK(w, privs)
}

// GET /api/menus/{id}/privileges
func (h *MenuHandler) GetPrivileges(w http.ResponseWriter, r *http.Request) {
	menuID := chi.URLParam(r, "id")
	privs, err := h.menuService.GetPrivileges(r.Context(), menuID)
	if err != nil {
		slog.Error("[Menu.GetPrivileges] failed", "menu_id", menuID, "error", err)
		response.InternalError(w, "Failed to fetch privileges")
		return
	}
	response.OK(w, privs)
}

// PUT /api/menus/{id}/privileges
func (h *MenuHandler) UpsertPrivileges(w http.ResponseWriter, r *http.Request) {
	menuID := chi.URLParam(r, "id")
	var input struct {
		Privileges []struct {
			Role      string `json:"role"       validate:"required"`
			CanAccess bool   `json:"can_access"`
		} `json:"privileges" validate:"required,min=1"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}

	privileges := make([]repository.MenuRolePrivilege, 0, len(input.Privileges))
	for _, p := range input.Privileges {
		privileges = append(privileges, repository.MenuRolePrivilege{
			MenuID:    menuID,
			Role:      p.Role,
			CanAccess: p.CanAccess,
		})
	}

	if err := h.menuService.UpsertPrivileges(r.Context(), menuID, privileges); err != nil {
		slog.Error("[Menu.UpsertPrivileges] failed", "menu_id", menuID, "error", err)
		response.InternalError(w, "Failed to update privileges")
		return
	}
	response.SuccessMessage(w, "Privileges updated")
}

// PUT /api/menus/privileges/bulk
func (h *MenuHandler) BulkUpsertPrivileges(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Items []struct {
			MenuID     string `json:"menu_id"     validate:"required"`
			Privileges []struct {
				Role      string `json:"role"       validate:"required"`
				CanAccess bool   `json:"can_access"`
			} `json:"privileges" validate:"required"`
		} `json:"items" validate:"required,min=1"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}

	menuPrivileges := make(map[string][]repository.MenuRolePrivilege, len(input.Items))
	for _, item := range input.Items {
		privs := make([]repository.MenuRolePrivilege, 0, len(item.Privileges))
		for _, p := range item.Privileges {
			privs = append(privs, repository.MenuRolePrivilege{
				MenuID:    item.MenuID,
				Role:      p.Role,
				CanAccess: p.CanAccess,
			})
		}
		menuPrivileges[item.MenuID] = privs
	}

	if err := h.menuService.BulkUpsertPrivileges(r.Context(), menuPrivileges); err != nil {
		slog.Error("[Menu.BulkUpsertPrivileges] failed", "error", err)
		response.InternalError(w, "Failed to update privileges")
		return
	}
	response.SuccessMessage(w, "Bulk privileges updated")
}

// ════════════════════════════════════════════════════════════════════
//  Reorder
// ════════════════════════════════════════════════════════════════════

// POST /api/menus/reorder
func (h *MenuHandler) Reorder(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Items []repository.MenuReorderItem `json:"items" validate:"required,min=1"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}

	if err := h.menuService.Reorder(r.Context(), input.Items); err != nil {
		slog.Error("[Menu.Reorder] failed", "error", err)
		response.InternalError(w, "Failed to reorder menus")
		return
	}
	response.SuccessMessage(w, "Menus reordered")
}
