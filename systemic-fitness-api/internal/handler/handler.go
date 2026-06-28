// Package handler wires HTTP handlers with the service layer.
// Each handler file follows the pattern:
//   - Struct holding service reference(s)
//   - Constructor
//   - Handler methods (one per endpoint)
//   - Input structs with validate tags
//
// Validation uses go-playground/validator with user-friendly error messages.

package handler

import (
	"fmt"
	"net/http"
	"strconv"
	"strings"

	"github.com/go-playground/validator/v10"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/pkg/response"
)

var validate *validator.Validate

func init() {
	validate = validator.New(validator.WithRequiredStructEnabled())
}

// validateStruct runs validation and returns user-friendly error strings.
func validateStruct(s any) []string {
	err := validate.Struct(s)
	if err == nil {
		return nil
	}

	validationErrors, ok := err.(validator.ValidationErrors)
	if !ok {
		return []string{err.Error()}
	}

	errs := make([]string, 0, len(validationErrors))
	for _, e := range validationErrors {
		field := toSnakeCase(e.Field())
		switch e.Tag() {
		case "required":
			errs = append(errs, fmt.Sprintf("%s is required", field))
		case "email":
			errs = append(errs, fmt.Sprintf("%s must be a valid email address", field))
		case "min":
			errs = append(errs, fmt.Sprintf("%s must be at least %s characters", field, e.Param()))
		case "max":
			errs = append(errs, fmt.Sprintf("%s must be at most %s characters", field, e.Param()))
		case "oneof":
			errs = append(errs, fmt.Sprintf("%s must be one of: %s", field, e.Param()))
		case "url":
			errs = append(errs, fmt.Sprintf("%s must be a valid URL", field))
		case "gt":
			errs = append(errs, fmt.Sprintf("%s must be greater than %s", field, e.Param()))
		case "lt":
			errs = append(errs, fmt.Sprintf("%s must be less than %s", field, e.Param()))
		case "len":
			errs = append(errs, fmt.Sprintf("%s must be exactly %s characters", field, e.Param()))
		default:
			errs = append(errs, fmt.Sprintf("%s failed validation: %s", field, e.Tag()))
		}
	}
	return errs
}

// toSnakeCase converts CamelCase to snake_case for field names.
func toSnakeCase(s string) string {
	var result strings.Builder
	for i, r := range s {
		if r >= 'A' && r <= 'Z' {
			if i > 0 {
				result.WriteByte('_')
			}
			result.WriteRune(r + 32) // to lowercase
		} else {
			result.WriteRune(r)
		}
	}
	return result.String()
}

// paginationFromQuery extracts pagination params from URL query string.
func paginationFromQuery(r *http.Request) model.PaginationParams {
	page, _ := strconv.Atoi(r.URL.Query().Get("page"))
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	p := model.NewPaginationParams(page, limit)
	p.Search = r.URL.Query().Get("search")
	p.SortBy = r.URL.Query().Get("sort_by")
	p.SortOrder = r.URL.Query().Get("sort_order")
	return p
}

// queryString returns a query param value or nil if empty/missing.
func queryString(r *http.Request, key string) *string {
	v := r.URL.Query().Get(key)
	if v == "" {
		return nil
	}
	return &v
}

// HealthCheck is a simple liveness probe.
func HealthCheck(w http.ResponseWriter, r *http.Request) {
	response.OK(w, map[string]string{
		"status":  "ok",
		"service": "fitcoach-api",
	})
}
