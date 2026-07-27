"use client";

import { EmptyState } from "@/components/shared/EmptyState";
import { InviteUserModal } from "@/components/shared/InviteUserModal";
import { useTeam } from "@/hooks/useNewFeatures";
import {
  Shield, Plus, Search, MoreHorizontal, Mail, UserCog, Loader2, UserPlus, Stethoscope, Dumbbell,
} from "lucide-react";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { cn, formatDate, getInitials } from "@/lib/utils";

const roleStyles: Record<string, string> = {
  owner: "bg-purple-100 text-purple-700",
  admin: "bg-blue-100 text-blue-700",
  finance: "bg-amber-100 text-amber-700",
  consultant: "bg-teal-100 text-teal-700",
  trainer: "bg-emerald-100 text-emerald-700",
};

const roleLabels: Record<string, string> = {
  owner: "Owner",
  admin: "Admin",
  finance: "Finance",
  consultant: "Health Consultant",
  trainer: "Trainer",
};

const statusStyles: Record<string, string> = {
  active: "bg-emerald-50 text-emerald-700",
  pending: "bg-blue-50 text-blue-700",
  invited: "bg-blue-50 text-blue-700",
  suspended: "bg-rose-50 text-rose-700",
  inactive: "bg-slate-100 text-slate-500",
};

export default function TeamPage() {
  const router = useRouter();
  const [search, setSearch] = useState("");
  const [inviteOpen, setInviteOpen] = useState(false);
  const [defaultRole, setDefaultRole] = useState("trainer");

  const { data: teamRes, isLoading } = useTeam({ search });
  const staffList = (teamRes?.data ?? []) as any[];

  const filtered = staffList.filter((s) =>
    (s.full_name || "").toLowerCase().includes(search.toLowerCase()) ||
    (s.email || "").toLowerCase().includes(search.toLowerCase()) ||
    (s.role || "").toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Team & Staff</h1>
          <p className="text-sm text-slate-500 mt-1">
            Manage your coaches, health consultants, and staff members
          </p>
        </div>
        <div className="flex flex-wrap items-center gap-2.5">
          <button
            onClick={() => { setDefaultRole("trainer"); setInviteOpen(true); }}
            className="btn-primary flex items-center gap-1.5"
          >
            <Dumbbell className="h-4 w-4" /> Add Trainer
          </button>
          <button
            onClick={() => { setDefaultRole("consultant"); setInviteOpen(true); }}
            className="bg-teal-600 hover:bg-teal-700 text-white px-4 py-2 rounded-xl text-sm font-medium transition-colors flex items-center gap-1.5 shadow-sm"
          >
            <Stethoscope className="h-4 w-4" /> Add Consultant
          </button>
          <button
            onClick={() => { setDefaultRole("admin"); setInviteOpen(true); }}
            className="btn-secondary flex items-center gap-1.5"
          >
            <UserPlus className="h-4 w-4" /> Invite Staff
          </button>
        </div>
      </div>

      {/* Search */}
      <div className="relative max-w-md">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
        <input
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="input pl-10"
          placeholder="Search trainers, consultants, staff by name or email..."
        />
      </div>

      {isLoading ? (
        <div className="flex items-center justify-center py-20">
          <Loader2 className="h-8 w-8 animate-spin text-slate-400" />
        </div>
      ) : filtered.length === 0 ? (
        <EmptyState
          icon={Shield}
          title="No team members found"
          description="Invite coaches, health consultants, and staff to help manage your business."
          action={
            <div className="flex gap-2">
              <button onClick={() => { setDefaultRole("trainer"); setInviteOpen(true); }} className="btn-primary">
                <Dumbbell className="h-4 w-4 mr-1.5" /> Add Trainer
              </button>
              <button onClick={() => { setDefaultRole("consultant"); setInviteOpen(true); }} className="bg-teal-600 hover:bg-teal-700 text-white px-4 py-2 rounded-xl text-sm font-medium transition-colors flex items-center gap-1.5">
                <Stethoscope className="h-4 w-4" /> Add Consultant
              </button>
            </div>
          }
        />
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {filtered.map((staff) => (
            <div
              key={staff.id}
              onClick={() => router.push(`/users/${staff.id}`)}
              className="card p-5 cursor-pointer group hover:border-slate-300 transition-all shadow-sm hover:shadow"
            >
              <div className="flex items-start justify-between mb-4">
                <div className="flex items-center gap-3">
                  <div className="h-12 w-12 rounded-full bg-sf-iceBlue flex items-center justify-center font-semibold text-sf-deepNavy shadow-inner">
                    {getInitials(staff.full_name || staff.email || "U")}
                  </div>
                  <div>
                    <h3 className="font-medium text-slate-900 text-sm line-clamp-1">{staff.full_name || staff.email}</h3>
                    <p className="text-xs text-slate-400 flex items-center gap-1 mt-0.5 line-clamp-1">
                      <Mail className="h-3 w-3 flex-shrink-0" /> {staff.email}
                    </p>
                  </div>
                </div>
                <button className="p-1 rounded hover:bg-slate-100 text-slate-400 opacity-0 group-hover:opacity-100 transition-opacity">
                  <MoreHorizontal className="h-4 w-4" />
                </button>
              </div>

              <div className="flex items-center gap-2 mb-4">
                <span className={cn("px-2.5 py-0.5 rounded-full text-xs font-medium", roleStyles[staff.role] ?? "bg-slate-100 text-slate-600")}>
                  {roleLabels[staff.role] ?? staff.role}
                </span>
                <span className={cn("px-2.5 py-0.5 rounded-full text-xs font-medium capitalize", statusStyles[staff.status] ?? "bg-slate-100 text-slate-600")}>
                  {staff.status}
                </span>
              </div>

              <div className="pt-3 border-t border-slate-50 flex items-center justify-between text-xs text-slate-400">
                <span className="flex items-center gap-1">
                  <UserCog className="h-3.5 w-3.5" />
                  Staff Member
                </span>
                <span>Joined {staff.created_at ? formatDate(staff.created_at) : "-"}</span>
              </div>
            </div>
          ))}
        </div>
      )}

      <InviteUserModal open={inviteOpen} onClose={() => setInviteOpen(false)} defaultRole={defaultRole} />
    </div>
  );
}
