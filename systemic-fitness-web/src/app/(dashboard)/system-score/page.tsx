"use client";

import { useEffect, useState } from "react";
import {
  useSystemScoreWeights,
  useUpdateSystemScoreWeights,
} from "@/hooks/useSystemScoreWeights";
import { Loader2, Save, RotateCcw, Activity, Apple, Moon } from "lucide-react";
import { cn } from "@/lib/utils";

// SF Phase 3 — System Score Weights editor (Owner only).
// Reference: SF_Master_Platform_Spec.docx §04.
//
// Branding: halaman ini pakai palette SF baru (warmWhite + DM fonts) sebagai
// preview Fase 8 sweep. Halaman lain belum disentuh.

const DEFAULT_WEIGHTS = { movement_pct: 35, nutrition_pct: 35, rest_pct: 30 };

export default function SystemScorePage() {
  const { data, isLoading } = useSystemScoreWeights();
  const update = useUpdateSystemScoreWeights();
  const current = data?.data;

  const [name, setName] = useState("SF Default");
  const [movement, setMovement] = useState(35);
  const [nutrition, setNutrition] = useState(35);
  const [rest, setRest] = useState(30);
  const [notes, setNotes] = useState("");

  useEffect(() => {
    if (!current) return;
    setName(current.name);
    setMovement(current.movement_pct);
    setNutrition(current.nutrition_pct);
    setRest(current.rest_pct);
    setNotes(current.notes ?? "");
  }, [current]);

  const sum = movement + nutrition + rest;
  const isValid = sum === 100 && name.trim().length >= 2;
  const isDirty =
    !!current &&
    (current.name !== name ||
      current.movement_pct !== movement ||
      current.nutrition_pct !== nutrition ||
      current.rest_pct !== rest ||
      (current.notes ?? "") !== notes);

  async function handleSave() {
    if (!isValid) return;
    await update.mutateAsync({
      name: name.trim(),
      movement_pct: movement,
      nutrition_pct: nutrition,
      rest_pct: rest,
      notes: notes.trim() || undefined,
    });
  }

  function handleReset() {
    setName("SF Default");
    setMovement(DEFAULT_WEIGHTS.movement_pct);
    setNutrition(DEFAULT_WEIGHTS.nutrition_pct);
    setRest(DEFAULT_WEIGHTS.rest_pct);
    setNotes("");
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="sf-headline text-3xl">Bobot System Score</h1>
        <p className="sf-body text-sm text-slate-500 mt-1">
          Atur proporsi tiga dimensi yang menyusun System Score: Movement (Olahraga),
          Nutrition (Nutrisi), dan Rest (Istirahat). Total ketiganya harus 100%.
          Default spec: <span className="font-dm-mono">35 / 35 / 30</span>.
        </p>
      </div>

      {isLoading ? (
        <div className="flex justify-center py-16">
          <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
        </div>
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
          {/* Editor */}
          <div className="lg:col-span-2 card p-6 bg-sf-warmWhite border-slate-200">
            <h2 className="sf-headline text-xl mb-4">Konfigurasi</h2>

            <div className="space-y-5">
              <div>
                <label className="block text-xs font-dm-sans font-medium text-sf-charcoal mb-1">
                  Nama profil bobot
                </label>
                <input
                  className="input w-full font-dm-sans"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="SF Default"
                />
              </div>

              <WeightSlider
                icon={Activity}
                label="Movement (Olahraga)"
                value={movement}
                onChange={setMovement}
                color="bg-sf-deepTeal"
              />
              <WeightSlider
                icon={Apple}
                label="Nutrition (Nutrisi)"
                value={nutrition}
                onChange={setNutrition}
                color="bg-sf-systemBlue"
              />
              <WeightSlider
                icon={Moon}
                label="Rest (Istirahat)"
                value={rest}
                onChange={setRest}
                color="bg-sf-warmGold"
              />

              <div>
                <label className="block text-xs font-dm-sans font-medium text-sf-charcoal mb-1">
                  Catatan (opsional)
                </label>
                <textarea
                  className="input w-full font-dm-sans"
                  rows={2}
                  value={notes}
                  onChange={(e) => setNotes(e.target.value)}
                  placeholder="Mis. eksperimen Q2 — tambah bobot Movement saat user banyak yang konsisten sesi."
                />
              </div>

              {/* Sum indicator */}
              <div
                className={cn(
                  "rounded-lg px-4 py-3 font-dm-sans text-sm",
                  sum === 100
                    ? "bg-emerald-50 text-emerald-700"
                    : "bg-amber-50 text-amber-700",
                )}
              >
                Total: <span className="font-dm-mono font-medium">{sum}</span>
                {sum === 100 ? " ✓ valid" : ` — harus 100% (selisih ${100 - sum})`}
              </div>

              <div className="flex justify-end gap-2 pt-2">
                <button
                  type="button"
                  onClick={handleReset}
                  className="btn-secondary font-dm-sans"
                >
                  <RotateCcw className="h-4 w-4" /> Reset Default
                </button>
                <button
                  type="button"
                  onClick={handleSave}
                  disabled={!isValid || !isDirty || update.isPending}
                  className="sf-cta-primary"
                >
                  {update.isPending ? (
                    <Loader2 className="h-4 w-4 animate-spin" />
                  ) : (
                    <Save className="h-4 w-4" />
                  )}
                  Simpan Bobot
                </button>
              </div>
            </div>
          </div>

          {/* Preview & metadata */}
          <div className="space-y-4">
            <div className="card p-5 bg-sf-deepNavy border-sf-deepNavy text-white">
              <p className="font-dm-sans text-xs uppercase tracking-wider text-sf-warmGold mb-1">
                Preview System Score
              </p>
              <p className="font-dm-sans text-sm text-white/80">
                Klien dengan skor:
              </p>
              <ul className="font-dm-sans text-xs text-white/70 mt-2 space-y-0.5">
                <li>Movement 80, Nutrition 70, Rest 60</li>
              </ul>
              <div className="mt-4 flex items-baseline gap-2">
                <span className="font-dm-mono text-5xl text-sf-warmGold">
                  {previewScore(80, 70, 60, movement, nutrition, rest)}
                </span>
                <span className="font-dm-sans text-sm text-white/60">/100</span>
              </div>
              <div className="grid grid-cols-3 gap-3 mt-4 pt-4 border-t border-white/10">
                <PreviewBar label="Movement" pct={movement} color="bg-sf-deepTeal" />
                <PreviewBar label="Nutrition" pct={nutrition} color="bg-sf-systemBlue" />
                <PreviewBar label="Rest" pct={rest} color="bg-sf-warmGold" />
              </div>
            </div>

            {current && (
              <div className="card p-4 text-xs font-dm-sans text-slate-500 space-y-1">
                <p>
                  ID:{" "}
                  <span className="font-dm-mono text-[11px]">{current.id}</span>
                </p>
                <p>
                  Diperbarui:{" "}
                  {new Date(current.updated_at).toLocaleString("id-ID", {
                    dateStyle: "medium",
                    timeStyle: "short",
                  })}
                </p>
                {current.notes && (
                  <p className="pt-1 italic">&ldquo;{current.notes}&rdquo;</p>
                )}
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

// ─── Subcomponents ─────────────────────────────────────────────────

function WeightSlider({
  icon: Icon,
  label,
  value,
  onChange,
  color,
}: {
  icon: React.ComponentType<{ className?: string }>;
  label: string;
  value: number;
  onChange: (v: number) => void;
  color: string;
}) {
  return (
    <div>
      <div className="flex items-center justify-between mb-2">
        <span className="flex items-center gap-2 font-dm-sans text-sm text-sf-charcoal">
          <Icon className="h-4 w-4 text-slate-400" />
          {label}
        </span>
        <span className="font-dm-mono text-base text-sf-charcoal">{value}%</span>
      </div>
      <div className="flex items-center gap-3">
        <input
          type="range"
          min={0}
          max={100}
          step={5}
          value={value}
          onChange={(e) => onChange(+e.target.value)}
          className="flex-1 accent-sf-warmGold"
        />
        <input
          type="number"
          min={0}
          max={100}
          value={value}
          onChange={(e) => onChange(Math.min(100, Math.max(0, +e.target.value)))}
          className="input w-20 text-center font-dm-mono"
        />
      </div>
      <div className="mt-2 h-2 rounded-full bg-slate-100 overflow-hidden">
        <div
          className={cn("h-full transition-all", color)}
          style={{ width: `${value}%` }}
        />
      </div>
    </div>
  );
}

function PreviewBar({ label, pct, color }: { label: string; pct: number; color: string }) {
  return (
    <div>
      <p className="font-dm-sans text-[10px] text-white/50 uppercase tracking-wider">
        {label}
      </p>
      <p className="font-dm-mono text-sm text-white">{pct}%</p>
      <div className="mt-1 h-1 rounded-full bg-white/10 overflow-hidden">
        <div className={cn("h-full", color)} style={{ width: `${pct}%` }} />
      </div>
    </div>
  );
}

// Same formula as the API engine: ComputeSystemScoreV2.
function previewScore(
  m: number, n: number, r: number,
  mPct: number, nPct: number, rPct: number,
): string {
  const total = (m * mPct + n * nPct + r * rPct) / 100;
  return total.toFixed(1);
}
