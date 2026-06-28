"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import { apiGet, apiPut } from "@/lib/api";
import { EmptyState } from "@/components/shared/EmptyState";
import { toast } from "@/stores/toastStore";
import {
  Zap, Plus, Play, Pause, UserPlus, CheckCircle,
  Clock, Trophy, Calendar, MessageSquare, Target,
  Bell, Mail, MoreHorizontal, Hash,
} from "lucide-react";
import { cn, formatRelative } from "@/lib/utils";
import { useQueryClient } from "@tanstack/react-query";

const triggerMeta: Record<string, { icon: typeof Zap; label: string; color: string }> = {
  on_signup:            { icon: UserPlus,    label: "New Signup",         color: "bg-blue-100 text-blue-600" },
  on_program_complete:  { icon: CheckCircle, label: "Program Complete",   color: "bg-emerald-100 text-emerald-600" },
  on_inactive_days:     { icon: Clock,       label: "Inactive Days",      color: "bg-amber-100 text-amber-600" },
  scheduled:            { icon: Calendar,    label: "Scheduled",          color: "bg-purple-100 text-purple-600" },
  on_milestone:         { icon: Trophy,      label: "Milestone",          color: "bg-rose-100 text-rose-600" },
};

const actionMeta: Record<string, { icon: typeof Zap; label: string }> = {
  send_message:      { icon: MessageSquare, label: "Send Message" },
  assign_program:    { icon: Target,        label: "Assign Program" },
  send_reminder:     { icon: Bell,          label: "Send Reminder" },
  send_notification: { icon: Bell,          label: "Notification" },
  send_email:        { icon: Mail,          label: "Send Email" },
};

export default function AutomationsPage() {
  const router = useRouter();
  const qc = useQueryClient();
  const [page] = useState(1);

  const { data, isLoading } = useQuery({
    queryKey: ["automations", page],
    queryFn: () => apiGet("/api/automations", { page, limit: 50 }),
  });
  const automations = (data?.data ?? []) as any[];

  async function toggleActive(id: string, current: boolean) {
    try {
      await apiPut(`/api/automations/${id}`, { is_active: !current });
      qc.invalidateQueries({ queryKey: ["automations"] });
      toast.success(!current ? "Automation activated" : "Automation paused");
    } catch (err: any) { toast.error(err.message); }
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Automations</h1>
          <p className="text-sm text-slate-500 mt-1">Automated workflows and triggers</p>
        </div>
        <button onClick={() => router.push("/automations/create")} className="btn-primary"><Plus className="h-4 w-4" /> Create Automation</button>
      </div>

      {isLoading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">{Array.from({ length: 4 }).map((_, i) => <div key={i} className="skeleton h-36 rounded-xl" />)}</div>
      ) : automations.length === 0 ? (
        <EmptyState icon={Zap} title="No automations" description="Create automated workflows to engage clients." action={<button onClick={() => router.push("/automations/create")} className="btn-primary"><Plus className="h-4 w-4" /> Create Automation</button>} />
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {automations.map((a: any) => {
            const trigger = triggerMeta[a.trigger_type] ?? { icon: Zap, label: a.trigger_type, color: "bg-slate-100 text-slate-600" };
            const action = actionMeta[a.action_type] ?? { icon: Zap, label: a.action_type };
            const TIcon = trigger.icon;
            const AIcon = action.icon;

            return (
              <div key={a.id} className="card p-5">
                <div className="flex items-start justify-between mb-3">
                  <h3 className="font-semibold text-slate-900">{a.name}</h3>
                  <button
                    onClick={() => toggleActive(a.id, a.is_active)}
                    className={cn(
                      "relative w-10 h-5 rounded-full transition-colors",
                      a.is_active ? "bg-emerald-500" : "bg-slate-300"
                    )}
                  >
                    <div className={cn(
                      "absolute top-0.5 w-4 h-4 rounded-full bg-white shadow transition-transform",
                      a.is_active ? "translate-x-5" : "translate-x-0.5"
                    )} />
                  </button>
                </div>

                {/* Trigger → Action flow */}
                <div className="flex items-center gap-2 mb-3">
                  <span className={cn("inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-xs font-medium", trigger.color)}>
                    <TIcon className="h-3 w-3" /> {trigger.label}
                  </span>
                  <span className="text-slate-300">→</span>
                  <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-xs font-medium bg-slate-100 text-slate-600">
                    <AIcon className="h-3 w-3" /> {action.label}
                  </span>
                </div>

                {a.description && <p className="text-xs text-slate-400 mb-3 line-clamp-2">{a.description}</p>}

                <div className="flex items-center justify-between text-[10px] text-slate-400 pt-2 border-t border-slate-50">
                  <span className="flex items-center gap-1">
                    {a.is_active ? <Play className="h-3 w-3 text-emerald-500" /> : <Pause className="h-3 w-3" />}
                    {a.is_active ? "Active" : "Paused"}
                  </span>
                  <span>Created {formatRelative(a.created_at)}</span>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
