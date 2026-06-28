"use client";

import { useEffect, useRef, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  Loader2,
  History,
  CheckCircle2,
  XCircle,
  ExternalLink,
  Building2,
  CreditCard,
  Image as ImageIcon,
} from "lucide-react";
import { apiGet, apiPatch } from "@/lib/api";
import { cn, formatDate, formatCurrency } from "@/lib/utils";

const PAYMENT_STATUSES = ["pending", "completed", "failed", "refunded"] as const;
type PaymentStatus = (typeof PAYMENT_STATUSES)[number];

const statusColors: Record<string, string> = {
  completed: "bg-emerald-100 text-emerald-700",
  pending: "bg-amber-100 text-amber-700",
  failed: "bg-rose-100 text-rose-700",
  refunded: "bg-slate-100 text-slate-600",
};

interface PaymentLog {
  id: string;
  old_status: string | null;
  new_status: string;
  changed_by_name: string | null;
  reason: string | null;
  created_at: string;
}

interface Props {
  open: boolean;
  onClose: () => void;
  payment: {
    id: string;
    user_name?: string | null;
    user_email?: string | null;
    status: string;
    amount: number;
    currency: string;
    payment_type?: string | null;
    bank_name?: string | null;
    proof_image_url?: string | null;
    proof_uploaded_at?: string | null;
    snap_redirect_url?: string | null;
    gateway_status?: string | null;
    external_id?: string | null;
    created_at?: string;
  } | null;
}

export function PaymentStatusModal({ open, onClose, payment }: Props) {
  const queryClient = useQueryClient();
  const overlayRef = useRef<HTMLDivElement>(null);
  const [status, setStatus] = useState<PaymentStatus>("completed");
  const [reason, setReason] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [showFullProof, setShowFullProof] = useState(false);

  useEffect(() => {
    if (open && payment) {
      // Default to "completed" so the most common admin action (approve)
      // is one click away. Reason field starts empty.
      setStatus("completed");
      setReason("");
      setError(null);
      setShowFullProof(false);
    }
  }, [open, payment]);

  useEffect(() => {
    if (!open) return;
    const handler = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    document.addEventListener("keydown", handler);
    return () => document.removeEventListener("keydown", handler);
  }, [open, onClose]);

  const { data: logsResp, isLoading: logsLoading } = useQuery({
    queryKey: ["payment-logs", payment?.id],
    queryFn: () => apiGet<PaymentLog[]>(`/api/payments/${payment!.id}/logs`),
    enabled: open && !!payment?.id,
  });
  const logs = (logsResp?.data ?? []) as PaymentLog[];

  const mutation = useMutation({
    mutationFn: () =>
      apiPatch(`/api/payments/${payment!.id}/status`, {
        status,
        reason: reason.trim() || undefined,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["payments"] });
      queryClient.invalidateQueries({ queryKey: ["payment-logs", payment?.id] });
      queryClient.invalidateQueries({ queryKey: ["dashboard"] });
      onClose();
    },
    onError: (err: Error) => setError(err.message),
  });

  if (!open || !payment) return null;

  const isManualTransfer = payment.payment_type === "manual_transfer";
  const isMidtrans = payment.payment_type === "midtrans_snap";
  const hasProof = !!payment.proof_image_url;

  return (
    <div
      ref={overlayRef}
      className="fixed inset-0 z-50 flex items-center justify-center"
      onClick={(e) => {
        if (e.target === overlayRef.current) onClose();
      }}
    >
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm animate-fade-in" />

      <div className="relative bg-white rounded-2xl shadow-xl max-w-2xl w-full mx-4 p-6 animate-slide-in max-h-[90vh] overflow-y-auto">
        {/* ── Header ─────────────────────────────────────────── */}
        <div className="flex items-start justify-between">
          <div className="min-w-0">
            <h3 className="text-lg font-semibold text-slate-900">
              {isManualTransfer && payment.status === "pending"
                ? "Verify Payment Proof"
                : "Update Payment Status"}
            </h3>
            <p className="text-sm text-slate-500 mt-1 truncate">
              {payment.user_name || "—"}
              {payment.user_email && (
                <span className="text-slate-400"> · {payment.user_email}</span>
              )}
            </p>
            <p className="text-sm font-mono text-slate-700 mt-0.5">
              {formatCurrency(payment.amount, payment.currency)}
            </p>
          </div>
          <span
            className={cn(
              "px-2 py-0.5 rounded-full text-xs font-medium capitalize shrink-0",
              statusColors[payment.status]
            )}
          >
            {payment.status}
          </span>
        </div>

        {/* ── Payment type / source info ─────────────────────── */}
        <div className="mt-4 flex items-center gap-2 text-xs text-slate-500">
          {isMidtrans ? (
            <>
              <CreditCard className="h-3.5 w-3.5 text-blue-500" />
              <span>Midtrans Snap</span>
              {payment.gateway_status && (
                <span className="text-slate-400">· gateway: {payment.gateway_status}</span>
              )}
              {payment.external_id && (
                <span className="text-slate-400">· {payment.external_id}</span>
              )}
            </>
          ) : (
            <>
              <Building2 className="h-3.5 w-3.5 text-emerald-500" />
              <span>Manual Bank Transfer</span>
              {payment.bank_name && (
                <span className="text-slate-400">· {payment.bank_name}</span>
              )}
            </>
          )}
        </div>

        {/* ── Proof preview (manual transfer only) ───────────── */}
        {isManualTransfer && (
          <div className="mt-5">
            <label className="text-xs font-medium text-slate-600 flex items-center gap-1.5">
              <ImageIcon className="h-3.5 w-3.5" />
              Transfer Receipt
            </label>
            <div className="mt-2">
              {hasProof ? (
                <div className="rounded-lg border border-slate-200 overflow-hidden bg-slate-50">
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img
                    src={payment.proof_image_url!}
                    alt="Payment proof"
                    className="w-full max-h-80 object-contain cursor-zoom-in bg-slate-100"
                    onClick={() => setShowFullProof(true)}
                  />
                  <div className="flex items-center justify-between px-3 py-2 text-xs bg-white border-t border-slate-100">
                    <span className="text-slate-500">
                      Uploaded {payment.proof_uploaded_at && formatDate(payment.proof_uploaded_at)}
                    </span>
                    <a
                      href={payment.proof_image_url!}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="inline-flex items-center gap-1 text-sf-deepNavy hover:text-sf-deepNavy font-medium"
                    >
                      <ExternalLink className="h-3 w-3" /> Open original
                    </a>
                  </div>
                </div>
              ) : (
                <div className="rounded-lg border border-dashed border-amber-300 bg-amber-50 px-4 py-6 text-center">
                  <p className="text-sm text-amber-800 font-medium">
                    No proof uploaded yet
                  </p>
                  <p className="text-xs text-amber-700 mt-1">
                    Customer hasn&apos;t submitted a transfer receipt. Wait until they upload before approving.
                  </p>
                </div>
              )}
            </div>
          </div>
        )}

        {/* ── Quick actions for pending manual transfers ─────── */}
        {isManualTransfer && payment.status === "pending" && hasProof && (
          <div className="mt-4 grid grid-cols-2 gap-3">
            <button
              type="button"
              disabled={mutation.isPending}
              onClick={() => {
                setStatus("completed");
                setError(null);
                mutation.mutate();
              }}
              className="inline-flex items-center justify-center gap-2 px-4 py-2.5 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white text-sm font-semibold disabled:opacity-50 transition"
            >
              {mutation.isPending && status === "completed" ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                <CheckCircle2 className="h-4 w-4" />
              )}
              Approve & Activate
            </button>
            <button
              type="button"
              disabled={mutation.isPending}
              onClick={() => {
                setStatus("failed");
                setError(null);
                mutation.mutate();
              }}
              className="inline-flex items-center justify-center gap-2 px-4 py-2.5 rounded-lg bg-rose-600 hover:bg-rose-700 text-white text-sm font-semibold disabled:opacity-50 transition"
            >
              {mutation.isPending && status === "failed" ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                <XCircle className="h-4 w-4" />
              )}
              Reject
            </button>
          </div>
        )}

        <div className="mt-5">
          <label className="text-xs font-medium text-slate-600">Or set status manually</label>
          <div className="mt-2 grid grid-cols-2 gap-2">
            {PAYMENT_STATUSES.map((s) => (
              <button
                key={s}
                type="button"
                onClick={() => setStatus(s)}
                className={cn(
                  "px-3 py-2 rounded-lg text-sm font-medium border transition capitalize",
                  status === s
                    ? "border-sf-deepNavy bg-sf-iceBlue text-sf-deepNavy"
                    : "border-slate-200 text-slate-600 hover:bg-slate-50"
                )}
              >
                {s}
              </button>
            ))}
          </div>
        </div>

        <div className="mt-4">
          <label className="text-xs font-medium text-slate-600">Reason (optional)</label>
          <textarea
            value={reason}
            onChange={(e) => setReason(e.target.value)}
            rows={2}
            placeholder="e.g. Manual verification — bank transfer received"
            className="mt-1 w-full rounded-lg border border-slate-200 px-3 py-2 text-sm focus:border-sf-deepNavy focus:outline-none focus:ring-1 focus:ring-sf-warmGold/40"
          />
        </div>

        {status === "completed" && (
          <p className="mt-3 text-xs text-emerald-700 bg-emerald-50 border border-emerald-200 rounded-lg px-3 py-2">
            Marking as <strong>completed</strong> will automatically activate the user&apos;s
            subscription (flip <code>pending</code> → <code>active</code>) and set the
            expiry to <strong>now + plan duration</strong>.
          </p>
        )}

        {error && (
          <p className="mt-3 text-xs text-rose-700 bg-rose-50 border border-rose-200 rounded-lg px-3 py-2">
            {error}
          </p>
        )}

        <div className="flex justify-end gap-3 mt-5">
          <button onClick={onClose} disabled={mutation.isPending} className="btn-secondary">
            Cancel
          </button>
          <button
            onClick={() => {
              setError(null);
              mutation.mutate();
            }}
            disabled={mutation.isPending || status === payment.status}
            className="btn-primary"
          >
            {mutation.isPending && <Loader2 className="h-4 w-4 animate-spin" />}
            Save change
          </button>
        </div>

        <div className="mt-6 border-t border-slate-100 pt-4">
          <div className="flex items-center gap-2 text-sm font-semibold text-slate-700">
            <History className="h-4 w-4" /> Status history
          </div>
          <div className="mt-3 space-y-2">
            {logsLoading && <p className="text-xs text-slate-400">Loading…</p>}
            {!logsLoading && logs.length === 0 && (
              <p className="text-xs text-slate-400">No status changes yet.</p>
            )}
            {logs.map((l) => (
              <div
                key={l.id}
                className="rounded-lg border border-slate-100 bg-slate-50 px-3 py-2 text-xs"
              >
                <div className="flex items-center gap-2">
                  {l.old_status && (
                    <span
                      className={cn(
                        "px-1.5 py-0.5 rounded capitalize",
                        statusColors[l.old_status]
                      )}
                    >
                      {l.old_status}
                    </span>
                  )}
                  <span className="text-slate-400">→</span>
                  <span
                    className={cn(
                      "px-1.5 py-0.5 rounded capitalize",
                      statusColors[l.new_status]
                    )}
                  >
                    {l.new_status}
                  </span>
                  <span className="ml-auto text-slate-400">{formatDate(l.created_at)}</span>
                </div>
                <div className="mt-1 text-slate-600">
                  by <strong>{l.changed_by_name || "—"}</strong>
                  {l.reason ? ` · ${l.reason}` : ""}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* ── Full-screen proof lightbox ────────────────────────── */}
      {showFullProof && hasProof && (
        <div
          className="absolute inset-0 z-10 flex items-center justify-center bg-black/80 cursor-zoom-out"
          onClick={() => setShowFullProof(false)}
        >
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            src={payment.proof_image_url!}
            alt="Payment proof full"
            className="max-w-[95vw] max-h-[95vh] object-contain"
          />
        </div>
      )}
    </div>
  );
}
