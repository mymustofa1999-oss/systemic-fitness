"use client";

import { useState } from "react";
import { useAuth } from "@/hooks/useAuth";
import {
  useMedicines,
  useCreateMedicine,
  useUpdateMedicine,
  useDeleteMedicine,
  useToggleMedicineActive,
} from "@/hooks/useNewFeatures";
import { EmptyState } from "@/components/shared/EmptyState";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import {
  Pill, Plus, X, Loader2, Pencil, Trash2, Search,
  Power, PowerOff, Eye, ChevronDown,
} from "lucide-react";
import { cn } from "@/lib/utils";

const CATEGORIES = [
  { value: "", label: "All Categories" },
  { value: "suplemen", label: "Supplement" },
  { value: "obat_resep", label: "Prescription Medicine" },
  { value: "herbal", label: "Herbal" },
  { value: "vitamin", label: "Vitamin" },
  { value: "mineral", label: "Mineral" },
  { value: "lainnya", label: "Others" },
];

const FLAG_LEVELS = [
  { value: "", label: "— None —" },
  { value: "green", label: "🟢 Safe (Green)" },
  { value: "yellow", label: "🟡 Warning (Yellow)" },
  { value: "red", label: "🔴 Dangerous (Red)" },
];

const FLAG_COLORS: Record<string, string> = {
  green: "bg-emerald-100 text-emerald-700 border border-emerald-200",
  yellow: "bg-amber-100 text-amber-700 border border-amber-200",
  red: "bg-red-100 text-red-700 border border-red-200",
};

const FLAG_LABELS: Record<string, string> = {
  green: "🟢 Safe",
  yellow: "🟡 Warning",
  red: "🔴 Dangerous",
};

const STATUS_FILTER = [
  { value: "", label: "All Status" },
  { value: "true", label: "Active" },
  { value: "false", label: "Inactive" },
];

type ModalMode = "create" | "edit" | "view";

interface MedicineForm {
  id?: string;
  name: string;
  category: string;
  main_function: string;
  side_effects: string;
  detail_url: string;
  image_url: string;
  is_active: boolean;
  active_ingredient: string;
  exercise_implications: string;
  exercise_adjustments: string;
  flag_level: string;
  _mode: ModalMode;
}

export default function MedicinesPage() {
  const [search, setSearch] = useState("");
  const [category, setCategory] = useState("");
  const [statusFilter, setStatusFilter] = useState("");

  const params: Record<string, unknown> = { limit: 100 };
  if (search) params.search = search;
  if (category) params.category = category;
  if (statusFilter !== "") params.is_active = statusFilter;

  const { data, isLoading } = useMedicines(params);
  const createMedicine = useCreateMedicine();
  const updateMedicine = useUpdateMedicine();
  const deleteMedicine = useDeleteMedicine();
  const toggleActive = useToggleMedicineActive();

  const { isTrainer } = useAuth();
  const canEdit = !isTrainer; // admin & consultant may edit; trainer is view-only

  const medicines = ((data as any)?.data ?? []) as any[];

  const [modal, setModal] = useState<MedicineForm | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<any | null>(null);

  function emptyForm(): MedicineForm {
    return {
      name: "",
      category: "",
      main_function: "",
      side_effects: "",
      detail_url: "",
      image_url: "",
      is_active: true,
      active_ingredient: "",
      exercise_implications: "",
      exercise_adjustments: "",
      flag_level: "",
      _mode: "create",
    };
  }

  function openCreate() {
    setModal(emptyForm());
  }

  function openEdit(m: any) {
    setModal({
      id: m.id,
      name: m.name || "",
      category: m.category || "",
      main_function: m.main_function || "",
      side_effects: m.side_effects || "",
      detail_url: m.detail_url || "",
      image_url: m.image_url || "",
      is_active: m.is_active ?? true,
      active_ingredient: m.active_ingredient || "",
      exercise_implications: m.exercise_implications || "",
      exercise_adjustments: m.exercise_adjustments || "",
      flag_level: m.flag_level || "",
      _mode: "edit",
    });
  }

  function openView(m: any) {
    setModal({
      id: m.id,
      name: m.name || "",
      category: m.category || "",
      main_function: m.main_function || "",
      side_effects: m.side_effects || "",
      detail_url: m.detail_url || "",
      image_url: m.image_url || "",
      is_active: m.is_active ?? true,
      active_ingredient: m.active_ingredient || "",
      exercise_implications: m.exercise_implications || "",
      exercise_adjustments: m.exercise_adjustments || "",
      flag_level: m.flag_level || "",
      _mode: "view",
    });
  }

  async function handleSave() {
    if (!modal) return;
    const payload = {
      name: modal.name.trim(),
      category: modal.category || null,
      main_function: modal.main_function || null,
      side_effects: modal.side_effects || null,
      detail_url: modal.detail_url || null,
      image_url: modal.image_url || null,
      is_active: modal.is_active,
      active_ingredient: modal.active_ingredient || null,
      exercise_implications: modal.exercise_implications || null,
      exercise_adjustments: modal.exercise_adjustments || null,
      flag_level: modal.flag_level || null,
    };

    if (modal._mode === "edit" && modal.id) {
      await updateMedicine.mutateAsync({ id: modal.id, ...payload });
    } else {
      await createMedicine.mutateAsync(payload);
    }
    setModal(null);
  }

  async function confirmDelete() {
    if (!deleteTarget) return;
    await deleteMedicine.mutateAsync(deleteTarget.id);
    setDeleteTarget(null);
  }

  async function handleToggleActive(m: any) {
    await toggleActive.mutateAsync(m.id);
  }

  const isSaving = createMedicine.isPending || updateMedicine.isPending;
  const isReadonly = modal?._mode === "view";

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Medicines</h1>
          <p className="text-sm text-slate-500 mt-1">
            List of medicines and supplements with exercise implications for trainer reference
          </p>
        </div>
        {canEdit && (
          <button
            onClick={openCreate}
            className="flex items-center gap-2 px-4 py-2 bg-sf-deepNavy text-white text-sm font-medium rounded-lg hover:bg-sf-deepNavy/90 transition-colors shadow-sm"
          >
            <Plus className="h-4 w-4" />
            Add Medicine
          </button>
        )}
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-3">
        <div className="relative flex-1 min-w-[200px]">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search medicine name..."
            className="w-full pl-9 pr-4 py-2 text-sm border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-sf-deepNavy/20 focus:border-sf-deepNavy"
          />
        </div>
        <div className="relative">
          <select
            value={category}
            onChange={(e) => setCategory(e.target.value)}
            className="appearance-none pl-3 pr-8 py-2 text-sm border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-sf-deepNavy/20 focus:border-sf-deepNavy text-slate-700 bg-white"
          >
            {CATEGORIES.map((c) => (
              <option key={c.value} value={c.value}>{c.label}</option>
            ))}
          </select>
          <ChevronDown className="absolute right-2 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400 pointer-events-none" />
        </div>
        <div className="relative">
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="appearance-none pl-3 pr-8 py-2 text-sm border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-sf-deepNavy/20 focus:border-sf-deepNavy text-slate-700 bg-white"
          >
            {STATUS_FILTER.map((s) => (
              <option key={s.value} value={s.value}>{s.label}</option>
            ))}
          </select>
          <ChevronDown className="absolute right-2 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400 pointer-events-none" />
        </div>
      </div>

      {/* Table */}
      {isLoading ? (
        <div className="flex justify-center py-16">
          <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
        </div>
      ) : medicines.length === 0 ? (
        <EmptyState
          icon={Pill}
          title="No medicines available"
          description="Add your first medicine to start managing the reference list"
          action={
            <button onClick={openCreate} className="btn-primary">
              <Plus className="h-4 w-4" /> Add Medicine
            </button>
          }
        />
      ) : (
        <div className="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 border-b border-slate-200">
              <tr>
                <th className="text-left px-4 py-3 font-semibold text-slate-600 w-[30%]">Medicine Name</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600 w-[15%]">Category</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600 w-[20%]">Active Ingredient</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600 w-[12%]">Flag</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600 w-[10%]">Status</th>
                <th className="text-right px-4 py-3 font-semibold text-slate-600 w-[13%]">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {medicines.map((m: any) => (
                <tr key={m.id} className={cn("hover:bg-slate-50/60 transition-colors", !m.is_active && "opacity-60")}>
                  <td className="px-4 py-3">
                    <div className="font-medium text-slate-800">{m.name}</div>
                    {m.main_function && (
                      <div className="text-[11px] text-slate-400 truncate max-w-[240px] mt-0.5">{m.main_function}</div>
                    )}
                  </td>
                  <td className="px-4 py-3">
                    {m.category ? (
                      <span className="text-xs px-2 py-0.5 rounded-full bg-slate-100 text-slate-600">{m.category}</span>
                    ) : (
                      <span className="text-slate-300">—</span>
                    )}
                  </td>
                  <td className="px-4 py-3 text-slate-600 text-xs">
                    {m.active_ingredient || <span className="text-slate-300">—</span>}
                  </td>
                  <td className="px-4 py-3">
                    {m.flag_level ? (
                      <span className={cn("text-[11px] px-2 py-0.5 rounded-full font-medium", FLAG_COLORS[m.flag_level] || "bg-slate-100 text-slate-500")}>
                        {FLAG_LABELS[m.flag_level] || m.flag_level}
                      </span>
                    ) : (
                      <span className="text-slate-300">—</span>
                    )}
                  </td>
                  <td className="px-4 py-3">
                    {canEdit ? (
                      <button
                        onClick={() => handleToggleActive(m)}
                        disabled={toggleActive.isPending}
                        className={cn(
                          "inline-flex items-center gap-1 text-[11px] px-2 py-0.5 rounded-full font-medium transition-colors",
                          m.is_active
                            ? "bg-emerald-100 text-emerald-700 hover:bg-emerald-200"
                            : "bg-slate-100 text-slate-500 hover:bg-slate-200"
                        )}
                        title={m.is_active ? "Click to deactivate" : "Click to activate"}
                      >
                        {m.is_active ? <Power className="h-3 w-3" /> : <PowerOff className="h-3 w-3" />}
                        {m.is_active ? "Active" : "Inactive"}
                      </button>
                    ) : (
                      <span className={cn(
                        "inline-flex items-center gap-1 text-[11px] px-2 py-0.5 rounded-full font-medium",
                        m.is_active
                          ? "bg-emerald-100 text-emerald-700"
                          : "bg-slate-100 text-slate-500"
                      )}>
                        {m.is_active ? <Power className="h-3 w-3" /> : <PowerOff className="h-3 w-3" />}
                        {m.is_active ? "Active" : "Inactive"}
                      </span>
                    )}
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center justify-end gap-1">
                      <button
                        onClick={() => openView(m)}
                        className="p-1.5 rounded text-slate-400 hover:text-sf-deepNavy hover:bg-slate-100 transition-colors"
                        title="View details"
                      >
                        <Eye className="h-4 w-4" />
                      </button>
                      {canEdit && (
                        <>
                          <button
                            onClick={() => openEdit(m)}
                            className="p-1.5 rounded text-slate-400 hover:text-sf-deepNavy hover:bg-slate-100 transition-colors"
                            title="Edit"
                          >
                            <Pencil className="h-4 w-4" />
                          </button>
                          <button
                            onClick={() => setDeleteTarget(m)}
                            className="p-1.5 rounded text-slate-400 hover:text-red-600 hover:bg-red-50 transition-colors"
                            title="Delete"
                          >
                            <Trash2 className="h-4 w-4" />
                          </button>
                        </>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <div className="px-4 py-2 border-t border-slate-100 text-xs text-slate-400 text-right">
            {medicines.length} medicines found
          </div>
        </div>
      )}

      {/* Create/Edit/View Modal */}
      {modal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl max-h-[90vh] flex flex-col overflow-hidden">
            {/* Modal Header */}
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
              <div className="flex items-center gap-2">
                <Pill className="h-5 w-5 text-sf-deepNavy" />
                <h2 className="text-lg font-bold text-slate-900">
                  {modal._mode === "create" && "Add New Medicine"}
                  {modal._mode === "edit" && "Edit Medicine"}
                  {modal._mode === "view" && modal.name}
                </h2>
              </div>
              <div className="flex items-center gap-2">
                {modal._mode === "view" && canEdit && (
                  <button
                    onClick={() => setModal({ ...modal, _mode: "edit" })}
                    className="flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium text-sf-deepNavy border border-sf-deepNavy/30 rounded-lg hover:bg-sf-deepNavy/5 transition-colors"
                  >
                    <Pencil className="h-3.5 w-3.5" /> Edit
                  </button>
                )}
                <button
                  onClick={() => setModal(null)}
                  className="p-2 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors"
                >
                  <X className="h-5 w-5" />
                </button>
              </div>
            </div>

            {/* Modal Body */}
            <div className="flex-1 overflow-y-auto px-6 py-5 space-y-5">
              {/* Name */}
              <div>
                <label className="block text-xs font-bold text-slate-600 mb-1.5 uppercase tracking-wide">
                  Medicine Name <span className="text-red-500">*</span>
                </label>
                {isReadonly ? (
                  <p className="text-slate-800 font-medium">{modal.name || "—"}</p>
                ) : (
                  <input
                    type="text"
                    value={modal.name}
                    onChange={(e) => setModal({ ...modal, name: e.target.value })}
                    placeholder="Example: Ibuprofen 400mg"
                    className="w-full px-3 py-2 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-sf-deepNavy/20 focus:border-sf-deepNavy"
                  />
                )}
              </div>

              {/* Row: Category + Flag Level */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-slate-600 mb-1.5 uppercase tracking-wide">
                    Category
                  </label>
                  {isReadonly ? (
                    <p className="text-slate-700">{modal.category || "—"}</p>
                  ) : (
                    <select
                      value={modal.category}
                      onChange={(e) => setModal({ ...modal, category: e.target.value })}
                      className="w-full px-3 py-2 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-sf-deepNavy/20 focus:border-sf-deepNavy bg-white"
                    >
                      {CATEGORIES.slice(1).map((c) => (
                        <option key={c.value} value={c.value}>{c.label}</option>
                      ))}
                      <option value="">— Select Category —</option>
                    </select>
                  )}
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-600 mb-1.5 uppercase tracking-wide">
                    Flag Level
                  </label>
                  {isReadonly ? (
                    modal.flag_level ? (
                      <span className={cn("text-xs px-2 py-0.5 rounded-full font-medium", FLAG_COLORS[modal.flag_level] || "bg-slate-100 text-slate-500")}>
                        {FLAG_LABELS[modal.flag_level] || modal.flag_level}
                      </span>
                    ) : (
                      <p className="text-slate-400">—</p>
                    )
                  ) : (
                    <select
                      value={modal.flag_level}
                      onChange={(e) => setModal({ ...modal, flag_level: e.target.value })}
                      className="w-full px-3 py-2 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-sf-deepNavy/20 focus:border-sf-deepNavy bg-white"
                    >
                      {FLAG_LEVELS.map((f) => (
                        <option key={f.value} value={f.value}>{f.label}</option>
                      ))}
                    </select>
                  )}
                </div>
              </div>

              {/* Active Ingredient */}
              <div>
                <label className="block text-xs font-bold text-slate-600 mb-1.5 uppercase tracking-wide">
                  Active Ingredient
                </label>
                {isReadonly ? (
                  <p className="text-slate-700">{modal.active_ingredient || "—"}</p>
                ) : (
                  <input
                    type="text"
                    value={modal.active_ingredient}
                    onChange={(e) => setModal({ ...modal, active_ingredient: e.target.value })}
                    placeholder="Example: Ibuprofen"
                    className="w-full px-3 py-2 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-sf-deepNavy/20 focus:border-sf-deepNavy"
                  />
                )}
              </div>

              {/* Main Function */}
              <div>
                <label className="block text-xs font-bold text-slate-600 mb-1.5 uppercase tracking-wide">
                  Main Function
                </label>
                {isReadonly ? (
                  <p className="text-slate-700 whitespace-pre-wrap">{modal.main_function || "—"}</p>
                ) : (
                  <textarea
                    value={modal.main_function}
                    onChange={(e) => setModal({ ...modal, main_function: e.target.value })}
                    rows={2}
                    placeholder="Explain the main function of this medicine..."
                    className="w-full px-3 py-2 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-sf-deepNavy/20 focus:border-sf-deepNavy resize-none"
                  />
                )}
              </div>

              {/* Side Effects */}
              <div>
                <label className="block text-xs font-bold text-slate-600 mb-1.5 uppercase tracking-wide">
                  Side Effects
                </label>
                {isReadonly ? (
                  <p className="text-slate-700 whitespace-pre-wrap">{modal.side_effects || "—"}</p>
                ) : (
                  <textarea
                    value={modal.side_effects}
                    onChange={(e) => setModal({ ...modal, side_effects: e.target.value })}
                    rows={2}
                    placeholder="Possible side effects..."
                    className="w-full px-3 py-2 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-sf-deepNavy/20 focus:border-sf-deepNavy resize-none"
                  />
                )}
              </div>

              {/* Exercise Implications */}
              <div className="bg-amber-50 border border-amber-200 rounded-lg p-4 space-y-3">
                <h3 className="text-xs font-bold text-amber-800 uppercase tracking-wide">
                  Exercise Implications
                </h3>
                <div>
                  <label className="block text-xs font-semibold text-amber-700 mb-1.5">
                    Impact on Exercise
                  </label>
                  {isReadonly ? (
                    <p className="text-slate-700 whitespace-pre-wrap text-sm">{modal.exercise_implications || "—"}</p>
                  ) : (
                    <textarea
                      value={modal.exercise_implications}
                      onChange={(e) => setModal({ ...modal, exercise_implications: e.target.value })}
                      rows={3}
                      placeholder="How this medicine affects sports performance, heart rate, blood pressure, etc..."
                      className="w-full px-3 py-2 border border-amber-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-amber-400/30 focus:border-amber-400 bg-white resize-none"
                    />
                  )}
                </div>
                <div>
                  <label className="block text-xs font-semibold text-amber-700 mb-1.5">
                    Exercise Adjustments
                  </label>
                  {isReadonly ? (
                    <p className="text-slate-700 whitespace-pre-wrap text-sm">{modal.exercise_adjustments || "—"}</p>
                  ) : (
                    <textarea
                      value={modal.exercise_adjustments}
                      onChange={(e) => setModal({ ...modal, exercise_adjustments: e.target.value })}
                      rows={3}
                      placeholder="Recommended adjustments to the exercise program for clients taking this medicine..."
                      className="w-full px-3 py-2 border border-amber-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-amber-400/30 focus:border-amber-400 bg-white resize-none"
                    />
                  )}
                </div>
              </div>

              {/* Detail URL */}
              <div>
                <label className="block text-xs font-bold text-slate-600 mb-1.5 uppercase tracking-wide">
                  Reference Link (URL)
                </label>
                {isReadonly ? (
                  modal.detail_url ? (
                    <a href={modal.detail_url} target="_blank" rel="noopener noreferrer" className="text-sf-deepNavy hover:underline text-sm break-all">
                      {modal.detail_url}
                    </a>
                  ) : (
                    <p className="text-slate-400">—</p>
                  )
                ) : (
                  <input
                    type="url"
                    value={modal.detail_url}
                    onChange={(e) => setModal({ ...modal, detail_url: e.target.value })}
                    placeholder="https://..."
                    className="w-full px-3 py-2 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-sf-deepNavy/20 focus:border-sf-deepNavy"
                  />
                )}
              </div>

              {/* Status toggle (create/edit only) */}
              {!isReadonly && (
                <div className="flex items-center gap-3 pt-1">
                  <button
                    type="button"
                    onClick={() => setModal({ ...modal, is_active: !modal.is_active })}
                    className={cn(
                      "relative w-11 h-6 rounded-full transition-colors duration-200",
                      modal.is_active ? "bg-emerald-500" : "bg-slate-300"
                    )}
                  >
                    <span
                      className={cn(
                        "absolute top-0.5 left-0.5 w-5 h-5 bg-white rounded-full shadow transition-transform duration-200",
                        modal.is_active ? "translate-x-5" : "translate-x-0"
                      )}
                    />
                  </button>
                  <span className="text-sm text-slate-700 font-medium">
                    {modal.is_active ? "Status: Active" : "Status: Inactive"}
                  </span>
                </div>
              )}
            </div>

            {/* Modal Footer */}
            {!isReadonly && (
              <div className="flex justify-end gap-3 px-6 py-4 border-t border-slate-100 bg-slate-50">
                <button
                  onClick={() => setModal(null)}
                  className="px-4 py-2 text-sm font-medium text-slate-600 border border-slate-200 rounded-lg hover:bg-slate-100 transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={handleSave}
                  disabled={isSaving || !modal.name.trim()}
                  className="flex items-center gap-2 px-5 py-2 text-sm font-medium bg-sf-deepNavy text-white rounded-lg hover:bg-sf-deepNavy/90 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {isSaving ? <Loader2 className="h-4 w-4 animate-spin" /> : null}
                  {modal._mode === "edit" ? "Save Changes" : "Add Medicine"}
                </button>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Delete Confirm */}
      <ConfirmDialog
        open={!!deleteTarget}
        title="Delete Medicine"
        description={`Are you sure you want to delete "${deleteTarget?.name}"? This action cannot be undone.`}
        confirmLabel="Delete"
        variant="danger"
        onConfirm={confirmDelete}
        onClose={() => setDeleteTarget(null)}
      />
    </div>
  );
}
