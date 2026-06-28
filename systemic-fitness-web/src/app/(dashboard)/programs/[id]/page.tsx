"use client";

import { useQuery } from "@tanstack/react-query";
import { apiGet } from "@/lib/api";
import { ArrowLeft, Users, Calendar } from "lucide-react";
import Link from "next/link";

const dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

export default function ProgramDetailPage({ params }: { params: { id: string } }) {
  const { data, isLoading } = useQuery({
    queryKey: ["programs", params.id],
    queryFn: () => apiGet(`/api/programs/${params.id}`),
  });
  const detail = data?.data as any;

  if (isLoading) return <div className="space-y-4"><div className="skeleton h-4 w-24" /><div className="skeleton h-64 w-full" /></div>;
  if (!detail) return <p className="text-center text-slate-400 py-12">Program not found</p>;

  // Group days by week
  const weeks = new Map<number, any[]>();
  (detail.days ?? []).forEach((d: any) => {
    if (!weeks.has(d.week_number)) weeks.set(d.week_number, []);
    weeks.get(d.week_number)!.push(d);
  });

  return (
    <div className="space-y-6">
      <Link href="/programs" className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-slate-700">
        <ArrowLeft className="h-4 w-4" /> Back to Programs
      </Link>

      <div className="card p-6 flex items-start justify-between">
        <div>
          <h1 className="text-xl font-bold text-slate-900">{detail.name}</h1>
          <p className="text-sm text-slate-500 mt-1">{detail.duration_weeks} weeks · {detail.difficulty} · {detail.goal?.replace(/_/g, " ")}</p>
          {detail.description && <p className="mt-3 text-sm text-slate-600">{detail.description}</p>}
        </div>
        <Link href={`/programs/${params.id}/assign`} className="btn-primary">
          <Users className="h-4 w-4" /> Assign Clients
        </Link>
      </div>

      {/* Weekly Schedule */}
      <div className="space-y-4">
        {Array.from(weeks.entries()).map(([weekNum, days]) => (
          <div key={weekNum} className="card overflow-hidden">
            <div className="px-4 py-2.5 bg-slate-50/50 border-b border-slate-100">
              <h3 className="text-sm font-semibold text-slate-700">Week {weekNum}</h3>
            </div>
            <div className="grid grid-cols-7 divide-x divide-slate-50">
              {Array.from({ length: 7 }).map((_, dow) => {
                const day = days.find((d: any) => d.day_of_week === dow);
                return (
                  <div key={dow} className="p-3 min-h-[80px]">
                    <p className="text-xs font-medium text-slate-400 mb-2">{dayNames[dow]}</p>
                    {day?.is_rest_day ? (
                      <p className="text-xs text-slate-300 italic">Rest</p>
                    ) : day?.workout_name ? (
                      <p className="text-xs font-medium text-sf-deepNavy bg-sf-iceBlue px-2 py-1 rounded">{day.workout_name}</p>
                    ) : (
                      <p className="text-xs text-slate-200">—</p>
                    )}
                  </div>
                );
              })}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
