package handler

import (
	"errors"
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

// ════════════════════════════════════════════════════════════════
//  Bank Account Handler
//  Admin CRUD + client-side list (active accounts only)
// ════════════════════════════════════════════════════════════════

type BankAccountHandler struct {
	svc *service.BankAccountService
}

func NewBankAccountHandler(svc *service.BankAccountService) *BankAccountHandler {
	return &BankAccountHandler{svc: svc}
}

// GET /api/payments/bank-accounts
// GET /api/subscription/bank-accounts (client-facing alias, active_only=true forced)
func (h *BankAccountHandler) List(w http.ResponseWriter, r *http.Request) {
	activeOnly := r.URL.Query().Get("active_only") != "false"
	accounts, err := h.svc.List(r.Context(), activeOnly)
	if err != nil {
		response.InternalError(w, "Failed to fetch bank accounts")
		return
	}
	response.OK(w, accounts)
}

// GET /api/payments/bank-accounts/{id}
func (h *BankAccountHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	acc, err := h.svc.GetByID(r.Context(), id)
	if err != nil {
		if errors.Is(err, service.ErrBankAccountNotFound) {
			response.NotFound(w, "Bank account not found")
			return
		}
		response.InternalError(w, "Failed to fetch bank account")
		return
	}
	response.OK(w, acc)
}

// POST /api/payments/bank-accounts
func (h *BankAccountHandler) Create(w http.ResponseWriter, r *http.Request) {
	var input service.CreateBankAccountInput
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	acc, err := h.svc.Create(r.Context(), &input)
	if err != nil {
		slog.Error("[BankAccount.Create] failed", "error", err)
		response.InternalError(w, "Failed to create bank account")
		return
	}
	response.Created(w, acc)
}

// PUT /api/payments/bank-accounts/{id}
func (h *BankAccountHandler) Update(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")

	var input service.UpdateBankAccountInput
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	acc, err := h.svc.Update(r.Context(), id, &input)
	if err != nil {
		if errors.Is(err, service.ErrBankAccountNotFound) {
			response.NotFound(w, "Bank account not found")
			return
		}
		slog.Error("[BankAccount.Update] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to update bank account")
		return
	}
	response.OK(w, acc)
}

// DELETE /api/payments/bank-accounts/{id}
func (h *BankAccountHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.svc.Delete(r.Context(), id); err != nil {
		if errors.Is(err, service.ErrBankAccountNotFound) {
			response.NotFound(w, "Bank account not found")
			return
		}
		slog.Error("[BankAccount.Delete] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to delete bank account")
		return
	}
	response.SuccessMessage(w, "Bank account deleted")
}
