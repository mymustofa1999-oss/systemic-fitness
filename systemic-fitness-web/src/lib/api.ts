import axios from "axios";
import { getSession, signOut } from "next-auth/react";

const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || "/backend-api",
  headers: { "Content-Type": "application/json" },
  timeout: 15000,
});

// Attach JWT to every request
api.interceptors.request.use(async (config) => {
  if (typeof window !== "undefined") {
    const session = await getSession();

    // If refresh token has expired, sign out immediately
    if ((session as any)?.error === "RefreshTokenExpired") {
      signOut({ callbackUrl: "/login" });
      return Promise.reject(new Error("Session expired. Please sign in again."));
    }

    if (session?.accessToken) {
      config.headers.Authorization = `Bearer ${session.accessToken}`;
    }
  }
  return config;
});

// Handle responses — auto sign-out on 401
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const status = error.response?.status;

    // 401 = token invalid/expired, and refresh already failed
    if (status === 401 && typeof window !== "undefined") {
      // Force session update to trigger JWT callback refresh
      const session = await getSession();
      if ((session as any)?.error === "RefreshTokenExpired" || !session?.accessToken) {
        signOut({ callbackUrl: "/login" });
        return Promise.reject(new Error("Session expired. Please sign in again."));
      }
    }

    const msg =
      error.response?.data?.message ||
      error.response?.data?.errors?.[0] ||
      error.message ||
      "Something went wrong";
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
