"use client";

import { useState, useEffect } from "react";
import { useParams, useRouter } from "next/navigation";
import { ArrowLeft, Loader2, Save, Activity, CalendarDays, Pill, Utensils, HeartPulse, Plus, Trash2 } from "lucide-react";
import Link from "next/link";
import { useUser } from "@/hooks/useUsers";
import { useCustomerMedicines, useCustomerPrograms, useCustomerSetup, useTeam, useUpsertHRZone } from "@/hooks/useNewFeatures";
import { useTrainingSessionLogs, useUpsertTrainingSessionLogs, TrainingSessionLog } from "@/hooks/useTrainingSessionLogs";
import { useQuery } from "@tanstack/react-query";
import { apiGet } from "@/lib/api";
import { cn } from "@/lib/utils";
import { MedicinesCard } from "@/components/shared/MedicinesCard";
import { HRZoneTable } from "@/components/shared/HRZoneTable";

const MONTHS = [
  "Januari", "Februari", "Maret", "April", "Mei", "Juni",
  "Juli", "Agustus", "September", "Oktober", "November", "Desember"
];

const DEFAULT_ROWS = 8;

export default function TrainingSessionLogPage() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const userId = params.id;

  const currentMonth = `${MONTHS[new Date().getMonth()]} ${new Date().getFullYear()}`;
  const [periodName, setPeriodName] = useState(currentMonth);

  const { data: userData, isLoading: userLoading } = useUser(userId);
  const { data: medsData } = useCustomerMedicines(userId);
  const { data: progsData } = useCustomerPrograms(userId);
  
  const { data: logsData, isLoading: logsLoading } = useTrainingSessionLogs(userId, periodName);
  const upsertLogs = useUpsertTrainingSessionLogs();
  const { data: setupData } = useCustomerSetup(userId);
  const setup = setupData?.data as any;

  const { data: teamData } = useTeam({ limit: 100 });
  const teamMembers = (teamData?.data as any[]) || [];

  const { data: profileData } = useQuery({ 
    queryKey: ["users", userId, "profile"], 
    queryFn: () => apiGet(`/api/users/${userId}/profile`) 
  });
  const profile = (profileData as any)?.data;

  const user = (userData?.data as any)?.user;
  const staff = setup?.staff;
  const consultantName = teamMembers.find(t => t.id === staff?.consultant_id)?.full_name || "-";
  const trainerName = teamMembers.find(t => t.id === staff?.trainer_id)?.full_name || "-";

  const activeProgram = (progsData?.data as any[])?.find(p => p.status === "active")?.program_category_name || "N/A";
  
  const dobStr = profile?.date_of_birth || user?.date_of_birth;
  const dob = dobStr ? new Date(dobStr) : null;
  const age = dob ? Math.floor((new Date().getTime() - dob.getTime()) / 31557600000) : "-";
  const formattedDob = dob ? new Intl.DateTimeFormat("id-ID", { day: "numeric", month: "long", year: "numeric" }).format(dob) : "-";
  const dobParts = formattedDob !== "-" ? formattedDob.split(" ") : ["-", "", ""];
  const dobDayMonth = dobParts[0] + " " + dobParts[1];
  const dobYear = dobParts[2];

  const maxHrCalc = age !== "-" ? 220 - (age as number) : null;
  
  const [editingHR, setEditingHR] = useState(false);
  const [hrForm, setHrForm] = useState(() => ({
    max_hr_upper: setup?.hr_zone?.max_hr_upper ?? (maxHrCalc || ""),
    zone5_lower: setup?.hr_zone?.zone5_lower ?? (maxHrCalc ? Math.round(0.9 * maxHrCalc) : ""),
    zone3_lower: setup?.hr_zone?.zone3_lower ?? (maxHrCalc ? Math.round(0.7 * maxHrCalc) : ""),
    zone2_lower: setup?.hr_zone?.zone2_lower ?? (maxHrCalc ? Math.round(0.6 * maxHrCalc) : ""),
    zone1_lower: setup?.hr_zone?.zone1_lower ?? (maxHrCalc ? Math.round(0.5 * maxHrCalc) : ""),
  }));

  useEffect(() => {
    if (!editingHR) {
      setHrForm({
        max_hr_upper: setup?.hr_zone?.max_hr_upper ?? (maxHrCalc || ""),
        zone5_lower: setup?.hr_zone?.zone5_lower ?? (maxHrCalc ? Math.round(0.9 * maxHrCalc) : ""),
        zone3_lower: setup?.hr_zone?.zone3_lower ?? (maxHrCalc ? Math.round(0.7 * maxHrCalc) : ""),
        zone2_lower: setup?.hr_zone?.zone2_lower ?? (maxHrCalc ? Math.round(0.6 * maxHrCalc) : ""),
        zone1_lower: setup?.hr_zone?.zone1_lower ?? (maxHrCalc ? Math.round(0.5 * maxHrCalc) : ""),
      });
    }
  }, [setup?.hr_zone, maxHrCalc, editingHR]);

  const upsertHR = useUpsertHRZone();
  function handleSaveHR() {
    upsertHR.mutate({
      customerId: userId,
      max_hr_upper: hrForm.max_hr_upper === "" ? null : Number(hrForm.max_hr_upper),
      zone5_lower: hrForm.zone5_lower === "" ? null : Number(hrForm.zone5_lower),
      zone3_lower: hrForm.zone3_lower === "" ? null : Number(hrForm.zone3_lower),
      zone2_lower: hrForm.zone2_lower === "" ? null : Number(hrForm.zone2_lower),
      zone1_lower: hrForm.zone1_lower === "" ? null : Number(hrForm.zone1_lower),
    }, { onSuccess: () => setEditingHR(false) });
  }

  const hrZones = [
    { label: "Max HR", key: "max_hr_upper", value: hrForm.max_hr_upper || "-" },
    { label: "Zona 5", key: "zone5_lower", value: hrForm.zone5_lower || "-" },
    { label: "Zona 3", key: "zone3_lower", value: hrForm.zone3_lower || "-" },
    { label: "Zona 2", key: "zone2_lower", value: hrForm.zone2_lower || "-" },
    { label: "Zona 1", key: "zone1_lower", value: hrForm.zone1_lower || "-" },
  ];

  const [rows, setRows] = useState<TrainingSessionLog[]>([]);

  useEffect(() => {
    if (logsLoading) return; // Don't do anything while loading

    if (logsData && Array.isArray(logsData) && logsData.length > 0) {
      setRows(logsData);
    } else {
      // Initialize empty rows (fallback if logsData is null/undefined/empty)
      const emptyRows: TrainingSessionLog[] = Array.from({ length: DEFAULT_ROWS }).map((_, i) => ({
        period_name: periodName,
        session_number: i + 1,
        date: "",
        took_medicine: false,
      }));
      setRows(emptyRows);
    }
  }, [logsData, logsLoading, periodName]);

  const handleRowChange = (index: number, field: keyof TrainingSessionLog, value: any) => {
    const newRows = [...rows];
    newRows[index] = { ...newRows[index], [field]: value };
    setRows(newRows);
  };

  const handleSave = () => {
    // Only save rows that have at least a date or took_medicine checked or any other value
    const filledRows = rows.map(r => ({
      ...r,
      date: r.date ? new Date(r.date).toISOString() : null,
      last_meal_hours: r.last_meal_hours || null,
      bp_pre_systolic: r.bp_pre_systolic || null,
      bp_pre_diastolic: r.bp_pre_diastolic || null,
      hr_pre: r.hr_pre || null,
      bp_post_systolic: r.bp_post_systolic || null,
      bp_post_diastolic: r.bp_post_diastolic || null,
      hr_post: r.hr_post || null,
    }));
    
    upsertLogs.mutate({ userId, periodName, logs: filledRows });
  };

  if (userLoading) {
    return (
      <div className="flex justify-center py-20">
        <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
      </div>
    );
  }

  // Calculate Averages
  const calcAvg = (field: keyof TrainingSessionLog) => {
    const validVals = rows.map(r => r[field]).filter(v => typeof v === "number" && v > 0) as number[];
    if (validVals.length === 0) return 0;
    const sum = validVals.reduce((a, b) => a + b, 0);
    return Math.round(sum / validVals.length);
  };

  return (
    <div className="max-w-7xl mx-auto space-y-6 pb-20">
      {/* Header */}
      <div className="flex items-center gap-4">
        <Link href={`/clients/${userId}`} className="p-2 -ml-2 rounded-lg hover:bg-slate-100 text-slate-500 transition-colors">
          <ArrowLeft className="h-5 w-5" />
        </Link>
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Training Session Log</h1>
          <p className="text-sm text-slate-500 mt-1">
            Log harian BP, HR, dan Makanan klien: <span className="font-semibold text-slate-700">{user?.full_name}</span>
          </p>
        </div>
      </div>

      {/* Info Card (PDF Table Layout - Modernized) */}
      <div className="overflow-x-auto w-full mb-6 bg-white rounded-xl shadow-sm border border-slate-200">
        <table className="w-full border-collapse text-xs text-slate-700">
          <tbody>
            <tr className="border-b border-slate-200">
              <td className="border-r border-slate-200 font-bold p-2.5 px-4 w-[12%] text-slate-600">Nama</td>
              <td colSpan={2} className="border-r border-slate-200 p-2.5 px-4 font-semibold w-[22%] text-slate-900">{user?.full_name}</td>
              <td rowSpan={8} className="border-r border-slate-200 text-center w-12 align-middle bg-slate-50">
                <span className="inline-block whitespace-nowrap font-semibold text-slate-500 uppercase tracking-widest text-[10px]" style={{ writingMode: "vertical-rl", transform: "rotate(180deg)" }}>
                  Daftar Obat
                </span>
              </td>
              <td rowSpan={8} className="border-r border-slate-200 p-2.5 px-4 align-top w-[18%] leading-loose">
                {((medsData as any)?.data || []).length > 0 ? (
                  ((medsData as any)?.data || []).map((m: any) => (
                    <div key={m.id} className="flex items-center gap-1.5 mb-1.5">
                      <div className="h-1.5 w-1.5 rounded-full bg-slate-300"></div>
                      <span className="font-medium text-slate-700">{m.medicine_name}</span>
                    </div>
                  ))
                ) : <span className="text-slate-400 italic">Tidak ada</span>}
              </td>
              <td className="border-r border-slate-200 font-bold p-2.5 px-4 w-[12%] bg-slate-50/80 text-slate-600">Consultant</td>
              <td className="border-r border-slate-200 p-2.5 px-4 w-[15%] text-slate-800">{consultantName}</td>
              <td className="border-r border-slate-200 font-bold p-2.5 px-4 w-[10%] bg-slate-50/80 text-slate-600">Trainer</td>
              <td className="p-2.5 px-4 w-[15%] text-slate-800">{trainerName}</td>
            </tr>
            <tr className="border-b border-slate-200">
              <td className="border-r border-slate-200 font-bold p-2.5 px-4 text-slate-600">Tanggal Lahir</td>
              <td className="border-r border-slate-200 p-2.5 px-4 text-slate-800">{dobDayMonth}</td>
              <td className="border-r border-slate-200 p-2.5 px-4 text-center text-slate-800">{dobYear}</td>
              <td rowSpan={2} className="border-r border-slate-200 p-2.5 px-4 font-bold text-center bg-slate-50 text-slate-600 align-middle">Prioritas</td>
              <td colSpan={3} rowSpan={2} className="p-2.5 px-4 bg-rose-50 text-center font-bold text-sm text-rose-700 align-middle">
                {activeProgram}
              </td>
            </tr>
            <tr className="border-b border-slate-200">
              <td className="border-r border-slate-200 font-bold p-2.5 px-4 text-slate-600">Usia</td>
              <td className="border-r border-slate-200 p-2.5 px-4 font-semibold text-slate-800" colSpan={2}>{age}</td>
            </tr>
          </tbody>
        </table>
        
        <div className="mt-4 mb-2">
          <HRZoneTable 
            hrZones={hrZones}
            editingHR={editingHR}
            hrForm={hrForm}
            setHrForm={setHrForm}
            handleSaveHR={handleSaveHR}
            isPending={upsertHR.isPending}
            setEditingHR={setEditingHR}
          />
        </div>
      </div>

      {/* Medis & Biometrik */}
      <div className="mb-6">
         <h2 className="text-sm font-bold text-slate-800 uppercase tracking-wider mb-3 flex items-center gap-2">
           <Pill className="h-4 w-4 text-emerald-500" /> Kelola Daftar Obat
         </h2>
         <div className="grid grid-cols-1 gap-4">
            
            <MedicinesCard customerId={userId} data={setup?.medicines ?? []} />
         </div>
      </div>

      {/* Main Table */}
      <div className="card border border-slate-200 shadow-sm rounded-xl overflow-hidden bg-white">
        <div className="p-4 border-b border-slate-200 bg-slate-50 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <CalendarDays className="h-5 w-5 text-sf-deepNavy" />
            <input 
              type="text" 
              value={periodName}
              onChange={(e) => setPeriodName(e.target.value)}
              className="text-lg font-bold bg-transparent border-b border-dashed border-slate-400 focus:border-sf-deepNavy focus:outline-none px-1"
            />
          </div>
          <button onClick={handleSave} disabled={upsertLogs.isPending || logsLoading} className="btn-primary flex items-center gap-2">
            {upsertLogs.isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />}
            Simpan Data
          </button>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-slate-100 border-b border-slate-200">
                <th className="px-3 py-3 font-semibold text-slate-600 text-center w-16" rowSpan={2}>Sesi</th>
                <th className="px-3 py-3 font-semibold text-slate-600 text-left w-36" rowSpan={2}>Tanggal</th>
                <th className="px-3 py-3 font-semibold text-slate-600 text-center w-16" rowSpan={2}>Obat</th>
                <th className="px-3 py-3 font-semibold text-slate-600 text-center border-l border-slate-200" colSpan={2}>Last Meal</th>
                <th className="px-3 py-3 font-semibold text-slate-600 text-center border-l border-slate-200 bg-blue-50/50" colSpan={3}>BP Pre-Workout</th>
                <th className="px-3 py-3 font-semibold text-slate-600 text-center border-l border-slate-200 bg-rose-50/50" colSpan={3}>BP Post-Workout</th>
              </tr>
              <tr className="bg-slate-50 border-b border-slate-200">
                <th className="px-3 py-2 font-medium text-slate-500 text-center border-l border-slate-200 text-xs">Jam</th>
                <th className="px-3 py-2 font-medium text-slate-500 text-left text-xs">Makanan</th>
                <th className="px-2 py-2 font-medium text-slate-500 text-center border-l border-slate-200 text-xs bg-blue-50/30">SYS</th>
                <th className="px-2 py-2 font-medium text-slate-500 text-center text-xs bg-blue-50/30">DIA</th>
                <th className="px-2 py-2 font-medium text-slate-500 text-center text-xs bg-blue-50/30">HR</th>
                <th className="px-2 py-2 font-medium text-slate-500 text-center border-l border-slate-200 text-xs bg-rose-50/30">SYS</th>
                <th className="px-2 py-2 font-medium text-slate-500 text-center text-xs bg-rose-50/30">DIA</th>
                <th className="px-2 py-2 font-medium text-slate-500 text-center text-xs bg-rose-50/30">HR</th>
              </tr>
            </thead>
            <tbody>
              {logsLoading ? (
                <tr><td colSpan={11} className="py-10 text-center"><Loader2 className="h-6 w-6 animate-spin text-slate-400 mx-auto" /></td></tr>
              ) : rows.map((row, i) => (
                <tr key={i} className="border-b border-slate-100 hover:bg-slate-50/50">
                  <td className="px-3 py-2 text-center font-medium text-slate-500">{row.session_number}</td>
                  <td className="px-3 py-2">
                    <input type="date" value={row.date ? row.date.substring(0,10) : ""} onChange={(e) => handleRowChange(i, "date", e.target.value)} className="w-full bg-transparent border-0 focus:ring-1 focus:ring-sf-deepNavy rounded text-sm px-1 py-1" />
                  </td>
                  <td className="px-3 py-2 text-center">
                    <input type="checkbox" checked={row.took_medicine} onChange={(e) => handleRowChange(i, "took_medicine", e.target.checked)} className="h-4 w-4 rounded border-slate-300 text-sf-deepNavy focus:ring-sf-deepNavy" />
                  </td>
                  <td className="px-2 py-2 border-l border-slate-100 text-center">
                    <input type="number" step="0.5" value={row.last_meal_hours || ""} onChange={(e) => handleRowChange(i, "last_meal_hours", parseFloat(e.target.value))} className="w-16 bg-transparent border-0 text-center focus:ring-1 focus:ring-sf-deepNavy rounded px-1 py-1" placeholder="3.5" />
                  </td>
                  <td className="px-2 py-2">
                    <input type="text" value={row.last_meal_food || ""} onChange={(e) => handleRowChange(i, "last_meal_food", e.target.value)} className="w-full min-w-[120px] bg-transparent border-0 focus:ring-1 focus:ring-sf-deepNavy rounded px-1 py-1" placeholder="Nasi, sayur..." />
                  </td>
                  
                  {/* Pre */}
                  <td className="px-1 py-2 border-l border-slate-100 bg-blue-50/10">
                    <input type="number" value={row.bp_pre_systolic || ""} onChange={(e) => handleRowChange(i, "bp_pre_systolic", parseInt(e.target.value))} className="w-14 bg-transparent border-0 text-center focus:ring-1 focus:ring-blue-500 rounded px-1 py-1 text-slate-700" />
                  </td>
                  <td className="px-1 py-2 bg-blue-50/10">
                    <input type="number" value={row.bp_pre_diastolic || ""} onChange={(e) => handleRowChange(i, "bp_pre_diastolic", parseInt(e.target.value))} className="w-14 bg-transparent border-0 text-center focus:ring-1 focus:ring-blue-500 rounded px-1 py-1 text-slate-700" />
                  </td>
                  <td className="px-1 py-2 bg-blue-50/10">
                    <input type="number" value={row.hr_pre || ""} onChange={(e) => handleRowChange(i, "hr_pre", parseInt(e.target.value))} className="w-14 bg-transparent border-0 text-center focus:ring-1 focus:ring-blue-500 rounded px-1 py-1 text-slate-700" />
                  </td>

                  {/* Post */}
                  <td className="px-1 py-2 border-l border-slate-100 bg-rose-50/10">
                    <input type="number" value={row.bp_post_systolic || ""} onChange={(e) => handleRowChange(i, "bp_post_systolic", parseInt(e.target.value))} className="w-14 bg-transparent border-0 text-center focus:ring-1 focus:ring-rose-500 rounded px-1 py-1 text-slate-700" />
                  </td>
                  <td className="px-1 py-2 bg-rose-50/10">
                    <input type="number" value={row.bp_post_diastolic || ""} onChange={(e) => handleRowChange(i, "bp_post_diastolic", parseInt(e.target.value))} className="w-14 bg-transparent border-0 text-center focus:ring-1 focus:ring-rose-500 rounded px-1 py-1 text-slate-700" />
                  </td>
                  <td className="px-1 py-2 bg-rose-50/10">
                    <input type="number" value={row.hr_post || ""} onChange={(e) => handleRowChange(i, "hr_post", parseInt(e.target.value))} className="w-14 bg-transparent border-0 text-center focus:ring-1 focus:ring-rose-500 rounded px-1 py-1 font-bold text-slate-700" />
                  </td>
                </tr>
              ))}
            </tbody>
            {/* Average Footer */}
            {!logsLoading && rows.length > 0 && (
              <tfoot>
                <tr className="bg-slate-800 text-white font-bold">
                  <td colSpan={5} className="px-4 py-3 text-right border-r border-slate-700">Average</td>
                  <td className="px-1 py-3 text-center">{calcAvg("bp_pre_systolic") || "-"}</td>
                  <td className="px-1 py-3 text-center">{calcAvg("bp_pre_diastolic") || "-"}</td>
                  <td className="px-1 py-3 text-center text-blue-300">{calcAvg("hr_pre") || "-"}</td>
                  <td className="px-1 py-3 text-center border-l border-slate-700">{calcAvg("bp_post_systolic") || "-"}</td>
                  <td className="px-1 py-3 text-center">{calcAvg("bp_post_diastolic") || "-"}</td>
                  <td className="px-1 py-3 text-center text-rose-300">{calcAvg("hr_post") || "-"}</td>
                </tr>
              </tfoot>
            )}
          </table>
        </div>
      </div>
    </div>
  );
}
