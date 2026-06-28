"use client";

import { useState } from "react";
import {
  useSpecificConditions,
  useCreateSpecificCondition,
  useUpdateSpecificCondition,
  useDeleteSpecificCondition,
  useConditionClassifications,
  type SpecificCondition,
} from "@/hooks/useConditionMaster";
import { EmptyState } from "@/components/shared/EmptyState";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { SearchableSelect } from "@/components/shared/SearchableSelect";
import { Stethoscope, Plus, X, Loader2, Pencil, Trash2 } from "lucide-react";
import { cn } from "@/lib/utils";

// SF Phase 1 — Master Kondisi Spesifik per Klasifikasi.
// Dipakai di Phase A Q2 sebagai sub-pilihan setelah klasifikasi dipilih.

type FormState = Partial<SpecificCondition> & { _edit?: boolean };

const SEVERITY_OPTIONS = [
  { value: "", label: "(tidak diset)" },
  { value: "mild", label: "Mild" },
  { value: "moderate", label: "Moderate" },
  { value: "severe", label: "Severe" },
  { value: "monitor", label: "Monitor" },
];

function severityBadgeClass(s?: string | null) {
  switch (s) {
    case "severe":
      return "bg-red-50 text-red-700";
    case "moderate":
      return "bg-amber-50 text-amber-700";
    case "mild":
      return "bg-emerald-50 text-emerald-700";
    case "monitor":
      return "bg-sky-50 text-sky-700";
    default:
      return "bg-slate-100 text-slate-500";
  }
}

export default function SpecificConditionsPage() {
  const [classificationFilter, setClassificationFilter] = useState<string>("");
  const [search, setSearch] = useState("");

  const { data: clsData } = useConditionClassifications(false);
  const classifications = (clsData?.data ?? []) as { id: string; slug: string; label: string }[];

  const { data, isLoading } = useSpecificConditions({
    classification: classificationFilter || undefined,
    includeInactive: true,
  });
  const items = (data?.data ?? []) as SpecificCondition[];
  const filtered = items.filter(
    (s) =>
      !search ||
      s.label.toLowerCase().includes(search.toLowerCase()) ||
      s.slug.toLowerCase().includes(search.toLowerCase()),
  );

  const create = useCreateSpecificCondition();
  const update = useUpdateSpecificCondition();
  const remove = useDeleteSpecificCondition();

  const [modal, setModal] = useState<FormState | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<SpecificCondition | null>(null);

  function openCreate() {
    setModal({
      classification_id: classifications[0]?.id ?? "",
      slug: "",
      label: "",
      description: "",
      severity_default: undefined,
      sort_order: 0,
      is_active: true,
    });
  }

  function openEdit(s: SpecificCondition) {
    setModal({ ...s, _edit: true });
  }

  async function handleSave() {
    if (!modal) return;
    const payload = {
      classification_id: modal.classification_id ?? "",
      slug: modal.slug ?? "",
      label: modal.label ?? "",
      description: modal.description || null,
      severity_default: modal.severity_default || null,
      sort_order: modal.sort_order ?? 0,
      is_active: modal.is_active ?? true,
    };
    if (modal._edit && modal.id) {
      await update.mutateAsync({ id: modal.id, ...payload });
    } else {
      await create.mutateAsync(payload);
    }
    setModal(null);
  }

  async function confirmDelete() {
    if (!deleteTarget) return;
    await remove.mutateAsync(deleteTarget.id);
    setDeleteTarget(null);
  }

  const isPending = create.isPending || update.isPending;
  const classificationOptions = [
    { value: "", label: "Semua klasifikasi" },
    ...classifications.map((c) => ({ value: c.slug, label: c.label })),
  ];
  const classificationIDOptions = classifications.map((c) => ({
    value: c.id,
    label: c.label,
    sublabel: c.slug,
  }));

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Kondisi Spesifik</h1>
          <p className="text-sm text-slate-500 mt-1">
            Sub-pilihan setelah user memilih klasifikasi di Phase A Q2 assessment.
          </p>
        </div>
        <button onClick={openCreate} className="btn-primary" disabled={classifications.length === 0}>
          <Plus className="h-4 w-4" /> Tambah Kondisi
        </button>
      </div>

      <div className="flex items-center gap-3 flex-wrap">
        <input
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Cari kondisi..."
          className="input w-64"
        />
        <div className="w-72">
          <SearchableSelect
            options={classificationOptions}
            value={classificationFilter}
            onChange={(v) => setClassificationFilter(v)}
            placeholder="Filter klasifikasi"
          />
        </div>
      </div>

      {isLoading ? (
        <div className="flex justify-center py-20">
          <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
        </div>
      ) : filtered.length === 0 ? (
        <EmptyState
          icon={Stethoscope}
          title="Belum ada kondisi spesifik"
          description="Tambahkan kondisi spesifik untuk klasifikasi yang sudah ada."
        />
      ) : (
        <div className="card overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 border-b border-slate-200">
              <tr>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Label</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Slug</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Klasifikasi</th>
                <th className="text-center px-4 py-3 font-semibold text-slate-600">Severity</th>
                <th className="text-center px-4 py-3 font-semibold text-slate-600">Urutan</th>
                <th className="text-center px-4 py-3 font-semibold text-slate-600">Status</th>
                <th className="text-right px-4 py-3 font-semibold text-slate-600">Aksi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filtered.map((s) => (
                <tr key={s.id} className="hover:bg-slate-50/50">
                  <td className="px-4 py-3 font-medium text-slate-900">{s.label}</td>
                  <td className="px-4 py-3 text-slate-500 font-mono text-xs">{s.slug}</td>
                  <td className="px-4 py-3 text-slate-600 text-xs">{s.classification_slug}</td>
                  <td className="px-4 py-3 text-center">
                    {s.severity_default ? (
                      <span
                        className={cn(
                          "inline-flex px-2 py-0.5 text-xs font-semibold rounded-full capitalize",
                          severityBadgeClass(s.severity_default),
                        )}
                      >
                        {s.severity_default}
                      </span>
                    ) : (
                      <span className="text-slate-400 text-xs">-</span>
                    )}
                  </td>
                  <td className="px-4 py-3 text-center text-slate-500">{s.sort_order}</td>
                  <td className="px-4 py-3 text-center">
                    <span
                      className={cn(
                        "inline-flex px-2 py-0.5 text-xs font-medium rounded-full",
                        s.is_active ? "bg-green-50 text-green-700" : "bg-slate-100 text-slate-500",
                      )}
                    >
                      {s.is_active ? "Aktif" : "Nonaktif"}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-right">
                    <div className="flex items-center justify-end gap-1">
                      <button
                        onClick={() => openEdit(s)}
                        className="p-1.5 rounded hover:bg-slate-100 text-slate-400 hover:text-slate-600"
                        title="Edit"
                      >
                        <Pencil className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() => setDeleteTarget(s)}
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

      {modal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
          <div className="bg-white rounded-xl shadow-xl w-full max-w-lg mx-4 p-6 space-y-4 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-bold text-slate-900">
                {modal._edit ? "Edit Kondisi Spesifik" : "Tambah Kondisi Spesifik"}
              </h2>
              <button onClick={() => setModal(null)} className="p-1 rounded hover:bg-slate-100">
                <X className="h-5 w-5 text-slate-400" />
              </button>
            </div>

            <div className="space-y-3">
              <div>
                <label className="block text-xs font-medium text-slate-600 mb-1">Klasifikasi *</label>
                <SearchableSelect
                  options={classificationIDOptions}
                  value={modal.classification_id ?? ""}
                  onChange={(v) => setModal({ ...modal, classification_id: v })}
                  placeholder="Pilih klasifikasi..."
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-medium text-slate-600 mb-1">Slug *</label>
                  <input
                    value={modal.slug ?? ""}
                    onChange={(e) => setModal({ ...modal, slug: e.target.value })}
                    className="input w-full font-mono text-xs"
                    placeholder="hipertensi"
                    disabled={modal._edit}
                  />
                </div>
                <div>
                  <label className="block text-xs font-medium text-slate-600 mb-1">Severity</label>
                  <SearchableSelect
                    options={SEVERITY_OPTIONS}
                    value={modal.severity_default ?? ""}
                    onChange={(v) =>
                      setModal({
                        ...modal,
                        severity_default: (v || undefined) as SpecificCondition["severity_default"],
                      })
                    }
                    placeholder="Pilih severity..."
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-medium text-slate-600 mb-1">Label *</label>
                <input
                  value={modal.label ?? ""}
                  onChange={(e) => setModal({ ...modal, label: e.target.value })}
                  className="input w-full"
                  placeholder="e.g. Hipertensi (stadium 1–2)"
                />
              </div>

              <div>
                <label className="block text-xs font-medium text-slate-600 mb-1">Deskripsi</label>
                <textarea
                  value={modal.description ?? ""}
                  onChange={(e) => setModal({ ...modal, description: e.target.value })}
                  className="input w-full"
                  rows={3}
                  placeholder="Deskripsi singkat kondisi..."
                />
              </div>

              <div className="flex items-center gap-4">
                <div className="flex-1">
                  <label className="block text-xs font-medium text-slate-600 mb-1">Urutan</label>
                  <input
                    type="number"
                    value={modal.sort_order ?? 0}
                    onChange={(e) => setModal({ ...modal, sort_order: +e.target.value })}
                    className="input w-full"
                  />
                </div>
                <label className="flex items-center gap-2 mt-5 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={modal.is_active ?? true}
                    onChange={(e) => setModal({ ...modal, is_active: e.target.checked })}
                    className="rounded"
                  />
                  <span className="text-sm text-slate-700">Aktif</span>
                </label>
              </div>
            </div>

            <div className="flex justify-end gap-2 pt-2">
              <button onClick={() => setModal(null)} className="btn-secondary">
                Batal
              </button>
              <button
                onClick={handleSave}
                disabled={
                  !modal.slug?.trim() ||
                  !modal.label?.trim() ||
                  !modal.classification_id ||
                  isPending
                }
                className="btn-primary"
              >
                {isPending && <Loader2 className="h-4 w-4 animate-spin" />}
                {modal._edit ? "Simpan" : "Tambah"}
              </button>
            </div>
          </div>
        </div>
      )}

      <ConfirmDialog
        open={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        onConfirm={confirmDelete}
        title="Hapus Kondisi Spesifik?"
        description={`Apakah Anda yakin ingin menghapus kondisi "${deleteTarget?.label}"?`}
        confirmLabel="Hapus"
        variant="danger"
        loading={remove.isPending}
      />
    </div>
  );
}
