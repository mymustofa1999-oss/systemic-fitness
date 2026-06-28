import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPost, apiPut, apiDelete } from "@/lib/api";
import { toast } from "@/stores/toastStore";

// ─── Categories & Levels ────────────────────────────────────────

export function useDLCategories() {
  return useQuery({
    queryKey: ["dl-categories"],
    queryFn: () => apiGet("/api/digital-library/categories"),
  });
}

export function useDLLevels() {
  return useQuery({
    queryKey: ["dl-levels"],
    queryFn: () => apiGet("/api/digital-library/levels"),
  });
}

// ─── Movements (CRUD) ───────────────────────────────────────────

export function useDLMovements(params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["dl-movements", params],
    queryFn: () => apiGet("/api/digital-library/movements", params),
  });
}

export function useDLMovement(id: string) {
  return useQuery({
    queryKey: ["dl-movements", id],
    queryFn: () => apiGet(`/api/digital-library/movements/${id}`),
    enabled: !!id,
  });
}

export function useCreateDLMovement() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: any) => apiPost("/api/digital-library/movements", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["dl-movements"] });
      toast.success("Movement created successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useUpdateDLMovement() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: any }) =>
      apiPut(`/api/digital-library/movements/${id}`, data),
    onSuccess: (_, { id }) => {
      qc.invalidateQueries({ queryKey: ["dl-movements", id] });
      qc.invalidateQueries({ queryKey: ["dl-movements"] });
      toast.success("Movement updated successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDeleteDLMovement() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => apiDelete(`/api/digital-library/movements/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["dl-movements"] });
      toast.success("Movement deleted successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ─── Menu / Isolate / Dynamic Items ─────────────────────────────

export function useDLMenuItems(code: string, level?: number) {
  const params: Record<string, unknown> = {};
  if (level !== undefined) params.level = level;
  return useQuery({
    queryKey: ["dl-menu", code, level],
    queryFn: () => apiGet(`/api/digital-library/categories/${code}/menu`, params),
    enabled: !!code,
  });
}

export function useDLIsolateItems(code: string, position?: string) {
  const params: Record<string, unknown> = {};
  if (position) params.position = position;
  return useQuery({
    queryKey: ["dl-isolate", code, position],
    queryFn: () => apiGet(`/api/digital-library/categories/${code}/isolate`, params),
    enabled: !!code,
  });
}

export function useDLDynamicItems(code: string) {
  return useQuery({
    queryKey: ["dl-dynamic", code],
    queryFn: () => apiGet(`/api/digital-library/categories/${code}/dynamic`),
    enabled: !!code,
  });
}

// ─── Program Overview ───────────────────────────────────────────

export function useDLProgramOverview(code: string) {
  return useQuery({
    queryKey: ["dl-program", code],
    queryFn: () => apiGet(`/api/digital-library/categories/${code}/program`),
    enabled: !!code,
  });
}
