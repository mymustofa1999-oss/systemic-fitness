"use client";

import Link from "next/link";
import {
  useLatestAssessmentV2,
  useTrainingCardForUser,
  type AssessmentV2,
  type ProgramType,
} from "@/hooks/useAssessmentV2";
import { useUser } from "@/hooks/useUsers";
import {
  useConditionClassifications,
  useSpecificConditions,
} from "@/hooks/useConditionMaster";
import {
  Loader2, ArrowLeft, AlertTriangle, Clock, Activity, Apple, Moon,
  Check, Minus, ClipboardList,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { ResponsiveContainer, RadialBarChart, RadialBar } from "recharts";

// SF Phase 3 — Read-only viewer hasil Assessment v2 untuk klien tertentu.
// Branding: pakai palette SF baru (warmWhite + DM fonts) sebagai preview.

export default function ClientAssessmentV2ViewerPage({
  params,
}: {
  params: { id: string };
}) {
  const userId = params.id;
  const { data: userResp } = useUser(userId);
  const { data, isLoading, error } = useLatestAssessmentV2(userId);

  const user = (userResp?.data as { full_name?: string; email?: string } | undefined);
  const a = data?.data as AssessmentV2 | undefined;

  return (
    <div className="space-y-5 bg-sf-warmWhite min-h-full -m-6 p-6 rounded-xl">
      <div className="flex items-center gap-3">
        <Link
          href={`/clients/${userId}`}
          className="p-2 rounded hover:bg-sf-iceBlue text-slate-400 hover:text-sf-systemBlue transition-colors"
        >
          <ArrowLeft className="h-4 w-4" />
        </Link>
        <div>
          <h1 className="sf-headline text-2xl">
            Hasil Asesmen v2{" "}
            {user?.full_name && <span className="text-slate-500 text-base">— {user.full_name}</span>}
          </h1>
          <p className="sf-body text-xs text-slate-500 mt-0.5">
            Output Phase A/B/C: System Score 35/35/30, Chronobiology Window, dan rekomendasi program.
          </p>
        </div>
      </div>

      {isLoading ? (
        <div className="flex justify-center py-20">
          <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
        </div>
      ) : !a ? (
        <EmptyState error={error} />
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
          {/* System Score Card */}
          <div className="lg:col-span-1 card p-6 bg-sf-deepNavy border-sf-deepNavy text-white">
            <p className="font-dm-sans text-xs uppercase tracking-wider text-sf-warmGold">
              SYSTEM SCORE
            </p>
            <p className="sf-headline text-2xl text-white mt-1">
              Skor Komposit
            </p>

            <div className="mt-6 flex justify-center">
              <SystemScoreGauge value={a.system_score ?? 0} />
            </div>

            <div className="mt-6 space-y-3">
              <ScoreRow label="Movement" value={a.movement_score} color="text-sf-deepTeal" />
              <ScoreRow label="Nutrition" value={a.nutrition_score} color="text-sf-systemBlue" />
              <ScoreRow label="Rest" value={a.rest_score} color="text-sf-warmGold" />
            </div>

            {a.system_score == null && (
              <p className="font-dm-sans text-xs text-white/50 mt-4 italic">
                System Score belum lengkap — menunggu Phase B + Phase C.
              </p>
            )}
          </div>

          {/* Phase A summary */}
          <div className="lg:col-span-2 space-y-5">
            <div className="card p-6 bg-white">
              <h2 className="sf-headline text-xl">Profil Phase A</h2>
              <div className="grid grid-cols-2 gap-4 mt-4 font-dm-sans text-sm">
                <Field label="Physical Status">
                  <Badge tone="navy">{prettyLevel(a.physical_status_level)}</Badge>
                </Field>
                <Field label="Program Type">
                  <Badge tone="gold">{prettyProgram(a.program_type)}</Badge>
                </Field>
                {a.phase_a.classification_slug && (
                  <Field label="Klasifikasi Kondisi">
                    <span className="font-dm-mono text-xs">{a.phase_a.classification_slug}</span>
                  </Field>
                )}
                {a.phase_a.specific_condition_slug && (
                  <Field label="Kondisi Spesifik">
                    <span className="font-dm-mono text-xs">{a.phase_a.specific_condition_slug}</span>
                  </Field>
                )}
                {a.phase_a.gender && (
                  <Field label="Gender / Usia">
                    {a.phase_a.gender} · {a.phase_a.age_bucket?.replace("_", "–")}
                  </Field>
                )}
                {a.phase_a.primary_goal && (
                  <Field label="Tujuan Utama">{prettyGoal(a.phase_a.primary_goal)}</Field>
                )}
              </div>

              {a.flags.length > 0 && (
                <div className="mt-4 border-t border-slate-100 pt-4">
                  <p className="font-dm-sans text-xs uppercase tracking-wider text-amber-700 mb-2">
                    Flags
                  </p>
                  <div className="flex flex-wrap gap-1.5">
                    {a.flags.map((f) => (
                      <span
                        key={f}
                        className="inline-flex items-center gap-1 bg-amber-50 text-amber-700 px-2 py-0.5 rounded-full font-dm-mono text-[11px]"
                      >
                        <AlertTriangle className="h-3 w-3" />
                        {f}
                      </span>
                    ))}
                  </div>
                </div>
              )}
            </div>

            {/* Chronobiology Window */}
            {a.chronobiology_window && (
              <div className="card p-6 bg-white">
                <div className="flex items-center justify-between">
                  <h2 className="sf-headline text-xl">Chronobiology Window</h2>
                  <Clock className="h-5 w-5 text-sf-warmGold" />
                </div>
                <p className="sf-body text-sm text-slate-500 mt-1">
                  Rekomendasi waktu sesi berdasarkan kondisi medis dan pola tidur klien.
                </p>

                <div className="mt-4 grid grid-cols-2 md:grid-cols-3 gap-3">
                  <WindowCell label="Ideal" tone="gold">
                    {a.chronobiology_window.ideal_start} – {a.chronobiology_window.ideal_end}
                  </WindowCell>
                  {a.chronobiology_window.alt_start && (
                    <WindowCell label="Alternatif" tone="teal">
                      {a.chronobiology_window.alt_start} – {a.chronobiology_window.alt_end}
                    </WindowCell>
                  )}
                  {a.chronobiology_window.avoid && (
                    <WindowCell label="Hindari" tone="rose">
                      {a.chronobiology_window.avoid}
                    </WindowCell>
                  )}
                  {a.chronobiology_window.hard_cap && (
                    <WindowCell label="Hard Cap" tone="navy">
                      {a.chronobiology_window.hard_cap}
                    </WindowCell>
                  )}
                </div>

                {a.chronobiology_window.override_reason && (
                  <p className="mt-4 text-xs font-dm-sans text-slate-600 italic border-l-2 border-sf-warmGold pl-3">
                    {a.chronobiology_window.override_reason}
                  </p>
                )}
              </div>
            )}

            {/* Program Map Recommendation */}
            {a.program_map && (
              <div className="card p-6 bg-white">
                <div className="flex items-center justify-between">
                  <h2 className="sf-headline text-xl">Program Map</h2>
                  <Activity className="h-5 w-5 text-sf-deepTeal" />
                </div>
                <p className="sf-body text-sm text-slate-500 mt-1 mb-4">
                  Rekomendasi Sequence Formula dan Load Weight berdasarkan profil klien.
                </p>

                <div className="space-y-6">
                  {/* Sequence Formula */}
                  <div>
                    <h3 className="text-[11px] uppercase tracking-wider text-slate-400 font-dm-sans mb-2 font-bold">Sequence Formula</h3>
                    <div className="grid grid-cols-3 gap-3">
                      <WindowCell label="FC (Flexibility & Core)" tone="navy">
                        {a.program_map.formula.fc_mins ? `${a.program_map.formula.fc_mins} Menit` : "—"}
                      </WindowCell>
                      <WindowCell label="CC (Cardio Conditioning)" tone="teal">
                        {a.program_map.formula.cc_mins ? `${a.program_map.formula.cc_mins} Menit` : "—"}
                      </WindowCell>
                      <WindowCell label="MC (Metabolic Conditioning)" tone="gold">
                        {a.program_map.formula.mc_mins ? `${a.program_map.formula.mc_mins} Menit` : "—"}
                      </WindowCell>
                    </div>
                    {a.program_map.formula.notes && (
                      <p className="mt-2 text-xs font-dm-sans text-slate-600 italic">
                        Catatan: {a.program_map.formula.notes}
                      </p>
                    )}
                  </div>

                  {/* Load Weight */}
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {/* Cardio Load */}
                    {a.program_map.cardio_load && (
                      <div className="bg-slate-50 p-4 rounded-xl border border-slate-100 space-y-2.5">
                        <h4 className="text-xs font-bold text-slate-700 font-dm-sans uppercase tracking-wider">Cardio Load</h4>
                        <div className="grid grid-cols-2 gap-2">
                          <WindowCell label="Upper Body" tone="navy">
                            {a.program_map.cardio_load.upper_body_kg != null ? `${a.program_map.cardio_load.upper_body_kg} Kg` : "—"}
                          </WindowCell>
                          <WindowCell label="Lower Body" tone="navy">
                            {a.program_map.cardio_load.lower_body_kg != null ? `${a.program_map.cardio_load.lower_body_kg} Kg` : "—"}
                          </WindowCell>
                        </div>
                      </div>
                    )}

                    {/* Metabolic Load */}
                    {a.program_map.metabolic_load && (
                      <div className="bg-slate-50 p-4 rounded-xl border border-slate-100 space-y-2.5">
                        <h4 className="text-xs font-bold text-slate-700 font-dm-sans uppercase tracking-wider">Metabolic Load</h4>
                        <div className="grid grid-cols-2 gap-2">
                          <WindowCell label="Upper Body" tone="gold">
                            {a.program_map.metabolic_load.upper_body_kg != null ? `${a.program_map.metabolic_load.upper_body_kg} Kg` : "—"}
                          </WindowCell>
                          <WindowCell label="Lower Body" tone="gold">
                            {a.program_map.metabolic_load.lower_body_kg != null ? `${a.program_map.metabolic_load.lower_body_kg} Kg` : "—"}
                          </WindowCell>
                        </div>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            )}

            {/* Phase A — Detail Jawaban */}
            <PhaseAQACard a={a} />

            {/* Phase B — 10 pertanyaan tidur */}
            <PhaseBQACard payload={a.phase_b} />

            {/* Phase C — 7 pertanyaan nutrisi */}
            <PhaseCQACard payload={a.phase_c} />

            {/* Training Card Preview */}
            <TrainingCardPreviewCard userId={userId} />

            <p className="text-xs font-dm-sans text-slate-400 italic">
              Asesmen disubmit:{" "}
              {new Date(a.created_at).toLocaleString("id-ID", {
                dateStyle: "long",
                timeStyle: "short",
              })}
            </p>
          </div>
        </div>
      )}
    </div>
  );
}

// ─── Subcomponents ─────────────────────────────────────────────────

function EmptyState({ error }: { error: unknown }) {
  const isNotFound = error instanceof Error && error.message.toLowerCase().includes("no v2");
  return (
    <div className="card p-10 text-center bg-white">
      <Activity className="h-10 w-10 text-slate-300 mx-auto" />
      <h3 className="sf-headline text-lg mt-3">Belum ada Asesmen v2</h3>
      <p className="sf-body text-sm text-slate-500 mt-1">
        {isNotFound
          ? "Klien ini belum melakukan asesmen Phase A/B/C. Tunggu sampai mereka submit dari mobile app."
          : (error instanceof Error ? error.message : "Gagal memuat data.")}
      </p>
    </div>
  );
}

function SystemScoreGauge({ value }: { value: number }) {
  const data = [{ name: "score", value, fill: "#B8922E" }];
  const tier =
    value >= 80 ? "OPTIMAL" : value >= 60 ? "STABLE" : value >= 40 ? "COMPROMISED" : "CRITICAL";
  return (
    <div className="relative h-44 w-44">
      <ResponsiveContainer width="100%" height="100%">
        <RadialBarChart
          innerRadius="75%"
          outerRadius="100%"
          startAngle={90}
          endAngle={-270}
          data={data}
        >
          <RadialBar dataKey="value" cornerRadius={20} fill="#B8922E" background={{ fill: "rgba(255,255,255,0.08)" }} />
        </RadialBarChart>
      </ResponsiveContainer>
      <div className="absolute inset-0 flex flex-col items-center justify-center">
        <span className="font-dm-mono text-4xl text-sf-warmGold">
          {value > 0 ? value.toFixed(0) : "—"}
        </span>
        <span className="font-dm-sans text-[10px] uppercase tracking-widest text-white/60 mt-1">
          {tier}
        </span>
      </div>
    </div>
  );
}

function ScoreRow({
  label, value, color,
}: { label: string; value: number | null | undefined; color: string }) {
  return (
    <div className="flex items-center justify-between text-sm">
      <span className="font-dm-sans text-white/80">{label}</span>
      <span className={cn("font-dm-mono", value == null ? "text-white/40" : "text-white")}>
        {value == null ? "—" : value.toFixed(1)}
      </span>
    </div>
  );
}

function Field({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div>
      <p className="text-[11px] uppercase tracking-wider text-slate-400 font-dm-sans">{label}</p>
      <div className="mt-1 text-sf-charcoal font-dm-sans">{children}</div>
    </div>
  );
}

function Badge({ tone, children }: { tone: "navy" | "gold" | "teal"; children: React.ReactNode }) {
  return (
    <span
      className={cn(
        "inline-flex px-2.5 py-0.5 text-xs font-dm-sans font-medium rounded-full",
        tone === "navy" && "bg-sf-iceBlue text-sf-midnightBlue",
        tone === "gold" && "bg-amber-50 text-sf-warmGoldDark",
        tone === "teal" && "bg-emerald-50 text-sf-deepTeal",
      )}
    >
      {children}
    </span>
  );
}

function WindowCell({
  label, tone, children,
}: {
  label: string;
  tone: "gold" | "teal" | "rose" | "navy";
  children: React.ReactNode;
}) {
  return (
    <div
      className={cn(
        "rounded-lg p-3",
        tone === "gold" && "bg-amber-50",
        tone === "teal" && "bg-emerald-50",
        tone === "rose" && "bg-rose-50",
        tone === "navy" && "bg-slate-100",
      )}
    >
      <p className="text-[10px] uppercase tracking-wider text-slate-500 font-dm-sans">{label}</p>
      <p className="font-dm-mono text-sm text-sf-charcoal mt-0.5">{children}</p>
    </div>
  );
}

// ════════════════════════════════════════════════════════════════════
//  Q&A Renderers — user-friendly view (no JSON)
// ════════════════════════════════════════════════════════════════════

interface OptionDef {
  value: string | number | boolean;
  label: string;
  hint?: string;
}

/** Single-select: tampilkan SEMUA opsi; yang dipilih di-highlight, lainnya abu-abu. */
function SingleSelect({
  options, selected,
}: {
  options: OptionDef[];
  selected: string | number | boolean | undefined;
}) {
  return (
    <ul className="space-y-1.5">
      {options.map((o) => {
        const isPicked = String(o.value) === String(selected);
        return (
          <li
            key={String(o.value)}
            className={cn(
              "flex items-start gap-3 rounded-lg px-3 py-2 transition-colors",
              isPicked
                ? "bg-sf-warmGold/10 border border-sf-warmGold/40"
                : "bg-slate-50 border border-transparent",
            )}
          >
            <span
              className={cn(
                "h-4 w-4 rounded-full border mt-0.5 shrink-0 flex items-center justify-center",
                isPicked
                  ? "border-sf-warmGoldDark bg-sf-warmGold text-white"
                  : "border-slate-300",
              )}
            >
              {isPicked && <Check className="h-3 w-3" />}
            </span>
            <span
              className={cn(
                "font-dm-sans text-sm",
                isPicked ? "text-sf-charcoal font-medium" : "text-slate-400",
              )}
            >
              {o.label}
              {o.hint && (
                <span
                  className={cn(
                    "block text-xs mt-0.5",
                    isPicked ? "text-slate-500" : "text-slate-400",
                  )}
                >
                  {o.hint}
                </span>
              )}
            </span>
          </li>
        );
      })}
    </ul>
  );
}

/** Multi-select: tampilkan SEMUA opsi; yang dipilih ✓ hijau, yang tidak abu-abu. */
function MultiSelect({
  options, selected,
}: {
  options: OptionDef[];
  selected: string[] | undefined;
}) {
  const set = new Set((selected ?? []).map((s) => s.toLowerCase()));
  return (
    <ul className="grid grid-cols-1 sm:grid-cols-2 gap-1.5">
      {options.map((o) => {
        const isPicked = set.has(String(o.value).toLowerCase());
        return (
          <li
            key={String(o.value)}
            className={cn(
              "flex items-center gap-2 rounded-lg px-3 py-2 border",
              isPicked
                ? "bg-emerald-50 border-emerald-200"
                : "bg-slate-50 border-transparent",
            )}
          >
            <span
              className={cn(
                "h-4 w-4 rounded border flex items-center justify-center shrink-0",
                isPicked
                  ? "bg-emerald-500 border-emerald-600 text-white"
                  : "border-slate-300 bg-white text-slate-300",
              )}
            >
              {isPicked ? <Check className="h-3 w-3" /> : <Minus className="h-3 w-3" />}
            </span>
            <span
              className={cn(
                "font-dm-sans text-sm",
                isPicked ? "text-sf-charcoal" : "text-slate-400",
              )}
            >
              {o.label}
            </span>
          </li>
        );
      })}
    </ul>
  );
}

/** Question wrapper. */
function QuestionBlock({
  no, label, description, children,
}: {
  no: string;
  label: string;
  description?: string;
  children: React.ReactNode;
}) {
  return (
    <div className="space-y-2">
      <div className="flex items-baseline gap-3">
        <span className="font-dm-mono text-xs text-sf-warmGoldDark whitespace-nowrap mt-0.5">
          {no}
        </span>
        <div>
          <p className="font-dm-sans text-sm font-medium text-sf-charcoal leading-snug">
            {label}
          </p>
          {description && (
            <p className="font-dm-sans text-xs text-slate-500 mt-0.5">{description}</p>
          )}
        </div>
      </div>
      <div className="pl-7">{children}</div>
    </div>
  );
}

// ─── Phase A QA ─────────────────────────────────────────────────────

function PhaseAQACard({ a }: { a: AssessmentV2 }) {
  const { data: clsResp } = useConditionClassifications(false);
  const { data: condResp } = useSpecificConditions({});

  const classifications =
    (clsResp?.data ?? []) as { slug: string; label: string }[];
  const conditions =
    (condResp?.data ?? []) as { slug: string; label: string; classification_slug?: string }[];

  const clsLabel = classifications.find(
    (c) => c.slug === a.phase_a.classification_slug,
  )?.label;
  const condLabel = conditions.find(
    (c) => c.slug === a.phase_a.specific_condition_slug,
  )?.label;

  return (
    <div className="card p-6 bg-white">
      <div className="flex items-center gap-2 mb-4">
        <ClipboardList className="h-4 w-4 text-sf-warmGold" />
        <h3 className="sf-headline text-lg">Phase A — Penilaian Kondisi</h3>
      </div>

      <div className="space-y-5">
        {/* A1 */}
        <QuestionBlock
          no="A1"
          label="Bagaimana kondisi gerak Anda saat ini?"
          description="Pilih yang paling mendekati keadaan sekarang."
        >
          <SingleSelect
            options={[
              {
                value: "level_0_1",
                label: "Saya hanya bisa berbaring atau duduk. Berdiri sendiri sangat sulit.",
                hint: "Level 0–1 — masuk waitlist program.",
              },
              {
                value: "level_2_3",
                label: "Saya bisa berdiri, tapi berjalan masih terbatas atau butuh bantuan.",
                hint: "Level 2–3 — masuk waitlist program.",
              },
              {
                value: "level_4_5_perf",
                label: "Saya bisa berjalan, tapi gerakan fisik masih terbatas dan stamina rendah.",
                hint: "Level 4–5 / Performance — lanjut ke pertanyaan berikutnya.",
              },
            ]}
            selected={a.phase_a.physical_status_level}
          />
        </QuestionBlock>

        {/* A2 */}
        <QuestionBlock
          no="A2"
          label="Apakah Anda memiliki kondisi medis yang sedang ditangani?"
          description="Membantu mencocokkan klien dengan program yang tepat."
        >
          <SingleSelect
            options={[
              { value: "true", label: "Ya — ada gangguan kondisi kesehatan" },
              { value: "false", label: "Tidak ada kondisi medis aktif" },
            ]}
            selected={String(a.phase_a.has_medical_condition)}
          />

          {/* Branching info */}
          {a.phase_a.has_medical_condition ? (
            <div className="mt-3 grid grid-cols-1 sm:grid-cols-2 gap-3">
              <SubField label="Klasifikasi kondisi">
                {clsLabel ?? a.phase_a.classification_slug ?? "—"}
              </SubField>
              <SubField label="Kondisi spesifik">
                {condLabel ?? a.phase_a.specific_condition_slug ?? "—"}
              </SubField>
              {a.phase_a.serious_condition_note && (
                <SubField label="Catatan kondisi" full>
                  {a.phase_a.serious_condition_note}
                </SubField>
              )}
            </div>
          ) : (
            <div className="mt-3 grid grid-cols-1 sm:grid-cols-2 gap-3">
              <SubField label="Gender">
                {a.phase_a.gender === "women"
                  ? "Wanita"
                  : a.phase_a.gender === "men"
                  ? "Pria"
                  : "—"}
              </SubField>
              <SubField label="Kelompok usia">
                {a.phase_a.age_bucket === "35_45"
                  ? "35–45 tahun"
                  : a.phase_a.age_bucket === "46_60"
                  ? "46–60 tahun"
                  : "—"}
              </SubField>
            </div>
          )}
        </QuestionBlock>

        {/* A3 — primary goal hanya kalau ada kondisi medis */}
        {a.phase_a.has_medical_condition && (
          <QuestionBlock
            no="A3"
            label="Apa yang paling ingin Anda capai?"
            description="Hanya untuk klien dengan kondisi medis aktif."
          >
            <SingleSelect
              options={[
                { value: "control_medical", label: "Mengontrol kondisi medis saya" },
                { value: "hormonal_feminine", label: "Menyeimbangkan hormon dan feminitas saya" },
                { value: "stamina_masculine", label: "Meningkatkan stamina dan performa fisik pria" },
              ]}
              selected={a.phase_a.primary_goal}
            />
          </QuestionBlock>
        )}

        {/* Movement test (preventive path) */}
        {a.phase_a.movement_test && (
          <QuestionBlock
            no="A1.5"
            label="Basic Movement Test"
            description="Self-report 3 gerakan dasar (0=tidak bisa, 1=dengan kompensasi, 2=bisa penuh)."
          >
            <div className="grid grid-cols-3 gap-2">
              <MovementCell label="Bodyweight Squat" value={a.phase_a.movement_test.squat} />
              <MovementCell label="Hip Hinge" value={a.phase_a.movement_test.hip_hinge} />
              <MovementCell label="Overhead Reach" value={a.phase_a.movement_test.overhead} />
            </div>
            <p className="mt-2 font-dm-sans text-xs text-slate-500">
              Total skor:{" "}
              <span className="font-dm-mono">
                {a.phase_a.movement_test.squat +
                  a.phase_a.movement_test.hip_hinge +
                  a.phase_a.movement_test.overhead}
              </span>{" "}
              / 6 — &ge; 4 = lanjut ke Phase B; &le; 3 = Book Konsultasi Online Gratis.
            </p>
          </QuestionBlock>
        )}
      </div>
    </div>
  );
}

function SubField({
  label, children, full,
}: {
  label: string;
  children: React.ReactNode;
  full?: boolean;
}) {
  return (
    <div className={cn("rounded-lg bg-sf-iceBlue/40 px-3 py-2", full && "sm:col-span-2")}>
      <p className="text-[10px] uppercase tracking-wider text-slate-500 font-dm-sans">
        {label}
      </p>
      <p className="font-dm-sans text-sm text-sf-charcoal mt-0.5">{children}</p>
    </div>
  );
}

function MovementCell({ label, value }: { label: string; value: number }) {
  const text =
    value === 2 ? "Bisa penuh" : value === 1 ? "Dengan kompensasi" : "Tidak bisa / nyeri";
  const color =
    value === 2 ? "bg-emerald-50 text-emerald-700"
      : value === 1 ? "bg-amber-50 text-amber-700"
      : "bg-rose-50 text-rose-700";
  return (
    <div className={cn("rounded-lg p-3", color)}>
      <p className="text-[10px] uppercase tracking-wider font-dm-sans opacity-70">{label}</p>
      <p className="font-dm-sans text-sm font-medium mt-0.5">{text}</p>
      <p className="font-dm-mono text-[10px] mt-0.5 opacity-60">skor {value}/2</p>
    </div>
  );
}

// ─── Phase B QA ─────────────────────────────────────────────────────

function PhaseBQACard({ payload }: { payload: AssessmentV2["phase_b"] }) {
  return (
    <div className="card p-6 bg-white">
      <div className="flex items-center gap-2 mb-4">
        <Moon className="h-4 w-4 text-sf-systemBlue" />
        <h3 className="sf-headline text-lg">Phase B — Pola Tidur &amp; Aktivitas</h3>
      </div>
      {!payload ? (
        <p className="font-dm-sans text-sm text-slate-400 italic">
          Phase B belum diisi.
        </p>
      ) : (
        <div className="space-y-5">
          <QuestionBlock no="B1" label="Rata-rata berapa jam Anda tidur per malam?">
            <SliderValue value={`${payload.duration_hours} jam`} />
          </QuestionBlock>

          <QuestionBlock
            no="B2"
            label="Seberapa konsisten jam tidur dan bangun Anda?"
          >
            <SingleSelect
              options={[
                { value: 1, label: "Sangat tidak teratur — berbeda lebih dari 2 jam setiap hari" },
                { value: 2, label: "Kadang berubah — berbeda sekitar 1–2 jam" },
                { value: 3, label: "Teratur setiap hari — hampir selalu di jam yang sama" },
              ]}
              selected={payload.consistency}
            />
          </QuestionBlock>

          <QuestionBlock
            no="B3"
            label="Berapa lama biasanya Anda butuh untuk tertidur setelah berbaring?"
            description="Indikator kortisol &amp; gula darah malam."
          >
            <SingleSelect
              options={[
                { value: 1, label: "Kurang dari 15 menit — langsung mengantuk (optimal)" },
                { value: 2, label: "15–30 menit — cukup normal" },
                { value: 3, label: "30–45 menit — agak sulit tidur" },
                { value: 4, label: "Lebih dari 45 menit — sulit sekali tidur" },
              ]}
              selected={payload.sleep_latency}
            />
          </QuestionBlock>

          <QuestionBlock no="B4" label="Bagaimana perasaan Anda saat bangun pagi?">
            <SingleSelect
              options={[
                { value: 1, label: "Lelah / pusing — tidak terasa sudah tidur" },
                { value: 2, label: "Biasa saja — butuh beberapa menit untuk segar" },
                { value: 3, label: "Segar &amp; langsung bertenaga" },
              ]}
              selected={payload.morning_readiness}
            />
          </QuestionBlock>

          <QuestionBlock
            no="B5"
            label="Seberapa sering Anda terbangun di tengah malam?"
            description="Indikator hipertensi atau fluktuasi gula darah."
          >
            <SingleSelect
              options={[
                { value: 1, label: "Tidak pernah — tidur nyenyak sampai pagi" },
                { value: 2, label: "1–2 kali — bisa tidur lagi dengan mudah" },
                { value: 3, label: "3+ kali — sering terbangun" },
                { value: 4, label: "Sering terbangun dan sulit tidur lagi" },
              ]}
              selected={payload.wake_frequency}
            />
          </QuestionBlock>

          <QuestionBlock no="B6" label="Apa yang biasanya Anda lakukan 1 jam sebelum tidur?">
            <SingleSelect
              options={[
                { value: 1, label: "Gadget aktif / kerja / makan berat / pikiran sibuk" },
                { value: 2, label: "Campuran — kadang santai, kadang masih aktif" },
                { value: 3, label: "Rutinitas relaksasi — baca, meditasi, stretching ringan" },
              ]}
              selected={payload.pre_sleep_habit}
            />
          </QuestionBlock>

          <QuestionBlock
            no="B7"
            label="Biasanya Anda tidur jam berapa malam?"
            description="Dasar perhitungan 5-Hour Recovery Window."
          >
            <SingleSelect
              options={[
                { value: 1, label: "Sebelum jam 21.00" },
                { value: 2, label: "Jam 21.00–22.00" },
                { value: 3, label: "Jam 22.00–23.00" },
                { value: 4, label: "Jam 23.00–00.00" },
                { value: 5, label: "Setelah jam 00.00" },
              ]}
              selected={payload.bedtime_bucket}
            />
          </QuestionBlock>

          <QuestionBlock no="B8" label="Biasanya Anda bangun jam berapa?">
            <SingleSelect
              options={[
                { value: 1, label: "Sebelum jam 05.00" },
                { value: 2, label: "Jam 05.00–06.00" },
                { value: 3, label: "Jam 06.00–07.00" },
                { value: 4, label: "Jam 07.00–08.00" },
                { value: 5, label: "Setelah jam 08.00" },
              ]}
              selected={payload.wake_time_bucket}
            />
          </QuestionBlock>

          <QuestionBlock
            no="B9"
            label="Mana yang paling menggambarkan rutinitas harian Anda?"
            description="Menentukan window waktu yang realistis bisa digunakan."
          >
            <SingleSelect
              options={[
                { value: "executive", label: "Pekerja eksekutif / kantoran" },
                { value: "creative", label: "Pekerja kreatif / freelancer" },
                { value: "traveller", label: "Frequent traveller" },
                { value: "homemaker", label: "Ibu rumah tangga" },
                { value: "shift_worker", label: "Pekerja shift (siang–malam atau malam–pagi)" },
                { value: "mixed", label: "Campuran / tidak menentu" },
              ]}
              selected={payload.activity_profile}
            />
          </QuestionBlock>

          <QuestionBlock
            no="B10"
            label="Biasanya Anda makan malam jam berapa?"
            description="Makan malam larut + sleep latency tinggi = sinyal gula darah spike."
          >
            <SingleSelect
              options={[
                { value: 1, label: "Sebelum jam 18.00" },
                { value: 2, label: "Jam 18.00–19.00" },
                { value: 3, label: "Jam 19.00–20.00" },
                { value: 4, label: "Setelah jam 20.00" },
                { value: 5, label: "Tidak menentu / sering skip" },
              ]}
              selected={payload.dinner_time}
            />
          </QuestionBlock>
        </div>
      )}
    </div>
  );
}

function SliderValue({ value }: { value: string }) {
  return (
    <span className="inline-flex items-center px-3 py-1.5 rounded-full bg-sf-warmGold/10 border border-sf-warmGold/40 font-dm-mono text-sm text-sf-warmGoldDark">
      {value}
    </span>
  );
}

// ─── Phase C QA ─────────────────────────────────────────────────────

function PhaseCQACard({ payload }: { payload: AssessmentV2["phase_c"] }) {
  return (
    <div className="card p-6 bg-white">
      <div className="flex items-center gap-2 mb-4">
        <Apple className="h-4 w-4 text-sf-deepTeal" />
        <h3 className="sf-headline text-lg">Phase C — Pola Makan &amp; Gizi</h3>
      </div>
      {!payload ? (
        <p className="font-dm-sans text-sm text-slate-400 italic">
          Phase C belum diisi.
        </p>
      ) : (
        <div className="space-y-5">
          <QuestionBlock no="C1" label="Bagaimana gambaran pola makan Anda sehari-hari?">
            <SingleSelect
              options={[
                { value: 1, label: "Makan besar 3 kali sehari, jarang snack" },
                { value: 2, label: "Makan 4–5 kali dalam porsi lebih kecil" },
                { value: 3, label: "Sering skip makan — tidak teratur" },
                { value: 4, label: "Intermittent fasting — ada jeda makan tertentu (mis. 16/8)" },
                { value: 5, label: "Tidak ada pola tetap" },
              ]}
              selected={payload.meal_pattern}
            />
          </QuestionBlock>

          <QuestionBlock no="C2" label="Apa yang paling sering ada di piring Anda?">
            <SingleSelect
              options={[
                { value: 1, label: "Nasi / karbohidrat sebagai porsi terbesar" },
                { value: 2, label: "Protein (ayam, ikan, telur, daging) sebagai fokus utama" },
                { value: 3, label: "Sayur dan buah mendominasi" },
                { value: 4, label: "Campuran seimbang antara karbo, protein, dan sayur" },
                { value: 5, label: "Makanan olahan / fast food cukup sering" },
              ]}
              selected={payload.food_dominance}
            />
          </QuestionBlock>

          <QuestionBlock
            no="C3"
            label="Berapa gelas air putih yang biasanya Anda minum per hari?"
            description="1 gelas = 250 ml."
          >
            <SingleSelect
              options={[
                { value: 1, label: "Kurang dari 4 gelas (< 1 liter) — sangat kurang" },
                { value: 2, label: "4–6 gelas (1–1.5 liter) — kurang" },
                { value: 3, label: "7–8 gelas (1.75–2 liter) — cukup" },
                { value: 4, label: "Lebih dari 8 gelas (> 2 liter) — baik" },
              ]}
              selected={payload.hydration}
            />
          </QuestionBlock>

          <QuestionBlock
            no="C4"
            label="Pilih semua yang sering ada dalam konsumsi harian Anda."
            description="Boleh pilih lebih dari satu — opsi yang Anda pilih ditandai hijau."
          >
            <MultiSelect
              options={[
                { value: "coffee", label: "Kopi (1+ cangkir per hari)" },
                { value: "sweet_drinks", label: "Teh manis atau minuman manis lainnya" },
                { value: "soda_energy", label: "Minuman bersoda / energi drink" },
                { value: "alcohol", label: "Alkohol" },
                { value: "fried", label: "Makanan digoreng / berminyak" },
                { value: "high_salt", label: "Makanan tinggi garam (keripik, acar, saus instan)" },
                { value: "organ_meat", label: "Jeroan (hati, ampela, dll)" },
                { value: "seafood", label: "Seafood (udang, cumi, kerang, dll)" },
                { value: "dairy", label: "Susu &amp; produk susu (keju, yogurt, es krim)" },
                { value: "fermented", label: "Makanan fermentasi (tape, kimchi, tempe, dll)" },
              ]}
              selected={payload.routine_foods}
            />
          </QuestionBlock>

          <QuestionBlock
            no="C5"
            label="Apakah Anda memiliki pantangan atau alergi makanan?"
            description="Filter untuk semua rekomendasi gizi yang dihasilkan sistem."
          >
            <MultiSelect
              options={[
                { value: "none", label: "Tidak ada" },
                { value: "specific_allergy", label: "Alergi spesifik" },
                { value: "religious", label: "Pantangan agama / keyakinan (halal, vegan, vegetarian, dll)" },
                { value: "lactose", label: "Intoleransi laktosa" },
                { value: "gluten", label: "Intoleransi / sensitivitas gluten" },
                { value: "other", label: "Pantangan lainnya" },
              ]}
              selected={payload.restrictions}
            />
            {payload.restriction_note && (
              <SubField label="Catatan klien">{payload.restriction_note}</SubField>
            )}
          </QuestionBlock>

          <QuestionBlock
            no="C6"
            label="Suplemen / obat yang sedang dikonsumsi"
            description="Memberi konteks tambahan untuk Consultant."
          >
            <MultiSelect
              options={[
                { value: "none", label: "Tidak ada" },
                { value: "multivitamin", label: "Multivitamin umum" },
                { value: "vitamin_d", label: "Vitamin D" },
                { value: "omega_3", label: "Omega-3 / Fish oil" },
                { value: "protein", label: "Suplemen protein (whey, plant-based)" },
                { value: "other", label: "Suplemen spesifik lainnya" },
                { value: "rx_metabolic", label: "Obat dokter yang mempengaruhi metabolisme" },
              ]}
              selected={payload.supplements}
            />
            {payload.supplement_note && (
              <SubField label="Catatan klien">{payload.supplement_note}</SubField>
            )}
          </QuestionBlock>

          <QuestionBlock
            no="C7"
            label="Apa yang paling ingin Anda perbaiki dari pola makan?"
          >
            <SingleSelect
              options={[
                { value: "blood_sugar", label: "Mengontrol gula darah dan metabolisme" },
                { value: "anti_inflammation", label: "Mengurangi peradangan, bloating, dan ketidaknyamanan pencernaan" },
                { value: "energy_vitality", label: "Meningkatkan energi dan vitalitas sepanjang hari" },
                { value: "hormonal_balance", label: "Mendukung keseimbangan hormonal" },
                { value: "weight", label: "Menjaga berat badan yang sehat" },
                { value: "muscle_recovery", label: "Mendukung performa, pemulihan otot, dan kebugaran" },
                { value: "organ_health", label: "Mendukung kesehatan organ spesifik (ginjal, jantung, dll)" },
              ]}
              selected={payload.nutrition_goal}
            />
          </QuestionBlock>
        </div>
      )}
    </div>
  );
}

// ─── Pretty helpers ────────────────────────────────────────────────

function prettyLevel(slug: string): string {
  switch (slug) {
    case "level_0_1": return "Level 0–1 (terbatas)";
    case "level_2_3": return "Level 2–3 (terbatas)";
    case "level_4_5_perf": return "Level 4–5 / Performance";
    default: return slug;
  }
}

function prettyProgram(p: ProgramType): string {
  switch (p) {
    case "condition_specific": return "Condition-Specific";
    case "preventive": return "Preventive Optimization";
    case "performance_women_35_45": return "Performance Women 35–45";
    case "performance_women_46_60": return "Performance Women 46–60";
    case "performance_men_35_45": return "Performance Men 35–45";
    case "performance_men_46_60": return "Performance Men 46–60";
    case "waitlist": return "Waitlist";
    default: return p;
  }
}

function prettyGoal(g: string): string {
  switch (g) {
    case "control_medical": return "Mengontrol kondisi medis";
    case "hormonal_feminine": return "Optimasi hormonal & feminitas";
    case "stamina_masculine": return "Stamina & performa pria";
    default: return g;
  }
}

function TrainingCardPreviewCard({ userId }: { userId: string }) {
  const { data: tcResp, isLoading, error } = useTrainingCardForUser(userId);
  
  if (isLoading) {
    return (
      <div className="card p-6 bg-white animate-pulse">
        <div className="h-6 w-1/3 bg-slate-200 rounded mb-4" />
        <div className="h-4 w-full bg-slate-100 rounded mb-2" />
        <div className="h-4 w-full bg-slate-100 rounded" />
      </div>
    );
  }

  const tc = tcResp?.data;
  if (!tc || error) {
    return (
      <div className="card p-6 bg-white border border-red-100">
        <h2 className="sf-headline text-xl text-slate-800">Training Card Preview</h2>
        <p className="sf-body text-sm text-red-500 mt-2">
          {error instanceof Error ? error.message : "Tidak dapat memuat Training Card"}
        </p>
      </div>
    );
  }

  return (
    <div className="card p-6 bg-white">
      <div className="flex items-center justify-between">
        <h2 className="sf-headline text-xl">Training Card Preview</h2>
        <Activity className="h-5 w-5 text-sf-systemBlue" />
      </div>
      <p className="sf-body text-sm text-slate-500 mt-1 mb-4">
        Simulasi hasil Training Card berdasarkan level klien saat ini.
      </p>

      {/* Program Categories preview */}
      <div className="space-y-6">
        <div>
          <h3 className="font-dm-sans font-bold text-slate-700 mb-3">Full Program</h3>
          {tc.full_program?.map((cat, i) => (
            <div key={i} className="mb-4">
              <p className="font-bold text-sm">{cat.type} ({cat.duration})</p>
              <div className="space-y-2 mt-2 pl-4 border-l-2 border-slate-100">
                {cat.sets?.map((set, j) => (
                  <div key={j} className="text-xs">
                    <span className="font-semibold">{set.set_name}</span> · {set.duration_mins} Min · {set.bpm_range} BPM
                    <ul className="list-disc pl-5 text-slate-500 mt-1">
                      {set.movements?.map((m) => (
                        <li key={m.id}>{m.title}</li>
                      ))}
                    </ul>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>

        <div>
          <h3 className="font-dm-sans font-bold text-slate-700 mb-3">Daily Reset</h3>
          {tc.daily_reset?.map((cat, i) => (
            <div key={i} className="mb-4">
              <p className="font-bold text-sm">{cat.type} ({cat.duration})</p>
              <div className="space-y-2 mt-2 pl-4 border-l-2 border-slate-100">
                {cat.sets?.map((set, j) => (
                  <div key={j} className="text-xs">
                    <span className="font-semibold">{set.set_name}</span> · {set.duration_mins} Min · {set.bpm_range} BPM
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
