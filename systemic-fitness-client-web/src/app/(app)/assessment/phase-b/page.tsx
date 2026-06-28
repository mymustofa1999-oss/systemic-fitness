"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useAssessmentStore } from "@/stores/assessmentStore";
import { PhaseHeader } from "@/components/assessment/PhaseHeader";
import { SelectCard } from "@/components/assessment/SelectCard";
import { BottomCta } from "@/components/assessment/BottomCta";
import { toast } from "@/stores/toastStore";

export default function PhaseBPage() {
  const router = useRouter();
  const draftPhaseA = useAssessmentStore((state) => state.draft.phaseA);
  const storeDraft = useAssessmentStore((state) => state.draft.phaseB);
  const draft = {
    durationHours: storeDraft?.durationHours ?? 7.0,
    consistency: storeDraft?.consistency,
    sleepLatency: storeDraft?.sleepLatency,
    morningReadiness: storeDraft?.morningReadiness,
    wakeFrequency: storeDraft?.wakeFrequency,
    preSleepHabit: storeDraft?.preSleepHabit,
    bedtimeBucket: storeDraft?.bedtimeBucket,
    wakeTimeBucket: storeDraft?.wakeTimeBucket,
    activityProfile: storeDraft?.activityProfile,
    dinnerTime: storeDraft?.dinnerTime,
  };
  const setPhaseB = useAssessmentStore((state) => state.setPhaseB);

  useEffect(() => {
    // 1. Check Phase A
    const isPhaseAComplete =
      draftPhaseA.physicalStatusLevel &&
      draftPhaseA.physicalStatusLevel !== "level_0_1" &&
      draftPhaseA.physicalStatusLevel !== "level_2_3" &&
      (draftPhaseA.hasMedicalCondition
        ? !!(draftPhaseA.classificationSlug && draftPhaseA.specificConditionSlug && draftPhaseA.primaryGoal)
        : !!(draftPhaseA.gender && draftPhaseA.ageBucket));

    if (!isPhaseAComplete) {
      toast.error("Mohon lengkapi Penilaian Kondisi terlebih dahulu.");
      router.push("/assessment");
      return;
    }

    // 2. Check Movement Test if non-medical path
    if (!draftPhaseA.hasMedicalCondition) {
      const m = draftPhaseA.movementTest;
      const isMovementComplete =
        m && m.squat !== undefined && m.hipHinge !== undefined && m.overhead !== undefined;

      if (!isMovementComplete) {
        toast.error("Mohon lengkapi Tes Gerakan Dasar terlebih dahulu.");
        router.push("/assessment/phase-a/movement");
        return;
      }
    }
  }, [draftPhaseA, router]);

  // Track if all required questions (B2-B10) are answered
  const answeredCount = [
    draft.consistency,
    draft.sleepLatency,
    draft.morningReadiness,
    draft.wakeFrequency,
    draft.preSleepHabit,
    draft.bedtimeBucket,
    draft.wakeTimeBucket,
    draft.activityProfile,
    draft.dinnerTime,
  ].filter((v) => v !== undefined).length + 1; // +1 for B1 which has a default

  const canContinue = answeredCount >= 10;

  const handleContinue = () => {
    router.push("/assessment/phase-c");
  };

  return (
    <div className="min-h-screen bg-bg-primary flex flex-col max-w-lg mx-auto shadow-sm">
      <PhaseHeader currentPhase={1} title="Pola Tidur & Aktivitas" subProgress={`${answeredCount}/10`} />

      <div className="flex-1 px-5 py-5 overflow-y-auto space-y-7 pb-28">
        {/* B1 */}
        <div className="w-full">
          <QHeader no="B1" label="Rata-rata berapa jam anda tidur per malam?" />
          <div className="mt-4 p-5 rounded-xl bg-bg-card border border-sf-warmGold/40 text-center">
            <div className="flex items-center justify-center mb-4">
              <span className="text-3xl font-bold text-sf-warmGoldDark dark:text-sf-warmGold">
                {draft.durationHours.toFixed(1)}
              </span>
              <span className="text-sm text-text-secondary ml-1.5 mt-2">jam</span>
            </div>
            <input
              type="range"
              min={4.0}
              max={10.0}
              step={0.5}
              value={draft.durationHours}
              onChange={(e) => setPhaseB({ durationHours: parseFloat(e.target.value) })}
              className="w-full h-1.5 bg-border-color rounded-lg appearance-none cursor-pointer accent-sf-warmGold"
            />
            <div className="flex justify-between mt-3 px-1 text-[10px] font-medium text-text-secondary">
              <span>4 jam</span>
              <span className="text-teal-600 dark:text-teal-400">7–8 optimal</span>
              <span>10 jam</span>
            </div>
          </div>
        </div>

        {/* B2 */}
        <SingleQ
          no="B2"
          label="Seberapa konsisten jam tidur dan bangun anda?"
          options={[
            { value: 1, label: "Sangat tidak teratur — berbeda lebih dari 2 jam setiap hari" },
            { value: 2, label: "Kadang berubah — berbeda sekitar 1–2 jam" },
            { value: 3, label: "Teratur setiap hari — hampir selalu di jam yang sama" },
          ]}
          selected={draft.consistency}
          onChanged={(val) => setPhaseB({ consistency: val as number })}
        />

        {/* B3 */}
        <SingleQ
          no="B3"
          label="Berapa lama biasanya anda butuh untuk tertidur?"
          description="Indikator kortisol & gula darah malam."
          options={[
            { value: 1, label: "Kurang dari 15 menit — langsung mengantuk (optimal)" },
            { value: 2, label: "15–30 menit — cukup normal" },
            { value: 3, label: "30–45 menit — agak sulit tidur" },
            { value: 4, label: "Lebih dari 45 menit — sulit sekali tidur" },
          ]}
          selected={draft.sleepLatency}
          onChanged={(val) => setPhaseB({ sleepLatency: val as number })}
        />

        {/* B4 */}
        <SingleQ
          no="B4"
          label="Bagaimana perasaan anda saat bangun pagi?"
          options={[
            { value: 1, label: "Lelah / pusing — tidak terasa sudah tidur" },
            { value: 2, label: "Biasa saja — butuh beberapa menit untuk segar" },
            { value: 3, label: "Segar & langsung bertenaga" },
          ]}
          selected={draft.morningReadiness}
          onChanged={(val) => setPhaseB({ morningReadiness: val as number })}
        />

        {/* B5 */}
        <SingleQ
          no="B5"
          label="Seberapa sering anda terbangun di tengah malam?"
          description="Indikator hipertensi atau fluktuasi gula darah."
          options={[
            { value: 1, label: "Tidak pernah — tidur nyenyak sampai pagi" },
            { value: 2, label: "1–2 kali — bisa tidur lagi dengan mudah" },
            { value: 3, label: "3+ kali — sering terbangun" },
            { value: 4, label: "Sering terbangun dan sulit tidur lagi" },
          ]}
          selected={draft.wakeFrequency}
          onChanged={(val) => setPhaseB({ wakeFrequency: val as number })}
        />

        {/* B6 */}
        <SingleQ
          no="B6"
          label="Apa yang biasanya anda lakukan 1 jam sebelum tidur?"
          options={[
            { value: 1, label: "Gadget aktif / kerja / makan berat / pikiran sibuk" },
            { value: 2, label: "Campuran — kadang santai, kadang masih aktif" },
            { value: 3, label: "Rutinitas relaksasi — baca, meditasi, stretching ringan" },
          ]}
          selected={draft.preSleepHabit}
          onChanged={(val) => setPhaseB({ preSleepHabit: val as number })}
        />

        {/* B7 */}
        <SingleQ
          no="B7"
          label="Biasanya anda tidur jam berapa malam?"
          description="Dasar perhitungan 5-Hour Recovery Window."
          options={[
            { value: 1, label: "Sebelum jam 21.00" },
            { value: 2, label: "Jam 21.00–22.00" },
            { value: 3, label: "Jam 22.00–23.00" },
            { value: 4, label: "Jam 23.00–00.00" },
            { value: 5, label: "Setelah jam 00.00" },
          ]}
          selected={draft.bedtimeBucket}
          onChanged={(val) => setPhaseB({ bedtimeBucket: val as number })}
        />

        {/* B8 */}
        <SingleQ
          no="B8"
          label="Biasanya anda bangun jam berapa?"
          options={[
            { value: 1, label: "Sebelum jam 05.00" },
            { value: 2, label: "Jam 05.00–06.00" },
            { value: 3, label: "Jam 06.00–07.00" },
            { value: 4, label: "Jam 07.00–08.00" },
            { value: 5, label: "Setelah jam 08.00" },
          ]}
          selected={draft.wakeTimeBucket}
          onChanged={(val) => setPhaseB({ wakeTimeBucket: val as number })}
        />

        {/* B9 */}
        <SingleQ
          no="B9"
          label="Mana yang paling menggambarkan rutinitas harian anda?"
          description="Menentukan window waktu yang realistis untuk sesi."
          options={[
            { value: "executive", label: "Pekerja eksekutif / kantoran", hint: "Jadwal rutin pagi sampai sore." },
            { value: "creative", label: "Pekerja kreatif / freelancer", hint: "Jam kerja tidak menentu, sering aktif malam." },
            { value: "traveller", label: "Frequent traveller", hint: "Sering beda zona waktu — anchor sore lokal." },
            { value: "homemaker", label: "Ibu rumah tangga", hint: "Aktif pagi, fleksibel siang." },
            { value: "shift_worker", label: "Pekerja shift", hint: "Window malam 19:00–20:30 (hard cap 21:00)." },
            { value: "mixed", label: "Campuran / tidak menentu" },
          ]}
          selected={draft.activityProfile}
          onChanged={(val) => setPhaseB({ activityProfile: val as string })}
        />

        {/* B10 */}
        <SingleQ
          no="B10"
          label="Biasanya anda makan malam jam berapa?"
          description="Makan malam larut + sleep latency tinggi = sinyal gula darah spike."
          options={[
            { value: 1, label: "Sebelum jam 18.00" },
            { value: 2, label: "Jam 18.00–19.00" },
            { value: 3, label: "Jam 19.00–20.00" },
            { value: 4, label: "Setelah jam 20.00" },
            { value: 5, label: "Tidak menentu / sering skip" },
          ]}
          selected={draft.dinnerTime}
          onChanged={(val) => setPhaseB({ dinnerTime: val as number })}
        />
      </div>

      <BottomCta
        label="Lanjut ke Phase C →"
        onPressed={canContinue ? handleContinue : undefined}
        hint={!canContinue ? `Lengkapi ${10 - answeredCount} pertanyaan lagi.` : null}
        disabled={!canContinue}
      />
    </div>
  );
}

function QHeader({ no, label, description }: { no: string; label: string; description?: string }) {
  return (
    <div className="flex items-start">
      <span className="text-[11px] font-bold text-sf-warmGold tracking-wider mt-1">{no}</span>
      <div className="ml-3 flex-1">
        <h3 className="text-base font-semibold text-text-primary leading-snug">{label}</h3>
        {description && (
          <p className="text-[12.5px] text-text-secondary mt-1.5 leading-relaxed">{description}</p>
        )}
      </div>
    </div>
  );
}

function SingleQ({
  no,
  label,
  description,
  options,
  selected,
  onChanged,
}: {
  no: string;
  label: string;
  description?: string;
  options: { value: string | number; label: string; hint?: string }[];
  selected: any;
  onChanged: (val: string | number) => void;
}) {
  return (
    <div className="w-full">
      <QHeader no={no} label={label} description={description} />
      <div className="space-y-2 mt-4 pl-7">
        {options.map((opt) => (
          <SelectCard
            key={opt.value}
            value={opt.value}
            groupValue={selected}
            label={opt.label}
            hint={opt.hint}
            onChanged={onChanged}
          />
        ))}
      </div>
    </div>
  );
}
