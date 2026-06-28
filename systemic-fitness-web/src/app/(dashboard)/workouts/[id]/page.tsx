"use client";

import { useWorkout, useDuplicateWorkout, useDeleteWorkout } from "@/hooks/useWorkouts";
import { ArrowLeft, Clock, Copy, Edit, Dumbbell, Trash2, Loader2 } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { cn } from "@/lib/utils";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { useState } from "react";

export default function WorkoutDetailPage({ params }: { params: { id: string } }) {
  const router = useRouter();
  const { data, isLoading } = useWorkout(params.id);
  const duplicateMutation = useDuplicateWorkout();
  const deleteMutation = useDeleteWorkout();
  const [deleteOpen, setDeleteOpen] = useState(false);
  const detail = data?.data as any;

  if (isLoading) return <WorkoutSkeleton />;
  if (!detail) return <p className="text-center text-slate-400 py-12">Sesi tidak ditemukan</p>;

  function handleDuplicate() {
    duplicateMutation.mutate(params.id, {
      onSuccess: () => router.push("/workouts"),
    });
  }

  function handleDelete() {
    deleteMutation.mutate(params.id, {
      onSuccess: () => router.push("/workouts"),
    });
  }

  return (
    <div className="space-y-6">
      <Link href="/workouts" className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-slate-700">
        <ArrowLeft className="h-4 w-4" /> Kembali ke Sesi
      </Link>

      <div className="card p-6 flex items-start justify-between">
        <div>
          <h1 className="text-xl font-bold text-slate-900">{detail.name}</h1>
          <div className="flex items-center gap-3 mt-2 text-sm text-slate-500">
            <span className="capitalize px-2 py-0.5 rounded-full bg-blue-100 text-blue-700 text-xs font-medium">{detail.type}</span>
            {detail.estimated_duration_min && (
              <span className="flex items-center gap-1"><Clock className="h-3.5 w-3.5" /> {detail.estimated_duration_min} min</span>
            )}
            <span>{detail.exercises?.length ?? 0} exercises</span>
          </div>
          {detail.description && <p className="mt-3 text-sm text-slate-600">{detail.description}</p>}
        </div>
        <div className="flex gap-2">
          <button
            className="btn-secondary"
            disabled={duplicateMutation.isPending}
            onClick={handleDuplicate}
          >
            {duplicateMutation.isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Copy className="h-4 w-4" />}
            Duplicate
          </button>
          <button className="btn-primary" onClick={() => router.push(`/workouts/create?edit=${params.id}`)}>
            <Edit className="h-4 w-4" /> Edit
          </button>
          <button className="btn-secondary text-rose-600 hover:bg-rose-50" onClick={() => setDeleteOpen(true)}>
            <Trash2 className="h-4 w-4" /> Delete
          </button>
        </div>
      </div>

      <ConfirmDialog
        open={deleteOpen}
        onClose={() => setDeleteOpen(false)}
        onConfirm={handleDelete}
        title="Hapus Sesi"
        description="Yakin ingin menghapus sesi ini? Tindakan ini tidak bisa dibatalkan."
        confirmLabel="Delete"
        variant="danger"
        loading={deleteMutation.isPending}
      />

      <div className="card overflow-hidden">
        <div className="px-4 py-3 bg-slate-50/50 border-b border-slate-100">
          <h3 className="text-sm font-semibold text-slate-700">Exercises</h3>
        </div>
        {detail.exercises?.length > 0 ? (
          <div className="divide-y divide-slate-50">
            {detail.exercises.map((ex: any, i: number) => (
              <div key={ex.id || i} className="px-4 py-3.5 flex items-center gap-4">
                <div className="w-8 h-8 rounded-lg bg-sf-iceBlue text-sf-deepNavy flex items-center justify-center text-xs font-bold shrink-0">
                  {ex.order_index + 1}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="font-medium text-slate-900 text-sm">{ex.exercise_name || "Exercise"}</p>
                  <p className="text-xs text-slate-400">
                    {[ex.sets && `${ex.sets} sets`, ex.reps && `${ex.reps} reps`, ex.rest_seconds && `${ex.rest_seconds}s rest`].filter(Boolean).join(" · ")}
                  </p>
                </div>
                {ex.superset_group != null && (
                  <span className="px-2 py-0.5 rounded-full bg-purple-100 text-purple-700 text-xs font-medium">SS {ex.superset_group}</span>
                )}
              </div>
            ))}
          </div>
        ) : (
          <div className="py-12 text-center text-sm text-slate-400">No exercises added yet</div>
        )}
      </div>
    </div>
  );
}

function WorkoutSkeleton() {
  return (
    <div className="space-y-6">
      <div className="skeleton h-4 w-28" />
      <div className="card p-6"><div className="skeleton h-6 w-48 mb-2" /><div className="skeleton h-4 w-64" /></div>
      <div className="card p-4 space-y-3">
        {Array.from({ length: 5 }).map((_, i) => <div key={i} className="skeleton h-12 w-full" />)}
      </div>
    </div>
  );
}
