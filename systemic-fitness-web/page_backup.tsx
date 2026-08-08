"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { useUser } from "@/hooks/useUsers";
import {
  useSystemicSessionLogs,
  useCreateSystemicSessionLog,
  SystemicSessionLog,
} from "@/hooks/useSystemicSessionLog";
import { calculateSystemicScore } from "@/utils/systemicScore";
import {
  ArrowLeft,
  Activity,
  Heart,
  Droplet,
  Moon,
  Coffee,
  CheckCircle,
  AlertTriangle,
  FileText,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { toast } from "@/stores/toastStore";


export default function SystemicSessionLogPage({
  params,
}: {
  params: { id: string };
}) {
  const userId = params.id;
  const { data: userResp } = useUser(userId);
  const user = userResp?.data as { full_name?: string } | undefined;

  const { data: logsResp, isLoading } = useSystemicSessionLogs(userId);
  const logs = (logsResp?.data || []) as SystemicSessionLog[];

  const createLog = useCreateSystemicSessionLog();

  const [activeTab, setActiveTab] = useState<"form" | "history">("form");

  // Form State
  const [formData, setFormData] = useState<Partial<SystemicSessionLog>>({
    session_date: new Date().toISOString().split("T")[0],
    session_number: 1,
    medication_status: "",
    bp_systolic_pre: undefined,
    bp_diastolic_pre: undefined,
    hr_pre: undefined,
    bp_systolic_post: undefined,
    bp_diastolic_post: undefined,
    hr_post: undefined,
    symptom: "",
    symptom_notes: "",
    session_stopped: false,
    resolved_under_5_min: true,
    dr_low_fiber_intake: false,
    dr_cakes_pastries: false,
    dr_starchy_foods: false,
    dr_sugary_drinks: false,
    dr_butter_fatty: false,
    dr_large_carb_portion: false,
    dr_seafood_organ_meats: false,
    dr_none_of_above: false,
    dr_food_detail: "",
    hydration: "Well Hydrated â€” more than 1.5 L",
    hydration_notes: "",
    sleep_recovery: "Good Recovery â€” slept well and felt refreshed",
    sleep_notes: "",
    daily_activity: "Active â€” regular daily movement",
    activity_notes: "",
  });

  const [scores, setScores] = useState(calculateSystemicScore(formData));

  useEffect(() => {
    setScores(calculateSystemicScore(formData));
  }, [formData]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    // Validasi basic
    if (!formData.session_date || !formData.session_number) {
      toast.error("Session date and number are required.");
      return;
    }

    const payload = {
      ...formData,
      ...scores,
    } as SystemicSessionLog;

    createLog.mutate(
      { userId, log: payload },
      {
        onSuccess: () => {
          setActiveTab("history");
          setFormData({
            ...formData,
            session_number: Number(formData.session_number) + 1,
            bp_systolic_pre: undefined,
            bp_diastolic_pre: undefined,
            hr_pre: undefined,
            bp_systolic_post: undefined,
            bp_diastolic_post: undefined,
            hr_post: undefined,
            symptom: "",
          });
        },
      }
    );
  };

  const handleCheckboxChange = (field: keyof SystemicSessionLog) => {
    setFormData((prev) => {
      const isChecked = !prev[field];
      const updates: Partial<SystemicSessionLog> = { [field]: isChecked } as any;
      
      // Mutual exclusivity for dr_none_of_above
      if (field === "dr_none_of_above" && isChecked) {
        updates.dr_low_fiber_intake = false;
        updates.dr_cakes_pastries = false;
        updates.dr_starchy_foods = false;
        updates.dr_sugary_drinks = false;
        updates.dr_butter_fatty = false;
        updates.dr_large_carb_portion = false;
        updates.dr_seafood_organ_meats = false;
      } else if (
        field !== "dr_none_of_above" &&
        field.startsWith("dr_") &&
        isChecked
      ) {
        updates.dr_none_of_above = false;
      }
      return { ...prev, ...updates };
    });
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Link
            href={`/clients/${userId}`}
            className="p-2 rounded-lg bg-white border border-slate-200 hover:bg-slate-50 transition-colors"
          >
            <ArrowLeft className="h-4 w-4 text-slate-500" />
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-slate-900">Systemic Session Log</h1>
            <p className="text-slate-500 text-sm">
              {user?.full_name ? `Client: ${user.full_name}` : "Loading client..."}
            </p>
          </div>
        </div>
      </div>

      <div className="flex bg-white rounded-xl shadow-sm border border-slate-200 p-1">
        <button
          onClick={() => setActiveTab("form")}
          className={cn(
            "flex-1 py-2 text-sm font-medium rounded-lg transition-colors",
            activeTab === "form"
              ? "bg-sf-deepNavy text-white"
              : "text-slate-500 hover:text-slate-900 hover:bg-slate-50"
          )}
        >
          New Session Form
        </button>
        <button
          onClick={() => setActiveTab("history")}
          className={cn(
            "flex-1 py-2 text-sm font-medium rounded-lg transition-colors",
            activeTab === "history"
              ? "bg-sf-deepNavy text-white"
              : "text-slate-500 hover:text-slate-900 hover:bg-slate-50"
          )}
        >
          Log History
        </button>
      </div>

      {activeTab === "form" && (
        <form onSubmit={handleSubmit} className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="lg:col-span-2 space-y-6">
            
            {/* Base Info */}
            <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-6">
              <h2 className="text-lg font-bold text-slate-900 mb-4 flex items-center gap-2">
                <FileText className="h-5 w-5 text-sf-systemBlue" />
                Session Details
              </h2>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                  <label className="block text-xs font-medium text-slate-500 mb-1">Session Date</label>
                  <input
                    type="date"
                    className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2 text-sm"
                    value={formData.session_date}
                    onChange={(e) => setFormData({ ...formData, session_date: e.target.value })}
                  />
                </div>
                <div>
                  <label className="block text-xs font-medium text-slate-500 mb-1">Session Number</label>
                  <input
                    type="number"
                    className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2 text-sm"
                    value={formData.session_number}
                    onChange={(e) => setFormData({ ...formData, session_number: Number(e.target.value) })}
                  />
                </div>
                <div>
                  <label className="block text-xs font-medium text-slate-500 mb-1">Medication Status</label>
                  <input
                    type="text"
                    placeholder="e.g. Amlodipine (Taken)"
                    className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2 text-sm"
                    value={formData.medication_status}
                    onChange={(e) => setFormData({ ...formData, medication_status: e.target.value })}
                  />
                </div>
              </div>
            </div>

            {/* Vitals */}
            <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-6">
              <h2 className="text-lg font-bold text-slate-900 mb-4 flex items-center gap-2">
                <Heart className="h-5 w-5 text-red-500" />
                Vitals & Physiology
              </h2>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                <div>
                  <h3 className="text-sm font-semibold text-slate-700 mb-3">Pre-Session</h3>
                  <div className="space-y-3">
                    <div className="flex gap-2">
                      <div className="flex-1">
                        <label className="block text-xs text-slate-500 mb-1">Systolic</label>
                        <input type="number" placeholder="mmHg" className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2 text-sm"
                          value={formData.bp_systolic_pre || ""} onChange={(e) => setFormData({ ...formData, bp_systolic_pre: Number(e.target.value) })} />
                      </div>
                      <div className="flex-1">
                        <label className="block text-xs text-slate-500 mb-1">Diastolic</label>
                        <input type="number" placeholder="mmHg" className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2 text-sm"
                          value={formData.bp_diastolic_pre || ""} onChange={(e) => setFormData({ ...formData, bp_diastolic_pre: Number(e.target.value) })} />
                      </div>
                    </div>
                    <div>
                      <label className="block text-xs text-slate-500 mb-1">Heart Rate (bpm)</label>
                      <input type="number" placeholder="BPM" className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2 text-sm"
                        value={formData.hr_pre || ""} onChange={(e) => setFormData({ ...formData, hr_pre: Number(e.target.value) })} />
                    </div>
                  </div>
                </div>
                <div>
                  <h3 className="text-sm font-semibold text-slate-700 mb-3">Post-Session</h3>
                  <div className="space-y-3">
                    <div className="flex gap-2">
                      <div className="flex-1">
                        <label className="block text-xs text-slate-500 mb-1">Systolic</label>
                        <input type="number" placeholder="mmHg" className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2 text-sm"
                          value={formData.bp_systolic_post || ""} onChange={(e) => setFormData({ ...formData, bp_systolic_post: Number(e.target.value) })} />
                      </div>
                      <div className="flex-1">
                        <label className="block text-xs text-slate-500 mb-1">Diastolic</label>
                        <input type="number" placeholder="mmHg" className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2 text-sm"
                          value={formData.bp_diastolic_post || ""} onChange={(e) => setFormData({ ...formData, bp_diastolic_post: Number(e.target.value) })} />
                      </div>
                    </div>
                    <div>
                      <label className="block text-xs text-slate-500 mb-1">Heart Rate (bpm)</label>
                      <input type="number" placeholder="BPM" className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2 text-sm"
                        value={formData.hr_post || ""} onChange={(e) => setFormData({ ...formData, hr_post: Number(e.target.value) })} />
                    </div>
                  </div>
                </div>
              </div>
              
              <div className="mt-6 border-t border-slate-100 pt-4">
                <h3 className="text-sm font-semibold text-slate-700 mb-3">Symptoms</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs text-slate-500 mb-1">Symptom Description</label>
                    <input type="text" placeholder="e.g. Dizziness" className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2 text-sm"
                      value={formData.symptom} onChange={(e) => setFormData({ ...formData, symptom: e.target.value })} />
                  </div>
                  <div>
                    <label className="block text-xs text-slate-500 mb-1">Notes</label>
                    <input type="text" placeholder="Additional details" className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2 text-sm"
                      value={formData.symptom_notes} onChange={(e) => setFormData({ ...formData, symptom_notes: e.target.value })} />
                  </div>
                </div>
                {formData.symptom && formData.symptom.length > 0 && (
                  <div className="mt-3 flex items-center gap-6 p-3 bg-red-50 text-red-700 rounded-lg border border-red-100 text-sm">
                    <label className="flex items-center gap-2 cursor-pointer">
                      <input type="checkbox" className="rounded text-red-600 focus:ring-red-500"
                        checked={formData.session_stopped} onChange={(e) => setFormData({ ...formData, session_stopped: e.target.checked })} />
                      Session Stopped
                    </label>
                    <label className="flex items-center gap-2 cursor-pointer">
                      <input type="checkbox" className="rounded text-red-600 focus:ring-red-500"
                        checked={formData.resolved_under_5_min} onChange={(e) => setFormData({ ...formData, resolved_under_5_min: e.target.checked })} />
                      Resolved &lt; 5 min
                    </label>
                  </div>
                )}
              </div>
            </div>

            {/* Lifestyle */}
            <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-6">
              <h2 className="text-lg font-bold text-slate-900 mb-4 flex items-center gap-2">
                <Activity className="h-5 w-5 text-green-500" />
                Daily Habits
              </h2>
              
              <div className="space-y-6">
                {/* Nutrition */}
                <div>
                  <h3 className="text-sm font-semibold text-slate-700 mb-2 flex items-center gap-2"><Coffee className="h-4 w-4"/> Nutrition Readiness (Past 24h)</h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-3 text-sm">
                    {[
                      { key: "dr_sugary_drinks", label: "Sugary drinks" },
                      { key: "dr_cakes_pastries", label: "Cakes, pastries, desserts" },
                      { key: "dr_starchy_foods", label: "Starchy foods (rice/noodles) > 1 portion" },
                      { key: "dr_butter_fatty", label: "Butter, fatty meats, fried foods" },
                      { key: "dr_large_carb_portion", label: "Large carb portion in one meal" },
                      { key: "dr_seafood_organ_meats", label: "Seafood or organ meats" },
                      { key: "dr_low_fiber_intake", label: "Low fiber intake" },
                    ].map((item) => (
                      <label key={item.key} className="flex items-center gap-2 cursor-pointer text-slate-700">
                        <input type="checkbox" className="rounded text-sf-deepNavy focus:ring-sf-deepNavy"
                          checked={formData[item.key as keyof SystemicSessionLog] as boolean}
                          onChange={() => handleCheckboxChange(item.key as keyof SystemicSessionLog)} />
                        {item.label}
                      </label>
                    ))}
                    <div className="col-span-1 md:col-span-2 mt-2 pt-2 border-t border-slate-100">
                      <label className="flex items-center gap-2 cursor-pointer font-medium text-slate-900">
                        <input type="checkbox" className="rounded text-sf-deepNavy focus:ring-sf-deepNavy"
                          checked={formData.dr_none_of_above} onChange={() => handleCheckboxChange("dr_none_of_above")} />
                        None of the above (Clean Diet)
                      </label>
                    </div>
                  </div>
                  <div className="mt-3">
                    <input type="text" placeholder="Food details / Notes" className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2 text-sm"
                      value={formData.dr_food_detail} onChange={(e) => setFormData({ ...formData, dr_food_detail: e.target.value })} />
                  </div>
                </div>

                {/* Hydration */}
                <div>
                  <h3 className="text-sm font-semibold text-slate-700 mb-2 flex items-center gap-2"><Droplet className="h-4 w-4 text-blue-400"/> Hydration</h3>
                  <select className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2 text-sm mb-2"
                    value={formData.hydration} onChange={(e) => setFormData({ ...formData, hydration: e.target.value })}>
                    <option value="Well Hydrated â€” more than 1.5 L">Well Hydrated â€” more than 1.5 L</option>
                    <option value="Mildly Dehydrated â€” around 1-1.5 L">Mildly Dehydrated â€” around 1-1.5 L</option>
                    <option value="Poor Hydration â€” less than 1 L">Poor Hydration â€” less than 1 L</option>
                  </select>
                  <input type="text" placeholder="Hydration Notes" className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2 text-sm"
                      value={formData.hydration_notes} onChange={(e) => setFormData({ ...formData, hydration_notes: e.target.value })} />
                </div>

                {/* Sleep */}
                <div>
                  <h3 className="text-sm font-semibold text-slate-700 mb-2 flex items-center gap-2"><Moon className="h-4 w-4 text-indigo-400"/> Sleep Recovery</h3>
                  <select className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2 text-sm mb-2"
                    value={formData.sleep_recovery} onChange={(e) => setFormData({ ...formData, sleep_recovery: e.target.value })}>
                    <option value="Good Recovery â€” slept well and felt refreshed">Good Recovery â€” slept well and felt refreshed</option>
                    <option value="Monitor â€” woke up once or twice">Monitor â€” woke up once or twice (urination/noise) but returned to sleep</option>
                    <option value="Poor Recovery â€” slept poorly">Poor Recovery â€” slept poorly, difficulty falling asleep</option>
                  </select>
                  <input type="text" placeholder="Sleep Notes" className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2 text-sm"
                      value={formData.sleep_notes} onChange={(e) => setFormData({ ...formData, sleep_notes: e.target.value })} />
                </div>

                {/* Activity */}
                <div>
                  <h3 className="text-sm font-semibold text-slate-700 mb-2 flex items-center gap-2"><Activity className="h-4 w-4 text-orange-400"/> Daily Activity</h3>
                  <select className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2 text-sm mb-2"
                    value={formData.daily_activity} onChange={(e) => setFormData({ ...formData, daily_activity: e.target.value })}>
                    <option value="Active â€” regular daily movement">Active â€” regular daily movement, &gt;5000 steps</option>
                    <option value="Low Activity â€” mostly sitting">Low Activity â€” mostly sitting, minimal walking</option>
                    <option value="Sedentary â€” bed rest / complete inactivity">Sedentary â€” bed rest / complete inactivity</option>
                  </select>
                  <input type="text" placeholder="Activity Notes" className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2 text-sm"
                      value={formData.activity_notes} onChange={(e) => setFormData({ ...formData, activity_notes: e.target.value })} />
                </div>
              </div>
            </div>

          </div>

          {/* Right Sidebar - Real-time Score */}
          <div className="lg:col-span-1">
            <div className="bg-sf-deepNavy text-white rounded-xl shadow-lg p-6 sticky top-6">
              <h2 className="text-lg font-bold mb-6 flex items-center gap-2">
                <CheckCircle className="h-5 w-5 text-sf-gold" />
                Live Assessment
              </h2>

              <div className="space-y-6">
                <div>
                  <p className="text-slate-300 text-xs mb-1">Systemic Score (P1+P2+P3)</p>
                  <div className="flex items-end gap-2">
                    <span className="text-4xl font-bold text-white">{scores.total_systemic_score.toFixed(1)}</span>
                    <span className="text-sm text-slate-400 mb-1">/ 3.0</span>
                  </div>
                  <div className="mt-2 inline-flex items-center px-2.5 py-1 rounded-md text-xs font-medium bg-white/10 text-white">
                    Status: {scores.systemic_status}
                  </div>
                  
                  <div className="mt-4 space-y-2 text-xs text-slate-300 bg-white/5 rounded-lg p-3">
                    <div className="flex justify-between">
                      <span>P1 Blood Pressure</span>
                      <span className="text-white font-medium">{scores.p1_score.toFixed(1)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span>P2 Heart Rate</span>
                      <span className="text-white font-medium">{scores.p2_score.toFixed(1)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span>P3 Symptoms</span>
                      <span className="text-white font-medium">{scores.p3_score.toFixed(1)}</span>
                    </div>
                  </div>
                </div>

                <div className="border-t border-white/10 pt-6">
                  <p className="text-slate-300 text-xs mb-1">Total Habit Score</p>
                  <div className="flex items-end gap-2">
                    <span className="text-4xl font-bold text-sf-gold">{scores.total_habit_score.toFixed(1)}</span>
                    <span className="text-sm text-slate-400 mb-1">/ 4.0</span>
                  </div>
                  <div className="mt-2 inline-flex items-center px-2.5 py-1 rounded-md text-xs font-medium bg-sf-gold/20 text-sf-gold">
                    Lifestyle: {scores.lifestyle_status}
                  </div>

                  <div className="mt-4 space-y-2 text-xs text-slate-300 bg-white/5 rounded-lg p-3">
                    <div className="flex justify-between">
                      <span>Nutrition ({scores.dr_risk_count} risks)</span>
                      <span className="text-white font-medium">{scores.dr_risk_score.toFixed(1)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Hydration</span>
                      <span className="text-white font-medium">{scores.hydration_score.toFixed(1)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Sleep</span>
                      <span className="text-white font-medium">{scores.sleep_score.toFixed(1)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Activity</span>
                      <span className="text-white font-medium">{scores.activity_score.toFixed(1)}</span>
                    </div>
                  </div>
                </div>
              </div>

              <button
                type="submit"
                disabled={createLog.isPending}
                className="w-full mt-8 bg-sf-systemBlue hover:bg-blue-600 text-white font-bold py-3 px-4 rounded-lg transition-colors flex items-center justify-center disabled:opacity-70"
              >
                {createLog.isPending ? "Saving..." : "Save Session Log"}
              </button>
            </div>
          </div>
        </form>
      )}

      {activeTab === "history" && (
        <div className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
          <div className="p-5 border-b border-slate-100 flex justify-between items-center bg-slate-50">
            <h2 className="font-bold text-slate-900">Session History</h2>
            <span className="text-xs bg-sf-deepNavy text-white px-2 py-1 rounded-full">{logs.length} Logs</span>
          </div>
          
          {isLoading ? (
            <div className="p-8 text-center text-slate-500">Loading history...</div>
          ) : logs.length === 0 ? (
            <div className="p-8 text-center text-slate-500">No session logs recorded yet.</div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-sm text-left">
                <thead className="bg-slate-50 text-slate-500 border-b border-slate-200 text-xs uppercase">
                  <tr>
                    <th className="px-4 py-3 font-semibold">Date</th>
                    <th className="px-4 py-3 font-semibold">Sess</th>
                    <th className="px-4 py-3 font-semibold">Vitals (Pre â†’ Post)</th>
                    <th className="px-4 py-3 font-semibold">Systemic</th>
                    <th className="px-4 py-3 font-semibold">Lifestyle</th>
                    <th className="px-4 py-3 font-semibold">Medication & Symptoms</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {logs.map((log) => (
                    <tr key={log.id} className="hover:bg-slate-50/50 transition-colors">
                      <td className="px-4 py-4 whitespace-nowrap text-slate-900 font-medium">
                        {new Date(log.session_date).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' })}
                      </td>
                      <td className="px-4 py-4 text-slate-500 font-medium text-center">
                        #{log.session_number}
                      </td>
                      <td className="px-4 py-4">
                        <div className="text-xs text-slate-600">
                          <span className="inline-block w-8">BP:</span> {log.bp_systolic_pre}/{log.bp_diastolic_pre} â†’ {log.bp_systolic_post}/{log.bp_diastolic_post}
                        </div>
                        <div className="text-xs text-slate-600">
                          <span className="inline-block w-8">HR:</span> {log.hr_pre} â†’ {log.hr_post}
                        </div>
                      </td>
                      <td className="px-4 py-4">
                        <div className="font-bold text-sf-deepNavy">{Number(log.total_systemic_score).toFixed(1)}</div>
                        <div className={cn(
                          "text-[10px] uppercase font-bold mt-0.5",
                          log.systemic_status === "Adaptive" ? "text-green-600" :
                          log.systemic_status === "Acceptable" ? "text-sf-gold" :
                          log.systemic_status === "Suboptimal" ? "text-orange-500" : "text-red-500"
                        )}>{log.systemic_status}</div>
                      </td>
                      <td className="px-4 py-4">
                        <div className="font-bold text-slate-900">{Number(log.total_habit_score).toFixed(1)}</div>
                        <div className={cn(
                          "text-[10px] uppercase font-bold mt-0.5",
                          log.lifestyle_status?.includes("Excellent") ? "text-green-600" :
                          log.lifestyle_status?.includes("Good") ? "text-green-500" :
                          log.lifestyle_status?.includes("Moderate") ? "text-orange-500" : "text-red-500"
                        )}>{log.lifestyle_status}</div>
                      </td>
                      <td className="px-4 py-4 max-w-[200px] truncate text-xs text-slate-500">
                        {log.medication_status && <div className="truncate"><span className="font-medium text-slate-700">Meds:</span> {log.medication_status}</div>}
                        {log.symptom && <div className="truncate text-red-600 mt-1"><span className="font-medium">Symp:</span> {log.symptom}</div>}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
