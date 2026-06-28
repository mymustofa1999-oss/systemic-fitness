import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPatch, apiPost } from "@/lib/api";
import { toast } from "@/stores/toastStore";

// SF Phase 6 — Tier 4 Waitlist + Lab Consultation hooks.

// ─── Tier 4 Waitlist ────────────────────────────────────────────────

export type WaitlistStatus = "new" | "contacted" | "converted" | "closed";
export type WaitlistSource = "tier4" | "level_0_3" | "other";

export interface Tier4WaitlistEntry {
  id: string;
  user_id?: string | null;
  full_name: string;
  email: string;
  phone?: string | null;
  city?: string | null;
  source: WaitlistSource;
  assessment_id?: string | null;
  note?: string | null;
  status: WaitlistStatus;
  admin_note?: string | null;
  contacted_at?: string | null;
  created_at: string;
  updated_at: string;
}

export function useTier4Waitlist(params: { status?: string; source?: string } = {}) {
  return useQuery({
    queryKey: ["tier4-waitlist", params],
    queryFn: () =>
      apiGet<Tier4WaitlistEntry[]>("/api/v2/tier4-waitlist", {
        ...(params.status ? { status: params.status } : {}),
        ...(params.source ? { source: params.source } : {}),
      }),
  });
}

export function useUpdateTier4WaitlistStatus() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({
      id, status, admin_note,
    }: { id: string; status: WaitlistStatus; admin_note?: string }) =>
      apiPatch(`/api/v2/tier4-waitlist/${id}/status`, {
        status,
        ...(admin_note ? { admin_note } : {}),
      }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["tier4-waitlist"] });
      toast.success("Status diperbarui");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ─── Lab Consultation ───────────────────────────────────────────────

export type LabStatus = "pending" | "scheduled" | "completed" | "cancelled" | "no_show";

export interface LabConsultation {
  id: string;
  user_id: string;
  consultant_id?: string | null;
  assessment_id?: string | null;
  payment_id?: string | null;
  status: LabStatus;
  fee_amount: number;
  booking_note?: string | null;
  preferred_at?: string | null;
  scheduled_at?: string | null;
  completed_at?: string | null;
  result_summary?: string | null;
  result_payload: Record<string, unknown>;
  user_name?: string | null;
  user_email?: string | null;
  consultant_name?: string | null;
  created_at: string;
  updated_at: string;
}

export function useLabConsultations(params: { status?: string; user_id?: string } = {}) {
  return useQuery({
    queryKey: ["lab-consultations", params],
    queryFn: () =>
      apiGet<LabConsultation[]>("/api/v2/lab-consultations", {
        ...(params.status ? { status: params.status } : {}),
        ...(params.user_id ? { user_id: params.user_id } : {}),
      }),
  });
}

export function useUpdateLabConsultation() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({
      id, ...data
    }: { id: string; status: LabStatus } & Record<string, unknown>) =>
      apiPatch(`/api/v2/lab-consultations/${id}`, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["lab-consultations"] });
      toast.success("Lab Consultation diperbarui");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useBookLabConsultation() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: { assessment_id?: string; booking_note?: string; preferred_at?: string }) =>
      apiPost("/api/v2/lab-consultations", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["lab-consultations"] });
      toast.success("Lab Consultation dipesan");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}
