import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPatch, ApiEnvelope } from "@/lib/api";
import { toast } from "@/stores/toastStore";

// ─── Types ─────────────────────────────────────────────────────

export type AssessmentTier = "free" | "paid";
export type AssessmentStatus = "submitted" | "verified" | "revised";

export type AssessmentClassification =
  | "optimal" | "compromised" | "critical"
  | "stable" | "compensation" | "dysfunction"
  | "efficient" | "at_risk" | "dysregulated";

export interface SleepInput {
  duration_hours: number;
  consistency: number;
  latency_minutes: number;
  morning_readiness: number;
  wake_frequency: number;
  pre_sleep_habit: number;
}

export interface MovementInput {
  squat: number;
  hip_hinge: number;
  overhead: number;
}

export interface MetabolicInput {
  hba1c: number;
  ldl: number;
  triglyceride: number;
  medications?: string[];
}

export interface AssessmentScores {
  sleep_score: number;
  recovery_score: number;
  movement_score: number;
  metabolic_score?: number;
  system_score: number;
}

export interface Assessment {
  id: string;
  user_id?: string | null;
  user_name?: string | null;
  tier: AssessmentTier;
  status: AssessmentStatus;
  sleep: SleepInput;
  movement: MovementInput;
  metabolic?: MetabolicInput;
  scores: AssessmentScores;
  sleep_class: AssessmentClassification;
  movement_class: AssessmentClassification;
  metabolic_class?: AssessmentClassification;
  flags: string[];
  insight: string;
  recommendations: string[];
  reviewed_by?: string | null;
  reviewed_at?: string | null;
  reviewer_notes?: string | null;
  created_at: string;
  updated_at: string;
}

export interface ReviewPayload {
  status: "verified" | "revised";
  reviewer_notes?: string;
  metabolic?: MetabolicInput;
}

// ─── Queries ───────────────────────────────────────────────────

/**
 * Pending review queue — paid assessments still in `submitted` status.
 * Trainer/admin only.
 */
export function usePendingReviewAssessments(params: { page?: number; limit?: number } = {}) {
  return useQuery({
    queryKey: ["assessments", "pending-review", params],
    queryFn: () => apiGet<Assessment[]>("/api/assessments/pending-review", params),
  });
}

/**
 * Admin/owner-only: every assessment in the system, with optional
 * tier + status + user_id filters. Used for the "All" / "Reviewed"
 * tabs on /assessments page.
 */
export function useAllAssessments(params: {
  page?: number;
  limit?: number;
  tier?: AssessmentTier;
  status?: AssessmentStatus;
  user_id?: string;
} = {}) {
  return useQuery({
    queryKey: ["assessments", "all", params],
    queryFn: () => apiGet<Assessment[]>("/api/assessments/all", params),
  });
}

/**
 * Get a single assessment by id.
 */
export function useAssessment(id: string | undefined) {
  return useQuery({
    queryKey: ["assessments", id],
    queryFn: () => apiGet<Assessment>(`/api/assessments/${id}`),
    enabled: !!id,
  });
}

/**
 * Per-user history. Trainer/admin only.
 */
export function useUserAssessments(
  userId: string | undefined,
  params: { page?: number; limit?: number } = {},
) {
  return useQuery({
    queryKey: ["assessments", "by-user", userId, params],
    queryFn: () => apiGet<Assessment[]>(`/api/users/${userId}/assessments`, params),
    enabled: !!userId,
  });
}

// ─── Schema (composition) ──────────────────────────────────────

export interface SchemaOption {
  label: string;
  value: number | string;
  points?: string;
}

export interface SchemaQuestion {
  key: string;
  title: string;
  subtitle?: string;
  input_type: "number" | "options";
  unit?: string;
  options?: SchemaOption[];
  points_rule?: string;
}

export interface SchemaSection {
  key: string;
  title: string;
  icon: string;
  description: string;
  max_score: string;
  formula: string;
  questions: SchemaQuestion[];
}

export interface SchemaPhysicalGroup {
  title: string;
  items: string[];
}

export interface SchemaFlag {
  key: string;
  label: string;
  color: string;
  rule: string;
}

export interface SchemaBand {
  label: string;
  range: string;
  color: string;
}

export interface SchemaClassification {
  score: string;
  bands: SchemaBand[];
}

export interface SchemaTier {
  system_score_formula: string;
  sections: SchemaSection[];
}

export interface AssessmentSchema {
  version: string;
  free: SchemaTier;
  paid: SchemaTier;
  physical_groups: SchemaPhysicalGroup[];
  flags: SchemaFlag[];
  classifications: SchemaClassification[];
}

/**
 * Fetches the composition/schema of free + paid assessment from the API.
 * Source of truth: systemic-fitness-api/internal/handler/assessment_schema.go
 */
export function useAssessmentSchema() {
  return useQuery({
    queryKey: ["assessments", "schema"],
    queryFn: () => apiGet<AssessmentSchema>("/api/assessments/schema"),
    staleTime: 5 * 60 * 1000,
  });
}

// ─── Mutations ─────────────────────────────────────────────────

/**
 * Apply trainer review to a paid assessment. If `metabolic` is given,
 * the backend re-computes scores using its single-source-of-truth engine.
 */
export function useReviewAssessment() {
  const qc = useQueryClient();
  return useMutation<
    ApiEnvelope<Assessment>,
    Error,
    { id: string; payload: ReviewPayload }
  >({
    mutationFn: ({ id, payload }) =>
      apiPatch<Assessment>(`/api/assessments/${id}/review`, payload),
    onSuccess: (_data, { id }) => {
      qc.invalidateQueries({ queryKey: ["assessments", id] });
      qc.invalidateQueries({ queryKey: ["assessments", "pending-review"] });
      qc.invalidateQueries({ queryKey: ["assessments", "by-user"] });
      toast.success("Review berhasil disimpan");
    },
    onError: (err) => toast.error(err.message),
  });
}
