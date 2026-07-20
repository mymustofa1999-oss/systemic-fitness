import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPost } from "@/lib/api";
import { toast } from "@/stores/toastStore";

export interface TrainingSessionLog {
  id?: string;
  user_id?: string;
  period_name: string;
  session_number: number;
  date?: string | null;
  took_medicine: boolean;
  last_meal_hours?: number | null;
  last_meal_food?: string | null;
  bp_pre_systolic?: number | null;
  bp_pre_diastolic?: number | null;
  hr_pre?: number | null;
  bp_post_systolic?: number | null;
  bp_post_diastolic?: number | null;
  hr_post?: number | null;
}

export function useTrainingSessionLogs(userId: string, periodName: string) {
  return useQuery({
    queryKey: ["training_sessions", userId, periodName],
    queryFn: async () => {
      if (!userId || !periodName) return null;
      const res = await apiGet(`/api/users/${userId}/training-sessions?period=${encodeURIComponent(periodName)}`);
      return res.data;
    },
    enabled: !!userId && !!periodName,
  });
}

export function useUpsertTrainingSessionLogs() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ userId, periodName, logs }: { userId: string; periodName: string; logs: TrainingSessionLog[] }) => {
      const payload = {
        period_name: periodName,
        logs: logs,
      };
      const res = await apiPost(`/api/users/${userId}/training-sessions`, payload);
      return res;
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ["training_sessions", variables.userId, variables.periodName] });
      toast.success("Training session logs saved successfully");
    },
    onError: (error: any) => {
      toast.error(error?.message || "Failed to save logs");
    },
  });
}
