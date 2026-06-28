import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPost } from "@/lib/api";
import { toast } from "@/stores/toastStore";

export interface Subscription {
  id: string;
  plan_id: string;
  plan_name: string;
  tier: string;
  billing_period: string;
  status: string;
  started_at: string;
  expires_at: string;
  cancelled_at?: string;
  payment_method?: string;
  created_at: string;
}

export interface MySubscriptionResult {
  has_subscription: boolean;
  subscription?: Subscription;
  days_remaining?: number;
}

export interface ClientPlan {
  id: string;
  name: string;
  description: string;
  tier: string;
  billing_period: string;
  price: number;
  original_price?: number;
  discount_pct?: number;
  features: string[];
  is_popular: boolean;
  sort_order: number;
}

export interface PlanGroup {
  tier: string;
  monthly: ClientPlan;
  annual?: ClientPlan;
  quarterly?: ClientPlan; // Maps to our 3-month plans
}

export interface SubscribeInput {
  plan_id: string;
  payment_method: string;
  payment_type: "manual_transfer" | "midtrans_snap";
  customer_name?: string;
  customer_email?: string;
  customer_phone?: string;
}

export interface BankAccount {
  id: string;
  bank_name: string;
  account_number: string;
  account_holder: string;
  branch?: string;
  notes?: string;
}

export interface ClientPaymentRecord {
  id: string;
  subscription_id: string;
  amount: number;
  currency: string;
  status: "pending" | "completed" | "failed" | "refunded";
  payment_method: string;
  payment_type: "manual_transfer" | "midtrans_snap";
  bank_account_id?: string;
  proof_image_url?: string;
  proof_uploaded_at?: string;
  snap_token?: string;
  snap_redirect_url?: string;
  external_id?: string;
  created_at: string;
}

export interface SubscribeResult {
  subscription: Subscription;
  payment: ClientPaymentRecord;
  bank_account?: BankAccount;
  snap_token?: string;
  snap_redirect_url?: string;
}

export function useMySubscription() {
  const query = useQuery({
    queryKey: ["my-subscription"],
    queryFn: () => apiGet<MySubscriptionResult>("/api/subscription/me"),
    retry: 1,
    staleTime: 1000 * 60 * 5, // Cache for 5 minutes
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
  });

  const subResult = query.data?.data;
  
  // A client is considered on the Free tier if they have no subscription,
  // the subscription is pending/inactive, or their tier is explicitly "sf_free" or "free".
  const isFree =
    !subResult ||
    !subResult.has_subscription ||
    !subResult.subscription ||
    subResult.subscription.status !== "active" ||
    subResult.subscription.tier === "sf_free" ||
    subResult.subscription.tier === "free";

  return {
    ...query,
    subscription: subResult?.subscription ?? null,
    isFree,
    isLoading: query.isLoading,
  };
}

export function useSubscriptionPlans() {
  return useQuery({
    queryKey: ["subscription-plans"],
    queryFn: async () => {
      const res = await apiGet<PlanGroup[]>("/api/subscription/plans");
      // Map quarterly plans to quarterly key for each group since the backend lists
      // annual or monthly, but our v2 migration uses quarterly for 3-month plans
      // which might be placed in "annual" or not by ListPlans. Let's make sure it handles quarterly:
      const groups = res.data || [];
      return groups.map((g: any) => {
        const mappedGroup: PlanGroup = {
          tier: g.tier,
          monthly: g.monthly,
        };
        // Backend returns billing_period "annual" or "quarterly".
        // Let's ensure quarterly/annual are populated.
        if (g.annual) {
          if (g.annual.billing_period === "quarterly") {
            mappedGroup.quarterly = g.annual;
          } else {
            mappedGroup.annual = g.annual;
          }
        }
        return mappedGroup;
      });
    },
  });
}

export function useSubscribe() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: SubscribeInput) =>
      apiPost<SubscribeResult>("/api/subscription/subscribe", data),
    onSuccess: (res) => {
      qc.invalidateQueries({ queryKey: ["my-subscription"] });
      qc.invalidateQueries({ queryKey: ["my-payments"] });
      if (res.message) {
        toast.success(res.message);
      } else {
        toast.success("Berhasil membuat pesanan langganan.");
      }
    },
    onError: (err: any) => {
      toast.error(err.message || "Gagal membuat pesanan langganan.");
    },
  });
}

export function useCancelSubscription() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (subscriptionId: string) =>
      apiPost<any>(`/api/subscription/${subscriptionId}/cancel`),
    onSuccess: (res) => {
      qc.invalidateQueries({ queryKey: ["my-subscription"] });
      qc.invalidateQueries({ queryKey: ["my-payments"] });
      toast.success(res.message || "Langganan berhasil dibatalkan.");
    },
    onError: (err: any) => {
      toast.error(err.message || "Gagal membatalkan langganan.");
    },
  });
}

export function useMyPayments(params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["my-payments", params],
    queryFn: () => apiGet<ClientPaymentRecord[]>("/api/subscription/payments", params),
  });
}

export function useBankAccounts() {
  return useQuery({
    queryKey: ["bank-accounts"],
    queryFn: () => apiGet<BankAccount[]>("/api/subscription/bank-accounts"),
  });
}

export function useUploadPaymentProof() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ paymentId, file }: { paymentId: string; file: File }) => {
      const formData = new FormData();
      formData.append("file", file);
      return apiPost<ClientPaymentRecord>(`/api/subscription/payments/${paymentId}/proof`, formData);
    },
    onSuccess: (res) => {
      qc.invalidateQueries({ queryKey: ["my-payments"] });
      qc.invalidateQueries({ queryKey: ["my-subscription"] });
      toast.success(res.message || "Bukti pembayaran berhasil diunggah.");
    },
    onError: (err: any) => {
      toast.error(err.message || "Gagal mengunggah bukti pembayaran.");
    },
  });
}


