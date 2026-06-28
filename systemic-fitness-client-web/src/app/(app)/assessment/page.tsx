"use client";

import { ArrowLeft, Lock } from "lucide-react";
import { useRouter } from "next/navigation";
import { useAssessmentStore } from "@/stores/assessmentStore";
import { useEffect } from "react";
import { BottomCta } from "@/components/assessment/BottomCta";

export default function AssessmentIntroPage() {
  const router = useRouter();
  const resetAssessment = useAssessmentStore((state) => state.reset);

  // Initialize/reset draft on start
  useEffect(() => {
    resetAssessment();
  }, [resetAssessment]);

  return (
    <div className="min-h-screen bg-bg-primary flex flex-col max-w-lg mx-auto shadow-sm">
      {/* Hero Section */}
      <div className="w-full px-5 pt-4 pb-6 bg-sf-deepNavy dark:bg-bg-card">
        <div className="flex mb-4">
          <button
            onClick={() => router.back()}
            className="w-8 h-8 flex items-center justify-center -ml-1 text-white hover:bg-white/10 rounded-full transition-colors"
          >
            <ArrowLeft size={20} />
          </button>
        </div>
        <div className="inline-flex items-center px-3 py-1.5 rounded-full bg-sf-warmGold/20 border border-sf-warmGold/40 mb-3.5">
          <span className="text-[10px] font-bold text-sf-warmGold tracking-widest uppercase">
            Asesmen Sistemik
          </span>
        </div>
        <h1 className="text-3xl font-bold text-white leading-tight mb-2">
          Mari kita pahami<br />sistem tubuh anda.
        </h1>
        <p className="text-[13px] text-white/75 leading-relaxed">
          Sekitar 7 menit. Anda dapat berhenti kapan saja — jawaban tersimpan otomatis di perangkat Anda.
        </p>
      </div>

      {/* Content */}
      <div className="flex-1 px-5 py-6 overflow-y-auto">
        <h2 className="text-[17px] font-bold text-text-primary mb-4">
          Yang akan anda lalui
        </h2>

        <div className="space-y-3">
          <PhaseCard
            index="A"
            title="Penilaian Kondisi"
            time="~2 menit"
            description="3 pertanyaan tentang kondisi fisik, kondisi medis (jika ada), dan tujuan utama anda."
            colorClass="bg-sf-warmGold text-sf-warmGold border-sf-warmGold/20"
          />
          <PhaseCard
            index="B"
            title="Pola Tidur & Aktivitas"
            time="~3 menit"
            description="10 pertanyaan untuk menentukan Rest Score & jadwal sesi yang optimal (Chronobiology Window)."
            colorClass="bg-blue-500 text-blue-500 border-blue-500/20"
          />
          <PhaseCard
            index="C"
            title="Pola Makan & Gizi"
            time="~2 menit"
            description="7 pertanyaan untuk Nutrition Score & rekomendasi gizi yang dipersonalisasi."
            colorClass="bg-teal-600 text-teal-600 border-teal-600/20"
          />
        </div>

        <div className="mt-6 p-4 rounded-xl bg-blue-50/50 dark:bg-blue-900/10 flex items-start border border-blue-100 dark:border-blue-800/30">
          <Lock size={18} className="text-blue-800 dark:text-blue-400 mt-0.5 shrink-0" />
          <p className="ml-2.5 text-[12.5px] text-blue-900 dark:text-blue-300 leading-relaxed font-medium">
            Jawaban anda hanya digunakan untuk mempersonalisasi program. Tidak dibagikan ke pihak ketiga.
          </p>
        </div>
      </div>

      {/* Bottom CTA */}
      <BottomCta
        label="Mulai Asesmen"
        onPressed={() => router.push("/assessment/phase-a")}
      />
    </div>
  );
}

function PhaseCard({
  index,
  title,
  time,
  description,
  colorClass,
}: {
  index: string;
  title: string;
  time: string;
  description: string;
  colorClass: string;
}) {
  const [, textColor] = colorClass.split(" ");
  
  return (
    <div className="p-4 rounded-xl bg-bg-card border border-border-color shadow-sm flex items-start">
      <div
        className={`w-10 h-10 shrink-0 rounded-xl flex items-center justify-center font-bold text-lg bg-opacity-10 dark:bg-opacity-20 ${colorClass}`}
      >
        <span className={textColor}>{index}</span>
      </div>
      <div className="ml-3.5 flex-1">
        <div className="flex items-center justify-between mb-1">
          <h3 className="font-bold text-[15px] text-text-primary">{title}</h3>
          <span className={`text-[11px] font-bold tracking-wide ${textColor}`}>
            {time}
          </span>
        </div>
        <p className="text-[13px] text-text-secondary leading-relaxed">
          {description}
        </p>
      </div>
    </div>
  );
}
