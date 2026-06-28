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

type DailyJournalHandler struct {
	journalService *service.DailyJournalService
}

func NewDailyJournalHandler(js *service.DailyJournalService) *DailyJournalHandler {
	return &DailyJournalHandler{journalService: js}
}

// GET /api/customers/{customerId}/journal?month=2026-04
func (h *DailyJournalHandler) ListByMonth(w http.ResponseWriter, r *http.Request) {
	customerID := chi.URLParam(r, "customerId")
	monthYear := r.URL.Query().Get("month")
	if monthYear == "" {
		response.BadRequest(w, "month query parameter is required (e.g. 2026-04)")
		return
	}

	sessions, err := h.journalService.ListByMonth(r.Context(), customerID, monthYear)
	if err != nil {
		slog.Error("[Journal.ListByMonth] failed", "error", err)
		response.InternalError(w, "Failed to fetch journal sessions")
		return
	}
	response.OK(w, sessions)
}

// GET /api/customers/{customerId}/journal/months
func (h *DailyJournalHandler) ListMonths(w http.ResponseWriter, r *http.Request) {
	customerID := chi.URLParam(r, "customerId")
	months, err := h.journalService.ListMonths(r.Context(), customerID)
	if err != nil {
		slog.Error("[Journal.ListMonths] failed", "error", err)
		response.InternalError(w, "Failed to fetch months")
		return
	}
	response.OK(w, months)
}

// POST /api/customers/{customerId}/journal
func (h *DailyJournalHandler) UpsertSession(w http.ResponseWriter, r *http.Request) {
	customerID := chi.URLParam(r, "customerId")
	callerID := middleware.GetUserID(r.Context())

	var input struct {
		SessionNumber int     `json:"session_number" validate:"required,min=1"`
		SessionDate   string  `json:"session_date"   validate:"required"`
		MonthYear     string  `json:"month_year"     validate:"required"`
		Notes         *string `json:"notes,omitempty"`
		Medicines     []struct {
			MedicineID string  `json:"medicine_id"`
			Notes      *string `json:"notes,omitempty"`
		} `json:"medicines"`
		Meals []struct {
			MealTime        *string `json:"meal_time,omitempty"`
			FoodDescription *string `json:"food_description,omitempty"`
			FoodID          *string `json:"food_id,omitempty"`
			Notes           *string `json:"notes,omitempty"`
		} `json:"meals"`
		PreVital *struct {
			Systolic  *int    `json:"systolic,omitempty"`
			Diastolic *int    `json:"diastolic,omitempty"`
			Heartrate *int    `json:"heartrate,omitempty"`
			Notes     *string `json:"notes,omitempty"`
		} `json:"pre_vital,omitempty"`
		PostVital *struct {
			Systolic  *int    `json:"systolic,omitempty"`
			Diastolic *int    `json:"diastolic,omitempty"`
			Heartrate *int    `json:"heartrate,omitempty"`
			Notes     *string `json:"notes,omitempty"`
		} `json:"post_vital,omitempty"`
	}

	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	session := &repository.JournalSession{
		CustomerID:    customerID,
		SessionNumber: input.SessionNumber,
		SessionDate:   input.SessionDate,
		MonthYear:     &input.MonthYear,
		Notes:         input.Notes,
		CreatedBy:     &callerID,
	}

	// Map medicines
	session.Medicines = make([]repository.SessionMedicineRow, len(input.Medicines))
	for i, m := range input.Medicines {
		session.Medicines[i] = repository.SessionMedicineRow{
			MedicineID: m.MedicineID,
			Notes:      m.Notes,
		}
	}

	// Map meals
	session.Meals = make([]repository.SessionMealRow, len(input.Meals))
	for i, ml := range input.Meals {
		session.Meals[i] = repository.SessionMealRow{
			MealTime:        ml.MealTime,
			FoodDescription: ml.FoodDescription,
			FoodID:          ml.FoodID,
			Notes:           ml.Notes,
		}
	}

	// Map vitals
	if input.PreVital != nil {
		session.PreVital = &repository.SessionVitalRow{
			MeasurementType: "pre_workout",
			Systolic:        input.PreVital.Systolic,
			Diastolic:       input.PreVital.Diastolic,
			Heartrate:       input.PreVital.Heartrate,
			Notes:           input.PreVital.Notes,
		}
	}
	if input.PostVital != nil {
		session.PostVital = &repository.SessionVitalRow{
			MeasurementType: "post_workout",
			Systolic:        input.PostVital.Systolic,
			Diastolic:       input.PostVital.Diastolic,
			Heartrate:       input.PostVital.Heartrate,
			Notes:           input.PostVital.Notes,
		}
	}

	if err := h.journalService.UpsertSession(r.Context(), session); err != nil {
		slog.Error("[Journal.Upsert] failed", "error", err)
		response.InternalError(w, "Failed to save session")
		return
	}

	response.OK(w, session)
}

// DELETE /api/customers/{customerId}/journal/{sessionId}
func (h *DailyJournalHandler) DeleteSession(w http.ResponseWriter, r *http.Request) {
	sessionID := chi.URLParam(r, "sessionId")
	if err := h.journalService.DeleteSession(r.Context(), sessionID); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Session not found")
			return
		}
		slog.Error("[Journal.Delete] failed", "error", err)
		response.InternalError(w, "Failed to delete session")
		return
	}
	response.SuccessMessage(w, "Session deleted")
}
