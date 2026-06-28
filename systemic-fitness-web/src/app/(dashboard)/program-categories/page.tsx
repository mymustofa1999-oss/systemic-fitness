"use client";

import { useState } from "react";
import {
  useProgramCategories,
  useCreateProgramCategory,
  useUpdateProgramCategory,
  useDeleteProgramCategory,
} from "@/hooks/useNewFeatures";
import { EmptyState } from "@/components/shared/EmptyState";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { SearchInput } from "@/components/shared/SearchInput";
import { DataTable, Column } from "@/components/shared/DataTable";
import { SearchableSelect } from "@/components/shared/SearchableSelect";
import {
  Layers, Plus, X, Loader2, Pencil, Trash2, MoreVertical,
  Check, XCircle,
} from "lucide-react";
import { cn } from "@/lib/utils";

export default function ProgramCategoriesPage() {
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [modalCategory, setModalCategory] = useState<any | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<any | null>(null);
  const [menuOpen, setMenuOpen] = useState<string | null>(null);

  const params: Record<string, unknown> = { page, limit: 20, search };

  const { data, isLoading } = useProgramCategories(params);
  const deleteCategory = useDeleteProgramCategory();
  const categories = (data?.data ?? []) as any[];
  const meta = data?.meta;

  function openCreate() {
    setModalCategory({});
  }

  function openEdit(cat: any) {
    setMenuOpen(null);
    setModalCategory(cat);
  }

  function openDelete(cat: any) {
    setMenuOpen(null);
    setDeleteTarget(cat);
  }

  async function confirmDelete() {
    if (!deleteTarget) return;
    await deleteCategory.mutateAsync(deleteTarget.id);
    setDeleteTarget(null);
  }

  // Format parameter template for display
  function formatParams(template: Record<string, boolean> | null) {
    if (!template || Object.keys(template).length === 0) return "-";
    return Object.entries(template)
      .filter(([, v]) => v)
      .map(([k]) => k.replace(/_/g, " "))
      .join(", ");
  }

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Program Categories</h1>
          <p className="text-sm text-slate-500 mt-1">
            {meta?.total != null
              ? `${meta.total} kategori program`
              : "Master data kategori program conditioning"}
          </p>
        </div>
        <button onClick={openCreate} className="btn-primary">
          <Plus className="h-4 w-4" /> Tambah Kategori
        </button>
      </div>

      {/* Search */}
      <div className="flex items-center gap-3">
        <div className="flex-1">
          <SearchInput
            value={search}
            onChange={(v) => { setSearch(v); setPage(1); }}
            placeholder="Cari nama atau kode kategori..."
          />
        </div>
      </div>

      {/* Table */}
      {!isLoading && categories.length === 0 ? (
        <EmptyState
          icon={Layers}
          title={search ? "Tidak ditemukan" : "Belum ada kategori program"}
          description={search ? "Coba kata kunci lain" : "Tambahkan kategori program conditioning untuk klien."}
          action={!search ? (
            <button onClick={openCreate} className="btn-primary">
              <Plus className="h-4 w-4" /> Tambah Kategori
            </button>
          ) : undefined}
        />
      ) : (
        <DataTable
          columns={categoryColumns(menuOpen, setMenuOpen, openEdit, openDelete, formatParams)}
          data={categories}
          loading={isLoading}
          page={page}
          totalPages={meta?.total_pages ?? 1}
          total={meta?.total ?? 0}
          onPageChange={setPage}
        />
      )}

      {/* Create / Edit Modal */}
      {modalCategory !== null && (
        <ProgramCategoryFormModal
          category={modalCategory.id ? modalCategory : null}
          onClose={() => setModalCategory(null)}
        />
      )}

      {/* Delete Confirm */}
      <ConfirmDialog
        open={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        onConfirm={confirmDelete}
        title="Hapus Kategori Program"
        description={`Apakah Anda yakin ingin menghapus "${deleteTarget?.name}"? Tindakan ini tidak dapat dibatalkan.`}
        confirmLabel="Hapus"
        variant="danger"
        loading={deleteCategory.isPending}
      />
    </div>
  );
}

// ── Table Columns ──────────────────────────────────────────────

function categoryColumns(
  menuOpen: string | null,
  setMenuOpen: (id: string | null) => void,
  openEdit: (cat: any) => void,
  openDelete: (cat: any) => void,
  formatParams: (t: Record<string, boolean> | null) => string,
): Column<any>[] {
  return [
    {
      key: "name", label: "Nama",
      render: (cat) => (
        <div>
          <span className="font-medium text-slate-900 text-sm">{cat.name}</span>
          {cat.description && <p className="text-xs text-slate-400 mt-0.5 truncate max-w-xs">{cat.description}</p>}
        </div>
      ),
    },
    {
      key: "code", label: "Kode", className: "w-32",
      render: (cat) => <span className="inline-block px-2 py-0.5 rounded-md bg-slate-100 text-slate-600 text-xs font-mono">{cat.code}</span>,
    },
    {
      key: "parameter_template", label: "Parameter",
      render: (cat) => <span className="text-sm text-slate-600 truncate max-w-xs">{formatParams(cat.parameter_template)}</span>,
    },
    {
      key: "display_order", label: "Urutan", className: "w-20 text-center",
      render: (cat) => <span className="text-sm text-slate-600">{cat.display_order}</span>,
    },
    {
      key: "is_active", label: "Status", className: "w-20",
      render: (cat) => cat.is_active ? (
        <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700 text-xs font-medium"><Check className="h-3 w-3" /> Aktif</span>
      ) : (
        <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-slate-100 text-slate-500 text-xs font-medium"><XCircle className="h-3 w-3" /> Nonaktif</span>
      ),
    },
    {
      key: "actions", label: "", className: "w-12",
      render: (cat) => (
        <div className="relative">
          <button onClick={(e) => { e.stopPropagation(); setMenuOpen(menuOpen === cat.id ? null : cat.id); }} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400 transition-colors">
            <MoreVertical className="h-4 w-4" />
          </button>
          {menuOpen === cat.id && (
            <>
              <div className="fixed inset-0 z-10" onClick={() => setMenuOpen(null)} />
              <div className="absolute right-4 top-10 bg-white rounded-lg shadow-lg border border-slate-100 py-1 min-w-[140px] z-20">
                <button onClick={(e) => { e.stopPropagation(); openEdit(cat); }} className="w-full px-3 py-2 text-left text-sm text-slate-700 hover:bg-slate-50 flex items-center gap-2"><Pencil className="h-3.5 w-3.5" /> Edit</button>
                <button onClick={(e) => { e.stopPropagation(); openDelete(cat); }} className="w-full px-3 py-2 text-left text-sm text-rose-600 hover:bg-rose-50 flex items-center gap-2"><Trash2 className="h-3.5 w-3.5" /> Hapus</button>
              </div>
            </>
          )}
        </div>
      ),
    },
  ];
}

// ── Create / Edit Form Modal ────────────────────────────────────

interface ProgramCategoryFormModalProps {
  category: any | null;
  onClose: () => void;
}

function ProgramCategoryFormModal({ category, onClose }: ProgramCategoryFormModalProps) {
  const isEdit = !!category?.id;
  const createCategory = useCreateProgramCategory();
  const updateCategory = useUpdateProgramCategory();
  const saving = createCategory.isPending || updateCategory.isPending;

  const [name, setName] = useState(category?.name ?? "");
  const [code, setCode] = useState(category?.code ?? "");
  const [description, setDescription] = useState(category?.description ?? "");
  const [displayOrder, setDisplayOrder] = useState<number>(category?.display_order ?? 0);
  const [isActive, setIsActive] = useState<boolean>(category?.is_active ?? true);

  // Parameter template toggles
  const existingParams = category?.parameter_template ?? {};
  const [bpmRange, setBpmRange] = useState<boolean>(!!existingParams.bpm_range);
  const [bebanUpper, setBebanUpper] = useState<boolean>(!!existingParams.beban_upper);
  const [bebanLower, setBebanLower] = useState<boolean>(!!existingParams.beban_lower);
  const [resistance, setResistance] = useState<boolean>(!!existingParams.resistance);

  // Auto-generate code from name
  function handleNameChange(val: string) {
    setName(val);
    if (!isEdit && !category?.code) {
      setCode(val.toLowerCase().replace(/\s+/g, "_").replace(/[^a-z0-9_]/g, ""));
    }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim() || !code.trim()) return;

    const parameterTemplate: Record<string, boolean> = {};
    if (bpmRange) parameterTemplate.bpm_range = true;
    if (bebanUpper) parameterTemplate.beban_upper = true;
    if (bebanLower) parameterTemplate.beban_lower = true;
    if (resistance) parameterTemplate.resistance = true;

    const payload: Record<string, unknown> = {
      name: name.trim(),
      code: code.trim(),
      description: description.trim() || undefined,
      parameter_template: parameterTemplate,
      display_order: displayOrder,
      is_active: isActive,
    };

    if (isEdit) {
      await updateCategory.mutateAsync({ id: category.id, ...payload });
    } else {
      await createCategory.mutateAsync(payload);
    }
    onClose();
  }

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center pt-[5vh] overflow-y-auto" onClick={onClose}>
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" />
      <div className="relative bg-white rounded-2xl shadow-xl max-w-2xl w-full mx-4 mb-12 animate-slide-in" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
          <h2 className="text-lg font-semibold text-slate-900">
            {isEdit ? "Edit Kategori Program" : "Tambah Kategori Program"}
          </h2>
          <button onClick={onClose} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400">
            <X className="h-5 w-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-5 max-h-[75vh] overflow-y-auto">
          <div>
            <label className="label">Nama Kategori *</label>
            <input
              value={name}
              onChange={(e) => handleNameChange(e.target.value)}
              required
              className="input"
              placeholder="e.g. Functional Conditioning"
              autoFocus
            />
          </div>

          <div>
            <label className="label">Kode *</label>
            <input
              value={code}
              onChange={(e) => setCode(e.target.value)}
              required
              className="input font-mono"
              placeholder="e.g. functional"
            />
            <p className="text-xs text-slate-400 mt-1">Kode unik untuk identifikasi (lowercase, tanpa spasi)</p>
          </div>

          <div>
            <label className="label">Deskripsi</label>
            <textarea
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              className="input"
              rows={3}
              placeholder="Deskripsi program conditioning..."
            />
          </div>

          {/* Parameter Template */}
          <div>
            <label className="label">Parameter Template</label>
            <p className="text-xs text-slate-400 mb-3">Pilih parameter yang tersedia untuk kategori ini</p>
            <div className="grid grid-cols-2 gap-3">
              <label className="flex items-center gap-2 p-3 rounded-lg border border-slate-200 hover:border-sf-systemBlue/40 cursor-pointer transition-colors">
                <input type="checkbox" checked={bpmRange} onChange={(e) => setBpmRange(e.target.checked)} className="rounded border-slate-300 text-sf-deepNavy focus:ring-sf-warmGold/40" />
                <span className="text-sm text-slate-700">BPM Range</span>
              </label>
              <label className="flex items-center gap-2 p-3 rounded-lg border border-slate-200 hover:border-sf-systemBlue/40 cursor-pointer transition-colors">
                <input type="checkbox" checked={bebanUpper} onChange={(e) => setBebanUpper(e.target.checked)} className="rounded border-slate-300 text-sf-deepNavy focus:ring-sf-warmGold/40" />
                <span className="text-sm text-slate-700">Beban Upper</span>
              </label>
              <label className="flex items-center gap-2 p-3 rounded-lg border border-slate-200 hover:border-sf-systemBlue/40 cursor-pointer transition-colors">
                <input type="checkbox" checked={bebanLower} onChange={(e) => setBebanLower(e.target.checked)} className="rounded border-slate-300 text-sf-deepNavy focus:ring-sf-warmGold/40" />
                <span className="text-sm text-slate-700">Beban Lower</span>
              </label>
              <label className="flex items-center gap-2 p-3 rounded-lg border border-slate-200 hover:border-sf-systemBlue/40 cursor-pointer transition-colors">
                <input type="checkbox" checked={resistance} onChange={(e) => setResistance(e.target.checked)} className="rounded border-slate-300 text-sf-deepNavy focus:ring-sf-warmGold/40" />
                <span className="text-sm text-slate-700">Resistance</span>
              </label>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Urutan Tampilan</label>
              <input
                type="number"
                value={displayOrder}
                onChange={(e) => setDisplayOrder(parseInt(e.target.value) || 0)}
                className="input"
                min={0}
              />
            </div>
            <div>
              <label className="label">Status</label>
              <SearchableSelect
                options={[{ value: "active", label: "Aktif" }, { value: "inactive", label: "Nonaktif" }]}
                value={isActive ? "active" : "inactive"}
                onChange={(v) => setIsActive(v === "active")}
                placeholder="Pilih status..."
              />
            </div>
          </div>

          <div className="flex justify-end gap-3 pt-2">
            <button type="button" onClick={onClose} className="btn-secondary">Batal</button>
            <button type="submit" disabled={saving || !name.trim() || !code.trim()} className="btn-primary">
              {saving ? <Loader2 className="h-4 w-4 animate-spin" /> : isEdit ? <Pencil className="h-4 w-4" /> : <Plus className="h-4 w-4" />}
              {saving ? "Menyimpan..." : isEdit ? "Simpan Perubahan" : "Tambah Kategori"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
