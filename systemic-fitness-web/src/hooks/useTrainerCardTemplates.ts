import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPost, apiDelete } from "@/lib/api";
import { toast } from "@/stores/toastStore";

export function useTemplates() {
  return useQuery({
    queryKey: ["training-card-templates"],
    queryFn: () => apiGet("/api/training-card-templates"),
  });
}

export function useTemplate(level: string) {
  return useQuery({
    queryKey: ["training-card-templates", level],
    queryFn: () => apiGet(`/api/training-card-templates/${level}`),
    enabled: !!level,
  });
}

export function useUpsertTemplate() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ level, ...data }: { level: string } & Record<string, unknown>) =>
      apiPost(`/api/training-card-templates/${level}`, data),
    onSuccess: (_d, vars) => {
      qc.invalidateQueries({ queryKey: ["training-card-templates"] });
      qc.invalidateQueries({ queryKey: ["training-card-templates", vars.level] });
      toast.success(`Template Level ${vars.level} disimpan`);
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDeleteTemplate() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (level: string) =>
      apiDelete(`/api/training-card-templates/${level}`),
    onSuccess: (_d, level) => {
      qc.invalidateQueries({ queryKey: ["training-card-templates"] });
      qc.invalidateQueries({ queryKey: ["training-card-templates", level] });
      toast.success(`Template Level ${level} dihapus`);
    },
    onError: (err: Error) => toast.error(err.message),
  });
}
