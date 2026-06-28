import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPost, apiPut, apiDelete } from "@/lib/api";
import { toast } from "@/stores/toastStore";

export function useExercises(params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["exercises", params],
    queryFn: () => apiGet("/api/exercises", params),
  });
}

export function useWorkouts(params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["workouts", params],
    queryFn: () => apiGet("/api/workouts", params),
  });
}

export function useWorkout(id: string) {
  return useQuery({
    queryKey: ["workouts", id],
    queryFn: () => apiGet(`/api/workouts/${id}`),
    enabled: !!id,
  });
}

export function useCreateWorkout() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: unknown) => apiPost("/api/workouts", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["workouts"] });
      toast.success("Workout created successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDuplicateWorkout() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => apiPost(`/api/workouts/${id}/duplicate`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["workouts"] });
      toast.success("Workout duplicated");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useCreateProgram() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: unknown) => apiPost("/api/programs", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["programs"] });
      toast.success("Program created successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useUpdateWorkout() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: unknown }) =>
      apiPut(`/api/workouts/${id}`, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["workouts"] });
      toast.success("Workout updated successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDeleteWorkout() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => apiDelete(`/api/workouts/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["workouts"] });
      toast.success("Workout deleted successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useUpdateProgram() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: unknown }) =>
      apiPut(`/api/programs/${id}`, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["programs"] });
      toast.success("Program updated successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDeleteProgram() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => apiDelete(`/api/programs/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["programs"] });
      toast.success("Program deleted successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useUpdateExercise() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: unknown }) =>
      apiPut(`/api/exercises/${id}`, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["exercises"] });
      toast.success("Exercise updated successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDeleteExercise() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => apiDelete(`/api/exercises/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["exercises"] });
      toast.success("Exercise deleted successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useAssignProgram() {
  return useMutation({
    mutationFn: ({ programId, data }: { programId: string; data: unknown }) =>
      apiPost(`/api/programs/${programId}/assign`, data),
    onSuccess: () => toast.success("Program assigned successfully"),
    onError: (err: Error) => toast.error(err.message),
  });
}
