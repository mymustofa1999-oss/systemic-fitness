"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { ArrowLeft, Bell, PlayCircle, Loader2 } from "lucide-react";
import { useAssessmentStore } from "@/stores/assessmentStore";
import { useAuth } from "@/hooks/useAuth";
import { apiPost } from "@/lib/api";
import { toast } from "@/stores/toastStore";

export default function AssessmentWaitlistPage() {
  const router = useRouter();
  const { user } = useAuth();
  const level = useAssessmentStore((state) => state.draft.phaseA.physicalStatusLevel);
  const [submitting, setSubmitting] = useState(false);

  const levelLabel = level === "level_0_1"
    ? "Level 0–1"
    : level === "level_2_3"
      ? "Level 2–3"
      : "Level fungsional terbatas";

  const handleJoinWaitlist = async () => {
    if (submitting) return;
    setSubmitting(true);

    try {
      if (!user || !user.email) {
        throw new Error("Anda belum login.");
      }

      const body = {
        full_name: user.name || "Anonymous",
        email: user.email,
        source: "level_0_3",
        note: "Daftar dari client-web — Phase A waitlist screen.",
      };

      await apiPost("/api/v2/tier4-waitlist", body);
      toast.success("Terima kasih — minat anda sudah tercatat. Kami akan menghubungi anda.");
      router.push("/dashboard");
    } catch (err: any) {
      toast.error(err.message || "Gagal mendaftarkan minat. Coba lagi.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen bg-sf-deepNavy flex flex-col max-w-lg mx-auto shadow-sm text-white">
      {/* Top Bar */}
      <div className="w-full px-5 pt-5 pb-2 flex items-center">
        <button
          onClick={() => {
            if (window.history.length > 1) {
              router.back();
            } else {
              router.push("/dashboard");
            }
          }}
          className="w-9 h-9 flex items-center justify-center -ml-2 text-white hover:bg-white/10 rounded-full transition-colors"
        >
          <ArrowLeft size={22} />
        </button>
      </div>

      {/* Main Content */}
      <div className="flex-1 px-6 py-4 overflow-y-auto space-y-6">
        <div>
          <span className="inline-block px-3.5 py-1.5 rounded-full bg-sf-warmGold/20 border border-sf-warmGold/45 text-[10px] font-bold text-sf-warmGold tracking-widest uppercase">
            WAITLIST · {levelLabel}
          </span>
        </div>

        <h1 className="text-3xl font-bold leading-tight tracking-tight font-dm-serif text-white">
          Anda adalah<br />alasan kami<br />bergerak lebih cepat.
        </h1>

        <p className="text-[13.5px] text-white/80 leading-relaxed font-dm-sans">
          Program Systemic Fitness saat ini dirancang untuk mereka yang sudah bisa bergerak mandiri. Kami sedang mengembangkan program khusus untuk anda.
        </p>

        {/* Info Tiles */}
        <div className="space-y-3.5 pt-2">
          <div className="p-4 bg-sf-midnightBlue/55 border border-white/6 rounded-2xl flex items-start space-x-3.5">
            <Bell className="text-sf-warmGold shrink-0 mt-0.5" size={20} />
            <div>
              <h3 className="text-[13.5px] font-bold text-white font-dm-sans">Daftar waitlist</h3>
              <p className="text-[12px] text-white/65 mt-0.5 leading-relaxed font-dm-sans">
                Kami akan kabari saat program untuk kondisi anda siap.
              </p>
            </div>
          </div>

          <div className="p-4 bg-sf-midnightBlue/55 border border-white/6 rounded-2xl flex items-start space-x-3.5">
            <PlayCircle className="text-sf-warmGold shrink-0 mt-0.5" size={20} />
            <div>
              <h3 className="text-[13.5px] font-bold text-white font-dm-sans">Bonus akses gratis</h3>
              <p className="text-[12px] text-white/65 mt-0.5 leading-relaxed font-dm-sans">
                Modul &quot;Gerakan dari Kursi&quot; — video gentle movement untuk dilakukan dari posisi duduk.
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* CTA Section */}
      <div className="px-6 py-6 pb-8 bg-sf-deepNavy space-y-3">
        <button
          onClick={handleJoinWaitlist}
          disabled={submitting}
          className="w-full bg-sf-warmGold hover:bg-sf-warmGoldDark disabled:bg-sf-warmGold/50 text-white font-semibold py-3.5 rounded-2xl flex items-center justify-center transition-colors shadow-glow-gold"
        >
          {submitting ? (
            <Loader2 className="animate-spin mr-2" size={20} />
          ) : null}
          Daftarkan Minat Saya
        </button>

        <button
          onClick={() => router.push("/dashboard")}
          disabled={submitting}
          className="w-full text-center text-[13px] text-white/60 hover:text-white transition-colors py-2 font-medium"
        >
          Lain kali saja
        </button>
      </div>
    </div>
  );
}
