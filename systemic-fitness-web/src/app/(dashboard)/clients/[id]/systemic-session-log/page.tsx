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
  AlertTriangle,
  FileText,
  ChevronRight,
  Save,
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
    hydration: "Well Hydrated - more than 1.5 L",
    hydration_notes: "",
    sleep_recovery: "Good Recovery - slept well and felt refreshed",
    sleep_notes: "",
    daily_activity: "Active - regular daily movement",
    activity_notes: "",
  });

  const [scores, setScores] = useState(calculateSystemicScore(formData));

  useEffect(() => {
    setScores(calculateSystemicScore(formData));
  }, [formData]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.session_date || !formData.session_number) {
      toast.error("Session date and number are required.");
      return;
    }

    const payload = { ...formData, ...scores } as SystemicSessionLog;

    createLog.mutate(
      { userId, log: payload },
      {
        onSuccess: () => {
          setFormData({
            ...formData,
            session_number: (formData.session_number || 1) + 1,
            bp_systolic_pre: undefined,
            bp_diastolic_pre: undefined,
            hr_pre: undefined,
            bp_systolic_post: undefined,
            bp_diastolic_post: undefined,
            hr_post: undefined,
            symptom: "",
            symptom_notes: "",
            dr_food_detail: "",
          });
        },
      }
    );
  };

  const handleCheckbox = (
    field: keyof SystemicSessionLog,
    checked: boolean
  ) => {
    if (field === "dr_none_of_above" && checked) {
      setFormData({
        ...formData,
        dr_low_fiber_intake: false,
        dr_cakes_pastries: false,
        dr_starchy_foods: false,
        dr_sugary_drinks: false,
        dr_butter_fatty: false,
        dr_large_carb_portion: false,
        dr_seafood_organ_meats: false,
        dr_none_of_above: true,
      });
    } else {
      setFormData((prev) => ({
        ...prev,
        [field]: checked,
        dr_none_of_above: field.startsWith("dr_") ? false : prev.dr_none_of_above,
      }));
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 p-6 md:p-8 space-y-8 pb-24">
      {/* Navigation */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <Link
            href={`/clients/${userId}`}
            className="p-2 rounded-xl bg-white border border-slate-200 hover:bg-slate-50 text-slate-500 transition-colors shadow-sm"
          >
            <ArrowLeft className="h-5 w-5" />
          </Link>
          <div>
            <div className="flex items-center gap-2 text-sm text-slate-500 mb-1">
              <Link href="/clients" className="hover:text-sf-deepNavy transition-colors">
                Clients
              </Link>
              <ChevronRight className="h-3 w-3" />
              <Link href={`/clients/${userId}`} className="hover:text-sf-deepNavy transition-colors">
                {user?.full_name || "..."}
              </Link>
            </div>
            <h1 className="text-2xl font-bold text-slate-900">Systemic Session Log</h1>
          </div>
        </div>
      </div>

      {/* Premium Input Form Section */}
      <div className="bg-white rounded-2xl shadow-md border border-slate-200 overflow-hidden">
        <div className="bg-sf-deepNavy text-white px-6 py-4 flex items-center justify-between">
          <h2 className="text-lg font-bold flex items-center gap-2">
            <Activity className="h-5 w-5 text-sf-gold" />
            New Session Entry
          </h2>
          <div className="text-sm font-medium bg-white/10 px-3 py-1 rounded-full border border-white/10">
            Auto-Score: <span className="text-sf-gold">{scores.total_systemic_score.toFixed(1)}</span> (Systemic) / <span className="text-sf-gold">{scores.total_habit_score.toFixed(1)}</span> (Lifestyle)
          </div>
        </div>

        <form onSubmit={handleSubmit} className="p-6">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
            {/* Col 1: Basic & Vitals */}
            <div className="lg:col-span-4 space-y-6">
              <div className="bg-slate-50 p-5 rounded-xl border border-slate-100 shadow-sm transition-all hover:shadow-md">
                <h3 className="text-sm font-bold text-slate-900 mb-4 uppercase tracking-wider flex items-center gap-2">
                  <FileText className="h-4 w-4 text-sf-blue" /> Session Info
                </h3>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs text-slate-500 mb-1.5 font-medium uppercase">Session No</label>
                    <input
                      type="number"
                      value={formData.session_number}
                      onChange={(e) =>
                        setFormData({ ...formData, session_number: parseInt(e.target.value) })
                      }
                      className="w-full p-2.5 bg-white border border-slate-200 rounded-lg text-sm focus:ring-2 focus:ring-sf-deepNavy focus:border-transparent outline-none transition-all"
                      required
                    />
                  </div>
                  <div>
                    <label className="block text-xs text-slate-500 mb-1.5 font-medium uppercase">Date</label>
                    <input
                      type="date"
                      value={formData.session_date}
                      onChange={(e) =>
                        setFormData({ ...formData, session_date: e.target.value })
                      }
                      className="w-full p-2.5 bg-white border border-slate-200 rounded-lg text-sm focus:ring-2 focus:ring-sf-deepNavy outline-none transition-all"
                      required
                    />
                  </div>
                  <div className="col-span-2">
                    <label className="block text-xs text-slate-500 mb-1.5 font-medium uppercase">Medication / Status</label>
                    <select
                      value={formData.medication_status || ""}
                      onChange={(e) =>
                        setFormData({ ...formData, medication_status: e.target.value })
                      }
                      className="w-full p-2.5 bg-white border border-slate-200 rounded-lg text-sm focus:ring-2 focus:ring-sf-deepNavy outline-none transition-all cursor-pointer"
                    >
                      <option value="">-- Select Status --</option>
                      <option value="✅ Consumed">✅ Consumed (Sudah minum)</option>
                      <option value="❎ Not Consumed">❎ Not Consumed (Tidak minum)</option>
                    </select>
                  </div>
                </div>
              </div>

              <div className="bg-blue-50/50 p-5 rounded-xl border border-blue-100 shadow-sm transition-all hover:shadow-md">
                <h3 className="text-sm font-bold text-slate-900 mb-4 uppercase tracking-wider flex items-center gap-2">
                  <Heart className="h-4 w-4 text-red-500" /> Pre-Workout Vitals
                </h3>
                <div className="grid grid-cols-3 gap-3">
                  <div>
                    <label className="block text-xs text-slate-500 mb-1.5 font-medium">Systolic</label>
                    <input
                      type="number"
                      value={formData.bp_systolic_pre || ""}
                      onChange={(e) =>
                        setFormData({ ...formData, bp_systolic_pre: parseInt(e.target.value) || undefined })
                      }
                      placeholder="120"
                      className="w-full p-2.5 bg-white border border-slate-200 rounded-lg text-sm focus:ring-2 focus:ring-blue-400 outline-none transition-all"
                    />
                  </div>
                  <div>
                    <label className="block text-xs text-slate-500 mb-1.5 font-medium">Diastolic</label>
                    <input
                      type="number"
                      value={formData.bp_diastolic_pre || ""}
                      onChange={(e) =>
                        setFormData({ ...formData, bp_diastolic_pre: parseInt(e.target.value) || undefined })
                      }
                      placeholder="80"
                      className="w-full p-2.5 bg-white border border-slate-200 rounded-lg text-sm focus:ring-2 focus:ring-blue-400 outline-none transition-all"
                    />
                  </div>
                  <div>
                    <label className="block text-xs text-slate-500 mb-1.5 font-medium">HR</label>
                    <input
                      type="number"
                      value={formData.hr_pre || ""}
                      onChange={(e) =>
                        setFormData({ ...formData, hr_pre: parseInt(e.target.value) || undefined })
                      }
                      placeholder="72"
                      className="w-full p-2.5 bg-white border border-slate-200 rounded-lg text-sm focus:ring-2 focus:ring-blue-400 outline-none transition-all"
                    />
                  </div>
                </div>
              </div>

              <div className="bg-green-50/50 p-5 rounded-xl border border-green-100 shadow-sm transition-all hover:shadow-md">
                <h3 className="text-sm font-bold text-slate-900 mb-4 uppercase tracking-wider flex items-center gap-2">
                  <Activity className="h-4 w-4 text-green-600" /> Post-Workout Vitals
                </h3>
                <div className="grid grid-cols-3 gap-3">
                  <div>
                    <label className="block text-xs text-slate-500 mb-1.5 font-medium">Systolic</label>
                    <input
                      type="number"
                      value={formData.bp_systolic_post || ""}
                      onChange={(e) =>
                        setFormData({ ...formData, bp_systolic_post: parseInt(e.target.value) || undefined })
                      }
                      placeholder="110"
                      className="w-full p-2.5 bg-white border border-slate-200 rounded-lg text-sm focus:ring-2 focus:ring-green-400 outline-none transition-all"
                    />
                  </div>
                  <div>
                    <label className="block text-xs text-slate-500 mb-1.5 font-medium">Diastolic</label>
                    <input
                      type="number"
                      value={formData.bp_diastolic_post || ""}
                      onChange={(e) =>
                        setFormData({ ...formData, bp_diastolic_post: parseInt(e.target.value) || undefined })
                      }
                      placeholder="70"
                      className="w-full p-2.5 bg-white border border-slate-200 rounded-lg text-sm focus:ring-2 focus:ring-green-400 outline-none transition-all"
                    />
                  </div>
                  <div>
                    <label className="block text-xs text-slate-500 mb-1.5 font-medium">HR</label>
                    <input
                      type="number"
                      value={formData.hr_post || ""}
                      onChange={(e) =>
                        setFormData({ ...formData, hr_post: parseInt(e.target.value) || undefined })
                      }
                      placeholder="85"
                      className="w-full p-2.5 bg-white border border-slate-200 rounded-lg text-sm focus:ring-2 focus:ring-green-400 outline-none transition-all"
                    />
                  </div>
                </div>
              </div>
            </div>

            {/* Col 2: Symptoms & Lifestyle Inputs */}
            <div className="lg:col-span-5 space-y-6">
              <div className="bg-purple-50/50 p-5 rounded-xl border border-purple-100 shadow-sm transition-all hover:shadow-md">
                <h3 className="text-sm font-bold text-slate-900 mb-4 uppercase tracking-wider flex items-center gap-2">
                  <Coffee className="h-4 w-4 text-purple-500" /> Dietary Risk (Past 24h)
                </h3>
                <div className="grid grid-cols-2 gap-y-3.5 gap-x-4">
                  {[
                    { id: "dr_low_fiber_intake", label: "Low Fiber Intake" },
                    { id: "dr_cakes_pastries", label: "Cakes / Pastries" },
                    { id: "dr_starchy_foods", label: "Starchy Foods" },
                    { id: "dr_sugary_drinks", label: "Sugary Drinks" },
                    { id: "dr_butter_fatty", label: "Butter / Fatty" },
                    { id: "dr_large_carb_portion", label: "Large Carb Portion" },
                    { id: "dr_seafood_organ_meats", label: "Seafood / Organ Meats" },
                    { id: "dr_none_of_above", label: "None of the above" },
                  ].map((item) => (
                    <label key={item.id} className="flex items-center gap-2.5 text-sm text-slate-700 cursor-pointer group">
                      <input
                        type="checkbox"
                        checked={!!formData[item.id as keyof SystemicSessionLog]}
                        onChange={(e) => handleCheckbox(item.id as keyof SystemicSessionLog, e.target.checked)}
                        className="w-4 h-4 rounded border-slate-300 text-purple-600 focus:ring-purple-600 cursor-pointer"
                      />
                      <span className="truncate group-hover:text-purple-700 transition-colors">{item.label}</span>
                    </label>
                  ))}
                </div>
                <div className="mt-5">
                  <input
                    type="text"
                    value={formData.dr_food_detail || ""}
                    onChange={(e) => setFormData({ ...formData, dr_food_detail: e.target.value })}
                    placeholder="Food detail notes..."
                    className="w-full p-2.5 bg-white border border-slate-200 rounded-lg text-sm focus:ring-2 focus:ring-purple-400 outline-none transition-all"
                  />
                </div>
              </div>

              <div className="bg-orange-50/50 p-5 rounded-xl border border-orange-100 shadow-sm transition-all hover:shadow-md">
                <h3 className="text-sm font-bold text-slate-900 mb-4 uppercase tracking-wider flex items-center gap-2">
                  <AlertTriangle className="h-4 w-4 text-orange-500" /> Exercise Symptoms
                </h3>
                <div className="space-y-4">
                  <div>
                    <label className="block text-xs text-slate-500 mb-1.5 font-medium uppercase">Symptom Experienced</label>
                    <select
                      value={formData.symptom || ""}
                      onChange={(e) => setFormData({ ...formData, symptom: e.target.value })}
                      className="w-full p-2.5 bg-white border border-slate-200 rounded-lg text-sm focus:ring-2 focus:ring-orange-400 outline-none transition-all cursor-pointer"
                    >
                      <option value="">-- Select Symptom --</option>
                      <option value="None">None</option>
                      <option value="Chest pain/tightness">Chest pain/tightness</option>
                      <option value="Palpitations">Palpitations</option>
                      <option value="Dizziness">Dizziness</option>
                      <option value="Shortness of breath">Shortness of breath</option>
                      <option value="Nausea/vomiting">Nausea/vomiting</option>
                    </select>
                  </div>
                  <div className="flex flex-wrap items-center gap-6 pt-2">
                    <label className="flex items-center gap-2.5 text-sm text-slate-700 cursor-pointer group">
                      <div className="relative flex items-center">
                        <input
                          type="checkbox"
                          checked={formData.session_stopped}
                          onChange={(e) => setFormData({ ...formData, session_stopped: e.target.checked })}
                          className="w-5 h-5 rounded border-slate-300 text-orange-500 focus:ring-orange-500 cursor-pointer"
                        />
                      </div>
                      <span className="group-hover:text-orange-600 font-medium transition-colors">Session Stopped?</span>
                    </label>
                    <label className="flex items-center gap-2.5 text-sm text-slate-700 cursor-pointer group">
                      <div className="relative flex items-center">
                        <input
                          type="checkbox"
                          checked={formData.resolved_under_5_min}
                          onChange={(e) => setFormData({ ...formData, resolved_under_5_min: e.target.checked })}
                          className="w-5 h-5 rounded border-slate-300 text-orange-500 focus:ring-orange-500 cursor-pointer"
                        />
                      </div>
                      <span className="group-hover:text-orange-600 font-medium transition-colors">Resolved &lt; 5 min?</span>
                    </label>
                  </div>
                </div>
              </div>
            </div>

            {/* Col 3: Recovery & Submit */}
            <div className="lg:col-span-3 space-y-6 flex flex-col justify-between">
              <div className="space-y-6">
                <div className="bg-sky-50/50 p-5 rounded-xl border border-sky-100 shadow-sm transition-all hover:shadow-md">
                  <h3 className="text-sm font-bold text-slate-900 mb-3 uppercase tracking-wider flex items-center gap-2">
                    <Droplet className="h-4 w-4 text-sky-500" /> Hydration
                  </h3>
                  <select
                    value={formData.hydration || ""}
                    onChange={(e) => setFormData({ ...formData, hydration: e.target.value })}
                    className="w-full p-2.5 bg-white border border-slate-200 rounded-lg text-sm focus:ring-2 focus:ring-sky-400 outline-none cursor-pointer"
                  >
                    <option value="Well Hydrated - more than 1.5 L">Well Hydrated (&gt; 1.5 L)</option>
                    <option value="Moderately Hydrated - 1 - 1.5 L">Moderately Hydrated (1 - 1.5 L)</option>
                    <option value="Dehydrated - less than 1 L">Dehydrated (&lt; 1 L)</option>
                  </select>
                </div>

                <div className="bg-indigo-50/50 p-5 rounded-xl border border-indigo-100 shadow-sm transition-all hover:shadow-md">
                  <h3 className="text-sm font-bold text-slate-900 mb-3 uppercase tracking-wider flex items-center gap-2">
                    <Moon className="h-4 w-4 text-indigo-500" /> Sleep Recovery
                  </h3>
                  <div className="space-y-3">
                    <select
                      value={formData.sleep_recovery || ""}
                      onChange={(e) => setFormData({ ...formData, sleep_recovery: e.target.value })}
                      className="w-full p-2.5 bg-white border border-slate-200 rounded-lg text-sm focus:ring-2 focus:ring-indigo-400 outline-none cursor-pointer"
                    >
                      <option value="Good Recovery - slept well and felt refreshed">Good Recovery</option>
                      <option value="Woke up once or twice (urination)">Woke up 1-2 times</option>
                      <option value="Difficulty sleeping - sleep deprived">Difficulty sleeping</option>
                    </select>
                    <input
                      type="text"
                      value={formData.sleep_notes || ""}
                      onChange={(e) => setFormData({ ...formData, sleep_notes: e.target.value })}
                      placeholder="Sleep notes..."
                      className="w-full p-2.5 bg-white border border-slate-200 rounded-lg text-sm focus:ring-2 focus:ring-indigo-400 outline-none transition-all"
                    />
                  </div>
                </div>

                <div className="bg-emerald-50/50 p-5 rounded-xl border border-emerald-100 shadow-sm transition-all hover:shadow-md">
                  <h3 className="text-sm font-bold text-slate-900 mb-3 uppercase tracking-wider flex items-center gap-2">
                    <Activity className="h-4 w-4 text-emerald-500" /> Daily Activity
                  </h3>
                  <select
                    value={formData.daily_activity || ""}
                    onChange={(e) => setFormData({ ...formData, daily_activity: e.target.value })}
                    className="w-full p-2.5 bg-white border border-slate-200 rounded-lg text-sm focus:ring-2 focus:ring-emerald-400 outline-none cursor-pointer"
                  >
                    <option value="Active - regular daily movement">Active (regular movement)</option>
                    <option value="Mostly sitting">Mostly sitting</option>
                    <option value="Bed rest / completely inactive">Bed rest / inactive</option>
                  </select>
                </div>
              </div>

              <button
                type="submit"
                disabled={createLog.isPending}
                className="w-full bg-sf-deepNavy hover:bg-slate-800 text-white font-bold py-3.5 px-4 rounded-xl transition-all shadow-md flex items-center justify-center gap-2 disabled:opacity-70 mt-6"
              >
                {createLog.isPending ? <Activity className="h-5 w-5 animate-spin" /> : <Save className="h-5 w-5" />}
                {createLog.isPending ? "Saving..." : "Save Session Log"}
              </button>
            </div>
          </div>
        </form>
      </div>

      {/* Spreadsheet History Table */}
      <div className="bg-white rounded-2xl shadow-md border border-slate-200 overflow-hidden">
        <div className="p-5 border-b border-slate-200 bg-slate-50 flex justify-between items-center">
          <h2 className="font-bold text-slate-900 text-lg flex items-center gap-2">
            <FileText className="h-5 w-5 text-sf-blue" /> Session History Spreadsheet
          </h2>
          <div className="text-xs bg-white border border-slate-200 text-slate-600 px-3 py-1.5 rounded-lg font-medium shadow-sm">
            Total Records: {logs.length}
          </div>
        </div>

        {isLoading ? (
          <div className="p-12 text-center text-slate-500 flex flex-col items-center gap-3">
            <Activity className="h-8 w-8 animate-pulse text-sf-gold" />
            Loading history...
          </div>
        ) : logs.length === 0 ? (
          <div className="p-12 text-center text-slate-500">No session logs recorded yet.</div>
        ) : (
          <div className="overflow-x-auto pb-2 custom-scrollbar">
            <table className="w-max min-w-full text-sm text-left border-collapse">
              <thead className="bg-slate-100 text-slate-600 border-b-2 border-slate-300 text-xs uppercase text-center">
                {/* Top Level Headers */}
                <tr>
                  <th colSpan={3} className="px-4 py-2.5 border-r border-slate-300 bg-slate-200 tracking-wider">SESSION</th>
                  <th colSpan={3} className="px-4 py-2.5 border-r border-slate-300 tracking-wider">PRE-WORKOUT</th>
                  <th colSpan={3} className="px-4 py-2.5 border-r border-slate-300 tracking-wider">POST-WORKOUT</th>
                  <th colSpan={3} className="px-4 py-2.5 border-r border-slate-300 bg-slate-50 tracking-wider">DELTA (Δ)</th>
                  <th colSpan={4} className="px-4 py-2.5 border-r border-slate-300 bg-orange-100 tracking-wider">EXERCISE SYMPTOMS</th>
                  <th colSpan={5} className="px-4 py-2.5 border-r border-slate-300 bg-blue-100 tracking-wider">SYSTEMIC SCORE</th>
                  <th colSpan={5} className="px-4 py-2.5 border-r border-slate-300 bg-purple-100 tracking-wider">DIETARY RISK</th>
                  <th colSpan={2} className="px-4 py-2.5 border-r border-slate-300 bg-sky-100 tracking-wider">HYDRATION</th>
                  <th colSpan={2} className="px-4 py-2.5 border-r border-slate-300 bg-indigo-100 tracking-wider">SLEEP</th>
                  <th colSpan={2} className="px-4 py-2.5 border-r border-slate-300 bg-emerald-100 tracking-wider">ACTIVITY</th>
                  <th colSpan={2} className="px-4 py-2.5 bg-yellow-100 tracking-wider">LIFESTYLE TOTAL</th>
                </tr>
                {/* Sub Headers */}
                <tr className="text-[10px] bg-slate-50 border-b border-slate-200">
                  <th className="px-3 py-2 font-semibold border-r border-slate-200">No</th>
                  <th className="px-3 py-2 font-semibold border-r border-slate-200 min-w-[100px]">Date</th>
                  <th className="px-3 py-2 font-semibold border-r border-slate-300 min-w-[120px]">Meds</th>

                  <th className="px-2 py-2 font-semibold border-r border-slate-200">SBP</th>
                  <th className="px-2 py-2 font-semibold border-r border-slate-200">DBP</th>
                  <th className="px-2 py-2 font-semibold border-r border-slate-300">HR</th>

                  <th className="px-2 py-2 font-semibold border-r border-slate-200">SBP</th>
                  <th className="px-2 py-2 font-semibold border-r border-slate-200">DBP</th>
                  <th className="px-2 py-2 font-semibold border-r border-slate-300">HR</th>

                  <th className="px-2 py-2 font-semibold border-r border-slate-200">ΔSBP</th>
                  <th className="px-2 py-2 font-semibold border-r border-slate-200">ΔDBP</th>
                  <th className="px-2 py-2 font-semibold border-r border-slate-300">ΔHR</th>

                  <th className="px-3 py-2 font-semibold border-r border-slate-200 min-w-[120px]">Symptom</th>
                  <th className="px-3 py-2 font-semibold border-r border-slate-200 min-w-[100px]">Notes</th>
                  <th className="px-2 py-2 font-semibold border-r border-slate-200">Stopped</th>
                  <th className="px-2 py-2 font-semibold border-r border-slate-300">Res &lt;5m</th>

                  <th className="px-2 py-2 font-semibold border-r border-slate-200 text-blue-700">P1</th>
                  <th className="px-2 py-2 font-semibold border-r border-slate-200 text-blue-700">P2</th>
                  <th className="px-2 py-2 font-semibold border-r border-slate-200 text-blue-700">P3</th>
                  <th className="px-2 py-2 font-bold border-r border-slate-200 text-blue-800">Total</th>
                  <th className="px-3 py-2 font-semibold border-r border-slate-300 min-w-[100px] text-blue-700">Status</th>

                  <th className="px-2 py-2 font-semibold border-r border-slate-200 text-purple-700">Count</th>
                  <th className="px-3 py-2 font-semibold border-r border-slate-200 min-w-[100px] text-purple-700">Status</th>
                  <th className="px-2 py-2 font-semibold border-r border-slate-200 text-purple-700">Score</th>
                  <th className="px-3 py-2 font-semibold border-r border-slate-200 min-w-[100px] text-purple-700">Detail</th>
                  <th className="px-3 py-2 font-semibold border-r border-slate-300 min-w-[120px] text-purple-700">Items</th>

                  <th className="px-2 py-2 font-semibold border-r border-slate-200 text-sky-700">Score</th>
                  <th className="px-3 py-2 font-semibold border-r border-slate-300 min-w-[120px] text-sky-700">Status</th>

                  <th className="px-2 py-2 font-semibold border-r border-slate-200 text-indigo-700">Score</th>
                  <th className="px-3 py-2 font-semibold border-r border-slate-300 min-w-[120px] text-indigo-700">Status</th>

                  <th className="px-2 py-2 font-semibold border-r border-slate-200 text-emerald-700">Score</th>
                  <th className="px-3 py-2 font-semibold border-r border-slate-300 min-w-[120px] text-emerald-700">Status</th>

                  <th className="px-2 py-2 font-bold border-r border-slate-200 text-yellow-700">Total</th>
                  <th className="px-3 py-2 font-bold min-w-[120px] text-yellow-700">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 bg-white text-center">
                {logs.map((log) => (
                  <tr key={log.id} className="hover:bg-slate-50 transition-colors group">
                    <td className="px-3 py-3 border-r border-slate-200 font-medium text-slate-900 group-hover:bg-slate-100/50">#{log.session_number}</td>
                    <td className="px-3 py-3 border-r border-slate-200 font-medium text-slate-700 group-hover:bg-slate-100/50">{new Date(log.session_date).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' })}</td>
                    <td className="px-3 py-3 border-r border-slate-300 text-left text-[11px] truncate max-w-[120px] text-slate-600">{log.medication_status || "-"}</td>

                    <td className="px-2 py-3 border-r border-slate-200 text-slate-700">{log.bp_systolic_pre || "-"}</td>
                    <td className="px-2 py-3 border-r border-slate-200 text-slate-700">{log.bp_diastolic_pre || "-"}</td>
                    <td className="px-2 py-3 border-r border-slate-300 text-slate-700">{log.hr_pre || "-"}</td>

                    <td className="px-2 py-3 border-r border-slate-200 text-slate-700">{log.bp_systolic_post || "-"}</td>
                    <td className="px-2 py-3 border-r border-slate-200 text-slate-700">{log.bp_diastolic_post || "-"}</td>
                    <td className="px-2 py-3 border-r border-slate-300 text-slate-700">{log.hr_post || "-"}</td>

                    <td className="px-2 py-3 border-r border-slate-200 font-medium text-slate-800">{log.bp_systolic_post && log.bp_systolic_pre ? log.bp_systolic_post - log.bp_systolic_pre : "-"}</td>
                    <td className="px-2 py-3 border-r border-slate-200 font-medium text-slate-800">{log.bp_diastolic_post && log.bp_diastolic_pre ? log.bp_diastolic_post - log.bp_diastolic_pre : "-"}</td>
                    <td className="px-2 py-3 border-r border-slate-300 font-medium text-slate-800">{log.hr_post && log.hr_pre ? log.hr_post - log.hr_pre : "-"}</td>

                    <td className="px-3 py-3 border-r border-slate-200 text-left text-xs truncate max-w-[120px] font-medium text-orange-700">{log.symptom || "None"}</td>
                    <td className="px-3 py-3 border-r border-slate-200 text-left text-xs truncate max-w-[100px] text-slate-600">{log.symptom_notes || "-"}</td>
                    <td className="px-2 py-3 border-r border-slate-200 text-xs">
                      {log.session_stopped ? <span className="bg-red-100 text-red-700 px-2 py-0.5 rounded font-bold">Yes</span> : <span className="text-slate-400">No</span>}
                    </td>
                    <td className="px-2 py-3 border-r border-slate-300 text-xs">
                      {log.resolved_under_5_min ? <span className="text-green-600 font-medium">Yes</span> : <span className="text-slate-400">No</span>}
                    </td>

                    <td className="px-2 py-3 border-r border-slate-200 text-blue-700">{Number(log.p1_score).toFixed(1)}</td>
                    <td className="px-2 py-3 border-r border-slate-200 text-blue-700">{Number(log.p2_score).toFixed(1)}</td>
                    <td className="px-2 py-3 border-r border-slate-200 text-blue-700">{Number(log.p3_score).toFixed(1)}</td>
                    <td className="px-2 py-3 border-r border-slate-200 font-bold bg-blue-50/50 text-blue-900 text-base">{Number(log.total_systemic_score).toFixed(1)}</td>
                    <td className={cn("px-3 py-3 border-r border-slate-300 font-bold text-xs bg-blue-50/20", log.systemic_status === "Adaptive" ? "text-green-600" : log.systemic_status === "Acceptable" ? "text-sf-gold" : log.systemic_status === "Suboptimal" ? "text-orange-500" : "text-red-600")}>
                      {log.systemic_status}
                    </td>

                    <td className="px-2 py-3 border-r border-slate-200 font-medium text-purple-700">{log.dr_risk_count}</td>
                    <td className={cn("px-3 py-3 border-r border-slate-200 font-bold text-xs bg-purple-50/20", log.dr_risk_status === "Safe" ? "text-green-600" : log.dr_risk_status === "Needs Attention" ? "text-red-500" : "text-sf-gold")}>
                      {log.dr_risk_status}
                    </td>
                    <td className="px-2 py-3 border-r border-slate-200 font-medium text-purple-700">{Number(log.dr_risk_score).toFixed(1)}</td>
                    <td className="px-3 py-3 border-r border-slate-200 text-xs text-left truncate max-w-[100px] text-slate-600">{log.dr_food_detail || "-"}</td>
                    <td className="px-3 py-3 border-r border-slate-300 text-[9px] text-left max-w-[120px] truncate text-slate-500 font-medium leading-tight">
                      {[log.dr_low_fiber_intake && "Fiber", log.dr_cakes_pastries && "Cake", log.dr_starchy_foods && "Starch", log.dr_sugary_drinks && "Sugar", log.dr_butter_fatty && "Fat", log.dr_large_carb_portion && "Carb", log.dr_seafood_organ_meats && "Seafood"].filter(Boolean).join(", ") || "None"}
                    </td>

                    <td className="px-2 py-3 border-r border-slate-200 font-medium text-sky-700">{Number(log.hydration_score).toFixed(1)}</td>
                    <td className={cn("px-3 py-3 border-r border-slate-300 font-bold text-xs bg-sky-50/20", log.hydration_status?.includes("Well") ? "text-green-600" : log.hydration_status?.includes("Moderat") ? "text-sf-gold" : "text-red-500")}>
                      {log.hydration_status?.split(" - ")[0]}
                    </td>

                    <td className="px-2 py-3 border-r border-slate-200 font-medium text-indigo-700">{Number(log.sleep_score).toFixed(1)}</td>
                    <td className={cn("px-3 py-3 border-r border-slate-300 font-bold text-xs bg-indigo-50/20", log.sleep_status?.includes("Good") ? "text-green-600" : log.sleep_status?.includes("Monitor") ? "text-sf-gold" : "text-red-500")}>
                      {log.sleep_status?.split(" - ")[0]}
                    </td>

                    <td className="px-2 py-3 border-r border-slate-200 font-medium text-emerald-700">{Number(log.activity_score).toFixed(1)}</td>
                    <td className={cn("px-3 py-3 border-r border-slate-300 font-bold text-xs bg-emerald-50/20", log.activity_status?.includes("Active") ? "text-green-600" : log.activity_status?.includes("Low") ? "text-sf-gold" : "text-red-500")}>
                      {log.activity_status?.split(" - ")[0]}
                    </td>

                    <td className="px-2 py-3 border-r border-slate-200 font-bold bg-yellow-50/50 text-yellow-900 text-base">{Number(log.total_habit_score).toFixed(1)}</td>
                    <td className={cn("px-3 py-3 font-bold text-xs bg-yellow-50/20", log.lifestyle_status?.includes("Excellent") ? "text-green-600" : log.lifestyle_status?.includes("Good") ? "text-teal-600" : log.lifestyle_status?.includes("Moderate") ? "text-sf-gold" : "text-red-600")}>
                      {log.lifestyle_status}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      <style dangerouslySetInnerHTML={{__html: `
        .custom-scrollbar::-webkit-scrollbar {
          height: 8px;
        }
        .custom-scrollbar::-webkit-scrollbar-track {
          background: #f1f5f9;
          border-radius: 4px;
        }
        .custom-scrollbar::-webkit-scrollbar-thumb {
          background: #cbd5e1;
          border-radius: 4px;
        }
        .custom-scrollbar::-webkit-scrollbar-thumb:hover {
          background: #94a3b8;
        }
      `}} />
    </div>
  );
}
