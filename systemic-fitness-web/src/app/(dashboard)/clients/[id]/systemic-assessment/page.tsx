"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { useUser } from "@/hooks/useUsers";
import {
  useQuarterlyAssessments,
  useCreateQuarterlyAssessment,
} from "@/hooks/useQuarterlyAssessment";
import {
  ArrowLeft,
  Activity,
  CheckCircle,
  XCircle,
  Save,
  FileText,
  ChevronRight,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { toast } from "@/stores/toastStore";

const EXIT_CRITERIA = {
  1: {
    functional: "• Able to transition safely between sitting and standing.\n• Able to remain standing throughout the training session.\n• Able to maintain standing balance without continuous physical assistance.\n• Able to complete standing Isolate Movements independently.",
    movement: "• Demonstrates acceptable movement quality during standing Isolate Movements.\n• No major loss of balance.\n• No significant compensatory movement patterns that compromise safety.",
  },
  2: {
    functional: "• Able to walk independently without continuous physical assistance.\n• Able to stand comfortably throughout the training session.\n• Able to initiate Dynamic Movement using external balance support.",
    movement: "• Demonstrates good control during standing Isolate Movements.\n• Demonstrates coordinated upper and lower body movement while using balance support.\n• Maintains postural control throughout movement.\n• No major compensatory movement patterns that compromise safety.",
  },
  3: {
    functional: "• Able to perform Dynamic Movement independently without external balance support.\n• Able to maintain upright posture throughout Dynamic Movement.\n• Able to safely change movement direction while maintaining balance.",
    movement: "• Demonstrates controlled Dynamic Movement.\n• Maintains coordinated upper and lower body movement throughout the session.\n• Demonstrates stable balance throughout movement.\n• Performs movement without major compensatory patterns.",
  },
  4: {
    functional: "• Able to perform Dynamic Movement independently with external load.\n• Able to complete the full training session without external balance support.\n• Able to maintain movement quality while handling prescribed training load.",
    movement: "• Demonstrates consistent movement quality throughout the session.\n• Maintains coordinated Dynamic Movement with external load.\n• Demonstrates stable balance throughout movement.\n• Performs movement without significant compensatory patterns.",
  },
  5: {
    functional: "• Able to complete higher-tempo Dynamic Movement independently.\n• Able to maintain coordination while performing loaded Dynamic Movement.\n• Able to complete the full training session independently without external support.",
    movement: "• Maintains movement quality throughout the prescribed tempo.\n• Maintains coordination despite increased movement complexity.\n• Demonstrates consistent postural control throughout the session.\n• Performs all prescribed movement patterns without significant compensatory movements.",
  },
  6: {
    functional: "Highest level — no exit criteria.",
    movement: "Highest level — no exit criteria.",
  },
};

export default function SystemicAssessmentPage({
  params,
}: {
  params: { id: string };
}) {
  const { data: userData } = useUser(params.id);
  const user = userData?.data as any;
  const { assessments, mutate, isLoading } = useQuarterlyAssessments(params.id);
  const { submit, isSubmitting } = useCreateQuarterlyAssessment();

  // Form State for the NEW row
  const [quarter, setQuarter] = useState(`Q${(assessments?.length || 0) + 1}`);
  const [periodRange, setPeriodRange] = useState("");
  const [currentLevel, setCurrentLevel] = useState<number>(1);
  const [functionalMet, setFunctionalMet] = useState(false);
  const [movementMet, setMovementMet] = useState(false);
  const [avgScore, setAvgScore] = useState<number | "">("");
  
  const [height, setHeight] = useState<number | "">("");
  const [weight, setWeight] = useState<number | "">("");
  const [gender, setGender] = useState<string>("Female");
  const [waist, setWaist] = useState<number | "">("");
  const [medicalCondition, setMedicalCondition] = useState("");
  const [labReport, setLabReport] = useState("");
  const [reviewDate, setReviewDate] = useState(() => new Date().toISOString().split("T")[0]);

  // Calculations
  const scoreThreshold = 2.25;
  const scoreMet = typeof avgScore === "number" && avgScore > scoreThreshold;
  const isProgress = functionalMet && movementMet && scoreMet;
  const decision = isProgress ? "PROGRESS" : "INCOMPLETE";
  const newLevel = isProgress ? (currentLevel < 6 ? currentLevel + 1 : 6) : currentLevel;

  let bmi = 0;
  let bmiCategory = "";
  if (typeof weight === "number" && typeof height === "number" && height > 0) {
    bmi = weight / Math.pow(height / 100, 2);
    if (bmi < 18.5) bmiCategory = "Underweight";
    else if (bmi <= 22.9) bmiCategory = "Normal";
    else if (bmi <= 24.9) bmiCategory = "Overweight";
    else if (bmi <= 29.9) bmiCategory = "Obese I";
    else bmiCategory = "Obese II";
  }

  let waistStatus = "";
  if (typeof waist === "number") {
    if (gender === "Male") {
      waistStatus = waist >= 90 ? "At Risk" : "Within Range";
    } else {
      waistStatus = waist >= 80 ? "At Risk" : "Within Range";
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!quarter || typeof currentLevel !== "number" || typeof avgScore !== "number") {
      toast.error("Please fill in all required fields (Quarter, Level, Avg Score)");
      return;
    }

    try {
      await submit({
        client_id: params.id,
        quarter,
        period_range: periodRange,
        current_level: currentLevel,
        functional_criteria_met: functionalMet,
        movement_quality_met: movementMet,
        avg_systemic_score: avgScore,
        score_status_met: scoreMet,
        decision,
        new_level: newLevel,
        height_cm: height || undefined,
        weight_kg: weight || undefined,
        gender: gender || undefined,
        bmi: bmi || undefined,
        bmi_category: bmiCategory || undefined,
        waist_circumference_cm: waist || undefined,
        waist_status: waistStatus || undefined,
        medical_condition: medicalCondition || undefined,
        lab_report_link: labReport || undefined,
        review_date: new Date(reviewDate).toISOString(),
      });
      
      toast.success("Quarterly Assessment saved successfully");
      mutate();
      
      // Reset form (partial)
      setFunctionalMet(false);
      setMovementMet(false);
      setAvgScore("");
      setQuarter(`Q${assessments.length + 2}`); // next quarter
      
    } catch (err: any) {
      toast.error(err.message || "Failed to save assessment");
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 p-6 md:p-8 space-y-8 pb-24">
      {/* Navigation */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <Link
            href={`/clients/${params.id}`}
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
              <Link href={`/clients/${params.id}`} className="hover:text-sf-deepNavy transition-colors">
                {user?.full_name || "..."}
              </Link>
            </div>
            <h1 className="text-2xl font-bold text-slate-900">Systemic Assesment</h1>
          </div>
        </div>
      </div>

      {/* Historical Data Table */}
      <div className="bg-white rounded-2xl shadow-md border border-slate-200 overflow-hidden">
        <div className="bg-sf-deepNavy text-white px-6 py-4 flex items-center justify-between">
          <div>
            <h2 className="text-lg font-bold flex items-center gap-2">
              <FileText className="h-5 w-5 text-sf-gold" />
              QUARTERLY REVIEW (HISTORY)
            </h2>
            <p className="text-xs text-slate-300 mt-1">every 3 months (24 sessions)</p>
          </div>
          <div className="text-sm bg-white/10 px-4 py-2 rounded-lg border border-white/10 flex items-center gap-2">
            Min Avg Systemic Score: <strong className="text-sf-gold">{scoreThreshold}</strong>
            <span className="text-xs text-slate-300 ml-2">&larr; pass threshold.</span>
          </div>
        </div>

        <div className="overflow-x-auto pb-4 custom-scrollbar">
          <table className="w-max min-w-full text-sm text-left border-collapse">
            <thead className="bg-slate-100 text-slate-600 border-b-2 border-slate-300 text-xs uppercase text-center">
              {/* Top Level Headers */}
              <tr>
                <th colSpan={3} className="px-4 py-2.5 border-r border-black bg-black text-amber-400 tracking-wider">QUARTER</th>
                <th colSpan={2} className="px-4 py-2.5 border-r border-black bg-black text-amber-400 tracking-wider font-semibold">EXIT CRITERIA — auto-filled, reference only</th>
                <th colSpan={4} className="px-4 py-2.5 border-r border-black bg-black text-amber-400 tracking-wider font-semibold">EXIT CHECKLIST — 3 parameters</th>
                <th colSpan={2} className="px-4 py-2.5 border-r border-black bg-black text-amber-400 tracking-wider">OUTCOME</th>
                <th colSpan={7} className="px-4 py-2.5 border-r border-black bg-black text-amber-400 tracking-wider">BODY COMPOSITION</th>
                <th colSpan={3} className="px-4 py-2.5 bg-black text-amber-400 tracking-wider">MEDICAL & RECORDS</th>
              </tr>
              {/* Sub Headers */}
              <tr className="text-[10px] text-white border-b border-black">
                <th className="px-3 py-2 font-semibold border-r border-black bg-black">Quarter</th>
                <th className="px-3 py-2 font-semibold border-r border-black min-w-[100px] bg-black">Period</th>
                <th className="px-3 py-2 font-semibold border-r border-black min-w-[80px] bg-black">Current<br/>Level</th>
                <th className="px-4 py-2 font-semibold border-r border-black min-w-[280px] bg-teal-900 text-white">EXIT CRITERIA - Functional</th>
                <th className="px-4 py-2 font-semibold border-r border-black min-w-[280px] bg-teal-900 text-white">EXIT CRITERIA - Movement Quality</th>
                <th className="px-3 py-2 font-semibold border-r border-black text-center bg-black">Functional</th>
                <th className="px-3 py-2 font-semibold border-r border-black text-center bg-black">Movement<br/>Quality</th>
                <th className="px-3 py-2 font-semibold border-r border-black min-w-[100px] text-center bg-black">Avg Systemic<br/>Score</th>
                <th className="px-3 py-2 font-semibold border-r border-black text-center bg-black">Score<br/>Status</th>
                <th className="px-4 py-2 font-bold border-r border-black text-center bg-black">DECISION</th>
                <th className="px-3 py-2 font-bold border-r border-black text-center bg-black">New<br/>Level</th>
                <th className="px-3 py-2 font-semibold border-r border-black text-center bg-black">Height<br/>(cm)</th>
                <th className="px-3 py-2 font-semibold border-r border-black text-center bg-black">Weight<br/>(kg)</th>
                <th className="px-3 py-2 font-semibold border-r border-black text-center bg-black">Gender</th>
                <th className="px-3 py-2 font-semibold border-r border-black text-center bg-black">BMI</th>
                <th className="px-3 py-2 font-semibold border-r border-black text-center bg-black">BMI Category</th>
                <th className="px-3 py-2 font-semibold border-r border-black text-center bg-black">Waist<br/>Circum (cm)</th>
                <th className="px-3 py-2 font-semibold border-r border-black text-center bg-black">Waist<br/>Status</th>
                <th className="px-4 py-2 font-semibold border-r border-black min-w-[200px] bg-black">Medical Condition</th>
                <th className="px-4 py-2 font-semibold border-r border-black min-w-[180px] bg-black">Lab Report (PDF link)</th>
                <th className="px-4 py-2 font-semibold min-w-[120px] text-center bg-black">Review<br/>Date</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 bg-white">
              {isLoading ? (
                <tr>
                  <td colSpan={21} className="py-12 text-center text-slate-500">
                    <Activity className="h-6 w-6 animate-spin mx-auto mb-2 text-sf-gold" />
                    Loading history...
                  </td>
                </tr>
              ) : assessments.length === 0 ? (
                <tr>
                  <td colSpan={21} className="py-12 text-center text-slate-500 italic">
                    Belum ada data assessment. Silakan input di bawah.
                  </td>
                </tr>
              ) : (
                assessments.map((a) => (
                  <tr key={a.id} className="hover:bg-slate-50 transition-colors">
                    <td className="px-3 py-3 border-r border-slate-200 font-bold text-slate-900 text-center">{a.quarter}</td>
                    <td className="px-3 py-3 border-r border-slate-200 text-slate-600">{a.period_range || "-"}</td>
                    <td className="px-3 py-3 border-r border-slate-300 font-bold text-center text-sf-deepNavy bg-slate-50">{a.current_level}</td>
                    
                    <td className="px-4 py-3 border-r border-slate-200 text-[11px] whitespace-pre-wrap text-slate-500 leading-tight">
                      {EXIT_CRITERIA[a.current_level as keyof typeof EXIT_CRITERIA]?.functional || ""}
                    </td>
                    <td className="px-4 py-3 border-r border-slate-300 text-[11px] whitespace-pre-wrap text-slate-500 leading-tight">
                      {EXIT_CRITERIA[a.current_level as keyof typeof EXIT_CRITERIA]?.movement || ""}
                    </td>

                    <td className={cn("px-3 py-3 border-r border-slate-200 text-center font-bold text-lg", a.functional_criteria_met ? "bg-[#d9ead3] text-green-800" : "text-red-400")}>
                      {a.functional_criteria_met ? "✔" : "✖"}
                    </td>
                    <td className={cn("px-3 py-3 border-r border-slate-300 text-center font-bold text-lg", a.movement_quality_met ? "bg-[#d9ead3] text-green-800" : "text-red-400")}>
                      {a.movement_quality_met ? "✔" : "✖"}
                    </td>

                    <td className="px-3 py-3 border-r border-slate-200 text-center font-bold text-slate-800">{a.avg_systemic_score}</td>
                    <td className={cn("px-3 py-3 border-r border-slate-300 text-center font-bold text-lg", a.score_status_met ? "bg-[#d9ead3] text-green-800" : "text-red-400")}>
                      {a.score_status_met ? "✔" : "✖"}
                    </td>

                    <td className={cn(
                      "px-4 py-3 border-r border-slate-200 text-center font-bold",
                      a.decision === "PROGRESS" ? "text-green-800 bg-[#d9ead3]" : "text-slate-500"
                    )}>
                      {a.decision}
                    </td>
                    <td className={cn("px-3 py-3 border-r border-slate-300 text-center font-bold", a.decision === "PROGRESS" ? "bg-[#d9ead3] text-green-900" : "text-slate-500")}>
                      {a.new_level || ""}
                    </td>

                    <td className="px-3 py-3 border-r border-slate-200 text-center text-slate-700">{a.height_cm || "-"}</td>
                    <td className="px-3 py-3 border-r border-slate-200 text-center text-slate-700">{a.weight_kg || "-"}</td>
                    <td className="px-3 py-3 border-r border-slate-200 text-center text-slate-700">{a.gender || "-"}</td>
                    <td className="px-3 py-3 border-r border-slate-200 text-center text-slate-700">{a.bmi || "-"}</td>
                    <td className="px-3 py-3 border-r border-slate-200 text-center text-slate-700">{a.bmi_category || "-"}</td>
                    <td className="px-3 py-3 border-r border-slate-200 text-center text-slate-700">{a.waist_circumference_cm || "-"}</td>
                    <td className="px-3 py-3 border-r border-slate-300 text-center text-slate-700">{a.waist_status || "-"}</td>

                    <td className="px-4 py-3 border-r border-slate-200 text-slate-600 text-xs">{a.medical_condition || "-"}</td>
                    <td className="px-4 py-3 border-r border-slate-200 text-slate-600 text-xs">
                      {a.lab_report_link ? (
                        <a href={a.lab_report_link} target="_blank" rel="noreferrer" className="text-blue-500 hover:underline break-all">Link</a>
                      ) : "-"}
                    </td>
                    <td className="px-4 py-3 text-center text-slate-600">{new Date(a.review_date).toLocaleDateString('en-GB')}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Input Form Section (Vertical Layout) */}
      <div className="bg-white rounded-2xl shadow-md border border-slate-200 overflow-hidden mt-8">
        <div className="bg-amber-400 text-black px-6 py-4 flex items-center justify-between border-b-4 border-black">
          <h2 className="text-lg font-bold flex items-center gap-2">
            <Activity className="h-5 w-5" />
            INPUT NEW ASSESSMENT
          </h2>
        </div>

        <form onSubmit={handleSubmit} className="p-6 md:p-8 space-y-8">
          {/* SECTION 1: QUARTER & PERIOD */}
          <div>
            <h3 className="text-sm font-bold text-slate-800 uppercase tracking-wider mb-4 border-b border-slate-100 pb-2">Quarter & Periode</h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div>
                <label className="block text-xs font-bold text-slate-500 mb-1">Quarter</label>
                <input type="text" value={quarter} onChange={e => setQuarter(e.target.value)} className="w-full p-2.5 bg-slate-50 border border-slate-200 rounded-lg focus:ring-2 focus:ring-amber-400 font-bold" required />
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-500 mb-1">Period Range</label>
                <input type="text" value={periodRange} onChange={e => setPeriodRange(e.target.value)} placeholder="e.g. Jan-Mar" className="w-full p-2.5 bg-slate-50 border border-slate-200 rounded-lg focus:ring-2 focus:ring-amber-400" />
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-500 mb-1">Review Date</label>
                <input type="date" value={reviewDate} onChange={e => setReviewDate(e.target.value)} className="w-full p-2.5 bg-slate-50 border border-slate-200 rounded-lg focus:ring-2 focus:ring-amber-400" required />
              </div>
            </div>
          </div>

          {/* SECTION 2: EXIT CHECKLIST */}
          <div>
            <h3 className="text-sm font-bold text-slate-800 uppercase tracking-wider mb-4 border-b border-slate-100 pb-2 flex items-center justify-between">
              Exit Checklist
              <span className="text-xs font-normal text-slate-500 bg-slate-100 px-2 py-1 rounded">Target Score: > {scoreThreshold}</span>
            </h3>
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 bg-slate-50 p-4 rounded-xl border border-slate-100">
              
              <div className="lg:col-span-2">
                <label className="block text-xs font-bold text-slate-700 mb-1">Current Level</label>
                <select value={currentLevel} onChange={e => setCurrentLevel(Number(e.target.value))} className="w-full p-2.5 font-bold text-center bg-white border border-slate-200 rounded-lg focus:ring-2 focus:ring-amber-400">
                  {[1,2,3,4,5,6].map(l => <option key={l} value={l}>Level {l}</option>)}
                </select>
              </div>

              <div className="lg:col-span-3 space-y-3">
                <label className="flex items-start gap-3 p-3 bg-white border border-slate-200 rounded-lg cursor-pointer hover:border-green-400 transition-colors">
                  <input type="checkbox" checked={functionalMet} onChange={e => setFunctionalMet(e.target.checked)} className="mt-0.5 w-5 h-5 rounded border-slate-300 text-green-600 focus:ring-green-600" />
                  <div>
                    <span className="block text-sm font-bold text-slate-800">Functional Met</span>
                    <span className="block text-[10px] text-slate-500 mt-1 leading-tight">{EXIT_CRITERIA[currentLevel as keyof typeof EXIT_CRITERIA]?.functional || ""}</span>
                  </div>
                </label>
              </div>

              <div className="lg:col-span-3 space-y-3">
                <label className="flex items-start gap-3 p-3 bg-white border border-slate-200 rounded-lg cursor-pointer hover:border-green-400 transition-colors">
                  <input type="checkbox" checked={movementMet} onChange={e => setMovementMet(e.target.checked)} className="mt-0.5 w-5 h-5 rounded border-slate-300 text-green-600 focus:ring-green-600" />
                  <div>
                    <span className="block text-sm font-bold text-slate-800">Movement Quality Met</span>
                    <span className="block text-[10px] text-slate-500 mt-1 leading-tight">{EXIT_CRITERIA[currentLevel as keyof typeof EXIT_CRITERIA]?.movement || ""}</span>
                  </div>
                </label>
              </div>

              <div className="lg:col-span-2">
                <label className="block text-xs font-bold text-slate-700 mb-1">Avg Systemic Score</label>
                <input type="number" step="0.01" value={avgScore} onChange={e => setAvgScore(e.target.value ? parseFloat(e.target.value) : "")} placeholder="2.50" className="w-full p-2.5 text-center font-bold bg-white border border-slate-200 rounded-lg focus:ring-2 focus:ring-amber-400" required />
                <div className="mt-2 text-center">
                  {avgScore !== "" ? (
                    scoreMet ? <span className="text-xs font-bold text-green-600 bg-green-50 px-2 py-1 rounded">✔ Score Passed</span> : <span className="text-xs font-bold text-red-500 bg-red-50 px-2 py-1 rounded">✖ Needs {scoreThreshold}</span>
                  ) : null}
                </div>
              </div>

              <div className="lg:col-span-2 flex flex-col justify-center items-center p-3 bg-white border border-slate-200 rounded-lg">
                <span className="text-xs text-slate-500 font-medium mb-1">Calculated Outcome</span>
                <span className={cn("px-3 py-1 rounded-md font-bold text-sm mb-1", decision === "PROGRESS" ? "text-green-700 bg-green-100" : "text-amber-700 bg-amber-100")}>{decision}</span>
                <span className="text-xs text-slate-500">New Level: <strong className="text-sf-deepNavy">{newLevel}</strong></span>
              </div>

            </div>
          </div>

          {/* SECTION 3: BODY COMPOSITION */}
          <div>
            <h3 className="text-sm font-bold text-slate-800 uppercase tracking-wider mb-4 border-b border-slate-100 pb-2">Body Composition</h3>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
              <div>
                <label className="block text-xs font-bold text-slate-500 mb-1">Gender</label>
                <select value={gender} onChange={e => setGender(e.target.value)} className="w-full p-2.5 bg-slate-50 border border-slate-200 rounded-lg focus:ring-2 focus:ring-amber-400">
                  <option value="Female">Female</option>
                  <option value="Male">Male</option>
                </select>
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-500 mb-1">Height (cm)</label>
                <input type="number" value={height} onChange={e => setHeight(e.target.value ? parseFloat(e.target.value) : "")} className="w-full p-2.5 bg-slate-50 border border-slate-200 rounded-lg focus:ring-2 focus:ring-amber-400" />
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-500 mb-1">Weight (kg)</label>
                <input type="number" step="0.1" value={weight} onChange={e => setWeight(e.target.value ? parseFloat(e.target.value) : "")} className="w-full p-2.5 bg-slate-50 border border-slate-200 rounded-lg focus:ring-2 focus:ring-amber-400" />
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-500 mb-1">Waist Circumference (cm)</label>
                <input type="number" step="0.1" value={waist} onChange={e => setWaist(e.target.value ? parseFloat(e.target.value) : "")} className="w-full p-2.5 bg-slate-50 border border-slate-200 rounded-lg focus:ring-2 focus:ring-amber-400" />
              </div>
            </div>
            {/* Auto-calculated indicators */}
            {(bmi > 0 || waistStatus) && (
              <div className="flex gap-4 mt-3">
                {bmi > 0 && <span className="text-xs bg-blue-50 text-blue-700 px-3 py-1 rounded-full font-medium">BMI: {bmi.toFixed(1)} ({bmiCategory})</span>}
                {waistStatus && <span className={cn("text-xs px-3 py-1 rounded-full font-medium", waistStatus === "At Risk" ? "bg-red-50 text-red-700" : "bg-green-50 text-green-700")}>Waist: {waistStatus}</span>}
              </div>
            )}
          </div>

          {/* SECTION 4: MEDICAL */}
          <div>
            <h3 className="text-sm font-bold text-slate-800 uppercase tracking-wider mb-4 border-b border-slate-100 pb-2">Medical & Records</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-xs font-bold text-slate-500 mb-1">Medical Condition</label>
                <textarea rows={2} value={medicalCondition} onChange={e => setMedicalCondition(e.target.value)} placeholder="Enter medical conditions..." className="w-full p-2.5 bg-slate-50 border border-slate-200 rounded-lg focus:ring-2 focus:ring-amber-400 resize-none" />
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-500 mb-1">Lab Report (PDF URL)</label>
                <input type="url" value={labReport} onChange={e => setLabReport(e.target.value)} placeholder="https://..." className="w-full p-2.5 bg-slate-50 border border-slate-200 rounded-lg focus:ring-2 focus:ring-amber-400 text-blue-600" />
              </div>
            </div>
          </div>

          <div className="pt-4 flex justify-end">
            <button type="submit" disabled={isSubmitting} className="py-3 px-8 bg-black text-amber-400 rounded-xl font-bold hover:bg-slate-800 disabled:opacity-50 flex items-center justify-center gap-2 shadow-lg transition-transform active:scale-95">
              {isSubmitting ? <Activity className="w-5 h-5 animate-spin" /> : <Save className="w-5 h-5" />} SAVE ASSESSMENT
            </button>
          </div>
        </form>
      </div>

      <style dangerouslySetInnerHTML={{__html: `
        .custom-scrollbar::-webkit-scrollbar {
          height: 10px;
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
