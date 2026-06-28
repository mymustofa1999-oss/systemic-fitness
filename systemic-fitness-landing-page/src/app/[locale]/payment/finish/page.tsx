"use client";

import { useSearchParams } from "next/navigation";
import { Check, Clock, XCircle, ArrowRight, Download } from "lucide-react";
import { motion } from "framer-motion";
import { Suspense } from "react";

function PaymentFinishContent() {
  const searchParams = useSearchParams();
  const transactionStatus = searchParams.get("transaction_status") ?? "pending";
  const orderId = searchParams.get("order_id") ?? "";
  const statusCode = searchParams.get("status_code") ?? "";

  const isSuccess =
    transactionStatus === "settlement" || transactionStatus === "capture";
  const isPending = transactionStatus === "pending";

  let icon: React.ReactNode;
  let bgGradient: string;
  let title: string;
  let subtitle: string;
  let statusColor: string;
  let statusBadge: string;

  if (isSuccess) {
    icon = <Check className="w-12 h-12 text-white" strokeWidth={2.5} />;
    bgGradient = "from-emerald-500 to-teal-600";
    title = "Pembayaran Berhasil!";
    subtitle =
      "Selamat! Langganan Systemic Fitness kamu sudah aktif. Buka aplikasi untuk mulai program latihan personalmu.";
    statusColor = "text-emerald-600 dark:text-emerald-400";
    statusBadge = "bg-emerald-50 dark:bg-emerald-500/10 border-emerald-200 dark:border-emerald-500/20";
  } else if (isPending) {
    icon = <Clock className="w-12 h-12 text-white" strokeWidth={2} />;
    bgGradient = "from-amber-500 to-orange-500";
    title = "Menunggu Pembayaran";
    subtitle =
      "Silakan selesaikan pembayaran sesuai instruksi. Status akan diperbarui otomatis setelah kami menerima pembayaranmu.";
    statusColor = "text-amber-600 dark:text-amber-400";
    statusBadge = "bg-amber-50 dark:bg-amber-500/10 border-amber-200 dark:border-amber-500/20";
  } else {
    icon = <XCircle className="w-12 h-12 text-white" strokeWidth={2} />;
    bgGradient = "from-red-500 to-rose-600";
    title = "Pembayaran Gagal";
    subtitle =
      "Maaf, pembayaran tidak berhasil diproses. Silakan coba lagi melalui aplikasi atau hubungi tim kami.";
    statusColor = "text-red-600 dark:text-red-400";
    statusBadge = "bg-red-50 dark:bg-red-500/10 border-red-200 dark:border-red-500/20";
  }

  return (
    <main className="bg-warm-white dark:bg-navy min-h-screen flex items-center justify-center px-[5%] py-16 transition-colors">
      <motion.div
        initial={{ opacity: 0, y: 24 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, ease: "easeOut" }}
        className="max-w-lg w-full"
      >
        {/* Icon */}
        <div className="flex justify-center mb-8">
          <div
            className={`w-24 h-24 rounded-full bg-gradient-to-br ${bgGradient} flex items-center justify-center shadow-lg`}
          >
            {icon}
          </div>
        </div>

        {/* Card */}
        <div className="bg-white dark:bg-white/5 border border-[rgba(10,22,40,0.12)] dark:border-white/10 rounded-3xl p-8 md:p-10 text-center shadow-sm">
          <h1
            className={`font-display text-3xl md:text-4xl mb-4 ${statusColor}`}
          >
            {title}
          </h1>

          <p className="text-brand-gray dark:text-white/60 leading-relaxed mb-6 text-[15px]">
            {subtitle}
          </p>

          {/* Order details */}
          {orderId && (
            <div
              className={`inline-flex items-center gap-2 border rounded-full px-4 py-2 mb-8 ${statusBadge}`}
            >
              <span
                className={`text-xs font-medium ${statusColor} tracking-wide`}
              >
                Order ID: {orderId}
              </span>
            </div>
          )}

          {/* CTA Buttons */}
          <div className="space-y-3">
            {/* Download App */}
            <a
              href="#download"
              className="flex items-center justify-center gap-2 w-full py-3.5 rounded-xl bg-navy dark:bg-brand-gold text-white text-[15px] font-medium no-underline transition-all hover:opacity-90"
            >
              <Download className="w-4 h-4" />
              Buka Aplikasi Systemic Fitness
            </a>

            {/* Back to home */}
            <a
              href="/"
              className="flex items-center justify-center gap-2 w-full py-3.5 rounded-xl border border-[rgba(10,22,40,0.12)] dark:border-white/15 text-navy dark:text-white text-[15px] font-medium no-underline transition-all hover:bg-warm-white dark:hover:bg-white/5"
            >
              Kembali ke Beranda
              <ArrowRight className="w-4 h-4" />
            </a>
          </div>
        </div>

        {/* Footer note */}
        <p className="text-center text-xs text-brand-gray/60 dark:text-white/30 mt-6">
          Status pembayaran dapat membutuhkan waktu beberapa menit untuk
          diperbarui. Jika ada pertanyaan, hubungi kami di{" "}
          <a
            href="mailto:support@systemicfitnesshealth.com"
            className="underline"
          >
            support@systemicfitnesshealth.com
          </a>
        </p>
      </motion.div>
    </main>
  );
}

export default function PaymentFinishPage() {
  return (
    <Suspense
      fallback={
        <main className="bg-warm-white dark:bg-navy min-h-screen flex items-center justify-center">
          <div className="animate-pulse text-brand-gray dark:text-white/60">
            Memuat status pembayaran...
          </div>
        </main>
      }
    >
      <PaymentFinishContent />
    </Suspense>
  );
}
