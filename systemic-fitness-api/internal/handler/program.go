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

type ProgramHandler struct {
	programService *service.ProgramService
}

func NewProgramHandler(ps *service.ProgramService) *ProgramHandler {
	return &ProgramHandler{programService: ps}
}

// GET /api/programs?difficulty=beginner&goal=gain_muscle&is_template=true&search=ppl&page=1&limit=20
func (h *ProgramHandler) List(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	f := repository.ProgramListFilter{
		Difficulty: queryString(r, "difficulty"),
		Goal:       queryString(r, "goal"),
		Search:     params.Search,
	}
	if v := r.URL.Query().Get("is_template"); v == "true" {
		t := true
		f.IsTemplate = &t
	} else if v == "false" {
		t := false
		f.IsTemplate = &t
	}

	programs, meta, err := h.programService.List(r.Context(), params, f)
	if err != nil {
		slog.Error("[Program.List] failed", "error", err)
		response.InternalError(w, "Failed to fetch programs")
		return
	}
	slog.Debug("[Program.List] success", "total", meta.Total)
	response.OKPaginated(w, programs, meta)
}

// GET /api/programs/templates
func (h *ProgramHandler) Templates(w http.ResponseWriter, r *http.Request) {
	templates, err := h.programService.ListTemplates(r.Context())
	if err != nil {
		slog.Error("[Program.Templates] failed", "error", err)
		response.InternalError(w, "Failed to fetch templates")
		return
	}
	slog.Debug("[Program.Templates] success", "count", len(templates))
	response.OK(w, templates)
}

// GET /api/programs/{id}
func (h *ProgramHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	detail, err := h.programService.GetDetail(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			slog.Warn("[Program.GetByID] not found", "id", id)
			response.NotFound(w, "Program not found")
			return
		}
		slog.Error("[Program.GetByID] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to fetch program")
		return
	}
	slog.Debug("[Program.GetByID] success", "id", id)
	response.OK(w, detail)
}

// POST /api/programs
func (h *ProgramHandler) Create(w http.ResponseWriter, r *http.Request) {
	var input service.CreateProgramInput
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Program.Create] invalid request body", "error", err)
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Program.Create] validation failed", "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	userID := middleware.GetUserID(r.Context())
	detail, err := h.programService.Create(r.Context(), &input, userID)
	if err != nil {
		slog.Error("[Program.Create] failed", "name", input.Name, "user_id", userID, "error", err)
		response.InternalError(w, err.Error())
		return
	}
	slog.Info("[Program.Create] success", "id", detail.ID, "name", input.Name, "user_id", userID)
	response.Created(w, detail)
}

// PUT /api/programs/{id}
func (h *ProgramHandler) Update(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var input service.UpdateProgramInput
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Program.Update] invalid request body", "id", id, "error", err)
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Program.Update] validation failed", "id", id, "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	detail, err := h.programService.Update(r.Context(), id, &input)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			slog.Warn("[Program.Update] not found", "id", id)
			response.NotFound(w, "Program not found")
			return
		}
		slog.Error("[Program.Update] failed", "id", id, "error", err)
		response.InternalError(w, err.Error())
		return
	}
	slog.Info("[Program.Update] success", "id", id)
	response.OK(w, detail)
}

// POST /api/programs/{id}/assign
func (h *ProgramHandler) Assign(w http.ResponseWriter, r *http.Request) {
	programID := chi.URLParam(r, "id")
	var input service.AssignProgramInput
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Program.Assign] invalid request body", "program_id", programID, "error", err)
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Program.Assign] validation failed", "program_id", programID, "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	assignedBy := middleware.GetUserID(r.Context())
	result, err := h.programService.Assign(r.Context(), programID, &input, assignedBy)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			slog.Warn("[Program.Assign] program not found", "program_id", programID)
			response.NotFound(w, "Program not found")
			return
		}
		slog.Error("[Program.Assign] failed", "program_id", programID, "error", err)
		response.BadRequest(w, err.Error())
		return
	}
	slog.Info("[Program.Assign] success", "program_id", programID, "assigned", result.Assigned, "failed", len(result.Failed))
	response.OKWithMessage(w, result, "Program assigned successfully")
}
