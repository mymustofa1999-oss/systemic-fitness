import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPost, apiPut, apiDelete } from "@/lib/api";
import { toast } from "@/stores/toastStore";

// SF Master — Condition Classifications & Specific Conditions (Phase 1).
// Backed by /api/master/* endpoints (see systemic-fitness-api Phase 1 docs).

// ─── Types ──────────────────────────────────────────────────────────────

export type FocusPillar = "FC" | "CC" | "MC";

export interface ConditionClassification {
  id: string;
  slug: string;
  label: string;
  description?: string | null;
  focus_pillar: FocusPillar;
  full_program_formula: Record<string, number>;
  daily_reset_formula: Record<string, number>;
  sort_order: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface SpecificCondition {
  id: string;
  classification_id: string;
  classification_slug?: string;
  slug: string;
  label: string;
  description?: string | null;
  severity_default?: "mild" | "moderate" | "severe" | "monitor" | null;
  notes: Record<string, unknown>;
  sort_order: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface PhysicalStatusLevel {
  id: string;
  slug: string;
  label: string;
  description?: string | null;
  routing: "waitlist" | "preventive_movement_test" | "continue";
  waitlist_message?: string | null;
  sort_order: number;
  is_active: boolean;
}

// ─── Condition Classifications ──────────────────────────────────────────

export function useConditionClassifications(includeInactive = false) {
  return useQuery({
    queryKey: ["condition-classifications", { includeInactive }],
    queryFn: () =>
      apiGet<ConditionClassification[]>(
        "/api/master/condition-classifications",
        includeInactive ? { include_inactive: "true" } : undefined,
      ),
  });
}

export function useConditionClassification(id: string | undefined) {
  return useQuery({
    queryKey: ["condition-classifications", id],
    queryFn: () =>
      apiGet<ConditionClassification>(`/api/master/condition-classifications/${id}`),
    enabled: !!id,
  });
}

export function useCreateConditionClassification() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Partial<ConditionClassification>) =>
      apiPost<ConditionClassification>("/api/master/condition-classifications", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["condition-classifications"] });
      toast.success("Klasifikasi kondisi dibuat");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useUpdateConditionClassification() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: { id: string } & Partial<ConditionClassification>) =>
      apiPut<ConditionClassification>(`/api/master/condition-classifications/${id}`, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["condition-classifications"] });
      toast.success("Klasifikasi kondisi diperbarui");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDeleteConditionClassification() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => apiDelete(`/api/master/condition-classifications/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["condition-classifications"] });
      toast.success("Klasifikasi kondisi dihapus");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ─── Specific Conditions ───────────────────────────────────────────────

export function useSpecificConditions(params: {
  classification?: string;
  includeInactive?: boolean;
} = {}) {
  return useQuery({
    queryKey: ["specific-conditions", params],
    queryFn: () =>
      apiGet<SpecificCondition[]>("/api/master/specific-conditions", {
        ...(params.classification ? { classification: params.classification } : {}),
        ...(params.includeInactive ? { include_inactive: "true" } : {}),
      }),
  });
}

export function useSpecificCondition(id: string | undefined) {
  return useQuery({
    queryKey: ["specific-conditions", id],
    queryFn: () => apiGet<SpecificCondition>(`/api/master/specific-conditions/${id}`),
    enabled: !!id,
  });
}

export function useCreateSpecificCondition() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Partial<SpecificCondition>) =>
      apiPost<SpecificCondition>("/api/master/specific-conditions", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["specific-conditions"] });
      toast.success("Kondisi spesifik dibuat");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useUpdateSpecificCondition() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: { id: string } & Partial<SpecificCondition>) =>
      apiPut<SpecificCondition>(`/api/master/specific-conditions/${id}`, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["specific-conditions"] });
      toast.success("Kondisi spesifik diperbarui");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDeleteSpecificCondition() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => apiDelete(`/api/master/specific-conditions/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["specific-conditions"] });
      toast.success("Kondisi spesifik dihapus");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ─── Physical Status Levels (read-only) ────────────────────────────────

export function usePhysicalStatusLevels() {
  return useQuery({
    queryKey: ["physical-status-levels"],
    queryFn: () => apiGet<PhysicalStatusLevel[]>("/api/master/physical-status-levels"),
  });
}
