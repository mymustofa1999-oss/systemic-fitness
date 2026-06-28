"use client";

import { useEffect, useMemo, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { ArrowRightLeft, Loader2, X, AlertTriangle } from "lucide-react";

import { apiGet, apiPost } from "@/lib/api";
import { toast } from "@/stores/toastStore";
import { cn, getInitials } from "@/lib/utils";

// ════════════════════════════════════════════════════════════════════
//  AssignSubstituteModal
//
//  Konsultan-only dialog used to reassign a session to another trainer
//  when the original trainer can't make it.
//
//  Two source modes are supported:
//
//   1. source = "session"  → real session row already exists.
//      Single API call: POST /sessions/{id}/substitute
//
//   2. source = "schedule" → recurring schedule "ghost" cell on the
//      calendar. We need to MATERIALIZE that day's session first via
//      POST /sessions, then substitute the freshly created row.
//      This means the recurring schedule stays untouched and only the
//      single occurrence is replaced.
// ════════════════════════════════════════════════════════════════════

export interface SubstituteTarget {
  // The opaque calendar item id (session id OR sched-{id}-{date})
  id: string;
  source: "session" | "schedule";
  // Real underlying ids — needed for either path
  sessionId?: string;            // when source = session
  scheduleId?: string;           // when source = schedule
  clientId?: string;             // needed when materializing schedule
  // Display + create payload
  clientName: string;
  originalTrainerId: string;
  originalTrainerName: string;
  dateStr: string;               // "YYYY-MM-DD"
  startTime: string;             // "HH:mm" or "HH:mm:ss"
  endTime: string;
  location: string | null;
  notes: string | null;
}

interface TeamMember {
  id: string;
  full_name: string;
  email: string;
  role: string;
  avatar_url?: string | null;
}

interface AssignSubstituteModalProps {
  target: SubstituteTarget | null;
  onClose: () => void;
}

export function AssignSubstituteModal({ target, onClose }: AssignSubstituteModalProps) {
  const qc = useQueryClient();
  const [substituteTrainerId, setSubstituteTrainerId] = useState<string>("");
  const [reason, setReason] = useState("");

  // Reset form whenever a new target is selected.
  const targetId = target?.id;
  useEffect(() => {
    if (targetId) {
      setSubstituteTrainerId("");
      setReason("");
    }
  }, [targetId]);

  // ─── Team list (active trainers + admins) ──
  const teamQuery = useQuery({
    queryKey: ["team", { limit: 100 }],
    queryFn: () => apiGet<TeamMember[]>("/api/team", { limit: 100 }),
    enabled: !!target,
  });

  const eligibleTrainers = useMemo(() => {
    const all = (teamQuery.data?.data ?? []) as TeamMember[];
    // Exclude the original trainer — there's nothing to substitute *to* themselves.
    return all
      .filter((m) => m.role === "trainer" || m.role === "admin" || m.role === "owner")
      .filter((m) => m.id !== target?.originalTrainerId);
  }, [teamQuery.data, target?.originalTrainerId]);

  // ─── Mutation: substitute (handles both source modes) ──
  const mutation = useMutation({
    mutationFn: async () => {
      if (!target) throw new Error("No target");

      let sessionId = target.sessionId;

      // For schedule "ghost" rows, materialize the session first.
      if (target.source === "schedule") {
        if (!target.scheduleId || !target.clientId) {
          throw new Error("Missing schedule_id or client_id for materialization");
        }
        const created = await apiPost<{ id: string }>(
          "/api/training-schedules/sessions",
          {
            schedule_id: target.scheduleId,
            client_id: target.clientId,
            trainer_id: target.originalTrainerId, // start with the original trainer
            session_date: target.dateStr,
            start_time: normalizeTime(target.startTime),
            end_time: normalizeTime(target.endTime),
            status: "scheduled",
            location: target.location ?? null,
            notes: target.notes ?? null,
          },
        );
        sessionId = (created.data as { id: string } | undefined)?.id;
        if (!sessionId) {
          throw new Error("Backend did not return a session id");
        }
      }

      if (!sessionId) {
        throw new Error("Missing session id");
      }

      return apiPost(`/api/training-schedules/sessions/${sessionId}/substitute`, {
        substitute_trainer_id: substituteTrainerId,
        reason,
      });
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["training-sessions"] });
      qc.invalidateQueries({ queryKey: ["training-schedules"] });
      toast.success("Substitusi trainer berhasil disimpan");
      onClose();
    },
    onError: (err: Error) => toast.error(err.message),
  });

  // Close on Escape
  useEffect(() => {
    if (!target) return;
    function onKey(e: KeyboardEvent) {
      if (e.key === "Escape") onClose();
    }
    document.addEventListener("keydown", onKey);
    return () => document.removeEventListener("keydown", onKey);
  }, [target, onClose]);

  if (!target) return null;

  const canSubmit =
    !!substituteTrainerId &&
    reason.trim().length > 0 &&
    !mutation.isPending;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 px-4">
      <div className="bg-white rounded-xl shadow-xl w-full max-w-lg overflow-hidden animate-fade-in">
        {/* Header */}
        <div className="px-5 py-4 border-b border-slate-100 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="p-1.5 rounded-lg bg-amber-100 text-amber-700">
              <ArrowRightLeft className="h-4 w-4" />
            </div>
            <h2 className="font-bold text-slate-900">Assign Trainer Pengganti</h2>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        {/* Body */}
        <div className="px-5 py-4 space-y-4">
          {/* Session summary */}
          <div className="bg-slate-50 rounded-lg p-3 text-sm">
            <div className="flex items-center justify-between mb-1.5">
              <span className="font-semibold text-slate-900">{target.clientName}</span>
              {target.source === "schedule" && (
                <span className="inline-flex items-center px-2 py-0.5 text-[10px] font-medium rounded-full bg-indigo-50 text-indigo-700">
                  Jadwal Rutin
                </span>
              )}
            </div>
            <div className="text-xs text-slate-500 space-y-0.5">
              <div>{formatDateLong(target.dateStr)}</div>
              <div>
                {target.startTime.slice(0, 5)} – {target.endTime.slice(0, 5)}
                {target.location && ` · ${target.location}`}
              </div>
              <div>
                Trainer asli:{" "}
                <span className="font-medium text-slate-700">
                  {target.originalTrainerName}
                </span>
              </div>
            </div>
          </div>

          {target.source === "schedule" && (
            <div className="flex items-start gap-2 px-3 py-2 bg-indigo-50 border border-indigo-100 rounded-lg">
              <AlertTriangle className="h-4 w-4 text-indigo-600 shrink-0 mt-0.5" />
              <p className="text-xs text-indigo-800">
                Ini berasal dari jadwal rutin. Sistem akan membuat satu sesi
                pengganti untuk tanggal ini saja — jadwal rutin tidak berubah.
              </p>
            </div>
          )}

          {/* Trainer picker */}
          <div>
            <label className="block text-xs font-medium text-slate-600 mb-2">
              Pilih trainer pengganti *
            </label>
            {teamQuery.isLoading ? (
              <div className="flex items-center justify-center py-6">
                <Loader2 className="h-5 w-5 animate-spin text-slate-400" />
              </div>
            ) : eligibleTrainers.length === 0 ? (
              <p className="text-xs text-slate-500 italic">
                Tidak ada trainer lain yang tersedia.
              </p>
            ) : (
              <div className="grid grid-cols-2 gap-2 max-h-64 overflow-y-auto">
                {eligibleTrainers.map((t) => (
                  <button
                    key={t.id}
                    type="button"
                    onClick={() => setSubstituteTrainerId(t.id)}
                    className={cn(
                      "flex items-center gap-2 p-2.5 rounded-lg border text-left transition-all",
                      substituteTrainerId === t.id
                        ? "border-sf-deepNavy bg-sf-iceBlue"
                        : "border-slate-200 hover:border-slate-300",
                    )}
                  >
                    <div className="h-8 w-8 rounded-full bg-sf-iceBlue text-sf-deepNavy flex items-center justify-center text-xs font-bold shrink-0 overflow-hidden">
                      {t.avatar_url ? (
                        // eslint-disable-next-line @next/next/no-img-element
                        <img src={t.avatar_url} alt={t.full_name} className="h-full w-full object-cover" />
                      ) : (
                        getInitials(t.full_name)
                      )}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-xs font-semibold text-slate-900 truncate">
                        {t.full_name}
                      </p>
                      <p className="text-[10px] text-slate-500 capitalize">{t.role}</p>
                    </div>
                  </button>
                ))}
              </div>
            )}
          </div>

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
              placeholder="Mis. Trainer asli sakit, cuti, atau ada urgensi lain..."
            />
          </div>
        </div>

        {/* Footer */}
        <div className="px-5 py-3 border-t border-slate-100 flex justify-end gap-2 bg-slate-50">
          <button onClick={onClose} className="btn-secondary" disabled={mutation.isPending}>
            Batal
          </button>
          <button
            onClick={() => mutation.mutate()}
            disabled={!canSubmit}
            className="btn-primary"
          >
            {mutation.isPending && <Loader2 className="h-4 w-4 animate-spin" />}
            Konfirmasi Pengganti
          </button>
        </div>
      </div>
    </div>
  );
}

// ─── Helpers ───────────────────────────────────────────────────

function normalizeTime(t: string): string {
  // Backend expects HH:MM:SS — accept HH:MM or HH:MM:SS.
  return t.length === 5 ? `${t}:00` : t;
}

function formatDateLong(dateStr: string): string {
  const d = new Date(dateStr + "T00:00:00");
  return d.toLocaleDateString("id-ID", {
    weekday: "long",
    day: "numeric",
    month: "long",
    year: "numeric",
  });
}
