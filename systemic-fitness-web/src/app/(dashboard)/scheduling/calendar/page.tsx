"use client";

import { useState, useMemo, useRef, useEffect } from "react";
import {
  useTrainingSessions,
  useTrainingSchedules,
  TrainingSession,
  TrainingSchedule,
} from "@/hooks/useTrainingSchedules";
import { useAuth } from "@/hooks/useAuth";
import { AssignSubstituteModal } from "@/components/scheduling/AssignSubstituteModal";
import { BulkSubstituteModal } from "@/components/scheduling/BulkSubstituteModal";
import {
  CalendarDays, ChevronLeft, ChevronRight, Clock, ArrowRightLeft,
  MapPin, User, X, CalendarClock, Info, Repeat,
} from "lucide-react";
import { cn } from "@/lib/utils";

const DAY_NAMES_SHORT = ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"];
const DAY_NAMES_FULL = ["Minggu", "Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu"];
const HOURS = Array.from({ length: 14 }, (_, i) => i + 6);

// ─── Date Helpers ──────────────────────────────────────────────

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
function formatWeekRange(monday: Date): string {
  const sunday = addDays(monday, 6);
  const mStr = monday.toLocaleDateString("id-ID", { day: "numeric", month: "long" });
  const sStr = sunday.toLocaleDateString("id-ID", { day: "numeric", month: "long", year: "numeric" });
  return `${mStr} - ${sStr}`;
}
function isToday(d: Date): boolean {
  const now = new Date();
  return d.getFullYear() === now.getFullYear() && d.getMonth() === now.getMonth() && d.getDate() === now.getDate();
}
function parseHour(timeStr: string): number {
  return parseInt(timeStr.slice(0, 2), 10);
}
function formatDateFull(dateStr: string): string {
  const d = new Date(dateStr + "T00:00:00");
  return d.toLocaleDateString("id-ID", { weekday: "long", day: "numeric", month: "long", year: "numeric" });
}

// ─── Unified calendar item ─────────────────────────────────────

interface CalendarItem {
  id: string;
  // Underlying ids — needed for substitution + edit flows.
  sessionId?: string;
  scheduleId?: string;
  clientId: string;
  trainerId: string;
  clientName: string;
  trainerName: string;
  startTime: string;
  endTime: string;
  location: string | null;
  notes: string | null;
  status: string;
  isSubstitute: boolean;
  originalTrainerName: string | null;
  substituteReason: string | null;
  // Audit log surfacing — only present on substituted sessions.
  substitutedByName: string | null;
  substitutedAt: string | null;
  source: "session" | "schedule";
  dateStr: string;
}

function itemColor(item: CalendarItem): string {
  if (item.isSubstitute) return "bg-amber-100 border-amber-300 text-amber-800";
  if (item.source === "schedule") return "bg-indigo-100 border-indigo-300 text-indigo-800";
  switch (item.status) {
    case "completed":   return "bg-emerald-100 border-emerald-300 text-emerald-800";
    case "cancelled":   return "bg-rose-100 border-rose-300 text-rose-700";
    case "substituted": return "bg-amber-100 border-amber-300 text-amber-800";
    default:            return "bg-sf-iceBlue border-sf-systemBlue/40 text-sf-deepNavy";
  }
}

function statusLabel(status: string): string {
  switch (status) {
    case "completed":   return "Selesai";
    case "cancelled":   return "Dibatalkan";
    case "substituted": return "Digantikan";
    default:            return "Terjadwal";
  }
}

function statusBadge(status: string): string {
  switch (status) {
    case "completed":   return "bg-emerald-100 text-emerald-700";
    case "cancelled":   return "bg-rose-100 text-rose-700";
    case "substituted": return "bg-amber-100 text-amber-700";
    default:            return "bg-blue-100 text-blue-700";
  }
}

// ─── Component ──────────────────────────────────────────────────

export default function CalendarPage() {
  const { user, isTrainer, isAdmin } = useAuth();
  const [weekStart, setWeekStart] = useState(() => getMonday(new Date()));
  const [selectedItem, setSelectedItem] = useState<CalendarItem | null>(null);
  const [substituteTarget, setSubstituteTarget] = useState<CalendarItem | null>(null);
  const [bulkModalOpen, setBulkModalOpen] = useState(false);

  const weekDates = useMemo(() =>
    Array.from({ length: 7 }, (_, i) => addDays(weekStart, i)),
    [weekStart]
  );

  const dateFrom = formatDate(weekDates[0]);
  const dateTo = formatDate(weekDates[6]);

  // Trainers see only their own data. Server also enforces this — the
  // explicit param keeps the React Query cache key correct.
  const trainerScope = isTrainer && user?.id ? { trainer_id: user.id } : {};

  const { data: sessData, isLoading: sessLoading } = useTrainingSessions({
    date_from: dateFrom, date_to: dateTo, limit: 200, ...trainerScope,
  });
  const { data: schedData, isLoading: schedLoading } = useTrainingSchedules({
    active: "true", limit: 200, ...trainerScope,
  });

  const sessions = (sessData?.data ?? []) as TrainingSession[];
  const schedules = (schedData?.data ?? []) as TrainingSchedule[];
  const isLoading = sessLoading || schedLoading;

  const sessionKeys = useMemo(() => {
    const keys = new Set<string>();
    sessions.forEach((s) => { if (s.schedule_id) keys.add(`${s.session_date}|${s.schedule_id}`); });
    return keys;
  }, [sessions]);

  const itemsByDate = useMemo(() => {
    const map: Record<string, CalendarItem[]> = {};

    sessions.forEach((s) => {
      const date = s.session_date;
      if (!map[date]) map[date] = [];
      map[date].push({
        id: s.id,
        sessionId: s.id,
        clientId: s.client_id,
        trainerId: s.trainer_id,
        clientName: s.client_name || "Client",
        trainerName: s.trainer_name || "Trainer",
        startTime: s.start_time,
        endTime: s.end_time,
        location: s.location,
        notes: s.notes,
        status: s.status,
        isSubstitute: s.is_substitute,
        originalTrainerName: s.original_trainer_name || null,
        substituteReason: s.substitute_reason || null,
        substitutedByName: s.substituted_by_name || null,
        substitutedAt: s.substituted_at || null,
        source: "session",
        dateStr: date,
      });
    });

    weekDates.forEach((date) => {
      const dow = date.getDay();
      const dateStr = formatDate(date);
      schedules.filter((sch) => sch.day_of_week === dow).forEach((sch) => {
        if (sch.id && sessionKeys.has(`${dateStr}|${sch.id}`)) return;
        if (!map[dateStr]) map[dateStr] = [];
        map[dateStr].push({
          id: `sched-${sch.id}-${dateStr}`,
          scheduleId: sch.id,
          clientId: sch.client_id,
          trainerId: sch.trainer_id,
          clientName: sch.client_name || "Client",
          trainerName: sch.trainer_name || "Trainer",
          startTime: sch.start_time,
          endTime: sch.end_time,
          location: sch.location,
          notes: sch.notes,
          status: "scheduled",
          isSubstitute: false,
          originalTrainerName: null,
          substituteReason: null,
          substitutedByName: null,
          substitutedAt: null,
          source: "schedule",
          dateStr,
        });
      });
    });

    return map;
  }, [sessions, schedules, weekDates, sessionKeys]);

  const todayStr = formatDate(new Date());
  const todayItems = itemsByDate[todayStr] ?? [];
  const totalItems = Object.values(itemsByDate).reduce((sum, arr) => sum + arr.length, 0);

  function prevWeek() { setWeekStart((d) => addDays(d, -7)); setSelectedItem(null); }
  function nextWeek() { setWeekStart((d) => addDays(d, 7)); setSelectedItem(null); }
  function goToday() { setWeekStart(getMonday(new Date())); setSelectedItem(null); }

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Calendar</h1>
          <p className="text-sm text-slate-500 mt-1">Jadwal sesi Certified Trainer & klien</p>
        </div>
        {isAdmin && (
          <button
            onClick={() => setBulkModalOpen(true)}
            className="inline-flex items-center gap-2 px-3 py-2 rounded-lg bg-amber-50 text-amber-700 hover:bg-amber-100 text-sm font-medium border border-amber-200"
            title="Reassign all sessions for a trainer to another trainer"
          >
            <ArrowRightLeft className="h-4 w-4" />
            Bulk Substitute Trainer
          </button>
        )}
      </div>

      {/* Toolbar */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <button onClick={prevWeek} className="btn-secondary p-2"><ChevronLeft className="h-4 w-4" /></button>
          <h2 className="text-lg font-semibold text-slate-900 min-w-[280px] text-center">
            {formatWeekRange(weekStart)}
          </h2>
          <button onClick={nextWeek} className="btn-secondary p-2"><ChevronRight className="h-4 w-4" /></button>
          <button onClick={goToday} className="btn-secondary text-sm">Hari Ini</button>
        </div>
        <div className="flex items-center gap-3 text-xs text-slate-500">
          {isLoading ? "Memuat..." : `${totalItems} sesi minggu ini`}
          <span className="flex items-center gap-1"><span className="w-2.5 h-2.5 rounded bg-indigo-200 border border-indigo-300" /> Jadwal</span>
          <span className="flex items-center gap-1"><span className="w-2.5 h-2.5 rounded bg-sf-iceBlue border border-sf-systemBlue/40" /> Sesi</span>
          <span className="flex items-center gap-1"><span className="w-2.5 h-2.5 rounded bg-amber-200 border border-amber-300" /> Substitusi</span>
        </div>
      </div>

      <div className="flex gap-5">
        {/* Week Grid */}
        <div className={cn("card overflow-hidden transition-all", selectedItem ? "flex-1" : "w-full")}>
          {/* Day Headers */}
          <div className="grid grid-cols-[60px_repeat(7,1fr)] border-b border-slate-100">
            <div className="p-2" />
            {weekDates.map((date, i) => {
              const today = isToday(date);
              const dateItems = itemsByDate[formatDate(date)] ?? [];
              return (
                <div key={i} className={cn("p-3 text-center border-l border-slate-50", today && "bg-sf-iceBlue/50")}>
                  <p className="text-xs text-slate-400 font-medium">{DAY_NAMES_SHORT[date.getDay()]}</p>
                  <p className={cn("text-lg font-semibold mt-0.5", today ? "text-sf-deepNavy" : "text-slate-900")}>
                    {date.getDate()}
                  </p>
                  {dateItems.length > 0 && (
                    <p className="text-[10px] text-slate-400 mt-0.5">{dateItems.length} sesi</p>
                  )}
                </div>
              );
            })}
          </div>

          {/* Time Grid */}
          <div className="grid grid-cols-[60px_repeat(7,1fr)] max-h-[560px] overflow-y-auto">
            {HOURS.map((hour) => (
              <div key={hour} className="contents">
                <div className="p-2 text-right pr-3 border-t border-slate-50 h-16">
                  <span className="text-[10px] text-slate-400 font-medium">
                    {String(hour).padStart(2, "0")}:00
                  </span>
                </div>
                {weekDates.map((date, dayIdx) => {
                  const dateStr = formatDate(date);
                  const hourItems = (itemsByDate[dateStr] ?? []).filter(
                    (item) => parseHour(item.startTime) === hour
                  );
                  const today = isToday(date);

                  return (
                    <div
                      key={`${hour}-${dayIdx}`}
                      className={cn("border-l border-t border-slate-50 h-16 p-0.5 relative", today && "bg-sf-iceBlue/30")}
                    >
                      {hourItems.map((item) => (
                        <button
                          key={item.id}
                          type="button"
                          onClick={() => setSelectedItem(selectedItem?.id === item.id ? null : item)}
                          className={cn(
                            "w-full px-1.5 py-1 rounded-md text-[10px] font-medium border truncate leading-tight text-left transition-all",
                            itemColor(item),
                            selectedItem?.id === item.id
                              ? "ring-2 ring-sf-warmGold/40 ring-offset-1 shadow-md"
                              : "hover:shadow-sm cursor-pointer"
                          )}
                        >
                          <span className="truncate block">{item.clientName}</span>
                          <span className="font-normal opacity-75 flex items-center gap-0.5">
                            {item.startTime?.slice(0, 5)} · {item.trainerName}
                            {item.isSubstitute && <ArrowRightLeft className="h-2.5 w-2.5 ml-0.5" />}
                          </span>
                        </button>
                      ))}
                    </div>
                  );
                })}
              </div>
            ))}
          </div>
        </div>

        {/* ── Detail Panel (side) ──────────────────────────────── */}
        {selectedItem && (
          <DetailPanel
            item={selectedItem}
            onClose={() => setSelectedItem(null)}
            canSubstitute={isAdmin}
            onSubstitute={() => setSubstituteTarget(selectedItem)}
          />
        )}
      </div>

      {/* Today's Sessions */}
      <div className="card p-5">
        <h3 className="text-sm font-semibold text-slate-900 mb-3">
          Sesi Hari Ini ({todayItems.length})
        </h3>
        <div className="space-y-3">
          {todayItems.length === 0 ? (
            <p className="text-sm text-slate-400">Tidak ada sesi hari ini</p>
          ) : (
            todayItems.map((item) => (
              <button
                key={item.id}
                type="button"
                onClick={() => setSelectedItem(item)}
                className="flex items-center gap-3 w-full text-left hover:bg-slate-50 rounded-lg p-1 -m-1 transition-colors"
              >
                <div className={cn("w-1 h-12 rounded-full shrink-0", itemColor(item).split(" ")[0])} />
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-slate-900 truncate">
                    {item.clientName} — {item.trainerName}
                    {item.isSubstitute && (
                      <span className="text-xs text-amber-600 ml-1">(pengganti {item.originalTrainerName})</span>
                    )}
                    {item.source === "schedule" && (
                      <span className="text-xs text-indigo-500 ml-1">(jadwal rutin)</span>
                    )}
                  </p>
                  <div className="flex items-center gap-3 text-xs text-slate-400 mt-0.5">
                    <span className="flex items-center gap-1">
                      <Clock className="h-3 w-3" />
                      {item.startTime?.slice(0, 5)} - {item.endTime?.slice(0, 5)}
                    </span>
                    {item.location && <span>{item.location}</span>}
                  </div>
                </div>
              </button>
            ))
          )}
        </div>
      </div>

      {/* Substitute modal — admin only */}
      <AssignSubstituteModal
        target={
          substituteTarget
            ? {
                id: substituteTarget.id,
                source: substituteTarget.source,
                sessionId: substituteTarget.sessionId,
                scheduleId: substituteTarget.scheduleId,
                clientId: substituteTarget.clientId,
                clientName: substituteTarget.clientName,
                originalTrainerId: substituteTarget.trainerId,
                originalTrainerName: substituteTarget.trainerName,
                dateStr: substituteTarget.dateStr,
                startTime: substituteTarget.startTime,
                endTime: substituteTarget.endTime,
                location: substituteTarget.location,
                notes: substituteTarget.notes,
              }
            : null
        }
        onClose={() => setSubstituteTarget(null)}
      />

      {/* Bulk substitute modal — admin only */}
      <BulkSubstituteModal
        open={bulkModalOpen}
        onClose={() => setBulkModalOpen(false)}
      />
    </div>
  );
}

// ════════════════════════════════════════════════════════════════════
//  Detail Panel
// ════════════════════════════════════════════════════════════════════

function DetailPanel({
  item,
  onClose,
  canSubstitute,
  onSubstitute,
}: {
  item: CalendarItem;
  onClose: () => void;
  canSubstitute: boolean;
  onSubstitute: () => void;
}) {
  const panelRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleKey(e: KeyboardEvent) { if (e.key === "Escape") onClose(); }
    document.addEventListener("keydown", handleKey);
    return () => document.removeEventListener("keydown", handleKey);
  }, [onClose]);

  const colorStrip = item.isSubstitute
    ? "bg-amber-500"
    : item.source === "schedule"
    ? "bg-indigo-500"
    : item.status === "completed" ? "bg-emerald-500"
    : item.status === "cancelled" ? "bg-rose-500"
    : "bg-sf-deepNavy";

  return (
    <div ref={panelRef} className="w-[340px] shrink-0 card overflow-hidden animate-slide-in">
      {/* Color strip */}
      <div className={cn("h-2", colorStrip)} />

      {/* Header */}
      <div className="px-5 pt-4 pb-3 border-b border-slate-100">
        <div className="flex items-start justify-between">
          <div className="flex-1 min-w-0">
            <h3 className="text-base font-semibold text-slate-900 truncate">
              {item.clientName}
            </h3>
            <p className="text-sm text-slate-500 mt-0.5">
              dengan {item.trainerName}
            </p>
          </div>
          <button onClick={onClose} className="p-1 rounded-lg hover:bg-slate-100 text-slate-400 shrink-0 -mr-1 -mt-1">
            <X className="h-4 w-4" />
          </button>
        </div>
      </div>

      {/* Body */}
      <div className="px-5 py-4 space-y-4">
        {/* Status + Type badges */}
        <div className="flex items-center gap-2 flex-wrap">
          <span className={cn("inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-medium", statusBadge(item.status))}>
            {statusLabel(item.status)}
          </span>
          {item.source === "schedule" ? (
            <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-medium bg-indigo-50 text-indigo-700">
              <Repeat className="h-3 w-3" /> Jadwal Rutin
            </span>
          ) : (
            <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-medium bg-slate-100 text-slate-600">
              <CalendarClock className="h-3 w-3" /> Sesi Individual
            </span>
          )}
        </div>

        {/* Info rows */}
        <div className="space-y-3">
          {/* Date */}
          <div className="flex items-start gap-3">
            <CalendarDays className="h-4 w-4 text-slate-400 mt-0.5 shrink-0" />
            <div>
              <p className="text-sm font-medium text-slate-900">{formatDateFull(item.dateStr)}</p>
            </div>
          </div>

          {/* Time */}
          <div className="flex items-start gap-3">
            <Clock className="h-4 w-4 text-slate-400 mt-0.5 shrink-0" />
            <div>
              <p className="text-sm font-medium text-slate-900">
                {item.startTime?.slice(0, 5)} — {item.endTime?.slice(0, 5)}
              </p>
              <p className="text-xs text-slate-400">
                {(() => {
                  const sh = parseInt(item.startTime?.slice(0, 2) || "0");
                  const sm = parseInt(item.startTime?.slice(3, 5) || "0");
                  const eh = parseInt(item.endTime?.slice(0, 2) || "0");
                  const em = parseInt(item.endTime?.slice(3, 5) || "0");
                  const mins = (eh * 60 + em) - (sh * 60 + sm);
                  return mins >= 60 ? `${Math.floor(mins / 60)} jam ${mins % 60 ? mins % 60 + " menit" : ""}` : `${mins} menit`;
                })()}
              </p>
            </div>
          </div>

          {/* Client */}
          <div className="flex items-start gap-3">
            <User className="h-4 w-4 text-slate-400 mt-0.5 shrink-0" />
            <div>
              <p className="text-xs text-slate-400">Client</p>
              <p className="text-sm font-medium text-slate-900">{item.clientName}</p>
            </div>
          </div>

          {/* Trainer */}
          <div className="flex items-start gap-3">
            <User className="h-4 w-4 text-slate-400 mt-0.5 shrink-0" />
            <div>
              <p className="text-xs text-slate-400">Trainer</p>
              <p className="text-sm font-medium text-slate-900">{item.trainerName}</p>
            </div>
          </div>

          {/* Location */}
          {item.location && (
            <div className="flex items-start gap-3">
              <MapPin className="h-4 w-4 text-slate-400 mt-0.5 shrink-0" />
              <div>
                <p className="text-xs text-slate-400">Lokasi</p>
                <p className="text-sm font-medium text-slate-900">{item.location}</p>
              </div>
            </div>
          )}

          {/* Substitution info */}
          {item.isSubstitute && (
            <div className="p-3 bg-amber-50 rounded-lg border border-amber-100">
              <div className="flex items-center gap-2 mb-1.5">
                <ArrowRightLeft className="h-4 w-4 text-amber-600" />
                <span className="text-xs font-semibold text-amber-800">Penggantian Trainer</span>
              </div>
              <p className="text-sm text-amber-800">
                Trainer asli: <strong>{item.originalTrainerName}</strong>
              </p>
              {item.substituteReason && (
                <p className="text-xs text-amber-600 mt-1">
                  Alasan: {item.substituteReason}
                </p>
              )}
              {(item.substitutedByName || item.substitutedAt) && (
                <div className="mt-2 pt-2 border-t border-amber-200/60 text-[10px] text-amber-700 space-y-0.5">
                  {item.substitutedByName && (
                    <p>
                      Diganti oleh: <strong>{item.substitutedByName}</strong>
                    </p>
                  )}
                  {item.substitutedAt && (
                    <p>
                      Pada:{" "}
                      {new Date(item.substitutedAt).toLocaleDateString("id-ID", {
                        day: "numeric",
                        month: "short",
                        year: "numeric",
                        hour: "2-digit",
                        minute: "2-digit",
                      })}
                    </p>
                  )}
                </div>
              )}
            </div>
          )}

          {/* Notes */}
          {item.notes && (
            <div className="flex items-start gap-3">
              <Info className="h-4 w-4 text-slate-400 mt-0.5 shrink-0" />
              <div>
                <p className="text-xs text-slate-400">Catatan</p>
                <p className="text-sm text-slate-700">{item.notes}</p>
              </div>
            </div>
          )}
        </div>

        {/* Konsultan-only action: assign substitute trainer */}
        {canSubstitute && !item.isSubstitute && item.status !== "cancelled" && item.status !== "completed" && (
          <div className="pt-4 border-t border-slate-100">
            <button
              type="button"
              onClick={onSubstitute}
              className="w-full inline-flex items-center justify-center gap-2 px-3 py-2 rounded-lg bg-amber-50 text-amber-700 hover:bg-amber-100 text-sm font-medium border border-amber-200"
            >
              <ArrowRightLeft className="h-4 w-4" />
              Assign Trainer Pengganti
            </button>
            <p className="text-[10px] text-slate-400 text-center mt-1.5">
              Hanya konsultan/admin yang bisa mengganti trainer untuk sesi ini
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
