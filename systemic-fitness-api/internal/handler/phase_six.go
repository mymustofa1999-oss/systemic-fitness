package handler

import (
	"encoding/json"
	"errors"
	"log/slog"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"

	"github.com/fitcoach/api/internal/middleware"
	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

// SF Phase 6 — Tier 4 Waitlist + Lab Consultation handlers.

// ─── Tier 4 Waitlist ────────────────────────────────────────────

type Tier4WaitlistHandler struct {
	service *service.Tier4WaitlistService
}

func NewTier4WaitlistHandler(s *service.Tier4WaitlistService) *Tier4WaitlistHandler {
	return &Tier4WaitlistHandler{service: s}
}

type tier4JoinInput struct {
	FullName     string  `json:"full_name"     validate:"required,min=2,max=120"`
	Email        string  `json:"email"         validate:"required,email,max=255"`
	Phone        *string `json:"phone,omitempty"        validate:"omitempty,max=32"`
	City         *string `json:"city,omitempty"         validate:"omitempty,max=80"`
	Source       string  `json:"source"        validate:"required,oneof=tier4 level_0_3 other"`
	AssessmentID *string `json:"assessment_id,omitempty"`
	Note         *string `json:"note,omitempty"         validate:"omitempty,max=2000"`
}

// POST /api/v2/tier4-waitlist — auth required (auto-fill user_id).
// Auth bisa dilakukan oleh client (untuk daftar diri sendiri) atau guest
// nanti via separate public endpoint kalau diperlukan.
func (h *Tier4WaitlistHandler) Join(w http.ResponseWriter, r *http.Request) {
	var in tier4JoinInput
	if err := response.DecodeJSON(r, &in); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&in); errs != nil {
		response.ValidationError(w, errs)
		return
	}
	userID := middleware.GetUserID(r.Context())
	var userIDPtr *string
	if userID != "" {
		userIDPtr = &userID
	}
	e := &repository.Tier4WaitlistEntry{
		UserID:       userIDPtr,
		FullName:     in.FullName,
		Email:        in.Email,
		Phone:        in.Phone,
		City:         in.City,
		Source:       in.Source,
		AssessmentID: in.AssessmentID,
		Note:         in.Note,
	}
	if err := h.service.Create(r.Context(), e); err != nil {
		slog.Error("[Tier4.Join] failed", "error", err)
		response.InternalError(w, "Gagal mendaftarkan minat. Coba lagi.")
		return
	}
	response.Created(w, e)
}

// GET /api/v2/tier4-waitlist — admin only.
func (h *Tier4WaitlistHandler) List(w http.ResponseWriter, r *http.Request) {
	f := repository.Tier4WaitlistFilter{
		Status: queryString(r, "status"),
		Source: queryString(r, "source"),
	}
	out, err := h.service.List(r.Context(), f)
	if err != nil {
		response.InternalError(w, "Failed to fetch waitlist")
		return
	}
	response.OK(w, out)
}

type tier4StatusInput struct {
	Status    string  `json:"status"     validate:"required,oneof=new contacted converted closed"`
	AdminNote *string `json:"admin_note,omitempty" validate:"omitempty,max=2000"`
}

// PATCH /api/v2/tier4-waitlist/{id}/status — admin only.
func (h *Tier4WaitlistHandler) UpdateStatus(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var in tier4StatusInput
	if err := response.DecodeJSON(r, &in); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&in); errs != nil {
		response.ValidationError(w, errs)
		return
	}
	if err := h.service.UpdateStatus(r.Context(), id, in.Status, in.AdminNote); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Waitlist entry not found")
			return
		}
		response.InternalError(w, "Failed to update status")
		return
	}
	response.SuccessMessage(w, "Status updated")
}

// ─── Lab Consultation ───────────────────────────────────────────

type LabConsultationHandler struct {
	service *service.LabConsultationService
}

func NewLabConsultationHandler(s *service.LabConsultationService) *LabConsultationHandler {
	return &LabConsultationHandler{service: s}
}

type labBookInput struct {
	AssessmentID *string    `json:"assessment_id,omitempty"`
	BookingNote  *string    `json:"booking_note,omitempty" validate:"omitempty,max=2000"`
	PreferredAt  *time.Time `json:"preferred_at,omitempty"`
}

// POST /api/v2/lab-consultations — client books for self.
func (h *LabConsultationHandler) Book(w http.ResponseWriter, r *http.Request) {
	var in labBookInput
	if err := response.DecodeJSON(r, &in); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&in); errs != nil {
		response.ValidationError(w, errs)
		return
	}
	userID := middleware.GetUserID(r.Context())
	if userID == "" {
		response.Unauthorized(w, "Authentication required")
		return
	}
	l := &repository.LabConsultation{
		UserID:       userID,
		AssessmentID: in.AssessmentID,
		BookingNote:  in.BookingNote,
		PreferredAt:  in.PreferredAt,
	}
	if err := h.service.Book(r.Context(), l); err != nil {
		response.InternalError(w, "Gagal memesan Lab Consultation")
		return
	}
	response.Created(w, l)
}

// GET /api/v2/lab-consultations — admin sees all; client sees only own.
func (h *LabConsultationHandler) List(w http.ResponseWriter, r *http.Request) {
	role := middleware.GetRole(r.Context())
	userID := middleware.GetUserID(r.Context())

	f := repository.LabConsultationFilter{
		Status: queryString(r, "status"),
	}
	if role == model.RoleClient {
		f.UserID = &userID
	} else if uid := queryString(r, "user_id"); uid != nil {
		f.UserID = uid
	}
	out, err := h.service.List(r.Context(), f)
	if err != nil {
		response.InternalError(w, "Failed to fetch lab consultations")
		return
	}
	response.OK(w, out)
}

// GET /api/v2/lab-consultations/{id}
func (h *LabConsultationHandler) Get(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	l, err := h.service.Get(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Lab consultation not found")
			return
		}
		response.InternalError(w, "Failed to fetch lab consultation")
		return
	}
	role := middleware.GetRole(r.Context())
	if role == model.RoleClient && l.UserID != middleware.GetUserID(r.Context()) {
		response.Forbidden(w, "Forbidden")
		return
	}
	response.OK(w, l)
}

type labUpdateInput struct {
	ConsultantID  *string         `json:"consultant_id,omitempty"`
	Status        string          `json:"status" validate:"required,oneof=pending scheduled completed cancelled no_show"`
	ScheduledAt   *time.Time      `json:"scheduled_at,omitempty"`
	CompletedAt   *time.Time      `json:"completed_at,omitempty"`
	ResultSummary *string         `json:"result_summary,omitempty" validate:"omitempty,max=4000"`
	ResultPayload json.RawMessage `json:"result_payload,omitempty"`
}

// PATCH /api/v2/lab-consultations/{id} — admin/consultant only.
func (h *LabConsultationHandler) Update(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var in labUpdateInput
	if err := response.DecodeJSON(r, &in); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&in); errs != nil {
		response.ValidationError(w, errs)
		return
	}
	existing, err := h.service.Get(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Lab consultation not found")
			return
		}
		response.InternalError(w, "Failed")
		return
	}
	existing.ConsultantID = in.ConsultantID
	existing.Status = in.Status
	existing.ScheduledAt = in.ScheduledAt
	existing.CompletedAt = in.CompletedAt
	existing.ResultSummary = in.ResultSummary
	if len(in.ResultPayload) > 0 {
		existing.ResultPayload = in.ResultPayload
	}
	if err := h.service.Update(r.Context(), existing); err != nil {
		response.InternalError(w, "Failed to update lab consultation")
		return
	}
	response.OK(w, existing)
}
