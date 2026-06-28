package service

import (
	"context"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

type NutritionService struct {
	nutritionRepo *repository.NutritionRepository
	logger        *slog.Logger
}

func NewNutritionService(nr *repository.NutritionRepository, logger *slog.Logger) *NutritionService {
	return &NutritionService{nutritionRepo: nr, logger: logger}
}

func (s *NutritionService) CreateMealPlan(ctx context.Context, mp *repository.MealPlan) error {
	if err := s.nutritionRepo.CreateMealPlan(ctx, mp); err != nil {
		s.logger.Error("create meal plan", "name", mp.Name, "error", err)
		return fmt.Errorf("creating meal plan: %w", err)
	}
	s.logger.Info("meal plan created", "id", mp.ID, "name", mp.Name)
	return nil
}

func (s *NutritionService) ListMealPlans(ctx context.Context, params model.PaginationParams) ([]repository.MealPlan, model.PaginationMeta, error) {
	plans, total, err := s.nutritionRepo.ListMealPlans(ctx, params)
	if err != nil {
		s.logger.Error("list meal plans", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return plans, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

func (s *NutritionService) LogNutrition(ctx context.Context, log *repository.NutritionLog) error {
	if err := s.nutritionRepo.LogNutrition(ctx, log); err != nil {
		s.logger.Error("log nutrition", "user_id", log.UserID, "meal_type", log.MealType, "error", err)
		return fmt.Errorf("logging nutrition: %w", err)
	}
	s.logger.Info("nutrition logged", "user_id", log.UserID, "meal_type", log.MealType, "food", log.FoodName)
	return nil
}

func (s *NutritionService) GetDailyLogs(ctx context.Context, userID, date string) ([]repository.NutritionLog, error) {
	logs, err := s.nutritionRepo.GetDailyLogs(ctx, userID, date)
	if err != nil {
		s.logger.Error("get daily nutrition logs", "user_id", userID, "date", date, "error", err)
		return nil, err
	}
	return logs, nil
}
