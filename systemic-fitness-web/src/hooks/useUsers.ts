import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPost, apiPut, apiDelete } from "@/lib/api";
import { toast } from "@/stores/toastStore";

export function useUsers(params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["users", params],
    queryFn: () => apiGet("/api/users", params),
  });
}

export function useUser(id: string) {
  return useQuery({
    queryKey: ["users", id],
    queryFn: () => apiGet(`/api/users/${id}`),
    enabled: !!id,
  });
}

export function useUserStats(id: string) {
  return useQuery({
    queryKey: ["users", id, "stats"],
    queryFn: () => apiGet(`/api/users/${id}/stats`),
    enabled: !!id,
  });
}

export function useUpdateUser() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: any }) => apiPut(`/api/users/${id}`, data),
    onSuccess: (_, { id }) => {
      qc.invalidateQueries({ queryKey: ["users", id] });
      qc.invalidateQueries({ queryKey: ["users"] });
      toast.success("User updated successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// Manually create a client account (admin). Uses the register endpoint so the
// client gets a usable password immediately (the invite flow leaves users
// password-less / pending). Role is forced to "client".
export function useCreateClient() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: { full_name: string; email: string; password: string; phone?: string }) =>
      apiPost("/api/auth/register", { ...data, role: "client" }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["clients"] });
      qc.invalidateQueries({ queryKey: ["users"] });
      toast.success("Client berhasil ditambahkan");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useUpdateClient() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: Record<string, unknown> }) =>
      apiPut(`/api/users/${id}`, data),
    onSuccess: (_, { id }) => {
      qc.invalidateQueries({ queryKey: ["clients"] });
      qc.invalidateQueries({ queryKey: ["users", id] });
      toast.success("Client berhasil diperbarui");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useInviteUser() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: { email: string; full_name: string; role: string; message?: string }) =>
      apiPost("/api/users/invite", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["users"] });
      toast.success("Invitation sent successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDeleteUser() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => apiDelete(`/api/users/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["users"] });
      toast.success("User deleted successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}
