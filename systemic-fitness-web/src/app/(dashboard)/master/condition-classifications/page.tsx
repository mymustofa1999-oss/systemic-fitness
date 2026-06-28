"use client";

import { useState } from "react";
import {
  useConditionClassifications,
  useCreateConditionClassification,
  useUpdateConditionClassification,
  useDeleteConditionClassification,
  type ConditionClassification,
  type FocusPillar,
} from "@/hooks/useConditionMaster";
import { EmptyState } from "@/components/shared/EmptyState";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { SearchableSelect } from "@/components/shared/SearchableSelect";
import { HeartPulse, Plus, X, Loader2, Pencil, Trash2 } from "lucide-react";
import { cn } from "@/lib/utils";

// SF Phase 1 — Master Klasifikasi Kondisi Fisik (5 kategori).
// Reference: SF_Master_Platform_Spec.docx §02 + halaman 168–181.

type FormState = Partial<ConditionClassification> & {
  _edit?: boolean;
  _full_fc?: number;
  _full_cc?: number;
  _full_mc?: number;
  _reset_fc?: number;
  _reset_cc?: number;
  _reset_mc?: number;
};

const PILLAR_OPTIONS: { value: FocusPillar; label: string }[] = [
  { value: "FC", label: "FC — Functional Conditioning" },
  { value: "CC", label: "CC — Cardiorespiratory Conditioning" },
  { value: "MC", label: "MC — Metabolic Conditioning" },
];

function pillarBadgeClass(p: FocusPillar) {
  switch (p) {
    case "FC":
      return "bg-teal-50 text-teal-700";
    case "CC":
      return "bg-blue-50 text-blue-700";
    case "MC":
      return "bg-amber-50 text-amber-700";
  }
}

function formulaToFields(formula: Record<string, number> | undefined) {
  return {
    fc: formula?.FC ?? 0,
    cc: formula?.CC ?? 0,
    mc: formula?.MC ?? 0,
  };
}

function fieldsToFormula(fc: number, cc: number, mc: number): Record<string, number> {
  const out: Record<string, number> = {};
  if (fc > 0) out.FC = fc;
  if (cc > 0) out.CC = cc;
  if (mc > 0) out.MC = mc;
  return out;
}

export default function ConditionClassificationsPage() {
  const { data, isLoading } = useConditionClassifications(true);
  const create = useCreateConditionClassification();
  const update = useUpdateConditionClassification();
  const remove = useDeleteConditionClassification();

  const items = (data?.data ?? []) as ConditionClassification[];
  const [modal, setModal] = useState<FormState | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<ConditionClassification | null>(null);
  const [search, setSearch] = useState("");

  function openCreate() {
    setModal({
      slug: "",
      label: "",
      description: "",
      focus_pillar: "FC",
      sort_order: 0,
      is_active: true,
      _full_fc: 0, _full_cc: 0, _full_mc: 0,
      _reset_fc: 0, _reset_cc: 0, _reset_mc: 0,
    });
  }

  function openEdit(c: ConditionClassification) {
    const f = formulaToFields(c.full_program_formula);
    const r = formulaToFields(c.daily_reset_formula);
    setModal({
      ...c,
      _edit: true,
      _full_fc: f.fc, _full_cc: f.cc, _full_mc: f.mc,
      _reset_fc: r.fc, _reset_cc: r.cc, _reset_mc: r.mc,
    });
  }

  async function handleSave() {
    if (!modal) return;
    const payload = {
      slug: modal.slug ?? "",
      label: modal.label ?? "",
      description: modal.description || null,
      focus_pillar: modal.focus_pillar as FocusPillar,
      full_program_formula: fieldsToFormula(
        modal._full_fc ?? 0, modal._full_cc ?? 0, modal._full_mc ?? 0,
      ),
      daily_reset_formula: fieldsToFormula(
        modal._reset_fc ?? 0, modal._reset_cc ?? 0, modal._reset_mc ?? 0,
      ),
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
  const filtered = items.filter(
    (c) =>
      !search ||
      c.label.toLowerCase().includes(search.toLowerCase()) ||
      c.slug.toLowerCase().includes(search.toLowerCase()),
  );

  const fullSum = (modal?._full_fc ?? 0) + (modal?._full_cc ?? 0) + (modal?._full_mc ?? 0);
  const resetSum = (modal?._reset_fc ?? 0) + (modal?._reset_cc ?? 0) + (modal?._reset_mc ?? 0);

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Klasifikasi Kondisi Fisik</h1>
          <p className="text-sm text-slate-500 mt-1">
            Master 5 klasifikasi induk untuk Phase A assessment & kurasi program (Imun & Inflamasi,
            Renal & Uric, Cardiorespiratory, Metabolic, Musculoskeletal).
          </p>
        </div>
        <button onClick={openCreate} className="btn-primary">
          <Plus className="h-4 w-4" /> Tambah Klasifikasi
        </button>
      </div>

      <div className="flex items-center gap-3">
        <input
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Cari klasifikasi..."
          className="input w-72"
        />
      </div>

      {isLoading ? (
        <div className="flex justify-center py-20">
          <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
        </div>
      ) : filtered.length === 0 ? (
        <EmptyState
          icon={HeartPulse}
          title="Belum ada klasifikasi"
          description="Tambahkan klasifikasi kondisi fisik untuk dipakai di assessment Phase A."
        />
      ) : (
        <div className="card overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 border-b border-slate-200">
              <tr>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Label</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Slug</th>
                <th className="text-center px-4 py-3 font-semibold text-slate-600">Pilar</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Full Program</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Daily Reset</th>
                <th className="text-center px-4 py-3 font-semibold text-slate-600">Urutan</th>
                <th className="text-center px-4 py-3 font-semibold text-slate-600">Status</th>
                <th className="text-right px-4 py-3 font-semibold text-slate-600">Aksi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filtered.map((c) => (
                <tr key={c.id} className="hover:bg-slate-50/50">
                  <td className="px-4 py-3 font-medium text-slate-900">{c.label}</td>
                  <td className="px-4 py-3 text-slate-500 font-mono text-xs">{c.slug}</td>
                  <td className="px-4 py-3 text-center">
                    <span
                      className={cn(
                        "inline-flex px-2 py-0.5 text-xs font-semibold rounded-full",
                        pillarBadgeClass(c.focus_pillar),
                      )}
                    >
                      {c.focus_pillar}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-xs text-slate-600">
                    {Object.entries(c.full_program_formula || {})
                      .map(([k, v]) => `${v} ${k}`)
                      .join(" + ") || "-"}
                  </td>
                  <td className="px-4 py-3 text-xs text-slate-600">
                    {Object.entries(c.daily_reset_formula || {})
                      .map(([k, v]) => `${v} ${k}`)
                      .join(" + ") || "-"}
                  </td>
                  <td className="px-4 py-3 text-center text-slate-500">{c.sort_order}</td>
                  <td className="px-4 py-3 text-center">
                    <span
                      className={cn(
                        "inline-flex px-2 py-0.5 text-xs font-medium rounded-full",
                        c.is_active ? "bg-green-50 text-green-700" : "bg-slate-100 text-slate-500",
                      )}
                    >
                      {c.is_active ? "Aktif" : "Nonaktif"}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-right">
                    <div className="flex items-center justify-end gap-1">
                      <button
                        onClick={() => openEdit(c)}
                        className="p-1.5 rounded hover:bg-slate-100 text-slate-400 hover:text-slate-600"
                        title="Edit"
                      >
                        <Pencil className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() => setDeleteTarget(c)}
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
          <div className="bg-white rounded-xl shadow-xl w-full max-w-xl mx-4 p-6 space-y-4 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-bold text-slate-900">
                {modal._edit ? "Edit Klasifikasi" : "Tambah Klasifikasi"}
              </h2>
              <button onClick={() => setModal(null)} className="p-1 rounded hover:bg-slate-100">
                <X className="h-5 w-5 text-slate-400" />
              </button>
            </div>

            <div className="space-y-3">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-medium text-slate-600 mb-1">Slug *</label>
                  <input
                    value={modal.slug ?? ""}
                    onChange={(e) => setModal({ ...modal, slug: e.target.value })}
                    className="input w-full font-mono text-xs"
                    placeholder="cardiorespiratory"
                    disabled={modal._edit}
                  />
                </div>
                <div>
                  <label className="block text-xs font-medium text-slate-600 mb-1">Pilar Fokus *</label>
                  <SearchableSelect
                    options={PILLAR_OPTIONS}
                    value={modal.focus_pillar ?? "FC"}
                    onChange={(v) => setModal({ ...modal, focus_pillar: v as FocusPillar })}
                    placeholder="Pilih pilar..."
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-medium text-slate-600 mb-1">Label *</label>
                <input
                  value={modal.label ?? ""}
                  onChange={(e) => setModal({ ...modal, label: e.target.value })}
                  className="input w-full"
                  placeholder="e.g. Cardiorespiratory"
                />
              </div>

              <div>
                <label className="block text-xs font-medium text-slate-600 mb-1">Deskripsi</label>
                <textarea
                  value={modal.description ?? ""}
                  onChange={(e) => setModal({ ...modal, description: e.target.value })}
                  className="input w-full"
                  rows={3}
                  placeholder="Deskripsi singkat klasifikasi..."
                />
              </div>

              <div>
                <label className="block text-xs font-medium text-slate-600 mb-1">
                  Formula Full Program (60 menit)
                </label>
                <div className="grid grid-cols-3 gap-2">
                  {(["fc", "cc", "mc"] as const).map((k) => (
                    <div key={k}>
                      <input
                        type="number"
                        min={0}
                        max={60}
                        value={modal[`_full_${k}`] ?? 0}
                        onChange={(e) =>
                          setModal({ ...modal, [`_full_${k}`]: +e.target.value })
                        }
                        className="input w-full"
                        placeholder={k.toUpperCase()}
                      />
                      <p className="text-[10px] text-slate-400 mt-1 text-center uppercase">{k}</p>
                    </div>
                  ))}
                </div>
                <p className={cn(
                  "text-xs mt-1",
                  fullSum === 60 ? "text-green-600" : "text-amber-600",
                )}>
                  Total: {fullSum} menit {fullSum !== 60 ? "(idealnya 60)" : "✓"}
                </p>
              </div>

              <div>
                <label className="block text-xs font-medium text-slate-600 mb-1">
                  Formula Daily Reset (30 menit)
                </label>
                <div className="grid grid-cols-3 gap-2">
                  {(["fc", "cc", "mc"] as const).map((k) => (
                    <div key={k}>
                      <input
                        type="number"
                        min={0}
                        max={30}
                        value={modal[`_reset_${k}`] ?? 0}
                        onChange={(e) =>
                          setModal({ ...modal, [`_reset_${k}`]: +e.target.value })
                        }
                        className="input w-full"
                        placeholder={k.toUpperCase()}
                      />
                      <p className="text-[10px] text-slate-400 mt-1 text-center uppercase">{k}</p>
                    </div>
                  ))}
                </div>
                <p className={cn(
                  "text-xs mt-1",
                  resetSum === 30 ? "text-green-600" : "text-amber-600",
                )}>
                  Total: {resetSum} menit {resetSum !== 30 ? "(idealnya 30)" : "✓"}
                </p>
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
                disabled={!modal.slug?.trim() || !modal.label?.trim() || isPending}
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
        title="Hapus Klasifikasi?"
        description={`Apakah Anda yakin ingin menghapus klasifikasi "${deleteTarget?.label}"? Aksi ini akan gagal jika masih ada kondisi spesifik yang merujuk klasifikasi ini.`}
        confirmLabel="Hapus"
        variant="danger"
        loading={remove.isPending}
      />
    </div>
  );
}
