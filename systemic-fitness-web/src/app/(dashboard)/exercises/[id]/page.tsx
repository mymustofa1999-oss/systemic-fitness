"use client";

import { useQuery } from "@tanstack/react-query";
import { apiGet } from "@/lib/api";
import { ArrowLeft, Play, Dumbbell } from "lucide-react";
import Link from "next/link";
import { cn } from "@/lib/utils";

export default function ExerciseDetailPage({ params }: { params: { id: string } }) {
  const { data, isLoading } = useQuery({
    queryKey: ["exercises", params.id],
    queryFn: () => apiGet(`/api/exercises/${params.id}`),
  });
  const ex = data?.data as any;

  if (isLoading) return <div className="space-y-4"><div className="skeleton h-4 w-24" /><div className="skeleton h-48 w-full" /></div>;
  if (!ex) return <p className="text-center text-slate-400 py-12">Exercise not found</p>;

  return (
    <div className="space-y-6">
      <Link href="/exercises" className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-slate-700">
        <ArrowLeft className="h-4 w-4" /> Back to Library
      </Link>

      <div className="card p-6">
        <div className="flex items-start justify-between">
          <div>
            <h1 className="text-xl font-bold text-slate-900">{ex.name}</h1>
            <div className="flex items-center gap-2 mt-2">
              {ex.muscle_group?.map((m: string) => (
                <span key={m} className="px-2 py-0.5 rounded-full bg-sf-iceBlue text-sf-deepNavy text-xs font-medium capitalize">{m}</span>
              ))}
              <span className={cn(
                "px-2 py-0.5 rounded-full text-xs font-medium capitalize",
                ex.difficulty === "beginner" ? "bg-emerald-100 text-emerald-700" :
                ex.difficulty === "intermediate" ? "bg-amber-100 text-amber-700" : "bg-rose-100 text-rose-700"
              )}>
                {ex.difficulty}
              </span>
            </div>
          </div>
          {ex.video_url && (
            <a href={ex.video_url} target="_blank" rel="noopener noreferrer" className="btn-secondary">
              <Play className="h-4 w-4" /> Watch Video
            </a>
          )}
        </div>
        {ex.description && <p className="mt-4 text-sm text-slate-600">{ex.description}</p>}
      </div>

      {ex.instructions?.length > 0 && (
        <div className="card p-6">
          <h3 className="text-sm font-semibold text-slate-700 mb-3">Instructions</h3>
          <ol className="space-y-2">
            {ex.instructions.map((step: string, i: number) => (
              <li key={i} className="flex items-start gap-3 text-sm text-slate-600">
                <span className="flex-none w-6 h-6 rounded-full bg-sf-iceBlue text-sf-deepNavy flex items-center justify-center text-xs font-bold">{i+1}</span>
                {step}
              </li>
            ))}
          </ol>
        </div>
      )}

      {ex.equipment && (
        <div className="card p-6">
          <h3 className="text-sm font-semibold text-slate-700 mb-2">Equipment</h3>
          <p className="text-sm text-slate-600 capitalize">{ex.equipment}</p>
        </div>
      )}
    </div>
  );
}
