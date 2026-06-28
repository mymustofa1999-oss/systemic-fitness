"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useAssessmentStore } from "@/stores/assessmentStore";
import { apiPost } from "@/lib/api";
import { useQueryClient } from "@tanstack/react-query";
import { PhaseHeader } from "@/components/assessment/PhaseHeader";
import { SelectCard } from "@/components/assessment/SelectCard";
import { MultiSelectCard } from "@/components/assessment/MultiSelectCard";
import { BottomCta } from "@/components/assessment/BottomCta";
import { toast } from "@/stores/toastStore";

export default function PhaseCPage() {
  const router = useRouter();
  const queryClient = useQueryClient();
  const storePhaseC = useAssessmentStore((state) => state.draft.phaseC);
  const draftPhaseC = {
    mealPattern: storePhaseC?.mealPattern,
    foodDominance: storePhaseC?.foodDominance,
    hydration: storePhaseC?.hydration,
    routineFoods: storePhaseC?.routineFoods ?? [],
    restrictions: storePhaseC?.restrictions ?? [],
    restrictionNote: storePhaseC?.restrictionNote ?? "",
    supplements: storePhaseC?.supplements ?? [],
    supplementNote: storePhaseC?.supplementNote ?? "",
    nutritionGoal: storePhaseC?.nutritionGoal,
  };
  const draftPhaseA = useAssessmentStore((state) => state.draft.phaseA);
  const draftPhaseB = useAssessmentStore((state) => state.draft.phaseB);
  
  const setPhaseC = useAssessmentStore((state) => state.setPhaseC);

  const [submitting, setSubmitting] = useState(false);

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

    // 3. Check Phase B
    const b = draftPhaseB;
    const isPhaseBComplete =
      b &&
      b.durationHours !== undefined &&
      b.consistency !== undefined &&
      b.sleepLatency !== undefined &&
      b.morningReadiness !== undefined &&
      b.wakeFrequency !== undefined &&
      b.preSleepHabit !== undefined &&
      b.bedtimeBucket !== undefined &&
      b.wakeTimeBucket !== undefined &&
      b.activityProfile !== undefined &&
      b.dinnerTime !== undefined;

    if (!isPhaseBComplete) {
      toast.error("Mohon lengkapi Pola Tidur & Aktivitas terlebih dahulu.");
      router.push("/assessment/phase-b");
      return;
    }
  }, [draftPhaseA, draftPhaseB, router]);

  // Wajib: C1, C2, C3, C7
  const isC1Answered = draftPhaseC.mealPattern !== undefined;
  const isC2Answered = draftPhaseC.foodDominance !== undefined;
  const isC3Answered = draftPhaseC.hydration !== undefined;
  const isC7Answered = draftPhaseC.nutritionGoal !== undefined;
  
  const wajibAnswered = [isC1Answered, isC2Answered, isC3Answered, isC7Answered].filter(Boolean).length;
  const canContinue = wajibAnswered === 4;

  const handleToggleMulti = (field: "routineFoods" | "restrictions" | "supplements", value: string) => {
    const list = draftPhaseC[field] as string[];
    const newList = list.includes(value) ? list.filter((v) => v !== value) : [...list, value];
    setPhaseC({ [field]: newList });
  };

  const handleSubmit = async () => {
    if (!canContinue) {
      toast.error("Lengkapi semua pertanyaan wajib (C1, C2, C3, C7).");
      return;
    }

    setSubmitting(true);
    try {
      const mapPhaseAToSnake = (input: any) => {
        if (!input) return undefined;
        return {
          physical_status_level: input.physicalStatusLevel,
          has_medical_condition: input.hasMedicalCondition,
          classification_slug: input.classificationSlug,
          specific_condition_slug: input.specificConditionSlug,
          serious_condition_note: input.seriousConditionNote,
          primary_goal: input.primaryGoal,
          gender: input.gender,
          age_bucket: input.ageBucket,
          movement_test: input.movementTest ? {
            squat: input.movementTest.squat,
            hip_hinge: input.movementTest.hipHinge,
            overhead: input.movementTest.overhead,
          } : undefined,
        };
      };

      const mapPhaseBToSnake = (input: any) => {
        if (!input) return undefined;
        return {
          duration_hours: input.durationHours,
          consistency: input.consistency,
          sleep_latency: input.sleepLatency,
          morning_readiness: input.morningReadiness,
          wake_frequency: input.wakeFrequency,
          pre_sleep_habit: input.preSleepHabit,
          bedtime_bucket: input.bedtimeBucket,
          wake_time_bucket: input.wakeTimeBucket,
          activity_profile: input.activityProfile,
          dinner_time: input.dinnerTime,
        };
      };

      const mapPhaseCToSnake = (input: any) => {
        if (!input) return undefined;
        return {
          meal_pattern: input.mealPattern,
          food_dominance: input.foodDominance,
          hydration: input.hydration,
          routine_foods: input.routineFoods,
          restrictions: input.restrictions,
          restriction_note: input.restrictionNote,
          supplements: input.supplements,
          supplement_note: input.supplementNote,
          nutrition_goal: input.nutritionGoal,
        };
      };

      const body = {
        phase_a: mapPhaseAToSnake(draftPhaseA),
        phase_b: mapPhaseBToSnake(draftPhaseB),
        phase_c: mapPhaseCToSnake(draftPhaseC),
      };

      const res = await apiPost<{ id: string }>("/api/v2/assessments", body);
      
      if (res?.data?.id) {
        queryClient.invalidateQueries({ queryKey: ["latest-assessment"] });
        // Direct to result page
        router.push(`/assessment/result?id=${res.data.id}`);
      } else {
        throw new Error("No result ID returned");
      }
    } catch (e: any) {
      toast.error(e.message || "Gagal mengirim asesmen. Coba lagi.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen bg-bg-primary flex flex-col max-w-lg mx-auto shadow-sm">
      <PhaseHeader currentPhase={2} title="Pola Makan & Gizi" subProgress={`${wajibAnswered}/4 wajib`} />

      <div className="flex-1 px-5 py-5 overflow-y-auto space-y-7 pb-28">
        {/* C1 */}
        <SingleC
          no="C1"
          label="Bagaimana gambaran pola makan anda sehari-hari?"
          options={[
            { value: 1, label: "Makan besar 3 kali sehari, jarang snack" },
            { value: 2, label: "Makan 4–5 kali dalam porsi lebih kecil" },
            { value: 3, label: "Sering skip makan — tidak teratur" },
            { value: 4, label: "Intermittent fasting (mis. 16/8)" },
            { value: 5, label: "Tidak ada pola tetap" },
          ]}
          selected={draftPhaseC.mealPattern}
          onChanged={(val) => setPhaseC({ mealPattern: val as number })}
        />

        {/* C2 */}
        <SingleC
          no="C2"
          label="Apa yang paling sering ada di piring anda?"
          options={[
            { value: 1, label: "Nasi / karbohidrat sebagai porsi terbesar" },
            { value: 2, label: "Protein (ayam, ikan, telur, daging) sebagai fokus" },
            { value: 3, label: "Sayur dan buah mendominasi" },
            { value: 4, label: "Campuran seimbang antara karbo, protein, dan sayur" },
            { value: 5, label: "Makanan olahan / fast food cukup sering" },
          ]}
          selected={draftPhaseC.foodDominance}
          onChanged={(val) => setPhaseC({ foodDominance: val as number })}
        />

        {/* C3 */}
        <SingleC
          no="C3"
          label="Berapa gelas air putih per hari?"
          description="1 gelas = 250 ml."
          options={[
            { value: 1, label: "Kurang dari 4 gelas — sangat kurang" },
            { value: 2, label: "4–6 gelas — kurang" },
            { value: 3, label: "7–8 gelas — cukup" },
            { value: 4, label: "Lebih dari 8 gelas — baik" },
          ]}
          selected={draftPhaseC.hydration}
          onChanged={(val) => setPhaseC({ hydration: val as number })}
        />

        {/* C4 */}
        <MultiC
          no="C4"
          label="Pilih semua yang sering dalam konsumsi harian anda."
          description="Boleh pilih lebih dari satu."
          options={[
            { value: "coffee", label: "Kopi (1+ cangkir per hari)" },
            { value: "sweet_drinks", label: "Teh manis / minuman manis lain" },
            { value: "soda_energy", label: "Minuman bersoda / energi drink" },
            { value: "alcohol", label: "Alkohol" },
            { value: "fried", label: "Makanan digoreng / berminyak" },
            { value: "high_salt", label: "Makanan tinggi garam" },
            { value: "organ_meat", label: "Jeroan" },
            { value: "seafood", label: "Seafood (udang, cumi, kerang)" },
            { value: "dairy", label: "Susu & produk susu" },
            { value: "fermented", label: "Makanan fermentasi (tempe, tape, kimchi)" },
          ]}
          selected={draftPhaseC.routineFoods}
          onToggle={(val) => handleToggleMulti("routineFoods", val)}
        />

        {/* C5 */}
        <MultiC
          no="C5"
          label="Apakah anda memiliki pantangan atau alergi makanan?"
          description="Jadi filter untuk semua rekomendasi gizi."
          options={[
            { value: "none", label: "Tidak ada" },
            { value: "specific_allergy", label: "Alergi spesifik" },
            { value: "religious", label: "Pantangan agama / keyakinan (halal, vegan, dll)" },
            { value: "lactose", label: "Intoleransi laktosa" },
            { value: "gluten", label: "Intoleransi / sensitivitas gluten" },
            { value: "other", label: "Pantangan lainnya" },
          ]}
          selected={draftPhaseC.restrictions}
          onToggle={(val) => handleToggleMulti("restrictions", val)}
          noteValue={draftPhaseC.restrictionNote}
          onNoteChange={(val) => setPhaseC({ restrictionNote: val })}
          notePlaceholder="Tuliskan detail alergi / pantangan (opsional)"
        />

        {/* C6 */}
        <MultiC
          no="C6"
          label="Suplemen / obat yang sedang anda konsumsi"
          description="Memberi konteks tambahan untuk Health Consultant."
          options={[
            { value: "none", label: "Tidak ada" },
            { value: "multivitamin", label: "Multivitamin umum" },
            { value: "vitamin_d", label: "Vitamin D" },
            { value: "omega_3", label: "Omega-3 / Fish oil" },
            { value: "protein", label: "Suplemen protein (whey, plant-based)" },
            { value: "other", label: "Suplemen spesifik lainnya" },
            { value: "rx_metabolic", label: "Obat dokter yang mempengaruhi metabolisme" },
          ]}
          selected={draftPhaseC.supplements}
          onToggle={(val) => handleToggleMulti("supplements", val)}
          noteValue={draftPhaseC.supplementNote}
          onNoteChange={(val) => setPhaseC({ supplementNote: val })}
          notePlaceholder="Sebutkan nama suplemen / obat (opsional)"
        />

        {/* C7 */}
        <SingleC
          no="C7"
          label="Apa yang paling ingin anda perbaiki dari pola makan?"
          options={[
            { value: "blood_sugar", label: "Mengontrol gula darah dan metabolisme" },
            { value: "anti_inflammation", label: "Mengurangi peradangan, bloating, ketidaknyamanan pencernaan" },
            { value: "energy_vitality", label: "Meningkatkan energi dan vitalitas" },
            { value: "hormonal_balance", label: "Mendukung keseimbangan hormonal" },
            { value: "weight", label: "Menjaga berat badan yang sehat" },
            { value: "muscle_recovery", label: "Mendukung performa, pemulihan otot, kebugaran" },
            { value: "organ_health", label: "Mendukung kesehatan organ spesifik (ginjal, jantung)" },
          ]}
          selected={draftPhaseC.nutritionGoal}
          onChanged={(val) => setPhaseC({ nutritionGoal: val as string })}
        />
      </div>

      <BottomCta
        label={submitting ? "Menyimpan…" : "Selesai & Lihat Hasil"}
        onPressed={canContinue && !submitting ? handleSubmit : undefined}
        hint={!canContinue ? "Lengkapi pertanyaan wajib (C1, C2, C3, C7) untuk lanjut." : null}
        disabled={!canContinue || submitting}
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

function SingleC({
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

function MultiC({
  no,
  label,
  description,
  options,
  selected,
  onToggle,
  noteValue,
  onNoteChange,
  notePlaceholder,
}: {
  no: string;
  label: string;
  description?: string;
  options: { value: string; label: string }[];
  selected: string[];
  onToggle: (val: string) => void;
  noteValue?: string;
  onNoteChange?: (val: string) => void;
  notePlaceholder?: string;
}) {
  return (
    <div className="w-full">
      <QHeader no={no} label={label} description={description} />
      <div className="space-y-2 mt-4 pl-7 flex flex-wrap gap-2">
        {options.map((opt) => (
          <div key={opt.value} className="w-full">
            <MultiSelectCard
              value={opt.value}
              selectedList={selected}
              label={opt.label}
              onToggle={onToggle}
            />
          </div>
        ))}
        {onNoteChange && (
          <input
            type="text"
            value={noteValue || ""}
            onChange={(e) => onNoteChange(e.target.value)}
            placeholder={notePlaceholder}
            className="w-full mt-2 bg-bg-card border border-border-color text-text-primary text-sm rounded-xl px-4 py-3.5 focus:outline-none focus:border-sf-warmGold focus:ring-1 focus:ring-sf-warmGold transition-all placeholder-text-secondary/50"
          />
        )}
      </div>
    </div>
  );
}
