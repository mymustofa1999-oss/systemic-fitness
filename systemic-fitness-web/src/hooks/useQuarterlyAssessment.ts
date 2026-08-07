import { useState, useCallback } from "react";
import useSWR from "swr";
import { fetcher } from "@/lib/api";

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
  const { data, error, mutate, isLoading } = useSWR<QuarterlyAssessment[]>(
    clientId ? `/v2/quarterly-assessments/client/${clientId}` : null,
    fetcher
  );

  return {
    assessments: data || [],
    isLoading,
    isError: error,
    mutate,
  };
}

export function useCreateQuarterlyAssessment() {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const submit = useCallback(
    async (payload: Omit<QuarterlyAssessment, "id" | "created_at" | "updated_at">) => {
      setIsSubmitting(true);
      setError(null);
      try {
        const token = localStorage.getItem("sf_access_token");
        const res = await fetch(
          `${process.env.NEXT_PUBLIC_API_URL}/v2/quarterly-assessments`,
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${token}`,
            },
            body: JSON.stringify(payload),
          }
        );

        if (!res.ok) {
          const errData = await res.json().catch(() => null);
          throw new Error(errData?.error || "Failed to submit assessment");
        }

        const data = await res.json();
        setIsSubmitting(false);
        return data;
      } catch (err: any) {
        setError(err);
        setIsSubmitting(false);
        throw err;
      }
    },
    []
  );

  return { submit, isSubmitting, error };
}
