import axios from "axios";
import { getSession, signOut } from "next-auth/react";

const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || "http://localhost:8080",
  headers: { "Content-Type": "application/json" },
  timeout: 15000,
});

// ── In-memory token store ──────────────────────────────────────
// We store the access token in memory to avoid calling getSession()
// on every API request. getSession() triggers a network call to
// /api/auth/session AND broadcasts to useSession(), which causes
// React re-renders and infinite loops.
let _accessToken: string | null = null;
let _sessionError: string | null = null;
let _tokenInitialized = false;
let _initPromise: Promise<void> | null = null;

/**
 * Called once from the SessionSync component after NextAuth session
 * is available. This avoids calling getSession() entirely.
 */
export function setAccessToken(token: string | null, error?: string | null) {
  _accessToken = token;
  _sessionError = error ?? null;
  _tokenInitialized = true;
}

/**
 * Fallback: fetch session ONCE if no SessionSync component has
 * provided the token yet. This should rarely happen.
 */
async function ensureToken() {
  if (_tokenInitialized) return;
  if (_initPromise) {
    await _initPromise;
    return;
  }
  _initPromise = getSession()
    .then((s) => {
      _accessToken = (s as any)?.accessToken ?? null;
      _sessionError = (s as any)?.error ?? null;
      _tokenInitialized = true;
    })
    .catch(() => {
      _tokenInitialized = true;
    })
    .finally(() => {
      _initPromise = null;
    });
  await _initPromise;
}

// Attach JWT to every request — NO getSession() call
api.interceptors.request.use(async (config) => {
  if (typeof window !== "undefined") {
    await ensureToken();

    // If refresh token has expired, sign out immediately
    if (_sessionError === "RefreshTokenExpired") {
      signOut({ callbackUrl: "/login" });
      return Promise.reject(
        new Error("Sesi telah berakhir. Silakan login kembali.")
      );
    }

    if (_accessToken) {
      config.headers.Authorization = `Bearer ${_accessToken}`;
    }
  }
  return config;
});

// Handle responses — auto sign-out on 401
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const status = error.response?.status;

    // 401 = token invalid/expired, try to refresh via getSession() ONCE
    if (status === 401 && typeof window !== "undefined") {
      try {
        const session = await getSession();
        const newToken = (session as any)?.accessToken;
        const newError = (session as any)?.error;

        if (newError === "RefreshTokenExpired" || !newToken) {
          _accessToken = null;
          _sessionError = "RefreshTokenExpired";
          signOut({ callbackUrl: "/login" });
          return Promise.reject(
            new Error("Sesi telah berakhir. Silakan login kembali.")
          );
        }

        // Store refreshed token
        _accessToken = newToken;
        _sessionError = null;
      } catch {
        // Refresh failed — sign out
        signOut({ callbackUrl: "/login" });
        return Promise.reject(
          new Error("Sesi telah berakhir. Silakan login kembali.")
        );
      }
    }

    const msg =
      error.response?.data?.message ||
      error.response?.data?.errors?.[0] ||
      error.message ||
      "Terjadi kesalahan";
    return Promise.reject(new Error(msg));
  }
);

export default api;

// ── Typed helpers ──────────────────────────────────────────────

export interface ApiEnvelope<T = unknown> {
  success: boolean;
  data?: T;
  message?: string;
  errors?: string[];
  meta?: { page: number; limit: number; total: number; total_pages: number };
}

export async function apiGet<T>(url: string, params?: Record<string, unknown>) {
  const res = await api.get<ApiEnvelope<T>>(url, { params });
  return res.data;
}

export async function apiPost<T>(url: string, body?: unknown) {
  const res = await api.post<ApiEnvelope<T>>(url, body);
  return res.data;
}

export async function apiPut<T>(url: string, body?: unknown) {
  const res = await api.put<ApiEnvelope<T>>(url, body);
  return res.data;
}

export async function apiPatch<T>(url: string, body?: unknown) {
  const res = await api.patch<ApiEnvelope<T>>(url, body);
  return res.data;
}

export async function apiDelete<T>(url: string) {
  const res = await api.delete<ApiEnvelope<T>>(url);
  return res.data;
}
