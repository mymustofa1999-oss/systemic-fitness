import { useQuery } from "@tanstack/react-query";
import { apiGet } from "@/lib/api";

export function useProgressHistory(userId: string, params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["progress", userId, "history", params],
    queryFn: () => apiGet(`/api/progress/user/${userId}`, params),
    enabled: !!userId,
  });
}

export function useProgressCharts(userId: string, params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["progress", userId, "charts", params],
    queryFn: () => apiGet(`/api/progress/user/${userId}/charts`, params),
    enabled: !!userId,
  });
}

export function useBodyMetrics(userId: string, params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["progress", userId, "body-metrics", params],
    queryFn: () => apiGet(`/api/progress/user/${userId}/body-metrics`, params),
    enabled: !!userId,
  });
}
