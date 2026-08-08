import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPost } from "@/lib/api";

export interface QuarterlyAssessment {
  id: string;
  client_id: string;
  quarter: string;
  period_range: string;
  current_level: number;
  functional_criteria_met: boolean;
  movement_quality_met: boolean;
  avg_systemic_score: number;
  score_status_met: boolean;
  decision: string;
  new_level?: number;
  height_cm?: number;
  weight_kg?: number;
  gender?: string;
  bmi?: number;
  bmi_category?: string;
  waist_circumference_cm?: number;
  waist_status?: string;
  medical_condition?: string;
  lab_report_link?: string;
  review_date: string;
  created_at: string;
  updated_at: string;
}

export function useQuarterlyAssessments(clientId: string | undefined) {
  const query = useQuery({
    queryKey: ["quarterly-assessments", clientId],
    queryFn: () => {
      if (!clientId) return { data: [] };
      return apiGet(`/v2/quarterly-assessments/client/${clientId}`);
    },
    enabled: !!clientId,
  });

  return {
    assessments: (query.data?.data || []) as QuarterlyAssessment[],
    isLoading: query.isLoading,
    isError: query.isError,
    mutate: () => query.refetch(),
  };
}

export function useCreateQuarterlyAssessment() {
  const qc = useQueryClient();
  
  const mutation = useMutation({
    mutationFn: (payload: Omit<QuarterlyAssessment, "id" | "created_at" | "updated_at">) =>
      apiPost(`/v2/quarterly-assessments`, payload),
    onSuccess: (_, vars) => {
      qc.invalidateQueries({ queryKey: ["quarterly-assessments", vars.client_id] });
    },
  });

  return {
    submit: mutation.mutateAsync,
    isSubmitting: mutation.isPending,
    error: mutation.error,
  };
}
