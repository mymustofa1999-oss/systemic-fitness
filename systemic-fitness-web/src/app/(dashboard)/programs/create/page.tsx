"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useWorkouts, useCreateProgram } from "@/hooks/useWorkouts";
import { SearchInput } from "@/components/shared/SearchInput";
import {
  ArrowLeft, Plus, X, Copy, Loader2, Save, FileText, Send,
  Dumbbell, Moon, Clock, ChevronDown,
} from "lucide-react";
import Link from "next/link";
import { cn } from "@/lib/utils";
import { SearchableSelect } from "@/components/shared/SearchableSelect";

const DAY_NAMES = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

interface DaySlot {
  workout_id: string | null;
  workout_name: string | null;
  is_rest_day: boolean;
}

type WeekSchedule = DaySlot[];

function emptyWeek(): WeekSchedule {
  return Array.from({ length: 7 }, () => ({ workout_id: null, workout_name: null, is_rest_day: false }));
}

export default function CreateProgramPage() {
  const router = useRouter();
  const { mutate: createProgram, isPending } = useCreateProgram();

  const [name, setName] = useState("");
  const [durationWeeks, setDurationWeeks] = useState(4);
  const [difficulty, setDifficulty] = useState("beginner");
  const [goal, setGoal] = useState("general_fitness");
  const [description, setDescription] = useState("");
  const [weeks, setWeeks] = useState<WeekSchedule[]>([emptyWeek()]);

  // Workout picker
  const [pickerOpen, setPickerOpen] = useState<{ week: number; day: number } | null>(null);
  const [workoutSearch, setWorkoutSearch] = useState("");
  const { data: workoutData } = useWorkouts({ limit: 50, search: workoutSearch });
  const workoutList = (workoutData?.data ?? []) as any[];

  // Ensure weeks array matches duration
  function setDuration(n: number) {
    setDurationWeeks(n);
    setWeeks((prev) => {
      if (prev.length < n) return [...prev, ...Array.from({ length: n - prev.length }, emptyWeek)];
      return prev.slice(0, n);
    });
  }

  function setSlot(weekIdx: number, dayIdx: number, slot: DaySlot) {
    setWeeks((prev) => prev.map((w, i) =>
      i === weekIdx ? w.map((d, j) => (j === dayIdx ? slot : d)) : w
    ));
  }

  function toggleRestDay(weekIdx: number, dayIdx: number) {
    setSlot(weekIdx, dayIdx, { workout_id: null, workout_name: null, is_rest_day: true });
  }

  function clearSlot(weekIdx: number, dayIdx: number) {
    setSlot(weekIdx, dayIdx, { workout_id: null, workout_name: null, is_rest_day: false });
  }

  function copyWeek(fromIdx: number) {
    setWeeks((prev) => prev.map((w, i) => (i === fromIdx + 1 ? [...prev[fromIdx]] : w)));
  }

  function pickWorkout(workout: any) {
    if (!pickerOpen) return;
    setSlot(pickerOpen.week, pickerOpen.day, {
      workout_id: workout.id,
      workout_name: workout.name,
      is_rest_day: false,
    });
    setPickerOpen(null);
  }

  function handleSubmit(isTemplate = false) {
    if (!name.trim()) return;
    const days: any[] = [];
    weeks.forEach((week, weekIdx) => {
      week.forEach((slot, dayIdx) => {
        if (slot.workout_id || slot.is_rest_day) {
          days.push({
            week_number: weekIdx + 1,
            day_of_week: dayIdx,
            workout_id: slot.workout_id || undefined,
            is_rest_day: slot.is_rest_day,
          });
        }
      });
    });

    createProgram(
      { name, description: description || undefined, duration_weeks: durationWeeks, difficulty, goal, is_template: isTemplate, days },
      { onSuccess: () => router.push("/programs") }
    );
  }

  return (
    <div className="space-y-5">
      <Link href="/programs" className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-slate-700">
        <ArrowLeft className="h-4 w-4" /> Back to Programs
      </Link>

      <h1 className="text-2xl font-bold text-slate-900">Create Program</h1>

      {/* Meta */}
      <div className="card p-5 grid grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="col-span-2">
          <label className="label">Program Name *</label>
          <input value={name} onChange={(e) => setName(e.target.value)} className="input" placeholder="e.g. Beginner Full Body" autoFocus />
        </div>
        <div>
          <label className="label">Duration (weeks)</label>
          <SearchableSelect
            options={Array.from({ length: 24 }, (_, i) => ({ value: String(i + 1), label: `${i + 1} week${i > 0 ? "s" : ""}` }))}
            value={String(durationWeeks)}
            onChange={(v) => setDuration(parseInt(v))}
            placeholder="Select duration..."
            searchPlaceholder="Search weeks..."
          />
        </div>
        <div>
          <label className="label">Difficulty</label>
          <SearchableSelect
            options={[{ value: "beginner", label: "Beginner" }, { value: "intermediate", label: "Intermediate" }, { value: "advanced", label: "Advanced" }]}
            value={difficulty}
            onChange={setDifficulty}
            placeholder="Select difficulty..."
          />
        </div>
        <div>
          <label className="label">Goal</label>
          <SearchableSelect
            options={[{ value: "general_fitness", label: "General Fitness" }, { value: "lose_weight", label: "Lose Weight" }, { value: "gain_muscle", label: "Gain Muscle" }, { value: "maintain", label: "Maintain" }]}
            value={goal}
            onChange={setGoal}
            placeholder="Select goal..."
          />
        </div>
        <div className="col-span-2 lg:col-span-3">
          <label className="label">Description</label>
          <input value={description} onChange={(e) => setDescription(e.target.value)} className="input" placeholder="Brief description (optional)" />
        </div>
      </div>

      {/* Calendar Grid */}
      <div className="space-y-4">
        {weeks.map((week, weekIdx) => (
          <div key={weekIdx} className="card overflow-hidden">
            <div className="px-4 py-2.5 bg-slate-50/50 border-b border-slate-100 flex items-center justify-between">
              <h3 className="text-sm font-semibold text-slate-700">Week {weekIdx + 1}</h3>
              {weekIdx < weeks.length - 1 && (
                <button onClick={() => copyWeek(weekIdx)} className="btn-ghost text-xs text-slate-500" title="Copy to next week">
                  <Copy className="h-3.5 w-3.5" /> Copy to Week {weekIdx + 2}
                </button>
              )}
            </div>
            <div className="grid grid-cols-7 divide-x divide-slate-50">
              {DAY_NAMES.map((day, dayIdx) => {
                const slot = week[dayIdx];
                return (
                  <div key={dayIdx} className="p-2 min-h-[100px] flex flex-col">
                    <p className="text-[10px] font-semibold text-slate-400 uppercase mb-2">{day}</p>

                    {slot.is_rest_day ? (
                      <div className="flex-1 flex flex-col items-center justify-center">
                        <div className="p-2 rounded-lg bg-slate-50 mb-1">
                          <Moon className="h-4 w-4 text-slate-300" />
                        </div>
                        <span className="text-[10px] text-slate-400">Rest Day</span>
                        <button onClick={() => clearSlot(weekIdx, dayIdx)} className="mt-1 text-[10px] text-slate-400 hover:text-rose-500">
                          Remove
                        </button>
                      </div>
                    ) : slot.workout_id ? (
                      <div className="flex-1">
                        <div className="p-2 rounded-lg bg-sf-iceBlue border border-sf-iceBlue group relative">
                          <p className="text-[11px] font-medium text-sf-deepNavy leading-tight">{slot.workout_name}</p>
                          <button
                            onClick={() => clearSlot(weekIdx, dayIdx)}
                            className="absolute -top-1.5 -right-1.5 h-4 w-4 rounded-full bg-rose-500 text-white
                                       flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity"
                          >
                            <X className="h-2.5 w-2.5" />
                          </button>
                        </div>
                      </div>
                    ) : (
                      <div className="flex-1 flex flex-col items-center justify-center gap-1">
                        <button
                          onClick={() => setPickerOpen({ week: weekIdx, day: dayIdx })}
                          className="p-2 rounded-lg border border-dashed border-slate-200 text-slate-300
                                     hover:border-sf-systemBlue/40 hover:text-sf-deepNavy hover:bg-sf-iceBlue transition-colors"
                        >
                          <Plus className="h-4 w-4" />
                        </button>
                        <button
                          onClick={() => toggleRestDay(weekIdx, dayIdx)}
                          className="text-[10px] text-slate-400 hover:text-slate-600"
                        >
                          Rest day
                        </button>
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          </div>
        ))}
      </div>

      {/* Bottom Actions */}
      <div className="card p-4 flex items-center justify-end gap-2">
        <button onClick={() => handleSubmit(true)} disabled={isPending || !name.trim()} className="btn-secondary">
          <FileText className="h-4 w-4" /> Save as Template
        </button>
        <button onClick={() => handleSubmit(false)} disabled={isPending || !name.trim()} className="btn-primary">
          {isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Send className="h-4 w-4" />}
          {isPending ? "Creating..." : "Create Program"}
        </button>
      </div>

      {/* Workout Picker Modal */}
      {pickerOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center" onClick={() => setPickerOpen(null)}>
          <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" />
          <div className="relative bg-white rounded-2xl shadow-xl max-w-md w-full mx-4 animate-slide-in max-h-[70vh] flex flex-col" onClick={(e) => e.stopPropagation()}>
            <div className="px-5 py-4 border-b border-slate-100 flex items-center justify-between shrink-0">
              <h3 className="text-sm font-semibold text-slate-700">
                Select Workout — Week {pickerOpen.week + 1}, {DAY_NAMES[pickerOpen.day]}
              </h3>
              <button onClick={() => setPickerOpen(null)} className="p-1 rounded-lg hover:bg-slate-100 text-slate-400">
                <X className="h-4 w-4" />
              </button>
            </div>
            <div className="px-4 py-2 border-b border-slate-100 shrink-0">
              <SearchInput value={workoutSearch} onChange={setWorkoutSearch} placeholder="Search workouts..." />
            </div>
            <div className="flex-1 overflow-y-auto p-2">
              {workoutList.length === 0 ? (
                <p className="text-sm text-slate-400 text-center py-8">No workouts found</p>
              ) : (
                workoutList.map((w: any) => (
                  <button
                    key={w.id}
                    onClick={() => pickWorkout(w)}
                    className="w-full flex items-center gap-3 px-3 py-2.5 rounded-lg hover:bg-sf-iceBlue transition-colors text-left"
                  >
                    <div className="h-9 w-9 rounded-lg bg-slate-50 flex items-center justify-center shrink-0">
                      <Dumbbell className="h-4 w-4 text-slate-300" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-slate-900 truncate">{w.name}</p>
                      <p className="text-xs text-slate-400 capitalize">{w.type}{w.estimated_duration_min ? ` · ${w.estimated_duration_min} min` : ""}</p>
                    </div>
                  </button>
                ))
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
