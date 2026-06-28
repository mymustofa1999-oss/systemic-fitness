"use client";

import Link from "next/link";
import { useParams, useRouter } from "next/navigation";
import { useState, useEffect, useMemo } from "react";
import {
  ArrowLeft, Loader2, AlertCircle, CheckCircle2, History,
} from "lucide-react";

import {
  useAssessment,
  useReviewAssessment,
  useUserAssessments,
  Assessment,
  ReviewPayload,
  AssessmentClassification,
} from "@/hooks/useAssessments";
import { useUser } from "@/hooks/useUsers";
import { useAuth } from "@/hooks/useAuth";
import { cn } from "@/lib/utils";

// ─── Helpers ───────────────────────────────────────────────────

function classColor(cls: AssessmentClassification | undefined): string {
  if (!cls) return "text-slate-500";
  switch (cls) {
    case "optimal":
    case "stable":
    case "efficient":
      return "text-green-600";
    case "compromised":
    case "compensation":
    case "at_risk":
      return "text-amber-600";
    default:
      return "text-red-600";
  }
}

function classBg(cls: AssessmentClassification | undefined): string {
  if (!cls) return "bg-slate-100";
  switch (cls) {
    case "optimal":
    case "stable":
    case "efficient":
      return "bg-green-50";
    case "compromised":
    case "compensation":
    case "at_risk":
      return "bg-amber-50";
    default:
      return "bg-red-50";
  }
}

function classLabel(cls: AssessmentClassification | undefined): string {
  if (!cls) return "—";
  return cls.replace("_", " ").replace(/\b\w/g, (c) => c.toUpperCase());
}

function scoreColor(score: number): string {
  if (score >= 80) return "text-green-600";
  if (score >= 60) return "text-amber-600";
  return "text-red-600";
}

function formatDate(iso: string): string {
  return new Intl.DateTimeFormat("id-ID", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  }).format(new Date(iso));
}

// ─── Page ──────────────────────────────────────────────────────

export default function AssessmentDetailPage() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const { data, isLoading, isError, error } = useAssessment(params.id);
  const review = useReviewAssessment();

  const a = data?.data as Assessment | undefined;
  const userQuery = useUser(a?.user_id ?? "");
  const userName = (userQuery.data?.data as any)?.full_name as string | undefined;
  const userEmail = (userQuery.data?.data as any)?.email as string | undefined;

  // Per-user history (sidebar panel)
  const historyQuery = useUserAssessments(a?.user_id ?? undefined, { limit: 10 });
  const history = (historyQuery.data?.data ?? []) as Assessment[];

  // ─── Review form state ──
  const [status, setStatus] = useState<"verified" | "revised">("verified");
  const [notes, setNotes] = useState("");
  const [overrideMetabolic, setOverrideMetabolic] = useState(false);
  const [hbA1c, setHbA1c] = useState("");
  const [ldl, setLdl] = useState("");
  const [trig, setTrig] = useState("");

  // Pre-fill metabolic fields whenever the assessment data loads so
  // the inputs reflect the current persisted values.
  const metabolic = a?.metabolic;
  const reviewerNotes = a?.reviewer_notes;
  useEffect(() => {
    if (metabolic) {
      setHbA1c(String(metabolic.hba1c));
      setLdl(String(metabolic.ldl));
      setTrig(String(metabolic.triglyceride));
    }
    if (reviewerNotes) setNotes(reviewerNotes);
  }, [metabolic, reviewerNotes]);

  // Review is admin/owner only — trainers can VIEW the queue + detail
  // pages (read-only) but cannot submit reviews. Backend also enforces.
  const { isAdmin } = useAuth();
  const canReview = useMemo(() => a?.tier === "paid" && isAdmin, [a?.tier, isAdmin]);

  async function handleSubmitReview() {
    if (!a) return;
    const payload: ReviewPayload = {
      status,
      reviewer_notes: notes.trim() || undefined,
    };
    if (overrideMetabolic) {
      const h = parseFloat(hbA1c);
      const l = parseFloat(ldl);
      const t = parseFloat(trig);
      if (isNaN(h) || isNaN(l) || isNaN(t) || h <= 0 || l <= 0 || t <= 0) {
        alert("Lab values harus angka positif");
        return;
      }
      payload.metabolic = {
        hba1c: h,
        ldl: l,
        triglyceride: t,
        medications: a.metabolic?.medications ?? [],
      };
    }
    await review.mutateAsync({ id: a.id, payload });
  }

  if (isLoading) {
    return (
      <div className="flex justify-center py-20">
        <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
      </div>
    );
  }
  if (isError || !a) {
    return (
      <div className="card p-6 text-center text-red-600">
        {error instanceof Error ? error.message : "Assessment tidak ditemukan"}
      </div>
    );
  }

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <button
            onClick={() => router.back()}
            className="flex items-center gap-1 text-sm text-slate-500 hover:text-slate-700 mb-2"
          >
            <ArrowLeft className="h-4 w-4" />
            Kembali
          </button>
          <h1 className="text-2xl font-bold text-slate-900">
            Assessment Detail
          </h1>
          <p className="text-sm text-slate-500 mt-1">
            {userName ? (
              <>
                <span className="font-medium text-slate-700">{userName}</span>
                {userEmail && <> · {userEmail}</>}
              </>
            ) : a.user_id ? (
              <span className="font-mono text-xs">{a.user_id}</span>
            ) : (
              "Anonim (lead)"
            )}
            <span className="mx-2">·</span>
            {formatDate(a.created_at)}
          </p>
        </div>
        <div className="flex items-center gap-2">
          <span className={cn(
            "inline-flex px-3 py-1 text-xs font-semibold rounded-full",
            a.tier === "paid" ? "bg-purple-50 text-purple-700" : "bg-slate-100 text-slate-600",
          )}>
            {a.tier === "paid" ? "Paid" : "Free"}
          </span>
          <span className={cn(
            "inline-flex px-3 py-1 text-xs font-semibold rounded-full",
            a.status === "submitted" && "bg-amber-50 text-amber-700",
            a.status === "verified" && "bg-green-50 text-green-700",
            a.status === "revised" && "bg-blue-50 text-blue-700",
          )}>
            {a.status}
          </span>
        </div>
      </div>

      {/* Top: Scores summary */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <ScoreCard label="System" score={a.scores.system_score} highlight />
        <ScoreCard
          label="Sleep"
          score={a.scores.sleep_score}
          classification={a.sleep_class}
        />
        <ScoreCard
          label="Movement"
          score={a.scores.movement_score}
          classification={a.movement_class}
        />
        <ScoreCard
          label="Metabolic"
          score={a.scores.metabolic_score ?? null}
          classification={a.metabolic_class}
        />
      </div>

      {/* Body: 3 columns */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
        {/* ─── Inputs ─── */}
        <div className="card p-5 space-y-4">
          <h2 className="font-bold text-slate-900">Raw Inputs</h2>

          <Section title="Sleep">
            <KV label="Duration" value={`${a.sleep.duration_hours} jam`} />
            <KV label="Consistency" value={`${a.sleep.consistency} / 3`} />
            <KV label="Latency" value={`${a.sleep.latency_minutes} menit`} />
            <KV label="Morning Readiness" value={`${a.sleep.morning_readiness} / 3`} />
            <KV label="Wake Frequency" value={`${a.sleep.wake_frequency}x`} />
            <KV label="Pre-sleep Habit" value={`${a.sleep.pre_sleep_habit} / 3`} />
          </Section>

          <Section title="Movement">
            <KV label="Squat" value={`${a.movement.squat} / 3`} />
            <KV label="Hip Hinge" value={`${a.movement.hip_hinge} / 3`} />
            <KV label="Overhead" value={`${a.movement.overhead} / 3`} />
          </Section>

          {a.metabolic && (
            <Section title="Metabolic (Lab)">
              <KV label="HbA1c" value={`${a.metabolic.hba1c} %`} />
              <KV label="LDL" value={`${a.metabolic.ldl} mg/dL`} />
              <KV label="Triglyceride" value={`${a.metabolic.triglyceride} mg/dL`} />
              <KV
                label="Medications"
                value={
                  a.metabolic.medications && a.metabolic.medications.length > 0
                    ? a.metabolic.medications.join(", ")
                    : "—"
                }
              />
            </Section>
          )}
        </div>

        {/* ─── Insight + Flags ─── */}
        <div className="card p-5 space-y-4">
          <h2 className="font-bold text-slate-900">Analysis</h2>

          <div>
            <div className="text-xs font-semibold text-slate-500 uppercase mb-2">
              Insight
            </div>
            <div className="bg-slate-50 rounded-lg p-3 text-sm text-slate-800">
              {a.insight}
            </div>
          </div>

          {a.flags.length > 0 && (
            <div>
              <div className="text-xs font-semibold text-slate-500 uppercase mb-2">
                Risk Flags
              </div>
              <div className="space-y-1.5">
                {a.flags.map((f) => (
                  <div
                    key={f}
                    className="flex items-center gap-2 bg-red-50 text-red-700 px-3 py-2 rounded-lg text-xs font-medium"
                  >
                    <AlertCircle className="h-4 w-4 shrink-0" />
                    {f}
                  </div>
                ))}
              </div>
            </div>
          )}

          {a.recommendations.length > 0 && (
            <div>
              <div className="text-xs font-semibold text-slate-500 uppercase mb-2">
                Recommendations
              </div>
              <ul className="space-y-1.5">
                {a.recommendations.map((rec, i) => (
                  <li
                    key={i}
                    className="flex items-start gap-2 text-sm text-slate-700"
                  >
                    <CheckCircle2 className="h-4 w-4 shrink-0 text-green-600 mt-0.5" />
                    {rec}
                  </li>
                ))}
              </ul>
            </div>
          )}

          {a.reviewed_at && (
            <div className="border-t border-slate-100 pt-3">
              <div className="text-xs font-semibold text-slate-500 uppercase mb-1">
                Review Saat Ini
              </div>
              <div className="text-xs text-slate-500">
                Direview {formatDate(a.reviewed_at)}
              </div>
              {a.reviewer_notes && (
                <div className="bg-yellow-50 border border-yellow-200 rounded p-2 mt-2 text-xs text-slate-700">
                  {a.reviewer_notes}
                </div>
              )}
            </div>
          )}
        </div>

        {/* ─── Review Form ─── */}
        <div className="card p-5 space-y-4">
          <h2 className="font-bold text-slate-900">Review</h2>

          {!canReview ? (
            <div className="bg-slate-50 rounded-lg p-3 text-xs text-slate-500">
              {a.tier !== "paid"
                ? "Hanya paid assessment yang bisa direview."
                : !isAdmin
                  ? "Review hanya bisa dilakukan oleh konsultan/admin. Anda hanya bisa melihat detail assessment."
                  : "Tidak ada review yang bisa dilakukan."}
            </div>
          ) : (
            <>
              <div>
                <label className="block text-xs font-medium text-slate-600 mb-1">
                  Status
                </label>
                <div className="grid grid-cols-2 gap-2">
                  <button
                    type="button"
                    onClick={() => setStatus("verified")}
                    className={cn(
                      "px-3 py-2 text-sm rounded-lg border font-medium",
                      status === "verified"
                        ? "border-green-500 bg-green-50 text-green-700"
                        : "border-slate-200 text-slate-600 hover:bg-slate-50",
                    )}
                  >
                    Verified
                  </button>
                  <button
                    type="button"
                    onClick={() => setStatus("revised")}
                    className={cn(
                      "px-3 py-2 text-sm rounded-lg border font-medium",
                      status === "revised"
                        ? "border-blue-500 bg-blue-50 text-blue-700"
                        : "border-slate-200 text-slate-600 hover:bg-slate-50",
                    )}
                  >
                    Revised
                  </button>
                </div>
              </div>

              <div>
                <label className="block text-xs font-medium text-slate-600 mb-1">
                  Catatan untuk klien
                </label>
                <textarea
                  value={notes}
                  onChange={(e) => setNotes(e.target.value)}
                  className="input w-full"
                  rows={4}
                  placeholder="Catatan opsional yang akan dilihat klien..."
                />
              </div>

              <div className="border-t border-slate-100 pt-3">
                <label className="flex items-center gap-2 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={overrideMetabolic}
                    onChange={(e) => setOverrideMetabolic(e.target.checked)}
                    className="rounded"
                  />
                  <span className="text-sm font-medium text-slate-700">
                    Override lab values
                  </span>
                </label>
                <p className="text-xs text-slate-500 mt-1 ml-6">
                  Kalau dicentang, scores akan dihitung ulang dengan nilai baru.
                </p>

                {overrideMetabolic && (
                  <div className="space-y-2 mt-3 ml-6">
                    <LabInput label="HbA1c (%)" value={hbA1c} onChange={setHbA1c} />
                    <LabInput label="LDL (mg/dL)" value={ldl} onChange={setLdl} />
                    <LabInput
                      label="Triglyceride (mg/dL)"
                      value={trig}
                      onChange={setTrig}
                    />
                  </div>
                )}
              </div>

              <button
                onClick={handleSubmitReview}
                disabled={review.isPending}
                className="btn-primary w-full"
              >
                {review.isPending && <Loader2 className="h-4 w-4 animate-spin" />}
                Simpan Review
              </button>
            </>
          )}
        </div>
      </div>

      {/* Per-user history */}
      {a.user_id && history.length > 0 && (
        <div className="card p-5">
          <div className="flex items-center gap-2 mb-3">
            <History className="h-5 w-5 text-slate-400" />
            <h2 className="font-bold text-slate-900">
              Histori {userName ?? "User"} ({history.length})
            </h2>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="border-b border-slate-100">
                <tr>
                  <th className="text-left px-2 py-2 font-semibold text-slate-500">Tanggal</th>
                  <th className="text-center px-2 py-2 font-semibold text-slate-500">Tier</th>
                  <th className="text-center px-2 py-2 font-semibold text-slate-500">System</th>
                  <th className="text-center px-2 py-2 font-semibold text-slate-500">Sleep</th>
                  <th className="text-center px-2 py-2 font-semibold text-slate-500">Movement</th>
                  <th className="text-center px-2 py-2 font-semibold text-slate-500">Metabolic</th>
                  <th className="text-center px-2 py-2 font-semibold text-slate-500">Status</th>
                  <th className="text-right px-2 py-2"></th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-50">
                {history.map((h) => (
                  <tr
                    key={h.id}
                    className={cn("hover:bg-slate-50/50", h.id === a.id && "bg-sf-iceBlue/40")}
                  >
                    <td className="px-2 py-2 text-xs text-slate-500">{formatDate(h.created_at)}</td>
                    <td className="px-2 py-2 text-center">{h.tier}</td>
                    <td className={cn("px-2 py-2 text-center font-bold", scoreColor(h.scores.system_score))}>
                      {h.scores.system_score}
                    </td>
                    <td className="px-2 py-2 text-center">{h.scores.sleep_score}</td>
                    <td className="px-2 py-2 text-center">{h.scores.movement_score}</td>
                    <td className="px-2 py-2 text-center">{h.scores.metabolic_score ?? "—"}</td>
                    <td className="px-2 py-2 text-center text-xs">{h.status}</td>
                    <td className="px-2 py-2 text-right">
                      {h.id !== a.id && (
                        <Link
                          href={`/assessments/${h.id}`}
                          className="text-xs text-sf-deepNavy hover:underline"
                        >
                          Lihat
                        </Link>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
}

// ─── Sub-components ────────────────────────────────────────────

function ScoreCard({
  label,
  score,
  classification,
  highlight = false,
}: {
  label: string;
  score: number | null;
  classification?: AssessmentClassification;
  highlight?: boolean;
}) {
  return (
    <div
      className={cn(
        "card p-4",
        highlight && "border-2 border-sf-deepNavy",
      )}
    >
      <div className="text-xs font-semibold text-slate-500 uppercase">{label}</div>
      <div className={cn("text-3xl font-bold mt-1", score == null ? "text-slate-300" : scoreColor(score))}>
        {score == null ? "—" : score}
      </div>
      {classification && (
        <div className={cn(
          "inline-flex px-2 py-0.5 text-xs font-medium rounded-full mt-2",
          classBg(classification),
          classColor(classification),
        )}>
          {classLabel(classification)}
        </div>
      )}
    </div>
  );
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div>
      <div className="text-xs font-semibold text-slate-500 uppercase mb-2">{title}</div>
      <div className="space-y-1.5">{children}</div>
    </div>
  );
}

function KV({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-center justify-between text-sm">
      <span className="text-slate-500">{label}</span>
      <span className="font-medium text-slate-800">{value}</span>
    </div>
  );
}

function LabInput({
  label,
  value,
  onChange,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
}) {
  return (
    <div>
      <label className="block text-xs text-slate-500 mb-1">{label}</label>
      <input
        type="number"
        step="0.01"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="input w-full"
      />
    </div>
  );
}
