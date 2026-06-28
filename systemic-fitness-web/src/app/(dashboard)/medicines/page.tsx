"use client";

import { useState } from "react";
import { useMedicines, useCreateMedicine, useUpdateMedicine, useDeleteMedicine } from "@/hooks/useNewFeatures";
import { EmptyState } from "@/components/shared/EmptyState";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { SearchInput } from "@/components/shared/SearchInput";
import { ImageUpload } from "@/components/shared/ImageUpload";
import {
  Pill, Plus, X, Loader2, Pencil, Trash2, MoreVertical,
  ExternalLink, AlertTriangle, ChevronLeft, ChevronRight,
} from "lucide-react";
import { cn } from "@/lib/utils";

function getPageNumbers(current: number, total: number): (number | "...")[] {
  if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1);
  const pages: (number | "...")[] = [1];
  if (current > 3) pages.push("...");
  const start = Math.max(2, current - 1);
  const end = Math.min(total - 1, current + 1);
  for (let i = start; i <= end; i++) pages.push(i);
  if (current < total - 2) pages.push("...");
  pages.push(total);
  return pages;
}

export default function MedicinesPage() {
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [categoryFilter, setCategoryFilter] = useState("");
  const [modalMedicine, setModalMedicine] = useState<any | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<any | null>(null);
  const [menuOpen, setMenuOpen] = useState<string | null>(null);
  const [expandedId, setExpandedId] = useState<string | null>(null);

  const params: Record<string, unknown> = { page, limit: 20, search };
  if (categoryFilter) params.category = categoryFilter;

  const { data, isLoading } = useMedicines(params);
  const deleteMedicine = useDeleteMedicine();
  const medicines = (data?.data ?? []) as any[];
  const meta = data?.meta;

  function openCreate() {
    setModalMedicine({});
  }

  function openEdit(med: any) {
    setMenuOpen(null);
    setModalMedicine(med);
  }

  function openDelete(med: any) {
    setMenuOpen(null);
    setDeleteTarget(med);
  }

  async function confirmDelete() {
    if (!deleteTarget) return;
    await deleteMedicine.mutateAsync(deleteTarget.id);
    setDeleteTarget(null);
  }

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Daftar Obat</h1>
          <p className="text-sm text-slate-500 mt-1">
            {meta?.total != null ? `${meta.total} obat terdaftar` : "Master data referensi obat & suplemen"}
          </p>
        </div>
        <button onClick={openCreate} className="btn-primary">
          <Plus className="h-4 w-4" /> Tambah Obat
        </button>
      </div>

      {/* Search & Filter */}
      <div className="flex items-center gap-3">
        <div className="flex-1">
          <SearchInput
            value={search}
            onChange={(v) => { setSearch(v); setPage(1); }}
            placeholder="Cari nama obat, golongan, atau fungsi..."
          />
        </div>
        <input
          value={categoryFilter}
          onChange={(e) => { setCategoryFilter(e.target.value); setPage(1); }}
          className="input w-64"
          placeholder="Filter golongan..."
        />
      </div>

      {/* Table */}
      {isLoading ? (
        <div className="space-y-3">
          {Array.from({ length: 8 }).map((_, i) => (
            <div key={i} className="card p-4">
              <div className="flex gap-4">
                <div className="skeleton h-5 w-48" />
                <div className="skeleton h-5 w-40" />
                <div className="skeleton h-5 w-32 ml-auto" />
              </div>
            </div>
          ))}
        </div>
      ) : medicines.length === 0 ? (
        <EmptyState
          icon={Pill}
          title={search || categoryFilter ? "Tidak ditemukan" : "Belum ada data obat"}
          description={search || categoryFilter ? "Coba kata kunci lain" : "Tambahkan data obat untuk referensi klien."}
          action={!search && !categoryFilter ? (
            <button onClick={openCreate} className="btn-primary">
              <Plus className="h-4 w-4" /> Tambah Obat
            </button>
          ) : undefined}
        />
      ) : (
        <div className="card overflow-hidden">
          <table className="w-full">
            <thead>
              <tr className="border-b border-slate-100 bg-slate-50/50">
                <th className="text-left px-4 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wider w-16">Gambar</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wider">Nama Obat</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wider">Golongan</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wider">Fungsi Utama</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wider w-20">Link</th>
                <th className="w-12" />
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-50">
              {medicines.map((med: any) => (
                <MedicineRow
                  key={med.id}
                  med={med}
                  expanded={expandedId === med.id}
                  onToggle={() => setExpandedId(expandedId === med.id ? null : med.id)}
                  menuOpen={menuOpen === med.id}
                  onMenuToggle={() => setMenuOpen(menuOpen === med.id ? null : med.id)}
                  onMenuClose={() => setMenuOpen(null)}
                  onEdit={() => openEdit(med)}
                  onDelete={() => openDelete(med)}
                />
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Pagination — matching DataTable style */}
      {meta && (
        <div className="flex items-center justify-between px-4 py-3">
          <p className="text-xs text-slate-500">
            {meta.total === 0
              ? "No data"
              : `Showing ${(page - 1) * 20 + 1}–${Math.min(page * 20, meta.total)} of ${meta.total}`}
          </p>
          {meta.total_pages > 1 && (
            <div className="flex items-center gap-1">
              <button type="button" className="p-1.5 rounded-lg text-slate-500 hover:bg-slate-100 disabled:opacity-30 transition-colors" disabled={page <= 1} onClick={() => setPage(page - 1)}>
                <ChevronLeft className="h-4 w-4" />
              </button>
              {getPageNumbers(page, meta.total_pages).map((p, i) =>
                p === "..." ? (
                  <span key={`dots-${i}`} className="px-1.5 text-xs text-slate-400 select-none">...</span>
                ) : (
                  <button key={p} type="button" onClick={() => setPage(p as number)}
                    className={cn("min-w-[32px] h-8 rounded-lg text-xs font-medium transition-colors",
                      p === page ? "bg-sf-deepNavy text-white shadow-sm" : "text-slate-600 hover:bg-slate-100"
                    )}>{p}</button>
                )
              )}
              <button type="button" className="p-1.5 rounded-lg text-slate-500 hover:bg-slate-100 disabled:opacity-30 transition-colors" disabled={page >= meta.total_pages} onClick={() => setPage(page + 1)}>
                <ChevronRight className="h-4 w-4" />
              </button>
            </div>
          )}
        </div>
      )}

      {/* Create / Edit Modal */}
      {modalMedicine !== null && (
        <MedicineFormModal
          medicine={modalMedicine.id ? modalMedicine : null}
          onClose={() => setModalMedicine(null)}
        />
      )}

      {/* Delete Confirm */}
      <ConfirmDialog
        open={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        onConfirm={confirmDelete}
        title="Hapus Obat"
        description={`Apakah Anda yakin ingin menghapus "${deleteTarget?.name}"? Tindakan ini tidak dapat dibatalkan.`}
        confirmLabel="Hapus"
        variant="danger"
        loading={deleteMedicine.isPending}
      />
    </div>
  );
}

// ── Medicine Row ────────────────────────────────────────────────

interface MedicineRowProps {
  med: any;
  expanded: boolean;
  onToggle: () => void;
  menuOpen: boolean;
  onMenuToggle: () => void;
  onMenuClose: () => void;
  onEdit: () => void;
  onDelete: () => void;
}

function MedicineRow({ med, expanded, onToggle, menuOpen, onMenuToggle, onMenuClose, onEdit, onDelete }: MedicineRowProps) {
  return (
    <>
      <tr
        onClick={onToggle}
        className="hover:bg-slate-50/80 cursor-pointer transition-colors"
      >
        <td className="px-4 py-3">
          <div className="h-10 w-10 rounded-lg bg-slate-50 flex items-center justify-center overflow-hidden border border-slate-100">
            {med.image_url ? (
              <img src={med.image_url} alt={med.name} className="h-full w-full object-cover" />
            ) : (
              <Pill className="h-4 w-4 text-slate-300" />
            )}
          </div>
        </td>
        <td className="px-4 py-3">
          <span className="font-medium text-slate-900 text-sm">{med.name}</span>
        </td>
        <td className="px-4 py-3">
          {med.category ? (
            <span className="inline-block px-2 py-0.5 rounded-md bg-indigo-50 text-indigo-700 text-xs font-medium">
              {med.category}
            </span>
          ) : (
            <span className="text-xs text-slate-300">-</span>
          )}
        </td>
        <td className="px-4 py-3 text-sm text-slate-600 max-w-xs truncate">
          {med.main_function || <span className="text-slate-300">-</span>}
        </td>
        <td className="px-4 py-3">
          {med.detail_url ? (
            <a
              href={med.detail_url}
              target="_blank"
              rel="noopener noreferrer"
              onClick={(e) => e.stopPropagation()}
              className="text-sf-deepNavy hover:text-sf-deepNavy transition-colors"
            >
              <ExternalLink className="h-4 w-4" />
            </a>
          ) : (
            <span className="text-slate-300">-</span>
          )}
        </td>
        <td className="px-4 py-3 relative">
          <button
            onClick={(e) => { e.stopPropagation(); onMenuToggle(); }}
            className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400 transition-colors"
          >
            <MoreVertical className="h-4 w-4" />
          </button>
          {menuOpen && (
            <>
              <div className="fixed inset-0 z-10" onClick={onMenuClose} />
              <div className="absolute right-4 top-10 bg-white rounded-lg shadow-lg border border-slate-100 py-1 min-w-[140px] z-20">
                <button
                  onClick={(e) => { e.stopPropagation(); onEdit(); }}
                  className="w-full px-3 py-2 text-left text-sm text-slate-700 hover:bg-slate-50 flex items-center gap-2"
                >
                  <Pencil className="h-3.5 w-3.5" /> Edit
                </button>
                <button
                  onClick={(e) => { e.stopPropagation(); onDelete(); }}
                  className="w-full px-3 py-2 text-left text-sm text-rose-600 hover:bg-rose-50 flex items-center gap-2"
                >
                  <Trash2 className="h-3.5 w-3.5" /> Hapus
                </button>
              </div>
            </>
          )}
        </td>
      </tr>

      {/* Expanded: Side Effects */}
      {expanded && med.side_effects && (
        <tr className="bg-amber-50/40">
          <td colSpan={6} className="px-4 py-3">
            <div className="flex gap-2 items-start">
              <AlertTriangle className="h-4 w-4 text-amber-500 shrink-0 mt-0.5" />
              <div>
                <p className="text-xs font-semibold text-amber-700 mb-1">Efek Samping</p>
                <p className="text-sm text-slate-600 whitespace-pre-line leading-relaxed">{med.side_effects}</p>
              </div>
            </div>
          </td>
        </tr>
      )}
    </>
  );
}

// ── Create / Edit Form Modal ────────────────────────────────────

interface MedicineFormModalProps {
  medicine: any | null;
  onClose: () => void;
}

function MedicineFormModal({ medicine, onClose }: MedicineFormModalProps) {
  const isEdit = !!medicine?.id;
  const createMedicine = useCreateMedicine();
  const updateMedicine = useUpdateMedicine();
  const saving = createMedicine.isPending || updateMedicine.isPending;

  const [name, setName] = useState(medicine?.name ?? "");
  const [category, setCategory] = useState(medicine?.category ?? "");
  const [mainFunction, setMainFunction] = useState(medicine?.main_function ?? "");
  const [sideEffects, setSideEffects] = useState(medicine?.side_effects ?? "");
  const [detailUrl, setDetailUrl] = useState(medicine?.detail_url ?? "");
  const [imageUrl, setImageUrl] = useState<string | null>(medicine?.image_url ?? null);
  const [imageId, setImageId] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim()) return;

    const payload: Record<string, unknown> = {
      name: name.trim(),
      category: category.trim() || undefined,
      main_function: mainFunction.trim() || undefined,
      side_effects: sideEffects.trim() || undefined,
      detail_url: detailUrl.trim() || undefined,
      image_id: imageId || undefined,
      image_url: imageUrl || undefined,
    };

    if (isEdit) {
      await updateMedicine.mutateAsync({ id: medicine.id, ...payload });
    } else {
      await createMedicine.mutateAsync(payload);
    }
    onClose();
  }

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center pt-[5vh] overflow-y-auto" onClick={onClose}>
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" />
      <div className="relative bg-white rounded-2xl shadow-xl max-w-2xl w-full mx-4 mb-12 animate-slide-in" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
          <h2 className="text-lg font-semibold text-slate-900">
            {isEdit ? "Edit Obat" : "Tambah Obat"}
          </h2>
          <button onClick={onClose} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400">
            <X className="h-5 w-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-5 max-h-[75vh] overflow-y-auto">
          {/* Image Upload */}
          <div>
            <label className="label">Gambar Obat</label>
            <ImageUpload
              value={imageUrl}
              onChange={(url, id) => { setImageUrl(url); setImageId(id); }}
              entityType="medicine"
              entityId={medicine?.id}
              aspectRatio="video"
              placeholder="Upload gambar obat"
            />
          </div>

          <div>
            <label className="label">Nama Obat *</label>
            <input
              value={name}
              onChange={(e) => setName(e.target.value)}
              required
              className="input"
              placeholder="e.g. Allopurinol"
              autoFocus
            />
          </div>

          <div>
            <label className="label">Golongan / Kandungan</label>
            <input
              value={category}
              onChange={(e) => setCategory(e.target.value)}
              className="input"
              placeholder="e.g. Penghambat xanthine-oxidase"
            />
          </div>

          <div>
            <label className="label">Fungsi Utama</label>
            <textarea
              value={mainFunction}
              onChange={(e) => setMainFunction(e.target.value)}
              className="input"
              rows={2}
              placeholder="e.g. Asam Urat, Batu Ginjal"
            />
          </div>

          <div>
            <label className="label">Efek Samping</label>
            <textarea
              value={sideEffects}
              onChange={(e) => setSideEffects(e.target.value)}
              className="input"
              rows={4}
              placeholder="e.g. Sakit perut, Mual, Muntah, Diare..."
            />
          </div>

          <div>
            <label className="label">Link Referensi</label>
            <input
              value={detailUrl}
              onChange={(e) => setDetailUrl(e.target.value)}
              className="input"
              type="url"
              placeholder="https://www.alodokter.com/..."
            />
          </div>

          <div className="flex justify-end gap-3 pt-2">
            <button type="button" onClick={onClose} className="btn-secondary">Batal</button>
            <button type="submit" disabled={saving || !name.trim()} className="btn-primary">
              {saving ? <Loader2 className="h-4 w-4 animate-spin" /> : isEdit ? <Pencil className="h-4 w-4" /> : <Plus className="h-4 w-4" />}
              {saving ? "Menyimpan..." : isEdit ? "Simpan Perubahan" : "Tambah Obat"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
