"use client";

import { EmptyState } from "@/components/shared/EmptyState";
import {
  Shield, Plus, Search, MoreHorizontal, Mail, UserCog,
} from "lucide-react";
import { useState } from "react";
import { cn } from "@/lib/utils";

const SAMPLE_STAFF = [
  { id: 1, name: "Alex Rivera", email: "alex@fitcoach.com", role: "Owner", status: "active", avatar: "AR", clients: 45, joined: "Jun 2024" },
  { id: 2, name: "Maria Santos", email: "maria@fitcoach.com", role: "Head Coach", status: "active", avatar: "MS", clients: 28, joined: "Sep 2024" },
  { id: 3, name: "Chris Park", email: "chris@fitcoach.com", role: "Coach", status: "active", avatar: "CP", clients: 22, joined: "Jan 2025" },
  { id: 4, name: "Jordan Lee", email: "jordan@fitcoach.com", role: "Coach", status: "active", avatar: "JL", clients: 18, joined: "Mar 2025" },
  { id: 5, name: "Taylor Nguyen", email: "taylor@fitcoach.com", role: "Nutritionist", status: "active", avatar: "TN", clients: 15, joined: "Jul 2025" },
  { id: 6, name: "Sam Mitchell", email: "sam@fitcoach.com", role: "Coach", status: "invited", avatar: "SM", clients: 0, joined: "Mar 2026" },
];

const roleStyles: Record<string, string> = {
  Owner: "bg-amber-50 text-amber-700",
  "Head Coach": "bg-sf-iceBlue text-sf-deepNavy",
  Coach: "bg-indigo-50 text-indigo-700",
  Nutritionist: "bg-emerald-50 text-emerald-700",
};

const statusStyles: Record<string, string> = {
  active: "bg-emerald-50 text-emerald-700",
  invited: "bg-blue-50 text-blue-700",
};

export default function TeamPage() {
  const [search, setSearch] = useState("");
  const showEmpty = false;

  const filtered = SAMPLE_STAFF.filter((s) =>
    s.name.toLowerCase().includes(search.toLowerCase()) ||
    s.email.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Team</h1>
          <p className="text-sm text-slate-500 mt-1">
            Manage your coaches and staff members
          </p>
        </div>
        <button className="btn-primary">
          <Plus className="h-4 w-4" /> Invite Member
        </button>
      </div>

      {/* Search */}
      <div className="relative max-w-md">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
        <input
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="input pl-10"
          placeholder="Search team members..."
        />
      </div>

      {showEmpty ? (
        <EmptyState
          icon={Shield}
          title="No team members"
          description="Invite coaches and staff to help manage your business."
          action={
            <button className="btn-primary">
              <Plus className="h-4 w-4" /> Invite Member
            </button>
          }
        />
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {filtered.map((staff) => (
            <div key={staff.id} className="card p-5 cursor-pointer group">
              <div className="flex items-start justify-between mb-4">
                <div className="flex items-center gap-3">
                  <div className="h-12 w-12 rounded-full bg-sf-iceBlue flex items-center justify-center">
                    <span className="text-sm font-semibold text-sf-deepNavy">{staff.avatar}</span>
                  </div>
                  <div>
                    <h3 className="font-medium text-slate-900 text-sm">{staff.name}</h3>
                    <p className="text-xs text-slate-400 flex items-center gap-1 mt-0.5">
                      <Mail className="h-3 w-3" /> {staff.email}
                    </p>
                  </div>
                </div>
                <button className="p-1 rounded hover:bg-slate-100 text-slate-400 opacity-0 group-hover:opacity-100 transition-opacity">
                  <MoreHorizontal className="h-4 w-4" />
                </button>
              </div>

              <div className="flex items-center gap-2 mb-4">
                <span className={cn("px-2 py-0.5 rounded-full text-xs font-medium", roleStyles[staff.role] ?? "bg-slate-100 text-slate-600")}>
                  {staff.role}
                </span>
                <span className={cn("px-2 py-0.5 rounded-full text-xs font-medium capitalize", statusStyles[staff.status])}>
                  {staff.status}
                </span>
              </div>

              <div className="pt-3 border-t border-slate-50 flex items-center justify-between text-xs text-slate-400">
                <span className="flex items-center gap-1">
                  <UserCog className="h-3.5 w-3.5" />
                  {staff.clients} clients
                </span>
                <span>Joined {staff.joined}</span>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
