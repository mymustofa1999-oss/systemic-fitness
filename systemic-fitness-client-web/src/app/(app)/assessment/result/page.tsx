"use client";

import { useEffect, useState, Suspense } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { apiGet } from "@/lib/api";
import { CheckCircle2, ArrowRight, Loader2, Activity, Moon, UtensilsCrossed } from "lucide-react";
import { BottomCta } from "@/components/assessment/BottomCta";

function ResultContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const id = searchParams.get("id");

  const [loading, setLoading] = useState(true);
  const [result, setResult] = useState<any>(null);

  useEffect(() => {
    if (!id) return;
    
    apiGet(`/api/v2/assessments/${id}`)
      .then((res: any) => {
        setResult(res.data);
      })
      .catch((err) => {
        console.error(err);
      })
      .finally(() => {
        setLoading(false);
      });
  }, [id]);

  if (loading || !result) {
    return (
      <div className="min-h-screen bg-bg-primary flex flex-col items-center justify-center max-w-lg mx-auto">
        <Loader2 size={36} className="text-sf-warmGold animate-spin mb-4" />
        <p className="text-sm text-text-secondary">Menyiapkan hasil asesmen anda...</p>
      </div>
    );
  }

  // Calculate scores to show (mock if null, but API should return them)
  const restScore = Number(result.rest_score ?? 0) || 0;
  const nutritionScore = Number(result.nutrition_score ?? 0) || 0;
  const systemScore = Number(result.system_score ?? 0) || 0;
  
  const scoreTier = systemScore >= 80 ? "OPTIMAL" : systemScore >= 60 ? "STABLE" : systemScore >= 40 ? "COMPROMISED" : "CRITICAL";
  const tierColor = systemScore >= 80 ? "text-green-500" : systemScore >= 60 ? "text-sf-warmGold" : systemScore >= 40 ? "text-amber-500" : "text-red-500";

  return (
    <div className="min-h-screen bg-bg-primary flex flex-col max-w-lg mx-auto shadow-sm">
      <div className="w-full px-5 pt-8 pb-10 bg-sf-deepNavy dark:bg-bg-card border-b border-sf-warmGold/20 flex flex-col items-center text-center">
        <div className="w-16 h-16 bg-green-500/20 rounded-full flex items-center justify-center mb-5 border border-green-500/40">
          <CheckCircle2 size={32} className="text-green-500" />
        </div>

        <h1 className="text-2xl font-bold text-white leading-tight mb-3">
          Asesmen Selesai
        </h1>
        <p className="text-[13.5px] text-white/80 leading-relaxed max-w-xs">
          Terima kasih. Profil kesehatan anda telah dianalisis. Berikut adalah ringkasan skor awal anda.
        </p>
      </div>

      <div className="flex-1 px-5 py-8 overflow-y-auto space-y-6">
        
        {/* Main Score */}
        <div className="p-5 bg-bg-card border border-border-color rounded-2xl shadow-sm flex flex-col items-center">
          <p className="text-[11px] font-bold text-text-secondary uppercase tracking-widest mb-2">
            System Score
          </p>
          <div className="flex items-baseline space-x-1">
            <span className="text-5xl font-black text-text-primary">{systemScore.toFixed(0)}</span>
            <span className="text-lg font-bold text-text-secondary">/100</span>
          </div>
          <div className={`mt-3 px-3 py-1 rounded-full bg-opacity-10 border ${tierColor.replace("text-", "bg-").replace("500", "500/10")} ${tierColor.replace("text-", "border-").replace("500", "500/30")}`}>
            <span className={`text-xs font-bold tracking-wider ${tierColor}`}>{scoreTier}</span>
          </div>
        </div>

        {/* Sub Scores */}
        <div className="grid grid-cols-2 gap-4">
          <div className="p-4 bg-bg-card border border-border-color rounded-2xl flex flex-col">
            <div className="flex items-center space-x-2 mb-3">
              <Moon size={16} className="text-blue-500" />
              <span className="text-[11px] font-bold text-text-secondary uppercase">Rest</span>
            </div>
            <span className="text-2xl font-bold text-text-primary">{restScore.toFixed(0)} <span className="text-sm font-medium text-text-secondary">/35</span></span>
          </div>
          
          <div className="p-4 bg-bg-card border border-border-color rounded-2xl flex flex-col">
            <div className="flex items-center space-x-2 mb-3">
              <UtensilsCrossed size={16} className="text-teal-500" />
              <span className="text-[11px] font-bold text-text-secondary uppercase">Nutrition</span>
            </div>
            <span className="text-2xl font-bold text-text-primary">{nutritionScore.toFixed(0)} <span className="text-sm font-medium text-text-secondary">/30</span></span>
          </div>
        </div>

        {/* Chronobiology Window */}
        {result.chronobiology_window && (
          <div className="p-5 bg-sf-warmGold/10 border border-sf-warmGold/30 rounded-2xl">
            <div className="flex items-center space-x-2 mb-3">
              <Activity size={18} className="text-sf-warmGoldDark dark:text-sf-warmGold" />
              <h3 className="text-[14px] font-bold text-sf-warmGoldDark dark:text-sf-warmGold">
                Chronobiology Window
              </h3>
            </div>
            <p className="text-[13px] text-text-primary leading-relaxed mb-3">
              Waktu paling optimal untuk anda melakukan sesi latihan fisik (untuk efisiensi hormon & recovery):
            </p>
            <div className="bg-bg-primary rounded-xl p-3 flex justify-center items-center border border-border-color">
              <span className="text-lg font-bold text-text-primary">{result.chronobiology_window.ideal_start}</span>
              <ArrowRight size={16} className="mx-3 text-text-secondary" />
              <span className="text-lg font-bold text-text-primary">{result.chronobiology_window.ideal_end}</span>
            </div>
          </div>
        )}

      </div>

      <BottomCta
        label="Kembali ke Dashboard"
        onPressed={() => router.push("/dashboard")}
      />
    </div>
  );
}

export default function AssessmentResultPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen bg-bg-primary flex flex-col items-center justify-center max-w-lg mx-auto">
        <Loader2 size={36} className="text-sf-warmGold animate-spin mb-4" />
      </div>
    }>
      <ResultContent />
    </Suspense>
  );
}
