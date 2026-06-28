package repository

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// ════════════════════════════════════════════════════════════════
//  Bank Account Repository
//  Admin-managed destination accounts for manual transfer payments
// ════════════════════════════════════════════════════════════════

type BankAccountRepository struct {
	db *pgxpool.Pool
}

func NewBankAccountRepository(db *pgxpool.Pool) *BankAccountRepository {
	return &BankAccountRepository{db: db}
}

type BankAccount struct {
	ID            string    `json:"id"`
	BankName      string    `json:"bank_name"`
	AccountNumber string    `json:"account_number"`
	AccountHolder string    `json:"account_holder"`
	Branch        *string   `json:"branch,omitempty"`
	Notes         *string   `json:"notes,omitempty"`
	IsActive      bool      `json:"is_active"`
	SortOrder     int       `json:"sort_order"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

const bankAccountColumns = `id, bank_name, account_number, account_holder, branch,
	notes, is_active, sort_order, created_at, updated_at`

func scanBankAccount(row pgx.Row) (*BankAccount, error) {
	b := &BankAccount{}
	err := row.Scan(&b.ID, &b.BankName, &b.AccountNumber, &b.AccountHolder, &b.Branch,
		&b.Notes, &b.IsActive, &b.SortOrder, &b.CreatedAt, &b.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return b, err
}

// ── List ────────────────────────────────────────────────────────

// List returns bank accounts. If activeOnly is true, only returns
// is_active=true rows ordered by sort_order then bank_name.
func (r *BankAccountRepository) List(ctx context.Context, activeOnly bool) ([]BankAccount, error) {
	query := fmt.Sprintf(`SELECT %s FROM bank_accounts`, bankAccountColumns)
	if activeOnly {
		query += ` WHERE is_active = TRUE`
	}
	query += ` ORDER BY sort_order ASC, bank_name ASC`

	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	accounts := make([]BankAccount, 0)
	for rows.Next() {
		var b BankAccount
		if err := rows.Scan(&b.ID, &b.BankName, &b.AccountNumber, &b.AccountHolder, &b.Branch,
			&b.Notes, &b.IsActive, &b.SortOrder, &b.CreatedAt, &b.UpdatedAt); err != nil {
			return nil, err
		}
		accounts = append(accounts, b)
	}
	return accounts, rows.Err()
}

// ── Get ─────────────────────────────────────────────────────────

func (r *BankAccountRepository) GetByID(ctx context.Context, id string) (*BankAccount, error) {
	return scanBankAccount(r.db.QueryRow(ctx, fmt.Sprintf(
		`SELECT %s FROM bank_accounts WHERE id = $1`, bankAccountColumns), id))
}

// GetFirstActive returns the first active bank account by sort_order.
// Used by the manual transfer flow when no specific account is requested.
func (r *BankAccountRepository) GetFirstActive(ctx context.Context) (*BankAccount, error) {
	return scanBankAccount(r.db.QueryRow(ctx, fmt.Sprintf(
		`SELECT %s FROM bank_accounts WHERE is_active = TRUE
		 ORDER BY sort_order ASC, bank_name ASC LIMIT 1`, bankAccountColumns)))
}

// ── Create ──────────────────────────────────────────────────────

func (r *BankAccountRepository) Create(ctx context.Context, b *BankAccount) error {
	return r.db.QueryRow(ctx, fmt.Sprintf(`
		INSERT INTO bank_accounts (bank_name, account_number, account_holder, branch, notes, is_active, sort_order)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING %s`, bankAccountColumns),
		b.BankName, b.AccountNumber, b.AccountHolder, b.Branch, b.Notes, b.IsActive, b.SortOrder,
	).Scan(&b.ID, &b.BankName, &b.AccountNumber, &b.AccountHolder, &b.Branch,
		&b.Notes, &b.IsActive, &b.SortOrder, &b.CreatedAt, &b.UpdatedAt)
}

// ── Update ──────────────────────────────────────────────────────

func (r *BankAccountRepository) Update(ctx context.Context, b *BankAccount) error {
	cmd, err := r.db.Exec(ctx, `
		UPDATE bank_accounts
		SET bank_name = $1, account_number = $2, account_holder = $3,
		    branch = $4, notes = $5, is_active = $6, sort_order = $7
		WHERE id = $8`,
		b.BankName, b.AccountNumber, b.AccountHolder, b.Branch, b.Notes,
		b.IsActive, b.SortOrder, b.ID,
	)
	if err != nil {
		return err
	}
	if cmd.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

// ── Delete ──────────────────────────────────────────────────────

func (r *BankAccountRepository) Delete(ctx context.Context, id string) error {
	cmd, err := r.db.Exec(ctx, `DELETE FROM bank_accounts WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if cmd.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}
