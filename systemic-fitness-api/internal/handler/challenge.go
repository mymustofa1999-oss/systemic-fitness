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

type ChallengeHandler struct {
	challengeService *service.ChallengeService
	images           *imageResolver
}

func NewChallengeHandler(cs *service.ChallengeService, us *service.UploadService) *ChallengeHandler {
	return &ChallengeHandler{challengeService: cs, images: &imageResolver{uploadService: us}}
}

// GET /api/challenges
func (h *ChallengeHandler) List(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	f := repository.ChallengeListFilter{
		Status: queryString(r, "status"),
		Search: params.Search,
	}

	challenges, meta, err := h.challengeService.List(r.Context(), params, f)
	if err != nil {
		slog.Error("[Challenge.List] failed", "error", err)
		response.InternalError(w, "Failed to fetch challenges")
		return
	}
	response.OKPaginated(w, challenges, meta)
}

// GET /api/challenges/{id}
func (h *ChallengeHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	c, err := h.challengeService.GetByID(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Challenge not found")
			return
		}
		response.InternalError(w, "Failed to fetch challenge")
		return
	}
	response.OK(w, c)
}

// POST /api/challenges
func (h *ChallengeHandler) Create(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Name            string   `json:"name"             validate:"required,min=1,max=150"`
		Description     *string  `json:"description,omitempty"`
		ImageID         string   `json:"image_id,omitempty"`
		ImageURL        *string  `json:"image_url,omitempty"`
		Status          string   `json:"status"           validate:"required,oneof=draft active completed cancelled"`
		StartDate       string   `json:"start_date"       validate:"required"`
		EndDate         string   `json:"end_date"         validate:"required"`
		GoalType        *string  `json:"goal_type,omitempty"`
		GoalValue       *float64 `json:"goal_value,omitempty"`
		MaxParticipants *int     `json:"max_participants,omitempty"`
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
	imgURL := h.images.resolve(r.Context(), input.ImageID, input.ImageURL, "challenge", "")

	c := &repository.Challenge{
		Name: input.Name, Description: input.Description, ImageURL: imgURL,
		Status: input.Status, StartDate: input.StartDate, EndDate: input.EndDate,
		GoalType: input.GoalType, GoalValue: input.GoalValue,
		MaxParticipants: input.MaxParticipants, CreatedBy: userID,
	}
	if err := h.challengeService.Create(r.Context(), c); err != nil {
		slog.Error("[Challenge.Create] failed", "error", err)
		response.InternalError(w, "Failed to create challenge")
		return
	}
	if input.ImageID != "" {
		h.images.resolve(r.Context(), input.ImageID, nil, "challenge", c.ID)
	}
	response.Created(w, c)
}

// PUT /api/challenges/{id}
func (h *ChallengeHandler) Update(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var input struct {
		Name            string   `json:"name"             validate:"required,min=1,max=150"`
		Description     *string  `json:"description,omitempty"`
		ImageID         string   `json:"image_id,omitempty"`
		ImageURL        *string  `json:"image_url,omitempty"`
		Status          string   `json:"status"           validate:"required,oneof=draft active completed cancelled"`
		StartDate       string   `json:"start_date"       validate:"required"`
		EndDate         string   `json:"end_date"         validate:"required"`
		GoalType        *string  `json:"goal_type,omitempty"`
		GoalValue       *float64 `json:"goal_value,omitempty"`
		MaxParticipants *int     `json:"max_participants,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	imgURL := h.images.resolve(r.Context(), input.ImageID, input.ImageURL, "challenge", id)

	c := &repository.Challenge{
		ID: id, Name: input.Name, Description: input.Description, ImageURL: imgURL,
		Status: input.Status, StartDate: input.StartDate, EndDate: input.EndDate,
		GoalType: input.GoalType, GoalValue: input.GoalValue, MaxParticipants: input.MaxParticipants,
	}
	if err := h.challengeService.Update(r.Context(), c); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Challenge not found")
			return
		}
		response.InternalError(w, "Failed to update challenge")
		return
	}
	response.OK(w, c)
}

// DELETE /api/challenges/{id}
func (h *ChallengeHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.challengeService.Delete(r.Context(), id); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Challenge not found")
			return
		}
		response.InternalError(w, "Failed to delete challenge")
		return
	}
	response.SuccessMessage(w, "Challenge deleted")
}

// ─── Participants ──────────────────────────────────────────────────

// POST /api/challenges/{id}/join
func (h *ChallengeHandler) Join(w http.ResponseWriter, r *http.Request) {
	challengeID := chi.URLParam(r, "id")
	userID := middleware.GetUserID(r.Context())

	cp := &repository.ChallengeParticipant{ChallengeID: challengeID, UserID: userID}
	if err := h.challengeService.Join(r.Context(), cp); err != nil {
		slog.Error("[Challenge.Join] failed", "challenge_id", challengeID, "error", err)
		response.InternalError(w, "Failed to join challenge")
		return
	}
	response.Created(w, cp)
}

// POST /api/challenges/{id}/leave
func (h *ChallengeHandler) Leave(w http.ResponseWriter, r *http.Request) {
	challengeID := chi.URLParam(r, "id")
	userID := middleware.GetUserID(r.Context())

	if err := h.challengeService.Leave(r.Context(), challengeID, userID); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Not a participant")
			return
		}
		response.InternalError(w, "Failed to leave challenge")
		return
	}
	response.SuccessMessage(w, "Left challenge")
}

// GET /api/challenges/{id}/participants
func (h *ChallengeHandler) ListParticipants(w http.ResponseWriter, r *http.Request) {
	challengeID := chi.URLParam(r, "id")
	participants, err := h.challengeService.ListParticipants(r.Context(), challengeID)
	if err != nil {
		response.InternalError(w, "Failed to fetch participants")
		return
	}
	response.OK(w, participants)
}

// POST /api/challenges/{id}/progress
func (h *ChallengeHandler) UpdateProgress(w http.ResponseWriter, r *http.Request) {
	challengeID := chi.URLParam(r, "id")
	var input struct {
		Value float64 `json:"value" validate:"required"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}

	userID := middleware.GetUserID(r.Context())
	if err := h.challengeService.UpdateProgress(r.Context(), challengeID, userID, input.Value); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Not a participant")
			return
		}
		response.InternalError(w, "Failed to update progress")
		return
	}
	response.SuccessMessage(w, "Progress updated")
}
