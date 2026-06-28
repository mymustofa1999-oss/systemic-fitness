package handler

import (
	"log/slog"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"

	"github.com/fitcoach/api/internal/middleware"
	"github.com/fitcoach/api/internal/repository"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

type NutritionHandler struct {
	nutritionService *service.NutritionService
}

func NewNutritionHandler(ns *service.NutritionService) *NutritionHandler {
	return &NutritionHandler{nutritionService: ns}
}

func (h *NutritionHandler) ListMealPlans(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	plans, meta, err := h.nutritionService.ListMealPlans(r.Context(), params)
	if err != nil {
		slog.Error("[Nutrition.ListMealPlans] failed", "error", err)
		response.InternalError(w, err.Error())
		return
	}
	slog.Debug("[Nutrition.ListMealPlans] success", "total", meta.Total)
	response.OKPaginated(w, plans, meta)
}

func (h *NutritionHandler) CreateMealPlan(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Name          string  `json:"name" validate:"required,min=1,max=100"`
		Description   *string `json:"description,omitempty"`
		DailyCalories *int    `json:"daily_calories,omitempty"`
		ProteinG      *int    `json:"protein_g,omitempty"`
		CarbsG        *int    `json:"carbs_g,omitempty"`
		FatG          *int    `json:"fat_g,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Nutrition.CreateMealPlan] invalid request body", "error", err)
		response.BadRequest(w, "Invalid request body")
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Nutrition.CreateMealPlan] validation failed", "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	userID := middleware.GetUserID(r.Context())
	mp := &repository.MealPlan{
		Name:          input.Name,
		Description:   input.Description,
		DailyCalories: input.DailyCalories,
		ProteinG:      input.ProteinG,
		CarbsG:        input.CarbsG,
		FatG:          input.FatG,
		CreatedBy:     &userID,
	}

	if err := h.nutritionService.CreateMealPlan(r.Context(), mp); err != nil {
		slog.Error("[Nutrition.CreateMealPlan] failed", "name", input.Name, "user_id", userID, "error", err)
		response.InternalError(w, err.Error())
		return
	}
	slog.Info("[Nutrition.CreateMealPlan] success", "id", mp.ID, "name", mp.Name, "user_id", userID)
	response.Created(w, mp)
}

func (h *NutritionHandler) LogNutrition(w http.ResponseWriter, r *http.Request) {
	var input struct {
		MealType string   `json:"meal_type" validate:"required,oneof=breakfast lunch dinner snack"`
		FoodName string   `json:"food_name" validate:"required,min=1,max=100"`
		Calories *int     `json:"calories,omitempty"`
		ProteinG *float64 `json:"protein_g,omitempty"`
		CarbsG   *float64 `json:"carbs_g,omitempty"`
		FatG     *float64 `json:"fat_g,omitempty"`
		PhotoURL *string  `json:"photo_url,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Nutrition.LogNutrition] invalid request body", "error", err)
		response.BadRequest(w, "Invalid request body")
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Nutrition.LogNutrition] validation failed", "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	userID := middleware.GetUserID(r.Context())
	log := &repository.NutritionLog{
		UserID:   userID,
		MealType: input.MealType,
		FoodName: input.FoodName,
		Calories: input.Calories,
		ProteinG: input.ProteinG,
		CarbsG:   input.CarbsG,
		FatG:     input.FatG,
		PhotoURL: input.PhotoURL,
	}

	if err := h.nutritionService.LogNutrition(r.Context(), log); err != nil {
		slog.Error("[Nutrition.LogNutrition] failed", "user_id", userID, "meal_type", input.MealType, "error", err)
		response.InternalError(w, err.Error())
		return
	}
	slog.Info("[Nutrition.LogNutrition] success", "user_id", userID, "meal_type", input.MealType, "food", input.FoodName)
	response.Created(w, log)
}

func (h *NutritionHandler) GetDaily(w http.ResponseWriter, r *http.Request) {
	userID := chi.URLParam(r, "id")
	date := r.URL.Query().Get("date")
	if date == "" {
		date = time.Now().Format("2006-01-02")
	}

	logs, err := h.nutritionService.GetDailyLogs(r.Context(), userID, date)
	if err != nil {
		slog.Error("[Nutrition.GetDaily] failed", "user_id", userID, "date", date, "error", err)
		response.InternalError(w, err.Error())
		return
	}

	// Aggregate totals from individual meal logs
	var totalCalories int
	var totalProteinG, totalCarbsG, totalFatG float64
	for _, l := range logs {
		if l.Calories != nil {
			totalCalories += *l.Calories
		}
		if l.ProteinG != nil {
			totalProteinG += *l.ProteinG
		}
		if l.CarbsG != nil {
			totalCarbsG += *l.CarbsG
		}
		if l.FatG != nil {
			totalFatG += *l.FatG
		}
	}

	slog.Debug("[Nutrition.GetDaily] success", "user_id", userID, "date", date, "entries", len(logs))
	response.OK(w, map[string]any{
		"date":            date,
		"total_calories":  totalCalories,
		"total_protein_g": totalProteinG,
		"total_carbs_g":   totalCarbsG,
		"total_fat_g":     totalFatG,
		"meals":           logs,
	})
}
