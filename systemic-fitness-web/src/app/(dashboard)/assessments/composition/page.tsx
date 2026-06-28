"use client";

import Link from "next/link";
import { useState } from "react";
import {
  ArrowLeft, Moon, Activity, FlaskConical, AlertTriangle,
  Info, Loader2, ClipboardList,
} from "lucide-react";

import {
  useAssessmentSchema,
  SchemaSection,
  SchemaTier,
  AssessmentSchema,
} from "@/hooks/useAssessments";
import { cn } from "@/lib/utils";

// ════════════════════════════════════════════════════════════════════
//  Assessment Composition (read-only reference page)
//
//  Schema is fetched from GET /api/assessments/schema, which is the
//  single source of truth in the Go backend
//  (internal/handler/assessment_schema.go). The numbers there mirror
//  the actual scoring engine in
//  internal/service/assessment_engine.go.
// ════════════════════════════════════════════════════════════════════

type TabKey = "free" | "paid";

// ─── Icon resolver ────────────────────────────────────────────────

function iconFor(name: string) {
  switch (name) {
    case "moon":
      return Moon;
    case "activity":
      return Activity;
    case "flask":
      return FlaskConical;
    default:
      return ClipboardList;
  }
}

// ─── Tailwind color resolver for schema-driven colors ────────────

function flagColorClasses(color: string): string {
  switch (color) {
    case "red":
      return "bg-red-50 text-red-700 border-red-200";
    case "amber":
      return "bg-amber-50 text-amber-700 border-amber-200";
    case "green":
      return "bg-green-50 text-green-700 border-green-200";
    default:
      return "bg-slate-50 text-slate-700 border-slate-200";
  }
}

function bandColorClasses(color: string): string {
  switch (color) {
    case "red":
      return "bg-red-50 text-red-700";
    case "amber":
      return "bg-amber-50 text-amber-700";
    case "green":
      return "bg-green-50 text-green-700";
    default:
      return "bg-slate-100 text-slate-700";
  }
}

// ─── Components ──────────────────────────────────────────────────

function SectionCard({ section }: { section: SchemaSection }) {
  const Icon = iconFor(section.icon);
  return (
    <div className="card overflow-hidden">
      <div className="border-b border-slate-200 bg-slate-50/50 px-5 py-4">
        <div className="flex items-start gap-3">
          <div className="mt-0.5 rounded-lg bg-sf-iceBlue p-2 text-sf-deepNavy">
            <Icon className="h-5 w-5" />
          </div>
          <div className="flex-1">
            <h3 className="text-base font-semibold text-slate-900">{section.title}</h3>
            <p className="mt-1 text-sm text-slate-500">{section.description}</p>
            <div className="mt-3 grid gap-2 sm:grid-cols-2">
              <div className="rounded-md bg-white border border-slate-200 px-3 py-2">
                <div className="text-[10px] font-semibold uppercase tracking-wide text-slate-400">
                  Range
                </div>
                <div className="text-xs font-medium text-slate-700">{section.max_score}</div>
              </div>
              <div className="rounded-md bg-white border border-slate-200 px-3 py-2">
                <div className="text-[10px] font-semibold uppercase tracking-wide text-slate-400">
                  Formula
                </div>
                <div className="text-xs font-mono text-slate-700">{section.formula}</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <ol className="divide-y divide-slate-100">
        {section.questions.map((q, idx) => (
          <li key={q.key} className="px-5 py-4">
            <div className="flex items-start gap-3">
              <span className="mt-0.5 inline-flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-slate-100 text-xs font-semibold text-slate-600">
                {idx + 1}
              </span>
              <div className="flex-1 min-w-0">
                <div className="flex items-center justify-between gap-2">
                  <h4 className="text-sm font-semibold text-slate-900">{q.title}</h4>
                  <span className="text-[10px] font-mono text-slate-400">{q.key}</span>
                </div>
                {q.subtitle && (
                  <p className="mt-0.5 text-xs text-slate-500">{q.subtitle}</p>
                )}

                {q.input_type === "number" && (
                  <div className="mt-2 inline-flex items-center gap-2 rounded-md bg-slate-50 px-2.5 py-1 text-xs text-slate-600">
                    <span className="font-medium">Input:</span>
                    <span>numeric{q.unit ? ` (${q.unit})` : ""}</span>
                  </div>
                )}

                {q.input_type === "options" && q.options && (
                  <ul className="mt-2 space-y-1">
                    {q.options.map((opt) => (
                      <li
                        key={String(opt.value)}
                        className="flex items-center justify-between gap-2 rounded-md border border-slate-100 bg-slate-50/50 px-2.5 py-1.5 text-xs"
                      >
                        <span className="text-slate-700">{opt.label}</span>
                        <span className="flex items-center gap-2">
                          <span className="font-mono text-slate-400">value={String(opt.value)}</span>
                          {opt.points && (
                            <span className="rounded bg-white border border-slate-200 px-1.5 py-0.5 font-medium text-slate-600">
                              {opt.points}
                            </span>
                          )}
                        </span>
                      </li>
                    ))}
                  </ul>
                )}

                {q.points_rule && (
                  <div className="mt-2 text-[11px] text-slate-500">
                    <span className="font-semibold text-slate-600">Scoring: </span>
                    <span className="font-mono">{q.points_rule}</span>
                  </div>
                )}
              </div>
            </div>
          </li>
        ))}
      </ol>
    </div>
  );
}

function FlagsCard({ schema }: { schema: AssessmentSchema }) {
  return (
    <div className="card p-5">
      <div className="flex items-center gap-2 mb-3">
        <AlertTriangle className="h-4 w-4 text-amber-600" />
        <h3 className="text-sm font-semibold text-slate-900">Risk Flags</h3>
      </div>
      <p className="text-xs text-slate-500 mb-4">
        Auto-trigger berdasarkan jawaban klien. Flag muncul di list assessment & detail review.
      </p>
      <ul className="space-y-2">
        {schema.flags.map((f) => (
          <li
            key={f.key}
            className={cn("rounded-md border px-3 py-2 text-xs", flagColorClasses(f.color))}
          >
            <div className="flex items-center justify-between gap-2">
              <span className="font-semibold">{f.label}</span>
              <span className="font-mono text-[10px] opacity-70">{f.key}</span>
            </div>
            <div className="mt-1 font-mono text-[11px] opacity-80">{f.rule}</div>
          </li>
        ))}
      </ul>
    </div>
  );
}

function ClassificationCard({ schema }: { schema: AssessmentSchema }) {
  return (
    <div className="card p-5">
      <div className="flex items-center gap-2 mb-3">
        <Info className="h-4 w-4 text-sf-deepNavy" />
        <h3 className="text-sm font-semibold text-slate-900">Classification Bands</h3>
      </div>
      <p className="text-xs text-slate-500 mb-4">
        Setiap score dipetakan ke label kualitatif yang dipakai untuk framing hasil ke klien.
      </p>
      <div className="space-y-4">
        {schema.classifications.map((c) => (
          <div key={c.score}>
            <div className="text-xs font-semibold text-slate-700 mb-1.5">{c.score}</div>
            <div className="flex flex-wrap gap-1.5">
              {c.bands.map((b) => (
                <span
                  key={b.label}
                  className={cn(
                    "inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[11px] font-medium",
                    bandColorClasses(b.color),
                  )}
                >
                  <span>{b.label}</span>
                  <span className="font-mono opacity-70">{b.range}</span>
                </span>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function SystemScoreCard({ tier }: { tier: SchemaTier }) {
  return (
    <div className="card p-5">
      <h3 className="text-sm font-semibold text-slate-900 mb-2">System Score</h3>
      <p className="text-xs text-slate-500 mb-3">
        Total tertimbang yang ditampilkan sebagai angka utama hasil assessment.
      </p>
      <div className="rounded-md bg-slate-50 border border-slate-200 px-3 py-2 font-mono text-xs text-slate-700">
        {tier.system_score_formula}
      </div>
    </div>
  );
}

// ─── Page ─────────────────────────────────────────────────────────

export default function AssessmentCompositionPage() {
  const [tab, setTab] = useState<TabKey>("free");
  const { data, isLoading, isError, error } = useAssessmentSchema();
  const schema = data?.data;

  return (
    <div className="space-y-5">
      {/* Header */}
      <div>
        <Link
          href="/assessments"
          className="inline-flex items-center gap-1 text-xs text-slate-500 hover:text-slate-700"
        >
          <ArrowLeft className="h-3.5 w-3.5" />
          Kembali ke Assessments
        </Link>
        <div className="mt-1 flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-slate-900">Komposisi Assessment</h1>
            <p className="mt-1 text-sm text-slate-500">
              Daftar pertanyaan, opsi jawaban, dan rumus scoring yang digunakan oleh aplikasi
              mobile dan engine backend. Diambil langsung dari API (single source of truth).
            </p>
          </div>
          {schema?.version && (
            <span className="text-[10px] font-mono text-slate-400 self-start mt-1">
              schema v{schema.version}
            </span>
          )}
        </div>
      </div>

      {isLoading && (
        <div className="flex justify-center py-20">
          <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
        </div>
      )}

      {isError && (
        <div className="card p-6 text-center text-red-600">
          {error instanceof Error ? error.message : "Failed to load schema"}
        </div>
      )}

      {schema && (
        <>
          {/* Tabs */}
          <div className="flex items-center gap-1 border-b border-slate-200">
            <button
              type="button"
              onClick={() => setTab("free")}
              className={cn(
                "px-4 py-2.5 text-sm font-medium border-b-2 transition-colors -mb-px",
                tab === "free"
                  ? "border-sf-deepNavy text-sf-deepNavy"
                  : "border-transparent text-slate-500 hover:text-slate-700",
              )}
            >
              Free Assessment
            </button>
            <button
              type="button"
              onClick={() => setTab("paid")}
              className={cn(
                "px-4 py-2.5 text-sm font-medium border-b-2 transition-colors -mb-px",
                tab === "paid"
                  ? "border-sf-deepNavy text-sf-deepNavy"
                  : "border-transparent text-slate-500 hover:text-slate-700",
              )}
            >
              Paid Assessment
            </button>
          </div>

          {tab === "free" && (
            <div className="grid gap-5 lg:grid-cols-3">
              <div className="lg:col-span-2 space-y-5">
                {schema.free.sections.map((s) => (
                  <SectionCard key={s.key} section={s} />
                ))}
              </div>
              <div className="space-y-5">
                <SystemScoreCard tier={schema.free} />
                <ClassificationCard schema={schema} />
                <FlagsCard schema={schema} />
              </div>
            </div>
          )}

          {tab === "paid" && (
            <div className="grid gap-5 lg:grid-cols-3">
              <div className="lg:col-span-2 space-y-5">
                <div className="card p-5 bg-sf-iceBlue/50 border-sf-iceBlue">
                  <div className="flex items-start gap-3">
                    <Info className="mt-0.5 h-5 w-5 text-sf-deepNavy shrink-0" />
                    <div className="text-xs text-slate-700">
                      <p className="font-semibold text-slate-900 mb-1">
                        Paid = Free + Clinical + Trainer-Assisted Physical Screening
                      </p>
                      <p>
                        Paid assessment mewarisi seluruh pertanyaan Sleep + Movement dari
                        free assessment, lalu menambahkan input lab (metabolic) yang
                        di-input trainer dan observasi fisik dari sheet{" "}
                        <span className="font-mono">Basic Assessment Systemic Fitness.xlsx</span>.
                      </p>
                    </div>
                  </div>
                </div>

                {schema.paid.sections.map((s) => (
                  <SectionCard key={s.key} section={s} />
                ))}

                {/* Qualitative physical screening (not scored) */}
                <div className="card overflow-hidden">
                  <div className="border-b border-slate-200 bg-slate-50/50 px-5 py-4">
                    <h3 className="text-base font-semibold text-slate-900">
                      Physical Screening (Trainer Observation)
                    </h3>
                    <p className="mt-1 text-sm text-slate-500">
                      Diisi trainer/konsultan saat sesi guided. Bersifat kualitatif —
                      tidak masuk scoring engine, tapi menjadi bahan untuk reviewer notes
                      dan rekomendasi program.
                    </p>
                  </div>
                  <ul className="divide-y divide-slate-100">
                    {schema.physical_groups.map((sec) => (
                      <li key={sec.title} className="px-5 py-4">
                        <div className="text-sm font-semibold text-slate-800">{sec.title}</div>
                        <ul className="mt-2 space-y-1">
                          {sec.items.map((item) => (
                            <li
                              key={item}
                              className="text-xs text-slate-600 flex items-start gap-2"
                            >
                              <span className="mt-1 h-1 w-1 rounded-full bg-slate-400 shrink-0" />
                              <span>{item}</span>
                            </li>
                          ))}
                        </ul>
                      </li>
                    ))}
                  </ul>
                </div>
              </div>

              <div className="space-y-5">
                <SystemScoreCard tier={schema.paid} />
                <ClassificationCard schema={schema} />
                <FlagsCard schema={schema} />
              </div>
            </div>
          )}
        </>
      )}
    </div>
  );
}
