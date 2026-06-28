"use client";

import { useState } from "react";
import { signIn } from "next-auth/react";
import { useRouter } from "next/navigation";
import { Eye, EyeOff, Loader2 } from "lucide-react";

const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8080";

export default function RegisterPage() {
  const router = useRouter();
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    if (password.length < 8) {
      setError("Password minimal 8 karakter.");
      return;
    }

    setIsLoading(true);

    try {
      // 1. Register the account (role defaults to "client" on the API)
      const res = await fetch(`${API_BASE}/api/auth/register`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          full_name: fullName,
          email,
          password,
          phone: phone || undefined,
        }),
      });

      if (!res.ok) {
        if (res.status === 409) {
          setError("Email ini sudah terdaftar. Silakan login.");
        } else {
          const data = await res.json().catch(() => null);
          setError(data?.message || "Gagal membuat akun. Periksa data Anda dan coba lagi.");
        }
        setIsLoading(false);
        return;
      }

      // 2. Auto sign-in via NextAuth credentials (same flow as login)
      const signInRes = await signIn("credentials", {
        email,
        password,
        redirect: false,
      });

      if (signInRes?.error) {
        // Account created but auto-login failed — fall back to the login page
        router.push("/login");
        return;
      }

      router.push("/dashboard");
      router.refresh();
    } catch {
      setError("Terjadi kesalahan. Silakan coba lagi.");
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-sf-warmWhite flex flex-col px-6 py-8">
      {/* Back button area — matches mobile / login layout */}
      <div className="h-10" />

      {/* Content area centered */}
      <div className="flex-1 flex flex-col max-w-sm mx-auto w-full">
        {/* Title */}
        <h1 className="text-3xl font-bold text-sf-charcoal">Create Account</h1>
        <p className="text-sm text-gray-500 mt-2 mb-6">
          Buat akun untuk memulai perjalanan fitness Anda.
        </p>

        <form onSubmit={handleSubmit} className="space-y-4 flex-1 flex flex-col">
          {/* Full Name */}
          <div>
            <input
              id="register-name"
              type="text"
              value={fullName}
              onChange={(e) => setFullName(e.target.value)}
              placeholder="Nama Lengkap"
              required
              className="input"
            />
          </div>

          {/* Email */}
          <div>
            <input
              id="register-email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="Email"
              required
              className="input"
            />
          </div>

          {/* Phone (optional) */}
          <div>
            <input
              id="register-phone"
              type="tel"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              placeholder="Nomor HP (opsional)"
              className="input"
            />
          </div>

          {/* Password */}
          <div className="relative">
            <input
              id="register-password"
              type={showPassword ? "text" : "password"}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Password (min. 8 karakter)"
              required
              minLength={8}
              className="input pr-11"
            />
            <button
              type="button"
              onClick={() => setShowPassword(!showPassword)}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors"
            >
              {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
            </button>
          </div>

          {/* Error message */}
          {error && (
            <div className="bg-rose-50 border border-rose-200 rounded-xl px-4 py-3 animate-fade-in">
              <p className="text-rose-600 text-xs">{error}</p>
            </div>
          )}

          {/* Spacer */}
          <div className="flex-1 min-h-4" />

          {/* Submit Button */}
          {isLoading ? (
            <div className="flex justify-center py-4">
              <Loader2 size={28} className="animate-spin text-sf-warmGold" />
            </div>
          ) : (
            <button type="submit" className="w-full sf-cta-primary py-4 text-base rounded-2xl">
              Create Account
            </button>
          )}

          {/* Separator */}
          <p className="text-center text-sm font-semibold text-sf-charcoal">OR</p>

          {/* Back to Login */}
          <button
            type="button"
            className="w-full sf-cta-primary py-4 text-base rounded-2xl"
            onClick={() => router.push("/login")}
          >
            Back to Login
          </button>
        </form>

        {/* Footer */}
        <p className="text-center text-[10px] text-gray-300 mt-6 mb-4">
          © {new Date().getFullYear()} Systemic Fitness Health
        </p>
      </div>
    </div>
  );
}
