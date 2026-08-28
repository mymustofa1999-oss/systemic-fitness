import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPut, apiPost, apiDelete } from "@/lib/api";
import { toast } from "@/stores/toastStore";

export interface TimeSlot {
  day_of_week: number;
  start_time: string;
  end_time: string;
  is_active: boolean;
}

export interface TrainerAvailability {
  id: string;
  trainer_id: string;
  day_of_week: number;
  start_time: string;
  end_time: string;
  is_active: boolean;
}

export interface TrainerAvailabilityWithUser extends TrainerAvailability {
  trainer_name: string;
}

export function useMyAvailability(trainerId?: string) {
  return useQuery({
    queryKey: ["availability", trainerId],
    queryFn: () => apiGet<TrainerAvailability[]>(`/api/scheduling/availability/${trainerId}`),
    enabled: !!trainerId,
  });
}

export function useAllAvailability() {
  return useQuery({
    queryKey: ["availability", "all"],
    queryFn: () => apiGet<TrainerAvailabilityWithUser[]>("/api/scheduling/availability/all"),
  });
}

export function useReplaceAvailability() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (slots: TimeSlot[]) => apiPut("/api/scheduling/availability", { slots }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["availability"] });
      toast.success("Availability schedule saved successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}
