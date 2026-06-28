import { useQuery } from "@tanstack/react-query";
import { apiGet } from "@/lib/api";

// SF Phase 3 — Assessment v2 read hooks (web admin viewer).

export type ProgramType =
  | "condition_specific"
  | "preventive"
  | "performance_women_35_45"
  | "performance_women_46_60"
  | "performance_men_35_45"
  | "performance_men_46_60"
  | "waitlist";

export interface PhaseAInput {
  physical_status_level: "level_0_1" | "level_2_3" | "level_4_5_perf";
  has_medical_condition: boolean;
  classification_slug?: string;
  specific_condition_slug?: string;
  serious_condition_note?: string;
  primary_goal?: "control_medical" | "hormonal_feminine" | "stamina_masculine";
  gender?: "women" | "men";
  age_bucket?: "35_45" | "46_60";
  movement_test?: { squat: number; hip_hinge: number; overhead: number };
}

export interface PhaseBInput {
  duration_hours: number;
  consistency: number;
  sleep_latency: number;
  morning_readiness: number;
  wake_frequency: number;
  pre_sleep_habit: number;
  bedtime_bucket: number;
  wake_time_bucket: number;
  activity_profile: string;
  dinner_time: number;
}

export interface PhaseCInput {
  meal_pattern: number;
  food_dominance: number;
  hydration: number;
  routine_foods?: string[];
  restrictions?: string[];
  restriction_note?: string;
  supplements?: string[];
  supplement_note?: string;
  nutrition_goal: string;
}

export interface ChronobiologyWindow {
  ideal_start: string;
  ideal_end: string;
  alt_start?: string;
  alt_end?: string;
  avoid?: string;
  override_reason?: string;
  hard_cap?: string;
}

export interface SequenceFormula {
  fc_mins?: number;
  cc_mins?: number;
  mc_mins?: number;
  notes?: string;
}

export interface LoadWeight {
  upper_body_kg: number;
  lower_body_kg: number;
}

export interface ProgramMapRecommendation {
  formula: SequenceFormula;
  cardio_load?: LoadWeight;
  metabolic_load?: LoadWeight;
}

export interface AssessmentV2 {
  id: string;
  user_id?: string;
  version: "v2";
  status: "submitted" | "verified" | "revised";

  phase_a: PhaseAInput;
  phase_b?: PhaseBInput;
  phase_c?: PhaseCInput;

  classification_id?: string;
  specific_condition_id?: string;
  physical_status_level: string;
  program_type: ProgramType;

  chronobiology_window?: ChronobiologyWindow;

  rest_score?: number;
  nutrition_score?: number;
  movement_score?: number;
  system_score?: number;

  program_map?: ProgramMapRecommendation;

  flags: string[];
  recommendations: string[];

  created_at: string;
  updated_at: string;
}

export interface TrainingMovement {
  id: string;
  sequence: number;
  title: string;
  video_url: string;
  movement_tag: string;
}

export interface TrainingSet {
  set_name: string;
  duration_mins: number;
  bpm_range: string;
  tags: string[];
  movements: TrainingMovement[];
}

export interface ProgramCategory {
  type: string;
  duration: string;
  sets: TrainingSet[];
}

export interface TrainingCardResponse {
  full_program: ProgramCategory[];
  daily_reset: ProgramCategory[];
}

export function useLatestAssessmentV2(userId: string | undefined) {
  return useQuery({
    queryKey: ["assessment-v2", "latest", userId],
    queryFn: () => apiGet<AssessmentV2>(`/api/v2/assessments/user/${userId}/latest`),
    enabled: !!userId,
    retry: false, // 404 expected for users with no v2 yet
  });
}

export function useAssessmentV2ById(id: string | undefined) {
  return useQuery({
    queryKey: ["assessment-v2", id],
    queryFn: () => apiGet<AssessmentV2>(`/api/v2/assessments/${id}`),
    enabled: !!id,
  });
}

export function useTrainingCardForUser(userId: string | undefined) {
  return useQuery({
    queryKey: ["assessment-v2", "training-card", userId],
    queryFn: () => apiGet<TrainingCardResponse>(`/api/v2/assessments/user/${userId}/training-card`),
    enabled: !!userId,
    retry: false, // Don't retry on 404 (no assessment) or 402 (no subscription)
  });
}
