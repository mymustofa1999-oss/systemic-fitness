"use client";

import { useState } from "react";
import { useFoods, useCreateFood, useUpdateFood, useDeleteFood } from "@/hooks/useNewFeatures";
import { ImageUpload } from "@/components/shared/ImageUpload";
import { EmptyState } from "@/components/shared/EmptyState";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { SearchInput } from "@/components/shared/SearchInput";
import {
  Apple, Plus, Flame, Wheat, Droplets, Beef, X, Loader2,
  Pencil, Trash2, MoreVertical,
} from "lucide-react";
import { cn } from "@/lib/utils";

const mealTypeColors: Record<string, string> = {
  breakfast: "bg-amber-50 text-amber-700",
  lunch: "bg-emerald-50 text-emerald-700",
  dinner: "bg-indigo-50 text-indigo-700",
  snack: "bg-rose-50 text-rose-700",
};

const MEAL_TYPES = ["breakfast", "lunch", "dinner", "snack"];

export default function FoodsPage() {
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [modalFood, setModalFood] = useState<any | null>(null); // null=closed, {}=create, {id,...}=edit
  const [deleteTarget, setDeleteTarget] = useState<any | null>(null);
  const [menuOpen, setMenuOpen] = useState<string | null>(null);

  const { data, isLoading } = useFoods({ page, limit: 24, search });
  const deleteFood = useDeleteFood();
  const foods = (data?.data ?? []) as any[];
  const meta = data?.meta;

  function openCreate() {
    setModalFood({});
  }

  function openEdit(food: any) {
    setMenuOpen(null);
    setModalFood(food);
  }

  function openDelete(food: any) {
    setMenuOpen(null);
    setDeleteTarget(food);
  }

  async function confirmDelete() {
    if (!deleteTarget) return;
    await deleteFood.mutateAsync(deleteTarget.id);
    setDeleteTarget(null);
  }

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Food Library</h1>
          <p className="text-sm text-slate-500 mt-1">
            {meta?.total != null ? `${meta.total} foods` : "Manage your food library"}
          </p>
        </div>
        <button onClick={openCreate} className="btn-primary">
          <Plus className="h-4 w-4" /> Add Food
        </button>
      </div>

      <SearchInput
        value={search}
        onChange={(v) => { setSearch(v); setPage(1); }}
        placeholder="Search foods..."
      />

      {isLoading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {Array.from({ length: 8 }).map((_, i) => (
            <div key={i} className="card p-4">
              <div className="skeleton h-32 w-full rounded-lg mb-3" />
              <div className="skeleton h-4 w-3/4 mb-2" />
              <div className="skeleton h-3 w-1/2" />
            </div>
          ))}
        </div>
      ) : foods.length === 0 ? (
        <EmptyState
          icon={Apple}
          title={search ? "No foods match" : "No foods yet"}
          description={search ? "Try a different search term" : "Add foods to build meal plans for clients."}
          action={!search ? <button onClick={openCreate} className="btn-primary"><Plus className="h-4 w-4" /> Add Food</button> : undefined}
        />
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {foods.map((food: any) => (
            <div key={food.id} className="card p-4 group relative">
              {/* Action Menu */}
              <div className="absolute top-3 right-3 z-10">
                <button
                  onClick={(e) => { e.stopPropagation(); setMenuOpen(menuOpen === food.id ? null : food.id); }}
                  className="p-1.5 rounded-lg bg-white hover:bg-slate-100 shadow-sm border border-slate-200 transition-colors"
                >
                  <MoreVertical className="h-4 w-4 text-slate-500" />
                </button>
                {menuOpen === food.id && (
                  <>
                    <div className="fixed inset-0" onClick={() => setMenuOpen(null)} />
                    <div className="absolute right-0 mt-1 bg-white rounded-lg shadow-lg border border-slate-100 py-1 min-w-[140px] z-20">
                      <button
                        onClick={() => openEdit(food)}
                        className="w-full px-3 py-2 text-left text-sm text-slate-700 hover:bg-slate-50 flex items-center gap-2"
                      >
                        <Pencil className="h-3.5 w-3.5" /> Edit
                      </button>
                      <button
                        onClick={() => openDelete(food)}
                        className="w-full px-3 py-2 text-left text-sm text-rose-600 hover:bg-rose-50 flex items-center gap-2"
                      >
                        <Trash2 className="h-3.5 w-3.5" /> Delete
                      </button>
                    </div>
                  </>
                )}
              </div>

              {/* Image */}
              <div
                onClick={() => openEdit(food)}
                className="h-32 rounded-lg bg-slate-50 flex items-center justify-center mb-3 overflow-hidden cursor-pointer"
              >
                {food.image_url ? (
                  <img src={food.image_url} alt={food.name} className="w-full h-full object-cover" />
                ) : (
                  <Apple className="h-8 w-8 text-slate-200" />
                )}
              </div>

              <h3
                onClick={() => openEdit(food)}
                className="font-medium text-slate-900 text-sm cursor-pointer hover:text-sf-deepNavy transition-colors"
              >
                {food.name}
              </h3>
              <p className="text-xs text-slate-400 mt-0.5">
                {food.serving_size} {food.serving_unit}
              </p>

              <div className="flex flex-wrap gap-1 mt-2">
                {food.meal_types?.map((mt: string) => (
                  <span key={mt} className={`px-1.5 py-0.5 rounded text-[10px] font-medium capitalize ${mealTypeColors[mt] ?? "bg-slate-50 text-slate-600"}`}>
                    {mt}
                  </span>
                ))}
              </div>

              <div className="grid grid-cols-4 gap-1 mt-3 pt-3 border-t border-slate-50">
                <div className="text-center">
                  <Flame className="h-3 w-3 text-orange-400 mx-auto mb-0.5" />
                  <p className="text-xs font-semibold text-slate-900">{food.calories ?? 0}</p>
                  <p className="text-[10px] text-slate-400">kcal</p>
                </div>
                <div className="text-center">
                  <Beef className="h-3 w-3 text-rose-400 mx-auto mb-0.5" />
                  <p className="text-xs font-semibold text-slate-900">{food.protein_g ?? 0}g</p>
                  <p className="text-[10px] text-slate-400">protein</p>
                </div>
                <div className="text-center">
                  <Wheat className="h-3 w-3 text-amber-400 mx-auto mb-0.5" />
                  <p className="text-xs font-semibold text-slate-900">{food.carbs_g ?? 0}g</p>
                  <p className="text-[10px] text-slate-400">carbs</p>
                </div>
                <div className="text-center">
                  <Droplets className="h-3 w-3 text-blue-400 mx-auto mb-0.5" />
                  <p className="text-xs font-semibold text-slate-900">{food.fat_g ?? 0}g</p>
                  <p className="text-[10px] text-slate-400">fat</p>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {(meta?.total_pages ?? 1) > 1 && (
        <div className="flex justify-center gap-1">
          {Array.from({ length: meta!.total_pages }, (_, i) => i + 1)
            .slice(Math.max(0, page - 3), page + 2)
            .map((p) => (
              <button key={p} onClick={() => setPage(p)}
                className={cn("w-8 h-8 rounded-lg text-sm font-medium transition-colors",
                  p === page ? "bg-sf-deepNavy text-white" : "text-slate-500 hover:bg-slate-100"
                )}>{p}</button>
            ))}
        </div>
      )}

      {/* Create / Edit Modal */}
      {modalFood !== null && (
        <FoodFormModal
          food={modalFood.id ? modalFood : null}
          onClose={() => setModalFood(null)}
        />
      )}

      {/* Delete Confirm */}
      <ConfirmDialog
        open={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        onConfirm={confirmDelete}
        title="Delete Food"
        description={`Are you sure you want to delete "${deleteTarget?.name}"? This action cannot be undone.`}
        confirmLabel="Delete"
        variant="danger"
        loading={deleteFood.isPending}
      />
    </div>
  );
}

// ── Create / Edit Form Modal ────────────────────────────────────

interface FoodFormModalProps {
  food: any | null; // null = create mode, object = edit mode
  onClose: () => void;
}

function FoodFormModal({ food, onClose }: FoodFormModalProps) {
  const isEdit = !!food?.id;
  const createFood = useCreateFood();
  const updateFood = useUpdateFood();
  const saving = createFood.isPending || updateFood.isPending;

  const [name, setName] = useState(food?.name ?? "");
  const [description, setDescription] = useState(food?.description ?? "");
  const [mealTypes, setMealTypes] = useState<string[]>(food?.meal_types ?? []);
  const [calories, setCalories] = useState(food?.calories?.toString() ?? "");
  const [proteinG, setProteinG] = useState(food?.protein_g?.toString() ?? "");
  const [carbsG, setCarbsG] = useState(food?.carbs_g?.toString() ?? "");
  const [fatG, setFatG] = useState(food?.fat_g?.toString() ?? "");
  const [fiberG, setFiberG] = useState(food?.fiber_g?.toString() ?? "");
  const [servingSize, setServingSize] = useState(food?.serving_size ?? "");
  const [servingUnit, setServingUnit] = useState(food?.serving_unit ?? "");
  const [imageUrl, setImageUrl] = useState<string | null>(food?.image_url ?? null);
  const [imageId, setImageId] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim() || mealTypes.length === 0) return;

    const payload: Record<string, unknown> = {
      name: name.trim(),
      description: description || undefined,
      image_id: imageId || undefined,
      image_url: imageUrl || undefined,
      meal_types: mealTypes,
      calories: calories ? Number(calories) : undefined,
      protein_g: proteinG ? Number(proteinG) : undefined,
      carbs_g: carbsG ? Number(carbsG) : undefined,
      fat_g: fatG ? Number(fatG) : undefined,
      fiber_g: fiberG ? Number(fiberG) : undefined,
      serving_size: servingSize || undefined,
      serving_unit: servingUnit || undefined,
    };

    if (isEdit) {
      await updateFood.mutateAsync({ id: food.id, ...payload });
    } else {
      await createFood.mutateAsync(payload);
    }
    onClose();
  }

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center pt-[5vh] overflow-y-auto" onClick={onClose}>
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" />
      <div className="relative bg-white rounded-2xl shadow-xl max-w-2xl w-full mx-4 mb-12 animate-slide-in" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
          <h2 className="text-lg font-semibold text-slate-900">
            {isEdit ? "Edit Food" : "Add Food"}
          </h2>
          <button onClick={onClose} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400">
            <X className="h-5 w-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-5 max-h-[75vh] overflow-y-auto">
          {/* Image Upload */}
          <div>
            <label className="label">Food Image</label>
            <ImageUpload
              value={imageUrl}
              onChange={(url, id) => { setImageUrl(url); setImageId(id); }}
              entityType="food"
              entityId={food?.id}
              aspectRatio="video"
              placeholder="Upload food photo"
            />
          </div>

          <div>
            <label className="label">Name *</label>
            <input value={name} onChange={(e) => setName(e.target.value)} required className="input" placeholder="e.g. Grilled Chicken Breast" autoFocus />
          </div>

          <div>
            <label className="label">Description</label>
            <textarea value={description} onChange={(e) => setDescription(e.target.value)} className="input" rows={2} placeholder="Brief description..." />
          </div>

          <div>
            <label className="label">Meal Types *</label>
            <div className="flex flex-wrap gap-2">
              {MEAL_TYPES.map((mt) => (
                <button key={mt} type="button"
                  onClick={() => setMealTypes((p) => p.includes(mt) ? p.filter((x) => x !== mt) : [...p, mt])}
                  className={cn("px-3 py-1.5 rounded-lg text-xs font-medium capitalize transition-colors",
                    mealTypes.includes(mt) ? "bg-sf-deepNavy text-white" : "bg-slate-50 text-slate-600 hover:bg-slate-100"
                  )}>{mt}</button>
              ))}
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Serving Size</label>
              <input value={servingSize} onChange={(e) => setServingSize(e.target.value)} className="input" placeholder="e.g. 200" />
            </div>
            <div>
              <label className="label">Serving Unit</label>
              <input value={servingUnit} onChange={(e) => setServingUnit(e.target.value)} className="input" placeholder="e.g. gram" />
            </div>
          </div>

          <div className="grid grid-cols-5 gap-3">
            <div>
              <label className="label">Calories</label>
              <input type="number" value={calories} onChange={(e) => setCalories(e.target.value)} className="input" placeholder="0" />
            </div>
            <div>
              <label className="label">Protein (g)</label>
              <input type="number" step="0.1" value={proteinG} onChange={(e) => setProteinG(e.target.value)} className="input" placeholder="0" />
            </div>
            <div>
              <label className="label">Carbs (g)</label>
              <input type="number" step="0.1" value={carbsG} onChange={(e) => setCarbsG(e.target.value)} className="input" placeholder="0" />
            </div>
            <div>
              <label className="label">Fat (g)</label>
              <input type="number" step="0.1" value={fatG} onChange={(e) => setFatG(e.target.value)} className="input" placeholder="0" />
            </div>
            <div>
              <label className="label">Fiber (g)</label>
              <input type="number" step="0.1" value={fiberG} onChange={(e) => setFiberG(e.target.value)} className="input" placeholder="0" />
            </div>
          </div>

          <div className="flex justify-end gap-3 pt-2">
            <button type="button" onClick={onClose} className="btn-secondary">Cancel</button>
            <button type="submit" disabled={saving || !name.trim() || mealTypes.length === 0} className="btn-primary">
              {saving ? <Loader2 className="h-4 w-4 animate-spin" /> : isEdit ? <Pencil className="h-4 w-4" /> : <Plus className="h-4 w-4" />}
              {saving ? "Saving..." : isEdit ? "Save Changes" : "Add Food"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
