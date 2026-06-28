import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPost, apiPut, apiDelete, ApiEnvelope } from "@/lib/api";
import { toast } from "@/stores/toastStore";

// ─── Types ──────────────────────────────────────────────────────

export interface TrainingSchedule {
  id: string;
  client_id: string;
  trainer_id: string;
  day_of_week: number;
  start_time: string;
  end_time: string;
  location: string | null;
  notes: string | null;
  is_active: boolean;
  created_by: string;
  created_at: string;
  updated_at: string;
  client_name?: string;
  trainer_name?: string;
}

export interface TrainingSession {
  id: string;
  schedule_id: string | null;
  client_id: string;
  trainer_id: string;
  session_date: string;
  start_time: string;
  end_time: string;
  status: "scheduled" | "completed" | "cancelled" | "substituted";
  location: string | null;
  notes: string | null;
  is_substitute: boolean;
  original_trainer_id: string | null;
  substitute_reason: string | null;
  // Audit log (populated when a consultant substitutes a trainer)
  substituted_by: string | null;
  substituted_at: string | null;
  created_by: string;
  created_at: string;
  updated_at: string;
  client_name?: string;
  trainer_name?: string;
  original_trainer_name?: string;
  substituted_by_name?: string;
}

// ─── Schedules (recurring) ──────────────────────────────────────

export function useTrainingSchedules(params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["training-schedules", params],
    queryFn: () => apiGet("/api/training-schedules", params),
  });
}

export function useCreateTrainingSchedule() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: unknown) => apiPost("/api/training-schedules", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["training-schedules"] });
      toast.success("Jadwal berhasil dibuat");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useUpdateTrainingSchedule() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: { id: string } & Record<string, unknown>) =>
      apiPut(`/api/training-schedules/${id}`, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["training-schedules"] });
      toast.success("Jadwal berhasil diupdate");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDeleteTrainingSchedule() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => apiDelete(`/api/training-schedules/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["training-schedules"] });
      toast.success("Jadwal berhasil dihapus");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ─── Sessions (individual) ──────────────────────────────────────

export function useTrainingSessions(params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["training-sessions", params],
    queryFn: () => apiGet("/api/training-schedules/sessions", params),
  });
}

export function useCreateTrainingSession() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: unknown) => apiPost("/api/training-schedules/sessions", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["training-sessions"] });
      toast.success("Sesi berhasil dibuat");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useUpdateTrainingSession() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: { id: string } & Record<string, unknown>) =>
      apiPut(`/api/training-schedules/sessions/${id}`, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["training-sessions"] });
      toast.success("Sesi berhasil diupdate");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDeleteTrainingSession() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => apiDelete(`/api/training-schedules/sessions/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["training-sessions"] });
      toast.success("Sesi berhasil dihapus");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useSubstituteTrainer() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ sessionId, ...data }: { sessionId: string; substitute_trainer_id: string; reason: string }) =>
      apiPost(`/api/training-schedules/sessions/${sessionId}/substitute`, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["training-sessions"] });
      toast.success("Trainer berhasil digantikan");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ─── Bulk substitution ─────────────────────────────────────────

export interface BulkSubstituteInput {
  original_trainer_id: string;
  substitute_trainer_id: string;
  date_from: string; // YYYY-MM-DD
  date_to: string;   // YYYY-MM-DD
  reason: string;
}

export interface BulkSubstituteResult {
  materialized_sessions: number;
  substituted_sessions: number;
  skipped_sessions: number;
  errors?: string[];
}

/**
 * Reassigns ALL sessions for a trainer within a date range to another
 * trainer. Used when a trainer is sick / on leave for several days.
 * Konsultan-only.
 */
export function useBulkSubstitute() {
  const qc = useQueryClient();
  return useMutation<ApiEnvelope<BulkSubstituteResult>, Error, BulkSubstituteInput>({
    mutationFn: (data) =>
      apiPost<BulkSubstituteResult>("/api/training-schedules/sessions/bulk-substitute", data),
    onSuccess: (res) => {
      qc.invalidateQueries({ queryKey: ["training-sessions"] });
      qc.invalidateQueries({ queryKey: ["training-schedules"] });
      const r = res.data;
      if (r) {
        const errCount = r.errors?.length ?? 0;
        if (errCount > 0) {
          toast.success(
            `${r.substituted_sessions} sesi diganti, ${errCount} gagal. Lihat log untuk detail.`,
          );
        } else {
          toast.success(`${r.substituted_sessions} sesi berhasil diganti`);
        }
      }
    },
    onError: (err) => toast.error(err.message),
  });
}
