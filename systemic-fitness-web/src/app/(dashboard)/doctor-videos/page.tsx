"use client";

import { useState } from "react";
import {
  useDoctorVideos,
  useCreateDoctorVideo,
  useUpdateDoctorVideo,
  useDeleteDoctorVideo,
} from "@/hooks/useHealthContent";
import { ImageUpload } from "@/components/shared/ImageUpload";
import { EmptyState } from "@/components/shared/EmptyState";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { SearchInput } from "@/components/shared/SearchInput";
import { Video, Plus, X, Loader2, Pencil, Trash2 } from "lucide-react";
import { cn } from "@/lib/utils";

export default function DoctorVideosPage() {
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState<"all" | "published" | "draft">("all");
  const [modal, setModal] = useState<any | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<any | null>(null);

  const { data, isLoading } = useDoctorVideos();
  const videos = (data?.data ?? []) as any[];
  const createDoctorVideo = useCreateDoctorVideo();
  const updateDoctorVideo = useUpdateDoctorVideo();
  const deleteDoctorVideo = useDeleteDoctorVideo();

  function openCreate() {
    setModal({
      title: "",
      title_en: "",
      description: "",
      description_en: "",
      video_url: "",
      thumbnail_url: "",
      doctor_name: "",
      doctor_specialty: "",
      is_published: true,
    });
  }

  function openEdit(vid: any) {
    setModal({
      ...vid,
      title_en: vid.title_en || "",
      description_en: vid.description_en || "",
      _edit: true,
    });
  }

  async function handleSave() {
    if (!modal) return;
    const payload = {
      title: modal.title.trim(),
      title_en: modal.title_en.trim(),
      description: modal.description.trim(),
      description_en: modal.description_en.trim(),
      video_url: modal.video_url.trim(),
      thumbnail_url: modal.thumbnail_url.trim(),
      doctor_name: modal.doctor_name.trim(),
      doctor_specialty: modal.doctor_specialty.trim(),
      is_published: modal.is_published,
    };

    if (modal._edit) {
      await updateDoctorVideo.mutateAsync({ id: modal.id, ...payload });
    } else {
      await createDoctorVideo.mutateAsync(payload);
    }
    setModal(null);
  }

  async function confirmDelete() {
    if (!deleteTarget) return;
    await deleteDoctorVideo.mutateAsync(deleteTarget.id);
    setDeleteTarget(null);
  }

  const isPending = createDoctorVideo.isPending || updateDoctorVideo.isPending;

  const filteredVideos = videos.filter((vid) => {
    const matchesSearch =
      vid.title?.toLowerCase().includes(search.toLowerCase()) ||
      vid.doctor_name?.toLowerCase().includes(search.toLowerCase()) ||
      vid.doctor_specialty?.toLowerCase().includes(search.toLowerCase());

    if (statusFilter === "all") return matchesSearch;
    if (statusFilter === "published") return matchesSearch && vid.is_published;
    if (statusFilter === "draft") return matchesSearch && !vid.is_published;
    return matchesSearch;
  });

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Doctor Videos</h1>
          <p className="text-sm text-slate-500 mt-1">
            Manage recommended educational videos by doctors for clients
          </p>
        </div>
        <button onClick={openCreate} className="btn-primary">
          <Plus className="h-4 w-4" /> New Video
        </button>
      </div>

      {/* Tabs */}
      <div className="flex items-center gap-1 border-b border-slate-100 pb-px">
        {(["all", "published", "draft"] as const).map((t) => (
          <button
            key={t}
            onClick={() => setStatusFilter(t)}
            className={cn(
              "px-3 py-2 text-sm font-medium rounded-t-lg transition-colors capitalize",
              statusFilter === t
                ? "text-sf-deepNavy border-b-2 border-sf-deepNavy"
                : "text-slate-500 hover:text-slate-700"
            )}
          >
            {t}
          </button>
        ))}
      </div>

      {/* Search */}
      <SearchInput
        value={search}
        onChange={(v) => setSearch(v)}
        placeholder="Search videos, doctors, specialties..."
      />

      {/* Table / List */}
      {isLoading ? (
        <div className="flex justify-center py-20">
          <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
        </div>
      ) : filteredVideos.length === 0 ? (
        <EmptyState
          icon={Video}
          title={search ? "No videos match" : "No videos yet"}
          description={
            search
              ? "Try a different search term"
              : "Publish your first doctor recommendation video to clients."
          }
          action={
            !search ? (
              <button onClick={openCreate} className="btn-primary">
                <Plus className="h-4 w-4" /> New Video
              </button>
            ) : undefined
          }
        />
      ) : (
        <div className="card overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 border-b border-slate-200">
              <tr>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Video</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Doctor & Specialty</th>
                <th className="text-center px-4 py-3 font-semibold text-slate-600">Status</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Created At</th>
                <th className="text-right px-4 py-3 font-semibold text-slate-600">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredVideos.map((vid: any) => (
                <tr key={vid.id} className="hover:bg-slate-50/50">
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-3">
                      {vid.thumbnail_url ? (
                        <img
                          src={vid.thumbnail_url}
                          alt={vid.title}
                          className="h-10 w-16 rounded object-cover bg-slate-100"
                        />
                      ) : (
                        <div className="h-10 w-16 rounded bg-slate-100 flex items-center justify-center">
                          <Video className="h-4 w-4 text-slate-400" />
                        </div>
                      )}
                      <div>
                        <span className="font-medium text-slate-900 block">{vid.title}</span>
                        <span className="text-xs text-slate-500 line-clamp-1">{vid.video_url}</span>
                      </div>
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <span className="font-medium text-slate-900 block">{vid.doctor_name}</span>
                    <span className="text-xs text-slate-500">{vid.doctor_specialty}</span>
                  </td>
                  <td className="px-4 py-3 text-center">
                    <span
                      className={cn(
                        "inline-flex px-2 py-0.5 text-[10px] font-medium rounded-full capitalize",
                        vid.is_published
                          ? "bg-emerald-50 text-emerald-700"
                          : "bg-slate-100 text-slate-600"
                      )}
                    >
                      {vid.is_published ? "Published" : "Draft"}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-slate-500 text-xs">
                    {new Date(vid.created_at).toLocaleDateString("id-ID", {
                      day: "numeric",
                      month: "short",
                      year: "numeric",
                    })}
                  </td>
                  <td className="px-4 py-3 text-right">
                    <div className="flex items-center justify-end gap-1">
                      <button
                        onClick={() => openEdit(vid)}
                        className="p-1.5 rounded hover:bg-slate-100 text-slate-400 hover:text-slate-600"
                        title="Edit"
                      >
                        <Pencil className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() => setDeleteTarget(vid)}
                        className="p-1.5 rounded hover:bg-red-50 text-slate-400 hover:text-red-600"
                        title="Delete"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Modal Form */}
      {modal && (
        <div className="fixed inset-0 z-50 flex items-start justify-center pt-[5vh] overflow-y-auto" onClick={() => setModal(null)}>
          <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" />
          <div
            className="relative bg-white rounded-2xl shadow-xl max-w-2xl w-full mx-4 mb-12 animate-slide-in"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
              <h2 className="text-lg font-semibold text-slate-900">
                {modal._edit ? "Edit Doctor Video" : "New Doctor Video"}
              </h2>
              <button onClick={() => setModal(null)} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400">
                <X className="h-5 w-5" />
              </button>
            </div>

            <form
              onSubmit={(e) => {
                e.preventDefault();
                handleSave();
              }}
              className="p-6 space-y-5 max-h-[75vh] overflow-y-auto"
            >
              {/* Title */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="label">Title (ID) *</label>
                  <input
                    value={modal.title}
                    onChange={(e) => setModal({ ...modal, title: e.target.value })}
                    required
                    className="input"
                    placeholder="e.g. Pentingnya Menjaga Pola Makan Sehat"
                    autoFocus
                  />
                </div>
                <div>
                  <label className="label">Title (EN) *</label>
                  <input
                    value={modal.title_en}
                    onChange={(e) => setModal({ ...modal, title_en: e.target.value })}
                    required
                    className="input"
                    placeholder="e.g. The Importance of Maintaining a Healthy Diet"
                  />
                </div>
              </div>

              {/* Doctor Details */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="label">Doctor Name *</label>
                  <input
                    value={modal.doctor_name}
                    onChange={(e) => setModal({ ...modal, doctor_name: e.target.value })}
                    required
                    className="input"
                    placeholder="e.g. dr. Denny Septiady"
                  />
                </div>
                <div>
                  <label className="label">Specialty *</label>
                  <input
                    value={modal.doctor_specialty}
                    onChange={(e) => setModal({ ...modal, doctor_specialty: e.target.value })}
                    required
                    className="input"
                    placeholder="e.g. Spesialis Gizi Klinik"
                  />
                </div>
              </div>

              {/* Video URL */}
              <div>
                <label className="label">YouTube Video URL *</label>
                <input
                  value={modal.video_url}
                  onChange={(e) => setModal({ ...modal, video_url: e.target.value })}
                  required
                  className="input"
                  placeholder="e.g. https://www.youtube.com/watch?v=..."
                />
              </div>

              {/* Thumbnail Image Upload */}
              <div>
                <label className="label">Video Thumbnail Image</label>
                <ImageUpload
                  value={modal.thumbnail_url}
                  onChange={(url) => setModal({ ...modal, thumbnail_url: url })}
                  entityType="doctor-video"
                  aspectRatio="banner"
                  placeholder="Upload video thumbnail image"
                />
              </div>

              {/* Description */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="label">Description (ID) *</label>
                  <textarea
                    value={modal.description}
                    onChange={(e) => setModal({ ...modal, description: e.target.value })}
                    required
                    className="input font-sans text-sm"
                    rows={4}
                    placeholder="Tulis deskripsi singkat tentang apa yang dibahas dalam video..."
                  />
                </div>
                <div>
                  <label className="label">Description (EN) *</label>
                  <textarea
                    value={modal.description_en}
                    onChange={(e) => setModal({ ...modal, description_en: e.target.value })}
                    required
                    className="input font-sans text-sm"
                    rows={4}
                    placeholder="Write a brief description of what the video covers in English..."
                  />
                </div>
              </div>

              {/* Publish Toggle */}
              <div className="flex items-center gap-3">
                <input
                  type="checkbox"
                  id="is_published"
                  checked={modal.is_published}
                  onChange={(e) => setModal({ ...modal, is_published: e.target.checked })}
                  className="h-4 w-4 rounded border-slate-300 text-sf-deepNavy focus:ring-sf-deepNavy"
                />
                <label htmlFor="is_published" className="text-sm font-medium text-slate-700 selection:bg-transparent cursor-pointer">
                  Publish video immediately (visible to clients)
                </label>
              </div>

              {/* Actions */}
              <div className="flex justify-end gap-3 pt-2">
                <button type="button" onClick={() => setModal(null)} className="btn-secondary">
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={!modal.title.trim() || !modal.title_en.trim() || !modal.description.trim() || !modal.description_en.trim() || !modal.video_url.trim() || !modal.doctor_name.trim() || isPending}
                  className="btn-primary"
                >
                  {isPending ? (
                    <Loader2 className="h-4 w-4 animate-spin" />
                  ) : modal._edit ? (
                    <Pencil className="h-4 w-4" />
                  ) : (
                    <Plus className="h-4 w-4" />
                  )}
                  {isPending ? "Saving..." : modal._edit ? "Update Video" : "Create Video"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Delete Confirmation */}
      <ConfirmDialog
        open={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        onConfirm={confirmDelete}
        title="Delete Doctor Video?"
        description={`Are you sure you want to delete "${deleteTarget?.title}"? This action cannot be undone.`}
        confirmLabel="Delete"
        variant="danger"
        loading={deleteDoctorVideo.isPending}
      />
    </div>
  );
}
