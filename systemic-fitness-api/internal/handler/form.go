package handler

import (
	"encoding/json"
	"errors"
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/fitcoach/api/internal/middleware"
	"github.com/fitcoach/api/internal/repository"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

type FormHandler struct {
	formService *service.FormService
}

func NewFormHandler(fs *service.FormService) *FormHandler {
	return &FormHandler{formService: fs}
}

// GET /api/forms
func (h *FormHandler) List(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	f := repository.FormListFilter{
		Status: queryString(r, "status"),
		Search: params.Search,
	}

	forms, meta, err := h.formService.List(r.Context(), params, f)
	if err != nil {
		slog.Error("[Form.List] failed", "error", err)
		response.InternalError(w, "Failed to fetch forms")
		return
	}
	response.OKPaginated(w, forms, meta)
}

// GET /api/forms/{id}
func (h *FormHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	form, err := h.formService.GetByID(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Form not found")
			return
		}
		response.InternalError(w, "Failed to fetch form")
		return
	}
	response.OK(w, form)
}

// POST /api/forms
func (h *FormHandler) Create(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Name        string `json:"name"        validate:"required,min=1,max=150"`
		Description *string `json:"description,omitempty"`
		Status      string `json:"status"      validate:"required,oneof=draft published archived"`
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
	form := &repository.Form{
		Name: input.Name, Description: input.Description,
		Status: input.Status, CreatedBy: &userID,
	}
	if err := h.formService.Create(r.Context(), form); err != nil {
		slog.Error("[Form.Create] failed", "error", err)
		response.InternalError(w, "Failed to create form")
		return
	}
	response.Created(w, form)
}

// PUT /api/forms/{id}
func (h *FormHandler) Update(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var input struct {
		Name        string  `json:"name"        validate:"required,min=1,max=150"`
		Description *string `json:"description,omitempty"`
		Status      string  `json:"status"      validate:"required,oneof=draft published archived"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	form := &repository.Form{ID: id, Name: input.Name, Description: input.Description, Status: input.Status}
	if err := h.formService.Update(r.Context(), form); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Form not found")
			return
		}
		response.InternalError(w, "Failed to update form")
		return
	}
	response.OK(w, form)
}

// DELETE /api/forms/{id}
func (h *FormHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.formService.Delete(r.Context(), id); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Form not found")
			return
		}
		response.InternalError(w, "Failed to delete form")
		return
	}
	response.SuccessMessage(w, "Form deleted")
}

// PUT /api/forms/{id}/fields
func (h *FormHandler) SaveFields(w http.ResponseWriter, r *http.Request) {
	formID := chi.URLParam(r, "id")
	var input struct {
		Fields []struct {
			Label     string           `json:"label"      validate:"required,min=1"`
			FieldType string           `json:"field_type"  validate:"required,oneof=text textarea number select multi_select checkbox radio date rating file_upload"`
			Required  bool             `json:"required"`
			Options   *json.RawMessage `json:"options,omitempty"`
		} `json:"fields" validate:"required"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}

	fields := make([]repository.FormField, len(input.Fields))
	for i, f := range input.Fields {
		fields[i] = repository.FormField{
			Label: f.Label, FieldType: f.FieldType,
			Required: f.Required, Options: f.Options,
		}
	}

	if err := h.formService.SaveFields(r.Context(), formID, fields); err != nil {
		slog.Error("[Form.SaveFields] failed", "form_id", formID, "error", err)
		response.InternalError(w, "Failed to save fields")
		return
	}
	response.SuccessMessage(w, "Fields saved")
}

// POST /api/forms/{id}/responses
func (h *FormHandler) SubmitResponse(w http.ResponseWriter, r *http.Request) {
	formID := chi.URLParam(r, "id")
	var input struct {
		Answers *json.RawMessage `json:"answers" validate:"required"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}

	userID := middleware.GetUserID(r.Context())
	resp := &repository.FormResponse{FormID: formID, UserID: userID, Answers: input.Answers}
	if err := h.formService.SubmitResponse(r.Context(), resp); err != nil {
		slog.Error("[Form.SubmitResponse] failed", "form_id", formID, "error", err)
		response.InternalError(w, "Failed to submit response")
		return
	}
	response.Created(w, resp)
}

// GET /api/forms/{id}/responses
func (h *FormHandler) ListResponses(w http.ResponseWriter, r *http.Request) {
	formID := chi.URLParam(r, "id")
	params := paginationFromQuery(r)

	responses, meta, err := h.formService.ListResponses(r.Context(), formID, params)
	if err != nil {
		slog.Error("[Form.ListResponses] failed", "form_id", formID, "error", err)
		response.InternalError(w, "Failed to fetch responses")
		return
	}
	response.OKPaginated(w, responses, meta)
}
