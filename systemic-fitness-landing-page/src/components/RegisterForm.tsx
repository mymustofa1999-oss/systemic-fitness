"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  User,
  Mail,
  Lock,
  Phone,
  Eye,
  EyeOff,
  ArrowRight,
  ArrowLeft,
  Check,
  Sparkles,
  Loader2,
  Shield,
} from "lucide-react";

const API_BASE = "https://api.systemicfitnesshealth.com/api";

interface Plan {
  id: string;
  name: string;
  tier: string;
  price: number;
  currency: string;
  billing_period: string;
  duration_months: number;
  description?: string;
}

interface PlanGroup {
  tier: string;
  monthly?: Plan;
  annual?: Plan;
}

type Step = "register" | "plans" | "checkout";

export function RegisterForm() {
  const [step, setStep] = useState<Step>("register");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  // Register form
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [phone, setPhone] = useState("");
  const [showPassword, setShowPassword] = useState(false);

  // Auth token
  const [token, setToken] = useState("");

  // Plans
  const [plans, setPlans] = useState<PlanGroup[]>([]);
  const [billingPeriod, setBillingPeriod] = useState<"monthly" | "annual">(
    "monthly"
  );
  const [selectedPlan, setSelectedPlan] = useState<Plan | null>(null);

  // ── Step 1: Register ──────────────────────────────────────────
  async function handleRegister(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      let accessToken = "";

      // 1. Register
      const regRes = await fetch(`${API_BASE}/auth/register`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          full_name: name,
          email,
          password,
          phone: phone || undefined,
        }),
      });
      const regData = await regRes.json();
      
      if (regRes.ok) {
        accessToken = regData.data?.tokens?.access_token;
      } else {
        // Jika email sudah ada, coba auto-login (handle user yg batal bayar sebelumnya)
        if (regRes.status === 409 || regData.message?.toLowerCase().includes("registered") || regData.message?.toLowerCase().includes("taken")) {
          const loginRes = await fetch(`${API_BASE}/auth/login`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ email, password }),
          });
          const loginData = await loginRes.json();
          if (loginRes.ok) {
            accessToken = loginData.data?.tokens?.access_token;
          } else {
            throw new Error("Email ini sudah terdaftar. Jika ini Anda, pastikan password yang dimasukkan benar.");
          }
        } else {
          throw new Error(regData.message || "Gagal mendaftar");
        }
      }

      if (!accessToken) throw new Error("Gagal mendapatkan akses token");
      setToken(accessToken);

      // 3. Fetch plans
      const plansRes = await fetch(`${API_BASE}/subscription/plans`, {
        headers: { Authorization: `Bearer ${accessToken}` },
      });
      const plansData = await plansRes.json();
      if (plansRes.ok && plansData.data) {
        setPlans(plansData.data);
      }

      setStep("plans");
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : "Terjadi kesalahan");
    } finally {
      setLoading(false);
    }
  }

  // ── Step 2: Select Plan ───────────────────────────────────────
  function handleSelectPlan(plan: Plan) {
    setSelectedPlan(plan);
    setStep("checkout");
  }

  // ── Step 3: Checkout ──────────────────────────────────────────
  async function handleCheckout() {
    if (!selectedPlan || !token) return;
    setError("");
    setLoading(true);

    try {
      const res = await fetch(`${API_BASE}/subscription/subscribe`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({
          plan_id: selectedPlan.id,
          payment_method: "midtrans",
          payment_type: "midtrans_snap",
          customer_name: name,
          customer_email: email,
          customer_phone: phone,
        }),
      });
      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.message || "Gagal memproses pembayaran");
      }

      const redirectUrl = data.data?.snap_redirect_url;
      if (redirectUrl) {
        window.location.href = redirectUrl;
      } else {
        throw new Error("URL pembayaran tidak tersedia");
      }
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : "Terjadi kesalahan");
    } finally {
      setLoading(false);
    }
  }

  // ── Formatters ────────────────────────────────────────────────
  function formatPrice(price: number) {
    return new Intl.NumberFormat("id-ID").format(price);
  }

  // ── Render ────────────────────────────────────────────────────
  return (
    <div className="max-w-2xl mx-auto w-full">
      {/* Progress Steps */}
      <div className="flex items-center justify-center gap-2 mb-10">
        {(["register", "plans", "checkout"] as Step[]).map((s, i) => {
          const isActive = step === s;
          const isDone =
            (s === "register" && step !== "register") ||
            (s === "plans" && step === "checkout");
          return (
            <div key={s} className="flex items-center gap-2">
              <div
                className={`w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold transition-all ${
                  isDone
                    ? "bg-brand-teal text-white dark:bg-[#5DCAA5]"
                    : isActive
                    ? "bg-navy text-white dark:bg-brand-gold"
                    : "bg-[rgba(10,22,40,0.06)] dark:bg-white/10 text-brand-gray dark:text-white/40"
                }`}
              >
                {isDone ? <Check className="w-4 h-4" /> : i + 1}
              </div>
              {i < 2 && (
                <div
                  className={`w-12 h-0.5 ${
                    isDone
                      ? "bg-brand-teal dark:bg-[#5DCAA5]"
                      : "bg-[rgba(10,22,40,0.08)] dark:bg-white/10"
                  }`}
                />
              )}
            </div>
          );
        })}
      </div>

      <AnimatePresence mode="wait">
        {/* ── STEP 1: Register ─────────────────────────────── */}
        {step === "register" && (
          <motion.div
            key="register"
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            transition={{ duration: 0.3 }}
          >
            <div className="bg-white dark:bg-white/5 border border-[rgba(10,22,40,0.12)] dark:border-white/10 rounded-3xl p-8 md:p-10 shadow-sm">
              <div className="text-center mb-8">
                <div className="inline-flex items-center justify-center w-14 h-14 rounded-2xl bg-navy/5 dark:bg-brand-gold/10 mb-4">
                  <User className="w-7 h-7 text-navy dark:text-brand-gold" />
                </div>
                <h2 className="font-display text-2xl text-navy dark:text-white mb-2">
                  Buat Akun Anda
                </h2>
                <p className="text-sm text-brand-gray dark:text-white/50">
                  Daftar untuk memulai perjalanan kesehatan Anda
                </p>
              </div>

              <form onSubmit={handleRegister} className="space-y-4">
                {/* Name */}
                <div className="relative">
                  <User className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-brand-gray/40 dark:text-white/30" />
                  <input
                    type="text"
                    placeholder="Nama Lengkap"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    required
                    className="w-full pl-11 pr-4 py-3.5 rounded-xl border border-[rgba(10,22,40,0.12)] dark:border-white/15 bg-transparent text-navy dark:text-white placeholder:text-brand-gray/40 dark:placeholder:text-white/30 text-[15px] outline-none focus:border-brand-blue dark:focus:border-brand-gold transition-colors"
                  />
                </div>

                {/* Email */}
                <div className="relative">
                  <Mail className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-brand-gray/40 dark:text-white/30" />
                  <input
                    type="email"
                    placeholder="Email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                    className="w-full pl-11 pr-4 py-3.5 rounded-xl border border-[rgba(10,22,40,0.12)] dark:border-white/15 bg-transparent text-navy dark:text-white placeholder:text-brand-gray/40 dark:placeholder:text-white/30 text-[15px] outline-none focus:border-brand-blue dark:focus:border-brand-gold transition-colors"
                  />
                </div>

                {/* Phone */}
                <div className="relative">
                  <Phone className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-brand-gray/40 dark:text-white/30" />
                  <input
                    type="tel"
                    placeholder="Nomor HP (opsional)"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    className="w-full pl-11 pr-4 py-3.5 rounded-xl border border-[rgba(10,22,40,0.12)] dark:border-white/15 bg-transparent text-navy dark:text-white placeholder:text-brand-gray/40 dark:placeholder:text-white/30 text-[15px] outline-none focus:border-brand-blue dark:focus:border-brand-gold transition-colors"
                  />
                </div>

                {/* Password */}
                <div className="relative">
                  <Lock className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-brand-gray/40 dark:text-white/30" />
                  <input
                    type={showPassword ? "text" : "password"}
                    placeholder="Password (min 8 karakter)"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                    minLength={8}
                    className="w-full pl-11 pr-11 py-3.5 rounded-xl border border-[rgba(10,22,40,0.12)] dark:border-white/15 bg-transparent text-navy dark:text-white placeholder:text-brand-gray/40 dark:placeholder:text-white/30 text-[15px] outline-none focus:border-brand-blue dark:focus:border-brand-gold transition-colors"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-4 top-1/2 -translate-y-1/2 text-brand-gray/40 dark:text-white/30"
                  >
                    {showPassword ? (
                      <EyeOff className="w-4 h-4" />
                    ) : (
                      <Eye className="w-4 h-4" />
                    )}
                  </button>
                </div>

                {error && (
                  <div className="text-red-500 text-sm text-center bg-red-50 dark:bg-red-500/10 rounded-lg py-2.5 px-4">
                    {error}
                  </div>
                )}

                <button
                  type="submit"
                  disabled={loading}
                  className="w-full flex items-center justify-center gap-2 py-3.5 rounded-xl bg-navy dark:bg-brand-gold text-white text-[15px] font-medium transition-all hover:opacity-90 disabled:opacity-50"
                >
                  {loading ? (
                    <Loader2 className="w-4 h-4 animate-spin" />
                  ) : (
                    <>
                      Lanjut Pilih Plan
                      <ArrowRight className="w-4 h-4" />
                    </>
                  )}
                </button>
              </form>

              <p className="text-center text-xs text-brand-gray/50 dark:text-white/30 mt-5">
                Sudah punya akun?{" "}
                <a href="/" className="underline text-brand-blue dark:text-brand-gold">
                  Buka aplikasi untuk login
                </a>
              </p>
            </div>
          </motion.div>
        )}

        {/* ── STEP 2: Plans ────────────────────────────────── */}
        {step === "plans" && (
          <motion.div
            key="plans"
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            transition={{ duration: 0.3 }}
          >
            <div className="text-center mb-6">
              <h2 className="font-display text-2xl text-navy dark:text-white mb-2">
                Pilih Plan Anda
              </h2>
              <p className="text-sm text-brand-gray dark:text-white/50">
                Pilih program yang sesuai dengan kebutuhan kesehatan Anda
              </p>
            </div>

            {/* Period toggle */}
            <div className="flex justify-center mb-6">
              <div className="inline-flex items-center bg-warm-white dark:bg-white/5 border border-[rgba(10,22,40,0.1)] dark:border-white/10 rounded-full p-1">
                {(["monthly", "annual"] as const).map((p) => (
                  <button
                    key={p}
                    onClick={() => setBillingPeriod(p)}
                    className={`relative px-5 py-2 text-[13px] font-medium rounded-full transition-colors ${
                      billingPeriod === p
                        ? "bg-navy dark:bg-brand-gold text-white"
                        : "text-navy/70 dark:text-white/70"
                    }`}
                  >
                    {p === "monthly" ? "Bulanan" : "Tahunan"}
                    {p === "annual" && (
                      <span className="ml-1.5 text-[10px] bg-brand-teal/20 text-brand-teal dark:bg-[#5DCAA5]/15 dark:text-[#5DCAA5] rounded-full px-1.5 py-0.5">
                        –20%
                      </span>
                    )}
                  </button>
                ))}
              </div>
            </div>

            <div className="space-y-3">
              {plans.map((group) => {
                const plan =
                  billingPeriod === "annual" && group.annual
                    ? group.annual
                    : group.monthly;
                if (!plan || plan.price === 0) return null;

                return (
                  <button
                    key={plan.id}
                    onClick={() => handleSelectPlan(plan)}
                    className="w-full bg-white dark:bg-white/5 border border-[rgba(10,22,40,0.12)] dark:border-white/10 rounded-2xl p-5 text-left transition-all hover:border-brand-blue dark:hover:border-brand-gold hover:-translate-y-0.5 hover:shadow-md"
                  >
                    <div className="flex items-center justify-between">
                      <div>
                        <div className="text-[15px] font-medium text-navy dark:text-white mb-1">
                          {plan.name}
                        </div>
                        <div className="text-xs text-brand-gray dark:text-white/50">
                          {plan.description || group.tier}
                        </div>
                      </div>
                      <div className="text-right">
                        <div className="font-mono text-lg text-navy dark:text-white">
                          Rp {formatPrice(plan.price)}
                        </div>
                        <div className="text-xs text-brand-gray dark:text-white/50">
                          /{" "}
                          {plan.billing_period === "annual"
                            ? "tahun"
                            : "bulan"}
                        </div>
                      </div>
                    </div>
                  </button>
                );
              })}
            </div>

            <button
              onClick={() => setStep("register")}
              className="flex items-center justify-center gap-2 w-full mt-4 py-3 text-sm text-brand-gray dark:text-white/50 hover:text-navy dark:hover:text-white transition-colors"
            >
              <ArrowLeft className="w-4 h-4" />
              Kembali
            </button>
          </motion.div>
        )}

        {/* ── STEP 3: Checkout ────────────────────────────── */}
        {step === "checkout" && selectedPlan && (
          <motion.div
            key="checkout"
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            transition={{ duration: 0.3 }}
          >
            <div className="bg-white dark:bg-white/5 border border-[rgba(10,22,40,0.12)] dark:border-white/10 rounded-3xl p-8 md:p-10 shadow-sm">
              <div className="text-center mb-8">
                <div className="inline-flex items-center justify-center w-14 h-14 rounded-2xl bg-brand-gold/10 mb-4">
                  <Sparkles className="w-7 h-7 text-brand-gold" />
                </div>
                <h2 className="font-display text-2xl text-navy dark:text-white mb-2">
                  Ringkasan Pesanan
                </h2>
              </div>

              {/* Order summary */}
              <div className="bg-warm-white dark:bg-white/5 rounded-2xl p-5 mb-6">
                <div className="flex justify-between items-start mb-3">
                  <div>
                    <div className="text-[15px] font-medium text-navy dark:text-white">
                      {selectedPlan.name}
                    </div>
                    <div className="text-xs text-brand-gray dark:text-white/50 mt-0.5">
                      {selectedPlan.billing_period === "annual"
                        ? "Tahunan"
                        : "Bulanan"}{" "}
                      · {selectedPlan.duration_months} bulan
                    </div>
                  </div>
                  <div className="font-mono text-lg text-navy dark:text-white">
                    Rp {formatPrice(selectedPlan.price)}
                  </div>
                </div>
                <div className="border-t border-[rgba(10,22,40,0.08)] dark:border-white/10 pt-3 flex justify-between">
                  <span className="text-sm font-medium text-navy dark:text-white">
                    Total
                  </span>
                  <span className="font-mono text-lg font-bold text-navy dark:text-white">
                    Rp {formatPrice(selectedPlan.price)}
                  </span>
                </div>
              </div>

              {/* Customer info */}
              <div className="space-y-2 mb-6">
                <div className="flex justify-between text-sm">
                  <span className="text-brand-gray dark:text-white/50">
                    Nama
                  </span>
                  <span className="text-navy dark:text-white">{name}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-brand-gray dark:text-white/50">
                    Email
                  </span>
                  <span className="text-navy dark:text-white">{email}</span>
                </div>
              </div>

              {/* Security note */}
              <div className="flex items-center gap-2 text-xs text-brand-gray/60 dark:text-white/30 mb-6 bg-warm-white dark:bg-white/5 rounded-lg p-3">
                <Shield className="w-4 h-4 flex-shrink-0" />
                <span>
                  Pembayaran aman melalui Midtrans. Kami tidak menyimpan data
                  kartu kredit Anda.
                </span>
              </div>

              {error && (
                <div className="text-red-500 text-sm text-center bg-red-50 dark:bg-red-500/10 rounded-lg py-2.5 px-4 mb-4">
                  {error}
                </div>
              )}

              <button
                onClick={handleCheckout}
                disabled={loading}
                className="w-full flex items-center justify-center gap-2 py-3.5 rounded-xl bg-brand-gold text-white text-[15px] font-medium transition-all hover:opacity-90 disabled:opacity-50"
              >
                {loading ? (
                  <Loader2 className="w-4 h-4 animate-spin" />
                ) : (
                  <>
                    Bayar Sekarang
                    <ArrowRight className="w-4 h-4" />
                  </>
                )}
              </button>

              <button
                onClick={() => setStep("plans")}
                className="flex items-center justify-center gap-2 w-full mt-3 py-3 text-sm text-brand-gray dark:text-white/50 hover:text-navy dark:hover:text-white transition-colors"
              >
                <ArrowLeft className="w-4 h-4" />
                Pilih plan lain
              </button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
