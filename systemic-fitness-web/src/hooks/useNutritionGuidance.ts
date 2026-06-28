import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { toast } from "@/stores/toastStore";

import { apiGet, apiPut, type ApiEnvelope } from "@/lib/api";

// ─── Types ─────────────────────────────────────────────────────

export type NutritionGender = "male" | "female";
export type NutritionAgeGroup = "under_18" | "18_40" | "41_60" | "over_60";
export type NutritionGoal = "maintenance" | "fat_loss" | "recovery";
export type FemaleCondition = "normal" | "pregnant" | "menopause";

export const HEALTH_CONDITIONS = [
  "hypertension",
  "diabetes",
  "kidney",
  "gout",
  "heart",
  "cancer",
  "autoimmune",
  "hormonal",
] as const;
export type HealthCondition = (typeof HEALTH_CONDITIONS)[number];

export const HEALTH_CONDITION_LABELS: Record<HealthCondition, string> = {
  hypertension: "Hipertensi",
  diabetes: "Diabetes",
  kidney: "Ginjal",
  gout: "Asam Urat",
  heart: "Jantung",
  cancer: "Kanker",
  autoimmune: "Autoimun",
  hormonal: "Hormonal",
};

export interface NutritionHealthProfile {
  user_id: string;
  gender: NutritionGender;
  age_group: NutritionAgeGroup;
  female_condition?: FemaleCondition | null;
  goal: NutritionGoal;
  weight_kg: number;
  allergies: string[];
  conditions: HealthCondition[];
  created_at?: string;
  updated_at?: string;
}

export interface UpsertHealthProfileInput {
  gender: NutritionGender;
  age_group: NutritionAgeGroup;
  female_condition?: FemaleCondition | "";
  goal: NutritionGoal;
  weight_kg: number;
  allergies: string[];
  conditions: HealthCondition[];
}

export interface DietPlan {
  allowed_foods: string[];
  limited_foods: string[];
  avoid_foods: string[];
}

export interface NutritionPlanResult {
  diet_plan: DietPlan;
  nutrition_rules: Record<string, unknown>;
  daily_score: number;
  status: "stable" | "warning" | "risk";
  insight: string[];
}

export interface NutritionDailyLogResult {
  log_date: string;
  daily_score: number;
  status: "stable" | "warning" | "risk";
  alert?: { alert: boolean; message: string } | null;
}

// ─── Queries ────────────────────────────────────────────────────

export function useCustomerHealthProfile(userId: string | undefined) {
  return useQuery({
    queryKey: ["nutrition-guidance", "profile", userId],
    queryFn: () =>
      apiGet<NutritionHealthProfile>(
        `/api/admin/nutrition-guidance/users/${userId}/profile`,
      ),
    enabled: !!userId,
    retry: (count, err) => {
      // Don't retry on 404 (profile not yet created)
      if (/not\s*set|not found/i.test(String((err as Error)?.message))) return false;
      return count < 2;
    },
  });
}

export function useCustomerNutritionPlan(userId: string | undefined) {
  return useQuery({
    queryKey: ["nutrition-guidance", "plan", userId],
    queryFn: () =>
      apiGet<NutritionPlanResult>(
        `/api/admin/nutrition-guidance/users/${userId}/plan`,
      ),
    enabled: !!userId,
    retry: false,
  });
}

export function useCustomerNutritionLogs(
  userId: string | undefined,
  limit = 30,
) {
  return useQuery({
    queryKey: ["nutrition-guidance", "logs", userId, limit],
    queryFn: () =>
      apiGet<NutritionDailyLogResult[]>(
        `/api/admin/nutrition-guidance/users/${userId}/logs`,
        { limit },
      ),
    enabled: !!userId,
  });
}

// ─── Mutations ──────────────────────────────────────────────────

export function useUpsertCustomerHealthProfile() {
  const qc = useQueryClient();
  return useMutation<
    ApiEnvelope<NutritionHealthProfile>,
    Error,
    { userId: string; payload: UpsertHealthProfileInput }
  >({
    mutationFn: ({ userId, payload }) =>
      apiPut<NutritionHealthProfile>(
        `/api/admin/nutrition-guidance/users/${userId}/profile`,
        payload,
      ),
    onSuccess: (_data, { userId }) => {
      qc.invalidateQueries({ queryKey: ["nutrition-guidance", "profile", userId] });
      qc.invalidateQueries({ queryKey: ["nutrition-guidance", "plan", userId] });
      toast.success("Profil nutrisi tersimpan");
    },
    onError: (err) => toast.error(err.message),
  });
}
