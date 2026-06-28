import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPost, apiPatch, apiDelete } from "@/lib/api";
import { toast } from "@/stores/toastStore";

// SF Phase 7b — Consultant Dashboard hooks (queue, klien saya, clinical notes, lab assign).

// ─── Antrian Review ────────────────────────────────────────────────

export interface PendingReviewItem {
  assessment_id: string;
  user_id: string | null;
  user_name: string | null;
  user_email: string | null;
  classification_id: string | null;
  specific_condition_id: string | null;
  physical_status_level:
    | "level_0_1"
    | "level_2_3"
    | "level_4_5_perf"
    | null;
  program_type:
    | "condition_specific"
    | "preventive"
    | "performance_women_35_45"
    | "performance_women_46_60"
    | "performance_men_35_45"
    | "performance_men_46_60"
    | "waitlist"
    | null;
  system_score: number | null;
  created_at: string;
}

export function useConsultantQueue(limit = 200) {
  return useQuery({
    queryKey: ["consultant-queue", limit],
    queryFn: () =>
      apiGet<PendingReviewItem[]>("/api/v2/consultant/queue", { limit }),
  });
}

// ─── Klien Saya ────────────────────────────────────────────────────

export interface ConsultantClient {
  client_id: string;
  client_name: string | null;
  client_email: string | null;
  note_count: number;
  lab_count: number;
  last_interaction: string;
}

export function useConsultantClients() {
  return useQuery({
    queryKey: ["consultant-clients"],
    queryFn: () =>
      apiGet<ConsultantClient[]>("/api/v2/consultant/clients"),
  });
}

// ─── Clinical Notes CRUD ───────────────────────────────────────────

export interface ClinicalNote {
  id: string;
  assessment_id: string | null;
  client_id: string;
  consultant_id: string;
  title: string;
  content: string;
  attachments: unknown[];
  is_visible_to_client: boolean;
  created_at: string;
  updated_at: string;
  client_name?: string | null;
  client_email?: string | null;
  consultant_name?: string | null;
}

export interface ClinicalNoteFilter {
  consultant_id?: string;
  client_id?: string;
  assessment_id?: string;
  only_published?: boolean;
}

export function useClinicalNotes(filter: ClinicalNoteFilter = {}) {
  return useQuery({
    queryKey: ["clinical-notes", filter],
    queryFn: () => {
      const params: Record<string, unknown> = {};
      if (filter.consultant_id) params.consultant_id = filter.consultant_id;
      if (filter.client_id) params.client_id = filter.client_id;
      if (filter.assessment_id) params.assessment_id = filter.assessment_id;
      if (filter.only_published) params.only_published = "true";
      return apiGet<ClinicalNote[]>("/api/v2/clinical-notes", params);
    },
  });
}

export function useClinicalNote(id: string | null) {
  return useQuery({
    queryKey: ["clinical-notes", id],
    queryFn: () => apiGet<ClinicalNote>(`/api/v2/clinical-notes/${id}`),
    enabled: !!id,
  });
}

export interface CreateClinicalNoteInput {
  client_id: string;
  assessment_id?: string;
  title?: string;
  content: string;
  attachments?: unknown[];
  is_visible_to_client?: boolean;
}

export function useCreateClinicalNote() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: CreateClinicalNoteInput) =>
      apiPost<ClinicalNote>("/api/v2/clinical-notes", data),
    onSuccess: (_, vars) => {
      qc.invalidateQueries({ queryKey: ["clinical-notes"] });
      qc.invalidateQueries({ queryKey: ["consultant-queue"] });
      qc.invalidateQueries({ queryKey: ["consultant-clients"] });
      if (vars.client_id) {
        qc.invalidateQueries({ queryKey: ["clinical-notes", { client_id: vars.client_id }] });
      }
      toast.success("Catatan klinis tersimpan");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export interface UpdateClinicalNoteInput {
  id: string;
  title?: string;
  content: string;
  attachments?: unknown[];
  is_visible_to_client: boolean;
}

export function useUpdateClinicalNote() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: UpdateClinicalNoteInput) =>
      apiPatch<ClinicalNote>(`/api/v2/clinical-notes/${id}`, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["clinical-notes"] });
      toast.success("Catatan klinis diperbarui");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDeleteClinicalNote() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) =>
      apiDelete<{ message: string }>(`/api/v2/clinical-notes/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["clinical-notes"] });
      qc.invalidateQueries({ queryKey: ["consultant-queue"] });
      toast.success("Catatan klinis dihapus");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ─── Lab Consultation: Assign Consultant ───────────────────────────

export function useAssignLabConsultant() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, consultant_id }: { id: string; consultant_id: string }) =>
      apiPatch(`/api/v2/lab-consultations/${id}/assign`, { consultant_id }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["lab-consultations"] });
      toast.success("Consultant ter-assign");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}
