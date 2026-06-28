"use client";

import { useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPost, apiPut, apiDelete } from "@/lib/api";
import { toast } from "@/stores/toastStore";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import {
  ArrowLeft,
  Plus,
  Pencil,
  Trash2,
  Loader2,
  Building2,
  CheckCircle2,
  XCircle,
} from "lucide-react";
import Link from "next/link";

interface BankAccount {
  id: string;
  bank_name: string;
  account_number: string;
  account_holder: string;
  branch?: string | null;
  notes?: string | null;
  is_active: boolean;
  sort_order: number;
  created_at: string;
  updated_at: string;
}

export default function BankAccountsPage() {
  const [createOpen, setCreateOpen] = useState(false);
  const [editing, setEditing] = useState<BankAccount | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ["bank-accounts"],
    queryFn: () => apiGet<BankAccount[]>("/api/payments/bank-accounts"),
  });
  const accounts = (data?.data ?? []) as BankAccount[];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Link
            href="/payments"
            className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400"
          >
            <ArrowLeft className="h-4 w-4" />
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-slate-900">Bank Accounts</h1>
            <p className="text-sm text-slate-500 mt-1">
              Destination accounts customers transfer to for manual payments
            </p>
          </div>
        </div>
        <button onClick={() => setCreateOpen(true)} className="btn-primary">
          <Plus className="h-4 w-4" /> Add Bank Account
        </button>
      </div>

      {isLoading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {Array.from({ length: 3 }).map((_, i) => (
            <div key={i} className="skeleton h-48 rounded-xl" />
          ))}
        </div>
      ) : accounts.length === 0 ? (
        <div className="card p-12 text-center">
          <Building2 className="h-12 w-12 mx-auto text-slate-300" />
          <p className="text-sm font-medium text-slate-700 mt-3">
            No bank accounts configured yet
          </p>
          <p className="text-xs text-slate-500 mt-1">
            Add at least one active account so customers can pay via manual transfer.
          </p>
          <button
            onClick={() => setCreateOpen(true)}
            className="btn-primary mt-4 inline-flex"
          >
            <Plus className="h-4 w-4" /> Add First Account
          </button>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {accounts.map((acc) => (
            <BankAccountCard
              key={acc.id}
              account={acc}
              onEdit={() => setEditing(acc)}
            />
          ))}
        </div>
      )}

      {createOpen && (
        <BankAccountFormModal mode="create" onClose={() => setCreateOpen(false)} />
      )}
      {editing && (
        <BankAccountFormModal
          mode="edit"
          account={editing}
          onClose={() => setEditing(null)}
        />
      )}
    </div>
  );
}

// ── Card ─────────────────────────────────────────────────────────

function BankAccountCard({
  account,
  onEdit,
}: {
  account: BankAccount;
  onEdit: () => void;
}) {
  const qc = useQueryClient();
  const [deleting, setDeleting] = useState(false);
  const [deleteOpen, setDeleteOpen] = useState(false);

  async function handleDelete() {
    setDeleting(true);
    try {
      await apiDelete(`/api/payments/bank-accounts/${account.id}`);
      qc.invalidateQueries({ queryKey: ["bank-accounts"] });
      toast.success("Bank account deleted");
      setDeleteOpen(false);
    } catch (e) {
      toast.error((e as Error).message);
    } finally {
      setDeleting(false);
    }
  }

  return (
    <div className="card p-5 flex flex-col">
      <div className="flex items-start justify-between mb-3">
        <div className="flex items-center gap-2">
          <div className="w-9 h-9 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center">
            <Building2 className="h-4 w-4" />
          </div>
          <div>
            <p className="text-sm font-bold text-slate-900 leading-tight">
              {account.bank_name}
            </p>
            {account.branch && (
              <p className="text-[11px] text-slate-400 mt-0.5">{account.branch}</p>
            )}
          </div>
        </div>
        {account.is_active ? (
          <span className="inline-flex items-center gap-1 text-[10px] font-medium text-emerald-700 bg-emerald-50 border border-emerald-200 px-1.5 py-0.5 rounded">
            <CheckCircle2 className="h-3 w-3" /> ACTIVE
          </span>
        ) : (
          <span className="inline-flex items-center gap-1 text-[10px] font-medium text-slate-500 bg-slate-100 border border-slate-200 px-1.5 py-0.5 rounded">
            <XCircle className="h-3 w-3" /> INACTIVE
          </span>
        )}
      </div>

      <p className="text-xl font-mono font-bold text-slate-800 tracking-wide">
        {account.account_number}
      </p>
      <p className="text-sm text-slate-500 mt-1">a.n. {account.account_holder}</p>

      {account.notes && (
        <p className="text-xs text-slate-400 mt-3 line-clamp-2">{account.notes}</p>
      )}

      <div className="text-[10px] text-slate-400 mt-3">
        Sort order: {account.sort_order}
      </div>

      <div className="flex gap-2 mt-4 pt-4 border-t border-slate-100">
        <button
          onClick={onEdit}
          className="flex-1 inline-flex items-center justify-center gap-1 text-xs font-medium text-sf-deepNavy hover:bg-sf-iceBlue px-3 py-2 rounded-lg transition"
        >
          <Pencil className="h-3.5 w-3.5" /> Edit
        </button>
        <button
          onClick={() => setDeleteOpen(true)}
          disabled={deleting}
          className="flex-1 inline-flex items-center justify-center gap-1 text-xs font-medium text-rose-600 hover:bg-rose-50 px-3 py-2 rounded-lg transition disabled:opacity-50"
        >
          {deleting ? (
            <Loader2 className="h-3.5 w-3.5 animate-spin" />
          ) : (
            <Trash2 className="h-3.5 w-3.5" />
          )}
          Delete
        </button>
      </div>

      <ConfirmDialog
        open={deleteOpen}
        onClose={() => setDeleteOpen(false)}
        onConfirm={handleDelete}
        title="Hapus Rekening"
        description={`Hapus rekening ${account.bank_name} ${account.account_number}? Tindakan ini tidak bisa dibatalkan.`}
        confirmLabel="Hapus"
        variant="danger"
        loading={deleting}
      />
    </div>
  );
}

// ── Form modal ───────────────────────────────────────────────────

function BankAccountFormModal({
  mode,
  account,
  onClose,
}: {
  mode: "create" | "edit";
  account?: BankAccount;
  onClose: () => void;
}) {
  const qc = useQueryClient();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [bankName, setBankName] = useState(account?.bank_name ?? "");
  const [accountNumber, setAccountNumber] = useState(account?.account_number ?? "");
  const [accountHolder, setAccountHolder] = useState(account?.account_holder ?? "");
  const [branch, setBranch] = useState(account?.branch ?? "");
  const [notes, setNotes] = useState(account?.notes ?? "");
  const [isActive, setIsActive] = useState(account?.is_active ?? true);
  const [sortOrder, setSortOrder] = useState(String(account?.sort_order ?? 0));

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!bankName.trim() || !accountNumber.trim() || !accountHolder.trim()) {
      setError("Bank name, account number, and account holder are required");
      return;
    }
    setLoading(true);
    setError(null);
    try {
      const payload = {
        bank_name: bankName.trim(),
        account_number: accountNumber.trim(),
        account_holder: accountHolder.trim(),
        branch: branch.trim() || undefined,
        notes: notes.trim() || undefined,
        is_active: isActive,
        sort_order: parseInt(sortOrder, 10) || 0,
      };
      if (mode === "create") {
        await apiPost("/api/payments/bank-accounts", payload);
        toast.success("Bank account created");
      } else if (account) {
        await apiPut(`/api/payments/bank-accounts/${account.id}`, payload);
        toast.success("Bank account updated");
      }
      qc.invalidateQueries({ queryKey: ["bank-accounts"] });
      onClose();
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center"
      onClick={(e) => {
        if (e.target === e.currentTarget) onClose();
      }}
    >
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm animate-fade-in" />

      <form
        onSubmit={handleSubmit}
        className="relative bg-white rounded-2xl shadow-xl max-w-md w-full mx-4 p-6 animate-slide-in max-h-[90vh] overflow-y-auto"
      >
        <h3 className="text-lg font-semibold text-slate-900">
          {mode === "create" ? "Add Bank Account" : "Edit Bank Account"}
        </h3>
        <p className="text-sm text-slate-500 mt-1">
          Customers will see active accounts when paying via manual transfer.
        </p>

        <div className="mt-5 space-y-4">
          <Field label="Bank Name *">
            <input
              type="text"
              value={bankName}
              onChange={(e) => setBankName(e.target.value)}
              className="input"
              placeholder="BCA"
              required
              maxLength={100}
            />
          </Field>

          <Field label="Account Number *">
            <input
              type="text"
              value={accountNumber}
              onChange={(e) => setAccountNumber(e.target.value)}
              className="input font-mono"
              placeholder="1234567890"
              required
              maxLength={50}
            />
          </Field>

          <Field label="Account Holder *">
            <input
              type="text"
              value={accountHolder}
              onChange={(e) => setAccountHolder(e.target.value)}
              className="input"
              placeholder="PT FitCoach Indonesia"
              required
              maxLength={100}
            />
          </Field>

          <Field label="Branch (optional)">
            <input
              type="text"
              value={branch}
              onChange={(e) => setBranch(e.target.value)}
              className="input"
              placeholder="KCP Jakarta Pusat"
              maxLength={100}
            />
          </Field>

          <Field label="Notes (optional)">
            <textarea
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              rows={2}
              className="input"
              placeholder="Internal notes — visible to customer if shown in instructions"
            />
          </Field>

          <div className="grid grid-cols-2 gap-3">
            <Field label="Sort Order">
              <input
                type="number"
                value={sortOrder}
                onChange={(e) => setSortOrder(e.target.value)}
                className="input"
                min={0}
              />
            </Field>
            <div>
              <label className="block text-xs font-medium text-slate-600 mb-1">
                Status
              </label>
              <button
                type="button"
                onClick={() => setIsActive(!isActive)}
                className={`w-full h-[38px] rounded-lg border text-sm font-medium transition ${
                  isActive
                    ? "border-emerald-300 bg-emerald-50 text-emerald-700"
                    : "border-slate-200 bg-slate-50 text-slate-500"
                }`}
              >
                {isActive ? "Active" : "Inactive"}
              </button>
            </div>
          </div>
        </div>

        {error && (
          <p className="mt-4 text-xs text-rose-700 bg-rose-50 border border-rose-200 rounded-lg px-3 py-2">
            {error}
          </p>
        )}

        <div className="flex justify-end gap-3 mt-6">
          <button
            type="button"
            onClick={onClose}
            disabled={loading}
            className="btn-secondary"
          >
            Cancel
          </button>
          <button type="submit" disabled={loading} className="btn-primary">
            {loading && <Loader2 className="h-4 w-4 animate-spin" />}
            {mode === "create" ? "Create" : "Save"}
          </button>
        </div>
      </form>
    </div>
  );
}

function Field({
  label,
  children,
}: {
  label: string;
  children: React.ReactNode;
}) {
  return (
    <div>
      <label className="block text-xs font-medium text-slate-600 mb-1">{label}</label>
      {children}
    </div>
  );
}
