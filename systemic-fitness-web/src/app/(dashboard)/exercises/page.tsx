"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useExercises } from "@/hooks/useWorkouts";
import { SearchInput } from "@/components/shared/SearchInput";
import { EmptyState } from "@/components/shared/EmptyState";
import {
  Dumbbell, Plus, LayoutGrid, List, Play, ChevronDown, ChevronLeft, ChevronRight,
  Loader2, X,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { SearchableSelect } from "@/components/shared/SearchableSelect";
import { apiPost } from "@/lib/api";
import { toast } from "@/stores/toastStore";
import { useQueryClient } from "@tanstack/react-query";

// ── Constants ───────────────────────────────────────────────────

const MUSCLE_GROUPS = [
  "chest", "back", "shoulders", "biceps", "triceps", "forearms",
  "quadriceps", "hamstrings", "glutes", "calves", "core", "cardio",
];

const EQUIPMENT = [
  "barbell", "dumbbell", "cable machine", "machine", "bodyweight",
  "pull-up bar", "ab wheel", "battle ropes", "jump rope",
  "treadmill", "rowing machine", "kettlebell",
];

const diffColors: Record<string, string> = {
  beginner: "bg-emerald-100 text-emerald-700",
  intermediate: "bg-amber-100 text-amber-700",
  advanced: "bg-rose-100 text-rose-700",
};

const muscleIcons: Record<string, string> = {
  chest: "💪", back: "🔙", shoulders: "🏋️", biceps: "💪", triceps: "💪",
  quadriceps: "🦵", hamstrings: "🦵", glutes: "🍑", calves: "🦵",
  core: "🎯", cardio: "❤️", forearms: "💪",
};

function getExPageNumbers(current: number, total: number): (number | "...")[] {
  if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1);
  const pages: (number | "...")[] = [1];
  if (current > 3) pages.push("...");
  const start = Math.max(2, current - 1);
  const end = Math.min(total - 1, current + 1);
  for (let i = start; i <= end; i++) pages.push(i);
  if (current < total - 2) pages.push("...");
  pages.push(total);
  return pages;
}

// ── Page ────────────────────────────────────────────────────────

export default function ExercisesPage() {
  const router = useRouter();
  const [view, setView] = useState<"grid" | "list">("grid");
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState("");
  const [selectedMuscles, setSelectedMuscles] = useState<string[]>([]);
  const [equipment, setEquipment] = useState("");
  const [difficulty, setDifficulty] = useState("");
  const [createOpen, setCreateOpen] = useState(false);
  const [filterOpen, setFilterOpen] = useState(false);

  const { data, isLoading } = useExercises({
    page, limit: view === "grid" ? 24 : 20, search,
    muscle_group: selectedMuscles.length > 0 ? selectedMuscles.join(",") : undefined,
    equipment: equipment || undefined,
    difficulty: difficulty || undefined,
  });
  const exercises = (data?.data ?? []) as any[];
  const meta = data?.meta;

  function toggleMuscle(m: string) {
    setSelectedMuscles((prev) =>
      prev.includes(m) ? prev.filter((x) => x !== m) : [...prev, m]
    );
    setPage(1);
  }

  function clearFilters() {
    setSelectedMuscles([]);
    setEquipment("");
    setDifficulty("");
    setSearch("");
    setPage(1);
  }

  const hasFilters = selectedMuscles.length > 0 || equipment || difficulty;

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Exercise Library</h1>
          <p className="text-sm text-slate-500 mt-1">
            {meta?.total != null ? `${meta.total} exercises` : "Browse and manage exercises"}
          </p>
        </div>
        <div className="flex items-center gap-2">
          {/* View Toggle */}
          <div className="flex rounded-lg border border-slate-200 p-0.5">
            <button
              onClick={() => setView("grid")}
              className={cn("p-2 rounded-md transition-colors", view === "grid" ? "bg-sf-iceBlue text-sf-deepNavy" : "text-slate-400 hover:text-slate-600")}
            >
              <LayoutGrid className="h-4 w-4" />
            </button>
            <button
              onClick={() => setView("list")}
              className={cn("p-2 rounded-md transition-colors", view === "list" ? "bg-sf-iceBlue text-sf-deepNavy" : "text-slate-400 hover:text-slate-600")}
            >
              <List className="h-4 w-4" />
            </button>
          </div>
          <button onClick={() => setCreateOpen(true)} className="btn-primary">
            <Plus className="h-4 w-4" /> Add Exercise
          </button>
        </div>
      </div>

      {/* Search + Filters */}
      <div className="flex items-center gap-3 flex-wrap">
        <SearchInput value={search} onChange={(v) => { setSearch(v); setPage(1); }} placeholder="Search exercises..." />

        <button
          onClick={() => setFilterOpen(!filterOpen)}
          className={cn("btn-secondary", hasFilters && "border-sf-systemBlue/40 text-sf-deepNavy")}
        >
          <ChevronDown className={cn("h-4 w-4 transition-transform", filterOpen && "rotate-180")} />
          Filters {hasFilters && `(${selectedMuscles.length + (equipment ? 1 : 0) + (difficulty ? 1 : 0)})`}
        </button>

        {hasFilters && (
          <button onClick={clearFilters} className="text-xs text-slate-500 hover:text-slate-700">
            Clear all
          </button>
        )}
      </div>

      {/* Filter Panel */}
      {filterOpen && (
        <div className="card p-5 space-y-4 animate-slide-in">
          <div>
            <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">Muscle Group</p>
            <div className="flex flex-wrap gap-2">
              {MUSCLE_GROUPS.map((m) => (
                <button
                  key={m}
                  onClick={() => toggleMuscle(m)}
                  className={cn(
                    "px-3 py-1.5 rounded-lg text-xs font-medium capitalize transition-colors",
                    selectedMuscles.includes(m)
                      ? "bg-sf-iceBlue text-sf-deepNavy border border-sf-iceBlue"
                      : "bg-slate-50 text-slate-600 border border-slate-100 hover:border-slate-200"
                  )}
                >
                  {muscleIcons[m] ?? "•"} {m}
                </button>
              ))}
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">Equipment</p>
              <SearchableSelect
                options={[{ value: "", label: "All Equipment" }, ...EQUIPMENT.map((eq) => ({ value: eq, label: eq.charAt(0).toUpperCase() + eq.slice(1) }))]}
                value={equipment}
                onChange={(v) => { setEquipment(v); setPage(1); }}
                placeholder="All Equipment"
                searchPlaceholder="Cari equipment..."
              />
            </div>
            <div>
              <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">Difficulty</p>
              <SearchableSelect
                options={[{ value: "", label: "All Levels" }, { value: "beginner", label: "Beginner" }, { value: "intermediate", label: "Intermediate" }, { value: "advanced", label: "Advanced" }]}
                value={difficulty}
                onChange={(v) => { setDifficulty(v); setPage(1); }}
                placeholder="All Levels"
              />
            </div>
          </div>
        </div>
      )}

      {/* Content */}
      {isLoading ? (
        view === "grid" ? <GridSkeleton /> : <ListSkeleton />
      ) : exercises.length === 0 ? (
        <EmptyState
          icon={Dumbbell}
          title={search || hasFilters ? "No exercises match" : "No exercises yet"}
          description={search || hasFilters ? "Try adjusting your filters" : "Add your first exercise to build workouts."}
          action={!search && !hasFilters ? <button onClick={() => setCreateOpen(true)} className="btn-primary"><Plus className="h-4 w-4" /> Add Exercise</button> : undefined}
        />
      ) : view === "grid" ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {exercises.map((ex: any) => (
            <div
              key={ex.id}
              onClick={() => router.push(`/exercises/${ex.id}`)}
              className="card p-4 cursor-pointer group"
            >
              {/* Thumbnail */}
              <div className="h-32 rounded-lg bg-slate-50 flex items-center justify-center mb-3 overflow-hidden relative">
                <Dumbbell className="h-8 w-8 text-slate-200" />
                {ex.video_url && (
                  <div className="absolute inset-0 bg-black/0 group-hover:bg-black/20 flex items-center justify-center transition-colors">
                    <Play className="h-8 w-8 text-white opacity-0 group-hover:opacity-100 transition-opacity" />
                  </div>
                )}
              </div>

              {/* Info */}
              <h3 className="font-medium text-slate-900 text-sm truncate">{ex.name}</h3>
              <div className="flex items-center gap-1.5 mt-2 flex-wrap">
                {ex.muscle_group?.slice(0, 3).map((m: string) => (
                  <span key={m} className="px-1.5 py-0.5 rounded bg-sf-iceBlue text-sf-deepNavy text-[10px] font-medium capitalize">{m}</span>
                ))}
                {ex.muscle_group?.length > 3 && (
                  <span className="text-[10px] text-slate-400">+{ex.muscle_group.length - 3}</span>
                )}
              </div>
              <div className="flex items-center justify-between mt-2">
                <span className={cn("px-2 py-0.5 rounded-full text-[10px] font-medium capitalize", diffColors[ex.difficulty])}>
                  {ex.difficulty}
                </span>
                {ex.equipment && (
                  <span className="text-[10px] text-slate-400 capitalize">{ex.equipment}</span>
                )}
              </div>
            </div>
          ))}
        </div>
      ) : (
        /* List View */
        <div className="card divide-y divide-slate-50 overflow-hidden">
          {exercises.map((ex: any) => (
            <div
              key={ex.id}
              onClick={() => router.push(`/exercises/${ex.id}`)}
              className="px-4 py-3.5 flex items-center gap-4 hover:bg-slate-50/80 cursor-pointer transition-colors"
            >
              <div className="h-10 w-10 rounded-lg bg-slate-50 flex items-center justify-center shrink-0">
                <Dumbbell className="h-4 w-4 text-slate-300" />
              </div>
              <div className="flex-1 min-w-0">
                <p className="font-medium text-slate-900 text-sm">{ex.name}</p>
                <p className="text-xs text-slate-400">{ex.muscle_group?.join(", ")}</p>
              </div>
              <span className="text-xs text-slate-400 capitalize hidden sm:block">{ex.equipment ?? "—"}</span>
              <span className={cn("px-2 py-0.5 rounded-full text-xs font-medium capitalize", diffColors[ex.difficulty])}>
                {ex.difficulty}
              </span>
              {ex.is_system && <span className="text-[10px] text-sf-deepNavy font-medium">System</span>}
            </div>
          ))}
        </div>
      )}

      {/* Pagination — matching DataTable style */}
      {meta && (
        <div className="flex items-center justify-between">
          <p className="text-xs text-slate-500">
            {meta.total === 0
              ? "No data"
              : `Showing ${(page - 1) * (view === "grid" ? 24 : 20) + 1}–${Math.min(page * (view === "grid" ? 24 : 20), meta.total)} of ${meta.total}`}
          </p>
          {meta.total_pages > 1 && (
            <div className="flex items-center gap-1">
              <button type="button" className="p-1.5 rounded-lg text-slate-500 hover:bg-slate-100 disabled:opacity-30 transition-colors" disabled={page <= 1} onClick={() => setPage(page - 1)}>
                <ChevronLeft className="h-4 w-4" />
              </button>
              {getExPageNumbers(page, meta.total_pages).map((p, i) =>
                p === "..." ? (
                  <span key={`dots-${i}`} className="px-1.5 text-xs text-slate-400 select-none">...</span>
                ) : (
                  <button key={p} type="button" onClick={() => setPage(p as number)}
                    className={cn("min-w-[32px] h-8 rounded-lg text-xs font-medium transition-colors",
                      p === page ? "bg-sf-deepNavy text-white shadow-sm" : "text-slate-600 hover:bg-slate-100"
                    )}>{p}</button>
                )
              )}
              <button type="button" className="p-1.5 rounded-lg text-slate-500 hover:bg-slate-100 disabled:opacity-30 transition-colors" disabled={page >= meta.total_pages} onClick={() => setPage(page + 1)}>
                <ChevronRight className="h-4 w-4" />
              </button>
            </div>
          )}
        </div>
      )}

      {/* Create Exercise Modal */}
      {createOpen && <CreateExerciseModal onClose={() => setCreateOpen(false)} />}
    </div>
  );
}

// ── Create Exercise Modal ───────────────────────────────────────

function CreateExerciseModal({ onClose }: { onClose: () => void }) {
  const qc = useQueryClient();
  const [loading, setLoading] = useState(false);
  const [name, setName] = useState("");
  const [nameEn, setNameEn] = useState("");
  const [muscles, setMuscles] = useState<string[]>([]);
  const [equip, setEquip] = useState("");
  const [diff, setDiff] = useState("beginner");
  const [videoUrl, setVideoUrl] = useState("");
  const [description, setDescription] = useState("");
  const [descriptionEn, setDescriptionEn] = useState("");
  const [instructions, setInstructions] = useState<{ id: string; en: string }[]>([{ id: "", en: "" }]);

  function addInstruction() { setInstructions([...instructions, { id: "", en: "" }]); }
  function removeInstruction(i: number) { setInstructions(instructions.filter((_, idx) => idx !== i)); }
  function updateInstruction(i: number, field: "id" | "en", v: string) {
    setInstructions(instructions.map((s, idx) => idx === i ? { ...s, [field]: v } : s));
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim() || !nameEn.trim() || muscles.length === 0) return;
    setLoading(true);
    try {
      await apiPost("/api/exercises", {
        name: name.trim(),
        name_en: nameEn.trim(),
        description: description || undefined,
        description_en: descriptionEn || undefined,
        muscle_group: muscles,
        equipment: equip || undefined,
        difficulty: diff,
        video_url: videoUrl || undefined,
        instructions: instructions.map((s) => s.id.trim()).filter(Boolean),
        instructions_en: instructions.map((s) => s.en.trim()).filter(Boolean),
      });
      qc.invalidateQueries({ queryKey: ["exercises"] });
      toast.success("Exercise created successfully");
      onClose();
    } catch (err: any) {
      toast.error(err.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center pt-[5vh] overflow-y-auto" onClick={onClose}>
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" />
      <div className="relative bg-white rounded-2xl shadow-xl max-w-2xl w-full mx-4 mb-12 animate-slide-in" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
          <h2 className="text-lg font-semibold text-slate-900">Create Exercise</h2>
          <button onClick={onClose} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400">
            <X className="h-5 w-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-5 max-h-[75vh] overflow-y-auto">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Exercise Name (ID) *</label>
              <input value={name} onChange={(e) => setName(e.target.value)} required className="input" placeholder="e.g. Barbel Bench Press" autoFocus />
            </div>
            <div>
              <label className="label">Exercise Name (EN) *</label>
              <input value={nameEn} onChange={(e) => setNameEn(e.target.value)} required className="input" placeholder="e.g. Barbell Bench Press" />
            </div>
          </div>

          <div>
            <label className="label">Muscle Groups *</label>
            <div className="flex flex-wrap gap-2">
              {MUSCLE_GROUPS.map((m) => (
                <button
                  key={m}
                  type="button"
                  onClick={() => setMuscles((prev) => prev.includes(m) ? prev.filter((x) => x !== m) : [...prev, m])}
                  className={cn(
                    "px-3 py-1.5 rounded-lg text-xs font-medium capitalize transition-colors",
                    muscles.includes(m)
                      ? "bg-sf-deepNavy text-white"
                      : "bg-slate-50 text-slate-600 hover:bg-slate-100"
                  )}
                >
                  {m}
                </button>
              ))}
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Equipment</label>
              <SearchableSelect
                options={[{ value: "", label: "None" }, ...EQUIPMENT.map((eq) => ({ value: eq, label: eq.charAt(0).toUpperCase() + eq.slice(1) }))]}
                value={equip}
                onChange={setEquip}
                placeholder="Select equipment..."
                searchPlaceholder="Search equipment..."
              />
            </div>
            <div>
              <label className="label">Difficulty *</label>
              <SearchableSelect
                options={[{ value: "beginner", label: "Beginner" }, { value: "intermediate", label: "Intermediate" }, { value: "advanced", label: "Advanced" }]}
                value={diff}
                onChange={setDiff}
                placeholder="Select difficulty..."
              />
            </div>
          </div>

          <div>
            <label className="label">Video URL</label>
            <input value={videoUrl} onChange={(e) => setVideoUrl(e.target.value)} className="input" placeholder="https://youtube.com/..." />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Description (ID)</label>
              <textarea value={description} onChange={(e) => setDescription(e.target.value)} className="input" rows={2} placeholder="Deskripsi singkat..." />
            </div>
            <div>
              <label className="label">Description (EN)</label>
              <textarea value={descriptionEn} onChange={(e) => setDescriptionEn(e.target.value)} className="input" rows={2} placeholder="Brief description..." />
            </div>
          </div>

          <div>
            <div className="flex items-center justify-between mb-1.5">
              <label className="text-sm font-medium text-slate-700">Instructions (Langkah-langkah)</label>
              <button type="button" onClick={addInstruction} className="text-xs text-sf-deepNavy hover:text-sf-deepNavy font-medium">+ Add Step</button>
            </div>
            <div className="space-y-3">
              {instructions.map((step, i) => (
                <div key={i} className="flex items-start gap-2 border border-slate-100 p-2.5 rounded-lg bg-slate-50/55">
                  <span className="w-6 h-6 rounded-full bg-slate-100 text-slate-500 flex items-center justify-center text-xs font-bold shrink-0 mt-2">{i + 1}</span>
                  <div className="flex-1 grid grid-cols-2 gap-3">
                    <input
                      value={step.id}
                      onChange={(e) => updateInstruction(i, "id", e.target.value)}
                      className="input"
                      placeholder={`Langkah ${i + 1} (ID)...`}
                    />
                    <input
                      value={step.en}
                      onChange={(e) => updateInstruction(i, "en", e.target.value)}
                      className="input"
                      placeholder={`Step ${i + 1} (EN)...`}
                    />
                  </div>
                  {instructions.length > 1 && (
                    <button type="button" onClick={() => removeInstruction(i)} className="p-1 text-slate-400 hover:text-rose-500 mt-2">
                      <X className="h-4 w-4" />
                    </button>
                  )}
                </div>
              ))}
            </div>
          </div>

          <div className="flex justify-end gap-3 pt-2">
            <button type="button" onClick={onClose} className="btn-secondary">Cancel</button>
            <button type="submit" disabled={loading || !name.trim() || !nameEn.trim() || muscles.length === 0} className="btn-primary">
              {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <Plus className="h-4 w-4" />}
              {loading ? "Creating..." : "Create Exercise"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

// ── Skeletons ───────────────────────────────────────────────────

function GridSkeleton() {
  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
      {Array.from({ length: 8 }).map((_, i) => (
        <div key={i} className="card p-4">
          <div className="skeleton h-32 w-full rounded-lg mb-3" />
          <div className="skeleton h-4 w-3/4 mb-2" />
          <div className="flex gap-1"><div className="skeleton h-5 w-12" /><div className="skeleton h-5 w-12" /></div>
        </div>
      ))}
    </div>
  );
}

function ListSkeleton() {
  return (
    <div className="card divide-y divide-slate-50 overflow-hidden">
      {Array.from({ length: 6 }).map((_, i) => (
        <div key={i} className="px-4 py-3.5 flex items-center gap-4">
          <div className="skeleton h-10 w-10 rounded-lg" />
          <div className="flex-1 space-y-1"><div className="skeleton h-4 w-32" /><div className="skeleton h-3 w-48" /></div>
          <div className="skeleton h-5 w-16 rounded-full" />
        </div>
      ))}
    </div>
  );
}
