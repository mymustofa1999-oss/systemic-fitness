"use client";

import { useEffect, useMemo, useState } from "react";
import {
  TrendingUp,
  Flame,
  Clock,
  CalendarDays,
  Dumbbell,
  Bell,
  Loader2,
  Check,
} from "lucide-react";
import {
  useWorkoutSessions,
  useWorkoutStats,
  useWorkoutReminder,
  useSaveWorkoutReminder,
  type WorkoutSessionLog,
} from "@/hooks/useWorkout";

const DAY_LABELS = ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"];

function formatDuration(totalSeconds: number): string {
  const m = Math.floor(totalSeconds / 60);
  const h = Math.floor(m / 60);
  const rem = m % 60;
  if (h > 0) return `${h}j ${rem}m`;
  return `${m} mnt`;
}

function formatDate(iso: string): string {
  try {
    return new Intl.DateTimeFormat("id-ID", {
      day: "2-digit",
      month: "short",
      year: "numeric",
    }).format(new Date(iso));
  } catch {
    return iso;
  }
}

function formatTime(iso: string): string {
  try {
    return new Intl.DateTimeFormat("id-ID", {
      hour: "2-digit",
      minute: "2-digit",
    }).format(new Date(iso));
  } catch {
    return "";
  }
}

function StatCard({
  icon,
  value,
  label,
}: {
  icon: React.ReactNode;
  value: string;
  label: string;
}) {
  return (
    <div className="card p-3 flex flex-col items-center justify-center text-center gap-1">
      <div className="w-9 h-9 rounded-xl bg-sf-warmGold/10 flex items-center justify-center text-sf-warmGold">
        {icon}
      </div>
      <span className="text-lg font-black text-text-primary leading-none">{value}</span>
      <span className="text-[10px] text-text-secondary leading-tight">{label}</span>
    </div>
  );
}

export default function ProgressPage() {
  const [filter, setFilter] = useState<"all" | "full" | "daily">("all");

  const { data: statsRes, isLoading: statsLoading } = useWorkoutStats();
  const { data: sessionsRes, isLoading: sessionsLoading } = useWorkoutSessions(
    filter === "all" ? undefined : filter
  );
  const stats = statsRes?.data;
  const sessions: WorkoutSessionLog[] = sessionsRes?.data ?? [];

  return (
    <div className="px-5 py-6 animate-fade-in-up space-y-5">
      <div className="flex items-center gap-3">
        <div className="w-10 h-10 rounded-2xl bg-sf-warmGold/10 flex items-center justify-center text-sf-warmGold">
          <TrendingUp size={22} />
        </div>
        <div>
          <h1 className="text-lg font-bold text-text-primary leading-tight">Progress Latihan</h1>
          <p className="text-xs text-text-secondary">Riwayat & statistik sesi latihan Anda</p>
        </div>
      </div>

      {/* ── Stats ─────────────────────────────────────────── */}
      <div className="grid grid-cols-4 gap-2.5">
        <StatCard
          icon={<Flame size={18} />}
          value={statsLoading ? "–" : `${stats?.current_streak ?? 0}`}
          label="Hari Beruntun"
        />
        <StatCard
          icon={<Dumbbell size={18} />}
          value={statsLoading ? "–" : `${stats?.total_sessions ?? 0}`}
          label="Total Sesi"
        />
        <StatCard
          icon={<Clock size={18} />}
          value={statsLoading ? "–" : formatDuration(stats?.total_seconds ?? 0)}
          label="Total Waktu"
        />
        <StatCard
          icon={<CalendarDays size={18} />}
          value={statsLoading ? "–" : `${stats?.this_week_count ?? 0}`}
          label="Minggu Ini"
        />
      </div>

      {/* ── Reminder settings ─────────────────────────────── */}
      <ReminderCard />

      {/* ── History ───────────────────────────────────────── */}
      <div className="space-y-3">
        <div className="flex items-center gap-2">
          {(
            [
              { key: "all", label: "Semua" },
              { key: "full", label: "Full Program" },
              { key: "daily", label: "Daily Reset" },
            ] as const
          ).map((t) => (
            <button
              key={t.key}
              onClick={() => setFilter(t.key)}
              className={`px-3 py-1.5 rounded-full text-xs font-bold transition-colors ${
                filter === t.key
                  ? "bg-sf-warmGold text-white"
                  : "bg-bg-card text-text-secondary border border-border-color"
              }`}
            >
              {t.label}
            </button>
          ))}
        </div>

        {sessionsLoading ? (
          <div className="py-10 flex justify-center">
            <Loader2 size={24} className="animate-spin text-sf-warmGold" />
          </div>
        ) : sessions.length === 0 ? (
          <div className="card p-8 flex flex-col items-center justify-center text-center min-h-[180px]">
            <div className="w-14 h-14 rounded-2xl bg-sf-warmGold/10 flex items-center justify-center mb-3 text-sf-warmGold">
              <TrendingUp size={26} />
            </div>
            <h2 className="text-sm font-bold text-text-primary mb-1">Belum Ada Sesi</h2>
            <p className="text-xs text-text-secondary max-w-xs">
              Selesaikan sesi latihan di Training Card dan tekan &quot;Akhiri Sesi&quot; — riwayatnya akan muncul di sini.
            </p>
          </div>
        ) : (
          <div className="space-y-2.5">
            {sessions.map((s) => (
              <div
                key={s.id}
                className="card p-3.5 flex items-center justify-between gap-3"
              >
                <div className="flex items-center gap-3 min-w-0">
                  <div className="w-10 h-10 rounded-xl bg-sf-warmGold/10 flex items-center justify-center text-sf-warmGold shrink-0">
                    <Dumbbell size={18} />
                  </div>
                  <div className="min-w-0">
                    <p className="text-sm font-bold text-text-primary truncate">
                      {s.session_type === "full" ? "Full Program" : "Daily Reset"}
                    </p>
                    <p className="text-xs text-text-secondary">
                      {formatDate(s.completed_at)} · {formatTime(s.completed_at)}
                    </p>
                  </div>
                </div>
                <div className="flex items-center gap-1.5 shrink-0 text-sf-warmGold">
                  <Clock size={14} />
                  <span className="text-sm font-bold font-mono">
                    {formatDuration(s.duration_seconds)}
                  </span>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

// ── Reminder settings card ────────────────────────────────────────────

function ReminderCard() {
  const { data: reminderRes, isLoading } = useWorkoutReminder();
  const save = useSaveWorkoutReminder();

  const [enabled, setEnabled] = useState(false);
  const [days, setDays] = useState<number[]>([]);
  const [time, setTime] = useState("07:00");
  const [hydrated, setHydrated] = useState(false);

  // Seed local state once from the server config.
  useEffect(() => {
    const r = reminderRes?.data;
    if (r && !hydrated) {
      setEnabled(!!r.enabled);
      setDays(Array.isArray(r.days_of_week) ? r.days_of_week : []);
      setTime(r.remind_at || "07:00");
      setHydrated(true);
    }
  }, [reminderRes, hydrated]);

  const browserTz = useMemo(() => {
    try {
      return Intl.DateTimeFormat().resolvedOptions().timeZone || "Asia/Jakarta";
    } catch {
      return "Asia/Jakarta";
    }
  }, []);

  const toggleDay = (d: number) => {
    setDays((prev) =>
      prev.includes(d) ? prev.filter((x) => x !== d) : [...prev, d].sort()
    );
  };

  const onSave = () => {
    save.mutate({
      enabled,
      days_of_week: days,
      remind_at: time,
      timezone: browserTz,
    });
  };

  return (
    <div className="card p-4 space-y-4">
      <div className="flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl bg-sf-warmGold/10 flex items-center justify-center text-sf-warmGold">
            <Bell size={18} />
          </div>
          <div>
            <p className="text-sm font-bold text-text-primary leading-tight">Reminder Latihan</p>
            <p className="text-[11px] text-text-secondary">Ingatkan saya sesuai jadwal</p>
          </div>
        </div>
        <button
          role="switch"
          aria-checked={enabled}
          onClick={() => setEnabled((v) => !v)}
          className={`relative w-11 h-6 rounded-full transition-colors duration-200 shrink-0 ${
            enabled ? "bg-sf-warmGold" : "bg-gray-300 dark:bg-slate-600"
          }`}
        >
          <span
            className={`absolute top-0.5 left-0.5 w-5 h-5 rounded-full bg-white shadow transition-transform duration-200 ${
              enabled ? "translate-x-5" : ""
            }`}
          />
        </button>
      </div>

      {isLoading ? (
        <div className="py-3 flex justify-center">
          <Loader2 size={18} className="animate-spin text-sf-warmGold" />
        </div>
      ) : (
        <div className={enabled ? "space-y-4" : "space-y-4 opacity-50 pointer-events-none"}>
          {/* Day chips */}
          <div className="flex items-center justify-between gap-1.5">
            {DAY_LABELS.map((label, idx) => {
              const active = days.includes(idx);
              return (
                <button
                  key={idx}
                  onClick={() => toggleDay(idx)}
                  className={`flex-1 py-2 rounded-lg text-[11px] font-bold transition-colors ${
                    active
                      ? "bg-sf-warmGold text-white"
                      : "bg-bg-primary border border-border-color text-text-secondary"
                  }`}
                >
                  {label}
                </button>
              );
            })}
          </div>

          {/* Time */}
          <div className="flex items-center justify-between">
            <span className="text-sm font-medium text-text-primary">Jam pengingat</span>
            <input
              type="time"
              value={time}
              onChange={(e) => setTime(e.target.value)}
              className="bg-bg-primary border border-border-color rounded-lg px-3 py-1.5 text-sm font-bold text-text-primary focus:outline-none focus:border-sf-warmGold"
            />
          </div>

          <button
            onClick={onSave}
            disabled={save.isPending}
            className="w-full bg-sf-warmGold hover:bg-sf-warmGoldDark disabled:opacity-60 text-white font-bold py-2.5 rounded-xl text-sm transition-colors flex items-center justify-center gap-2"
          >
            {save.isPending ? (
              <Loader2 size={16} className="animate-spin" />
            ) : (
              <Check size={16} />
            )}
            Simpan Reminder
          </button>
        </div>
      )}
    </div>
  );
}
