"use client";

import { useAuth } from "@/hooks/useAuth";
import {
  Dumbbell,
  TrendingUp,
  Apple,
  ChevronRight,
  Flame,
  Target,
  Clock,
  BarChart3,
  Trophy,
  Users,
  Megaphone,
  Brain,
  CalendarDays,
  UtensilsCrossed,
  ClipboardList,
  BookOpen,
  Droplets,
  Moon,
  Heart,
  Lock,
  X,
  Check,
  AlertCircle,
  Upload,
  ExternalLink,
  FileText,
  Loader2,
  CreditCard,
} from "lucide-react";
import Link from "next/link";
import useEmblaCarousel from "embla-carousel-react";
import Autoplay from "embla-carousel-autoplay";
import Image from "next/image";
import { useQuery } from "@tanstack/react-query";
import { apiGet } from "@/lib/api";
import {
  useMySubscription,
  useSubscriptionPlans,
  useSubscribe,
  useCancelSubscription,
  useMyPayments,
  useBankAccounts,
  useUploadPaymentProof,
} from "@/hooks/useSubscription";
import { toast } from "@/stores/toastStore";
import { useState, useEffect } from "react";

// ── Tip of the Day (rotates by day-of-year, like mobile) ──
const tips = [
  {
    category: "NUTRITION",
    title: "Hidrasi adalah pondasi performa",
    body: "Minum 30–35 ml air per kg berat badan setiap hari. Mulai pagimu dengan segelas air sebelum kafein.",
    icon: Droplets,
    color: "#0EA5E9",
  },
  {
    category: "RECOVERY",
    title: "Tidur = sesi latihan tak kasat mata",
    body: "Otot tumbuh saat tidur, bukan saat angkat beban. Target 7–9 jam berkualitas setiap malam.",
    icon: Moon,
    color: "#8B5CF6",
  },
  {
    category: "TRAINING",
    title: "Konsistensi mengalahkan intensitas",
    body: "4 sesi sederhana per minggu yang konsisten lebih efektif daripada 1 sesi maksimal lalu menghilang.",
    icon: Dumbbell,
    color: "#F97316",
  },
  {
    category: "MINDSET",
    title: "Progress, bukan kesempurnaan",
    body: "Lewatkan satu sesi tidak menghapus minggumu. Yang penting kembali ke jalur di sesi berikutnya.",
    icon: Brain,
    color: "#EC4899",
  },
  {
    category: "NUTRITION",
    title: "Protein di setiap waktu makan",
    body: "Sebar 1.6–2.2 g protein/kg BB ke dalam 3–4 waktu makan untuk sintesis otot optimal.",
    icon: UtensilsCrossed,
    color: "#10B981",
  },
  {
    category: "RECOVERY",
    title: "Mobility 5 menit > tidak sama sekali",
    body: "Stretching ringan setelah latihan menjaga rentang gerak dan mengurangi risiko cedera.",
    icon: Heart,
    color: "#14B8A6",
  },
  {
    category: "TRAINING",
    title: "Catat angka, lihat polanya",
    body: "Tracking beban dan repetisi adalah cara paling jujur untuk tahu apakah kamu progress.",
    icon: BarChart3,
    color: "#6366F1",
  },
];

// ── Quick Action items (matches mobile grid) ──
const quickActions = [
  { label: "Log\nProgress", icon: BarChart3, href: "/progress", color: "#0B5C5C" },
  { label: "Nutrition\nGuidance", icon: Brain, href: "#", color: "#0EA5E9" },
  { label: "Jadwal", icon: CalendarDays, href: "#", color: "#F59E0B" },
];

// ── Dummy Promo Banners (matches mobile) ──
const promoBanners = [
  {
    id: 1,
    title: "New Program: Hypertrophy Phase 1",
    subtitle: "Build muscle mass efficiently.",
    image: "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1470&auto=format&fit=crop",
    badge: "NEW",
  },
  {
    id: 2,
    title: "Nutrition Guide 101",
    subtitle: "Master your macros and micros.",
    image: "https://images.unsplash.com/photo-1490645935967-10de6ba17061?q=80&w=1453&auto=format&fit=crop",
    badge: "POPULAR",
  },
];

const AutoplayPlugin = typeof Autoplay === "function" ? Autoplay : (Autoplay as any).default;

// Defensively coerce a plan's `features` into a string[]. Handles the
// canonical array, legacy double-encoded rows (a JSON string like
// '["a","b"]'), and any null/unexpected value — so one bad record can
// never crash the dashboard with "x.map is not a function".
function normalizeFeatures(raw: unknown): string[] {
  if (Array.isArray(raw)) return raw as string[];
  if (typeof raw === "string") {
    try {
      const parsed = JSON.parse(raw);
      return Array.isArray(parsed) ? parsed : [];
    } catch {
      return [];
    }
  }
  return [];
}

export default function DashboardPage() {
  const { user } = useAuth();
  const [emblaRef] = useEmblaCarousel({ loop: true }, [AutoplayPlugin({ delay: 4000 })]);

  // Subscription states & queries
  const { subscription, isFree, refetch: refetchSub } = useMySubscription();
  const { data: plansRes } = useSubscriptionPlans();
  const { data: paymentsRes, refetch: refetchPayments } = useMyPayments();
  const { data: bankAccountsRes } = useBankAccounts();

  const subscribeMutation = useSubscribe();
  const cancelSubMutation = useCancelSubscription();
  const uploadProofMutation = useUploadPaymentProof();

  // Selected plan state
  const [showPlansModal, setShowPlansModal] = useState(false);
  const [showPaymentMethodModal, setShowPaymentMethodModal] = useState(false);
  const [billingPeriod, setBillingPeriod] = useState<"monthly" | "quarterly">("monthly");
  const [selectedPlanTier, setSelectedPlanTier] = useState<"sf_tier_2" | "sf_tier_3" | null>(null);
  const [selectedPaymentType, setSelectedPaymentType] = useState<"manual_transfer" | "midtrans_snap" | null>(null);

  const { data: assessmentRes } = useQuery({
    queryKey: ["latest-assessment"],
    queryFn: async () => {
      try {
        return await apiGet<any>("/api/v2/assessments/latest");
      } catch (err: any) {
        const msg = err.message?.toLowerCase() || "";
        if (msg.includes("not found") || msg.includes("no v2 assessment") || msg.includes("404")) {
          return { success: true, data: null };
        }
        throw err;
      }
    },
    retry: false,
    refetchOnMount: false,
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
    staleTime: Infinity,
    gcTime: Infinity,
  });

  const { data: newsRes } = useQuery({
    queryKey: ["health-news"],
    queryFn: () => apiGet<any>("/api/health-news"),
  });

  const { data: videosRes } = useQuery({
    queryKey: ["doctor-videos"],
    queryFn: () => apiGet<any>("/api/doctor-videos"),
  });

  const [selectedArticle, setSelectedArticle] = useState<any | null>(null);
  const [selectedVideo, setSelectedVideo] = useState<any | null>(null);
  const [lang, setLang] = useState("id");

  // Load language settings on mount
  useEffect(() => {
    const saved = localStorage.getItem("locale");
    if (saved === "en" || saved === "id") {
      setLang(saved);
    } else if (typeof window !== "undefined" && window.navigator) {
      const browserLang = window.navigator.language;
      if (browserLang && browserLang.toLowerCase().startsWith("en")) {
        setLang("en");
      }
    }
  }, []);

  const latestAssessment = assessmentRes?.data;

  const isPending = subscription?.status === "pending";
  const activePayments = paymentsRes?.data || [];
  const pendingPayment = activePayments.find(
    (p) => p.status === "pending" && p.subscription_id === subscription?.id
  );
  const bankAccounts = bankAccountsRes?.data || [];

  const getLevelPackageInfo = (level?: string) => {
    switch (level) {
      case "level_0_1":
        return {
          title: lang === "en" ? "Level 0–1 Package" : "Paket Level 0–1",
          desc: lang === "en" ? "Very Restricted (Gentle Movement & Recovery)" : "Sangat Terbatas (Gentle Movement & Pemulihan)",
          details: lang === "en"
            ? "Special program for highly restricted movement (lying or sitting). Designed to accelerate recovery and maintain basic joint mobility."
            : "Program khusus latihan aman untuk kondisi gerak sangat terbatas (berbaring atau duduk). Dirancang untuk mempercepat pemulihan dan menjaga mobilitas sendi dasar.",
        };
      case "level_2_3":
        return {
          title: lang === "en" ? "Level 2–3 Package" : "Paket Level 2–3",
          desc: lang === "en" ? "Restricted (Mobility & Light Functional Training)" : "Terbatas (Latihan Mobilitas & Fungsional Ringan)",
          details: lang === "en"
            ? "Light independent exercise program to improve stabilizing muscles, walking capacity, and standing stability safely."
            : "Program latihan mandiri ringan untuk meningkatkan kekuatan otot penopang tubuh, kapasitas jalan, serta stabilitas berdiri dengan aman.",
        };
      case "level_4_5_perf":
      default:
        return {
          title: lang === "en" ? "Level 4–5 / Performance Package" : "Paket Level 4–5 / Performance",
          desc: lang === "en" ? "Active & Independent (Stamina & Fitness Optimization)" : "Aktif & Mandiri (Optimasi Stamina & Kebugaran)",
          details: lang === "en"
            ? "Medium-intensity structured program to build muscle mass, reduce body fat, balance hormones, and optimize daily energy."
            : "Program latihan terstruktur intensitas sedang untuk membangun massa otot, memangkas lemak tubuh, menyeimbangkan hormon, dan mengoptimalkan energi harian.",
        };
    }
  };

  const levelInfo = getLevelPackageInfo(latestAssessment?.physical_status_level);

  // Tip of the day rotation
  const now = new Date();
  const dayOfYear = Math.floor(
    (now.getTime() - new Date(now.getFullYear(), 0, 0).getTime()) / 86400000
  );
  const tip = tips[dayOfYear % tips.length];
  const TipIcon = tip.icon;

  // Greeting based on time
  const hour = now.getHours();
  const greeting = lang === "en"
    ? (hour < 12 ? "Good Morning" : hour < 17 ? "Good Afternoon" : "Good Evening")
    : (hour < 12 ? "Selamat Pagi" : hour < 17 ? "Selamat Siang" : "Selamat Malam");

  const firstName = user?.name?.split(" ")[0] || "User";

  // Dynamic quick actions: append "Hasil Asesmen" if completed
  const localizedQuickActions = [
    {
      label: lang === "en" ? "Log\nProgress" : "Log\nProgress",
      icon: BarChart3,
      href: "/progress",
      color: "#0B5C5C"
    },
    {
      label: lang === "en" ? "Nutrition\nGuidance" : "Panduan\nNutrisi",
      icon: Brain,
      href: "#",
      color: "#0EA5E9"
    },
    {
      label: lang === "en" ? "Schedule" : "Jadwal",
      icon: CalendarDays,
      href: "#",
      color: "#F59E0B"
    },
    ...(latestAssessment
      ? [
          {
            label: lang === "en" ? "Assessment\nResult" : "Hasil\nAsesmen",
            icon: ClipboardList,
            href: `/assessment/result?id=${latestAssessment.id}`,
            color: "#B8922E",
          },
        ]
      : []),
  ];

  // Subscription action
  const handleAmbilPaket = () => {
    setShowPlansModal(true);
  };

  const selectPlanAndNext = (tier: "sf_tier_2" | "sf_tier_3") => {
    setSelectedPlanTier(tier);
    setShowPlansModal(false);
    setShowPaymentMethodModal(true);
  };

  const executeCheckout = () => {
    if (!selectedPlanTier || !selectedPaymentType || !plansRes) return;

    // Find the correct plan ID based on tier and billing duration
    const group = plansRes.find((p) => p.tier === selectedPlanTier);
    if (!group) {
      toast.error("Format data paket program salah.");
      return;
    }

    const plan = billingPeriod === "monthly" ? group.monthly : group.quarterly || group.annual;
    if (!plan) {
      toast.error("Paket program yang dipilih tidak tersedia.");
      return;
    }

    subscribeMutation.mutate(
      {
        plan_id: plan.id,
        payment_method: selectedPaymentType === "midtrans_snap" ? "midtrans" : "bank_transfer",
        payment_type: selectedPaymentType,
        customer_name: user?.name,
        customer_email: user?.email,
      },
      {
        onSuccess: (res) => {
          setShowPaymentMethodModal(false);
          refetchSub();
          refetchPayments();
          if (res.data?.snap_redirect_url && selectedPaymentType === "midtrans_snap") {
            window.location.href = res.data.snap_redirect_url;
          }
        },
      }
    );
  };

  const handleCancelPending = (subId: string) => {
    if (confirm("Apakah anda yakin ingin membatalkan pesanan langganan ini?")) {
      cancelSubMutation.mutate(subId, {
        onSuccess: () => {
          refetchSub();
          refetchPayments();
        },
      });
    }
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>, paymentId: string) => {
    const file = e.target.files?.[0];
    if (file) {
      uploadProofMutation.mutate(
        { paymentId, file },
        {
          onSuccess: () => {
            refetchSub();
            refetchPayments();
          },
        }
      );
    }
  };

  return (
    <div className="px-4 py-4 space-y-4 animate-fade-in-up">
      {/* ── Greeting Header ──────────────────────────────── */}
      <div className="flex items-center gap-3">
        <div className="w-12 h-12 rounded-full bg-black/5 dark:bg-white/5 flex items-center justify-center shrink-0">
          <span className="text-lg font-bold text-text-primary">
            {firstName.charAt(0).toUpperCase()}
          </span>
        </div>
        <div className="flex-1 min-w-0">
          <h2 className="text-base font-bold text-text-primary truncate">
            {greeting}, {firstName}! 👋
          </h2>
          <p className="text-xs text-text-secondary">
            {now.toLocaleDateString(lang === "en" ? "en-US" : "id-ID", {
              weekday: "long",
              day: "numeric",
              month: "long",
              year: "numeric",
            })}
          </p>
        </div>
      </div>

      {/* ── Promo Banner Slider ────────────────────────────── */}
      <div className="overflow-hidden rounded-2xl" ref={emblaRef}>
        <div className="flex">
          {promoBanners.map((banner) => (
            <div key={banner.id} className="relative flex-[0_0_100%] min-w-0">
              <div className="relative h-40 w-full overflow-hidden bg-black">
                <img
                  src={banner.image}
                  alt={banner.title}
                  className="w-full h-full object-cover opacity-60"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-sf-deepNavy via-sf-deepNavy/40 to-transparent" />
                <div className="absolute bottom-4 left-4 right-4 text-white">
                  {banner.badge && (
                    <span className="inline-block px-2 py-0.5 rounded-full bg-sf-warmGold text-[10px] font-bold tracking-wider mb-2">
                      {banner.badge}
                    </span>
                  )}
                  <h3 className="font-bold text-base leading-tight">{banner.title}</h3>
                  <p className="text-xs text-white/80 mt-1">{banner.subtitle}</p>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* ── Assessment / Level Package Card / Pending Subscription ────────── */}
      {isPending && pendingPayment ? (
        <div className="rounded-2xl border border-amber-500/35 bg-sf-deepNavy p-5 text-white flex flex-col space-y-4 shadow-md">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-amber-500/10 flex items-center justify-center border border-amber-500/20 shrink-0">
              <Clock size={22} className="text-amber-500" />
            </div>
            <div>
              <span className="text-[9px] font-extrabold tracking-widest text-amber-500 uppercase">
                MENUNGGU VERIFIKASI PEMBAYARAN
              </span>
              <h3 className="text-sm font-bold text-white mt-0.5">
                {subscription?.plan_name}
              </h3>
            </div>
          </div>

          <div className="text-[12px] text-white/80 leading-relaxed space-y-2 bg-white/5 rounded-xl p-3.5 border border-white/5">
            {pendingPayment.payment_type === "midtrans_snap" ? (
              <div className="space-y-3">
                <p>
                  Pesanan telah dibuat melalui sistem pembayaran otomatis. Mohon selesaikan
                  transaksi Anda melalui portal pembayaran.
                </p>
                {pendingPayment.snap_redirect_url && (
                  <a
                    href={pendingPayment.snap_redirect_url}
                    target="_blank"
                    rel="noreferrer"
                    className="inline-flex items-center gap-1.5 bg-sf-warmGold hover:bg-sf-warmGoldDark text-white px-4 py-2.5 rounded-lg text-xs font-semibold tracking-wide transition-colors"
                  >
                    Bayar Sekarang (Midtrans) <ExternalLink size={14} />
                  </a>
                )}
              </div>
            ) : (
              <div className="space-y-2.5">
                <p className="font-semibold text-amber-500">Instruksi Transfer Manual:</p>
                <p>
                  Kirim persis sebesar{" "}
                  <strong className="text-sm text-white font-bold sf-data">
                    Rp {Number(pendingPayment.amount).toLocaleString("id-ID")}
                  </strong>{" "}
                  ke rekening di bawah ini:
                </p>
                {bankAccounts.length > 0 ? (
                  <div className="space-y-1.5 pt-1">
                    {bankAccounts.map((b) => (
                      <div
                        key={b.id}
                        className="bg-black/25 rounded-lg p-2.5 text-[11.5px] border border-white/5"
                      >
                        <p className="font-bold text-white/90">Bank {b.bank_name}</p>
                        <p className="text-white select-all font-mono tracking-wider font-semibold text-[13px] mt-0.5">
                          {b.account_number}
                        </p>
                        <p className="text-white/60 text-[10.5px]">a/n {b.account_holder}</p>
                      </div>
                    ))}
                  </div>
                ) : (
                  <p className="text-white/60 text-[11px] italic">
                    Memuat rekening tujuan transfer...
                  </p>
                )}

                {/* Proof Uploader */}
                <div className="pt-2 border-t border-white/10 mt-2">
                  <p className="font-semibold text-white/95 mb-2">Unggah Bukti Transfer:</p>
                  {pendingPayment.proof_image_url ? (
                    <div className="bg-green-500/10 border border-green-500/20 text-green-400 rounded-lg p-2.5 text-[11.5px] flex items-center gap-2">
                      <Check size={16} className="shrink-0" />
                      <span>Bukti transfer berhasil diunggah. Menunggu verifikasi admin.</span>
                    </div>
                  ) : (
                    <label className="flex flex-col items-center justify-center w-full h-24 border-2 border-white/20 border-dashed rounded-xl cursor-pointer hover:bg-white/5 transition-colors">
                      <div className="flex flex-col items-center justify-center pt-3 pb-3">
                        {uploadProofMutation.isPending ? (
                          <>
                            <Loader2 className="animate-spin text-sf-warmGold mb-1.5" size={20} />
                            <p className="text-[11px] text-white/60">Mengunggah...</p>
                          </>
                        ) : (
                          <>
                            <Upload className="text-white/40 mb-1.5" size={20} />
                            <p className="text-[11px] text-white/85 font-semibold">Pilih Gambar Resi</p>
                            <p className="text-[9px] text-white/50 mt-0.5">Format JPG, PNG, WEBP</p>
                          </>
                        )}
                      </div>
                      <input
                        type="file"
                        accept="image/*"
                        className="hidden"
                        onChange={(e) => handleFileChange(e, pendingPayment.id)}
                        disabled={uploadProofMutation.isPending}
                      />
                    </label>
                  )}
                </div>
              </div>
            )}
          </div>

          <div className="flex justify-between items-center pt-2">
            <button
              onClick={() => handleCancelPending(subscription!.id)}
              disabled={cancelSubMutation.isPending}
              className="text-[11px] text-white/50 hover:text-red-400 font-semibold transition-colors flex items-center gap-1"
            >
              {cancelSubMutation.isPending ? "Membatalkan..." : "Batalkan Pesanan Langganan ✕"}
            </button>
          </div>
        </div>
      ) : !latestAssessment ? (
        <Link href="/assessment" className="block group">
          <div className="rounded-2xl bg-sf-deepNavy dark:bg-sf-warmGold p-4 flex items-center gap-3 transition-colors duration-200">
            <div className="w-10 h-10 rounded-xl bg-white/10 dark:bg-sf-deepNavy/20 flex items-center justify-center shrink-0">
              <ClipboardList size={22} className="text-white dark:text-sf-deepNavy" />
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-bold text-white dark:text-sf-deepNavy">
                Complete your Basic Assessment
              </p>
              <p className="text-xs text-white/60 dark:text-sf-deepNavy/80 mt-0.5">
                Sleep, movement, and metabolic baseline
              </p>
            </div>
            <ChevronRight
              size={20}
              className="text-white/50 dark:text-sf-deepNavy/50 shrink-0 group-hover:translate-x-1 transition-transform"
            />
          </div>
        </Link>
      ) : isFree ? (
        <div className="rounded-2xl border border-sf-warmGold/35 bg-sf-deepNavy p-5 text-white flex flex-col items-center text-center space-y-4 shadow-md animate-fade-in">
          <div className="w-14 h-14 rounded-2xl bg-sf-warmGold/15 flex items-center justify-center border border-sf-warmGold/30 shrink-0 animate-pulse">
            <Lock size={28} className="text-sf-warmGold" />
          </div>

          <div className="space-y-1">
            <span className="inline-block px-3 py-1 rounded-full bg-sf-warmGold/10 border border-sf-warmGold/25 text-[10px] font-bold tracking-widest text-sf-warmGold uppercase">
              ASESMEN SELESAI
            </span>
            <h3 className="text-lg font-bold font-dm-serif text-white pt-1.5 leading-snug">
              {levelInfo.title}
            </h3>
            <p className="text-xs text-white/70 font-semibold animate-pulse">{levelInfo.desc}</p>
          </div>

          <p className="bg-white/5 rounded-xl p-3 border border-white/5 text-[11.5px] leading-relaxed text-white/80 max-w-sm">
            {levelInfo.details}
          </p>

          <div className="flex gap-2 w-full max-w-sm">
            <Link
              href={`/assessment/result?id=${latestAssessment.id}`}
              className="flex-1 border border-white/20 hover:bg-white/5 text-white font-semibold py-3 rounded-xl text-[11px] transition-colors tracking-wider uppercase text-center flex items-center justify-center gap-1"
            >
              Lihat Hasil 📋
            </Link>
            <button
              onClick={handleAmbilPaket}
              className="flex-1 bg-sf-warmGold hover:bg-sf-warmGoldDark text-white font-semibold py-3 rounded-xl text-[11px] transition-colors tracking-wider uppercase flex items-center justify-center gap-1"
            >
              Ambil Paket 🔑
            </button>
          </div>
        </div>
      ) : null}

      {/* ── Weekly Goal Card ─────────────────────────────── */}
      <div className="card p-4">
        <div className="flex items-center gap-4">
          {/* Progress Ring */}
          <div className="relative w-[88px] h-[88px] shrink-0">
            <svg className="w-full h-full -rotate-90" viewBox="0 0 88 88">
              <circle cx="44" cy="44" r="38" fill="none" stroke="#E5E7EB" strokeWidth="7" />
              <circle
                cx="44"
                cy="44"
                r="38"
                fill="none"
                stroke="#B8922E"
                strokeWidth="7"
                strokeLinecap="round"
                strokeDasharray={`${0 * 2 * Math.PI * 38} ${2 * Math.PI * 38}`}
              />
            </svg>
            <div className="absolute inset-0 flex flex-col items-center justify-center">
              <span className="text-lg font-bold text-text-primary">0/5</span>
              <span className="text-[9px] text-text-secondary">workouts</span>
            </div>
          </div>
          <div className="flex-1">
            <h3 className="text-sm font-bold text-text-primary">
              {lang === "en" ? "Weekly Goal" : "Goal Mingguan"}
            </h3>
            <p className="text-[11px] text-text-secondary mt-0.5">
              {lang === "en" ? "5 more workouts to reach your goal" : "Lagi 5 workout untuk capai target"}
            </p>
            <div className="flex gap-3 mt-3">
              <div className="flex items-center gap-1.5">
                <div className="w-7 h-7 rounded-lg bg-orange-50 flex items-center justify-center">
                  <Flame size={14} className="text-orange-500" />
                </div>
                <div>
                  <p className="text-xs font-bold text-text-primary leading-tight">0</p>
                  <p className="text-[8px] text-text-secondary leading-tight">
                    {lang === "en" ? "day streak" : "hari streak"}
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-1.5">
                <div className="w-7 h-7 rounded-lg bg-blue-50 flex items-center justify-center">
                  <Clock size={14} className="text-blue-500" />
                </div>
                <div>
                  <p className="text-xs font-bold text-text-primary leading-tight">0h</p>
                  <p className="text-[8px] text-text-secondary leading-tight">
                    {lang === "en" ? "total workout" : "total latihan"}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* ── Quick Actions Grid ───────────────────────────── */}
      <section>
        <h2 className="text-sm font-bold text-text-primary mb-2.5">
          {lang === "en" ? "Quick Actions" : "Quick Actions"}
        </h2>
        <div className="grid grid-cols-3 gap-2.5">
          {localizedQuickActions.map((action, i) => {
            const ActionIcon = action.icon;
            return (
              <Link key={i} href={action.href} className="quick-action group">
                <div
                  className="w-10 h-10 rounded-xl flex items-center justify-center mb-1.5 transition-transform group-hover:scale-110"
                  style={{ backgroundColor: action.color + "15" }}
                >
                  <ActionIcon size={20} style={{ color: action.color }} />
                </div>
                <p className="text-[11px] font-semibold text-text-primary text-center leading-tight whitespace-pre-line">
                  {action.label}
                </p>
              </Link>
            );
          })}
        </div>
      </section>

      {/* ── Health News Section ───────────────────────────── */}
      <section className="space-y-3">
        <h2 className="text-sm font-bold text-text-primary">
          {lang === "en" ? "Latest Health News" : "Berita Kesehatan Terbaru"}
        </h2>
        <div className="space-y-3">
          {newsRes?.data?.map((article: any) => {
            const displayTitle = lang === "en" && article.title_en ? article.title_en : article.title;
            const displayContent = lang === "en" && article.content_en ? article.content_en : article.content;
            return (
              <div
                key={article.id}
                onClick={() => setSelectedArticle(article)}
                className="card p-3 flex gap-3 hover:border-sf-warmGold/40 cursor-pointer transition-all duration-200"
              >
                {article.image_url ? (
                  <img
                    src={article.image_url}
                    alt={displayTitle}
                    className="w-20 h-20 rounded-xl object-cover shrink-0"
                  />
                ) : (
                  <div className="w-20 h-20 rounded-xl bg-slate-100 dark:bg-white/5 flex items-center justify-center shrink-0">
                    <Megaphone size={20} className="text-text-secondary" />
                  </div>
                )}
                <div className="flex-1 min-w-0 flex flex-col justify-between py-0.5">
                  <div>
                    <h3 className="text-xs font-bold text-text-primary line-clamp-2 leading-snug">
                      {displayTitle}
                    </h3>
                    <p className="text-[10px] text-text-secondary line-clamp-2 mt-1 leading-relaxed">
                      {displayContent}
                    </p>
                  </div>
                  <div className="flex justify-between items-center text-[9px] text-text-secondary mt-1">
                    <span>
                      {lang === "en" ? "Source" : "Sumber"}: {article.source}
                    </span>
                    <span>
                      {new Date(article.created_at).toLocaleDateString(lang === "en" ? "en-US" : "id-ID", {
                        day: "numeric",
                        month: "short",
                      })}
                    </span>
                  </div>
                </div>
              </div>
            );
          })}
          {!newsRes?.data?.length && (
            <p className="text-xs text-text-secondary text-center py-4">
              {lang === "en" ? "No health news available." : "Belum ada berita kesehatan."}
            </p>
          )}
        </div>
      </section>

      {/* ── Doctor Videos Section ─────────────────────────── */}
      <section className="space-y-3">
        <h2 className="text-sm font-bold text-text-primary">
          {lang === "en" ? "Recommended Doctor Videos" : "Rekomendasi Video Dokter"}
        </h2>
        <div className="grid grid-cols-2 gap-3">
          {videosRes?.data?.map((video: any) => {
            const displayTitle = lang === "en" && video.title_en ? video.title_en : video.title;
            return (
              <div
                key={video.id}
                onClick={() => setSelectedVideo(video)}
                className="card overflow-hidden hover:border-sf-warmGold/40 cursor-pointer transition-all duration-200"
              >
                <div className="relative aspect-video bg-black flex items-center justify-center">
                  {video.thumbnail_url ? (
                    <img
                      src={video.thumbnail_url}
                      alt={displayTitle}
                      className="w-full h-full object-cover opacity-80"
                    />
                  ) : (
                    <div className="w-full h-full bg-slate-200 dark:bg-white/5" />
                  )}
                  {/* Play Button Overlay */}
                  <div className="absolute inset-0 flex items-center justify-center bg-black/25">
                    <div className="w-9 h-9 rounded-full bg-white/90 dark:bg-sf-deepNavy/90 flex items-center justify-center shadow-md">
                      <span className="text-sf-warmGold text-xs ml-0.5">▶</span>
                    </div>
                  </div>
                </div>
                <div className="p-2.5 space-y-1.5">
                  <h3 className="text-[11px] font-bold text-text-primary line-clamp-2 leading-snug">
                    {displayTitle}
                  </h3>
                  <div className="flex items-center gap-1.5">
                    <div className="w-5 h-5 rounded-full bg-sf-warmGold/10 flex items-center justify-center shrink-0">
                      <span className="text-[9px] font-bold text-sf-warmGold">D</span>
                    </div>
                    <div className="min-w-0">
                      <p className="text-[9px] font-bold text-text-primary truncate">
                        {video.doctor_name}
                      </p>
                      <p className="text-[8px] text-text-secondary truncate">
                        {video.doctor_specialty}
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
        {!videosRes?.data?.length && (
          <p className="text-xs text-text-secondary text-center py-4">
            {lang === "en" ? "No recommended videos available." : "Belum ada video rekomendasi."}
          </p>
        )}
      </section>

      {/* ── Article Detail Modal ─────────────────────────── */}
      {selectedArticle && (
        <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/75 backdrop-blur-md p-4 animate-fade-in" onClick={() => setSelectedArticle(null)}>
          <div className="relative w-full max-w-lg bg-sf-deepNavy border border-sf-warmGold/20 rounded-t-3xl sm:rounded-3xl p-6 shadow-2xl text-white max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <button
              onClick={() => setSelectedArticle(null)}
              className="absolute top-4 right-4 w-8 h-8 rounded-full bg-white/5 flex items-center justify-center hover:bg-white/10 transition-colors"
            >
              <X size={16} />
            </button>
            <div className="space-y-4">
              {selectedArticle.image_url && (
                <img
                  src={selectedArticle.image_url}
                  alt={lang === "en" && selectedArticle.title_en ? selectedArticle.title_en : selectedArticle.title}
                  className="w-full h-48 rounded-xl object-cover"
                />
              )}
              <div className="space-y-1">
                <span className="text-[9px] font-extrabold tracking-widest text-sf-warmGold uppercase">
                  {lang === "en" ? "SOURCE" : "SUMBER"}: {selectedArticle.source}
                </span>
                <h3 className="text-lg font-bold leading-snug">
                  {lang === "en" && selectedArticle.title_en ? selectedArticle.title_en : selectedArticle.title}
                </h3>
                <p className="text-[10px] text-white/50">
                  {lang === "en" ? "Published on" : "Diterbitkan pada"}{" "}
                  {new Date(selectedArticle.created_at).toLocaleDateString(lang === "en" ? "en-US" : "id-ID", {
                    day: "numeric",
                    month: "long",
                    year: "numeric",
                  })}
                </p>
              </div>
              <div className="divider" />
              <p className="text-xs leading-relaxed text-white/90 whitespace-pre-wrap">
                {lang === "en" && selectedArticle.content_en ? selectedArticle.content_en : selectedArticle.content}
              </p>
            </div>
          </div>
        </div>
      )}

      {/* ── Video Player Modal ───────────────────────────── */}
      {selectedVideo && (
        <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/75 backdrop-blur-md p-4 animate-fade-in" onClick={() => setSelectedVideo(null)}>
          <div className="relative w-full max-w-2xl bg-sf-deepNavy border border-sf-warmGold/20 rounded-t-3xl sm:rounded-3xl p-6 shadow-2xl text-white" onClick={(e) => e.stopPropagation()}>
            <button
              onClick={() => setSelectedVideo(null)}
              className="absolute top-4 right-4 w-8 h-8 rounded-full bg-white/5 flex items-center justify-center hover:bg-white/10 transition-colors"
            >
              <X size={16} />
            </button>
            <div className="space-y-4">
              <h3 className="text-base font-bold pr-8 leading-snug">
                {lang === "en" && selectedVideo.title_en ? selectedVideo.title_en : selectedVideo.title}
              </h3>
              <div className="aspect-video w-full rounded-xl overflow-hidden bg-black">
                <iframe
                  src={selectedVideo.video_url}
                  title={lang === "en" && selectedVideo.title_en ? selectedVideo.title_en : selectedVideo.title}
                  className="w-full h-full border-0"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowFullScreen
                />
              </div>
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-8 rounded-full bg-sf-warmGold/10 flex items-center justify-center shrink-0">
                  <span className="text-xs font-bold text-sf-warmGold">Dr</span>
                </div>
                <div>
                  <p className="text-xs font-bold">{selectedVideo.doctor_name}</p>
                  <p className="text-[10px] text-white/50">{selectedVideo.doctor_specialty}</p>
                </div>
              </div>
              {(lang === "en" && selectedVideo.description_en ? selectedVideo.description_en : selectedVideo.description) && (
                <p className="text-xs text-white/70 leading-relaxed bg-white/5 p-3 rounded-lg">
                  {lang === "en" && selectedVideo.description_en ? selectedVideo.description_en : selectedVideo.description}
                </p>
              )}
            </div>
          </div>
        </div>
      )}


      {/* ── Tip of the Day ───────────────────────────────── */}
      <div className="card p-4">
        <div className="flex gap-3">
          <div
            className="w-12 h-12 rounded-2xl flex items-center justify-center shrink-0"
            style={{ backgroundColor: tip.color + "18" }}
          >
            <TipIcon size={24} style={{ color: tip.color }} />
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 mb-1">
              <span
                className="text-[9px] font-extrabold tracking-wide px-2 py-0.5 rounded-full"
                style={{ backgroundColor: tip.color + "18", color: tip.color }}
              >
                {tip.category}
              </span>
              <span className="text-[10px] text-text-secondary font-semibold">
                {lang === "en" ? "Tip of the Day" : "Tip Hari Ini"}
              </span>
            </div>
            <h3 className="text-sm font-extrabold text-text-primary leading-snug">{tip.title}</h3>
            <p className="text-[11px] text-text-secondary mt-1 leading-relaxed">{tip.body}</p>
          </div>
        </div>
      </div>

      {/* ── MODALS SEQUENCE ──────────────────────────────── */}

      {/* 1. Plans Selector Modal */}
      {showPlansModal && (
        <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/75 backdrop-blur-md p-4 animate-fade-in">
          <div className="w-full max-w-lg bg-sf-deepNavy border border-sf-warmGold/20 rounded-t-3xl sm:rounded-3xl p-6 sm:p-8 shadow-[0_0_50px_rgba(184,146,46,0.15)] space-y-6 overflow-y-auto max-h-[90vh] transition-all text-white relative">
            
            <div className="flex items-center justify-between pb-3.5 border-b border-white/10">
              <div>
                <span className="text-[10px] font-black tracking-widest text-sf-warmGold uppercase">
                  INVESTASI KESEHATAN
                </span>
                <h3 className="text-xl sm:text-2xl font-bold font-dm-serif text-white mt-1">
                  Pilih Paket Program 🔑
                </h3>
                <p className="text-xs text-white/60 mt-1">
                  Pilih program latihan terkurasi sesuai profil klinis & level fisik Anda
                </p>
              </div>
              <button
                onClick={() => setShowPlansModal(false)}
                className="w-9 h-9 rounded-full bg-white/5 flex items-center justify-center text-white/60 hover:text-white hover:bg-white/10 transition-colors shrink-0 self-start"
              >
                <X size={18} />
              </button>
            </div>

            {/* Billing Period Selector */}
            <div className="bg-sf-midnightBlue/30 p-1.5 rounded-2xl flex gap-1.5 border border-white/5">
              <button
                onClick={() => setBillingPeriod("monthly")}
                className={`flex-1 py-3 text-xs font-black rounded-xl transition-all duration-300 ${
                  billingPeriod === "monthly"
                    ? "bg-gradient-to-r from-sf-warmGold to-sf-warmGoldDark text-white shadow-lg shadow-sf-warmGold/10 transform scale-[1.01]"
                    : "text-white/60 hover:text-white hover:bg-white/5"
                }`}
              >
                Bayar Bulanan
              </button>
              <button
                onClick={() => setBillingPeriod("quarterly")}
                className={`flex-1 py-3 text-xs font-black rounded-xl transition-all duration-300 flex items-center justify-center gap-1.5 ${
                  billingPeriod === "quarterly"
                    ? "bg-gradient-to-r from-sf-warmGold to-sf-warmGoldDark text-white shadow-lg shadow-sf-warmGold/10 transform scale-[1.01]"
                    : "text-white/60 hover:text-white hover:bg-white/5"
                }`}
              >
                Bayar 3 Bulan
                <span className="bg-green-500 text-white text-[8px] font-extrabold px-2 py-0.5 rounded-full uppercase tracking-wider shadow-sm">
                  Hemat 15%
                </span>
              </button>
            </div>

            {/* Plans List */}
            <div className="space-y-6">
              {plansRes
                ?.filter((group) => group.tier === "sf_tier_2" || group.tier === "sf_tier_3")
                ?.map((group) => {
                  const plan = billingPeriod === "monthly" ? group.monthly : group.quarterly || group.annual;
                  if (!plan) return null;

                  const isPopular = plan.tier === "sf_tier_3";
                  // `features` should be a string[], but guard against legacy
                  // rows where it arrives as a JSON-encoded string (or null)
                  // so a bad record can never crash the whole dashboard.
                  const features = normalizeFeatures(plan.features);

                  return (
                    <div
                      key={plan.id}
                      className={`group relative rounded-2xl p-5 space-y-4 transition-all duration-300 ${
                        isPopular
                          ? "border-2 border-sf-warmGold bg-gradient-to-b from-sf-warmGold/15 to-sf-deepNavy shadow-[0_0_30px_rgba(184,146,46,0.15)] overflow-hidden"
                          : "border border-white/10 bg-sf-midnightBlue/20 hover:border-white/20"
                      }`}
                    >
                      {isPopular && (
                        <>
                          <div className="absolute -top-10 -right-10 w-24 h-24 bg-sf-warmGold/20 rounded-full blur-2xl pointer-events-none" />
                          <span className="absolute top-0 right-5 -translate-y-1/2 bg-gradient-to-r from-sf-warmGold to-sf-warmGoldDark text-white text-[9px] font-black px-3 py-1 rounded-full tracking-widest uppercase shadow-md border border-sf-warmGold/35">
                            REKOMENDASI MEDIS
                          </span>
                        </>
                      )}

                      <div className="flex justify-between items-start gap-4">
                        <div className="space-y-1">
                          <div className="flex items-center gap-2">
                            <span className={`w-2 h-2 rounded-full ${isPopular ? "bg-sf-warmGold animate-ping" : "bg-green-400 animate-pulse"}`} />
                            <span className={`text-[10px] font-bold uppercase tracking-widest ${isPopular ? "text-sf-warmGold" : "text-green-400"}`}>
                              {isPopular ? "MEDICAL & PREVENTIVE CURATION" : "PROGRAM OTOMATIS & TERARAH"}
                            </span>
                          </div>
                          <h4 className="text-base font-bold text-white leading-tight">
                            {plan.name}
                          </h4>
                        </div>
                        <div className="text-right shrink-0">
                          <p className={`text-lg font-black sf-data ${isPopular ? "text-sf-warmGold" : "text-white"}`}>
                            Rp {new Intl.NumberFormat("id-ID").format(plan.price)}
                          </p>
                          <p className="text-[10px] text-white/50">
                            /{billingPeriod === "monthly" ? "bulan" : "3 bulan"}
                          </p>
                        </div>
                      </div>

                      {plan.description && (
                        <p className="text-xs text-white/70 leading-relaxed bg-white/5 p-3 rounded-xl border border-white/5">
                          {plan.description}
                        </p>
                      )}

                      <ul className={`grid grid-cols-1 gap-2 border-t pt-4 text-[11.5px] ${isPopular ? "border-sf-warmGold/20 text-white/90" : "border-white/10 text-white/80"}`}>
                        {features.map((feat, idx) => (
                          <li key={idx} className="flex items-start gap-2.5">
                            <span className={`w-4 h-4 rounded-full flex items-center justify-center shrink-0 mt-0.5 border ${isPopular ? "bg-sf-warmGold/25 border-sf-warmGold/40" : "bg-green-500/10 border-green-500/20"}`}>
                              <Check size={10} className={isPopular ? "text-sf-warmGold" : "text-green-400"} />
                            </span>
                            <span className="leading-tight">{feat}</span>
                          </li>
                        ))}
                      </ul>

                      <button
                        onClick={() => selectPlanAndNext(group.tier as any)}
                        className={`w-full mt-2 py-3 rounded-xl text-xs font-black tracking-wider uppercase transition-all duration-300 active:scale-[0.98] ${
                          isPopular
                            ? "bg-gradient-to-r from-sf-warmGold to-sf-warmGoldDark hover:from-sf-warmGoldDark hover:to-sf-warmGold text-white shadow-lg shadow-sf-warmGold/20"
                            : "bg-white/10 hover:bg-sf-warmGold hover:text-white text-white hover:shadow-[0_0_15px_rgba(184,146,46,0.3)]"
                        }`}
                      >
                        Pilih {plan.name} 🔑
                      </button>
                    </div>
                  );
                })}
            </div>
          </div>
        </div>
      )}

      {/* 2. Payment Method Selector Modal */}
      {showPaymentMethodModal && (
        <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/75 backdrop-blur-md p-4 animate-fade-in">
          <div className="w-full max-w-md bg-sf-deepNavy border border-sf-warmGold/20 rounded-t-3xl sm:rounded-3xl p-6 sm:p-8 shadow-[0_0_50px_rgba(184,146,46,0.15)] space-y-6 text-white relative">
            <div className="flex items-center justify-between pb-3.5 border-b border-white/10">
              <div>
                <span className="text-[10px] font-black tracking-widest text-sf-warmGold uppercase">
                  METODE PEMBAYARAN
                </span>
                <h3 className="text-xl font-bold font-dm-serif text-white mt-1">
                  Selesaikan Pesanan 💳
                </h3>
                <p className="text-xs text-white/60 mt-1">
                  Pilih metode pembayaran di bawah untuk mengaktifkan paket Anda
                </p>
              </div>
              <button
                onClick={() => setShowPaymentMethodModal(false)}
                className="w-9 h-9 rounded-full bg-white/5 flex items-center justify-center text-white/60 hover:text-white hover:bg-white/10 transition-colors shrink-0 self-start"
              >
                <X size={18} />
              </button>
            </div>

            {/* Order Summary box */}
            <div className="bg-sf-midnightBlue/30 border border-white/5 p-4 rounded-xl space-y-2">
              <div className="flex justify-between text-xs">
                <span className="text-white/60">Paket Terpilih:</span>
                <span className="font-bold text-white">
                  {selectedPlanTier === "sf_tier_2"
                    ? "Tier 2 — Dinamis (Level 5 & 6)"
                    : "Tier 3 — System Active"}
                </span>
              </div>
              <div className="flex justify-between text-xs">
                <span className="text-white/60">Durasi:</span>
                <span className="font-bold text-white">
                  {billingPeriod === "monthly" ? "Bulanan (1 Bulan)" : "Triwulan (3 Bulan)"}
                </span>
              </div>
              <div className="border-t border-white/5 my-2 pt-2 flex justify-between items-baseline">
                <span className="text-xs font-bold text-sf-warmGold">Total Tagihan:</span>
                <span className="text-lg font-black text-sf-warmGold sf-data">
                  {selectedPlanTier === "sf_tier_2"
                    ? billingPeriod === "monthly"
                      ? "Rp 499.000"
                      : "Rp 1.272.000"
                    : billingPeriod === "monthly"
                    ? "Rp 799.000"
                    : "Rp 2.037.000"}
                </span>
              </div>
            </div>

            <div className="space-y-4">
              {/* Midtrans Option */}
              <button
                onClick={() => setSelectedPaymentType("midtrans_snap")}
                className={`w-full p-4.5 rounded-2xl border text-left flex items-start gap-4 transition-all duration-300 ${
                  selectedPaymentType === "midtrans_snap"
                    ? "border-sf-warmGold bg-sf-warmGold/10 shadow-[0_0_15px_rgba(184,146,46,0.1)]"
                    : "border-white/10 hover:border-white/20 bg-white/5"
                }`}
              >
                <div className="w-11 h-11 rounded-xl bg-blue-500/10 flex items-center justify-center border border-blue-500/20 text-blue-400 shrink-0 mt-0.5">
                  <CreditCard size={22} />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-1.5">
                    <h5 className="text-sm font-bold text-white">Sistem Pembayaran Instan</h5>
                    <span className="bg-blue-500/10 text-blue-400 text-[8px] font-black px-1.5 py-0.5 rounded-full uppercase tracking-wider scale-90">
                      OTOMATIS
                    </span>
                  </div>
                  <p className="text-[11px] text-white/60 leading-relaxed mt-1">
                    Gunakan Virtual Account Bank (BCA, Mandiri, dll), QRIS, GoPay, ShopeePay, atau Kartu Kredit. Pembayaran Anda langsung diproses instan tanpa harus upload bukti transfer.
                  </p>
                </div>
                <div className="self-center shrink-0">
                  <div
                    className={`w-5 h-5 rounded-full border flex items-center justify-center transition-all ${
                      selectedPaymentType === "midtrans_snap"
                        ? "border-sf-warmGold bg-sf-warmGold text-white scale-110"
                        : "border-white/20"
                    }`}
                  >
                    {selectedPaymentType === "midtrans_snap" && <Check size={12} />}
                  </div>
                </div>
              </button>

              {/* Manual Transfer Option */}
              <button
                onClick={() => setSelectedPaymentType("manual_transfer")}
                className={`w-full p-4.5 rounded-2xl border text-left flex items-start gap-4 transition-all duration-300 ${
                  selectedPaymentType === "manual_transfer"
                    ? "border-sf-warmGold bg-sf-warmGold/10 shadow-[0_0_15px_rgba(184,146,46,0.1)]"
                    : "border-white/10 hover:border-white/20 bg-white/5"
                }`}
              >
                <div className="w-11 h-11 rounded-xl bg-green-500/10 flex items-center justify-center border border-green-500/20 text-green-400 shrink-0 mt-0.5">
                  <FileText size={22} />
                </div>
                <div className="flex-1 min-w-0">
                  <h5 className="text-sm font-bold text-white">Transfer Bank Manual</h5>
                  <p className="text-[11px] text-white/60 leading-relaxed mt-1">
                    Transfer manual via ATM/M-Banking Anda ke rekening resmi BCA/BRI kami. Memerlukan verifikasi admin (maksimal 1x24 jam) setelah Anda mengunggah bukti resi transfer.
                  </p>
                </div>
                <div className="self-center shrink-0">
                  <div
                    className={`w-5 h-5 rounded-full border flex items-center justify-center transition-all ${
                      selectedPaymentType === "manual_transfer"
                        ? "border-sf-warmGold bg-sf-warmGold text-white scale-110"
                        : "border-white/20"
                    }`}
                  >
                    {selectedPaymentType === "manual_transfer" && <Check size={12} />}
                  </div>
                </div>
              </button>
            </div>

            {/* Buttons Actions */}
            <div className="flex gap-3 pt-2">
              <button
                onClick={() => {
                  setShowPaymentMethodModal(false);
                  setShowPlansModal(true);
                }}
                className="flex-1 border border-white/10 hover:bg-white/5 text-white/80 py-3.5 rounded-xl text-xs font-black tracking-wider uppercase transition-colors"
              >
                Kembali
              </button>
              <button
                onClick={executeCheckout}
                disabled={!selectedPaymentType || subscribeMutation.isPending}
                className="flex-2 bg-gradient-to-r from-sf-warmGold to-sf-warmGoldDark hover:from-sf-warmGoldDark hover:to-sf-warmGold text-white py-3.5 rounded-xl text-xs font-black tracking-wider uppercase transition-all duration-300 flex items-center justify-center gap-2 disabled:opacity-50 hover:shadow-lg hover:shadow-sf-warmGold/20 active:scale-[0.98]"
              >
                {subscribeMutation.isPending && <Loader2 size={16} className="animate-spin" />}
                Bayar Sekarang 🔑
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
