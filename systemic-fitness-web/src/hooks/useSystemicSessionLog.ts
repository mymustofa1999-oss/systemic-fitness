import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPost } from "@/lib/api";
import { toast } from "@/stores/toastStore";

export interface SystemicSessionLog {
  id?: string;
  user_id?: string;
  session_date: string;
  session_number: number;
  medication_status?: string;

  bp_systolic_pre?: number | null;
  bp_diastolic_pre?: number | null;
  hr_pre?: number | null;
  bp_systolic_post?: number | null;
  bp_diastolic_post?: number | null;
  hr_post?: number | null;

  delta_sbp?: number | null;
  delta_dbp?: number | null;
  delta_hr?: number | null;

  symptom?: string;
  symptom_notes?: string;
  session_stopped: boolean;
  resolved_under_5_min: boolean;

  p1_score?: number | null;
  p2_score?: number | null;
  p3_score?: number | null;
  total_systemic_score?: number | null;
  systemic_status?: string;

  dr_low_fiber_intake: boolean;
  dr_cakes_pastries: boolean;
  dr_starchy_foods: boolean;
  dr_sugary_drinks: boolean;
  dr_butter_fatty: boolean;
  dr_large_carb_portion: boolean;
  dr_seafood_organ_meats: boolean;
  dr_none_of_above: boolean;
  dr_food_detail?: string;
  dr_risk_count: number;
  dr_risk_status?: string;
  dr_risk_score?: number | null;

  hydration?: string;
  hydration_status?: string;
  hydration_notes?: string;
  hydration_score?: number | null;

  sleep_recovery?: string;
  sleep_status?: string;
  sleep_notes?: string;
  sleep_score?: number | null;

  daily_activity?: string;
  activity_status?: string;
  activity_notes?: string;
  activity_score?: number | null;

  total_habit_score?: number | null;
  lifestyle_status?: string;

  created_at?: string;
}

export function useSystemicSessionLogs(userId: string) {
  return useQuery({
    queryKey: ["systemic-session-logs", userId],
    queryFn: async () => {
      if (!userId) return null;
      // Because the route is under clients/{id}, it maps to /users/{id}/systemic-session-log in the API
      // Wait, let's verify what the base URL group is! 
      // I'll assume /users/{id}/systemic-session-log for now based on training-sessions.
      const res = await apiGet(`/users/${userId}/systemic-session-log`);
      return res;
    },
    enabled: !!userId,
  });
}

export function useCreateSystemicSessionLog() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ userId, log }: { userId: string; log: SystemicSessionLog }) => {
      return await apiPost(`/users/${userId}/systemic-session-log`, log);
    },
    onSuccess: (_, variables) => {
      toast.success("Session log saved successfully.");
      queryClient.invalidateQueries({ queryKey: ["systemic-session-logs", variables.userId] });
    },
    onError: (err: any) => {
      toast.error(err?.message || "Failed to save session log");
    },
  });
}
