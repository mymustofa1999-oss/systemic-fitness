package handler

import (
	"errors"
	"log/slog"
	"net/http"
	"strings"

	"github.com/go-chi/chi/v5"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/middleware"
	"github.com/fitcoach/api/internal/repository"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

type TrainerCardHandler struct {
	cardService *service.TrainerCardService
}

func NewTrainerCardHandler(cs *service.TrainerCardService) *TrainerCardHandler {
	return &TrainerCardHandler{cardService: cs}
}

// ────────────────────────────────────────────────────────────────
//  POST /api/v2/trainer-cards/{customer_id}/publish
// ────────────────────────────────────────────────────────────────

func (h *TrainerCardHandler) PublishCard(w http.ResponseWriter, r *http.Request) {
	customerID := chi.URLParam(r, "id")
	if customerID == "" {
		response.BadRequest(w, "customer_id is required")
		return
	}

	if err := h.cardService.PublishCard(r.Context(), customerID); err != nil {
		slog.Error("PublishCard failed", "customer_id", customerID, "error", err)
		if err.Error() == "not found" {
			response.NotFound(w, "Trainer card not found")
			return
		}
		response.InternalError(w, "Failed to publish training card")
		return
	}

	response.SuccessMessage(w, "Training card published successfully")
}

// ────────────────────────────────────────────────────────────────
//  GET /api/training-card-types
// ────────────────────────────────────────────────────────────────

func (h *TrainerCardHandler) ListTypes(w http.ResponseWriter, r *http.Request) {
	types, err := h.cardService.ListTypes(r.Context())
	if err != nil {
		slog.Error("[TrainingCard.ListTypes] failed", "error", err)
		response.InternalError(w, "Failed to fetch training card types")
		return
	}
	response.OK(w, types)
}

// ────────────────────────────────────────────────────────────────
//  POST /api/training-card-types
// ────────────────────────────────────────────────────────────────

func (h *TrainerCardHandler) CreateType(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Name        string  `json:"name"        validate:"required,min=1,max=50"`
		Description *string `json:"description,omitempty"`
		IsActive    *bool   `json:"is_active,omitempty"`
		SortOrder   int     `json:"sort_order"`
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

	t := &repository.TrainerCardType{
		Name:        input.Name,
		Description: input.Description,
		IsActive:    isActive,
		SortOrder:   input.SortOrder,
	}
	if err := h.cardService.CreateType(r.Context(), t); err != nil {
		slog.Error("[TrainingCard.CreateType] failed", "error", err)
		response.InternalError(w, "Failed to create training card type")
		return
	}
	response.Created(w, t)
}

// ────────────────────────────────────────────────────────────────
//  PUT /api/training-card-types/{id}
// ────────────────────────────────────────────────────────────────

func (h *TrainerCardHandler) UpdateType(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var input struct {
		Name        string  `json:"name"        validate:"required,min=1,max=50"`
		Description *string `json:"description,omitempty"`
		IsActive    *bool   `json:"is_active,omitempty"`
		SortOrder   int     `json:"sort_order"`
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

	t := &repository.TrainerCardType{
		Name:        input.Name,
		Description: input.Description,
		IsActive:    isActive,
		SortOrder:   input.SortOrder,
	}
	if err := h.cardService.UpdateType(r.Context(), id, t); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Training card type not found")
			return
		}
		slog.Error("[TrainingCard.UpdateType] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to update training card type")
		return
	}
	response.SuccessMessage(w, "Training card type updated")
}

// ────────────────────────────────────────────────────────────────
//  DELETE /api/training-card-types/{id}
// ────────────────────────────────────────────────────────────────

func (h *TrainerCardHandler) DeleteType(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.cardService.DeleteType(r.Context(), id); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Training card type not found")
			return
		}
		slog.Error("[TrainingCard.DeleteType] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to delete training card type")
		return
	}
	response.SuccessMessage(w, "Training card type deleted")
}

// ────────────────────────────────────────────────────────────────
//  GET /api/customers/{customerId}/training-card
// ────────────────────────────────────────────────────────────────

func (h *TrainerCardHandler) GetCard(w http.ResponseWriter, r *http.Request) {
	customerID := chi.URLParam(r, "id")
	card, err := h.cardService.GetByCustomerID(r.Context(), customerID)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.OK(w, nil)
			return
		}
		slog.Error("[TrainingCard.GetCard] failed", "customer_id", customerID, "error", err)
		response.InternalError(w, "Failed to fetch training card")
		return
	}

	// Hide draft cards from trainers
	userRole := middleware.GetRole(r.Context())
	if userRole == model.RoleTrainer && card.Status != "published" {
		response.OK(w, nil)
		return
	}

	response.OK(w, card)
}

// ────────────────────────────────────────────────────────────────
//  POST /api/customers/{customerId}/training-card
// ────────────────────────────────────────────────────────────────

type upsertSetItemInput struct {
	MovementID         *string `json:"movement_id,omitempty"`
	MovementName       *string `json:"movement_name,omitempty"`
	BodyPart           string  `json:"body_part"    validate:"required,oneof=upper lower core 'whole body'"`
	Equipment          *string `json:"equipment,omitempty"`
	Reps               *int    `json:"reps,omitempty"`
	SetsCount          *int    `json:"sets_count,omitempty"`
	SortOrder          int     `json:"sort_order"`
	BreathingCore      *string `json:"breathing_core,omitempty"`
	BreathingDiaphragm *string `json:"breathing_diaphragm,omitempty"`
}

type upsertSetInput struct {
	SetNumber          int                  `json:"set_number"      validate:"required,min=1"`
	Duration           *string              `json:"duration,omitempty"`
	EquipmentUpper     *string              `json:"equipment_upper,omitempty"`
	EquipmentLower     *string              `json:"equipment_lower,omitempty"`
	TypeID             *string              `json:"type_id,omitempty"`
	BPM                *string              `json:"bpm,omitempty"`
	ExtraLoad          *string              `json:"extra_load,omitempty"`
	Notes              *string              `json:"notes,omitempty"`
	SortOrder          int                  `json:"sort_order"`
	Pattern            *string              `json:"pattern,omitempty"`
	BreathingCore      *string              `json:"breathing_core,omitempty"`
	BreathingDiaphragm *string              `json:"breathing_diaphragm,omitempty"`
	Items              []upsertSetItemInput `json:"items"`
}

type upsertSequenceInput struct {
	ProgramCategoryID string           `json:"program_category_id" validate:"required"`
	Duration          *string          `json:"duration,omitempty"`
	SortOrder         int              `json:"sort_order"`
	Sets              []upsertSetInput `json:"sets"`
}

func (h *TrainerCardHandler) UpsertCard(w http.ResponseWriter, r *http.Request) {
	customerID := chi.URLParam(r, "id")

	var input struct {
		Level     string                `json:"level"     validate:"required,min=1,max=10"`
		Notes     *string               `json:"notes,omitempty"`
		Sequences []upsertSequenceInput `json:"sequences" validate:"required,min=1,dive"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	// Extract created_by from auth context
	createdBy := r.Context().Value("user_id")
	var createdByStr *string
	if uid, ok := createdBy.(string); ok {
		createdByStr = &uid
	}

	// Build domain model
	card := &repository.TrainerCard{
		CustomerID: customerID,
		Level:      input.Level,
		Notes:      input.Notes,
		CreatedBy:  createdByStr,
	}

	for si, seqIn := range input.Sequences {
		seq := repository.TrainerCardSequence{
			ProgramCategoryID: seqIn.ProgramCategoryID,
			Duration:          seqIn.Duration,
			SortOrder:         seqIn.SortOrder,
		}
		if seq.SortOrder == 0 {
			seq.SortOrder = si
		}

		for seti, setIn := range seqIn.Sets {
			set := repository.TrainerCardSet{
				SetNumber:          setIn.SetNumber,
				Duration:           setIn.Duration,
				EquipmentUpper:     setIn.EquipmentUpper,
				EquipmentLower:     setIn.EquipmentLower,
				TypeID:             setIn.TypeID,
				BPM:                setIn.BPM,
				ExtraLoad:          setIn.ExtraLoad,
				Notes:              setIn.Notes,
				SortOrder:          setIn.SortOrder,
				Pattern:            setIn.Pattern,
				BreathingCore:      setIn.BreathingCore,
				BreathingDiaphragm: setIn.BreathingDiaphragm,
			}
			if set.SortOrder == 0 {
				set.SortOrder = seti
			}

			for itemi, itemIn := range setIn.Items {
				item := repository.TrainerCardSetItem{
					MovementID:         itemIn.MovementID,
					MovementName:       itemIn.MovementName,
					BodyPart:           itemIn.BodyPart,
					Equipment:          itemIn.Equipment,
					Reps:               itemIn.Reps,
					SetsCount:          itemIn.SetsCount,
					SortOrder:          itemIn.SortOrder,
					BreathingCore:      itemIn.BreathingCore,
					BreathingDiaphragm: itemIn.BreathingDiaphragm,
				}
				if item.SortOrder == 0 {
					item.SortOrder = itemi
				}
				set.Items = append(set.Items, item)
			}

			seq.Sets = append(seq.Sets, set)
		}

		card.Sequences = append(card.Sequences, seq)
	}

	// A manual save is an explicit human edit: drop the auto-generated marker so
	// GetTrainingCard never regenerates (overwrites) these movements. The admin UI
	// re-sends whatever notes the card already had, which may still carry it.
	if card.Notes != nil && strings.Contains(*card.Notes, "Auto-generated") {
		cleaned := strings.TrimSpace(strings.ReplaceAll(*card.Notes, "Auto-generated upon subscription activation.", ""))
		if cleaned == "" {
			card.Notes = nil
		} else {
			card.Notes = &cleaned
		}
	}

	if err := h.cardService.UpsertCard(r.Context(), card); err != nil {
		slog.Error("[TrainingCard.UpsertCard] failed", "customer_id", customerID, "error", err)
		response.InternalError(w, "Failed to save training card")
		return
	}
	response.OK(w, card)
}

// ────────────────────────────────────────────────────────────────
//  DELETE /api/customers/{customerId}/training-card
// ────────────────────────────────────────────────────────────────

func (h *TrainerCardHandler) DeleteCard(w http.ResponseWriter, r *http.Request) {
	customerID := chi.URLParam(r, "id")
	if err := h.cardService.DeleteCard(r.Context(), customerID); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Training card not found")
			return
		}
		slog.Error("[TrainingCard.DeleteCard] failed", "customer_id", customerID, "error", err)
		response.InternalError(w, "Failed to delete training card")
		return
	}
	response.SuccessMessage(w, "Training card deleted")
}
