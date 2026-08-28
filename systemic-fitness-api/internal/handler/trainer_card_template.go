package handler

import (
	"errors"
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/fitcoach/api/internal/repository"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

type TrainerCardTemplateHandler struct {
	templateService *service.TrainerCardTemplateService
}

func NewTrainerCardTemplateHandler(s *service.TrainerCardTemplateService) *TrainerCardTemplateHandler {
	return &TrainerCardTemplateHandler{templateService: s}
}

// ────────────────────────────────────────────────────────────────
//  GET /api/training-card-templates
// ────────────────────────────────────────────────────────────────

func (h *TrainerCardTemplateHandler) ListTemplates(w http.ResponseWriter, r *http.Request) {
	templates, err := h.templateService.List(r.Context())
	if err != nil {
		slog.Error("[TemplateHandler.ListTemplates] failed", "error", err)
		response.InternalError(w, "Failed to fetch training card templates")
		return
	}
	response.OK(w, templates)
}

// ────────────────────────────────────────────────────────────────
//  GET /api/training-card-templates/{level}
// ────────────────────────────────────────────────────────────────

func (h *TrainerCardTemplateHandler) GetTemplate(w http.ResponseWriter, r *http.Request) {
	level := chi.URLParam(r, "level")
	tmpl, err := h.templateService.GetByLevel(r.Context(), level)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Template not found for this level")
			return
		}
		slog.Error("[TemplateHandler.GetTemplate] failed", "level", level, "error", err)
		response.InternalError(w, "Failed to fetch template")
		return
	}
	response.OK(w, tmpl)
}

// ────────────────────────────────────────────────────────────────
//  POST /api/training-card-templates/{level}
// ────────────────────────────────────────────────────────────────

type upsertTemplateSetItemInput struct {
	MovementID       *string  `json:"movement_id,omitempty"`
	MovementName     *string  `json:"movement_name,omitempty"`
	BodyPart         string   `json:"body_part"    validate:"required,oneof=upper lower core"`
	Equipment        *string  `json:"equipment,omitempty"`
	Reps             *int     `json:"reps,omitempty"`
	SetsCount        *int     `json:"sets_count,omitempty"`
	SortOrder        int      `json:"sort_order"`
	AllowedTiers     []string `json:"allowed_tiers,omitempty"`
	VideoURLSnapshot *string  `json:"video_url_snapshot,omitempty"`
}

type upsertTemplateSetInput struct {
	SetNumber      int                          `json:"set_number"      validate:"required,min=1"`
	Duration       *string                      `json:"duration,omitempty"`
	EquipmentUpper *string                      `json:"equipment_upper,omitempty"`
	EquipmentLower *string                      `json:"equipment_lower,omitempty"`
	TypeID         *string                      `json:"type_id,omitempty"`
	BPM            *string                      `json:"bpm,omitempty"`
	ExtraLoad      *string                      `json:"extra_load,omitempty"`
	Notes          *string                      `json:"notes,omitempty"`
	SortOrder      int                          `json:"sort_order"`
	Items          []upsertTemplateSetItemInput `json:"items"`
}

type upsertTemplateSequenceInput struct {
	ProgramCategoryID string                   `json:"program_category_id" validate:"required"`
	Duration          *string                  `json:"duration,omitempty"`
	SortOrder         int                      `json:"sort_order"`
	Sets              []upsertTemplateSetInput `json:"sets"`
}

func (h *TrainerCardTemplateHandler) UpsertTemplate(w http.ResponseWriter, r *http.Request) {
	level := chi.URLParam(r, "level")

	var input struct {
		Notes        *string                       `json:"notes,omitempty"`
		TargetGender *string                       `json:"target_gender,omitempty" validate:"omitempty,oneof=male female universal"`
		Sequences    []upsertTemplateSequenceInput `json:"sequences" validate:"required,min=1,dive"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	tmpl := &repository.TrainerCardTemplate{
		Level:        level,
		Notes:        input.Notes,
		TargetGender: input.TargetGender,
	}

	for si, seqIn := range input.Sequences {
		seq := repository.TrainerCardTemplateSequence{
			ProgramCategoryID: seqIn.ProgramCategoryID,
			Duration:          seqIn.Duration,
			SortOrder:         seqIn.SortOrder,
		}
		if seq.SortOrder == 0 {
			seq.SortOrder = si
		}

		for seti, setIn := range seqIn.Sets {
			set := repository.TrainerCardTemplateSet{
				SetNumber:      setIn.SetNumber,
				Duration:       setIn.Duration,
				EquipmentUpper: setIn.EquipmentUpper,
				EquipmentLower: setIn.EquipmentLower,
				TypeID:         setIn.TypeID,
				BPM:            setIn.BPM,
				ExtraLoad:      setIn.ExtraLoad,
				Notes:          setIn.Notes,
				SortOrder:      setIn.SortOrder,
			}
			if set.SortOrder == 0 {
				set.SortOrder = seti
			}

			for itemi, itemIn := range setIn.Items {
				item := repository.TrainerCardTemplateSetItem{
					MovementID:       itemIn.MovementID,
					MovementName:     itemIn.MovementName,
					BodyPart:         itemIn.BodyPart,
					Equipment:        itemIn.Equipment,
					Reps:             itemIn.Reps,
					SetsCount:        itemIn.SetsCount,
					SortOrder:        itemIn.SortOrder,
					AllowedTiers:     itemIn.AllowedTiers,
					VideoURLSnapshot: itemIn.VideoURLSnapshot,
				}
				if item.SortOrder == 0 {
					item.SortOrder = itemi
				}
				set.Items = append(set.Items, item)
			}
			seq.Sets = append(seq.Sets, set)
		}
		tmpl.Sequences = append(tmpl.Sequences, seq)
	}

	if err := h.templateService.UpsertTemplate(r.Context(), tmpl); err != nil {
		slog.Error("[TemplateHandler.UpsertTemplate] failed", "level", level, "error", err)
		response.InternalError(w, "Failed to save template")
		return
	}
	response.OK(w, tmpl)
}

// ────────────────────────────────────────────────────────────────
//  DELETE /api/training-card-templates/{level}
// ────────────────────────────────────────────────────────────────

func (h *TrainerCardTemplateHandler) DeleteTemplate(w http.ResponseWriter, r *http.Request) {
	level := chi.URLParam(r, "level")
	if err := h.templateService.DeleteTemplate(r.Context(), level); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Template not found")
			return
		}
		slog.Error("[TemplateHandler.DeleteTemplate] failed", "level", level, "error", err)
		response.InternalError(w, "Failed to delete template")
		return
	}
	response.SuccessMessage(w, "Template deleted")
}
