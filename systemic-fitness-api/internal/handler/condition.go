package handler

import (
	"encoding/json"
	"errors"
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

// ConditionHandler exposes SF master endpoints (Phase 1):
// - GET    /api/master/condition-classifications              (auth, all roles)
// - POST   /api/master/condition-classifications              (admin+)
// - GET    /api/master/condition-classifications/{id}         (auth)
// - PUT    /api/master/condition-classifications/{id}         (admin+)
// - DELETE /api/master/condition-classifications/{id}         (admin+)
// - GET    /api/master/specific-conditions[?classification=]  (auth)
// - POST   /api/master/specific-conditions                    (admin+)
// - GET    /api/master/specific-conditions/{id}               (auth)
// - PUT    /api/master/specific-conditions/{id}               (admin+)
// - DELETE /api/master/specific-conditions/{id}               (admin+)
// - GET    /api/master/physical-status-levels                 (auth)
type ConditionHandler struct {
	service *service.ConditionService
}

func NewConditionHandler(s *service.ConditionService) *ConditionHandler {
	return &ConditionHandler{service: s}
}

// ─── Condition Classifications ─────────────────────────────────────────

func (h *ConditionHandler) ListClassifications(w http.ResponseWriter, r *http.Request) {
	includeInactive := r.URL.Query().Get("include_inactive") == "true"
	out, err := h.service.ListClassifications(r.Context(), includeInactive)
	if err != nil {
		slog.Error("[Condition.ListClassifications] failed", "error", err)
		response.InternalError(w, "Failed to fetch condition classifications")
		return
	}
	response.OK(w, out)
}

func (h *ConditionHandler) GetClassification(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	c, err := h.service.GetClassification(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Classification not found")
			return
		}
		response.InternalError(w, "Failed to fetch classification")
		return
	}
	response.OK(w, c)
}

type classificationInput struct {
	Slug                 string          `json:"slug"                  validate:"required,min=2,max=64"`
	Label                string          `json:"label"                 validate:"required,min=1,max=120"`
	Description          *string         `json:"description,omitempty"`
	FocusPillar          string          `json:"focus_pillar"          validate:"required,oneof=FC CC MC"`
	FullProgramFormula   json.RawMessage `json:"full_program_formula,omitempty"`
	DailyResetFormula    json.RawMessage `json:"daily_reset_formula,omitempty"`
	SortOrder            int16           `json:"sort_order,omitempty"`
	IsActive             *bool           `json:"is_active,omitempty"`
}

func (h *ConditionHandler) CreateClassification(w http.ResponseWriter, r *http.Request) {
	var in classificationInput
	if err := response.DecodeJSON(r, &in); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&in); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	c := &repository.ConditionClassification{
		Slug:               in.Slug,
		Label:              in.Label,
		Description:        in.Description,
		FocusPillar:        model.FocusPillar(in.FocusPillar),
		FullProgramFormula: in.FullProgramFormula,
		DailyResetFormula:  in.DailyResetFormula,
		SortOrder:          in.SortOrder,
		IsActive:           true,
	}
	if in.IsActive != nil {
		c.IsActive = *in.IsActive
	}

	if err := h.service.CreateClassification(r.Context(), c); err != nil {
		response.InternalError(w, "Failed to create classification")
		return
	}
	response.Created(w, c)
}

func (h *ConditionHandler) UpdateClassification(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var in classificationInput
	if err := response.DecodeJSON(r, &in); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&in); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	c := &repository.ConditionClassification{
		ID:                 id,
		Slug:               in.Slug,
		Label:              in.Label,
		Description:        in.Description,
		FocusPillar:        model.FocusPillar(in.FocusPillar),
		FullProgramFormula: in.FullProgramFormula,
		DailyResetFormula:  in.DailyResetFormula,
		SortOrder:          in.SortOrder,
		IsActive:           true,
	}
	if in.IsActive != nil {
		c.IsActive = *in.IsActive
	}

	if err := h.service.UpdateClassification(r.Context(), c); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Classification not found")
			return
		}
		response.InternalError(w, "Failed to update classification")
		return
	}
	response.OK(w, c)
}

func (h *ConditionHandler) DeleteClassification(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.service.DeleteClassification(r.Context(), id); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Classification not found")
			return
		}
		response.InternalError(w, "Failed to delete classification")
		return
	}
	response.SuccessMessage(w, "Classification deleted")
}

// ─── Specific Conditions ───────────────────────────────────────────────

func (h *ConditionHandler) ListSpecificConditions(w http.ResponseWriter, r *http.Request) {
	f := repository.SpecificConditionFilter{
		ClassificationSlug: queryString(r, "classification"),
		IncludeInactive:    r.URL.Query().Get("include_inactive") == "true",
	}
	out, err := h.service.ListSpecificConditions(r.Context(), f)
	if err != nil {
		slog.Error("[Condition.ListSpecificConditions] failed", "error", err)
		response.InternalError(w, "Failed to fetch specific conditions")
		return
	}
	response.OK(w, out)
}

func (h *ConditionHandler) GetSpecific(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	sc, err := h.service.GetSpecific(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Specific condition not found")
			return
		}
		response.InternalError(w, "Failed to fetch specific condition")
		return
	}
	response.OK(w, sc)
}

type specificConditionInput struct {
	ClassificationID string          `json:"classification_id"          validate:"required,uuid"`
	Slug             string          `json:"slug"                       validate:"required,min=2,max=80"`
	Label            string          `json:"label"                      validate:"required,min=1,max=160"`
	Description      *string         `json:"description,omitempty"`
	SeverityDefault  *string         `json:"severity_default,omitempty" validate:"omitempty,oneof=mild moderate severe monitor"`
	Notes            json.RawMessage `json:"notes,omitempty"`
	SortOrder        int16           `json:"sort_order,omitempty"`
	IsActive         *bool           `json:"is_active,omitempty"`
}

func (h *ConditionHandler) CreateSpecific(w http.ResponseWriter, r *http.Request) {
	var in specificConditionInput
	if err := response.DecodeJSON(r, &in); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&in); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	sc := &repository.SpecificCondition{
		ClassificationID: in.ClassificationID,
		Slug:             in.Slug,
		Label:            in.Label,
		Description:      in.Description,
		SeverityDefault:  in.SeverityDefault,
		Notes:            in.Notes,
		SortOrder:        in.SortOrder,
		IsActive:         true,
	}
	if in.IsActive != nil {
		sc.IsActive = *in.IsActive
	}

	if err := h.service.CreateSpecific(r.Context(), sc); err != nil {
		response.InternalError(w, "Failed to create specific condition")
		return
	}
	response.Created(w, sc)
}

func (h *ConditionHandler) UpdateSpecific(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var in specificConditionInput
	if err := response.DecodeJSON(r, &in); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&in); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	sc := &repository.SpecificCondition{
		ID:               id,
		ClassificationID: in.ClassificationID,
		Slug:             in.Slug,
		Label:            in.Label,
		Description:      in.Description,
		SeverityDefault:  in.SeverityDefault,
		Notes:            in.Notes,
		SortOrder:        in.SortOrder,
		IsActive:         true,
	}
	if in.IsActive != nil {
		sc.IsActive = *in.IsActive
	}

	if err := h.service.UpdateSpecific(r.Context(), sc); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Specific condition not found")
			return
		}
		response.InternalError(w, "Failed to update specific condition")
		return
	}
	response.OK(w, sc)
}

func (h *ConditionHandler) DeleteSpecific(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.service.DeleteSpecific(r.Context(), id); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Specific condition not found")
			return
		}
		response.InternalError(w, "Failed to delete specific condition")
		return
	}
	response.SuccessMessage(w, "Specific condition deleted")
}

// ─── Physical Status Levels (read-only) ────────────────────────────────

func (h *ConditionHandler) ListPhysicalStatusLevels(w http.ResponseWriter, r *http.Request) {
	includeInactive := r.URL.Query().Get("include_inactive") == "true"
	out, err := h.service.ListPhysicalStatusLevels(r.Context(), includeInactive)
	if err != nil {
		slog.Error("[Condition.ListPhysicalStatusLevels] failed", "error", err)
		response.InternalError(w, "Failed to fetch physical status levels")
		return
	}
	response.OK(w, out)
}
