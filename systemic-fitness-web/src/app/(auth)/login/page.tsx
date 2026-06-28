"use client";

import { signIn } from "next-auth/react";
import { useRouter, useSearchParams } from "next/navigation";
import { Suspense, useState } from "react";
import { Eye, EyeOff, Loader2 } from "lucide-react";
import Image from "next/image";
import Link from "next/link";

export default function LoginPage() {
  return (
    <Suspense>
      <LoginForm />
    </Suspense>
  );
}

function LoginForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const error = searchParams.get("error");

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPw, setShowPw] = useState(false);
  const [loading, setLoading] = useState(false);
  const [loginError, setLoginError] = useState(error ? "Invalid email or password" : "");

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setLoginError("");

    const res = await signIn("credentials", {
      email,
      password,
      redirect: false,
    });

    if (res?.error) {
      setLoginError("Invalid email or password");
      setLoading(false);
    } else {
      router.push("/");
      router.refresh();
      // Reset loading after a short delay in case redirect doesn't happen immediately
      setTimeout(() => setLoading(false), 5000);
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center relative overflow-hidden">
      {/* Gradient background */}
      <div className="absolute inset-0 bg-gradient-to-br from-brand-950 via-brand-900 to-brand-800" />
      <div className="absolute inset-0 bg-[url('data:image/svg+xml,%3Csvg%20width%3D%2260%22%20height%3D%2260%22%20viewBox%3D%220%200%2060%2060%22%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%3E%3Cg%20fill%3D%22none%22%20fill-rule%3D%22evenodd%22%3E%3Cg%20fill%3D%22%23ffffff%22%20fill-opacity%3D%220.03%22%3E%3Ccircle%20cx%3D%2230%22%20cy%3D%2230%22%20r%3D%221.5%22%2F%3E%3C%2Fg%3E%3C%2Fg%3E%3C%2Fsvg%3E')] " />

      {/* Glow effects */}
      <div className="absolute top-1/4 -left-32 w-96 h-96 bg-sf-deepNavy/20 rounded-full blur-3xl" />
      <div className="absolute bottom-1/4 -right-32 w-96 h-96 bg-blue-500/15 rounded-full blur-3xl" />

      {/* Card */}
      <div className="relative w-full max-w-md mx-4">
        <div className="bg-white/[0.08] backdrop-blur-xl rounded-2xl border border-white/10 p-8 shadow-2xl">
          {/* Logo */}
          <div className="flex flex-col items-center mb-8">
            <Image
              src="/logo.jpeg"
              alt="Systemic Fitness"
              width={88}
              height={88}
              className="rounded-2xl mb-4"
            />
            <h1 className="text-2xl font-heading font-bold text-white tracking-tight">
              Systemic Fitness
            </h1>
          </div>

          <div className="text-center mb-8">
            <h2 className="text-xl font-heading font-bold text-white">Welcome back</h2>
            <p className="text-sm text-sf-iceBlue mt-1">Sign in to your admin account</p>
          </div>

          {loginError && (
            <div className="mb-4 p-3 rounded-lg bg-rose-500/10 border border-rose-500/20 text-rose-300 text-sm text-center">
              {loginError}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-5">
            <div>
              <label className="block text-sm font-medium text-sf-iceBlue mb-1.5">Email</label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="admin@systemicfitness.app"
                required
                className="w-full px-4 py-3 rounded-xl bg-white/5 border border-white/10 text-white
                           placeholder:text-sf-systemBlue/40/50 text-sm
                           focus:outline-none focus:ring-2 focus:ring-sf-warmGold/30 focus:border-sf-systemBlue
                           transition-colors"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-sf-iceBlue mb-1.5">Password</label>
              <div className="relative">
                <input
                  type={showPw ? "text" : "password"}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Enter your password"
                  required
                  className="w-full px-4 py-3 pr-11 rounded-xl bg-white/5 border border-white/10 text-white
                             placeholder:text-sf-systemBlue/40/50 text-sm
                             focus:outline-none focus:ring-2 focus:ring-sf-warmGold/30 focus:border-sf-systemBlue
                             transition-colors"
                />
                <button
                  type="button"
                  onClick={() => setShowPw((v) => !v)}
                  aria-label={showPw ? "Hide password" : "Show password"}
                  className="absolute right-1 top-1/2 -translate-y-1/2 z-10 p-2 rounded-md
                             text-sf-systemBlue/40 hover:text-white focus:outline-none
                             focus:ring-2 focus:ring-sf-warmGold/30"
                >
                  {showPw ? (
                    <EyeOff className="h-4 w-4 pointer-events-none" />
                  ) : (
                    <Eye className="h-4 w-4 pointer-events-none" />
                  )}
                </button>
              </div>
            </div>

            <div className="flex items-center justify-between">
              <label className="flex items-center gap-2 text-sm text-sf-iceBlue cursor-pointer">
                <input type="checkbox" className="rounded border-white/20 bg-white/5 text-sf-deepNavy" />
                Remember me
              </label>
              <Link
                href="/forgot-password"
                className="text-sm text-sf-systemBlue/40 hover:text-white transition-colors"
              >
                Forgot password?
              </Link>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-3 rounded-xl bg-sf-deepNavy hover:bg-sf-systemBlue text-white font-semibold
                         text-sm transition-colors disabled:opacity-50 disabled:cursor-not-allowed
                         flex items-center justify-center gap-2"
            >
              {loading ? (
                <>
                  <Loader2 className="h-4 w-4 animate-spin" />
                  Signing in...
                </>
              ) : (
                "Sign in"
              )}
            </button>
          </form>
        </div>

        <p className="text-center text-xs text-sf-systemBlue mt-6">
          Systemic Fitness Platform &copy; {new Date().getFullYear()}. All rights reserved.
        </p>
      </div>
    </div>
  );
}
