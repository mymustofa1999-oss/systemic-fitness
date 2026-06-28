package service

import (
	"context"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/repository"
)

type CustomerSetupService struct {
	repo   *repository.CustomerSetupRepository
	logger *slog.Logger
}

func NewCustomerSetupService(r *repository.CustomerSetupRepository, logger *slog.Logger) *CustomerSetupService {
	return &CustomerSetupService{repo: r, logger: logger}
}

// ── Full Setup ──────────────────────────────────────────────────

func (s *CustomerSetupService) GetFullSetup(ctx context.Context, customerID string) (*repository.CustomerSetup, error) {
	setup, err := s.repo.GetFullSetup(ctx, customerID)
	if err != nil {
		s.logger.Error("get customer setup", "customer_id", customerID, "error", err)
		return nil, fmt.Errorf("getting customer setup: %w", err)
	}
	return setup, nil
}

// ── Staff Assignment ────────────────────────────────────────────

func (s *CustomerSetupService) GetStaffAssignment(ctx context.Context, clientID string) (*repository.StaffAssignment, error) {
	return s.repo.GetStaffAssignment(ctx, clientID)
}

func (s *CustomerSetupService) AssignStaff(ctx context.Context, clientID, staffID, roleType string) error {
	if err := s.repo.AssignStaff(ctx, clientID, staffID, roleType); err != nil {
		s.logger.Error("assign staff", "client_id", clientID, "staff_id", staffID, "role_type", roleType, "error", err)
		return fmt.Errorf("assigning staff: %w", err)
	}
	s.logger.Info("staff assigned", "client_id", clientID, "staff_id", staffID, "role_type", roleType)
	return nil
}

// ── HR Zones ────────────────────────────────────────────────────

func (s *CustomerSetupService) GetHRZone(ctx context.Context, customerID string) (*repository.CustomerHRZone, error) {
	return s.repo.GetHRZone(ctx, customerID)
}

func (s *CustomerSetupService) UpsertHRZone(ctx context.Context, z *repository.CustomerHRZone) error {
	if err := s.repo.UpsertHRZone(ctx, z); err != nil {
		s.logger.Error("upsert hr zone", "customer_id", z.CustomerID, "error", err)
		return fmt.Errorf("upserting hr zone: %w", err)
	}
	s.logger.Info("hr zone saved", "customer_id", z.CustomerID)
	return nil
}

// ── Customer Medicines ──────────────────────────────────────────

func (s *CustomerSetupService) ListCustomerMedicines(ctx context.Context, customerID string) ([]repository.CustomerMedicine, error) {
	return s.repo.ListCustomerMedicines(ctx, customerID)
}

func (s *CustomerSetupService) AddCustomerMedicine(ctx context.Context, cm *repository.CustomerMedicine) error {
	if err := s.repo.AddCustomerMedicine(ctx, cm); err != nil {
		s.logger.Error("add customer medicine", "customer_id", cm.CustomerID, "error", err)
		return fmt.Errorf("adding customer medicine: %w", err)
	}
	return nil
}

func (s *CustomerSetupService) RemoveCustomerMedicine(ctx context.Context, customerID, medicineID string) error {
	return s.repo.RemoveCustomerMedicine(ctx, customerID, medicineID)
}

// ── Customer Program Assignments ────────────────────────────────

func (s *CustomerSetupService) ListCustomerPrograms(ctx context.Context, customerID string) ([]repository.CustomerProgramAssignment, error) {
	return s.repo.ListCustomerPrograms(ctx, customerID)
}

func (s *CustomerSetupService) UpsertCustomerProgram(ctx context.Context, a *repository.CustomerProgramAssignment) error {
	if err := s.repo.UpsertCustomerProgram(ctx, a); err != nil {
		s.logger.Error("upsert customer program", "customer_id", a.CustomerID, "error", err)
		return fmt.Errorf("upserting customer program: %w", err)
	}
	return nil
}

func (s *CustomerSetupService) RemoveCustomerProgram(ctx context.Context, customerID, programCategoryID string) error {
	return s.repo.RemoveCustomerProgram(ctx, customerID, programCategoryID)
}

// ── Customer Priority ──────────────────────────────────────────

func (s *CustomerSetupService) UpdatePriority(ctx context.Context, customerID, priority string) error {
	if err := s.repo.UpdatePriority(ctx, customerID, priority); err != nil {
		s.logger.Error("update priority", "customer_id", customerID, "error", err)
		return fmt.Errorf("updating priority: %w", err)
	}
	s.logger.Info("priority updated", "customer_id", customerID, "priority", priority)
	return nil
}
