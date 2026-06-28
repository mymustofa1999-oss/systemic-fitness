"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useAssessmentStore } from "@/stores/assessmentStore";
import { apiGet } from "@/lib/api";
import { PhaseHeader } from "@/components/assessment/PhaseHeader";
import { SelectCard } from "@/components/assessment/SelectCard";
import { PickerField } from "@/components/assessment/PickerField";
import { BottomCta } from "@/components/assessment/BottomCta";
import { toast } from "@/stores/toastStore";

export default function PhaseAPage() {
  const router = useRouter();
  const draft = useAssessmentStore((state) => state.draft.phaseA);
  const setPhaseA = useAssessmentStore((state) => state.setPhaseA);

  const [classifications, setClassifications] = useState<{ label: string; value: string }[]>([]);
  const [specificConditions, setSpecificConditions] = useState<{ label: string; value: string }[]>([]);

  // Fetch classifications
  useEffect(() => {
    if (draft.hasMedicalCondition) {
      apiGet<any[]>("/api/master/condition-classifications")
        .then((res) => {
          if (res.data) {
            setClassifications(res.data.map((item) => ({ label: item.label, value: item.slug })));
          }
        })
        .catch(() => {});
    }
  }, [draft.hasMedicalCondition]);

  // Fetch specific conditions
  useEffect(() => {
    if (draft.classificationSlug) {
      apiGet<any[]>("/api/master/specific-conditions", { classification: draft.classificationSlug })
        .then((res) => {
          if (res.data) {
            setSpecificConditions(res.data.map((item) => ({ label: item.label, value: item.slug })));
          }
        })
        .catch(() => {});
    } else {
      setSpecificConditions([]);
    }
  }, [draft.classificationSlug]);

  const showQ2 = draft.physicalStatusLevel === "level_4_5_perf";
  const showQ3 = showQ2 && draft.hasMedicalCondition;
  const showGenderAge = showQ2 && !draft.hasMedicalCondition;

  const canContinue = () => {
    if (draft.physicalStatusLevel === "level_0_1" || draft.physicalStatusLevel === "level_2_3") {
      return false; // waitlist intercepts immediately
    }
    if (draft.hasMedicalCondition) {
      return !!(draft.classificationSlug && draft.specificConditionSlug && draft.primaryGoal);
    } else {
      return !!(draft.gender && draft.ageBucket);
    }
  };

  const handleContinue = () => {
    if (!canContinue()) {
      toast.error("Mohon lengkapi semua jawaban dulu.");
      return;
    }

    if (!draft.hasMedicalCondition) {
      router.push("/assessment/phase-a/movement");
    } else {
      router.push("/assessment/phase-b");
    }
  };

  return (
    <div className="min-h-screen bg-bg-primary flex flex-col max-w-lg mx-auto shadow-sm">
      <PhaseHeader currentPhase={0} title="Penilaian Kondisi" subProgress="~3 pertanyaan" />

      <div className="flex-1 px-5 py-5 overflow-y-auto space-y-7 pb-28">
        {/* Q1 */}
        <Question
          no="A1"
          label="Bagaimana kondisi gerak anda saat ini?"
          description="Pilih yang paling mendekati keadaan sekarang."
        >
          <div className="space-y-2 mt-3">
            <SelectCard
              value="level_0_1"
              groupValue={draft.physicalStatusLevel}
              label="Saya hanya bisa berbaring atau duduk. Berdiri sendiri sangat sulit."
              hint="Akan diarahkan ke waitlist program."
              onChanged={(val) => {
                setPhaseA({
                  physicalStatusLevel: val,
                  hasMedicalCondition: false,
                  classificationSlug: undefined,
                  specificConditionSlug: undefined,
                  gender: undefined,
                  ageBucket: undefined,
                  primaryGoal: undefined,
                });
                router.push("/assessment/waitlist");
              }}
            />
            <SelectCard
              value="level_2_3"
              groupValue={draft.physicalStatusLevel}
              label="Saya bisa berdiri, tapi berjalan masih terbatas atau butuh bantuan."
              hint="Akan diarahkan ke waitlist program."
              onChanged={(val) => {
                setPhaseA({
                  physicalStatusLevel: val,
                  hasMedicalCondition: false,
                  classificationSlug: undefined,
                  specificConditionSlug: undefined,
                  gender: undefined,
                  ageBucket: undefined,
                  primaryGoal: undefined,
                });
                router.push("/assessment/waitlist");
              }}
            />
            <SelectCard
              value="level_4_5_perf"
              groupValue={draft.physicalStatusLevel}
              label="Saya bisa berjalan, tapi gerakan fisik saya masih sangat terbatas and stamina rendah."
              hint="Lanjut ke pertanyaan berikutnya."
              onChanged={(val) => setPhaseA({ physicalStatusLevel: val })}
            />
          </div>
        </Question>

        {/* Q2 */}
        {showQ2 && (
          <Question
            no="A2"
            label="Apakah anda memiliki kondisi medis aktif?"
            description="Membantu kami menyesuaikan program dengan kondisi anda."
          >
            <div className="space-y-2 mt-3">
              <SelectCard
                value={true}
                groupValue={draft.hasMedicalCondition}
                label="Ya — ada gangguan kondisi kesehatan"
                onChanged={(val) => {
                  setPhaseA({
                    hasMedicalCondition: val,
                    classificationSlug: undefined,
                    specificConditionSlug: undefined,
                    gender: undefined,
                    ageBucket: undefined,
                    primaryGoal: undefined,
                  });
                }}
              />
              <SelectCard
                value={false}
                groupValue={draft.hasMedicalCondition}
                label="Tidak ada kondisi medis aktif"
                onChanged={(val) => {
                  setPhaseA({
                    hasMedicalCondition: val,
                    classificationSlug: undefined,
                    specificConditionSlug: undefined,
                    gender: undefined,
                    ageBucket: undefined,
                    primaryGoal: undefined,
                  });
                }}
              />
            </div>
          </Question>
        )}

        {/* Medical Path */}
        {showQ2 && draft.hasMedicalCondition && (
          <div className="space-y-4">
            <PickerField
              label="Klasifikasi kondisi"
              placeholder="Pilih klasifikasi"
              options={classifications}
              value={draft.classificationSlug || ""}
              onChange={(e) => setPhaseA({ classificationSlug: e.target.value, specificConditionSlug: undefined })}
            />
            <PickerField
              label="Kondisi spesifik"
              placeholder={draft.classificationSlug ? "Pilih kondisi" : "Pilih klasifikasi terlebih dulu"}
              options={specificConditions}
              value={draft.specificConditionSlug || ""}
              disabled={!draft.classificationSlug}
              onChange={(e) => setPhaseA({ specificConditionSlug: e.target.value })}
            />
          </div>
        )}

        {/* Non-Medical Path */}
        {showGenderAge && (
          <>
            <Question no="A2.1" label="Pilih program gender">
              <div className="space-y-2 mt-3">
                <SelectCard
                  value="women"
                  groupValue={draft.gender}
                  label="Program Wanita"
                  hint="Optimasi hormon, stamina & vitalitas feminitas"
                  onChanged={(val) => setPhaseA({ gender: val })}
                />
                <SelectCard
                  value="men"
                  groupValue={draft.gender}
                  label="Program Pria"
                  hint="Optimasi testosteron, massa otot & stamina maskulin"
                  onChanged={(val) => setPhaseA({ gender: val })}
                />
              </div>
            </Question>

            {draft.gender && (
              <Question no="A2.2" label="Berapa usia anda?">
                <div className="space-y-2 mt-3">
                  <SelectCard
                    value="35_45"
                    groupValue={draft.ageBucket}
                    label="35–45 tahun"
                    onChanged={(val) => setPhaseA({ ageBucket: val })}
                  />
                  <SelectCard
                    value="46_60"
                    groupValue={draft.ageBucket}
                    label="46–60 tahun"
                    onChanged={(val) => setPhaseA({ ageBucket: val })}
                  />
                </div>
              </Question>
            )}
          </>
        )}

        {/* Q3 Primary Goal */}
        {showQ3 && (
          <Question
            no="A3"
            label="Apa yang paling ingin anda capai?"
            description="Membantu kami prioritaskan fokus program."
          >
            <div className="space-y-2 mt-3">
              <SelectCard
                value="control_medical"
                groupValue={draft.primaryGoal}
                label="Mengontrol kondisi medis saya"
                onChanged={(val) => setPhaseA({ primaryGoal: val })}
              />
              <SelectCard
                value="hormonal_feminine"
                groupValue={draft.primaryGoal}
                label="Menyeimbangkan hormon dan feminitas saya"
                onChanged={(val) => setPhaseA({ primaryGoal: val })}
              />
              <SelectCard
                value="stamina_masculine"
                groupValue={draft.primaryGoal}
                label="Meningkatkan stamina dan performa fisik pria"
                onChanged={(val) => setPhaseA({ primaryGoal: val })}
              />
            </div>
          </Question>
        )}
      </div>

      <BottomCta
        label="Lanjut ke Phase B →"
        onPressed={canContinue() ? handleContinue : undefined}
        hint={!canContinue() ? "Lengkapi pertanyaan untuk lanjut." : null}
        disabled={!canContinue()}
      />
    </div>
  );
}

function Question({
  no,
  label,
  description,
  children,
}: {
  no: string;
  label: string;
  description?: string;
  children: React.ReactNode;
}) {
  return (
    <div className="w-full">
      <div className="flex items-start">
        <span className="text-[11px] font-bold text-sf-warmGold tracking-wider mt-1">{no}</span>
        <div className="ml-3 flex-1">
          <h3 className="text-base font-semibold text-text-primary leading-snug">{label}</h3>
          {description && (
            <p className="text-[12.5px] text-text-secondary mt-1 leading-relaxed">{description}</p>
          )}
        </div>
      </div>
      {children}
    </div>
  );
}
