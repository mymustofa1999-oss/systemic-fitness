"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useAssessmentStore } from "@/stores/assessmentStore";
import { PhaseHeader } from "@/components/assessment/PhaseHeader";
import { SelectCard } from "@/components/assessment/SelectCard";
import { BottomCta } from "@/components/assessment/BottomCta";
import { toast } from "@/stores/toastStore";
import { CheckCircle2, Info } from "lucide-react";

export default function PhaseAMovementTestPage() {
  const router = useRouter();
  const phaseA = useAssessmentStore((state) => state.draft.phaseA);
  const setPhaseA = useAssessmentStore((state) => state.setPhaseA);

  useEffect(() => {
    // Check Phase A
    const isPhaseAComplete =
      phaseA.physicalStatusLevel &&
      phaseA.physicalStatusLevel !== "level_0_1" &&
      phaseA.physicalStatusLevel !== "level_2_3" &&
      (phaseA.hasMedicalCondition
        ? !!(phaseA.classificationSlug && phaseA.specificConditionSlug && phaseA.primaryGoal)
        : !!(phaseA.gender && phaseA.ageBucket));

    if (!isPhaseAComplete) {
      toast.error("Mohon lengkapi Penilaian Kondisi terlebih dahulu.");
      router.push("/assessment");
    }
  }, [phaseA, router]);

  const [squat, setSquat] = useState<number | undefined>(phaseA.movementTest?.squat);
  const [hipHinge, setHipHinge] = useState<number | undefined>(phaseA.movementTest?.hipHinge);
  const [overhead, setOverhead] = useState<number | undefined>(phaseA.movementTest?.overhead);

  const canContinue = squat !== undefined && hipHinge !== undefined && overhead !== undefined;
  const totalScore = (squat ?? 0) + (hipHinge ?? 0) + (overhead ?? 0);

  const handleContinue = () => {
    if (!canContinue) {
      toast.error("Mohon jawab semua 3 gerakan dulu.");
      return;
    }

    setPhaseA({
      movementTest: { squat, hipHinge, overhead },
    });

    if (totalScore < 4) {
      toast.info(
        `Skor gerakan ${totalScore}/6 — kami sarankan Konsultasi Online Gratis 15 menit. (Akan tersedia pada update berikutnya.)`,
      );
    }
    
    router.push("/assessment/phase-b");
  };

  return (
    <div className="min-h-screen bg-bg-primary flex flex-col max-w-lg mx-auto shadow-sm">
      <PhaseHeader currentPhase={0} title="Tes Gerakan Dasar" subProgress="3 gerakan" />

      <div className="flex-1 px-5 py-5 overflow-y-auto space-y-7 pb-28">
        <p className="text-[13.5px] text-text-secondary leading-relaxed">
          Lakukan 3 gerakan ini sambil duduk atau berdiri di tempat yang aman, lalu pilih opsi yang paling cocok.
        </p>

        <MovementQuestion
          no="1"
          title="Bodyweight Squat"
          description="Berdiri tegak, lalu tekuk lutut sampai paha sejajar lantai (atau semampu anda), kembali ke posisi awal."
          selected={squat}
          onChanged={setSquat}
        />
        <MovementQuestion
          no="2"
          title="Hip Hinge"
          description="Berdiri tegak, lutut sedikit menekuk. Bungkukkan badan dari pinggul (bukan punggung) seakan-akan mau ambil sesuatu di lantai."
          selected={hipHinge}
          onChanged={setHipHinge}
        />
        <MovementQuestion
          no="3"
          title="Overhead Reach"
          description="Angkat kedua tangan lurus ke atas tanpa membusungkan dada atau menaikkan bahu (shrug)."
          selected={overhead}
          onChanged={setOverhead}
        />

        {canContinue && (
          <div
            className={`p-4 rounded-xl flex items-start border ${
              totalScore >= 4
                ? "bg-green-50/50 dark:bg-green-900/10 border-green-200 dark:border-green-800/30"
                : "bg-amber-50/50 dark:bg-amber-900/10 border-amber-200 dark:border-amber-800/30"
            }`}
          >
            {totalScore >= 4 ? (
              <CheckCircle2 size={18} className="text-green-600 dark:text-green-500 mt-0.5 shrink-0" />
            ) : (
              <Info size={18} className="text-amber-600 dark:text-amber-500 mt-0.5 shrink-0" />
            )}
            <p
              className={`ml-2.5 text-[12.5px] leading-relaxed font-medium ${
                totalScore >= 4
                  ? "text-green-800 dark:text-green-300"
                  : "text-amber-900 dark:text-amber-300"
              }`}
            >
              {totalScore >= 4
                ? `Total skor anda ${totalScore}/6 — siap lanjut ke Phase B.`
                : `Total skor anda ${totalScore}/6. Kami akan tetap arahkan anda ke Phase B, dan menyarankan Konsultasi Online Gratis 15 menit.`}
            </p>
          </div>
        )}
      </div>

      <BottomCta
        label="Lanjut ke Phase B →"
        onPressed={canContinue ? handleContinue : undefined}
        hint={!canContinue ? "Jawab semua 3 gerakan untuk lanjut." : null}
        disabled={!canContinue}
      />
    </div>
  );
}

function MovementQuestion({
  no,
  title,
  description,
  selected,
  onChanged,
}: {
  no: string;
  title: string;
  description: string;
  selected?: number;
  onChanged: (val: number) => void;
}) {
  return (
    <div className="w-full">
      <div className="flex items-start">
        <div className="w-6 h-6 rounded-full bg-sf-warmGold/15 flex items-center justify-center shrink-0 mt-0.5">
          <span className="text-[11px] font-bold text-sf-warmGold">{no}</span>
        </div>
        <div className="ml-3 flex-1">
          <h3 className="text-base font-semibold text-text-primary leading-snug">{title}</h3>
          <p className="text-[12.5px] text-text-secondary mt-1 leading-relaxed">{description}</p>
        </div>
      </div>
      <div className="space-y-2 mt-4 pl-9">
        <SelectCard
          value={2}
          groupValue={selected}
          label="Bisa penuh — tanpa kompensasi atau nyeri"
          onChanged={onChanged}
        />
        <SelectCard
          value={1}
          groupValue={selected}
          label="Bisa, tapi dengan kompensasi (tubuh menyesuaikan)"
          onChanged={onChanged}
        />
        <SelectCard
          value={0}
          groupValue={selected}
          label="Tidak bisa atau terasa nyeri"
          onChanged={onChanged}
        />
      </div>
    </div>
  );
}
