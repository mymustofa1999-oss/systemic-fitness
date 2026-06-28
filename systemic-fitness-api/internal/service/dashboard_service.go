package service

import (
	"context"
	"log/slog"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

type DashboardService struct {
	userRepo    *repository.UserRepository
	paymentRepo *repository.PaymentRepository
	db          dashboardDB // direct queries not covered by existing repos
	logger      *slog.Logger
}

// dashboardDB defines the pool interface we need for raw dashboard queries.
type dashboardDB interface {
	QueryRow(ctx context.Context, sql string, args ...any) interface{ Scan(dest ...any) error }
}

func NewDashboardService(ur *repository.UserRepository, pr *repository.PaymentRepository, logger *slog.Logger) *DashboardService {
	return &DashboardService{userRepo: ur, paymentRepo: pr, logger: logger}
}

// ═══════════════════════════════════════════════════════════════
//  Overview
// ═══════════════════════════════════════════════════════════════

type DashboardOverview struct {
	TotalUsers          int     `json:"total_users"`
	ActiveUsers7d       int     `json:"active_users_7d"`
	NewUsers30d         int     `json:"new_users_30d"`
	TotalTrainers       int     `json:"total_trainers"`
	TotalClients        int     `json:"total_clients"`
	ActiveSubscriptions int     `json:"active_subscriptions"`
	Revenue30d          float64 `json:"revenue_30d"`
	TransactionCount30d int     `json:"transaction_count_30d"`
}

func (s *DashboardService) GetOverview(ctx context.Context) (*DashboardOverview, error) {
	overview := &DashboardOverview{}
	oneRow := model.NewPaginationParams(1, 1)

	// Total users
	_, total, err := s.userRepo.List(ctx, oneRow, repository.UserListFilter{})
	if err != nil {
		s.logger.Error("dashboard overview: total users", "error", err)
		return nil, err
	}
	overview.TotalUsers = total

	// Trainers
	trainerRole := model.RoleTrainer
	_, tc, err := s.userRepo.List(ctx, oneRow, repository.UserListFilter{Role: &trainerRole})
	if err != nil {
		s.logger.Warn("dashboard overview: trainers count", "error", err)
	}
	overview.TotalTrainers = tc

	// Clients
	clientRole := model.RoleClient
	_, cc, err := s.userRepo.List(ctx, oneRow, repository.UserListFilter{Role: &clientRole})
	if err != nil {
		s.logger.Warn("dashboard overview: clients count", "error", err)
	}
	overview.TotalClients = cc

	// Revenue (30d)
	revenue, txnCount, err := s.paymentRepo.GetDashboardRevenue(ctx)
	if err != nil {
		s.logger.Warn("dashboard overview: revenue", "error", err)
	}
	overview.Revenue30d = revenue
	overview.TransactionCount30d = txnCount

	s.logger.Debug("dashboard overview fetched", "total_users", overview.TotalUsers, "trainers", overview.TotalTrainers, "clients", overview.TotalClients)
	return overview, nil
}

// ═══════════════════════════════════════════════════════════════
//  Revenue Chart (monthly, last N months)
// ═══════════════════════════════════════════════════════════════

func (s *DashboardService) GetRevenueChart(ctx context.Context, months int) ([]repository.MonthlyRevenue, error) {
	if months < 1 {
		months = 12
	}
	data, err := s.paymentRepo.GetMonthlyRevenue(ctx, months)
	if err != nil {
		s.logger.Error("dashboard revenue chart", "months", months, "error", err)
		return nil, err
	}
	return data, nil
}

// ═══════════════════════════════════════════════════════════════
//  Engagement
// ═══════════════════════════════════════════════════════════════

type EngagementData struct {
	// Placeholder — would need progress_logs queries
	DAU                  int     `json:"dau"`
	WAU                  int     `json:"wau"`
	MAU                  int     `json:"mau"`
	AvgWorkoutsPerWeek   float64 `json:"avg_workouts_per_week"`
}

func (s *DashboardService) GetEngagement(ctx context.Context) (*EngagementData, error) {
	// These would be real SQL queries in production
	s.logger.Debug("dashboard engagement fetched")
	return &EngagementData{}, nil
}

// ═══════════════════════════════════════════════════════════════
//  Trainer Performance
// ═══════════════════════════════════════════════════════════════

type TrainerPerformance struct {
	TrainerID          string  `json:"trainer_id"`
	TrainerName        string  `json:"trainer_name"`
	TotalClients       int     `json:"total_clients"`
	ActiveClients      int     `json:"active_clients"`
	ClientCompletionPct float64 `json:"client_completion_pct"`
	WorkoutsCreated    int     `json:"workouts_created"`
	ProgramsCreated    int     `json:"programs_created"`
}

func (s *DashboardService) GetTrainerPerformance(ctx context.Context) ([]TrainerPerformance, error) {
	// Placeholder — would join users + trainer_clients + workouts + programs
	s.logger.Debug("dashboard trainer performance fetched")
	return []TrainerPerformance{}, nil
}
