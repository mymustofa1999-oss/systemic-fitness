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

type HabitHandler struct {
	habitService *service.HabitService
	images       *imageResolver
}

func NewHabitHandler(hs *service.HabitService, us *service.UploadService) *HabitHandler {
	return &HabitHandler{habitService: hs, images: &imageResolver{uploadService: us}}
}

// ─── Folders ───────────────────────────────────────────────────────

// GET /api/habits/folders
func (h *HabitHandler) ListFolders(w http.ResponseWriter, r *http.Request) {
	folders, err := h.habitService.ListFolders(r.Context())
	if err != nil {
		slog.Error("[Habit.ListFolders] failed", "error", err)
		response.InternalError(w, "Failed to fetch habit folders")
		return
	}
	response.OK(w, folders)
}

// POST /api/habits/folders
func (h *HabitHandler) CreateFolder(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Name      string `json:"name"       validate:"required,min=1,max=100"`
		SortOrder int    `json:"sort_order"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	userID := middleware.GetUserID(r.Context())
	f := &repository.HabitFolder{Name: input.Name, SortOrder: input.SortOrder, CreatedBy: &userID}
	if err := h.habitService.CreateFolder(r.Context(), f); err != nil {
		slog.Error("[Habit.CreateFolder] failed", "error", err)
		response.InternalError(w, "Failed to create folder")
		return
	}
	response.Created(w, f)
}

// PUT /api/habits/folders/{id}
func (h *HabitHandler) UpdateFolder(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var input struct {
		Name      string `json:"name"       validate:"required,min=1,max=100"`
		SortOrder int    `json:"sort_order"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	f := &repository.HabitFolder{ID: id, Name: input.Name, SortOrder: input.SortOrder}
	if err := h.habitService.UpdateFolder(r.Context(), f); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Folder not found")
			return
		}
		response.InternalError(w, "Failed to update folder")
		return
	}
	response.OK(w, f)
}

// DELETE /api/habits/folders/{id}
func (h *HabitHandler) DeleteFolder(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.habitService.DeleteFolder(r.Context(), id); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Folder not found")
			return
		}
		response.InternalError(w, "Failed to delete folder")
		return
	}
	response.SuccessMessage(w, "Folder deleted")
}

// ─── Habits ────────────────────────────────────────────────────────

// GET /api/habits
func (h *HabitHandler) List(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	f := repository.HabitListFilter{
		FolderID: queryString(r, "folder_id"),
		Search:   params.Search,
	}

	habits, meta, err := h.habitService.List(r.Context(), params, f)
	if err != nil {
		slog.Error("[Habit.List] failed", "error", err)
		response.InternalError(w, "Failed to fetch habits")
		return
	}
	response.OKPaginated(w, habits, meta)
}

// GET /api/habits/{id}
func (h *HabitHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	habit, err := h.habitService.GetByID(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Habit not found")
			return
		}
		response.InternalError(w, "Failed to fetch habit")
		return
	}
	response.OK(w, habit)
}

// POST /api/habits
func (h *HabitHandler) Create(w http.ResponseWriter, r *http.Request) {
	var input struct {
		FolderID    *string `json:"folder_id,omitempty"`
		Name        string  `json:"name"        validate:"required,min=1,max=150"`
		Description *string `json:"description,omitempty"`
		Icon        *string `json:"icon,omitempty"`
		IconImageID string  `json:"icon_image_id,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	userID := middleware.GetUserID(r.Context())

	// If icon_image_id is provided, resolve upload URL as icon
	icon := input.Icon
	if input.IconImageID != "" {
		resolved := h.images.resolve(r.Context(), input.IconImageID, nil, "habit", "")
		if resolved != nil {
			icon = resolved
		}
	}

	habit := &repository.Habit{
		FolderID:    input.FolderID,
		Name:        input.Name,
		Description: input.Description,
		Icon:        icon,
		CreatedBy:   &userID,
	}
	if err := h.habitService.Create(r.Context(), habit); err != nil {
		slog.Error("[Habit.Create] failed", "error", err)
		response.InternalError(w, "Failed to create habit")
		return
	}
	if input.IconImageID != "" {
		h.images.resolve(r.Context(), input.IconImageID, nil, "habit", habit.ID)
	}
	response.Created(w, habit)
}

// PUT /api/habits/{id}
func (h *HabitHandler) Update(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var input struct {
		FolderID    *string `json:"folder_id,omitempty"`
		Name        string  `json:"name"        validate:"required,min=1,max=150"`
		Description *string `json:"description,omitempty"`
		Icon        *string `json:"icon,omitempty"`
		IconImageID string  `json:"icon_image_id,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	icon := input.Icon
	if input.IconImageID != "" {
		resolved := h.images.resolve(r.Context(), input.IconImageID, nil, "habit", id)
		if resolved != nil {
			icon = resolved
		}
	}

	habit := &repository.Habit{
		ID: id, FolderID: input.FolderID, Name: input.Name,
		Description: input.Description, Icon: icon,
	}
	if err := h.habitService.Update(r.Context(), habit); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Habit not found")
			return
		}
		response.InternalError(w, "Failed to update habit")
		return
	}
	response.OK(w, habit)
}

// DELETE /api/habits/{id}
func (h *HabitHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.habitService.Delete(r.Context(), id); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Habit not found")
			return
		}
		response.InternalError(w, "Failed to delete habit")
		return
	}
	response.SuccessMessage(w, "Habit deleted")
}

// ─── Habit Logs ────────────────────────────────────────────────────

// POST /api/habits/log
func (h *HabitHandler) LogHabit(w http.ResponseWriter, r *http.Request) {
	var input struct {
		HabitID   string  `json:"habit_id"   validate:"required"`
		LoggedAt  string  `json:"logged_at"  validate:"required"`
		Completed bool    `json:"completed"`
		Notes     *string `json:"notes,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	userID := middleware.GetUserID(r.Context())
	log := &repository.HabitLog{
		UserID: userID, HabitID: input.HabitID, LoggedAt: input.LoggedAt,
		Completed: input.Completed, Notes: input.Notes,
	}
	if err := h.habitService.LogHabit(r.Context(), log); err != nil {
		slog.Error("[Habit.Log] failed", "error", err)
		response.InternalError(w, "Failed to log habit")
		return
	}
	response.Created(w, log)
}

// GET /api/habits/user/{id}/logs?start_date=2026-01-01&end_date=2026-01-31
func (h *HabitHandler) GetUserLogs(w http.ResponseWriter, r *http.Request) {
	userID := chi.URLParam(r, "id")
	startDate := r.URL.Query().Get("start_date")
	endDate := r.URL.Query().Get("end_date")
	if startDate == "" || endDate == "" {
		response.BadRequest(w, "start_date and end_date are required")
		return
	}

	logs, err := h.habitService.GetUserHabitLogs(r.Context(), userID, startDate, endDate)
	if err != nil {
		slog.Error("[Habit.GetUserLogs] failed", "user_id", userID, "error", err)
		response.InternalError(w, "Failed to fetch habit logs")
		return
	}
	response.OK(w, logs)
}
