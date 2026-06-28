import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPatch } from "@/lib/api";
import { toast } from "@/stores/toastStore";

// SF Phase 3 — System Score Weights (owner-tunable 35/35/30 default).
// Backed by /api/v2/assessments/score-weights.

export interface SystemScoreWeights {
  id: string;
  name: string;
  movement_pct: number;
  nutrition_pct: number;
  rest_pct: number;
  is_active: boolean;
  notes?: string | null;
  created_at: string;
  updated_at: string;
}

export interface UpdateScoreWeightsInput {
  name: string;
  movement_pct: number;
  nutrition_pct: number;
  rest_pct: number;
  notes?: string;
}

export function useSystemScoreWeights() {
  return useQuery({
    queryKey: ["system-score-weights"],
    queryFn: () => apiGet<SystemScoreWeights>("/api/v2/assessments/score-weights"),
  });
}

export function useUpdateSystemScoreWeights() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: UpdateScoreWeightsInput) =>
      apiPatch<SystemScoreWeights>("/api/v2/assessments/score-weights", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["system-score-weights"] });
      toast.success("Bobot System Score diperbarui");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}
