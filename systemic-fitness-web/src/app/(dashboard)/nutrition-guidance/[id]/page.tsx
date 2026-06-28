"use client";

import { useEffect, useMemo, useState } from "react";
import { useParams } from "next/navigation";
import Link from "next/link";
import { ArrowLeft, Save, Plus, X, AlertTriangle } from "lucide-react";

import {
  HEALTH_CONDITIONS,
  HEALTH_CONDITION_LABELS,
  useCustomerHealthProfile,
  useCustomerNutritionLogs,
  useCustomerNutritionPlan,
  useUpsertCustomerHealthProfile,
  type HealthCondition,
  type NutritionAgeGroup,
  type NutritionGender,
  type NutritionGoal,
  type FemaleCondition,
} from "@/hooks/useNutritionGuidance";
import { SearchableSelect } from "@/components/shared/SearchableSelect";
import { cn } from "@/lib/utils";

const GENDER_OPTS: { value: NutritionGender; label: string }[] = [
  { value: "male", label: "Laki-laki" },
  { value: "female", label: "Perempuan" },
];

const AGE_OPTS: { value: NutritionAgeGroup; label: string }[] = [
  { value: "under_18", label: "< 18 tahun" },
  { value: "18_40", label: "18 - 40 tahun" },
  { value: "41_60", label: "41 - 60 tahun" },
  { value: "over_60", label: "> 60 tahun" },
];

const GOAL_OPTS: { value: NutritionGoal; label: string }[] = [
  { value: "maintenance", label: "Maintenance" },
  { value: "fat_loss", label: "Fat Loss" },
  { value: "recovery", label: "Recovery" },
];

const FEMALE_OPTS: { value: FemaleCondition | ""; label: string }[] = [
  { value: "", label: "—" },
  { value: "normal", label: "Normal" },
  { value: "pregnant", label: "Hamil" },
  { value: "menopause", label: "Menopause" },
];

const STATUS_STYLES: Record<string, string> = {
  stable: "bg-emerald-50 text-emerald-700 border-emerald-200",
  warning: "bg-amber-50 text-amber-700 border-amber-200",
  risk: "bg-rose-50 text-rose-700 border-rose-200",
};

export default function NutritionGuidanceDetailPage() {
  const { id } = useParams<{ id: string }>();
  const userId = id;

  const profileQ = useCustomerHealthProfile(userId);
  const planQ = useCustomerNutritionPlan(userId);
  const logsQ = useCustomerNutritionLogs(userId, 30);
  const upsert = useUpsertCustomerHealthProfile();

  // ─── Form state ────────────────────────────────────────────────
  const [gender, setGender] = useState<NutritionGender>("male");
  const [ageGroup, setAgeGroup] = useState<NutritionAgeGroup>("18_40");
  const [femaleCond, setFemaleCond] = useState<FemaleCondition | "">("");
  const [goal, setGoal] = useState<NutritionGoal>("maintenance");
  const [weight, setWeight] = useState<string>("");
  const [conditions, setConditions] = useState<Set<HealthCondition>>(new Set());
  const [allergies, setAllergies] = useState<string[]>([]);
  const [allergyInput, setAllergyInput] = useState("");

  // Hydrate form when profile loads
  useEffect(() => {
    const p = profileQ.data?.data;
    if (!p) return;
    setGender(p.gender);
    setAgeGroup(p.age_group);
    setFemaleCond((p.female_condition as FemaleCondition) || "");
    setGoal(p.goal);
    setWeight(String(p.weight_kg ?? ""));
    setConditions(new Set(p.conditions || []));
    setAllergies(p.allergies || []);
  }, [profileQ.data?.data]);

  const profileNotFound = useMemo(() => {
    const msg = (profileQ.error as Error | undefined)?.message ?? "";
    return /not\s*set|not found/i.test(msg);
  }, [profileQ.error]);

  function toggleCondition(c: HealthCondition) {
    setConditions((prev) => {
      const next = new Set(prev);
      if (next.has(c)) next.delete(c);
      else next.add(c);
      return next;
    });
  }

  function addAllergy() {
    const v = allergyInput.trim();
    if (!v) return;
    setAllergies((a) => Array.from(new Set([...a, v])));
    setAllergyInput("");
  }

  function handleSave(e: React.FormEvent) {
    e.preventDefault();
    const w = parseFloat(weight);
    if (!Number.isFinite(w) || w <= 0) {
      alert("Berat badan harus angka positif");
      return;
    }
    upsert.mutate({
      userId,
      payload: {
        gender,
        age_group: ageGroup,
        female_condition: gender === "female" ? femaleCond : "",
        goal,
        weight_kg: w,
        allergies,
        conditions: Array.from(conditions),
      },
    });
  }

  const plan = planQ.data?.data;
  const logs = (logsQ.data?.data ?? []) as any[];

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3">
        <Link
          href="/nutrition-guidance"
          className="p-2 rounded-lg hover:bg-slate-100 text-slate-500"
        >
          <ArrowLeft className="h-4 w-4" />
        </Link>
        <div>
          <h1 className="text-2xl font-bold text-slate-900">
            Profil Nutrisi Customer
          </h1>
          <p className="text-sm text-slate-500 mt-1">
            User ID: <code className="text-xs">{userId}</code>
          </p>
        </div>
      </div>

      {profileQ.isLoading ? (
        <div className="card p-6">
          <div className="skeleton h-6 w-40 mb-4" />
          <div className="space-y-2">
            <div className="skeleton h-10 w-full" />
            <div className="skeleton h-10 w-full" />
          </div>
        </div>
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
          {/* ─── Form ─────────────────────────────────────────── */}
          <form onSubmit={handleSave} className="card p-6 space-y-4">
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-semibold">Health Profile</h2>
              {profileNotFound && (
                <span className="text-xs text-amber-600">Belum dibuat</span>
              )}
            </div>

            <div className="grid grid-cols-2 gap-3">
              <Field label="Jenis Kelamin">
                <SearchableSelect
                  options={GENDER_OPTS.map((o) => ({
                    value: o.value,
                    label: o.label,
                  }))}
                  value={gender}
                  onChange={(v) => setGender(v as NutritionGender)}
                  placeholder="Pilih jenis kelamin"
                />
              </Field>
              <Field label="Kelompok Usia">
                <SearchableSelect
                  options={AGE_OPTS.map((o) => ({
                    value: o.value,
                    label: o.label,
                  }))}
                  value={ageGroup}
                  onChange={(v) => setAgeGroup(v as NutritionAgeGroup)}
                  placeholder="Pilih kelompok usia"
                />
              </Field>
            </div>

            {gender === "female" && (
              <Field label="Kondisi (perempuan)">
                <SearchableSelect
                  options={FEMALE_OPTS.map((o) => ({
                    value: o.value,
                    label: o.label,
                  }))}
                  value={femaleCond}
                  onChange={(v) => setFemaleCond(v as FemaleCondition | "")}
                  placeholder="Pilih kondisi"
                />
              </Field>
            )}

            <div className="grid grid-cols-2 gap-3">
              <Field label="Tujuan">
                <SearchableSelect
                  options={GOAL_OPTS.map((o) => ({
                    value: o.value,
                    label: o.label,
                  }))}
                  value={goal}
                  onChange={(v) => setGoal(v as NutritionGoal)}
                  placeholder="Pilih tujuan"
                />
              </Field>
              <Field label="Berat (kg)">
                <input
                  type="number"
                  step="0.1"
                  className="input"
                  value={weight}
                  onChange={(e) => setWeight(e.target.value)}
                />
              </Field>
            </div>

            <Field label="Kondisi Kesehatan">
              <div className="flex flex-wrap gap-2">
                {HEALTH_CONDITIONS.map((c) => {
                  const sel = conditions.has(c);
                  return (
                    <button
                      type="button"
                      key={c}
                      onClick={() => toggleCondition(c)}
                      className={cn(
                        "px-3 py-1.5 rounded-full text-xs font-medium border transition-colors",
                        sel
                          ? "bg-emerald-50 text-emerald-700 border-emerald-300"
                          : "bg-white text-slate-500 border-slate-200 hover:bg-slate-50",
                      )}
                    >
                      {HEALTH_CONDITION_LABELS[c]}
                    </button>
                  );
                })}
              </div>
            </Field>

            <Field label="Alergi Makanan">
              <div className="flex gap-2">
                <input
                  className="input flex-1"
                  placeholder="mis. peanut"
                  value={allergyInput}
                  onChange={(e) => setAllergyInput(e.target.value)}
                  onKeyDown={(e) => {
                    if (e.key === "Enter") {
                      e.preventDefault();
                      addAllergy();
                    }
                  }}
                />
                <button
                  type="button"
                  onClick={addAllergy}
                  className="px-3 py-2 rounded-lg bg-slate-100 hover:bg-slate-200 text-slate-700"
                >
                  <Plus className="h-4 w-4" />
                </button>
              </div>
              {allergies.length > 0 && (
                <div className="flex flex-wrap gap-2 mt-2">
                  {allergies.map((a) => (
                    <span
                      key={a}
                      className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-rose-50 text-rose-700 text-xs"
                    >
                      {a}
                      <button
                        type="button"
                        onClick={() =>
                          setAllergies((arr) => arr.filter((x) => x !== a))
                        }
                      >
                        <X className="h-3 w-3" />
                      </button>
                    </span>
                  ))}
                </div>
              )}
            </Field>

            <button
              type="submit"
              disabled={upsert.isPending}
              className="w-full px-4 py-2.5 rounded-lg bg-emerald-600 text-white font-medium hover:bg-emerald-700 disabled:opacity-50 flex items-center justify-center gap-2"
            >
              <Save className="h-4 w-4" />
              {upsert.isPending ? "Menyimpan..." : "Simpan Profil"}
            </button>
          </form>

          {/* ─── Plan + Logs ─────────────────────────────────── */}
          <div className="space-y-5">
            {/* Plan */}
            <div className="card p-6 space-y-3">
              <h2 className="text-lg font-semibold">Rencana Nutrisi</h2>
              {planQ.isLoading ? (
                <div className="skeleton h-20 w-full" />
              ) : !plan ? (
                <p className="text-sm text-slate-400">
                  Profil belum dibuat — simpan profil untuk melihat rencana.
                </p>
              ) : (
                <>
                  <div
                    className={cn(
                      "border rounded-xl px-4 py-3 flex items-center gap-4",
                      STATUS_STYLES[plan.status],
                    )}
                  >
                    <div className="text-3xl font-bold">{plan.daily_score}</div>
                    <div>
                      <p className="text-xs uppercase tracking-wide opacity-75">
                        Skor Hari Ini
                      </p>
                      <p className="font-semibold uppercase">{plan.status}</p>
                    </div>
                  </div>

                  <FoodList
                    title="Boleh"
                    items={plan.diet_plan.allowed_foods}
                    color="emerald"
                  />
                  <FoodList
                    title="Batasi"
                    items={plan.diet_plan.limited_foods}
                    color="amber"
                  />
                  <FoodList
                    title="Hindari"
                    items={plan.diet_plan.avoid_foods}
                    color="rose"
                  />

                  {Object.keys(plan.nutrition_rules).length > 0 && (
                    <details className="text-sm">
                      <summary className="cursor-pointer text-slate-500">
                        Aturan Nutrisi
                      </summary>
                      <ul className="mt-2 space-y-0.5 text-xs text-slate-600">
                        {Object.entries(plan.nutrition_rules).map(([k, v]) => (
                          <li key={k}>
                            <code>{k}</code>: {String(v)}
                          </li>
                        ))}
                      </ul>
                    </details>
                  )}

                  {plan.insight.length > 0 && (
                    <div className="bg-slate-50 rounded-lg p-3 text-xs text-slate-600">
                      <p className="font-medium text-slate-700 mb-1">Insight</p>
                      <ul className="space-y-0.5">
                        {plan.insight.map((i, idx) => (
                          <li key={idx}>• {i}</li>
                        ))}
                      </ul>
                    </div>
                  )}
                </>
              )}
            </div>

            {/* Logs */}
            <div className="card p-6 space-y-3">
              <h2 className="text-lg font-semibold">Log Harian (30 hari)</h2>
              {logsQ.isLoading ? (
                <div className="skeleton h-20 w-full" />
              ) : logs.length === 0 ? (
                <p className="text-sm text-slate-400">Belum ada log harian.</p>
              ) : (
                <div className="divide-y divide-slate-100">
                  {logs.map((l) => (
                    <div
                      key={l.log_date}
                      className="py-2 flex items-center justify-between"
                    >
                      <span className="text-sm text-slate-600">
                        {l.log_date}
                      </span>
                      <div className="flex items-center gap-3">
                        <span className="text-sm font-semibold">
                          {l.daily_score}
                        </span>
                        <span
                          className={cn(
                            "px-2 py-0.5 rounded-full text-xs font-medium border",
                            STATUS_STYLES[l.status],
                          )}
                        >
                          {l.status}
                        </span>
                        {l.alert?.alert && (
                          <AlertTriangle className="h-4 w-4 text-rose-500" />
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      )}
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
      <label className="block text-xs font-medium text-slate-600 mb-1">
        {label}
      </label>
      {children}
    </div>
  );
}

function FoodList({
  title,
  items,
  color,
}: {
  title: string;
  items: string[];
  color: "emerald" | "amber" | "rose";
}) {
  if (!items?.length) return null;
  const colorMap = {
    emerald: "bg-emerald-50 text-emerald-700",
    amber: "bg-amber-50 text-amber-700",
    rose: "bg-rose-50 text-rose-700",
  };
  return (
    <div>
      <p className="text-xs font-medium text-slate-600 mb-1">{title}</p>
      <div className="flex flex-wrap gap-1.5">
        {items.map((f) => (
          <span
            key={f}
            className={cn("px-2 py-0.5 rounded text-xs", colorMap[color])}
          >
            {f}
          </span>
        ))}
      </div>
    </div>
  );
}
