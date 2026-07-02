package handler

import (
	"encoding/json"
	"errors"
	"log/slog"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"

	"github.com/fitcoach/api/internal/middleware"
	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

// ConsultantHandler — SF Phase 7b.
//
// Endpoint group:
//
//	GET    /api/v2/consultant/queue       (consultant+admin)
//	GET    /api/v2/consultant/clients     (consultant only — own clients)
//
//	POST   /api/v2/clinical-notes         (consultant only — author = self)
//	GET    /api/v2/clinical-notes         (consultant+admin; filter via ?consultant_id=&client_id=&assessment_id=)
//	GET    /api/v2/clinical-notes/{id}    (any role; ACL via service.CanRead)
//	PATCH  /api/v2/clinical-notes/{id}    (author or admin)
//	DELETE /api/v2/clinical-notes/{id}    (author or admin — soft delete)
//
//	PATCH  /api/v2/lab-consultations/{id}/assign   (admin/owner — set consultant_id)
type ConsultantHandler struct {
	notes *service.ClinicalNoteService
	labs  *service.LabConsultationService
}

func NewConsultantHandler(
	notes *service.ClinicalNoteService,
	labs *service.LabConsultationService,
) *ConsultantHandler {
	return &ConsultantHandler{notes: notes, labs: labs}
}

// ─── Consultant queue ──────────────────────────────────────────────

// GET /api/v2/consultant/queue
//
// Returns v2 assessments status='submitted' yang belum punya catatan
// klinis aktif. FIFO (oldest first). Optional ?limit=200.
func (h *ConsultantHandler) Queue(w http.ResponseWriter, r *http.Request) {
	limit := 200
	if s := r.URL.Query().Get("limit"); s != "" {
		if n, err := strconv.Atoi(s); err == nil && n > 0 {
			limit = n
		}
	}
	out, err := h.notes.ListPendingReview(r.Context(), limit)
	if err != nil {
		response.InternalError(w, "Failed to fetch review queue")
		return
	}
	response.OK(w, out)
}

// GET /api/v2/consultant/clients
//
// Distinct clients yang pernah disentuh consultant ini via clinical_notes
// atau lab_consultations. Auth: consultant only (admin pakai endpoint
// list user umum).
func (h *ConsultantHandler) Clients(w http.ResponseWriter, r *http.Request) {
	consultantID := middleware.GetUserID(r.Context())
	if consultantID == "" {
		response.Unauthorized(w, "Authentication required")
		return
	}
	out, err := h.notes.ListClients(r.Context(), consultantID)
	if err != nil {
		response.InternalError(w, "Failed to fetch consultant clients")
		return
	}
	response.OK(w, out)
}

// ─── Clinical notes CRUD ───────────────────────────────────────────

type clinicalNoteCreateInput struct {
	AssessmentID      *string         `json:"assessment_id,omitempty" validate:"omitempty,uuid"`
	ClientID          string          `json:"client_id" validate:"required,uuid"`
	Title             string          `json:"title"     validate:"omitempty,max=160"`
	Content           string          `json:"content"   validate:"required,min=1,max=20000"`
	Attachments       json.RawMessage `json:"attachments,omitempty"`
	IsVisibleToClient bool            `json:"is_visible_to_client"`
}

// POST /api/v2/clinical-notes — consultant only.
// consultant_id di-derive dari JWT (tidak boleh dikirim dari client).
func (h *ConsultantHandler) CreateNote(w http.ResponseWriter, r *http.Request) {
	var in clinicalNoteCreateInput
	if err := response.DecodeJSON(r, &in); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&in); errs != nil {
		response.ValidationError(w, errs)
		return
	}
	consultantID := middleware.GetUserID(r.Context())
	if consultantID == "" {
		response.Unauthorized(w, "Authentication required")
		return
	}
	slog.Info("Creating clinical note payload", "payload", in)

	n := &repository.ClinicalNote{
		AssessmentID:      in.AssessmentID,
		ClientID:          in.ClientID,
		ConsultantID:      consultantID,
		Title:             in.Title,
		Content:           in.Content,
		Attachments:       in.Attachments,
		IsVisibleToClient: in.IsVisibleToClient,
	}
	if err := h.notes.Create(r.Context(), n); err != nil {
		switch {
		case errors.Is(err, service.ErrClinicalNoteInvalid):
			response.BadRequest(w, err.Error())
		default:
			slog.Error("[Consultant.CreateNote] failed", "error", err)
			response.InternalError(w, "Failed to create clinical note")
		}
		return
	}
	response.Created(w, n)
}

// GET /api/v2/clinical-notes
//
// Filters: ?consultant_id=&client_id=&assessment_id=&only_published=true
// Auth: consultant+admin (handled di route mount).
func (h *ConsultantHandler) ListNotes(w http.ResponseWriter, r *http.Request) {
	f := repository.ClinicalNoteFilter{
		ConsultantID: queryString(r, "consultant_id"),
		ClientID:     queryString(r, "client_id"),
		AssessmentID: queryString(r, "assessment_id"),
	}
	if v := r.URL.Query().Get("only_published"); v == "true" || v == "1" {
		t := true
		f.OnlyPublished = &t
	}
	out, err := h.notes.List(r.Context(), f)
	if err != nil {
		response.InternalError(w, "Failed to fetch clinical notes")
		return
	}
	response.OK(w, out)
}

// GET /api/v2/clinical-notes/{id} — ACL via service.CanRead.
func (h *ConsultantHandler) GetNote(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	n, err := h.notes.Get(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Clinical note not found")
			return
		}
		response.InternalError(w, "Failed to fetch clinical note")
		return
	}
	role := middleware.GetRole(r.Context())
	callerID := middleware.GetUserID(r.Context())
	if !h.notes.CanRead(role, callerID, n) {
		response.Forbidden(w, "Forbidden")
		return
	}
	response.OK(w, n)
}

type clinicalNoteUpdateInput struct {
	Title             string          `json:"title"   validate:"omitempty,max=160"`
	Content           string          `json:"content" validate:"required,min=1,max=20000"`
	Attachments       json.RawMessage `json:"attachments,omitempty"`
	IsVisibleToClient bool            `json:"is_visible_to_client"`
}

// PATCH /api/v2/clinical-notes/{id} — author or admin.
func (h *ConsultantHandler) UpdateNote(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var in clinicalNoteUpdateInput
	if err := response.DecodeJSON(r, &in); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&in); errs != nil {
		response.ValidationError(w, errs)
		return
	}
	callerID := middleware.GetUserID(r.Context())
	role := middleware.GetRole(r.Context())

	n := &repository.ClinicalNote{
		ID:                id,
		Title:             in.Title,
		Content:           in.Content,
		Attachments:       in.Attachments,
		IsVisibleToClient: in.IsVisibleToClient,
	}
	if err := h.notes.Update(r.Context(), n, callerID, role); err != nil {
		switch {
		case errors.Is(err, repository.ErrNotFound):
			response.NotFound(w, "Clinical note not found")
		case errors.Is(err, service.ErrClinicalNoteForbidden):
			response.Forbidden(w, "Only the author or an admin can edit this note")
		default:
			slog.Error("[Consultant.UpdateNote] failed", "id", id, "error", err)
			response.InternalError(w, "Failed to update clinical note")
		}
		return
	}
	// reload joined fields for client convenience
	full, err := h.notes.Get(r.Context(), id)
	if err == nil {
		response.OK(w, full)
		return
	}
	response.OK(w, n)
}

// DELETE /api/v2/clinical-notes/{id} — author or admin (soft delete).
func (h *ConsultantHandler) DeleteNote(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	callerID := middleware.GetUserID(r.Context())
	role := middleware.GetRole(r.Context())
	if err := h.notes.Delete(r.Context(), id, callerID, role); err != nil {
		switch {
		case errors.Is(err, repository.ErrNotFound):
			response.NotFound(w, "Clinical note not found")
		case errors.Is(err, service.ErrClinicalNoteForbidden):
			response.Forbidden(w, "Only the author or an admin can delete this note")
		default:
			slog.Error("[Consultant.DeleteNote] failed", "id", id, "error", err)
			response.InternalError(w, "Failed to delete clinical note")
		}
		return
	}
	response.SuccessMessage(w, "Clinical note deleted")
}

// ─── Lab Consultation assignment ───────────────────────────────────

type labAssignInput struct {
	ConsultantID string `json:"consultant_id" validate:"required,uuid"`
}

// PATCH /api/v2/lab-consultations/{id}/assign — admin/owner only.
//
// Convenience endpoint untuk meng-assign consultant tanpa harus mengirim
// payload Update lengkap (yang men-`required` field status). Status akan
// di-bump ke 'scheduled' kalau sebelumnya 'pending'.
func (h *ConsultantHandler) AssignLab(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var in labAssignInput
	if err := response.DecodeJSON(r, &in); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&in); errs != nil {
		response.ValidationError(w, errs)
		return
	}
	if err := h.labs.AssignConsultant(r.Context(), id, in.ConsultantID); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Lab consultation not found")
			return
		}
		response.InternalError(w, "Failed to assign consultant")
		return
	}
	updated, err := h.labs.Get(r.Context(), id)
	if err != nil {
		response.SuccessMessage(w, "Consultant assigned")
		return
	}
	response.OK(w, updated)
}

// ─── compile-time assertion role enum reference ───────────────────
var _ = model.RoleConsultant
