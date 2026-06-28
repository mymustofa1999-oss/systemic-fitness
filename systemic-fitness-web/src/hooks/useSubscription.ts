import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPost } from "@/lib/api";
import { toast } from "@/stores/toastStore";

// ─── Client Subscription Plans ─────────────────────────────────

export function useSubscriptionPlans() {
  return useQuery({
    queryKey: ["subscription-plans"],
    queryFn: () => apiGet("/api/subscription/plans"),
  });
}

export function useSubscriptionPlan(id: string) {
  return useQuery({
    queryKey: ["subscription-plans", id],
    queryFn: () => apiGet(`/api/subscription/plans/${id}`),
    enabled: !!id,
  });
}

// ─── My Subscription ──────────────────────────────────────────

export function useMySubscription() {
  return useQuery({
    queryKey: ["my-subscription"],
    queryFn: () => apiGet("/api/subscription/me"),
  });
}

// ─── Subscribe ────────────────────────────────────────────────

export function useSubscribe() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: { plan_id: string; payment_method: string }) =>
      apiPost("/api/subscription/subscribe", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["my-subscription"] });
      qc.invalidateQueries({ queryKey: ["subscription-history"] });
      qc.invalidateQueries({ queryKey: ["subscription-payments"] });
      toast.success("Berhasil berlangganan");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ─── Cancel ───────────────────────────────────────────────────

export function useCancelSubscription() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (subscriptionId: string) =>
      apiPost(`/api/subscription/${subscriptionId}/cancel`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["my-subscription"] });
      qc.invalidateQueries({ queryKey: ["subscription-history"] });
      toast.success("Langganan berhasil dibatalkan");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ─── History ──────────────────────────────────────────────────

export function useSubscriptionHistory(params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["subscription-history", params],
    queryFn: () => apiGet("/api/subscription/history", params),
  });
}

// ─── My Payments ──────────────────────────────────────────────

export function useSubscriptionPayments(params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["subscription-payments", params],
    queryFn: () => apiGet("/api/subscription/payments", params),
  });
}

// ─── Create Manual Subscription (Admin/Owner) ──────────────────

export function useCreateManualSubscription() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: { user_id: string; plan_id: string }) =>
      apiPost("/api/payments/subscriptions", data),
    onSuccess: (_, vars) => {
      qc.invalidateQueries({ queryKey: ["client-subscriptions", vars.user_id] });
      qc.invalidateQueries({ queryKey: ["client-payments", vars.user_id] });
      qc.invalidateQueries({ queryKey: ["admin-subscriptions"] });
      qc.invalidateQueries({ queryKey: ["admin-payments"] });
      qc.invalidateQueries({ queryKey: ["user", vars.user_id] });
      toast.success("Langganan berhasil ditambahkan secara manual");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

