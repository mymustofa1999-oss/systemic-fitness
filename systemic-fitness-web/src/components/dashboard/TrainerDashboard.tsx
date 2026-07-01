"use client";

import Link from "next/link";
import { useMemo } from "react";
import {
  Users, CalendarDays, Clock, ChevronRight, MapPin, ArrowRight, ArrowRightLeft,
} from "lucide-react";

import { useAuth } from "@/hooks/useAuth";
import { apiGet } from "@/lib/api";
import { useQuery } from "@tanstack/react-query";
import {
  useTrainingSessions,
  useTrainingSchedules,
  TrainingSession,
  TrainingSchedule,
} from "@/hooks/useTrainingSchedules";
import { cn, getInitials } from "@/lib/utils";

// ════════════════════════════════════════════════════════════════════
//  TrainerDashboard
//
//  Role-specific dashboard shown when the logged-in user is a trainer.
//  Two main widgets, both scoped to the trainer's own data:
//   1. My Clients   — grid of avatar cards (max 8) + link to /clients
//   2. This Week    — compact week grid + link to /scheduling/calendar
// ════════════════════════════════════════════════════════════════════

const DAY_NAMES_SHORT = ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"];

// ─── Date helpers (mirrored from scheduling/calendar/page.tsx) ──

function getMonday(d: Date): Date {
  const day = d.getDay();
  const diff = d.getDate() - day + (day === 0 ? -6 : 1);
  return new Date(d.getFullYear(), d.getMonth(), diff);
}
function addDays(d: Date, n: number): Date {
  return new Date(d.getFullYear(), d.getMonth(), d.getDate() + n);
}
function formatDate(d: Date): string {
  return d.toISOString().slice(0, 10);
}
function isToday(d: Date): boolean {
  const now = new Date();
  return (
    d.getFullYear() === now.getFullYear() &&
    d.getMonth() === now.getMonth() &&
    d.getDate() === now.getDate()
  );
}

interface ClientUser {
  id: string;
  full_name: string;
  email: string;
  avatar_url?: string | null;
  status: string;
}

// ─── Component ──────────────────────────────────────────────────

export function TrainerDashboard() {
  const { user } = useAuth();
  const trainerId = user?.id;

  // Compute current week range up front so all queries are consistent.
  const weekStart = useMemo(() => getMonday(new Date()), []);
  const weekDates = useMemo(
    () => Array.from({ length: 7 }, (_, i) => addDays(weekStart, i)),
    [weekStart],
  );
  const dateFrom = formatDate(weekDates[0]);
  const dateTo = formatDate(weekDates[6]);

  // ─── Clients (auto-scoped server-side for trainer role) ──
  const clientsQuery = useQuery({
    queryKey: ["clients", { limit: 100 }],
    queryFn: () => apiGet<ClientUser[]>("/api/clients", { limit: 100 }),
  });
  const allClients = (clientsQuery.data?.data ?? []) as ClientUser[];
  const clientCount = clientsQuery.data?.meta?.total ?? allClients.length;
  const visibleClients = allClients.slice(0, 8);

  // ─── Schedules + sessions (filter to this trainer) ──
  const sessionsQuery = useTrainingSessions({
    trainer_id: trainerId,
    date_from: dateFrom,
    date_to: dateTo,
    limit: 200,
  });
  const schedulesQuery = useTrainingSchedules({
    trainer_id: trainerId,
    active: "true",
    limit: 200,
  });

  // Build the same items-by-date map the calendar page uses, but
  // collapsed to a small visual. We unwrap the data inside the
  // useMemo so the dependency array stays referentially stable.
  const sessionsRaw = sessionsQuery.data?.data;
  const schedulesRaw = schedulesQuery.data?.data;
  const itemsByDate = useMemo(() => {
    const sessions = (sessionsRaw ?? []) as TrainingSession[];
    const schedules = (schedulesRaw ?? []) as TrainingSchedule[];

    const sessionKeys = new Set<string>();
    sessions.forEach((s) => {
      if (s.schedule_id) sessionKeys.add(`${s.session_date}|${s.schedule_id}`);
    });

    const map: Record<string, CalendarItem[]> = {};
    sessions.forEach((s) => {
      const date = s.session_date;
      if (!map[date]) map[date] = [];
      map[date].push({
        id: s.id,
        clientName: s.client_name || "Client",
        startTime: s.start_time,
        endTime: s.end_time,
        location: s.location,
        status: s.status,
        isSubstitute: s.is_substitute,
        source: "session",
      });
    });

    weekDates.forEach((date) => {
      const dow = date.getDay();
      const dateStr = formatDate(date);
      schedules
        .filter((sch) => sch.day_of_week === dow)
        .forEach((sch) => {
          if (sch.id && sessionKeys.has(`${dateStr}|${sch.id}`)) return;
          if (!map[dateStr]) map[dateStr] = [];
          map[dateStr].push({
            id: `sched-${sch.id}-${dateStr}`,
            clientName: sch.client_name || "Client",
            startTime: sch.start_time,
            endTime: sch.end_time,
            location: sch.location,
            status: "scheduled",
            isSubstitute: false,
            source: "schedule",
          });
        });
    });

    // Sort each day's items by start time.
    for (const k of Object.keys(map)) {
      map[k].sort((a, b) => a.startTime.localeCompare(b.startTime));
    }
    return map;
  }, [sessionsRaw, schedulesRaw, weekDates]);

  const todayStr = formatDate(new Date());
  const todayItems = itemsByDate[todayStr] ?? [];
  const totalThisWeek = Object.values(itemsByDate).reduce((sum, arr) => sum + arr.length, 0);

  const hour = new Date().getHours();
  const greeting = hour < 12 ? "Selamat pagi" : hour < 17 ? "Selamat siang" : "Selamat sore";

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-slate-900">
          {greeting}, {user?.name?.split(" ")[0] ?? "Coach"}
        </h1>
        <p className="text-sm text-slate-500 mt-1">
          Berikut ringkasan klien dan jadwal kamu minggu ini.
        </p>
      </div>

      {/* Stats row */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <StatCard
          icon={Users}
          label="Total Klien"
          value={clientCount}
          color="text-sf-deepNavy"
          bg="bg-sf-iceBlue"
        />
        <StatCard
          icon={CalendarDays}
          label="Sesi Minggu Ini"
          value={totalThisWeek}
          color="text-emerald-600"
          bg="bg-emerald-50"
        />
        <StatCard
          icon={Clock}
          label="Sesi Hari Ini"
          value={todayItems.length}
          color="text-amber-600"
          bg="bg-amber-50"
        />
      </div>

      {/* My Clients */}
      <div className="card overflow-hidden">
        <div className="px-5 py-4 border-b border-slate-100 flex items-center justify-between">
          <div>
            <h3 className="text-sm font-semibold text-slate-900">Klien Saya</h3>
            <p className="text-xs text-slate-500 mt-0.5">
              Klien yang ditugaskan ke kamu
            </p>
          </div>
          <Link
            href="/clients"
            className="text-xs text-sf-deepNavy hover:text-sf-deepNavy font-medium inline-flex items-center gap-0.5"
          >
            Lihat semua <ChevronRight className="h-3.5 w-3.5" />
          </Link>
        </div>

        {clientsQuery.isLoading ? (
          <div className="p-6 grid grid-cols-2 sm:grid-cols-4 gap-3">
            {Array.from({ length: 8 }).map((_, i) => (
              <div key={i} className="h-24 bg-slate-100 rounded-lg animate-pulse" />
            ))}
          </div>
        ) : visibleClients.length === 0 ? (
          <div className="p-10 text-center">
            <Users className="h-10 w-10 text-slate-300 mx-auto mb-2" />
            <p className="text-sm text-slate-500">Belum ada klien yang ditugaskan.</p>
            <p className="text-xs text-slate-400 mt-1">
              Hubungi admin untuk assign klien ke akun kamu.
            </p>
          </div>
        ) : (
          <div className="p-5 grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3">
            {visibleClients.map((c, i) => (
              <Link
                key={c.id}
                href={`/clients/${c.id}/training-card`}
                className="group relative flex flex-col items-center text-center p-4 rounded-xl border border-slate-100 hover:border-sf-systemBlue/40 hover:shadow-sm transition-all animate-fade-in"
                style={{ animationDelay: `${i * 50}ms` }}
              >
                <div className="h-14 w-14 rounded-full bg-sf-iceBlue text-sf-deepNavy flex items-center justify-center text-base font-bold mb-2 overflow-hidden">
                  {c.avatar_url ? (
                    // eslint-disable-next-line @next/next/no-img-element
                    <img src={c.avatar_url} alt={c.full_name} className="h-full w-full object-cover" />
                  ) : (
                    getInitials(c.full_name)
                  )}
                </div>
                <p className="text-sm font-medium text-slate-900 truncate w-full">
                  {c.full_name}
                </p>
                <span
                  className={cn(
                    "mt-1 inline-flex px-2 py-0.5 text-[10px] font-medium rounded-full",
                    c.status === "active"
                      ? "bg-emerald-50 text-emerald-700"
                      : "bg-slate-100 text-slate-500",
                  )}
                >
                  {c.status === "active" ? "Aktif" : c.status}
                </span>
              </Link>
            ))}
          </div>
        )}
      </div>

      {/* Needs Re-assessment Widget */}
      {(() => {
        const clientsNeedingReassessment = allClients.filter((c: any) => c.needs_reassessment);
        if (clientsNeedingReassessment.length === 0) return null;
        
        return (
          <div className="card overflow-hidden border-red-200">
            <div className="px-5 py-4 border-b border-red-100 bg-red-50 flex items-center justify-between">
              <div>
                <h3 className="text-sm font-semibold text-red-900">Perlu Re-assessment Bulanan</h3>
                <p className="text-xs text-red-600 mt-0.5">
                  Klien yang asesmen terakhirnya sudah lebih dari 30 hari.
                </p>
              </div>
            </div>
            <div className="divide-y divide-slate-50">
              {clientsNeedingReassessment.map((c) => (
                <div key={c.id} className="px-5 py-3 flex items-center justify-between hover:bg-slate-50 transition-colors">
                  <div className="flex items-center gap-3">
                    <div className="h-8 w-8 rounded-full bg-red-100 text-red-700 flex items-center justify-center text-xs font-bold">
                      {getInitials(c.full_name)}
                    </div>
                    <div>
                      <p className="text-sm font-medium text-slate-900">{c.full_name}</p>
                      <p className="text-xs text-slate-500">{c.email}</p>
                    </div>
                  </div>
                  <Link
                    href={`/clients/${c.id}`}
                    className="text-xs font-medium text-red-600 hover:text-red-700 bg-red-50 hover:bg-red-100 px-3 py-1.5 rounded-lg transition-colors"
                  >
                    Lihat Profil
                  </Link>
                </div>
              ))}
            </div>
          </div>
        );
      })()}

      {/* Compact week schedule */}
      <div className="card overflow-hidden">
        <div className="px-5 py-4 border-b border-slate-100 flex items-center justify-between">
          <div>
            <h3 className="text-sm font-semibold text-slate-900">Jadwal Minggu Ini</h3>
            <p className="text-xs text-slate-500 mt-0.5">
              {weekDates[0].toLocaleDateString("id-ID", { day: "numeric", month: "long" })} -{" "}
              {weekDates[6].toLocaleDateString("id-ID", {
                day: "numeric",
                month: "long",
                year: "numeric",
              })}
            </p>
          </div>
          <Link
            href="/scheduling/calendar"
            className="text-xs text-sf-deepNavy hover:text-sf-deepNavy font-medium inline-flex items-center gap-0.5"
          >
            Lihat calendar lengkap <ArrowRight className="h-3.5 w-3.5" />
          </Link>
        </div>

        {sessionsQuery.isLoading || schedulesQuery.isLoading ? (
          <div className="p-6 grid grid-cols-7 gap-2">
            {Array.from({ length: 7 }).map((_, i) => (
              <div key={i} className="h-32 bg-slate-100 rounded-lg animate-pulse" />
            ))}
          </div>
        ) : (
          <div className="p-5 grid grid-cols-7 gap-2">
            {weekDates.map((date) => {
              const dateStr = formatDate(date);
              const items = itemsByDate[dateStr] ?? [];
              const today = isToday(date);
              return (
                <div
                  key={dateStr}
                  className={cn(
                    "rounded-lg border min-h-[120px] flex flex-col",
                    today ? "border-sf-systemBlue bg-sf-iceBlue/40" : "border-slate-100",
                  )}
                >
                  <div
                    className={cn(
                      "px-2 pt-2 text-center",
                      today ? "text-sf-deepNavy" : "text-slate-500",
                    )}
                  >
                    <p className="text-[10px] font-medium uppercase">
                      {DAY_NAMES_SHORT[date.getDay()]}
                    </p>
                    <p
                      className={cn(
                        "text-lg font-bold leading-none mt-0.5",
                        today ? "text-sf-deepNavy" : "text-slate-900",
                      )}
                    >
                      {date.getDate()}
                    </p>
                  </div>
                  <div className="flex-1 p-1.5 space-y-1">
                    {items.length === 0 ? (
                      <div className="h-full flex items-center justify-center">
                        <span className="text-[10px] text-slate-300">—</span>
                      </div>
                    ) : (
                      items.slice(0, 3).map((it) => (
                        <div
                          key={it.id}
                          className={cn(
                            "px-1.5 py-1 rounded text-[10px] font-medium truncate leading-tight border",
                            itemColor(it),
                          )}
                          title={`${it.startTime.slice(0, 5)} ${it.clientName}`}
                        >
                          <div className="flex items-center gap-0.5">
                            <span className="font-bold">{it.startTime.slice(0, 5)}</span>
                            {it.isSubstitute && (
                              <ArrowRightLeft className="h-2 w-2" />
                            )}
                          </div>
                          <div className="truncate opacity-90">{it.clientName}</div>
                        </div>
                      ))
                    )}
                    {items.length > 3 && (
                      <p className="text-[9px] text-center text-slate-400 font-medium">
                        +{items.length - 3} lagi
                      </p>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* Today's sessions detail */}
      <div className="card overflow-hidden">
        <div className="px-5 py-4 border-b border-slate-100">
          <h3 className="text-sm font-semibold text-slate-900">
            Sesi Hari Ini ({todayItems.length})
          </h3>
        </div>
        <div className="divide-y divide-slate-50">
          {todayItems.length === 0 ? (
            <div className="px-5 py-8 text-center">
              <CalendarDays className="h-10 w-10 text-slate-300 mx-auto mb-2" />
              <p className="text-sm text-slate-500">Tidak ada sesi hari ini.</p>
              <p className="text-xs text-slate-400 mt-1">Nikmati hari yang lebih santai!</p>
            </div>
          ) : (
            todayItems.map((it, i) => (
              <div
                key={it.id}
                className="px-5 py-3 flex items-center gap-3 hover:bg-slate-50/50 transition-colors animate-fade-in"
                style={{ animationDelay: `${i * 50}ms` }}
              >
                <div
                  className={cn(
                    "w-1 h-12 rounded-full shrink-0",
                    itemColor(it).split(" ")[0],
                  )}
                />
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-slate-900 truncate">
                    {it.clientName}
                    {it.isSubstitute && (
                      <span className="text-xs text-amber-600 ml-1">(pengganti)</span>
                    )}
                    {it.source === "schedule" && (
                      <span className="text-xs text-indigo-500 ml-1">(jadwal rutin)</span>
                    )}
                  </p>
                  <div className="flex items-center gap-3 text-xs text-slate-500 mt-0.5">
                    <span className="flex items-center gap-1">
                      <Clock className="h-3 w-3" />
                      {it.startTime.slice(0, 5)} - {it.endTime.slice(0, 5)}
                    </span>
                    {it.location && (
                      <span className="flex items-center gap-1">
                        <MapPin className="h-3 w-3" />
                        {it.location}
                      </span>
                    )}
                  </div>
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
}

// ─── Sub-types & helpers ───────────────────────────────────────

interface CalendarItem {
  id: string;
  clientName: string;
  startTime: string;
  endTime: string;
  location: string | null;
  status: string;
  isSubstitute: boolean;
  source: "session" | "schedule";
}

function itemColor(item: CalendarItem): string {
  if (item.isSubstitute) return "bg-amber-100 border-amber-300 text-amber-800";
  if (item.source === "schedule") return "bg-indigo-100 border-indigo-300 text-indigo-800";
  switch (item.status) {
    case "completed":
      return "bg-emerald-100 border-emerald-300 text-emerald-800";
    case "cancelled":
      return "bg-rose-100 border-rose-300 text-rose-700";
    case "substituted":
      return "bg-amber-100 border-amber-300 text-amber-800";
    default:
      return "bg-sf-iceBlue border-sf-systemBlue/40 text-sf-deepNavy";
  }
}

// ─── Tiny stat card ────────────────────────────────────────────

function StatCard({
  icon: Icon,
  label,
  value,
  color,
  bg,
}: {
  icon: typeof Users;
  label: string;
  value: number;
  color: string;
  bg: string;
}) {
  return (
    <div className="card p-5 flex items-center gap-4">
      <div className={cn("p-3 rounded-xl", bg)}>
        <Icon className={cn("h-6 w-6", color)} />
      </div>
      <div>
        <p className="text-xs text-slate-500 font-medium uppercase tracking-wide">{label}</p>
        <p className="text-2xl font-bold text-slate-900 mt-0.5">{value}</p>
      </div>
    </div>
  );
}
