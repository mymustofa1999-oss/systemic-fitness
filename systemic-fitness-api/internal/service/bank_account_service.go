package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/repository"
)

// ════════════════════════════════════════════════════════════════
//  Bank Account Service
//  Manages destination bank accounts for manual transfer payments
// ════════════════════════════════════════════════════════════════

var ErrBankAccountNotFound = errors.New("bank account not found")

type BankAccountService struct {
	repo   *repository.BankAccountRepository
	logger *slog.Logger
}

func NewBankAccountService(
	repo *repository.BankAccountRepository,
	logger *slog.Logger,
) *BankAccountService {
	return &BankAccountService{repo: repo, logger: logger}
}

// ── Inputs ──────────────────────────────────────────────────────

type CreateBankAccountInput struct {
	BankName      string  `json:"bank_name"      validate:"required,min=1,max=100"`
	AccountNumber string  `json:"account_number" validate:"required,min=1,max=50"`
	AccountHolder string  `json:"account_holder" validate:"required,min=1,max=100"`
	Branch        *string `json:"branch,omitempty"        validate:"omitempty,max=100"`
	Notes         *string `json:"notes,omitempty"`
	IsActive      *bool   `json:"is_active,omitempty"`
	SortOrder     *int    `json:"sort_order,omitempty"`
}

type UpdateBankAccountInput struct {
	BankName      *string `json:"bank_name,omitempty"      validate:"omitempty,min=1,max=100"`
	AccountNumber *string `json:"account_number,omitempty" validate:"omitempty,min=1,max=50"`
	AccountHolder *string `json:"account_holder,omitempty" validate:"omitempty,min=1,max=100"`
	Branch        *string `json:"branch,omitempty"         validate:"omitempty,max=100"`
	Notes         *string `json:"notes,omitempty"`
	IsActive      *bool   `json:"is_active,omitempty"`
	SortOrder     *int    `json:"sort_order,omitempty"`
}

// ── Methods ─────────────────────────────────────────────────────

func (s *BankAccountService) List(ctx context.Context, activeOnly bool) ([]repository.BankAccount, error) {
	accounts, err := s.repo.List(ctx, activeOnly)
	if err != nil {
		s.logger.Error("list bank accounts", "active_only", activeOnly, "error", err)
		return nil, fmt.Errorf("listing bank accounts: %w", err)
	}
	return accounts, nil
}

func (s *BankAccountService) GetByID(ctx context.Context, id string) (*repository.BankAccount, error) {
	acc, err := s.repo.GetByID(ctx, id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, ErrBankAccountNotFound
		}
		s.logger.Error("get bank account", "id", id, "error", err)
		return nil, fmt.Errorf("getting bank account: %w", err)
	}
	return acc, nil
}

func (s *BankAccountService) Create(ctx context.Context, input *CreateBankAccountInput) (*repository.BankAccount, error) {
	acc := &repository.BankAccount{
		BankName:      input.BankName,
		AccountNumber: input.AccountNumber,
		AccountHolder: input.AccountHolder,
		Branch:        input.Branch,
		Notes:         input.Notes,
		IsActive:      true,
		SortOrder:     0,
	}
	if input.IsActive != nil {
		acc.IsActive = *input.IsActive
	}
	if input.SortOrder != nil {
		acc.SortOrder = *input.SortOrder
	}

	if err := s.repo.Create(ctx, acc); err != nil {
		s.logger.Error("create bank account", "bank_name", input.BankName, "error", err)
		return nil, fmt.Errorf("creating bank account: %w", err)
	}

	s.logger.Info("bank account created",
		"id", acc.ID,
		"bank_name", acc.BankName,
		"account_number", acc.AccountNumber,
	)
	return acc, nil
}

func (s *BankAccountService) Update(ctx context.Context, id string, input *UpdateBankAccountInput) (*repository.BankAccount, error) {
	existing, err := s.repo.GetByID(ctx, id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, ErrBankAccountNotFound
		}
		s.logger.Error("get bank account for update", "id", id, "error", err)
		return nil, fmt.Errorf("fetching bank account: %w", err)
	}

	if input.BankName != nil {
		existing.BankName = *input.BankName
	}
	if input.AccountNumber != nil {
		existing.AccountNumber = *input.AccountNumber
	}
	if input.AccountHolder != nil {
		existing.AccountHolder = *input.AccountHolder
	}
	if input.Branch != nil {
		existing.Branch = input.Branch
	}
	if input.Notes != nil {
		existing.Notes = input.Notes
	}
	if input.IsActive != nil {
		existing.IsActive = *input.IsActive
	}
	if input.SortOrder != nil {
		existing.SortOrder = *input.SortOrder
	}

	if err := s.repo.Update(ctx, existing); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, ErrBankAccountNotFound
		}
		s.logger.Error("update bank account", "id", id, "error", err)
		return nil, fmt.Errorf("updating bank account: %w", err)
	}

	s.logger.Info("bank account updated", "id", id)
	return existing, nil
}

func (s *BankAccountService) Delete(ctx context.Context, id string) error {
	if err := s.repo.Delete(ctx, id); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return ErrBankAccountNotFound
		}
		s.logger.Error("delete bank account", "id", id, "error", err)
		return fmt.Errorf("deleting bank account: %w", err)
	}
	s.logger.Info("bank account deleted", "id", id)
	return nil
}
