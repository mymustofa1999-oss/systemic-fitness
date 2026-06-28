"use client";

import { useState, useMemo } from "react";
import { useQuery } from "@tanstack/react-query";
import { apiGet } from "@/lib/api";
import {
  LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid,
  Tooltip, ResponsiveContainer,
} from "recharts";
import {
  ArrowLeft, Flame, Dumbbell, TrendingUp, Scale,
  Calendar, Target, Camera,
} from "lucide-react";
import Link from "next/link";
import { cn, formatDate, getInitials } from "@/lib/utils";
import { SearchableSelect } from "@/components/shared/SearchableSelect";

// ── Heatmap ─────────────────────────────────────────────────────

function buildHeatmap(logs: any[]): { date: string; count: number }[] {
  const counts: Record<string, number> = {};
  logs.forEach((l: any) => {
    const d = new Date(l.logged_at).toISOString().split("T")[0];
    counts[d] = (counts[d] || 0) + 1;
  });
  const out: { date: string; count: number }[] = [];
  const today = new Date();
  for (let i = 364; i >= 0; i--) {
    const d = new Date(today); d.setDate(d.getDate() - i);
    const k = d.toISOString().split("T")[0];
    out.push({ date: k, count: counts[k] || 0 });
  }
  return out;
}

const heatColors = ["bg-slate-100", "bg-emerald-200", "bg-emerald-400", "bg-emerald-600", "bg-emerald-800"];

// ── Page ────────────────────────────────────────────────────────

export default function ProgressPage({ params }: { params: { userId: string } }) {
  const uid = params.userId;
  const [exFilter, setExFilter] = useState("");

  const { data: userData } = useQuery({ queryKey: ["users", uid], queryFn: () => apiGet(`/api/users/${uid}`) });
  const user = (userData?.data as any)?.user;
  const stats = (userData?.data as any)?.stats;

  const { data: histData, isLoading } = useQuery({
    queryKey: ["progress", uid, "all"], queryFn: () => apiGet(`/api/progress/user/${uid}`, { limit: 500 }),
  });
  const allLogs = ((histData?.data as any)?.entries ?? histData?.data ?? []) as any[];

  const { data: chartData } = useQuery({
    queryKey: ["progress", uid, "charts", exFilter],
    queryFn: () => apiGet(`/api/progress/user/${uid}/charts`, { exercise_id: exFilter || undefined }),
  });
  const chartEx = ((chartData?.data as any)?.exercises ?? []) as any[];

  const { data: metData } = useQuery({
    queryKey: ["body-metrics", uid], queryFn: () => apiGet(`/api/progress/user/${uid}/body-metrics`, { limit: 50 }),
  });
  const metrics = ((metData?.data as any)?.entries ?? metData?.data ?? []) as any[];

  const heatmap = useMemo(() => buildHeatmap(allLogs), [allLogs]);

  const weightData = metrics.filter((m: any) => m.weight_kg)
    .map((m: any) => ({ date: formatDate(m.logged_at), weight: m.weight_kg, bf: m.body_fat_pct })).reverse();

  const exOptions = useMemo(() => {
    const m = new Map<string, string>();
    allLogs.forEach((l: any) => { if (l.exercise_id && l.exercise_name) m.set(l.exercise_id, l.exercise_name); });
    return Array.from(m.entries()).map(([id, name]) => ({ id, name }));
  }, [allLogs]);

  return (
    <div className="space-y-6">
      <Link href="/progress" className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-slate-700">
        <ArrowLeft className="h-4 w-4" /> Back to Progress
      </Link>

      {/* Client Header */}
      <div className="card p-5 flex items-center gap-5">
        <div className="h-14 w-14 rounded-2xl bg-sf-iceBlue text-sf-deepNavy flex items-center justify-center text-lg font-bold shrink-0">
          {getInitials(user?.full_name ?? "?")}
        </div>
        <div className="flex-1"><h1 className="text-lg font-bold text-slate-900">{user?.full_name ?? "…"}</h1><p className="text-sm text-slate-500">{user?.email}</p></div>
        <div className="hidden md:flex gap-6">
          {[
            { icon: Dumbbell, l: "Sesi", v: stats?.total_workouts ?? 0 },
            { icon: Flame, l: "Streak", v: `${stats?.current_streak_days ?? 0}d` },
            { icon: Target, l: "Program", v: stats?.active_program_name ?? "None" },
          ].map((s) => (
            <div key={s.l} className="text-center"><s.icon className="h-4 w-4 text-slate-400 mx-auto mb-1" /><p className="text-sm font-bold text-slate-900">{s.v}</p><p className="text-[10px] text-slate-400">{s.l}</p></div>
          ))}
        </div>
      </div>

      {/* Body Metrics */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="card p-5">
          <div className="flex items-center gap-2 mb-4"><Scale className="h-4 w-4 text-slate-400" /><h3 className="text-sm font-semibold text-slate-700">Weight Trend</h3></div>
          {weightData.length < 2 ? <div className="h-48 flex items-center justify-center text-sm text-slate-400">Not enough data</div> : (
            <ResponsiveContainer width="100%" height={192}>
              <LineChart data={weightData} margin={{ top: 5, right: 5, left: -20, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#F1F5F9" vertical={false} />
                <XAxis dataKey="date" tick={{ fontSize: 10, fill: "#94A3B8" }} axisLine={false} tickLine={false} />
                <YAxis tick={{ fontSize: 10, fill: "#94A3B8" }} axisLine={false} tickLine={false} domain={["dataMin - 2", "dataMax + 2"]} />
                <Tooltip contentStyle={{ borderRadius: "12px", border: "1px solid #E2E8F0", fontSize: "12px" }} />
                <Line type="monotone" dataKey="weight" stroke="#4F46E5" strokeWidth={2} dot={{ r: 3 }} name="Weight (kg)" />
              </LineChart>
            </ResponsiveContainer>
          )}
        </div>
        <div className="card p-5">
          <div className="flex items-center gap-2 mb-4"><Camera className="h-4 w-4 text-slate-400" /><h3 className="text-sm font-semibold text-slate-700">Body Fat Trend</h3></div>
          {weightData.some((d) => d.bf) ? (
            <ResponsiveContainer width="100%" height={192}>
              <LineChart data={weightData.filter((d) => d.bf)} margin={{ top: 5, right: 5, left: -20, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#F1F5F9" vertical={false} />
                <XAxis dataKey="date" tick={{ fontSize: 10, fill: "#94A3B8" }} axisLine={false} tickLine={false} />
                <YAxis tick={{ fontSize: 10, fill: "#94A3B8" }} axisLine={false} tickLine={false} unit="%" />
                <Tooltip contentStyle={{ borderRadius: "12px", border: "1px solid #E2E8F0", fontSize: "12px" }} />
                <Line type="monotone" dataKey="bf" stroke="#10B981" strokeWidth={2} dot={{ r: 3 }} name="Body Fat %" />
              </LineChart>
            </ResponsiveContainer>
          ) : <div className="h-48 flex items-center justify-center text-sm text-slate-400">No body fat data</div>}
        </div>
      </div>

      {/* Workout Progress Charts */}
      <div className="card p-5">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2"><TrendingUp className="h-4 w-4 text-slate-400" /><h3 className="text-sm font-semibold text-slate-700">Progres Sesi</h3></div>
          <SearchableSelect
            options={[{ value: "", label: "All Exercises" }, ...exOptions.map((e: any) => ({ value: e.id, label: e.name }))]}
            value={exFilter}
            onChange={setExFilter}
            placeholder="All Exercises"
            searchPlaceholder="Search exercises..."
            className="w-56"
          />
        </div>
        {chartEx.length === 0 ? <div className="h-48 flex items-center justify-center text-sm text-slate-400">No progress data</div> : (
          <div className="space-y-6">
            {chartEx.slice(0, 4).map((ex: any) => (
              <div key={ex.exercise_id}>
                <p className="text-xs font-medium text-slate-600 mb-2">{ex.exercise_name}</p>
                <ResponsiveContainer width="100%" height={140}>
                  <BarChart data={ex.data} margin={{ top: 5, right: 5, left: -20, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#F1F5F9" vertical={false} />
                    <XAxis dataKey="date" tick={{ fontSize: 9, fill: "#94A3B8" }} axisLine={false} tickLine={false} />
                    <YAxis tick={{ fontSize: 9, fill: "#94A3B8" }} axisLine={false} tickLine={false} />
                    <Tooltip contentStyle={{ borderRadius: "12px", border: "1px solid #E2E8F0", fontSize: "12px" }} />
                    <Bar dataKey="total_volume" name="Volume" fill="#4F46E5" radius={[3, 3, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Recent Logs */}
      <div className="card overflow-hidden">
        <div className="px-5 py-3 border-b border-slate-100"><h3 className="text-sm font-semibold text-slate-700">Recent Logs</h3></div>
        {isLoading ? <div className="p-4 space-y-3">{Array.from({ length: 5 }).map((_, i) => <div key={i} className="skeleton h-10 w-full" />)}</div>
        : allLogs.length === 0 ? <div className="py-12 text-center text-sm text-slate-400">No logs yet</div>
        : <div className="divide-y divide-slate-50 max-h-80 overflow-y-auto">{allLogs.slice(0, 20).map((l: any) => (
            <div key={l.id} className="px-5 py-3 flex items-center gap-4">
              <div className="h-8 w-8 rounded-lg bg-sf-iceBlue flex items-center justify-center shrink-0"><Dumbbell className="h-3.5 w-3.5 text-sf-deepNavy" /></div>
              <div className="flex-1 min-w-0"><p className="text-sm font-medium text-slate-900">{l.exercise_name ?? "Exercise"}</p><p className="text-xs text-slate-400">{formatDate(l.logged_at)}</p></div>
              {l.mood && <span className="text-xs capitalize text-slate-500 px-2 py-0.5 rounded-full bg-slate-50">{l.mood}</span>}
            </div>
          ))}</div>}
      </div>

      {/* Heatmap */}
      <div className="card p-5">
        <div className="flex items-center gap-2 mb-4"><Calendar className="h-4 w-4 text-slate-400" /><h3 className="text-sm font-semibold text-slate-700">Consistency (365 days)</h3></div>
        <div className="overflow-x-auto pb-2">
          <div className="flex gap-[3px]" style={{ minWidth: "720px" }}>
            {Array.from({ length: 53 }).map((_, wi) => (
              <div key={wi} className="flex flex-col gap-[3px]">
                {Array.from({ length: 7 }).map((_, di) => {
                  const idx = wi * 7 + di;
                  if (idx >= heatmap.length) return <div key={di} className="w-[11px] h-[11px]" />;
                  const d = heatmap[idx];
                  const lv = d.count === 0 ? 0 : d.count === 1 ? 1 : d.count <= 3 ? 2 : d.count <= 5 ? 3 : 4;
                  return <div key={di} className={cn("w-[11px] h-[11px] rounded-sm", heatColors[lv])} title={`${d.date}: ${d.count}`} />;
                })}
              </div>
            ))}
          </div>
        </div>
        <div className="flex items-center gap-2 mt-2 justify-end">
          <span className="text-[10px] text-slate-400">Less</span>
          {heatColors.map((c, i) => <div key={i} className={cn("w-[11px] h-[11px] rounded-sm", c)} />)}
          <span className="text-[10px] text-slate-400">More</span>
        </div>
      </div>
    </div>
  );
}
