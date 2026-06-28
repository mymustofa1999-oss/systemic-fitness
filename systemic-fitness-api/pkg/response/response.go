package response

import (
	"encoding/json"
	"net/http"

	"github.com/fitcoach/api/internal/model"
)

// Envelope is the standard API response wrapper.
type Envelope struct {
	Success bool               `json:"success"`
	Data    any                `json:"data,omitempty"`
	Message string             `json:"message,omitempty"`
	Errors  []string           `json:"errors,omitempty"`
	Meta    *model.PaginationMeta `json:"meta,omitempty"`
}

func write(w http.ResponseWriter, status int, envelope Envelope) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(envelope)
}

// OK sends a 200 response with data.
func OK(w http.ResponseWriter, data any) {
	write(w, http.StatusOK, Envelope{
		Success: true,
		Data:    data,
	})
}

// OKWithMessage sends a 200 response with data and a message.
func OKWithMessage(w http.ResponseWriter, data any, message string) {
	write(w, http.StatusOK, Envelope{
		Success: true,
		Data:    data,
		Message: message,
	})
}

// OKPaginated sends a 200 response with data and pagination metadata.
func OKPaginated(w http.ResponseWriter, data any, meta model.PaginationMeta) {
	write(w, http.StatusOK, Envelope{
		Success: true,
		Data:    data,
		Meta:    &meta,
	})
}

// Created sends a 201 response.
func Created(w http.ResponseWriter, data any) {
	write(w, http.StatusCreated, Envelope{
		Success: true,
		Data:    data,
	})
}

// CreatedWithMessage sends a 201 response with a message.
func CreatedWithMessage(w http.ResponseWriter, data any, message string) {
	write(w, http.StatusCreated, Envelope{
		Success: true,
		Data:    data,
		Message: message,
	})
}

// NoContent sends a 204 response with no body.
func NoContent(w http.ResponseWriter) {
	w.WriteHeader(http.StatusNoContent)
}

// SuccessMessage sends a 200 with only a message, no data.
func SuccessMessage(w http.ResponseWriter, message string) {
	write(w, http.StatusOK, Envelope{
		Success: true,
		Message: message,
	})
}

// ─── Error Responses ────────────────────────────────────────────

func writeError(w http.ResponseWriter, status int, message string, errors []string) {
	write(w, status, Envelope{
		Success: false,
		Message: message,
		Errors:  errors,
	})
}

// BadRequest sends a 400 response.
func BadRequest(w http.ResponseWriter, message string) {
	writeError(w, http.StatusBadRequest, message, nil)
}

// ValidationError sends a 400 response with field-level errors.
func ValidationError(w http.ResponseWriter, errors []string) {
	writeError(w, http.StatusBadRequest, "Validation failed", errors)
}

// Unauthorized sends a 401 response.
func Unauthorized(w http.ResponseWriter, message string) {
	writeError(w, http.StatusUnauthorized, message, nil)
}

// Forbidden sends a 403 response.
func Forbidden(w http.ResponseWriter, message string) {
	writeError(w, http.StatusForbidden, message, nil)
}

// NotFound sends a 404 response.
func NotFound(w http.ResponseWriter, message string) {
	writeError(w, http.StatusNotFound, message, nil)
}

// Conflict sends a 409 response.
func Conflict(w http.ResponseWriter, message string) {
	writeError(w, http.StatusConflict, message, nil)
}

// InternalError sends a 500 response.
func InternalError(w http.ResponseWriter, message string) {
	writeError(w, http.StatusInternalServerError, message, nil)
}

// PreconditionFailed sends a 412 response — used when the client must
// satisfy a setup step (e.g. fill in profile) before the requested
// action can succeed.
func PreconditionFailed(w http.ResponseWriter, message string) {
	writeError(w, http.StatusPreconditionFailed, message, nil)
}

// ServiceUnavailable sends a 503 response — used when an upstream
// dependency (LLM provider, payment gateway, etc.) is not configured
// or is temporarily down.
func ServiceUnavailable(w http.ResponseWriter, message string) {
	writeError(w, http.StatusServiceUnavailable, message, nil)
}

// PaymentRequired sends a 402 response — used when a premium feature
// requires an active subscription or payment.
func PaymentRequired(w http.ResponseWriter, message string) {
	writeError(w, http.StatusPaymentRequired, message, nil)
}

// ─── Helpers ────────────────────────────────────────────────────

// DecodeJSON reads a JSON request body into dst.
func DecodeJSON(r *http.Request, dst any) error {
	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()
	return decoder.Decode(dst)
}
