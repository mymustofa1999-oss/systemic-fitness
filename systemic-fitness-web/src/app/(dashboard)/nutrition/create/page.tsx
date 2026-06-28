"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { apiPost } from "@/lib/api";
import { toast } from "@/stores/toastStore";
import { ArrowLeft, Plus, Trash2, Loader2, Send } from "lucide-react";
import Link from "next/link";
import { useQueryClient } from "@tanstack/react-query";
import { SearchableSelect } from "@/components/shared/SearchableSelect";

const MEAL_TYPES = ["breakfast", "lunch", "dinner", "snack"] as const;

interface MealItem { meal_type: string; food_name: string; portion: string; calories: number; protein_g: number; carbs_g: number; fat_g: number; }

export default function CreateMealPlanPage() {
  const router = useRouter();
  const qc = useQueryClient();
  const [loading, setLoading] = useState(false);
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [dailyCal, setDailyCal] = useState("");
  const [proteinG, setProteinG] = useState("");
  const [carbsG, setCarbsG] = useState("");
  const [fatG, setFatG] = useState("");
  const [items, setItems] = useState<MealItem[]>([{ meal_type: "breakfast", food_name: "", portion: "", calories: 0, protein_g: 0, carbs_g: 0, fat_g: 0 }]);

  function addItem() { setItems([...items, { meal_type: "lunch", food_name: "", portion: "", calories: 0, protein_g: 0, carbs_g: 0, fat_g: 0 }]); }
  function removeItem(i: number) { setItems(items.filter((_, idx) => idx !== i)); }
  function updateItem(i: number, field: string, value: any) { setItems(items.map((it, idx) => idx === i ? { ...it, [field]: value } : it)); }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim()) return;
    setLoading(true);
    try {
      await apiPost("/api/nutrition/meal-plans", {
        name, description: description || undefined,
        daily_calories: dailyCal ? parseInt(dailyCal) : undefined,
        protein_g: proteinG ? parseInt(proteinG) : undefined,
        carbs_g: carbsG ? parseInt(carbsG) : undefined,
        fat_g: fatG ? parseInt(fatG) : undefined,
      });
      qc.invalidateQueries({ queryKey: ["meal-plans"] });
      toast.success("Meal plan created");
      router.push("/nutrition");
    } catch (err: any) { toast.error(err.message); }
    setLoading(false);
  }

  return (
    <div className="space-y-5 max-w-3xl">
      <Link href="/nutrition" className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-slate-700"><ArrowLeft className="h-4 w-4" /> Back</Link>
      <h1 className="text-2xl font-bold text-slate-900">Create Meal Plan</h1>

      <form onSubmit={handleSubmit} className="space-y-5">
        <div className="card p-5 space-y-4">
          <div><label className="label">Plan Name *</label><input value={name} onChange={(e) => setName(e.target.value)} className="input" placeholder="e.g. High Protein Cut" required autoFocus /></div>
          <div><label className="label">Description</label><textarea value={description} onChange={(e) => setDescription(e.target.value)} className="input" rows={2} /></div>
        </div>

        <div className="card p-5">
          <h3 className="text-sm font-semibold text-slate-700 mb-3">Daily Macro Targets</h3>
          <div className="grid grid-cols-4 gap-4">
            <div><label className="label">Calories</label><input value={dailyCal} onChange={(e) => setDailyCal(e.target.value)} type="number" className="input" placeholder="2000" /></div>
            <div><label className="label">Protein (g)</label><input value={proteinG} onChange={(e) => setProteinG(e.target.value)} type="number" className="input" placeholder="150" /></div>
            <div><label className="label">Carbs (g)</label><input value={carbsG} onChange={(e) => setCarbsG(e.target.value)} type="number" className="input" placeholder="200" /></div>
            <div><label className="label">Fat (g)</label><input value={fatG} onChange={(e) => setFatG(e.target.value)} type="number" className="input" placeholder="65" /></div>
          </div>
        </div>

        <div className="card overflow-hidden">
          <div className="px-5 py-3 border-b border-slate-100 flex items-center justify-between">
            <h3 className="text-sm font-semibold text-slate-700">Meal Items</h3>
            <button type="button" onClick={addItem} className="btn-ghost text-sf-deepNavy text-xs"><Plus className="h-3.5 w-3.5" /> Add Item</button>
          </div>
          <div className="divide-y divide-slate-50">
            {items.map((item, i) => (
              <div key={i} className="px-5 py-3 grid grid-cols-12 gap-2 items-center">
                <div className="col-span-2">
                  <SearchableSelect
                    options={MEAL_TYPES.map((t) => ({ value: t, label: t.charAt(0).toUpperCase() + t.slice(1) }))}
                    value={item.meal_type}
                    onChange={(v) => updateItem(i, "meal_type", v)}
                    placeholder="Meal type"
                  />
                </div>
                <input value={item.food_name} onChange={(e) => updateItem(i, "food_name", e.target.value)} className="input col-span-3 py-1.5 text-xs" placeholder="Food name" />
                <input value={item.portion} onChange={(e) => updateItem(i, "portion", e.target.value)} className="input col-span-2 py-1.5 text-xs" placeholder="200g" />
                <input value={item.calories || ""} onChange={(e) => updateItem(i, "calories", +e.target.value)} type="number" className="input col-span-1 py-1.5 text-xs text-center" placeholder="cal" />
                <input value={item.protein_g || ""} onChange={(e) => updateItem(i, "protein_g", +e.target.value)} type="number" className="input col-span-1 py-1.5 text-xs text-center" placeholder="P" />
                <input value={item.carbs_g || ""} onChange={(e) => updateItem(i, "carbs_g", +e.target.value)} type="number" className="input col-span-1 py-1.5 text-xs text-center" placeholder="C" />
                <input value={item.fat_g || ""} onChange={(e) => updateItem(i, "fat_g", +e.target.value)} type="number" className="input col-span-1 py-1.5 text-xs text-center" placeholder="F" />
                <button type="button" onClick={() => removeItem(i)} className="p-1 text-slate-400 hover:text-rose-500 col-span-1 justify-self-center"><Trash2 className="h-3.5 w-3.5" /></button>
              </div>
            ))}
          </div>
        </div>

        <div className="flex justify-end gap-3">
          <button type="button" onClick={() => router.back()} className="btn-secondary">Cancel</button>
          <button type="submit" disabled={loading || !name.trim()} className="btn-primary">
            {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <Send className="h-4 w-4" />}
            {loading ? "Creating..." : "Create Plan"}
          </button>
        </div>
      </form>
    </div>
  );
}
