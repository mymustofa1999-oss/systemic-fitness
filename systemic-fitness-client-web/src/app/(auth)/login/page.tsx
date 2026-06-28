"use client";

import { useState } from "react";
import { signIn } from "next-auth/react";
import { useRouter } from "next/navigation";
import { Eye, EyeOff, Loader2 } from "lucide-react";

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setIsLoading(true);

    try {
      const result = await signIn("credentials", {
        email,
        password,
        redirect: false,
      });

      if (result?.error) {
        setError("Email atau password salah. Pastikan akun Anda terdaftar sebagai client atau trainer.");
      } else {
        router.push("/dashboard");
        router.refresh();
      }
    } catch {
      setError("Terjadi kesalahan. Silakan coba lagi.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-sf-warmWhite flex flex-col px-6 py-8">
      {/* Back button area — matches mobile login_page.dart */}
      <div className="h-10" />

      {/* Content area centered */}
      <div className="flex-1 flex flex-col max-w-sm mx-auto w-full">
        {/* Title */}
        <h1 className="text-3xl font-bold text-sf-charcoal">Login</h1>
        <p className="text-sm text-gray-500 mt-2 mb-6">
          Welcome back! Sign in to continue your fitness journey.
        </p>

        <form onSubmit={handleSubmit} className="space-y-4 flex-1 flex flex-col">
          {/* Email */}
          <div>
            <input
              id="login-email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="Email"
              required
              className="input"
            />
          </div>

          {/* Password */}
          <div className="relative">
            <input
              id="login-password"
              type={showPassword ? "text" : "password"}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Password"
              required
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

          {/* Forgot Password */}
          <div className="text-right">
            <button type="button" className="text-sm font-semibold text-sf-charcoal hover:underline">
              Forgot Password?
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

          {/* Login Button */}
          {isLoading ? (
            <div className="flex justify-center py-4">
              <Loader2 size={28} className="animate-spin text-sf-warmGold" />
            </div>
          ) : (
            <button type="submit" className="w-full sf-cta-primary py-4 text-base rounded-2xl">
              Login
            </button>
          )}

          {/* Separator */}
          <p className="text-center text-sm font-semibold text-sf-charcoal">OR</p>

          {/* Create Account */}
          <button
            type="button"
            className="w-full sf-cta-primary py-4 text-base rounded-2xl"
            onClick={() => router.push("/register")}
          >
            Create New Account
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
