import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPost, apiPut } from "@/lib/api";
import { toast } from "@/stores/toastStore";

// ── Types ───────────────────────────────────────────────────────────

export interface WorkoutSessionLog {
  id: string;
  user_id: string;
  trainer_card_id?: string | null;
  session_type: "full" | "daily";
  level: string;
  duration_seconds: number;
  completed_at: string;
  created_at: string;
}

export interface WorkoutSessionStats {
  total_sessions: number;
  total_seconds: number;
  full_sessions: number;
  daily_sessions: number;
  current_streak: number;
  this_week_count: number;
  last_session_at?: string | null;
}

export interface WorkoutReminder {
  id?: string;
  user_id?: string;
  enabled: boolean;
  days_of_week: number[];
  remind_at: string; // "HH:MM"
  timezone: string;
  last_sent_on?: string | null;
}

// ── Session logs ────────────────────────────────────────────────────

export function useLogWorkoutSession() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: {
      session_type: "full" | "daily";
      duration_seconds: number;
      level?: string;
    }) => apiPost<WorkoutSessionLog>("/api/v2/workout-sessions", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["workout-sessions"] });
      qc.invalidateQueries({ queryKey: ["workout-session-stats"] });
    },
  });
}

export function useWorkoutSessions(sessionType?: "full" | "daily") {
  return useQuery({
    queryKey: ["workout-sessions", sessionType ?? "all"],
    queryFn: () =>
      apiGet<WorkoutSessionLog[]>("/api/v2/workout-sessions", {
        ...(sessionType ? { session_type: sessionType } : {}),
        limit: 50,
      }),
  });
}

export function useWorkoutStats() {
  return useQuery({
    queryKey: ["workout-session-stats"],
    queryFn: () => apiGet<WorkoutSessionStats>("/api/v2/workout-sessions/stats"),
  });
}

// ── Reminders ───────────────────────────────────────────────────────

export function useWorkoutReminder() {
  return useQuery({
    queryKey: ["workout-reminder"],
    queryFn: () => apiGet<WorkoutReminder>("/api/v2/workout-reminders/me"),
  });
}

export function useSaveWorkoutReminder() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: {
      enabled: boolean;
      days_of_week: number[];
      remind_at: string;
      timezone?: string;
    }) => apiPut<WorkoutReminder>("/api/v2/workout-reminders/me", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["workout-reminder"] });
      toast.success("Pengaturan reminder disimpan.");
    },
    onError: (err: any) => {
      toast.error(err?.message || "Gagal menyimpan reminder.");
    },
  });
}
