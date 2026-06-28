"use client";

import { useState } from "react";
import {
  useHealthArticles,
  useCreateHealthArticle,
  useUpdateHealthArticle,
  useDeleteHealthArticle,
} from "@/hooks/useHealthContent";
import { ImageUpload } from "@/components/shared/ImageUpload";
import { EmptyState } from "@/components/shared/EmptyState";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { SearchInput } from "@/components/shared/SearchInput";
import { Megaphone, Plus, X, Loader2, Pencil, Trash2 } from "lucide-react";
import { cn } from "@/lib/utils";

export default function HealthNewsPage() {
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState<"all" | "published" | "draft">("all");
  const [modal, setModal] = useState<any | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<any | null>(null);

  const { data, isLoading } = useHealthArticles();
  const articles = (data?.data ?? []) as any[];
  const createHealthArticle = useCreateHealthArticle();
  const updateHealthArticle = useUpdateHealthArticle();
  const deleteHealthArticle = useDeleteHealthArticle();

  function openCreate() {
    setModal({
      title: "",
      title_en: "",
      content: "",
      content_en: "",
      image_url: "",
      source: "",
      is_published: true,
    });
  }

  function openEdit(art: any) {
    setModal({
      ...art,
      title_en: art.title_en || "",
      content_en: art.content_en || "",
      _edit: true,
    });
  }

  async function handleSave() {
    if (!modal) return;
    const payload = {
      title: modal.title.trim(),
      title_en: modal.title_en.trim(),
      content: modal.content.trim(),
      content_en: modal.content_en.trim(),
      image_url: modal.image_url.trim(),
      source: modal.source.trim() || "Systemic Fitness",
      is_published: modal.is_published,
    };

    if (modal._edit) {
      await updateHealthArticle.mutateAsync({ id: modal.id, ...payload });
    } else {
      await createHealthArticle.mutateAsync(payload);
    }
    setModal(null);
  }

  async function confirmDelete() {
    if (!deleteTarget) return;
    await deleteHealthArticle.mutateAsync(deleteTarget.id);
    setDeleteTarget(null);
  }

  const isPending = createHealthArticle.isPending || updateHealthArticle.isPending;

  const filteredArticles = articles.filter((art) => {
    const matchesSearch =
      art.title?.toLowerCase().includes(search.toLowerCase()) ||
      art.source?.toLowerCase().includes(search.toLowerCase());

    if (statusFilter === "all") return matchesSearch;
    if (statusFilter === "published") return matchesSearch && art.is_published;
    if (statusFilter === "draft") return matchesSearch && !art.is_published;
    return matchesSearch;
  });

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Health News</h1>
          <p className="text-sm text-slate-500 mt-1">
            Manage articles and news about health and fitness for clients
          </p>
        </div>
        <button onClick={openCreate} className="btn-primary">
          <Plus className="h-4 w-4" /> New Article
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
        placeholder="Search articles..."
      />

      {/* Table / List */}
      {isLoading ? (
        <div className="flex justify-center py-20">
          <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
        </div>
      ) : filteredArticles.length === 0 ? (
        <EmptyState
          icon={Megaphone}
          title={search ? "No articles match" : "No articles yet"}
          description={
            search
              ? "Try a different search term"
              : "Create your first health article to publish to clients."
          }
          action={
            !search ? (
              <button onClick={openCreate} className="btn-primary">
                <Plus className="h-4 w-4" /> New Article
              </button>
            ) : undefined
          }
        />
      ) : (
        <div className="card overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 border-b border-slate-200">
              <tr>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Article</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Source</th>
                <th className="text-center px-4 py-3 font-semibold text-slate-600">Status</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Created At</th>
                <th className="text-right px-4 py-3 font-semibold text-slate-600">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredArticles.map((art: any) => (
                <tr key={art.id} className="hover:bg-slate-50/50">
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-3">
                      {art.image_url ? (
                        <img
                          src={art.image_url}
                          alt={art.title}
                          className="h-10 w-16 rounded object-cover bg-slate-100"
                        />
                      ) : (
                        <div className="h-10 w-16 rounded bg-slate-100 flex items-center justify-center">
                          <Megaphone className="h-4 w-4 text-slate-400" />
                        </div>
                      )}
                      <div>
                        <span className="font-medium text-slate-900 block">{art.title}</span>
                        <span className="text-xs text-slate-500 line-clamp-1">{art.content}</span>
                      </div>
                    </div>
                  </td>
                  <td className="px-4 py-3 text-slate-600 font-medium">{art.source}</td>
                  <td className="px-4 py-3 text-center">
                    <span
                      className={cn(
                        "inline-flex px-2 py-0.5 text-[10px] font-medium rounded-full capitalize",
                        art.is_published
                          ? "bg-emerald-50 text-emerald-700"
                          : "bg-slate-100 text-slate-600"
                      )}
                    >
                      {art.is_published ? "Published" : "Draft"}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-slate-500 text-xs">
                    {new Date(art.created_at).toLocaleDateString("id-ID", {
                      day: "numeric",
                      month: "short",
                      year: "numeric",
                    })}
                  </td>
                  <td className="px-4 py-3 text-right">
                    <div className="flex items-center justify-end gap-1">
                      <button
                        onClick={() => openEdit(art)}
                        className="p-1.5 rounded hover:bg-slate-100 text-slate-400 hover:text-slate-600"
                        title="Edit"
                      >
                        <Pencil className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() => setDeleteTarget(art)}
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
                {modal._edit ? "Edit Health Article" : "New Health Article"}
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
                    placeholder="e.g. Manfaat Hidrasi untuk Performa Otot"
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
                    placeholder="e.g. Benefits of Hydration for Muscle Performance"
                  />
                </div>
              </div>

              {/* Source */}
              <div>
                <label className="label">Source *</label>
                <input
                  value={modal.source}
                  onChange={(e) => setModal({ ...modal, source: e.target.value })}
                  required
                  className="input"
                  placeholder="e.g. Kemenkes RI, dr. Denny, etc."
                />
              </div>

              {/* Image Upload */}
              <div>
                <label className="label">Article Image</label>
                <ImageUpload
                  value={modal.image_url}
                  onChange={(url) => setModal({ ...modal, image_url: url })}
                  entityType="health-news"
                  aspectRatio="banner"
                  placeholder="Upload article main image"
                />
              </div>

              {/* Content */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="label">Content (ID) *</label>
                  <textarea
                    value={modal.content}
                    onChange={(e) => setModal({ ...modal, content: e.target.value })}
                    required
                    className="input font-sans text-sm"
                    rows={8}
                    placeholder="Tulis konten lengkap artikel kesehatan di sini..."
                  />
                </div>
                <div>
                  <label className="label">Content (EN) *</label>
                  <textarea
                    value={modal.content_en}
                    onChange={(e) => setModal({ ...modal, content_en: e.target.value })}
                    required
                    className="input font-sans text-sm"
                    rows={8}
                    placeholder="Write the full content of the health article in English here..."
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
                  Publish article immediately (visible to clients)
                </label>
              </div>

              {/* Actions */}
              <div className="flex justify-end gap-3 pt-2">
                <button type="button" onClick={() => setModal(null)} className="btn-secondary">
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={!modal.title.trim() || !modal.title_en.trim() || !modal.content.trim() || !modal.content_en.trim() || isPending}
                  className="btn-primary"
                >
                  {isPending ? (
                    <Loader2 className="h-4 w-4 animate-spin" />
                  ) : modal._edit ? (
                    <Pencil className="h-4 w-4" />
                  ) : (
                    <Plus className="h-4 w-4" />
                  )}
                  {isPending ? "Saving..." : modal._edit ? "Update Article" : "Create Article"}
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
        title="Delete Health Article?"
        description={`Are you sure you want to delete "${deleteTarget?.title}"? This action cannot be undone.`}
        confirmLabel="Delete"
        variant="danger"
        loading={deleteHealthArticle.isPending}
      />
    </div>
  );
}
