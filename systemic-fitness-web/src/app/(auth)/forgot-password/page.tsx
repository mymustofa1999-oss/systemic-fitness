"use client";

import { useState } from "react";
import { Activity, ArrowLeft, Loader2, Mail } from "lucide-react";
import Link from "next/link";

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const [sent, setSent] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    // Hit API (always returns success)
    await new Promise((r) => setTimeout(r, 1500));
    setSent(true);
    setLoading(false);
  }

  return (
    <div className="min-h-screen flex items-center justify-center relative overflow-hidden">
      <div className="absolute inset-0 bg-gradient-to-br from-brand-950 via-brand-900 to-brand-800" />

      <div className="relative w-full max-w-md mx-4">
        <div className="bg-white/[0.08] backdrop-blur-xl rounded-2xl border border-white/10 p-8 shadow-2xl">
          <div className="flex items-center justify-center gap-3 mb-8">
            <div className="p-2.5 bg-sf-deepNavy rounded-xl">
              <Activity className="h-6 w-6 text-white" />
            </div>
          </div>

          {sent ? (
            <div className="text-center">
              <div className="mx-auto w-14 h-14 rounded-2xl bg-emerald-500/10 flex items-center justify-center mb-4">
                <Mail className="h-7 w-7 text-emerald-400" />
              </div>
              <h2 className="text-xl font-heading font-bold text-white mb-2">Check your email</h2>
              <p className="text-sm text-sf-iceBlue mb-6">
                If an account exists for {email}, you&apos;ll receive a password reset link.
              </p>
              <Link href="/login" className="text-sm text-sf-systemBlue/40 hover:text-white transition-colors">
                Back to sign in
              </Link>
            </div>
          ) : (
            <>
              <div className="text-center mb-6">
                <h2 className="text-xl font-heading font-bold text-white">Reset password</h2>
                <p className="text-sm text-sf-iceBlue mt-1">Enter your email to receive a reset link</p>
              </div>

              <form onSubmit={handleSubmit} className="space-y-5">
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="Enter your email"
                  required
                  className="w-full px-4 py-3 rounded-xl bg-white/5 border border-white/10 text-white
                             placeholder:text-sf-systemBlue/40/50 text-sm
                             focus:outline-none focus:ring-2 focus:ring-sf-warmGold/30 transition-colors"
                />
                <button
                  type="submit"
                  disabled={loading}
                  className="w-full py-3 rounded-xl bg-sf-deepNavy hover:bg-sf-systemBlue text-white font-semibold
                             text-sm transition-colors disabled:opacity-50 flex items-center justify-center gap-2"
                >
                  {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : null}
                  {loading ? "Sending..." : "Send reset link"}
                </button>
              </form>

              <div className="mt-4 text-center">
                <Link
                  href="/login"
                  className="inline-flex items-center gap-1 text-sm text-sf-systemBlue/40 hover:text-white transition-colors"
                >
                  <ArrowLeft className="h-3.5 w-3.5" /> Back to sign in
                </Link>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
