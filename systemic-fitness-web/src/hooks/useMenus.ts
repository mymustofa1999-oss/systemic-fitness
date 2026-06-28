import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPost, apiPut, apiDelete } from "@/lib/api";
import { toast } from "@/stores/toastStore";

// ─── Types ───────────────────���──────────────────────────────────

export interface MenuItem {
  id: string;
  parent_id: string | null;
  code: string;
  label: string;
  icon: string | null;
  href: string | null;
  sort_order: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
  children?: MenuItem[];
}

export interface MenuRolePrivilege {
  id: string;
  menu_id: string;
  role: string;
  can_access: boolean;
  created_at: string;
}

// ─── User menus (sidebar) ───────────────────────────────────────

export function useMyMenus() {
  return useQuery({
    queryKey: ["menus", "my"],
    queryFn: () => apiGet<MenuItem[]>("/api/menus/my"),
    staleTime: 5 * 60 * 1000, // cache 5 minutes
  });
}

// ─── Admin: Menu CRUD ────────────────────────���──────────────────

export function useMenus(params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["menus", "all", params],
    queryFn: () => apiGet("/api/menus", params),
  });
}

export function useMenuTree() {
  return useQuery({
    queryKey: ["menus", "tree"],
    queryFn: () => apiGet<MenuItem[]>("/api/menus/tree"),
  });
}

export function useCreateMenu() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: unknown) => apiPost("/api/menus", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["menus"] });
      toast.success("Menu created successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useUpdateMenu() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: { id: string } & Record<string, unknown>) =>
      apiPut(`/api/menus/${id}`, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["menus"] });
      toast.success("Menu updated successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDeleteMenu() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => apiDelete(`/api/menus/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["menus"] });
      toast.success("Menu deleted");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useReorderMenus() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (items: { id: string; sort_order: number; parent_id: string | null }[]) =>
      apiPost("/api/menus/reorder", { items }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["menus"] });
      toast.success("Menu order updated");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ─── Admin: Privileges ──────────────────────────────────────────

export function useMenuPrivileges() {
  return useQuery({
    queryKey: ["menus", "privileges"],
    queryFn: () => apiGet<MenuRolePrivilege[]>("/api/menus/privileges"),
  });
}

export function useUpsertMenuPrivileges() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ menuId, privileges }: {
      menuId: string;
      privileges: { role: string; can_access: boolean }[];
    }) => apiPut(`/api/menus/${menuId}/privileges`, { privileges }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["menus"] });
      toast.success("Privileges updated");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useBulkUpsertPrivileges() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (items: {
      menu_id: string;
      privileges: { role: string; can_access: boolean }[];
    }[]) => apiPut("/api/menus/privileges/bulk", { items }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["menus"] });
      toast.success("All privileges updated");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}
