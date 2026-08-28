import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPost, apiPut, apiDelete } from "@/lib/api";
import { toast } from "@/stores/toastStore";

// ─── Foods ──────────────────────────────────────────────────────

export function useFoods(params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["foods", params],
    queryFn: () => apiGet("/api/foods", params),
  });
}

export function useCreateFood() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: unknown) => apiPost("/api/foods", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["foods"] });
      toast.success("Food created successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useUpdateFood() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: { id: string } & Record<string, unknown>) =>
      apiPut(`/api/foods/${id}`, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["foods"] });
      toast.success("Food updated successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDeleteFood() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => apiDelete(`/api/foods/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["foods"] });
      toast.success("Food deleted");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ─── Medicines (Daftar Obat) ────────────────────────────────────

export function useMedicines(params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["medicines", params],
    queryFn: () => apiGet("/api/medicines", params),
  });
}

export function useCreateMedicine() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: unknown) => apiPost("/api/medicines", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["medicines"] });
      toast.success("Medicine created successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useUpdateMedicine() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: { id: string } & Record<string, unknown>) =>
      apiPut(`/api/medicines/${id}`, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["medicines"] });
      toast.success("Medicine updated successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDeleteMedicine() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => apiDelete(`/api/medicines/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["medicines"] });
      toast.success("Medicine deleted");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ─── Program Categories ────────────────────────────────────────

export function useProgramCategories(params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["program-categories", params],
    queryFn: () => apiGet("/api/program-categories", params),
  });
}

export function useCreateProgramCategory() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: unknown) => apiPost("/api/program-categories", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["program-categories"] });
      toast.success("Program category created successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useUpdateProgramCategory() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: { id: string } & Record<string, unknown>) =>
      apiPut(`/api/program-categories/${id}`, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["program-categories"] });
      toast.success("Program category updated successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDeleteProgramCategory() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => apiDelete(`/api/program-categories/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["program-categories"] });
      toast.success("Program category deleted");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ─── Customer Setup ────────────────────────────────────────────

export function useCustomerSetup(customerId: string) {
  return useQuery({
    queryKey: ["customer-setup", customerId],
    queryFn: () => apiGet(`/api/customers/${customerId}/setup`),
    enabled: !!customerId,
  });
}

export function useCustomerHRZone(customerId: string) {
  return useQuery({
    queryKey: ["customer-hr-zone", customerId],
    queryFn: () => apiGet(`/api/customers/${customerId}/hr-zone`),
    enabled: !!customerId,
  });
}

export function useUpsertHRZone() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ customerId, ...data }: { customerId: string } & Record<string, unknown>) =>
      apiPut(`/api/customers/${customerId}/hr-zone`, data),
    onSuccess: (_d, vars) => {
      qc.invalidateQueries({ queryKey: ["customer-hr-zone", vars.customerId] });
      qc.invalidateQueries({ queryKey: ["customer-setup", vars.customerId] });
      toast.success("HR Zone saved");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useCustomerMedicines(customerId: string) {
  return useQuery({
    queryKey: ["customer-medicines", customerId],
    queryFn: () => apiGet(`/api/customers/${customerId}/medicines`),
    enabled: !!customerId,
  });
}

export function useAddCustomerMedicine() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ customerId, ...data }: { customerId: string } & Record<string, unknown>) =>
      apiPost(`/api/customers/${customerId}/medicines`, data),
    onSuccess: (_d, vars) => {
      qc.invalidateQueries({ queryKey: ["customer-medicines", vars.customerId] });
      qc.invalidateQueries({ queryKey: ["customer-setup", vars.customerId] });
      toast.success("Obat ditambahkan");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useRemoveCustomerMedicine() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ customerId, medicineId }: { customerId: string; medicineId: string }) =>
      apiDelete(`/api/customers/${customerId}/medicines/${medicineId}`),
    onSuccess: (_d, vars) => {
      qc.invalidateQueries({ queryKey: ["customer-medicines", vars.customerId] });
      qc.invalidateQueries({ queryKey: ["customer-setup", vars.customerId] });
      toast.success("Obat dihapus");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useCustomerPrograms(customerId: string) {
  return useQuery({
    queryKey: ["customer-programs", customerId],
    queryFn: () => apiGet(`/api/customers/${customerId}/programs`),
    enabled: !!customerId,
  });
}

export function useUpsertCustomerProgram() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ customerId, ...data }: { customerId: string } & Record<string, unknown>) =>
      apiPost(`/api/customers/${customerId}/programs`, data),
    onSuccess: (_d, vars) => {
      qc.invalidateQueries({ queryKey: ["customer-programs", vars.customerId] });
      qc.invalidateQueries({ queryKey: ["customer-setup", vars.customerId] });
      toast.success("Program disimpan");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useRemoveCustomerProgram() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ customerId, programCategoryId }: { customerId: string; programCategoryId: string }) =>
      apiDelete(`/api/customers/${customerId}/programs/${programCategoryId}`),
    onSuccess: (_d, vars) => {
      qc.invalidateQueries({ queryKey: ["customer-programs", vars.customerId] });
      qc.invalidateQueries({ queryKey: ["customer-setup", vars.customerId] });
      toast.success("Program dihapus");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ─── Staff Assignment ──────────────────────────────────────────

export function useAssignStaff() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ customerId, ...data }: { customerId: string; staff_id: string; role_type: string }) =>
      apiPost(`/api/customers/${customerId}/staff`, data),
    onSuccess: (_d, vars) => {
      qc.invalidateQueries({ queryKey: ["customer-setup", vars.customerId] });
      toast.success("Staff berhasil di-assign");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useUpdateCustomerPriority() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ customerId, ...data }: { customerId: string; priority: string }) =>
      apiPut(`/api/customers/${customerId}/priority`, data),
    onSuccess: (_d, vars) => {
      qc.invalidateQueries({ queryKey: ["customer-setup", vars.customerId] });
      toast.success("Prioritas disimpan");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ─── Daily Journal ─────────────────────────────────────────────

export function useJournalSessions(customerId: string, month: string) {
  return useQuery({
    queryKey: ["journal-sessions", customerId, month],
    queryFn: () => apiGet(`/api/customers/${customerId}/journal`, { month }),
    enabled: !!customerId && !!month,
  });
}

export function useJournalMonths(customerId: string) {
  return useQuery({
    queryKey: ["journal-months", customerId],
    queryFn: () => apiGet(`/api/customers/${customerId}/journal/months`),
    enabled: !!customerId,
  });
}

export function useUpsertJournalSession() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ customerId, ...data }: { customerId: string } & Record<string, unknown>) =>
      apiPost(`/api/customers/${customerId}/journal`, data),
    onSuccess: (_d, vars) => {
      qc.invalidateQueries({ queryKey: ["journal-sessions", vars.customerId] });
      qc.invalidateQueries({ queryKey: ["journal-months", vars.customerId] });
      toast.success("Sesi disimpan");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDeleteJournalSession() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ customerId, sessionId }: { customerId: string; sessionId: string }) =>
      apiDelete(`/api/customers/${customerId}/journal/${sessionId}`),
    onSuccess: (_d, vars) => {
      qc.invalidateQueries({ queryKey: ["journal-sessions", vars.customerId] });
      qc.invalidateQueries({ queryKey: ["journal-months", vars.customerId] });
      toast.success("Sesi dihapus");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ─── Groups ─────────────────────────────────────────────────────

export function useGroups(params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["groups", params],
    queryFn: () => apiGet("/api/groups", params),
  });
}

export function useCreateGroup() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: unknown) => apiPost("/api/groups", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["groups"] });
      toast.success("Group created successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDeleteGroup() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => apiDelete(`/api/groups/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["groups"] });
      toast.success("Group deleted");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ─── Challenges ─────────────────────────────────────────────────

export function useChallenges(params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["challenges", params],
    queryFn: () => apiGet("/api/challenges", params),
  });
}

export function useCreateChallenge() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: unknown) => apiPost("/api/challenges", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["challenges"] });
      toast.success("Challenge created successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDeleteChallenge() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => apiDelete(`/api/challenges/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["challenges"] });
      toast.success("Challenge deleted");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ─── Announcements ──────────────────────────────────────────────

export function useAnnouncements(params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["announcements", params],
    queryFn: () => apiGet("/api/announcements", params),
  });
}

export function useCreateAnnouncement() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: unknown) => apiPost("/api/announcements", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["announcements"] });
      toast.success("Announcement created successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDeleteAnnouncement() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => apiDelete(`/api/announcements/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["announcements"] });
      toast.success("Announcement deleted");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ─── Habits ─────────────────────────────────────────────────────

export function useHabitFolders() {
  return useQuery({
    queryKey: ["habit-folders"],
    queryFn: () => apiGet("/api/habits/folders"),
  });
}

export function useHabits(params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["habits", params],
    queryFn: () => apiGet("/api/habits", params),
  });
}

export function useCreateHabit() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: unknown) => apiPost("/api/habits", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["habits"] });
      toast.success("Habit created successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useCreateHabitFolder() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: unknown) => apiPost("/api/habits/folders", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["habit-folders"] });
      toast.success("Folder created");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ─── Forms ──────────────────────────────────────────────────────

export function useForms(params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["forms", params],
    queryFn: () => apiGet("/api/forms", params),
  });
}

export function useCreateForm() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: unknown) => apiPost("/api/forms", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["forms"] });
      toast.success("Form created successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ─── Clients ────────────────────────────────────────────────────

export function useClients(params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["clients", params],
    queryFn: () => apiGet("/api/clients", params),
  });
}

// ─── Team ───────────────────────────────────────────────────────

export function useTeam(params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["team", params],
    queryFn: () => apiGet("/api/team", params),
  });
}

// ─── Scheduling ─────────────────────────────────────────────────

export function useCalendarEvents(params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["calendar-events", params],
    queryFn: () => apiGet("/api/scheduling/events", params),
  });
}

export function useEventTypes() {
  return useQuery({
    queryKey: ["event-types"],
    queryFn: () => apiGet("/api/scheduling/event-types"),
  });
}

export function useCreateEvent() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: unknown) => apiPost("/api/scheduling/events", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["calendar-events"] });
      toast.success("Event created successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ─── Equipments (Master Data) ───────────────────────────────────

export function useEquipments(params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["equipments", params],
    queryFn: () => apiGet("/api/equipments", params),
  });
}

export function useCreateEquipment() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: unknown) => apiPost("/api/equipments", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["equipments"] });
      toast.success("Equipment berhasil dibuat");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useUpdateEquipment() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: { id: string } & Record<string, unknown>) =>
      apiPut(`/api/equipments/${id}`, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["equipments"] });
      toast.success("Equipment berhasil diperbarui");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDeleteEquipment() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => apiDelete(`/api/equipments/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["equipments"] });
      toast.success("Equipment berhasil dihapus");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ─── Promotions (Banners) ──────────────────────────────────────

export function usePromotions(params: Record<string, unknown> = {}) {
  return useQuery({
    queryKey: ["promotions", params],
    queryFn: () => apiGet("/api/promotions", params),
  });
}

export function usePromotion(id: string) {
  return useQuery({
    queryKey: ["promotions", id],
    queryFn: () => apiGet(`/api/promotions/${id}`),
    enabled: !!id,
  });
}

export function useCreatePromotion() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: unknown) => apiPost("/api/promotions", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["promotions"] });
      toast.success("Banner created successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useUpdatePromotion() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: { id: string } & Record<string, unknown>) =>
      apiPut(`/api/promotions/${id}`, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["promotions"] });
      toast.success("Banner updated successfully");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDeletePromotion() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => apiDelete(`/api/promotions/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["promotions"] });
      toast.success("Banner deleted");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ─── Training Card Types (Master) ──────────────────────────────

export function useTrainerCardTypes() {
  return useQuery({
    queryKey: ["trainer-card-types"],
    queryFn: () => apiGet("/api/training-card-types"),
  });
}

export function useCreateTrainerCardType() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: unknown) => apiPost("/api/training-card-types", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["trainer-card-types"] });
      toast.success("Tipe berhasil ditambahkan");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useUpdateTrainerCardType() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: { id: string } & Record<string, unknown>) =>
      apiPut(`/api/training-card-types/${id}`, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["trainer-card-types"] });
      toast.success("Tipe berhasil diperbarui");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDeleteTrainerCardType() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => apiDelete(`/api/training-card-types/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["trainer-card-types"] });
      toast.success("Tipe berhasil dihapus");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ─── Training Card (per Customer) ──────────────────────────────

export function useTrainerCard(customerId: string) {
  return useQuery({
    queryKey: ["trainer-card", customerId],
    queryFn: () => apiGet(`/api/customers/${customerId}/training-card`),
    enabled: !!customerId,
  });
}

export function useUpsertTrainerCard() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ customerId, ...data }: { customerId: string } & Record<string, unknown>) =>
      apiPost(`/api/customers/${customerId}/training-card`, data),
    onSuccess: (_d, vars) => {
      qc.invalidateQueries({ queryKey: ["trainer-card", vars.customerId] });
      toast.success("Training card disimpan");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function usePublishTrainerCard() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (customerId: string) =>
      apiPost(`/api/customers/${customerId}/training-card/publish`, {}),
    onSuccess: (_d, vars) => {
      qc.invalidateQueries({ queryKey: ["trainer-card", vars] });
      toast.success("Training card berhasil dikirim ke Trainer");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDeleteTrainerCard() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (customerId: string) =>
      apiDelete(`/api/customers/${customerId}/training-card`),
    onSuccess: (_d, customerId) => {
      qc.invalidateQueries({ queryKey: ["trainer-card", customerId] });
      toast.success("Training card dihapus");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useToggleMedicineActive() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, is_active }: { id: string, is_active: boolean }) => apiPut(`/api/medicines/${id}`, { is_active }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["medicines"] });
    }
  });
}
