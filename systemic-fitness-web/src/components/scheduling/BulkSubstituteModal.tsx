"use client";

import { useEffect, useMemo, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import {
  ArrowRightLeft, Calendar as CalendarIcon, Loader2, X, AlertTriangle, CheckCircle2,
} from "lucide-react";

import { apiGet } from "@/lib/api";
import { useBulkSubstitute, BulkSubstituteResult } from "@/hooks/useTrainingSchedules";
import { cn, getInitials } from "@/lib/utils";

// ════════════════════════════════════════════════════════════════════
//  BulkSubstituteModal
//
//  Konsultan-only flow used when a trainer is sick / on leave for
//  several days. Reassigns ALL sessions + recurring schedule occurrences
//  for a trainer in a date range to another trainer in one shot.
//
//  After confirmation we show a success summary (materialized count,
//  substituted count, errors) before letting the user dismiss.
// ════════════════════════════════════════════════════════════════════

interface TeamMember {
  id: string;
  full_name: string;
  email: string;
  role: string;
  avatar_url?: string | null;
}

interface BulkSubstituteModalProps {
  open: boolean;
  onClose: () => void;
}

export function BulkSubstituteModal({ open, onClose }: BulkSubstituteModalProps) {
  const today = new Date().toISOString().slice(0, 10);

  const [originalTrainerId, setOriginalTrainerId] = useState("");
  const [substituteTrainerId, setSubstituteTrainerId] = useState("");
  const [dateFrom, setDateFrom] = useState(today);
  const [dateTo, setDateTo] = useState(today);
  const [reason, setReason] = useState("");
  const [resultSummary, setResultSummary] = useState<BulkSubstituteResult | null>(null);

  const bulk = useBulkSubstitute();

  // Reset state whenever the modal is reopened.
  useEffect(() => {
    if (open) {
      setOriginalTrainerId("");
      setSubstituteTrainerId("");
      setDateFrom(today);
      setDateTo(today);
      setReason("");
      setResultSummary(null);
    }
    // We intentionally exclude `today` so re-opens from any moment use
    // the local snapshot rather than re-rendering on every clock tick.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open]);

  // Close on Escape
  useEffect(() => {
    if (!open) return;
    function onKey(e: KeyboardEvent) {
      if (e.key === "Escape") onClose();
    }
    document.addEventListener("keydown", onKey);
    return () => document.removeEventListener("keydown", onKey);
  }, [open, onClose]);

  // ─── Team list ──
  const teamQuery = useQuery({
    queryKey: ["team", { limit: 100 }],
    queryFn: () => apiGet<TeamMember[]>("/api/team", { limit: 100 }),
    enabled: open,
  });

  const trainers = useMemo(() => {
    const all = (teamQuery.data?.data ?? []) as TeamMember[];
    return all.filter((m) => m.role === "trainer" || m.role === "admin" || m.role === "owner");
  }, [teamQuery.data]);

  const eligibleSubstitutes = useMemo(
    () => trainers.filter((t) => t.id !== originalTrainerId),
    [trainers, originalTrainerId],
  );

  const canSubmit =
    !!originalTrainerId &&
    !!substituteTrainerId &&
    !!dateFrom &&
    !!dateTo &&
    dateFrom <= dateTo &&
    reason.trim().length > 0 &&
    !bulk.isPending;

  async function handleSubmit() {
    const res = await bulk.mutateAsync({
      original_trainer_id: originalTrainerId,
      substitute_trainer_id: substituteTrainerId,
      date_from: dateFrom,
      date_to: dateTo,
      reason: reason.trim(),
    });
    setResultSummary((res.data ?? null) as BulkSubstituteResult | null);
  }

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 px-4">
      <div className="bg-white rounded-xl shadow-xl w-full max-w-2xl overflow-hidden animate-fade-in">
        {/* Header */}
        <div className="px-5 py-4 border-b border-slate-100 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="p-1.5 rounded-lg bg-amber-100 text-amber-700">
              <ArrowRightLeft className="h-4 w-4" />
            </div>
            <h2 className="font-bold text-slate-900">
              Bulk Substitute Trainer
            </h2>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        {/* Body */}
        <div className="px-5 py-4 space-y-4 max-h-[70vh] overflow-y-auto">
          {resultSummary ? (
            <ResultView result={resultSummary} onClose={onClose} />
          ) : (
            <>
              <div className="flex items-start gap-2 px-3 py-2 bg-blue-50 border border-blue-100 rounded-lg">
                <AlertTriangle className="h-4 w-4 text-blue-600 shrink-0 mt-0.5" />
                <p className="text-xs text-blue-800">
                  Gunakan flow ini saat trainer tidak bisa hadir untuk beberapa hari
                  (sakit, cuti, dll). Sistem akan memindahkan SEMUA sesi + jadwal
                  rutin trainer asli dalam rentang tanggal ke trainer pengganti.
                </p>
              </div>

              {/* Original trainer */}
              <div>
                <label className="block text-xs font-medium text-slate-600 mb-2">
                  Trainer asli (yang berhalangan) *
                </label>
                {teamQuery.isLoading ? (
                  <div className="flex items-center justify-center py-6">
                    <Loader2 className="h-5 w-5 animate-spin text-slate-400" />
                  </div>
                ) : trainers.length === 0 ? (
                  <p className="text-xs text-slate-500 italic">Tidak ada trainer.</p>
                ) : (
                  <div className="grid grid-cols-2 gap-2 max-h-48 overflow-y-auto">
                    {trainers.map((t) => (
                      <TrainerCard
                        key={t.id}
                        member={t}
                        selected={originalTrainerId === t.id}
                        onClick={() => {
                          setOriginalTrainerId(t.id);
                          // Clear substitute if it was the same person
                          if (substituteTrainerId === t.id) setSubstituteTrainerId("");
                        }}
                      />
                    ))}
                  </div>
                )}
              </div>

              {/* Substitute trainer */}
              <div>
                <label className="block text-xs font-medium text-slate-600 mb-2">
                  Trainer pengganti *
                </label>
                {!originalTrainerId ? (
                  <p className="text-xs text-slate-400 italic">
                    Pilih trainer asli dulu.
                  </p>
                ) : eligibleSubstitutes.length === 0 ? (
                  <p className="text-xs text-slate-500 italic">
                    Tidak ada trainer pengganti yang tersedia.
                  </p>
                ) : (
                  <div className="grid grid-cols-2 gap-2 max-h-48 overflow-y-auto">
                    {eligibleSubstitutes.map((t) => (
                      <TrainerCard
                        key={t.id}
                        member={t}
                        selected={substituteTrainerId === t.id}
                        onClick={() => setSubstituteTrainerId(t.id)}
                      />
                    ))}
                  </div>
                )}
              </div>

              {/* Date range */}
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-medium text-slate-600 mb-1">
                    Tanggal mulai *
                  </label>
                  <div className="relative">
                    <CalendarIcon className="h-4 w-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none" />
                    <input
                      type="date"
                      value={dateFrom}
                      onChange={(e) => setDateFrom(e.target.value)}
                      className="input w-full pl-9"
                    />
                  </div>
                </div>
                <div>
                  <label className="block text-xs font-medium text-slate-600 mb-1">
                    Tanggal akhir *
                  </label>
                  <div className="relative">
                    <CalendarIcon className="h-4 w-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none" />
                    <input
                      type="date"
                      value={dateTo}
                      min={dateFrom}
                      onChange={(e) => setDateTo(e.target.value)}
                      className="input w-full pl-9"
                    />
                  </div>
                </div>
              </div>
              {dateFrom && dateTo && dateFrom > dateTo && (
                <p className="text-xs text-red-600">
                  Tanggal akhir tidak boleh sebelum tanggal mulai.
                </p>
              )}

              {/* Reason */}
              <div>
                <label className="block text-xs font-medium text-slate-600 mb-1">
                  Alasan penggantian *
                </label>
                <textarea
                  value={reason}
                  onChange={(e) => setReason(e.target.value)}
                  className="input w-full"
                  rows={3}
                  placeholder="Mis. Trainer asli sakit selama seminggu, sedang cuti, dll..."
                />
              </div>
            </>
          )}
        </div>

        {/* Footer */}
        {!resultSummary && (
          <div className="px-5 py-3 border-t border-slate-100 flex justify-end gap-2 bg-slate-50">
            <button onClick={onClose} className="btn-secondary" disabled={bulk.isPending}>
              Batal
            </button>
            <button
              onClick={handleSubmit}
              disabled={!canSubmit}
              className="btn-primary"
            >
              {bulk.isPending && <Loader2 className="h-4 w-4 animate-spin" />}
              Konfirmasi Bulk Substitute
            </button>
          </div>
        )}
      </div>
    </div>
  );
}

// ─── Sub-components ────────────────────────────────────────────

function TrainerCard({
  member,
  selected,
  onClick,
}: {
  member: TeamMember;
  selected: boolean;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={cn(
        "flex items-center gap-2 p-2.5 rounded-lg border text-left transition-all",
        selected
          ? "border-sf-deepNavy bg-sf-iceBlue"
          : "border-slate-200 hover:border-slate-300",
      )}
    >
      <div className="h-8 w-8 rounded-full bg-sf-iceBlue text-sf-deepNavy flex items-center justify-center text-xs font-bold shrink-0 overflow-hidden">
        {member.avatar_url ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img src={member.avatar_url} alt={member.full_name} className="h-full w-full object-cover" />
        ) : (
          getInitials(member.full_name)
        )}
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-xs font-semibold text-slate-900 truncate">
          {member.full_name}
        </p>
        <p className="text-[10px] text-slate-500 capitalize">{member.role}</p>
      </div>
    </button>
  );
}

function ResultView({
  result,
  onClose,
}: {
  result: BulkSubstituteResult;
  onClose: () => void;
}) {
  const hasErrors = (result.errors?.length ?? 0) > 0;
  return (
    <div className="space-y-4">
      <div className="text-center py-4">
        <div
          className={cn(
            "inline-flex p-3 rounded-full mb-3",
            hasErrors ? "bg-amber-100" : "bg-green-100",
          )}
        >
          {hasErrors ? (
            <AlertTriangle className="h-8 w-8 text-amber-600" />
          ) : (
            <CheckCircle2 className="h-8 w-8 text-green-600" />
          )}
        </div>
        <h3 className="font-bold text-slate-900 text-lg">
          {hasErrors ? "Bulk substitute selesai dengan beberapa error" : "Bulk substitute berhasil"}
        </h3>
      </div>

      <div className="grid grid-cols-3 gap-3">
        <SummaryCard
          label="Berhasil"
          value={result.substituted_sessions}
          color="text-green-600"
          bg="bg-green-50"
        />
        <SummaryCard
          label="Materialized"
          value={result.materialized_sessions}
          color="text-blue-600"
          bg="bg-blue-50"
        />
        <SummaryCard
          label="Skipped"
          value={result.skipped_sessions}
          color="text-slate-600"
          bg="bg-slate-50"
        />
      </div>

      <p className="text-xs text-slate-500">
        <strong>Materialized</strong>: jumlah jadwal rutin yang dipromosikan jadi sesi
        baru sebelum substitusi. <strong>Skipped</strong>: sesi yang sudah cancelled,
        completed, atau sudah pernah disubstitusi.
      </p>

      {hasErrors && (
        <div className="bg-red-50 border border-red-100 rounded-lg p-3">
          <p className="text-xs font-semibold text-red-700 mb-2">
            Errors ({result.errors?.length}):
          </p>
          <ul className="space-y-1 max-h-32 overflow-y-auto">
            {result.errors!.map((e, i) => (
              <li key={i} className="text-xs text-red-600 font-mono">
                • {e}
              </li>
            ))}
          </ul>
        </div>
      )}

      <button onClick={onClose} className="btn-primary w-full">
        Tutup
      </button>
    </div>
  );
}

function SummaryCard({
  label,
  value,
  color,
  bg,
}: {
  label: string;
  value: number;
  color: string;
  bg: string;
}) {
  return (
    <div className={cn("p-3 rounded-lg text-center", bg)}>
      <p className={cn("text-2xl font-bold", color)}>{value}</p>
      <p className="text-[10px] text-slate-500 uppercase font-medium">{label}</p>
    </div>
  );
}
