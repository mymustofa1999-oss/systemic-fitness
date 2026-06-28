"use client";

import { useState, useCallback, useEffect } from "react";
import { useRouter } from "next/navigation";
import { useExercises, useCreateWorkout } from "@/hooks/useWorkouts";
import { SearchInput } from "@/components/shared/SearchInput";
import {
  DndContext, closestCenter, DragOverlay,
  useSensor, useSensors, PointerSensor,
  type DragEndEvent, type DragStartEvent,
} from "@dnd-kit/core";
import {
  SortableContext, verticalListSortingStrategy,
  useSortable, arrayMove,
} from "@dnd-kit/sortable";
import { CSS } from "@dnd-kit/utilities";
import {
  ArrowLeft, Plus, GripVertical, Trash2, Loader2,
  Dumbbell, ChevronDown, Save, FileText, Send, X,
} from "lucide-react";
import Link from "next/link";
import { cn } from "@/lib/utils";
import { SearchableSelect } from "@/components/shared/SearchableSelect";

// ── Types ───────────────────────────────────────────────────────

interface WorkoutExerciseItem {
  _uid: string;
  exercise_id: string;
  exercise_name: string;
  order_index: number;
  sets: number;
  reps: string;
  weight_kg: string;
  rest_seconds: number;
  notes: string;
  superset_group: number | null;
}

const MUSCLE_TABS = ["All", "Chest", "Back", "Legs", "Shoulders", "Arms", "Core", "Cardio"];
const REST_OPTIONS = [30, 45, 60, 90, 120, 180];

let uidCounter = 0;
function uid() { return `we_${++uidCounter}_${Date.now()}`; }

// ── Page ────────────────────────────────────────────────────────

export default function CreateWorkoutPage() {
  const router = useRouter();
  const { mutate: create, isPending } = useCreateWorkout();

  // Workout form
  const [name, setName] = useState("");
  const [type, setType] = useState("strength");
  const [duration, setDuration] = useState("");
  const [description, setDescription] = useState("");
  const [exercises, setExercises] = useState<WorkoutExerciseItem[]>([]);

  // Exercise browser
  const [search, setSearch] = useState("");
  const [muscleTab, setMuscleTab] = useState("All");
  const { data: exData } = useExercises({
    limit: 100, search,
    muscle_group: muscleTab === "All" ? undefined : muscleTab.toLowerCase(),
  });
  const exerciseList = (exData?.data ?? []) as any[];

  // DnD
  const [activeId, setActiveId] = useState<string | null>(null);
  const sensors = useSensors(useSensor(PointerSensor, { activationConstraint: { distance: 5 } }));

  // Auto-save draft to localStorage
  useEffect(() => {
    const t = setTimeout(() => {
      if (name || exercises.length > 0) {
        localStorage.setItem("workout_draft", JSON.stringify({ name, type, duration, description, exercises }));
      }
    }, 1000);
    return () => clearTimeout(t);
  }, [name, type, duration, description, exercises]);

  // Load draft on mount
  useEffect(() => {
    try {
      const draft = localStorage.getItem("workout_draft");
      if (draft) {
        const d = JSON.parse(draft);
        if (d.name) setName(d.name);
        if (d.type) setType(d.type);
        if (d.duration) setDuration(d.duration);
        if (d.description) setDescription(d.description);
        if (d.exercises?.length) setExercises(d.exercises);
      }
    } catch { /* ignore */ }
  }, []);

  function addExercise(ex: any) {
    setExercises((prev) => [
      ...prev,
      {
        _uid: uid(),
        exercise_id: ex.id,
        exercise_name: ex.name,
        order_index: prev.length,
        sets: 3,
        reps: "10",
        weight_kg: "",
        rest_seconds: 60,
        notes: "",
        superset_group: null,
      },
    ]);
  }

  function removeExercise(uidVal: string) {
    setExercises((prev) => prev.filter((e) => e._uid !== uidVal).map((e, i) => ({ ...e, order_index: i })));
  }

  function updateExercise(uidVal: string, field: string, value: any) {
    setExercises((prev) => prev.map((e) => (e._uid === uidVal ? { ...e, [field]: value } : e)));
  }

  function handleDragStart(event: DragStartEvent) {
    setActiveId(event.active.id as string);
  }

  function handleDragEnd(event: DragEndEvent) {
    setActiveId(null);
    const { active, over } = event;
    if (!over || active.id === over.id) return;
    setExercises((prev) => {
      const oldIdx = prev.findIndex((e) => e._uid === active.id);
      const newIdx = prev.findIndex((e) => e._uid === over.id);
      return arrayMove(prev, oldIdx, newIdx).map((e, i) => ({ ...e, order_index: i }));
    });
  }

  function handleSubmit(isTemplate = false) {
    if (!name.trim() || exercises.length === 0) return;
    create(
      {
        name: name.trim(),
        description: description || undefined,
        type,
        estimated_duration_min: duration ? parseInt(duration) : undefined,
        is_template: isTemplate,
        exercises: exercises.map((e) => ({
          exercise_id: e.exercise_id,
          order_index: e.order_index,
          sets: e.sets,
          reps: e.reps || undefined,
          weight_kg: e.weight_kg ? parseFloat(e.weight_kg) : undefined,
          rest_seconds: e.rest_seconds,
          notes: e.notes || undefined,
          superset_group: e.superset_group,
        })),
      },
      {
        onSuccess: () => {
          localStorage.removeItem("workout_draft");
          router.push("/workouts");
        },
      }
    );
  }

  const activeExercise = exercises.find((e) => e._uid === activeId);

  return (
    <div className="space-y-4">
      <Link href="/workouts" className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-slate-700">
        <ArrowLeft className="h-4 w-4" /> Back to Workouts
      </Link>

      <DndContext sensors={sensors} collisionDetection={closestCenter} onDragStart={handleDragStart} onDragEnd={handleDragEnd}>
        <div className="flex gap-5" style={{ height: "calc(100vh - 180px)" }}>

          {/* ── LEFT: Exercise Library Browser ─────────────── */}
          <div className="w-[380px] shrink-0 card flex flex-col overflow-hidden">
            <div className="p-3 border-b border-slate-100">
              <h3 className="text-sm font-semibold text-slate-700 mb-2">Exercise Library</h3>
              <SearchInput value={search} onChange={setSearch} placeholder="Search exercises..." />
            </div>

            {/* Muscle tabs */}
            <div className="px-3 py-2 border-b border-slate-100 flex gap-1 overflow-x-auto">
              {MUSCLE_TABS.map((tab) => (
                <button
                  key={tab}
                  onClick={() => setMuscleTab(tab)}
                  className={cn(
                    "px-2.5 py-1 rounded-md text-xs font-medium whitespace-nowrap transition-colors",
                    muscleTab === tab
                      ? "bg-sf-iceBlue text-sf-deepNavy"
                      : "text-slate-500 hover:bg-slate-50"
                  )}
                >
                  {tab}
                </button>
              ))}
            </div>

            {/* Exercise list */}
            <div className="flex-1 overflow-y-auto p-2">
              {exerciseList.length === 0 ? (
                <p className="text-xs text-slate-400 text-center py-8">No exercises found</p>
              ) : (
                <div className="space-y-1">
                  {exerciseList.map((ex: any) => (
                    <button
                      key={ex.id}
                      onClick={() => addExercise(ex)}
                      className="w-full flex items-center gap-2.5 px-3 py-2.5 rounded-lg text-left
                                 hover:bg-sf-iceBlue transition-colors group"
                    >
                      <div className="h-8 w-8 rounded-lg bg-slate-50 group-hover:bg-sf-iceBlue flex items-center justify-center shrink-0 transition-colors">
                        <Dumbbell className="h-3.5 w-3.5 text-slate-300 group-hover:text-sf-deepNavy" />
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="text-sm font-medium text-slate-800 truncate">{ex.name}</p>
                        <p className="text-[10px] text-slate-400 capitalize">{ex.muscle_group?.slice(0, 2).join(", ")}</p>
                      </div>
                      <Plus className="h-4 w-4 text-slate-300 group-hover:text-sf-deepNavy shrink-0 opacity-0 group-hover:opacity-100 transition-opacity" />
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* ── RIGHT: Workout Canvas ──────────────────────── */}
          <div className="flex-1 flex flex-col overflow-hidden">
            {/* Workout meta */}
            <div className="card p-4 mb-4 shrink-0">
              <input
                value={name}
                onChange={(e) => setName(e.target.value)}
                className="text-xl font-bold font-heading text-slate-900 w-full bg-transparent
                           placeholder:text-slate-300 focus:outline-none"
                placeholder="Nama Sesi..."
              />
              <div className="flex items-center gap-3 mt-3">
                <SearchableSelect
                  options={["strength", "cardio", "hiit", "flexibility", "custom"].map((t) => ({ value: t, label: t.charAt(0).toUpperCase() + t.slice(1) }))}
                  value={type}
                  onChange={setType}
                  placeholder="Select type..."
                  className="w-40"
                />
                <div className="flex items-center gap-1.5">
                  <input
                    value={duration}
                    onChange={(e) => setDuration(e.target.value)}
                    type="number"
                    min="1"
                    className="input w-20 text-center"
                    placeholder="—"
                  />
                  <span className="text-xs text-slate-400">min</span>
                </div>
                <input
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  className="input flex-1"
                  placeholder="Description (optional)"
                />
              </div>
            </div>

            {/* Exercise list (sortable) */}
            <div className="flex-1 overflow-y-auto">
              {exercises.length === 0 ? (
                <div className="card h-full flex flex-col items-center justify-center text-center p-8">
                  <div className="p-4 rounded-2xl bg-slate-50 mb-4">
                    <Dumbbell className="h-8 w-8 text-slate-300" />
                  </div>
                  <p className="text-sm font-medium text-slate-500">No exercises added yet</p>
                  <p className="text-xs text-slate-400 mt-1">Click exercises from the library to add them</p>
                </div>
              ) : (
                <SortableContext items={exercises.map((e) => e._uid)} strategy={verticalListSortingStrategy}>
                  <div className="space-y-2">
                    {exercises.map((ex) => (
                      <SortableExerciseRow
                        key={ex._uid}
                        item={ex}
                        onUpdate={(f, v) => updateExercise(ex._uid, f, v)}
                        onRemove={() => removeExercise(ex._uid)}
                      />
                    ))}
                  </div>
                </SortableContext>
              )}
            </div>

            {/* Bottom Actions */}
            <div className="card p-3 mt-4 flex items-center justify-between shrink-0">
              <p className="text-xs text-slate-400">
                {exercises.length} exercise{exercises.length !== 1 ? "s" : ""}
                {localStorage.getItem("workout_draft") && " · Draft saved"}
              </p>
              <div className="flex gap-2">
                <button
                  onClick={() => handleSubmit(true)}
                  disabled={isPending || !name.trim() || exercises.length === 0}
                  className="btn-secondary"
                >
                  <FileText className="h-4 w-4" /> Save as Template
                </button>
                <button
                  onClick={() => handleSubmit(false)}
                  disabled={isPending || !name.trim() || exercises.length === 0}
                  className="btn-primary"
                >
                  {isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Send className="h-4 w-4" />}
                  {isPending ? "Menyimpan..." : "Buat Sesi"}
                </button>
              </div>
            </div>
          </div>
        </div>

        <DragOverlay>
          {activeExercise && (
            <div className="card p-3 px-4 shadow-lg border-sf-iceBlue opacity-90">
              <span className="text-sm font-medium text-slate-900">{activeExercise.exercise_name}</span>
            </div>
          )}
        </DragOverlay>
      </DndContext>
    </div>
  );
}

// ── Sortable Exercise Row ───────────────────────────────────────

function SortableExerciseRow({
  item, onUpdate, onRemove,
}: {
  item: WorkoutExerciseItem;
  onUpdate: (field: string, value: any) => void;
  onRemove: () => void;
}) {
  const { attributes, listeners, setNodeRef, transform, transition, isDragging } = useSortable({ id: item._uid });
  const [notesOpen, setNotesOpen] = useState(false);

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.4 : 1,
  };

  return (
    <div ref={setNodeRef} style={style} className="card p-3 group">
      <div className="flex items-center gap-2">
        {/* Drag Handle */}
        <button {...attributes} {...listeners} className="p-1 cursor-grab active:cursor-grabbing text-slate-300 hover:text-slate-500">
          <GripVertical className="h-4 w-4" />
        </button>

        {/* Order number */}
        <span className="w-6 h-6 rounded-md bg-sf-iceBlue text-sf-deepNavy flex items-center justify-center text-xs font-bold shrink-0">
          {item.order_index + 1}
        </span>

        {/* Exercise icon + name */}
        <div className="flex items-center gap-2 min-w-[140px]">
          <div className="h-8 w-8 rounded-lg bg-slate-50 flex items-center justify-center shrink-0">
            <Dumbbell className="h-3.5 w-3.5 text-slate-300" />
          </div>
          <span className="text-sm font-medium text-slate-900 truncate">{item.exercise_name}</span>
        </div>

        {/* Sets */}
        <div className="flex items-center gap-1">
          <input
            value={item.sets}
            onChange={(e) => onUpdate("sets", parseInt(e.target.value) || 0)}
            type="number"
            min="1"
            className="input w-14 text-center py-1.5"
          />
          <span className="text-[10px] text-slate-400 w-6">sets</span>
        </div>

        {/* Reps */}
        <div className="flex items-center gap-1">
          <input
            value={item.reps}
            onChange={(e) => onUpdate("reps", e.target.value)}
            className="input w-16 text-center py-1.5"
            placeholder="8-12"
          />
          <span className="text-[10px] text-slate-400 w-6">reps</span>
        </div>

        {/* Weight */}
        <div className="flex items-center gap-1">
          <input
            value={item.weight_kg}
            onChange={(e) => onUpdate("weight_kg", e.target.value)}
            className="input w-16 text-center py-1.5"
            placeholder="—"
          />
          <span className="text-[10px] text-slate-400 w-4">kg</span>
        </div>

        {/* Rest */}
        <SearchableSelect
          options={REST_OPTIONS.map((s) => ({ value: String(s), label: `${s}s` }))}
          value={String(item.rest_seconds)}
          onChange={(v) => onUpdate("rest_seconds", parseInt(v))}
          placeholder="Rest"
          className="w-24"
        />

        {/* Notes toggle */}
        <button
          onClick={() => setNotesOpen(!notesOpen)}
          className={cn("p-1.5 rounded-md transition-colors", notesOpen ? "bg-sf-iceBlue text-sf-deepNavy" : "text-slate-300 hover:text-slate-500")}
          title="Notes"
        >
          <ChevronDown className={cn("h-3.5 w-3.5 transition-transform", notesOpen && "rotate-180")} />
        </button>

        {/* Delete */}
        <button onClick={onRemove} className="p-1.5 text-slate-300 hover:text-rose-500 opacity-0 group-hover:opacity-100 transition-all">
          <Trash2 className="h-3.5 w-3.5" />
        </button>
      </div>

      {/* Expandable notes */}
      {notesOpen && (
        <div className="mt-2 ml-10 animate-slide-in">
          <input
            value={item.notes}
            onChange={(e) => onUpdate("notes", e.target.value)}
            className="input text-xs py-1.5"
            placeholder="Add notes (e.g., tempo 3-1-2, drop set on last set)..."
          />
        </div>
      )}
    </div>
  );
}
