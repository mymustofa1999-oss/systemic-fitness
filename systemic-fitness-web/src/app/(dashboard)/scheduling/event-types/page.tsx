"use client";

import { EmptyState } from "@/components/shared/EmptyState";
import {
  CalendarClock, Plus, Search, MoreHorizontal, Clock, Globe, Link2, Users,
  Copy, ExternalLink, ToggleLeft, ToggleRight,
} from "lucide-react";
import { useState } from "react";
import { cn } from "@/lib/utils";

const SAMPLE_EVENT_TYPES = [
  { id: 1, name: "1-on-1 Training Session", duration: 60, color: "bg-sf-deepNavy", description: "Personal training session with a certified coach", location: "In-person", active: true, bookingsThisWeek: 12, price: "$75" },
  { id: 2, name: "Nutrition Consultation", duration: 30, color: "bg-emerald-500", description: "One-on-one nutrition planning and review", location: "Video Call", active: true, bookingsThisWeek: 5, price: "$50" },
  { id: 3, name: "Initial Assessment", duration: 90, color: "bg-violet-500", description: "Comprehensive fitness assessment for new clients", location: "In-person", active: true, bookingsThisWeek: 3, price: "$100" },
  { id: 4, name: "Group Class", duration: 60, color: "bg-amber-500", description: "Group fitness class, up to 20 participants", location: "In-person", active: true, bookingsThisWeek: 8, price: "$25" },
  { id: 5, name: "Progress Check-in", duration: 15, color: "bg-cyan-500", description: "Quick progress review and plan adjustments", location: "Video Call", active: false, bookingsThisWeek: 0, price: "Free" },
  { id: 6, name: "Recovery & Mobility", duration: 45, color: "bg-rose-500", description: "Guided recovery and stretching session", location: "In-person", active: true, bookingsThisWeek: 4, price: "$40" },
];

export default function EventTypesPage() {
  const [search, setSearch] = useState("");
  const showEmpty = false;

  const filtered = SAMPLE_EVENT_TYPES.filter((et) =>
    et.name.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Event Types</h1>
          <p className="text-sm text-slate-500 mt-1">
            Configure the types of sessions clients can book
          </p>
        </div>
        <button className="btn-primary">
          <Plus className="h-4 w-4" /> New Event Type
        </button>
      </div>

      {/* Search */}
      <div className="relative max-w-md">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
        <input
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="input pl-10"
          placeholder="Search event types..."
        />
      </div>

      {showEmpty ? (
        <EmptyState
          icon={CalendarClock}
          title="No event types"
          description="Create event types so clients can book sessions, consultations, and classes."
          action={
            <button className="btn-primary">
              <Plus className="h-4 w-4" /> New Event Type
            </button>
          }
        />
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {filtered.map((eventType) => (
            <div key={eventType.id} className="card p-5 cursor-pointer group">
              <div className="flex items-start gap-4">
                {/* Color bar */}
                <div className={cn("w-1.5 h-full min-h-[80px] rounded-full shrink-0", eventType.color)} />

                <div className="flex-1 min-w-0">
                  {/* Header */}
                  <div className="flex items-start justify-between mb-1">
                    <div>
                      <h3 className="font-medium text-slate-900 text-sm">{eventType.name}</h3>
                      <p className="text-xs text-slate-500 mt-0.5">{eventType.description}</p>
                    </div>
                    <div className="flex items-center gap-1">
                      <button
                        className="p-1 text-slate-400 hover:text-slate-600 transition-colors"
                        title={eventType.active ? "Active" : "Inactive"}
                      >
                        {eventType.active ? (
                          <ToggleRight className="h-5 w-5 text-sf-deepNavy" />
                        ) : (
                          <ToggleLeft className="h-5 w-5 text-slate-300" />
                        )}
                      </button>
                      <button className="p-1 rounded hover:bg-slate-100 text-slate-400 opacity-0 group-hover:opacity-100 transition-opacity">
                        <MoreHorizontal className="h-4 w-4" />
                      </button>
                    </div>
                  </div>

                  {/* Details */}
                  <div className="flex items-center gap-4 text-xs text-slate-400 mt-3">
                    <span className="flex items-center gap-1">
                      <Clock className="h-3.5 w-3.5" />
                      {eventType.duration} min
                    </span>
                    <span className="flex items-center gap-1">
                      <Globe className="h-3.5 w-3.5" />
                      {eventType.location}
                    </span>
                    <span className="font-medium text-slate-600">{eventType.price}</span>
                  </div>

                  {/* Footer */}
                  <div className="flex items-center justify-between mt-3 pt-3 border-t border-slate-50">
                    <span className="text-xs text-slate-400">
                      {eventType.bookingsThisWeek} bookings this week
                    </span>
                    <div className="flex items-center gap-2">
                      <button
                        className="flex items-center gap-1 text-xs text-sf-deepNavy hover:text-sf-deepNavy font-medium"
                        title="Copy booking link"
                      >
                        <Copy className="h-3.5 w-3.5" /> Copy Link
                      </button>
                      <button
                        className="flex items-center gap-1 text-xs text-slate-500 hover:text-slate-700 font-medium"
                        title="Preview booking page"
                      >
                        <ExternalLink className="h-3.5 w-3.5" /> Preview
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
