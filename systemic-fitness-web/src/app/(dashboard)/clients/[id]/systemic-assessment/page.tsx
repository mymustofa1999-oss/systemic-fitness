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
  User as UserIcon,
  Ruler,
  Weight,
  FileText,
  AlertTriangle,
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
  const { user } = useUser(params.id);
  const { assessments, mutate, isLoading: isLoadingAssessments } = useQuarterlyAssessments(params.id);
  const { submit, isSubmitting } = useCreateQuarterlyAssessment();

  // Form State
  const [quarter, setQuarter] = useState("Q1");
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
  const decision = isProgress ? "PROGRESS" : "HOLD";
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
      
    } catch (err: any) {
      toast.error(err.message || "Failed to save assessment");
    }
  };

  return (
    <div className="p-4 md:p-8 max-w-7xl mx-auto space-y-6">
      {/* Header */}
      <div className="flex items-center gap-4">
        <Link
          href={`/clients/${params.id}`}
          className="p-2 bg-white border border-slate-200 rounded-lg hover:bg-slate-50 transition-colors"
        >
          <ArrowLeft className="h-5 w-5 text-slate-600" />
        </Link>
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Systemic Assessment</h1>
          <p className="text-sm text-slate-500">
            Quarterly Review for {user ? `${user.first_name} ${user.last_name}` : "Client"}
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* LEFT COLUMN: FORM */}
        <div className="lg:col-span-2 space-y-6">
          <form onSubmit={handleSubmit} className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
            <div className="p-4 border-b border-slate-200 bg-slate-50/50 flex justify-between items-center">
              <h2 className="font-semibold text-slate-900">New Quarterly Review</h2>
            </div>
            
            <div className="p-6 space-y-8">
              {/* Row 1: Basic Info */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-semibold text-slate-500 uppercase mb-1">Quarter</label>
                  <select
                    value={quarter}
                    onChange={(e) => setQuarter(e.target.value)}
                    className="w-full bg-slate-50 border border-slate-200 rounded-lg p-3 text-sm"
                  >
                    <option value="Q1">Q1</option>
                    <option value="Q2">Q2</option>
                    <option value="Q3">Q3</option>
                    <option value="Q4">Q4</option>
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-semibold text-slate-500 uppercase mb-1">Period Range</label>
                  <input
                    type="text"
                    value={periodRange}
                    onChange={(e) => setPeriodRange(e.target.value)}
                    placeholder="e.g., Jan-Mar 2026"
                    className="w-full bg-slate-50 border border-slate-200 rounded-lg p-3 text-sm"
                  />
                </div>
                <div className="md:col-span-2">
                  <label className="block text-xs font-semibold text-slate-500 uppercase mb-1">Review Date</label>
                  <input
                    type="date"
                    value={reviewDate}
                    onChange={(e) => setReviewDate(e.target.value)}
                    required
                    className="w-full bg-slate-50 border border-slate-200 rounded-lg p-3 text-sm"
                  />
                </div>
              </div>

              {/* Row 2: Level & Exit Criteria */}
              <div className="bg-slate-50 rounded-xl p-5 border border-slate-200 space-y-4">
                <div className="flex justify-between items-center">
                  <h3 className="font-semibold text-slate-800 flex items-center gap-2">
                    <Activity className="w-4 h-4 text-sf-deepNavy" /> Level & Exit Criteria
                  </h3>
                  <div className="w-1/3">
                    <label className="block text-xs font-semibold text-slate-500 uppercase mb-1">Current Level</label>
                    <select
                      value={currentLevel}
                      onChange={(e) => setCurrentLevel(Number(e.target.value))}
                      className="w-full bg-white border border-slate-200 rounded-lg p-2.5 text-sm font-semibold text-slate-900"
                    >
                      {[1, 2, 3, 4, 5, 6].map((l) => (
                        <option key={l} value={l}>Level {l}</option>
                      ))}
                    </select>
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-3">
                    <div>
                      <p className="text-xs font-semibold text-slate-500 uppercase mb-1">Functional Criteria</p>
                      <div className="text-xs text-slate-600 bg-white p-3 rounded-lg border border-slate-200 whitespace-pre-wrap min-h-[100px]">
                        {EXIT_CRITERIA[currentLevel as keyof typeof EXIT_CRITERIA].functional}
                      </div>
                    </div>
                    <label className="flex items-center gap-2 cursor-pointer p-2 hover:bg-slate-100 rounded-lg transition-colors">
                      <input
                        type="checkbox"
                        checked={functionalMet}
                        onChange={(e) => setFunctionalMet(e.target.checked)}
                        className="w-4 h-4 text-green-600 rounded border-slate-300 focus:ring-green-600"
                      />
                      <span className="text-sm font-medium text-slate-700">All functional criteria met</span>
                    </label>
                  </div>
                  
                  <div className="space-y-3">
                    <div>
                      <p className="text-xs font-semibold text-slate-500 uppercase mb-1">Movement Quality Criteria</p>
                      <div className="text-xs text-slate-600 bg-white p-3 rounded-lg border border-slate-200 whitespace-pre-wrap min-h-[100px]">
                        {EXIT_CRITERIA[currentLevel as keyof typeof EXIT_CRITERIA].movement}
                      </div>
                    </div>
                    <label className="flex items-center gap-2 cursor-pointer p-2 hover:bg-slate-100 rounded-lg transition-colors">
                      <input
                        type="checkbox"
                        checked={movementMet}
                        onChange={(e) => setMovementMet(e.target.checked)}
                        className="w-4 h-4 text-green-600 rounded border-slate-300 focus:ring-green-600"
                      />
                      <span className="text-sm font-medium text-slate-700">All movement quality met</span>
                    </label>
                  </div>
                </div>
              </div>

              {/* Row 3: Score & Decision */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-xs font-semibold text-slate-500 uppercase mb-1">
                    Avg Systemic Score
                  </label>
                  <p className="text-[10px] text-slate-400 mb-2">Must be &gt; {scoreThreshold} to pass</p>
                  <input
                    type="number"
                    step="0.01"
                    required
                    value={avgScore}
                    onChange={(e) => setAvgScore(e.target.value ? parseFloat(e.target.value) : "")}
                    className="w-full bg-slate-50 border border-slate-200 rounded-lg p-3 text-sm"
                    placeholder="e.g., 2.50"
                  />
                  {typeof avgScore === "number" && (
                    <div className={cn("mt-2 text-xs flex items-center gap-1", scoreMet ? "text-green-600" : "text-slate-500")}>
                      {scoreMet ? <CheckCircle className="w-3 h-3" /> : <XCircle className="w-3 h-3" />}
                      {scoreMet ? "Score threshold met" : "Score too low"}
                    </div>
                  )}
                </div>

                <div className="bg-slate-50 p-4 rounded-xl border border-slate-200 flex flex-col justify-center items-center">
                  <p className="text-xs font-semibold text-slate-500 uppercase mb-2">Quarterly Decision</p>
                  <div className={cn(
                    "px-4 py-2 rounded-full font-bold text-sm",
                    decision === "PROGRESS" ? "bg-green-100 text-green-700" : "bg-amber-100 text-amber-700"
                  )}>
                    {decision}
                  </div>
                  {decision === "PROGRESS" && (
                    <p className="mt-2 text-xs text-slate-600">
                      Advances to <strong>Level {newLevel}</strong>
                    </p>
                  )}
                </div>
              </div>

              <hr className="border-slate-200" />

              {/* Row 4: Body Composition & Medical */}
              <div>
                <h3 className="font-semibold text-slate-800 flex items-center gap-2 mb-4">
                  <UserIcon className="w-4 h-4 text-sf-deepNavy" /> Body Composition & Medical
                </h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label className="block text-xs font-semibold text-slate-500 uppercase mb-1">Gender</label>
                    <select
                      value={gender}
                      onChange={(e) => setGender(e.target.value)}
                      className="w-full bg-slate-50 border border-slate-200 rounded-lg p-3 text-sm"
                    >
                      <option value="Female">Female</option>
                      <option value="Male">Male</option>
                    </select>
                  </div>
                  <div>
                    <label className="block text-xs font-semibold text-slate-500 uppercase mb-1">Height (cm)</label>
                    <input
                      type="number"
                      value={height}
                      onChange={(e) => setHeight(e.target.value ? parseFloat(e.target.value) : "")}
                      className="w-full bg-slate-50 border border-slate-200 rounded-lg p-3 text-sm"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-semibold text-slate-500 uppercase mb-1">Weight (kg)</label>
                    <input
                      type="number"
                      step="0.1"
                      value={weight}
                      onChange={(e) => setWeight(e.target.value ? parseFloat(e.target.value) : "")}
                      className="w-full bg-slate-50 border border-slate-200 rounded-lg p-3 text-sm"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-semibold text-slate-500 uppercase mb-1">Waist (cm)</label>
                    <input
                      type="number"
                      step="0.1"
                      value={waist}
                      onChange={(e) => setWaist(e.target.value ? parseFloat(e.target.value) : "")}
                      className="w-full bg-slate-50 border border-slate-200 rounded-lg p-3 text-sm"
                    />
                  </div>
                </div>

                {/* Auto Calcs display */}
                {(bmi > 0 || waistStatus) && (
                  <div className="mt-4 p-3 bg-blue-50/50 rounded-lg border border-blue-100 grid grid-cols-2 gap-4 text-sm">
                    <div>
                      <span className="text-slate-500">BMI:</span> <span className="font-semibold">{bmi.toFixed(1)}</span>{" "}
                      <span className={cn(
                        "text-xs px-2 py-0.5 rounded-full",
                        bmiCategory === "Normal" ? "bg-green-100 text-green-700" :
                        bmiCategory.includes("Obese") ? "bg-slate-200 text-slate-700" :
                        "bg-amber-100 text-amber-700"
                      )}>{bmiCategory}</span>
                    </div>
                    <div>
                      <span className="text-slate-500">Waist Status:</span>{" "}
                      <span className={cn(
                        "font-semibold",
                        waistStatus === "Within Range" ? "text-green-600" : "text-slate-600"
                      )}>{waistStatus}</span>
                    </div>
                  </div>
                )}

                <div className="mt-4 space-y-4">
                  <div>
                    <label className="block text-xs font-semibold text-slate-500 uppercase mb-1">Medical Condition</label>
                    <input
                      type="text"
                      value={medicalCondition}
                      onChange={(e) => setMedicalCondition(e.target.value)}
                      placeholder="List any ongoing medical conditions..."
                      className="w-full bg-slate-50 border border-slate-200 rounded-lg p-3 text-sm"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-semibold text-slate-500 uppercase mb-1">Lab Report (PDF Link)</label>
                    <input
                      type="url"
                      value={labReport}
                      onChange={(e) => setLabReport(e.target.value)}
                      placeholder="https://..."
                      className="w-full bg-slate-50 border border-slate-200 rounded-lg p-3 text-sm text-blue-600"
                    />
                  </div>
                </div>
              </div>
            </div>

            <div className="p-4 bg-slate-50 border-t border-slate-200 flex justify-end">
              <button
                type="submit"
                disabled={isSubmitting}
                className="flex items-center gap-2 px-6 py-2 bg-sf-deepNavy text-white rounded-xl hover:bg-slate-800 transition-colors disabled:opacity-50"
              >
                <Save className="w-4 h-4" />
                {isSubmitting ? "Saving..." : "Save Assessment"}
              </button>
            </div>
          </form>
        </div>

        {/* RIGHT COLUMN: HISTORY */}
        <div className="space-y-4">
          <h2 className="font-semibold text-slate-900 px-1">Assessment History</h2>
          
          {isLoadingAssessments ? (
            <div className="text-sm text-slate-500 p-4">Loading history...</div>
          ) : assessments.length === 0 ? (
            <div className="bg-slate-50 border border-slate-200 border-dashed rounded-xl p-8 text-center">
              <FileText className="w-8 h-8 text-slate-300 mx-auto mb-2" />
              <p className="text-sm text-slate-500">No quarterly assessments recorded yet.</p>
            </div>
          ) : (
            <div className="space-y-3">
              {assessments.map((a) => (
                <div key={a.id} className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm relative overflow-hidden">
                  <div className={cn(
                    "absolute top-0 left-0 w-1 h-full",
                    a.decision === "PROGRESS" ? "bg-green-500" : "bg-amber-500"
                  )} />
                  <div className="flex justify-between items-start mb-2 pl-2">
                    <div>
                      <h4 className="font-bold text-slate-900">{a.quarter}</h4>
                      <p className="text-[10px] text-slate-500">{new Date(a.review_date).toLocaleDateString()}</p>
                    </div>
                    <span className={cn(
                      "text-xs font-bold px-2 py-1 rounded-md",
                      a.decision === "PROGRESS" ? "bg-green-50 text-green-700" : "bg-amber-50 text-amber-700"
                    )}>
                      {a.decision}
                    </span>
                  </div>
                  
                  <div className="pl-2 space-y-1 mt-3 text-xs text-slate-600">
                    <p>Level: <strong className="text-slate-900">{a.current_level}</strong> → {a.new_level ? <strong className="text-slate-900">{a.new_level}</strong> : "HOLD"}</p>
                    <p>Score: <strong>{a.avg_systemic_score}</strong></p>
                    {a.bmi_category && <p>BMI: {a.bmi_category}</p>}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
