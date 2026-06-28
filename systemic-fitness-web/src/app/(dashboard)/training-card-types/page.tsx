"use client";

import { useState } from "react";
import {
  useTrainerCardTypes,
  useCreateTrainerCardType,
  useUpdateTrainerCardType,
  useDeleteTrainerCardType,
} from "@/hooks/useNewFeatures";
import { EmptyState } from "@/components/shared/EmptyState";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import {
  ClipboardCheck, Plus, X, Loader2, Pencil, Trash2,
} from "lucide-react";
import { cn } from "@/lib/utils";

export default function TrainingCardTypesPage() {
  const { data, isLoading } = useTrainerCardTypes();
  const createType = useCreateTrainerCardType();
  const updateType = useUpdateTrainerCardType();
  const deleteType = useDeleteTrainerCardType();

  const types = (data?.data ?? []) as any[];
  const [modal, setModal] = useState<any | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<any | null>(null);

  function openCreate() {
    setModal({ name: "", description: "", is_active: true, sort_order: 0 });
  }

  function openEdit(t: any) {
    setModal({ ...t, _edit: true });
  }

  async function handleSave() {
    if (!modal) return;
    const payload = {
      name: modal.name,
      description: modal.description || null,
      is_active: modal.is_active,
      sort_order: modal.sort_order,
    };
    if (modal._edit) {
      await updateType.mutateAsync({ id: modal.id, ...payload });
    } else {
      await createType.mutateAsync(payload);
    }
    setModal(null);
  }

  async function confirmDelete() {
    if (!deleteTarget) return;
    await deleteType.mutateAsync(deleteTarget.id);
    setDeleteTarget(null);
  }

  const isPending = createType.isPending || updateType.isPending;

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Training Card Types</h1>
          <p className="text-sm text-slate-500 mt-1">
            Master tipe gerakan untuk Training Card (Isolate, Dynamic, dll.)
          </p>
        </div>
        <button onClick={openCreate} className="btn-primary">
          <Plus className="h-4 w-4" /> Tambah Tipe
        </button>
      </div>

      {/* Table */}
      {isLoading ? (
        <div className="flex justify-center py-20">
          <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
        </div>
      ) : types.length === 0 ? (
        <EmptyState
          icon={ClipboardCheck}
          title="Belum ada tipe"
          description="Buat tipe pertama untuk digunakan di Training Card"
        />
      ) : (
        <div className="card overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 border-b border-slate-200">
              <tr>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Nama</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Deskripsi</th>
                <th className="text-center px-4 py-3 font-semibold text-slate-600">Urutan</th>
                <th className="text-center px-4 py-3 font-semibold text-slate-600">Status</th>
                <th className="text-right px-4 py-3 font-semibold text-slate-600">Aksi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {types.map((t: any) => (
                <tr key={t.id} className="hover:bg-slate-50/50">
                  <td className="px-4 py-3 font-medium text-slate-900">{t.name}</td>
                  <td className="px-4 py-3 text-slate-500">{t.description || "-"}</td>
                  <td className="px-4 py-3 text-center text-slate-500">{t.sort_order}</td>
                  <td className="px-4 py-3 text-center">
                    <span className={cn(
                      "inline-flex px-2 py-0.5 text-xs font-medium rounded-full",
                      t.is_active ? "bg-green-50 text-green-700" : "bg-slate-100 text-slate-500"
                    )}>
                      {t.is_active ? "Aktif" : "Nonaktif"}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-right">
                    <div className="flex items-center justify-end gap-1">
                      <button
                        onClick={() => openEdit(t)}
                        className="p-1.5 rounded hover:bg-slate-100 text-slate-400 hover:text-slate-600"
                        title="Edit"
                      >
                        <Pencil className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() => setDeleteTarget(t)}
                        className="p-1.5 rounded hover:bg-red-50 text-slate-400 hover:text-red-600"
                        title="Hapus"
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

      {/* Create/Edit Modal */}
      {modal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
          <div className="bg-white rounded-xl shadow-xl w-full max-w-md mx-4 p-6 space-y-4">
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-bold text-slate-900">
                {modal._edit ? "Edit Tipe" : "Tambah Tipe"}
              </h2>
              <button onClick={() => setModal(null)} className="p-1 rounded hover:bg-slate-100">
                <X className="h-5 w-5 text-slate-400" />
              </button>
            </div>

            <div className="space-y-3">
              <div>
                <label className="block text-xs font-medium text-slate-600 mb-1">Nama *</label>
                <input
                  value={modal.name}
                  onChange={(e) => setModal({ ...modal, name: e.target.value })}
                  className="input w-full"
                  placeholder="e.g. Isolate, Dynamic"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-slate-600 mb-1">Deskripsi</label>
                <textarea
                  value={modal.description || ""}
                  onChange={(e) => setModal({ ...modal, description: e.target.value })}
                  className="input w-full"
                  rows={2}
                  placeholder="Deskripsi singkat tipe gerakan"
                />
              </div>
              <div className="flex items-center gap-4">
                <div className="flex-1">
                  <label className="block text-xs font-medium text-slate-600 mb-1">Urutan</label>
                  <input
                    type="number"
                    value={modal.sort_order}
                    onChange={(e) => setModal({ ...modal, sort_order: +e.target.value })}
                    className="input w-full"
                  />
                </div>
                <label className="flex items-center gap-2 mt-5 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={modal.is_active}
                    onChange={(e) => setModal({ ...modal, is_active: e.target.checked })}
                    className="rounded"
                  />
                  <span className="text-sm text-slate-700">Aktif</span>
                </label>
              </div>
            </div>

            <div className="flex justify-end gap-2 pt-2">
              <button onClick={() => setModal(null)} className="btn-secondary">Batal</button>
              <button
                onClick={handleSave}
                disabled={!modal.name.trim() || isPending}
                className="btn-primary"
              >
                {isPending && <Loader2 className="h-4 w-4 animate-spin" />}
                {modal._edit ? "Simpan" : "Tambah"}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirmation */}
      <ConfirmDialog
        open={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        onConfirm={confirmDelete}
        title="Hapus Tipe?"
        description={`Apakah Anda yakin ingin menghapus tipe "${deleteTarget?.name}"?`}
        confirmLabel="Hapus"
        variant="danger"
        loading={deleteType.isPending}
      />
    </div>
  );
}
