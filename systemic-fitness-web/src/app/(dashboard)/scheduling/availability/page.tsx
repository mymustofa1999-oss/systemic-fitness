"use client";

import { useState } from "react";
import { EmptyState } from "@/components/shared/EmptyState";
import {
  Clock, Plus, Save, Trash2, Copy,
} from "lucide-react";
import { cn } from "@/lib/utils";

const DAYS_OF_WEEK = [
  { key: "monday", label: "Monday" },
  { key: "tuesday", label: "Tuesday" },
  { key: "wednesday", label: "Wednesday" },
  { key: "thursday", label: "Thursday" },
  { key: "friday", label: "Friday" },
  { key: "saturday", label: "Saturday" },
  { key: "sunday", label: "Sunday" },
];

interface TimeSlot {
  start: string;
  end: string;
}

const DEFAULT_SCHEDULE: Record<string, { enabled: boolean; slots: TimeSlot[] }> = {
  monday: { enabled: true, slots: [{ start: "07:00", end: "12:00" }, { start: "14:00", end: "19:00" }] },
  tuesday: { enabled: true, slots: [{ start: "07:00", end: "12:00" }, { start: "14:00", end: "19:00" }] },
  wednesday: { enabled: true, slots: [{ start: "09:00", end: "17:00" }] },
  thursday: { enabled: true, slots: [{ start: "07:00", end: "12:00" }, { start: "14:00", end: "19:00" }] },
  friday: { enabled: true, slots: [{ start: "07:00", end: "15:00" }] },
  saturday: { enabled: true, slots: [{ start: "08:00", end: "12:00" }] },
  sunday: { enabled: false, slots: [] },
};

export default function AvailabilityPage() {
  const [schedule, setSchedule] = useState(DEFAULT_SCHEDULE);
  const [timezone] = useState("Asia/Jakarta (WIB)");

  function toggleDay(day: string) {
    setSchedule((prev) => ({
      ...prev,
      [day]: {
        ...prev[day],
        enabled: !prev[day].enabled,
        slots: !prev[day].enabled && prev[day].slots.length === 0
          ? [{ start: "09:00", end: "17:00" }]
          : prev[day].slots,
      },
    }));
  }

  function addSlot(day: string) {
    setSchedule((prev) => ({
      ...prev,
      [day]: {
        ...prev[day],
        slots: [...prev[day].slots, { start: "09:00", end: "17:00" }],
      },
    }));
  }

  function removeSlot(day: string, index: number) {
    setSchedule((prev) => ({
      ...prev,
      [day]: {
        ...prev[day],
        slots: prev[day].slots.filter((_, i) => i !== index),
      },
    }));
  }

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Availability</h1>
          <p className="text-sm text-slate-500 mt-1">
            Set your weekly availability for client bookings
          </p>
        </div>
        <button className="btn-primary">
          <Save className="h-4 w-4" /> Save Changes
        </button>
      </div>

      {/* Timezone */}
      <div className="card p-4 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="h-9 w-9 rounded-lg bg-slate-100 flex items-center justify-center">
            <Clock className="h-4 w-4 text-slate-500" />
          </div>
          <div>
            <p className="text-sm font-medium text-slate-900">Timezone</p>
            <p className="text-xs text-slate-400">{timezone}</p>
          </div>
        </div>
        <button className="btn-secondary text-sm">Change</button>
      </div>

      {/* Weekly Schedule */}
      <div className="card divide-y divide-slate-50 overflow-hidden">
        {DAYS_OF_WEEK.map(({ key, label }) => {
          const day = schedule[key];
          return (
            <div key={key} className="px-5 py-4">
              <div className="flex items-center gap-4">
                {/* Toggle */}
                <button
                  onClick={() => toggleDay(key)}
                  className={cn(
                    "relative w-10 h-5 rounded-full transition-colors shrink-0",
                    day.enabled ? "bg-sf-deepNavy" : "bg-slate-200"
                  )}
                >
                  <span
                    className={cn(
                      "absolute top-0.5 left-0.5 w-4 h-4 rounded-full bg-white shadow transition-transform",
                      day.enabled && "translate-x-5"
                    )}
                  />
                </button>

                {/* Day Label */}
                <span className={cn(
                  "w-28 text-sm font-medium",
                  day.enabled ? "text-slate-900" : "text-slate-400"
                )}>
                  {label}
                </span>

                {/* Time Slots */}
                {day.enabled ? (
                  <div className="flex-1 flex items-center gap-3 flex-wrap">
                    {day.slots.map((slot, i) => (
                      <div key={i} className="flex items-center gap-2">
                        <input
                          type="time"
                          value={slot.start}
                          className="input py-1.5 px-2 text-sm w-[110px]"
                          readOnly
                        />
                        <span className="text-xs text-slate-400">to</span>
                        <input
                          type="time"
                          value={slot.end}
                          className="input py-1.5 px-2 text-sm w-[110px]"
                          readOnly
                        />
                        {day.slots.length > 1 && (
                          <button
                            onClick={() => removeSlot(key, i)}
                            className="p-1 rounded hover:bg-rose-50 text-slate-300 hover:text-rose-500 transition-colors"
                          >
                            <Trash2 className="h-3.5 w-3.5" />
                          </button>
                        )}
                      </div>
                    ))}
                    <button
                      onClick={() => addSlot(key)}
                      className="flex items-center gap-1 text-xs text-sf-deepNavy hover:text-sf-deepNavy font-medium"
                    >
                      <Plus className="h-3 w-3" /> Add
                    </button>
                  </div>
                ) : (
                  <span className="text-sm text-slate-400">Unavailable</span>
                )}

                {/* Copy button */}
                {day.enabled && (
                  <button
                    className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-300 hover:text-slate-500 transition-colors"
                    title="Copy to all days"
                  >
                    <Copy className="h-4 w-4" />
                  </button>
                )}
              </div>
            </div>
          );
        })}
      </div>

      {/* Date Overrides */}
      <div className="card p-5">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h3 className="text-sm font-semibold text-slate-900">Date Overrides</h3>
            <p className="text-xs text-slate-400 mt-0.5">
              Override your availability for specific dates
            </p>
          </div>
          <button className="btn-secondary text-sm">
            <Plus className="h-3.5 w-3.5" /> Add Override
          </button>
        </div>
        <div className="flex flex-col items-center justify-center py-8 text-center">
          <Clock className="h-8 w-8 text-slate-200 mb-2" />
          <p className="text-sm text-slate-400">No date overrides set</p>
        </div>
      </div>
    </div>
  );
}
