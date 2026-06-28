import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPost, apiPut, apiDelete } from "@/lib/api";
import { toast } from "@/stores/toastStore";

// ════════════════════════════════════════════════════════════════════
//  Health News / Articles Hooks
// ════════════════════════════════════════════════════════════════════

export interface HealthArticleInput {
  title: string;
  content: string;
  image_url: string;
  source: string;
  is_published: boolean;
}

export function useHealthArticles() {
  return useQuery({
    queryKey: ["health-news"],
    queryFn: () => apiGet<any[]>("/api/cms/health-news"),
  });
}

export function useHealthArticle(id: string) {
  return useQuery({
    queryKey: ["health-news", id],
    queryFn: () => apiGet<any>(`/api/cms/health-news/${id}`),
    enabled: !!id,
  });
}

export function useCreateHealthArticle() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: HealthArticleInput) =>
      apiPost("/api/cms/health-news", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["health-news"] });
      toast.success("Berita kesehatan berhasil dibuat");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useUpdateHealthArticle() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: { id: string } & HealthArticleInput) =>
      apiPut(`/api/cms/health-news/${id}`, data),
    onSuccess: (_d, vars) => {
      qc.invalidateQueries({ queryKey: ["health-news"] });
      qc.invalidateQueries({ queryKey: ["health-news", vars.id] });
      toast.success("Berita kesehatan berhasil diperbarui");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDeleteHealthArticle() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => apiDelete(`/api/cms/health-news/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["health-news"] });
      toast.success("Berita kesehatan berhasil dihapus");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

// ════════════════════════════════════════════════════════════════════
//  Doctor Videos Hooks
// ════════════════════════════════════════════════════════════════════

export interface DoctorVideoInput {
  title: string;
  description: string;
  video_url: string;
  thumbnail_url: string;
  doctor_name: string;
  doctor_specialty: string;
  is_published: boolean;
}

export function useDoctorVideos() {
  return useQuery({
    queryKey: ["doctor-videos"],
    queryFn: () => apiGet<any[]>("/api/cms/doctor-videos"),
  });
}

export function useDoctorVideo(id: string) {
  return useQuery({
    queryKey: ["doctor-videos", id],
    queryFn: () => apiGet<any>(`/api/cms/doctor-videos/${id}`),
    enabled: !!id,
  });
}

export function useCreateDoctorVideo() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: DoctorVideoInput) =>
      apiPost("/api/cms/doctor-videos", data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["doctor-videos"] });
      toast.success("Video dokter berhasil dibuat");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useUpdateDoctorVideo() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: { id: string } & DoctorVideoInput) =>
      apiPut(`/api/cms/doctor-videos/${id}`, data),
    onSuccess: (_d, vars) => {
      qc.invalidateQueries({ queryKey: ["doctor-videos"] });
      qc.invalidateQueries({ queryKey: ["doctor-videos", vars.id] });
      toast.success("Video dokter berhasil diperbarui");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}

export function useDeleteDoctorVideo() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => apiDelete(`/api/cms/doctor-videos/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["doctor-videos"] });
      toast.success("Video dokter berhasil dihapus");
    },
    onError: (err: Error) => toast.error(err.message),
  });
}
