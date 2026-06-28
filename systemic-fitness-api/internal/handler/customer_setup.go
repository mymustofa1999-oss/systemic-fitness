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

type CustomerSetupHandler struct {
	setupService *service.CustomerSetupService
}

func NewCustomerSetupHandler(ss *service.CustomerSetupService) *CustomerSetupHandler {
	return &CustomerSetupHandler{setupService: ss}
}

// ────────────────────────────────────────────────────────────────
//  GET /api/customers/{customerId}/setup
// ────────────────────────────────────────────────────────────────

func (h *CustomerSetupHandler) GetFullSetup(w http.ResponseWriter, r *http.Request) {
	customerID := chi.URLParam(r, "customerId")
	setup, err := h.setupService.GetFullSetup(r.Context(), customerID)
	if err != nil {
		slog.Error("[CustomerSetup.GetFull] failed", "customer_id", customerID, "error", err)
		response.InternalError(w, "Failed to fetch customer setup")
		return
	}
	response.OK(w, setup)
}

// ────────────────────────────────────────────────────────────────
//  GET /api/customers/{customerId}/staff
// ────────────────────────────────────────────────────────────────

func (h *CustomerSetupHandler) GetStaff(w http.ResponseWriter, r *http.Request) {
	customerID := chi.URLParam(r, "customerId")
	staff, err := h.setupService.GetStaffAssignment(r.Context(), customerID)
	if err != nil {
		response.InternalError(w, "Failed to fetch staff assignment")
		return
	}
	response.OK(w, staff)
}

// ────────────────────────────────────────────────────────────────
//  POST /api/customers/{customerId}/staff
// ────────────────────────────────────────────────────────────────

func (h *CustomerSetupHandler) AssignStaff(w http.ResponseWriter, r *http.Request) {
	customerID := chi.URLParam(r, "customerId")
	var input struct {
		StaffID  string `json:"staff_id"  validate:"required"`
		RoleType string `json:"role_type" validate:"required"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}
	if input.RoleType != "trainer" && input.RoleType != "consultant" {
		response.BadRequest(w, "role_type must be 'trainer' or 'consultant'")
		return
	}

	if err := h.setupService.AssignStaff(r.Context(), customerID, input.StaffID, input.RoleType); err != nil {
		response.InternalError(w, "Failed to assign staff")
		return
	}
	response.SuccessMessage(w, "Staff assigned")
}

// ────────────────────────────────────────────────────────────────
//  PUT /api/customers/{customerId}/priority
// ────────────────────────────────────────────────────────────────

func (h *CustomerSetupHandler) UpdatePriority(w http.ResponseWriter, r *http.Request) {
	customerID := chi.URLParam(r, "customerId")
	var input struct {
		Priority string `json:"priority" validate:"required"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	if err := h.setupService.UpdatePriority(r.Context(), customerID, input.Priority); err != nil {
		slog.Error("[CustomerSetup.UpdatePriority] failed", "customer_id", customerID, "error", err)
		response.InternalError(w, "Failed to save priority")
		return
	}
	response.SuccessMessage(w, "Priority saved")
}

// ────────────────────────────────────────────────────────────────
//  GET /api/customers/{customerId}/hr-zone
// ────────────────────────────────────────────────────────────────

func (h *CustomerSetupHandler) GetHRZone(w http.ResponseWriter, r *http.Request) {
	customerID := chi.URLParam(r, "customerId")
	zone, err := h.setupService.GetHRZone(r.Context(), customerID)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.OK(w, nil)
			return
		}
		slog.Error("[CustomerSetup.GetHRZone] failed", "customer_id", customerID, "error", err)
		response.InternalError(w, "Failed to fetch HR zone")
		return
	}
	response.OK(w, zone)
}

// ────────────────────────────────────────────────────────────────
//  PUT /api/customers/{customerId}/hr-zone
// ────────────────────────────────────────────────────────────────

func (h *CustomerSetupHandler) UpsertHRZone(w http.ResponseWriter, r *http.Request) {
	customerID := chi.URLParam(r, "customerId")
	var input struct {
		MaxHRUpper *int    `json:"max_hr_upper,omitempty"`
		MaxHRLower *int    `json:"max_hr_lower,omitempty"`
		Zone5Upper *int    `json:"zone5_upper,omitempty"`
		Zone5Lower *int    `json:"zone5_lower,omitempty"`
		Zone4Upper *int    `json:"zone4_upper,omitempty"`
		Zone4Lower *int    `json:"zone4_lower,omitempty"`
		Zone3Upper *int    `json:"zone3_upper,omitempty"`
		Zone3Lower *int    `json:"zone3_lower,omitempty"`
		Zone2Upper *int    `json:"zone2_upper,omitempty"`
		Zone2Lower *int    `json:"zone2_lower,omitempty"`
		Zone1Upper *int    `json:"zone1_upper,omitempty"`
		Zone1Lower *int    `json:"zone1_lower,omitempty"`
		Notes      *string `json:"notes,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}

	z := &repository.CustomerHRZone{
		CustomerID: customerID,
		MaxHRUpper: input.MaxHRUpper, MaxHRLower: input.MaxHRLower,
		Zone5Upper: input.Zone5Upper, Zone5Lower: input.Zone5Lower,
		Zone4Upper: input.Zone4Upper, Zone4Lower: input.Zone4Lower,
		Zone3Upper: input.Zone3Upper, Zone3Lower: input.Zone3Lower,
		Zone2Upper: input.Zone2Upper, Zone2Lower: input.Zone2Lower,
		Zone1Upper: input.Zone1Upper, Zone1Lower: input.Zone1Lower,
		Notes: input.Notes,
	}

	if err := h.setupService.UpsertHRZone(r.Context(), z); err != nil {
		slog.Error("[CustomerSetup.UpsertHRZone] failed", "customer_id", customerID, "error", err)
		response.InternalError(w, "Failed to save HR zone")
		return
	}
	response.OK(w, z)
}

// ────────────────────────────────────────────────────────────────
//  GET /api/customers/{customerId}/medicines
// ────────────────────────────────────────────────────────────────

func (h *CustomerSetupHandler) ListMedicines(w http.ResponseWriter, r *http.Request) {
	customerID := chi.URLParam(r, "customerId")
	medicines, err := h.setupService.ListCustomerMedicines(r.Context(), customerID)
	if err != nil {
		slog.Error("[CustomerSetup.ListMedicines] failed", "customer_id", customerID, "error", err)
		response.InternalError(w, "Failed to fetch customer medicines")
		return
	}
	response.OK(w, medicines)
}

// ────────────────────────────────────────────────────────────────
//  POST /api/customers/{customerId}/medicines
// ────────────────────────────────────────────────────────────────

func (h *CustomerSetupHandler) AddMedicine(w http.ResponseWriter, r *http.Request) {
	customerID := chi.URLParam(r, "customerId")
	var input struct {
		MedicineID string  `json:"medicine_id" validate:"required"`
		Notes      *string `json:"notes,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	cm := &repository.CustomerMedicine{
		CustomerID: customerID,
		MedicineID: input.MedicineID,
		Notes:      input.Notes,
		IsActive:   true,
	}
	if err := h.setupService.AddCustomerMedicine(r.Context(), cm); err != nil {
		slog.Error("[CustomerSetup.AddMedicine] failed", "customer_id", customerID, "error", err)
		response.InternalError(w, "Failed to add medicine")
		return
	}
	response.Created(w, cm)
}

// ────────────────────────────────────────────────────────────────
//  DELETE /api/customers/{customerId}/medicines/{medicineId}
// ────────────────────────────────────────────────────────────────

func (h *CustomerSetupHandler) RemoveMedicine(w http.ResponseWriter, r *http.Request) {
	customerID := chi.URLParam(r, "customerId")
	medicineID := chi.URLParam(r, "medicineId")
	if err := h.setupService.RemoveCustomerMedicine(r.Context(), customerID, medicineID); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Medicine assignment not found")
			return
		}
		slog.Error("[CustomerSetup.RemoveMedicine] failed", "error", err)
		response.InternalError(w, "Failed to remove medicine")
		return
	}
	response.SuccessMessage(w, "Medicine removed")
}

// ────────────────────────────────────────────────────────────────
//  GET /api/customers/{customerId}/programs
// ────────────────────────────────────────────────────────────────

func (h *CustomerSetupHandler) ListPrograms(w http.ResponseWriter, r *http.Request) {
	customerID := chi.URLParam(r, "customerId")
	programs, err := h.setupService.ListCustomerPrograms(r.Context(), customerID)
	if err != nil {
		slog.Error("[CustomerSetup.ListPrograms] failed", "customer_id", customerID, "error", err)
		response.InternalError(w, "Failed to fetch customer programs")
		return
	}
	response.OK(w, programs)
}

// ────────────────────────────────────────────────────────────────
//  POST /api/customers/{customerId}/programs
// ────────────────────────────────────────────────────────────────

func (h *CustomerSetupHandler) UpsertProgram(w http.ResponseWriter, r *http.Request) {
	customerID := chi.URLParam(r, "customerId")
	var input struct {
		ProgramCategoryID string  `json:"program_category_id" validate:"required"`
		IsActive          *bool   `json:"is_active,omitempty"`
		BPMUpper          *int    `json:"bpm_upper,omitempty"`
		BPMLower          *int    `json:"bpm_lower,omitempty"`
		HasBebanUpper     bool     `json:"has_beban_upper"`
		HasBebanLower     bool     `json:"has_beban_lower"`
		BebanUpperValue   *float64 `json:"beban_upper_value,omitempty"`
		BebanLowerValue   *float64 `json:"beban_lower_value,omitempty"`
		HasResistance     bool    `json:"has_resistance"`
		ParameterNotes    *string `json:"parameter_notes,omitempty"`
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

	// Auto-derive has_beban flags from value presence
	hasBebanUpper := input.HasBebanUpper || (input.BebanUpperValue != nil && *input.BebanUpperValue > 0)
	hasBebanLower := input.HasBebanLower || (input.BebanLowerValue != nil && *input.BebanLowerValue > 0)

	a := &repository.CustomerProgramAssignment{
		CustomerID:        customerID,
		ProgramCategoryID: input.ProgramCategoryID,
		IsActive:          isActive,
		BPMUpper:          input.BPMUpper,
		BPMLower:          input.BPMLower,
		HasBebanUpper:     hasBebanUpper,
		HasBebanLower:     hasBebanLower,
		BebanUpperValue:   input.BebanUpperValue,
		BebanLowerValue:   input.BebanLowerValue,
		HasResistance:     input.HasResistance,
		ParameterNotes:    input.ParameterNotes,
	}
	if err := h.setupService.UpsertCustomerProgram(r.Context(), a); err != nil {
		slog.Error("[CustomerSetup.UpsertProgram] failed", "customer_id", customerID, "error", err)
		response.InternalError(w, "Failed to save program assignment")
		return
	}
	response.OK(w, a)
}

// ────────────────────────────────────────────────────────────────
//  DELETE /api/customers/{customerId}/programs/{programCategoryId}
// ────────────────────────────────────────────────────────────────

func (h *CustomerSetupHandler) RemoveProgram(w http.ResponseWriter, r *http.Request) {
	customerID := chi.URLParam(r, "customerId")
	programCategoryID := chi.URLParam(r, "programCategoryId")
	if err := h.setupService.RemoveCustomerProgram(r.Context(), customerID, programCategoryID); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Program assignment not found")
			return
		}
		slog.Error("[CustomerSetup.RemoveProgram] failed", "error", err)
		response.InternalError(w, "Failed to remove program")
		return
	}
	response.SuccessMessage(w, "Program removed")
}
