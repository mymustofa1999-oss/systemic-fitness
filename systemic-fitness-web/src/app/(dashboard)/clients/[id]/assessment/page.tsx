"use client";

import { useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ArrowLeft, Loader2, Save, FileText } from "lucide-react";
import Link from "next/link";
import { useSubmitAssessmentForUser } from "@/hooks/useAssessmentV2";
import { useUser } from "@/hooks/useUsers";

export default function TrainerAssessmentFormPage() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const { data: userData, isLoading: userLoading } = useUser(params.id);
  const { mutate: submitAssessment, isPending } = useSubmitAssessmentForUser();

  const user = (userData?.data as any)?.user;

  // Form State
  const [phaseA, setPhaseA] = useState({
    physical_status_level: "level_4_5_perf",
    has_medical_condition: false,
    classification_slug: "",
    specific_condition_slug: "",
    primary_goal: "stamina_masculine",
    gender: "men",
    age_bucket: "35_45",
  });

  const [phaseB, setPhaseB] = useState({
    duration_hours: 7,
    consistency: 3,
    sleep_latency: 2,
    morning_readiness: 3,
    wake_frequency: 1,
    pre_sleep_habit: 3,
    bedtime_bucket: 1,
    wake_time_bucket: 1,
    activity_profile: "executive",
    dinner_time: 1,
  });

  const [phaseC, setPhaseC] = useState({
    meal_pattern: 3,
    food_dominance: 1,
    hydration: 4,
    nutrition_goal: "weight",
  });

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    submitAssessment(
      {
        userId: params.id,
        data: {
          phase_a: {
            ...phaseA,
            has_medical_condition: phaseA.has_medical_condition,
            physical_status_level: phaseA.physical_status_level as any,
            gender: phaseA.gender as any,
            age_bucket: phaseA.age_bucket as any,
            primary_goal: phaseA.primary_goal as any,
          },
          phase_b: phaseB,
          phase_c: phaseC,
        },
      },
      {
        onSuccess: () => {
          router.push(`/clients/${params.id}`);
        },
      }
    );
  }

  if (userLoading) {
    return (
      <div className="flex justify-center py-20">
        <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto space-y-6 pb-20">
      <div className="flex items-center gap-4">
        <Link
          href={`/clients/${params.id}`}
          className="p-2 -ml-2 rounded-lg hover:bg-slate-100 text-slate-500 transition-colors"
        >
          <ArrowLeft className="h-5 w-5" />
        </Link>
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Isi Assessment Manual</h1>
          <p className="text-sm text-slate-500 mt-1">
            Trainer dapat mengisi formulir assessment atas nama klien: <span className="font-semibold text-slate-700">{user?.full_name}</span>
          </p>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        {/* PHASE A */}
        <div className="card p-6 border border-slate-200 shadow-sm rounded-xl space-y-4">
          <h2 className="text-lg font-bold text-sf-deepNavy border-b pb-2 mb-4 flex items-center gap-2">
            <FileText className="h-5 w-5 text-sf-systemBlue" />
            Phase A: Kondisi & Program (Wajib)
          </h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="label">Kondisi Gerak</label>
              <select className="input" value={phaseA.physical_status_level} onChange={e => setPhaseA({...phaseA, physical_status_level: e.target.value})}>
                <option value="level_0_1">Level 0-1 (Berbaring/Duduk)</option>
                <option value="level_2_3">Level 2-3 (Bisa Berdiri Terbatas)</option>
                <option value="level_4_5_perf">Level 4-5 (Bisa Berjalan/Performa)</option>
              </select>
            </div>
            <div>
              <label className="label">Kondisi Medis</label>
              <select className="input" value={phaseA.has_medical_condition ? "yes" : "no"} onChange={e => setPhaseA({...phaseA, has_medical_condition: e.target.value === "yes"})}>
                <option value="no">Tidak Ada</option>
                <option value="yes">Ya, Ada Kondisi Medis</option>
              </select>
            </div>
            <div>
              <label className="label">Gender</label>
              <select className="input" value={phaseA.gender} onChange={e => setPhaseA({...phaseA, gender: e.target.value})}>
                <option value="men">Pria</option>
                <option value="women">Wanita</option>
              </select>
            </div>
            <div>
              <label className="label">Usia</label>
              <select className="input" value={phaseA.age_bucket} onChange={e => setPhaseA({...phaseA, age_bucket: e.target.value})}>
                <option value="35_45">35 - 45 Tahun</option>
                <option value="46_60">46 - 60 Tahun</option>
              </select>
            </div>
          </div>
        </div>

        {/* PHASE B */}
        <div className="card p-6 border border-slate-200 shadow-sm rounded-xl space-y-4">
          <h2 className="text-lg font-bold text-sf-deepNavy border-b pb-2 mb-4 flex items-center gap-2">
            <FileText className="h-5 w-5 text-sf-warmGold" />
            Phase B: Rest Audit & Chronobiology (Opsional)
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="label">Durasi Tidur (Jam)</label>
              <input type="number" min="0" max="24" className="input" value={phaseB.duration_hours} onChange={e => setPhaseB({...phaseB, duration_hours: parseFloat(e.target.value)})} />
            </div>
            <div>
              <label className="label">Konsistensi Jam Tidur (1-3)</label>
              <input type="number" min="1" max="3" className="input" value={phaseB.consistency} onChange={e => setPhaseB({...phaseB, consistency: parseInt(e.target.value)})} />
            </div>
            <div>
              <label className="label">Kecepatan Tertidur (1-4)</label>
              <input type="number" min="1" max="4" className="input" value={phaseB.sleep_latency} onChange={e => setPhaseB({...phaseB, sleep_latency: parseInt(e.target.value)})} />
            </div>
            <div>
              <label className="label">Aktivitas</label>
              <select className="input" value={phaseB.activity_profile} onChange={e => setPhaseB({...phaseB, activity_profile: e.target.value})}>
                <option value="executive">Pekerja Kantoran</option>
                <option value="shift_worker">Pekerja Shift</option>
                <option value="traveller">Sering Bepergian</option>
              </select>
            </div>
          </div>
        </div>

        {/* PHASE C */}
        <div className="card p-6 border border-slate-200 shadow-sm rounded-xl space-y-4">
          <h2 className="text-lg font-bold text-sf-deepNavy border-b pb-2 mb-4 flex items-center gap-2">
            <FileText className="h-5 w-5 text-green-500" />
            Phase C: Nutrition (Opsional)
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="label">Pola Makan (1-4)</label>
              <input type="number" min="1" max="4" className="input" value={phaseC.meal_pattern} onChange={e => setPhaseC({...phaseC, meal_pattern: parseInt(e.target.value)})} />
            </div>
            <div>
              <label className="label">Dominansi Makanan (1-3)</label>
              <input type="number" min="1" max="3" className="input" value={phaseC.food_dominance} onChange={e => setPhaseC({...phaseC, food_dominance: parseInt(e.target.value)})} />
            </div>
            <div>
              <label className="label">Gelas Air Per Hari (1-4)</label>
              <input type="number" min="1" max="4" className="input" value={phaseC.hydration} onChange={e => setPhaseC({...phaseC, hydration: parseInt(e.target.value)})} />
            </div>
          </div>
        </div>

        <div className="flex justify-end gap-3 pt-6">
          <button type="button" onClick={() => router.back()} className="btn-secondary" disabled={isPending}>
            Batal
          </button>
          <button type="submit" className="btn-primary" disabled={isPending}>
            {isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />}
            {isPending ? "Menyimpan..." : "Simpan Assessment"}
          </button>
        </div>
      </form>
    </div>
  );
}
