"use client";

import { useState } from "react";
import {
  usePromotions,
  useCreatePromotion,
  useUpdatePromotion,
  useDeletePromotion,
} from "@/hooks/useNewFeatures";
import { ImageUpload } from "@/components/shared/ImageUpload";
import { EmptyState } from "@/components/shared/EmptyState";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { SearchInput } from "@/components/shared/SearchInput";
import { SearchableSelect } from "@/components/shared/SearchableSelect";
import {
  Image, Plus, X, Loader2, Pencil, Trash2, Calendar, ArrowUpDown,
} from "lucide-react";
import { cn } from "@/lib/utils";

const STATUS_TABS = ["all", "draft", "active", "ended"] as const;

const statusBadge: Record<string, string> = {
  draft: "bg-slate-100 text-slate-600",
  active: "bg-emerald-50 text-emerald-700",
  ended: "bg-red-50 text-red-600",
};

function toLocalDatetime(iso?: string | null) {
  if (!iso) return "";
  const d = new Date(iso);
  const offset = d.getTimezoneOffset() * 60000;
  return new Date(d.getTime() - offset).toISOString().slice(0, 16);
}

function formatDate(iso?: string | null) {
  if (!iso) return "-";
  return new Date(iso).toLocaleDateString("en-US", {
    month: "short", day: "numeric", year: "numeric", hour: "2-digit", minute: "2-digit",
  });
}

export default function BannersPage() {
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [statusFilter, setStatusFilter] = useState<string>("all");
  const [modal, setModal] = useState<any | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<any | null>(null);

  const { data, isLoading } = usePromotions({
    page,
    limit: 20,
    search: search || undefined,
    status: statusFilter !== "all" ? statusFilter : undefined,
  });
  const createPromotion = useCreatePromotion();
  const updatePromotion = useUpdatePromotion();
  const deletePromotion = useDeletePromotion();

  const banners = (data?.data ?? []) as any[];
  const meta = data?.meta;

  function openCreate() {
    setModal({
      title: "",
      description: "",
      badge: "",
      route: "",
      status: "draft",
      start_date: "",
      end_date: "",
      sort_order: 0,
      image_url: null,
      image_id: null,
    });
  }

  function openEdit(b: any) {
    setModal({
      ...b,
      _edit: true,
      start_date: toLocalDatetime(b.start_date),
      end_date: toLocalDatetime(b.end_date),
      image_id: null,
    });
  }

  async function handleSave() {
    if (!modal) return;
    const payload: Record<string, unknown> = {
      title: modal.title.trim(),
      description: modal.description || undefined,
      badge: modal.badge.trim(),
      route: modal.route.trim(),
      status: modal.status,
      start_date: modal.start_date ? new Date(modal.start_date).toISOString() : undefined,
      end_date: modal.end_date ? new Date(modal.end_date).toISOString() : undefined,
      sort_order: modal.sort_order,
    };
    if (modal.image_id) {
      payload.image_id = modal.image_id;
    } else if (modal.image_url) {
      payload.image_url = modal.image_url;
    }
    if (modal._edit) {
      await updatePromotion.mutateAsync({ id: modal.id, ...payload });
    } else {
      await createPromotion.mutateAsync(payload);
    }
    setModal(null);
  }

  async function confirmDelete() {
    if (!deleteTarget) return;
    await deletePromotion.mutateAsync(deleteTarget.id);
    setDeleteTarget(null);
  }

  const isPending = createPromotion.isPending || updatePromotion.isPending;

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Banners</h1>
          <p className="text-sm text-slate-500 mt-1">
            {meta?.total != null
              ? `${meta.total} banners`
              : "Manage promotional banners for mobile app carousel"}
          </p>
        </div>
        <button onClick={openCreate} className="btn-primary">
          <Plus className="h-4 w-4" /> New Banner
        </button>
      </div>

      {/* Status Tabs */}
      <div className="flex items-center gap-1 border-b border-slate-100 pb-px">
        {STATUS_TABS.map((t) => (
          <button
            key={t}
            onClick={() => { setStatusFilter(t); setPage(1); }}
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
        onChange={(v) => { setSearch(v); setPage(1); }}
        placeholder="Search banners..."
      />

      {/* Table */}
      {isLoading ? (
        <div className="flex justify-center py-20">
          <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
        </div>
      ) : banners.length === 0 ? (
        <EmptyState
          icon={Image}
          title={search ? "No banners match" : "No banners yet"}
          description={
            search
              ? "Try a different search term"
              : "Create your first banner to display in the mobile app carousel."
          }
          action={
            !search ? (
              <button onClick={openCreate} className="btn-primary">
                <Plus className="h-4 w-4" /> New Banner
              </button>
            ) : undefined
          }
        />
      ) : (
        <div className="card overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 border-b border-slate-200">
              <tr>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Banner</th>
                <th className="text-center px-4 py-3 font-semibold text-slate-600">Badge</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Route</th>
                <th className="text-center px-4 py-3 font-semibold text-slate-600">Status</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Schedule</th>
                <th className="text-center px-4 py-3 font-semibold text-slate-600">Order</th>
                <th className="text-right px-4 py-3 font-semibold text-slate-600">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {banners.map((b: any) => {
                const badge = statusBadge[b.status] ?? "bg-slate-100 text-slate-600";
                return (
                  <tr key={b.id} className="hover:bg-slate-50/50">
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-3">
                        {b.image_url ? (
                          <img
                            src={b.image_url}
                            alt={b.title}
                            className="h-10 w-20 rounded-lg object-cover bg-slate-100"
                          />
                        ) : (
                          <div className="h-10 w-20 rounded-lg bg-slate-100 flex items-center justify-center">
                            <Image className="h-4 w-4 text-slate-400" />
                          </div>
                        )}
                        <span className="font-medium text-slate-900">{b.title}</span>
                      </div>
                    </td>
                    <td className="px-4 py-3 text-center">
                      {b.badge && (
                        <span className="inline-flex px-2 py-0.5 text-xs font-bold rounded-full bg-amber-50 text-amber-700">
                          {b.badge}
                        </span>
                      )}
                    </td>
                    <td className="px-4 py-3 text-slate-500 font-mono text-xs">{b.route || "-"}</td>
                    <td className="px-4 py-3 text-center">
                      <span className={cn("inline-flex px-2 py-0.5 text-[10px] font-medium rounded-full capitalize", badge)}>
                        {b.status}
                      </span>
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-1 text-xs text-slate-400">
                        <Calendar className="h-3.5 w-3.5" />
                        <span>{formatDate(b.start_date)} — {formatDate(b.end_date)}</span>
                      </div>
                    </td>
                    <td className="px-4 py-3 text-center text-slate-500">{b.sort_order}</td>
                    <td className="px-4 py-3 text-right">
                      <div className="flex items-center justify-end gap-1">
                        <button
                          onClick={() => openEdit(b)}
                          className="p-1.5 rounded hover:bg-slate-100 text-slate-400 hover:text-slate-600"
                          title="Edit"
                        >
                          <Pencil className="h-4 w-4" />
                        </button>
                        <button
                          onClick={() => setDeleteTarget(b)}
                          className="p-1.5 rounded hover:bg-red-50 text-slate-400 hover:text-red-600"
                          title="Delete"
                        >
                          <Trash2 className="h-4 w-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}

      {/* Pagination */}
      {(meta?.total_pages ?? 1) > 1 && (
        <div className="flex justify-center gap-1">
          {Array.from({ length: meta!.total_pages }, (_, i) => i + 1)
            .slice(Math.max(0, page - 3), page + 2)
            .map((p) => (
              <button
                key={p}
                onClick={() => setPage(p)}
                className={cn(
                  "w-8 h-8 rounded-lg text-sm font-medium transition-colors",
                  p === page
                    ? "bg-sf-deepNavy text-white"
                    : "text-slate-500 hover:bg-slate-100"
                )}
              >
                {p}
              </button>
            ))}
        </div>
      )}

      {/* Create/Edit Modal */}
      {modal && (
        <div className="fixed inset-0 z-50 flex items-start justify-center pt-[5vh] overflow-y-auto" onClick={() => setModal(null)}>
          <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" />
          <div
            className="relative bg-white rounded-2xl shadow-xl max-w-2xl w-full mx-4 mb-12 animate-slide-in"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
              <h2 className="text-lg font-semibold text-slate-900">
                {modal._edit ? "Edit Banner" : "New Banner"}
              </h2>
              <button onClick={() => setModal(null)} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400">
                <X className="h-5 w-5" />
              </button>
            </div>

            <form
              onSubmit={(e) => { e.preventDefault(); handleSave(); }}
              className="p-6 space-y-5 max-h-[75vh] overflow-y-auto"
            >
              {/* Image Upload */}
              <div>
                <label className="label">Banner Image</label>
                <ImageUpload
                  value={modal.image_url}
                  onChange={(url, id) => setModal({ ...modal, image_url: url, image_id: id })}
                  entityType="promotion"
                  aspectRatio="banner"
                  placeholder="Upload promotional banner image"
                />
              </div>

              {/* Title */}
              <div>
                <label className="label">Title *</label>
                <input
                  value={modal.title}
                  onChange={(e) => setModal({ ...modal, title: e.target.value })}
                  required
                  className="input"
                  placeholder="e.g. New Year Promo 50% Off"
                  autoFocus
                />
              </div>

              {/* Description */}
              <div>
                <label className="label">Description</label>
                <textarea
                  value={modal.description || ""}
                  onChange={(e) => setModal({ ...modal, description: e.target.value })}
                  className="input"
                  rows={3}
                  placeholder="Optional description for the banner..."
                />
              </div>

              {/* Badge & Route */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="label">Badge *</label>
                  <input
                    value={modal.badge}
                    onChange={(e) => setModal({ ...modal, badge: e.target.value })}
                    required
                    className="input"
                    placeholder="e.g. HOT, NEW, LIMITED"
                  />
                </div>
                <div>
                  <label className="label">Route *</label>
                  <input
                    value={modal.route}
                    onChange={(e) => setModal({ ...modal, route: e.target.value })}
                    required
                    className="input"
                    placeholder="e.g. /challenges, /nutrition"
                  />
                </div>
              </div>

              {/* Status & Sort Order */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="label">Status *</label>
                  <SearchableSelect
                    options={[
                      { value: "draft", label: "Draft" },
                      { value: "active", label: "Active" },
                      { value: "ended", label: "Ended" },
                    ]}
                    value={modal.status}
                    onChange={(v) => setModal({ ...modal, status: v })}
                    placeholder="Select status..."
                  />
                </div>
                <div>
                  <label className="label">Sort Order</label>
                  <input
                    type="number"
                    value={modal.sort_order}
                    onChange={(e) => setModal({ ...modal, sort_order: Number(e.target.value) })}
                    className="input"
                  />
                </div>
              </div>

              {/* Date Range */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="label">Start Date *</label>
                  <input
                    type="datetime-local"
                    value={modal.start_date}
                    onChange={(e) => setModal({ ...modal, start_date: e.target.value })}
                    required
                    className="input"
                  />
                </div>
                <div>
                  <label className="label">End Date *</label>
                  <input
                    type="datetime-local"
                    value={modal.end_date}
                    onChange={(e) => setModal({ ...modal, end_date: e.target.value })}
                    required
                    className="input"
                  />
                </div>
              </div>

              {/* Actions */}
              <div className="flex justify-end gap-3 pt-2">
                <button type="button" onClick={() => setModal(null)} className="btn-secondary">
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={!modal.title.trim() || !modal.badge.trim() || !modal.route.trim() || isPending}
                  className="btn-primary"
                >
                  {isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : modal._edit ? <Pencil className="h-4 w-4" /> : <Plus className="h-4 w-4" />}
                  {isPending ? "Saving..." : modal._edit ? "Update Banner" : "Create Banner"}
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
        title="Delete Banner?"
        description={`Are you sure you want to delete "${deleteTarget?.title}"? This action cannot be undone.`}
        confirmLabel="Delete"
        variant="danger"
        loading={deletePromotion.isPending}
      />
    </div>
  );
}
