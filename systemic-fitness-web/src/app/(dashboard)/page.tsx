"use client";

import { useQuery } from "@tanstack/react-query";
import { apiGet } from "@/lib/api";
import { StatsCard, StatsCardSkeleton } from "@/components/shared/StatsCard";
import { RevenueChartSkeleton, EngagementChartSkeleton } from "@/components/charts/ChartSkeletons";
import dynamic from "next/dynamic";

const RevenueChart = dynamic(
  () => import("@/components/charts/RevenueChart").then((mod) => mod.RevenueChart),
  { ssr: false, loading: () => <RevenueChartSkeleton /> }
);

const EngagementChart = dynamic(
  () => import("@/components/charts/EngagementChart").then((mod) => mod.EngagementChart),
  { ssr: false, loading: () => <EngagementChartSkeleton /> }
);
import {
  Users, Activity, DollarSign, Dumbbell,
  Clock, Trophy, TrendingUp, ChevronRight,
} from "lucide-react";
import { cn, formatCurrency, formatRelative, getInitials } from "@/lib/utils";
import { useAuth } from "@/hooks/useAuth";
import { TrainerDashboard } from "@/components/dashboard/TrainerDashboard";

// ── Mock data (replaced by real API data once backend returns it) ─

const mockRevenueData = [
  { month: "2025-04", revenue: 12500000 },
  { month: "2025-05", revenue: 18200000 },
  { month: "2025-06", revenue: 15800000 },
  { month: "2025-07", revenue: 22100000 },
  { month: "2025-08", revenue: 24500000 },
  { month: "2025-09", revenue: 19800000 },
  { month: "2025-10", revenue: 27300000 },
  { month: "2025-11", revenue: 31200000 },
  { month: "2025-12", revenue: 28900000 },
  { month: "2026-01", revenue: 35100000 },
  { month: "2026-02", revenue: 33400000 },
  { month: "2026-03", revenue: 38700000 },
];

const mockEngagementData = [
  { label: "Week 1", dau: 120, wau: 340, mau: 890 },
  { label: "Week 2", dau: 145, wau: 380, mau: 920 },
  { label: "Week 3", dau: 132, wau: 360, mau: 905 },
  { label: "Week 4", dau: 168, wau: 410, mau: 960 },
];

const mockActivity = [
  { id: "1", user: "Rina Wijaya", action: "completed Week 3 of Intermediate PPL", time: new Date(Date.now() - 25 * 60000).toISOString(), type: "program" as const },
  { id: "2", user: "Budi Santoso", action: "logged Chest & Triceps workout", time: new Date(Date.now() - 2 * 3600000).toISOString(), type: "workout" as const },
  { id: "3", user: "Sarah Chen", action: "reached 50 workout milestone 🎉", time: new Date(Date.now() - 4 * 3600000).toISOString(), type: "milestone" as const },
  { id: "4", user: "Ahmad Fadli", action: "logged body metrics: 78.5 kg", time: new Date(Date.now() - 6 * 3600000).toISOString(), type: "metric" as const },
  { id: "5", user: "Dewi Lestari", action: "was assigned to Beginner Full Body", time: new Date(Date.now() - 8 * 3600000).toISOString(), type: "program" as const },
  { id: "6", user: "Reza Pratama", action: "set new PR: Bench Press 100kg", time: new Date(Date.now() - 12 * 3600000).toISOString(), type: "milestone" as const },
];

const mockTrainers = [
  { id: "1", name: "Andi", clients: 24, active: 21, completion: 87 },
  { id: "2", name: "Maya", clients: 18, active: 16, completion: 92 },
  { id: "3", name: "Riko", clients: 15, active: 12, completion: 78 },
  { id: "4", name: "Sari", clients: 12, active: 11, completion: 95 },
];

const activityIcons = {
  program:   { icon: Dumbbell,   color: "bg-sf-iceBlue text-sf-deepNavy" },
  workout:   { icon: Activity,    color: "bg-emerald-100 text-emerald-600" },
  milestone: { icon: Trophy,      color: "bg-amber-100 text-amber-600" },
  metric:    { icon: TrendingUp,  color: "bg-blue-100 text-blue-600" },
};

export default function DashboardPage() {
  const { isTrainer } = useAuth();

  // Trainers get a dedicated, role-specific dashboard with their own
  // clients and schedule. Admin/owner/finance keep the platform overview
  // (AdminDashboardView below).
  if (isTrainer) {
    return <TrainerDashboard />;
  }
  return <AdminDashboardView />;
}

function AdminDashboardView() {
  const { user } = useAuth();

  const { data: overviewData, isLoading: overviewLoading } = useQuery({
    queryKey: ["dashboard", "overview"],
    queryFn: () => apiGet("/api/dashboard/overview"),
  });

  const { data: revenueData, isLoading: revenueLoading } = useQuery({
    queryKey: ["dashboard", "revenue"],
    queryFn: () => apiGet("/api/dashboard/revenue", { months: 12 }),
  });

  const stats = overviewData?.data as any;
  const revenueChartRaw = revenueData?.data as any;
  const revenueChart = Array.isArray(revenueChartRaw) ? revenueChartRaw : (revenueChartRaw?.data ?? mockRevenueData);

  const hour = new Date().getHours();
  const greeting = hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : "Good evening";

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-slate-900">
          {greeting}, {user?.name?.split(" ")[0] ?? "there"}
        </h1>
        <p className="text-sm text-slate-500 mt-1">
          Here&apos;s what&apos;s happening with your platform today.
        </p>
      </div>

      {/* Row 1: Stats Cards — staggered mount animation */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        {overviewLoading ? (
          Array.from({ length: 4 }).map((_, i) => <StatsCardSkeleton key={i} />)
        ) : (
          [
            { label: "Total Users", value: stats?.total_users?.toLocaleString() ?? "0", change: stats?.total_users_change, icon: Users, color: "text-sf-deepNavy" },
            { label: "Active Users (7d)", value: stats?.active_users_7d?.toLocaleString() ?? "0", change: stats?.active_users_change, icon: Activity, color: "text-emerald-600" },
            { label: "Revenue (30d)", value: formatCurrency(stats?.revenue_30d ?? 0), change: stats?.revenue_change, icon: DollarSign, color: "text-blue-600" },
            { label: "Active Programs", value: stats?.active_subscriptions?.toLocaleString() ?? "0", change: stats?.subscriptions_change, icon: Dumbbell, color: "text-purple-600" },
          ].map((s, i) => (
            <div key={s.label} className="animate-fade-in" style={{ animationDelay: `${i * 75}ms` }}>
              <StatsCard label={s.label} value={s.value} change={s.change} icon={s.icon} iconColor={s.color} />
            </div>
          ))
        )}
      </div>

      {/* Row 2: Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="card p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-sm font-semibold text-slate-700">Revenue Trend</h3>
            <span className="text-xs text-slate-400">Last 12 months</span>
          </div>
          {revenueLoading ? <RevenueChartSkeleton /> : <RevenueChart data={revenueChart} />}
        </div>
        <div className="card p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-sm font-semibold text-slate-700">User Engagement</h3>
            <span className="text-xs text-slate-400">This month</span>
          </div>
          <EngagementChart data={mockEngagementData} />
        </div>
      </div>

      {/* Row 3: Activity Feed + Trainer Leaderboard */}
      <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
        {/* Activity Feed — 3 cols */}
        <div className="lg:col-span-3 card overflow-hidden">
          <div className="px-5 py-4 border-b border-slate-100 flex items-center justify-between">
            <h3 className="text-sm font-semibold text-slate-700">Recent Activity</h3>
            <button className="text-xs text-sf-deepNavy hover:text-sf-deepNavy font-medium inline-flex items-center gap-0.5">
              View all <ChevronRight className="h-3.5 w-3.5" />
            </button>
          </div>
          <div className="divide-y divide-slate-50">
            {mockActivity.map((item, i) => {
              const cfg = activityIcons[item.type];
              const Icon = cfg.icon;
              return (
                <div
                  key={item.id}
                  className="px-5 py-3.5 flex items-start gap-3 hover:bg-slate-50/50 transition-colors animate-fade-in"
                  style={{ animationDelay: `${i * 50}ms` }}
                >
                  <div className={cn("p-2 rounded-lg shrink-0", cfg.color)}>
                    <Icon className="h-3.5 w-3.5" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm text-slate-700">
                      <span className="font-medium text-slate-900">{item.user}</span>{" "}
                      {item.action}
                    </p>
                    <p className="text-xs text-slate-400 mt-0.5 flex items-center gap-1">
                      <Clock className="h-3 w-3" />
                      {formatRelative(item.time)}
                    </p>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Trainer Leaderboard — 2 cols */}
        <div className="lg:col-span-2 card overflow-hidden">
          <div className="px-5 py-4 border-b border-slate-100">
            <h3 className="text-sm font-semibold text-slate-700">Top Certified Trainers</h3>
          </div>
          <div className="divide-y divide-slate-50">
            {mockTrainers.map((t, i) => (
              <div
                key={t.id}
                className="px-5 py-3.5 flex items-center gap-3 hover:bg-slate-50/50 transition-colors animate-fade-in"
                style={{ animationDelay: `${i * 75}ms` }}
              >
                <span className={cn(
                  "w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold shrink-0",
                  i === 0 ? "bg-amber-100 text-amber-700" :
                  i === 1 ? "bg-slate-200 text-slate-600" :
                  i === 2 ? "bg-orange-100 text-orange-700" :
                  "bg-slate-100 text-slate-400"
                )}>
                  {i + 1}
                </span>
                <div className="h-9 w-9 rounded-full bg-sf-iceBlue text-sf-deepNavy flex items-center justify-center text-xs font-bold shrink-0">
                  {getInitials(t.name)}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-slate-900">{t.name}</p>
                  <p className="text-xs text-slate-400">{t.active}/{t.clients} active clients</p>
                </div>
                <div className="w-24 shrink-0">
                  <p className="text-xs font-mono font-medium text-slate-700 text-right mb-1">{t.completion}%</p>
                  <div className="h-1.5 bg-slate-100 rounded-full overflow-hidden">
                    <div
                      className={cn(
                        "h-full rounded-full transition-all duration-1000 ease-out",
                        t.completion >= 90 ? "bg-emerald-500" :
                        t.completion >= 80 ? "bg-sf-deepNavy" : "bg-amber-500"
                      )}
                      style={{ width: `${t.completion}%` }}
                    />
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
