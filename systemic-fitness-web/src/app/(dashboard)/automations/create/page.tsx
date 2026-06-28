"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { apiPost } from "@/lib/api";
import { toast } from "@/stores/toastStore";
import { useQueryClient } from "@tanstack/react-query";
import {
  ArrowLeft, UserPlus, CheckCircle, Clock, Calendar, Trophy,
  MessageSquare, Target, Bell, Mail,
  ChevronRight, Loader2, Zap, Check,
} from "lucide-react";
import Link from "next/link";
import { cn } from "@/lib/utils";
import { SearchableSelect } from "@/components/shared/SearchableSelect";

// ── Step data ───────────────────────────────────────────────────

const TRIGGERS = [
  { type: "on_signup", icon: UserPlus, label: "New Signup", desc: "When a new user registers", color: "border-blue-200 bg-blue-50" },
  { type: "on_program_complete", icon: CheckCircle, label: "Program Complete", desc: "When a client completes a program", color: "border-emerald-200 bg-emerald-50" },
  { type: "on_inactive_days", icon: Clock, label: "Inactive Days", desc: "When a client hasn't logged in X days", color: "border-amber-200 bg-amber-50" },
  { type: "scheduled", icon: Calendar, label: "Scheduled", desc: "Run on a cron schedule", color: "border-purple-200 bg-purple-50" },
  { type: "on_milestone", icon: Trophy, label: "Milestone", desc: "When a client reaches a milestone", color: "border-rose-200 bg-rose-50" },
];

const ACTIONS = [
  { type: "send_message", icon: MessageSquare, label: "Send Message", desc: "Send an automated message" },
  { type: "assign_program", icon: Target, label: "Assign Program", desc: "Auto-assign a training program" },
  { type: "send_reminder", icon: Bell, label: "Send Reminder", desc: "Push notification reminder" },
  { type: "send_notification", icon: Bell, label: "Notification", desc: "In-app notification" },
  { type: "send_email", icon: Mail, label: "Send Email", desc: "Send an email" },
];

type Step = 1 | 2 | 3;

export default function CreateAutomationPage() {
  const router = useRouter();
  const qc = useQueryClient();
  const [step, setStep] = useState<Step>(1);
  const [loading, setLoading] = useState(false);

  // Selections
  const [triggerType, setTriggerType] = useState("");
  const [actionType, setActionType] = useState("");
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [isActive, setIsActive] = useState(true);

  // Trigger config
  const [inactiveDays, setInactiveDays] = useState("3");
  const [cronExpr, setCronExpr] = useState("0 8 * * 1");
  const [milestone, setMilestone] = useState("100_workouts");

  // Action config
  const [message, setMessage] = useState("");
  const [programId, setProgramId] = useState("");
  const [emailSubject, setEmailSubject] = useState("");

  const selectedTrigger = TRIGGERS.find((t) => t.type === triggerType);
  const selectedAction = ACTIONS.find((a) => a.type === actionType);

  function buildTriggerConfig() {
    switch (triggerType) {
      case "on_inactive_days": return { inactive_days: parseInt(inactiveDays) };
      case "scheduled": return { cron: cronExpr };
      case "on_milestone": return { milestone };
      default: return {};
    }
  }

  function buildActionConfig() {
    switch (actionType) {
      case "send_message": return { message };
      case "assign_program": return { program_id: programId };
      case "send_reminder": case "send_notification": return { title: name, body: message };
      case "send_email": return { subject: emailSubject, template: message };
      default: return {};
    }
  }

  async function handleSubmit() {
    if (!name.trim() || !triggerType || !actionType) return;
    setLoading(true);
    try {
      await apiPost("/api/automations", {
        name, description: description || undefined,
        trigger_type: triggerType,
        trigger_config: buildTriggerConfig(),
        action_type: actionType,
        action_config: buildActionConfig(),
        is_active: isActive,
      });
      qc.invalidateQueries({ queryKey: ["automations"] });
      toast.success("Automation created");
      router.push("/automations");
    } catch (err: any) { toast.error(err.message); }
    setLoading(false);
  }

  return (
    <div className="space-y-6 max-w-3xl">
      <Link href="/automations" className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-slate-700">
        <ArrowLeft className="h-4 w-4" /> Back
      </Link>

      <h1 className="text-2xl font-bold text-slate-900">Create Automation</h1>

      {/* Step indicator */}
      <div className="flex items-center gap-2">
        {[1, 2, 3].map((s) => (
          <div key={s} className="flex items-center gap-2">
            <button
              onClick={() => { if (s === 1 || (s === 2 && triggerType) || (s === 3 && triggerType && actionType)) setStep(s as Step); }}
              className={cn(
                "w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold transition-colors",
                step === s ? "bg-sf-deepNavy text-white" :
                step > s ? "bg-sf-iceBlue text-sf-deepNavy" : "bg-slate-100 text-slate-400"
              )}
            >
              {step > s ? <Check className="h-4 w-4" /> : s}
            </button>
            {s < 3 && <ChevronRight className="h-4 w-4 text-slate-300" />}
          </div>
        ))}
        <span className="text-sm text-slate-500 ml-2">
          {step === 1 ? "Choose Trigger" : step === 2 ? "Choose Action" : "Review & Save"}
        </span>
      </div>

      {/* Step 1: Trigger */}
      {step === 1 && (
        <div className="space-y-4 animate-fade-in">
          <p className="text-sm text-slate-600">What should start this automation?</p>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            {TRIGGERS.map((t) => {
              const TIcon = t.icon;
              const sel = triggerType === t.type;
              return (
                <button
                  key={t.type}
                  onClick={() => setTriggerType(t.type)}
                  className={cn(
                    "p-4 rounded-xl border-2 text-left transition-all",
                    sel ? `${t.color} border-sf-systemBlue ring-2 ring-sf-warmGold/20` : "border-slate-100 hover:border-slate-200 bg-white"
                  )}
                >
                  <TIcon className={cn("h-5 w-5 mb-2", sel ? "text-sf-deepNavy" : "text-slate-400")} />
                  <p className="text-sm font-semibold text-slate-900">{t.label}</p>
                  <p className="text-xs text-slate-500 mt-0.5">{t.desc}</p>
                </button>
              );
            })}
          </div>

          {/* Trigger config */}
          {triggerType === "on_inactive_days" && (
            <div className="card p-4 animate-slide-in">
              <label className="label">Days of inactivity</label>
              <input value={inactiveDays} onChange={(e) => setInactiveDays(e.target.value)} type="number" min="1" className="input w-24" />
            </div>
          )}
          {triggerType === "scheduled" && (
            <div className="card p-4 animate-slide-in">
              <label className="label">Cron Expression</label>
              <input value={cronExpr} onChange={(e) => setCronExpr(e.target.value)} className="input w-64" placeholder="0 8 * * 1" />
              <p className="text-[10px] text-slate-400 mt-1">{"e.g. \"0 8 * * 1\" = every Monday at 8 AM"}</p>
            </div>
          )}
          {triggerType === "on_milestone" && (
            <div className="card p-4 animate-slide-in">
              <label className="label">Milestone</label>
              <SearchableSelect
                options={[{ value: "10_workouts", label: "10 Workouts" }, { value: "50_workouts", label: "50 Workouts" }, { value: "100_workouts", label: "100 Workouts" }]}
                value={milestone}
                onChange={setMilestone}
                placeholder="Select milestone..."
                className="w-48"
              />
            </div>
          )}

          <div className="flex justify-end">
            <button onClick={() => setStep(2)} disabled={!triggerType} className="btn-primary">
              Next <ChevronRight className="h-4 w-4" />
            </button>
          </div>
        </div>
      )}

      {/* Step 2: Action */}
      {step === 2 && (
        <div className="space-y-4 animate-fade-in">
          <p className="text-sm text-slate-600">What action should be taken?</p>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            {ACTIONS.map((a) => {
              const AIcon = a.icon;
              const sel = actionType === a.type;
              return (
                <button
                  key={a.type}
                  onClick={() => setActionType(a.type)}
                  className={cn(
                    "p-4 rounded-xl border-2 text-left transition-all",
                    sel ? "border-sf-systemBlue bg-sf-iceBlue ring-2 ring-sf-warmGold/20" : "border-slate-100 hover:border-slate-200 bg-white"
                  )}
                >
                  <AIcon className={cn("h-5 w-5 mb-2", sel ? "text-sf-deepNavy" : "text-slate-400")} />
                  <p className="text-sm font-semibold text-slate-900">{a.label}</p>
                  <p className="text-xs text-slate-500 mt-0.5">{a.desc}</p>
                </button>
              );
            })}
          </div>

          {/* Action config */}
          {(actionType === "send_message" || actionType === "send_reminder" || actionType === "send_notification") && (
            <div className="card p-4 animate-slide-in">
              <label className="label">Message</label>
              <textarea value={message} onChange={(e) => setMessage(e.target.value)} className="input" rows={3} placeholder="Hey {{user.name}}, ..." />
              <p className="text-[10px] text-slate-400 mt-1">{"Supports: {{user.name}}, {{program.name}}"}</p>
            </div>
          )}
          {actionType === "assign_program" && (
            <div className="card p-4 animate-slide-in">
              <label className="label">Program ID</label>
              <input value={programId} onChange={(e) => setProgramId(e.target.value)} className="input" placeholder="Enter program UUID" />
            </div>
          )}
          {actionType === "send_email" && (
            <div className="card p-4 animate-slide-in space-y-3">
              <div><label className="label">Subject</label><input value={emailSubject} onChange={(e) => setEmailSubject(e.target.value)} className="input" /></div>
              <div><label className="label">Body</label><textarea value={message} onChange={(e) => setMessage(e.target.value)} className="input" rows={3} /></div>
            </div>
          )}

          <div className="flex justify-between">
            <button onClick={() => setStep(1)} className="btn-secondary">Back</button>
            <button onClick={() => setStep(3)} disabled={!actionType} className="btn-primary">Next <ChevronRight className="h-4 w-4" /></button>
          </div>
        </div>
      )}

      {/* Step 3: Review */}
      {step === 3 && (
        <div className="space-y-4 animate-fade-in">
          {/* Flow summary */}
          <div className="card p-5">
            <div className="flex items-center gap-3 justify-center">
              {selectedTrigger && (
                <div className={cn("flex items-center gap-2 px-4 py-2.5 rounded-xl", selectedTrigger.color)}>
                  <selectedTrigger.icon className="h-4 w-4" />
                  <span className="text-sm font-medium">{selectedTrigger.label}</span>
                </div>
              )}
              <ChevronRight className="h-5 w-5 text-slate-300" />
              <Zap className="h-5 w-5 text-amber-500" />
              <ChevronRight className="h-5 w-5 text-slate-300" />
              {selectedAction && (
                <div className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-slate-100">
                  <selectedAction.icon className="h-4 w-4 text-slate-600" />
                  <span className="text-sm font-medium text-slate-700">{selectedAction.label}</span>
                </div>
              )}
            </div>
          </div>

          <div className="card p-5 space-y-4">
            <div><label className="label">Automation Name *</label><input value={name} onChange={(e) => setName(e.target.value)} className="input" placeholder="e.g. Welcome new clients" autoFocus /></div>
            <div><label className="label">Description</label><textarea value={description} onChange={(e) => setDescription(e.target.value)} className="input" rows={2} /></div>
            <div className="flex items-center justify-between">
              <span className="text-sm font-medium text-slate-700">Activate immediately</span>
              <button onClick={() => setIsActive(!isActive)} className={cn("relative w-10 h-5 rounded-full transition-colors", isActive ? "bg-emerald-500" : "bg-slate-300")}>
                <div className={cn("absolute top-0.5 w-4 h-4 rounded-full bg-white shadow transition-transform", isActive ? "translate-x-5" : "translate-x-0.5")} />
              </button>
            </div>
          </div>

          <div className="flex justify-between">
            <button onClick={() => setStep(2)} className="btn-secondary">Back</button>
            <button onClick={handleSubmit} disabled={loading || !name.trim()} className="btn-primary">
              {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <Zap className="h-4 w-4" />}
              {loading ? "Creating..." : "Create Automation"}
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
