"use client";

import { useState, useMemo } from "react";
import Link from "next/link";
import * as Popover from "@radix-ui/react-popover";
import {
  useTemplate,
  useUpsertTemplate,
  useDeleteTemplate,
} from "@/hooks/useTrainerCardTemplates";
import {
  useTrainerCardTypes,
  useProgramCategories,
  useEquipments,
} from "@/hooks/useNewFeatures";
import { useDLMovements, useDLMenuItems } from "@/hooks/useDigitalLibrary";
import { useSubscriptionPlans } from "@/hooks/useSubscription";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { SearchableSelect } from "@/components/shared/SearchableSelect";
import {
  ArrowLeft, Plus, Trash2, Save, Loader2, Pencil, X,
  ChevronDown, ChevronRight, Layers,
} from "lucide-react";
import { cn } from "@/lib/utils";

// ─── Types ──────────────────────────────────────────────────────

interface CardItem {
  movement_id?: string | null;
  movement_name?: string | null;
  body_part: string;
  equipment?: string | null;
  reps?: number | null;
  sets_count?: number | null;
  sort_order: number;
  breathing_core?: string | null;
  breathing_diaphragm?: string | null;
  allowed_tiers?: string[] | null;
}

interface CardSet {
  set_number: number;
  duration?: string | null;
  equipment_upper?: string | null;
  equipment_lower?: string | null;
  type_id?: string | null;
  type_name?: string | null;
  bpm?: string | null;
  extra_load?: string | null;
  notes?: string | null;
  sort_order: number;
  pattern?: string | null;
  breathing_core?: string | null;
  breathing_diaphragm?: string | null;
  items: CardItem[];
}

interface CardSequence {
  program_category_id: string;
  program_category_name?: string;
  program_category_code?: string;
  duration?: string | null;
  sort_order: number;
  sets: CardSet[];
}

interface TemplateForm {
  notes: string;
  sequences: CardSequence[];
}

const cellBase = "px-2 py-1.5 text-xs border-r border-slate-100 last:border-r-0";
const inpCell = "w-full border border-slate-200 rounded px-1.5 py-1 text-xs focus:outline-none focus:ring-1 focus:ring-sf-warmGold/40 bg-white";

// Subscription packages a movement can be restricted to. Empty allowed_tiers
// means the movement is open to every package (default). The list is sourced
// live from the payment_plans table (see deriveTierPackages) so prices stay
// in sync with what is actually sold.
interface TierPackage {
  code: string;
  label: string; // short price, e.g. "499K"
  name: string; // full plan name for tooltip
}

// Tiers that must NOT appear as movement-gating packages: the free tier itself
// and non-subscription add-ons / waitlist-only plans.
const TIER_PACKAGE_DENYLIST = new Set([
  "free",
  "sf_free",
  "sf_tier_4_waitlist",
  "sf_lab_consultation",
]);

// Used until the live plan list loads (keeps the editor usable offline).
const FALLBACK_TIER_PACKAGES: TierPackage[] = [
  { code: "sf_tier_2", label: "499K", name: "Performance Program" },
  { code: "sf_tier_3", label: "799K", name: "System Active" },
];

function formatPriceShort(price: number): string {
  if (!price || price <= 0) return "Gratis";
  if (price >= 1_000_000) {
    const v = price / 1_000_000;
    return `${Number.isInteger(v) ? v : v.toFixed(1)}jt`;
  }
  if (price >= 1_000) return `${Math.round(price / 1_000)}K`;
  return `${price}`;
}

// deriveTierPackages turns the grouped /api/subscription/plans response
// ([{ tier, monthly, annual }]) into the package toggles shown in the Paket
// column, sorted cheapest-first with a price label.
function deriveTierPackages(plansData: any): TierPackage[] {
  const groups: any[] = plansData?.data ?? plansData ?? [];
  if (!Array.isArray(groups) || groups.length === 0) return FALLBACK_TIER_PACKAGES;
  const pkgs: (TierPackage & { price: number })[] = [];
  for (const g of groups) {
    const tier = g?.tier;
    if (!tier || TIER_PACKAGE_DENYLIST.has(tier)) continue;
    const plan = g.monthly || g.quarterly || g.annual;
    if (!plan) continue;
    pkgs.push({
      code: tier,
      label: formatPriceShort(plan.price),
      name: plan.name || tier,
      price: plan.price ?? 0,
    });
  }
  if (pkgs.length === 0) return FALLBACK_TIER_PACKAGES;
  pkgs.sort((a, b) => a.price - b.price);
  return pkgs.map(({ code, label, name }) => ({ code, label, name }));
}

export default function TemplateEditorPage({ params }: { params: { level: string } }) {
  const level = params.level;
  const { data: templateResponse, isLoading: templateLoading } = useTemplate(level);
  const { data: typesData } = useTrainerCardTypes();
  const { data: categoriesData } = useProgramCategories({ limit: 100 });
  const { data: movementsData } = useDLMovements({ limit: 1000 });
  const { data: equipUpperData } = useEquipments({ category: "upper", limit: 100 });
  const { data: equipLowerData } = useEquipments({ category: "lower", limit: 100 });

  const levelNum = parseInt(level, 10);
  // The "free" level is non-numeric; fall back to undefined so the Digital
  // Library menu query doesn't send level=NaN.
  const dlLevel = Number.isNaN(levelNum) ? undefined : levelNum;
  const { data: fcMenuItemsData } = useDLMenuItems("fc", dlLevel);
  const { data: ccMenuItemsData } = useDLMenuItems("cc", dlLevel);
  const { data: mcMenuItemsData } = useDLMenuItems("mc", dlLevel);

  // Movement-access packages, sourced live from the payment plans (prices shown).
  const { data: plansData } = useSubscriptionPlans();
  const tierPackages = useMemo(() => deriveTierPackages(plansData), [plansData]);

  const upsertTemplate = useUpsertTemplate();
  const deleteTemplate = useDeleteTemplate();

  const dbTemplate = templateResponse?.data as any;
  const types = (typesData?.data ?? []) as any[];
  const programCategories = (categoriesData?.data ?? []) as any[];
  const movements = (movementsData?.data ?? []) as any[];
  const equipUpper = (equipUpperData?.data ?? []) as any[];
  const equipLower = (equipLowerData?.data ?? []) as any[];

  const [editing, setEditing] = useState(false);
  const [form, setForm] = useState<TemplateForm | null>(null);
  const [deleteOpen, setDeleteOpen] = useState(false);

  // Options mapping
  const typeOptions = useMemo(() =>
    types.filter((t: any) => t.is_active).map((t: any) => ({
      value: t.id, label: t.name, sublabel: t.description || "",
    })), [types]);

  const movementOptions = useMemo(() =>
    movements
      .filter((m: any) => {
        const nameMatch = m.name.match(/\((FC|CC|MC)\s*-\s*Level\s*(\d+)\)/i);
        const mLevel = nameMatch ? parseInt(nameMatch[2]) : null;
        const effectiveLevel = mLevel !== null ? mLevel : m.level;

        const cardLevelMatch = params.level.match(/\d+/);
        const cardLevelNum = cardLevelMatch ? parseInt(cardLevelMatch[0]) : 1;
        
        if (effectiveLevel != null && effectiveLevel !== cardLevelNum) {
          return false;
        }
        return true;
      })
      .map((m: any) => {
        const nameMatch = m.name.match(/\((FC|CC|MC)\s*-\s*Level\s*(\d+)\)/i);
        const mCategory = nameMatch ? nameMatch[1].toUpperCase() : "";
        const mLevel = nameMatch ? parseInt(nameMatch[2]) : "";
        const sectionName = nameMatch ? `${mCategory} - Level ${mLevel}` : (m.pattern ? "Pola: " + m.pattern : "Lainnya");

        return {
          value: m.id, 
          label: m.name, 
          sublabel: m.body_part, 
          pattern: m.pattern || "", 
          section: sectionName,
          extractedCategory: mCategory
        };
      }), [movements, params.level]);

  const movementMap = useMemo(() => {
    const map: Record<string, string> = {};
    movements.forEach((m: any) => { map[m.id] = m.name; });
    return map;
  }, [movements]);

  const equipUpperOptions = useMemo(() =>
    equipUpper.filter((e: any) => e.is_active).map((e: any) => ({
      value: e.name, label: e.name,
    })), [equipUpper]);

  const equipLowerOptions = useMemo(() =>
    equipLower.filter((e: any) => e.is_active).map((e: any) => ({
      value: e.name, label: e.name,
    })), [equipLower]);

  // Map digital library menu items into sequential card sets (max 3 sets)
  const autoPopulatedSequences = useMemo(() => {
    if (!categoriesData || !fcMenuItemsData || !ccMenuItemsData || !mcMenuItemsData) return [];

    const getItemsForCategory = (code: string) => {
      const c = code.toLowerCase();
      if (c === "functional" || c === "fc") return fcMenuItemsData?.data || [];
      if (c === "cardiorespiratory" || c === "cc") return ccMenuItemsData?.data || [];
      if (c === "metabolic" || c === "mc") return mcMenuItemsData?.data || [];
      return [];
    };

    return programCategories
      .filter((p: any) => p.is_active !== false)
      .map((p: any, i: number) => {
        const dlItems = getItemsForCategory(p.code) as any[];

        // Group by body part
        const uppers = dlItems.filter((item: any) => item.body_part === "upper");
        const lowers = dlItems.filter((item: any) => item.body_part === "lower");
        const cores = dlItems.filter((item: any) => item.body_part === "core");

        const maxSets = Math.min(3, Math.max(uppers.length, lowers.length, cores.length));
        const sets: CardSet[] = [];

        for (let sIdx = 0; sIdx < maxSets; sIdx++) {
          sets.push({
            set_number: sIdx + 1,
            duration: "",
            equipment_upper: "",
            equipment_lower: "",
            type_id: "",
            bpm: "",
            extra_load: "",
            notes: "",
            sort_order: sIdx,
            items: [],
          });
        }

        // Distribute upper body movements
        uppers.forEach((up, idx) => {
          const sIdx = idx % maxSets;
          sets[sIdx].items.push({
            movement_id: up.movement_id,
            movement_name: up.movement?.name || "",
            body_part: "upper",
            reps: 20,
            sets_count: 1,
            sort_order: sets[sIdx].items.length,
          });
        });

        // Distribute lower body movements
        lowers.forEach((low, idx) => {
          const sIdx = idx % maxSets;
          sets[sIdx].items.push({
            movement_id: low.movement_id,
            movement_name: low.movement?.name || "",
            body_part: "lower",
            reps: 20,
            sets_count: 1,
            sort_order: sets[sIdx].items.length,
          });
        });

        // Distribute core movements
        cores.forEach((cor, idx) => {
          const sIdx = idx % maxSets;
          sets[sIdx].items.push({
            movement_id: cor.movement_id,
            movement_name: cor.movement?.name || "",
            body_part: "core",
            reps: 20,
            sets_count: 1,
            sort_order: sets[sIdx].items.length,
          });
        });

        return {
          program_category_id: p.id,
          program_category_name: p.name,
          program_category_code: p.code,
          duration: "",
          sort_order: i,
          sets,
        };
      });
  }, [categoriesData, programCategories, fcMenuItemsData, ccMenuItemsData, mcMenuItemsData]);

  // ── Form init ──────────────────────────────────────────────
  function startEdit() {
    if (dbTemplate) {
      setForm({
        notes: dbTemplate.notes || "",
        sequences: (dbTemplate.sequences || []).map((s: any, si: number) => ({
          program_category_id: s.program_category_id,
          program_category_name: s.program_category_name,
          program_category_code: s.program_category_code,
          duration: s.duration || "",
          sort_order: si,
          sets: (s.sets || []).map((set: any, seti: number) => ({
            set_number: set.set_number,
            duration: set.duration || "",
            equipment_upper: set.equipment_upper || "",
            equipment_lower: set.equipment_lower || "",
            type_id: set.type_id || "",
            type_name: set.type_name || "",
            bpm: set.bpm || "",
            extra_load: set.extra_load || "",
            notes: set.notes || "",
            sort_order: seti,
            pattern: set.pattern || "",
            breathing_core: set.breathing_core || "",
            breathing_diaphragm: set.breathing_diaphragm || "",
            items: (set.items || []).map((item: any, ii: number) => ({
              movement_id: item.movement_id || null,
              movement_name: item.movement_name || "",
              body_part: item.body_part || "upper",
              equipment: item.equipment || "",
              reps: item.reps ?? null,
              sets_count: item.sets_count ?? 1,
              sort_order: ii,
              breathing_core: item.breathing_core || "",
              breathing_diaphragm: item.breathing_diaphragm || "",
              allowed_tiers: item.allowed_tiers || [],
            })),
          })),
        })),
      });
    } else {
      // Default: create template pre-populated from Digital Library if available, otherwise empty sets
      const hasAutoPopulated = autoPopulatedSequences.some((s: any) => s.sets.length > 0);
      setForm({
        notes: "",
        sequences: hasAutoPopulated
          ? autoPopulatedSequences
          : programCategories
              .filter((p: any) => p.is_active !== false)
              .map((p: any, i: number) => ({
                program_category_id: p.id,
                program_category_name: p.name,
                program_category_code: p.code,
                duration: "",
                sort_order: i,
                sets: [],
              })),
      });
    }
    setEditing(true);
  }

  function cancelEdit() { setForm(null); setEditing(false); }

  async function handleSave() {
    if (!form) return;
    const payload = {
      level,
      notes: form.notes || null,
      sequences: form.sequences.map((seq) => ({
        program_category_id: seq.program_category_id,
        duration: seq.duration || null,
        sort_order: seq.sort_order,
        sets: seq.sets.map((set) => ({
          set_number: set.set_number,
          duration: set.duration || null,
          equipment_upper: set.equipment_upper || null,
          equipment_lower: set.equipment_lower || null,
          type_id: set.type_id || null,
          bpm: set.bpm || null,
          extra_load: set.extra_load || null,
          notes: set.notes || null,
          sort_order: set.sort_order,
          pattern: set.pattern || null,
          breathing_core: set.breathing_core || null,
          breathing_diaphragm: set.breathing_diaphragm || null,
          items: set.items.map((item) => ({
            movement_id: item.movement_id || null,
            movement_name: item.movement_name || null,
            body_part: item.body_part,
            equipment: item.equipment || null,
            reps: item.reps || null,
            sets_count: item.sets_count || 1,
            sort_order: item.sort_order,
            breathing_core: item.breathing_core || null,
            breathing_diaphragm: item.breathing_diaphragm || null,
            allowed_tiers: item.allowed_tiers || [],
          })),
        })),
      })),
    };
    await upsertTemplate.mutateAsync(payload);
    setEditing(false);
    setForm(null);
  }

  async function handleDelete() {
    await deleteTemplate.mutateAsync(level);
    setDeleteOpen(false);
  }

  // ── Form mutation helpers ──────────────────────────────────
  function updateSeq(si: number, patch: Partial<CardSequence>) {
    if (!form) return;
    const seqs = [...form.sequences];
    seqs[si] = { ...seqs[si], ...patch };
    setForm({ ...form, sequences: seqs });
  }

  function addSet(si: number) {
    if (!form) return;
    const seqs = [...form.sequences];
    const sets = [...seqs[si].sets];
    
    sets.push({
      set_number: sets.length + 1,
      duration: "", equipment_upper: "", equipment_lower: "",
      type_id: "", bpm: "", extra_load: "", notes: "",
      sort_order: sets.length, items: [],
    });
    seqs[si] = { ...seqs[si], sets };
    setForm({ ...form, sequences: seqs });
  }

  function removeSet(si: number, seti: number) {
    if (!form) return;
    const seqs = [...form.sequences];
    const sets = seqs[si].sets.filter((_, i) => i !== seti);
    sets.forEach((s, i) => { s.sort_order = i; s.set_number = i + 1; });
    seqs[si] = { ...seqs[si], sets };
    setForm({ ...form, sequences: seqs });
  }

  function updateSet(si: number, seti: number, patch: Partial<CardSet>) {
    if (!form) return;
    const seqs = [...form.sequences];
    const sets = [...seqs[si].sets];
    sets[seti] = { ...sets[seti], ...patch };
    seqs[si] = { ...seqs[si], sets };
    setForm({ ...form, sequences: seqs });
  }

  function addItem(si: number, seti: number, bodyPart: string = "upper") {
    if (!form) return;
    const seqs = [...form.sequences];
    const sets = [...seqs[si].sets];
    const items = [...sets[seti].items];
    items.push({
      movement_id: null, movement_name: "", body_part: bodyPart,
      equipment: "", reps: 20, sets_count: 1, sort_order: items.length,
    });
    sets[seti] = { ...sets[seti], items };
    seqs[si] = { ...seqs[si], sets };
    setForm({ ...form, sequences: seqs });
  }

  function removeItem(si: number, seti: number, ii: number) {
    if (!form) return;
    const seqs = [...form.sequences];
    const sets = [...seqs[si].sets];
    const items = sets[seti].items.filter((_, i) => i !== ii);
    items.forEach((item, i) => { item.sort_order = i; });
    sets[seti] = { ...sets[seti], items };
    seqs[si] = { ...seqs[si], sets };
    setForm({ ...form, sequences: seqs });
  }

  function updateItem(si: number, seti: number, ii: number, patch: Partial<CardItem>) {
    if (!form) return;
    const seqs = [...form.sequences];
    const sets = [...seqs[si].sets];
    const items = [...sets[seti].items];
    items[ii] = { ...items[ii], ...patch };
    sets[seti] = { ...sets[seti], items };
    seqs[si] = { ...seqs[si], sets };
    setForm({ ...form, sequences: seqs });
  }

  // ── Loading ────────────────────────────────────────────────
  if (templateLoading) {
    return (
      <div className="flex justify-center py-20">
        <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
      </div>
    );
  }

  const displayData = editing ? form : dbTemplate;
  const sequences: CardSequence[] = displayData?.sequences || [];

  return (
    <div className="space-y-4 max-w-[1400px]">
      <Link href="/training-card-templates" className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-slate-700">
        <ArrowLeft className="h-4 w-4" /> Kembali ke Daftar Template
      </Link>

      {/* ═══ TEMPLATE HEADER ════════════════════════════════════ */}
      <div className="border border-slate-200 rounded-lg overflow-hidden shadow-sm">
        {/* Title bar */}
        <div className="bg-slate-800 text-white px-5 py-3 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Layers className="h-5 w-5 text-sf-warmGold" />
            <h1 className="text-lg font-bold tracking-widest uppercase">
              {level === "free" ? "TEMPLATE FREE (TANPA BAYAR)" : `TEMPLATE LEVEL ${level}`}
            </h1>
          </div>
          <div className="flex items-center gap-2">
            {editing ? (
              <>
                <button
                  type="button"
                  onClick={() => {
                    if (confirm("Apakah Anda yakin ingin memuat semua gerakan berdasarkan data di Digital Library? Ini akan menimpa perubahan saat ini.")) {
                      setForm(prev => prev ? { ...prev, sequences: autoPopulatedSequences } : null);
                    }
                  }}
                  className="px-3 py-1.5 text-xs rounded-md bg-sf-warmGold text-slate-900 hover:bg-sf-warmGold/95 flex items-center gap-1.5 transition-colors font-semibold"
                >
                  <Layers className="h-3.5 w-3.5" /> Muat dari Digital Library
                </button>
                <button onClick={cancelEdit} className="px-3 py-1.5 text-xs rounded-md bg-white/10 hover:bg-white/20 flex items-center gap-1.5 transition-colors">
                  <X className="h-3.5 w-3.5" />Batal
                </button>
                <button
                  onClick={handleSave}
                  disabled={upsertTemplate.isPending}
                  className="px-4 py-1.5 text-xs rounded-md bg-sf-deepNavy hover:bg-sf-deepNavy disabled:opacity-50 flex items-center gap-1.5 font-medium transition-colors"
                >
                  {upsertTemplate.isPending ? <Loader2 className="h-3.5 w-3.5 animate-spin" /> : <Save className="h-3.5 w-3.5" />}
                  Simpan
                </button>
              </>
            ) : (
              <>
                <button onClick={startEdit} className="px-3 py-1.5 text-xs rounded-md bg-white/10 hover:bg-white/20 flex items-center gap-1.5 transition-colors">
                  <Pencil className="h-3.5 w-3.5" /> Edit
                </button>
                {dbTemplate && (
                  <button onClick={() => setDeleteOpen(true)} className="px-3 py-1.5 text-xs rounded-md bg-red-500/80 hover:bg-red-500 flex items-center gap-1.5 transition-colors">
                    <Trash2 className="h-3.5 w-3.5" /> Hapus
                  </button>
                )}
              </>
            )}
          </div>
        </div>

        {/* Notes row */}
        <div className="bg-slate-50 border-t border-slate-200 px-4 py-3 flex items-center gap-4">
          <span className="text-xs font-bold text-slate-600 w-28 shrink-0">Catatan Internal:</span>
          {editing && form ? (
            <input
              type="text"
              value={form.notes}
              onChange={(e) => setForm({ ...form, notes: e.target.value })}
              className={cn(inpCell, "flex-1")}
              placeholder="Catatan mengenai target level ini..."
            />
          ) : (
            <span className="text-xs text-slate-700 italic">{dbTemplate?.notes || "-"}</span>
          )}
        </div>
      </div>

      {/* ═══ NO DATA STATE ═════════════════════════════════════ */}
      {!dbTemplate && !editing && (
        <div className="border border-dashed border-slate-300 rounded-lg p-12 text-center">
          <p className="text-slate-400 text-sm mb-4">
            {level === "free" ? "Belum ada data template untuk tier Free" : `Belum ada data template untuk Level ${level}`}
          </p>
          <button onClick={startEdit} className="px-4 py-2 text-xs font-medium text-white bg-sf-deepNavy hover:bg-sf-deepNavy/90 rounded-md transition-colors inline-flex items-center gap-1.5">
            <Plus className="h-4 w-4" /> Buat Template Baru
          </button>
        </div>
      )}

      {/* ═══ SEQUENCES (FC / CC / MC) ═════════════════════════ */}
      {sequences.map((seq, si) => {
        const code = seq.program_category_code || "";
        const isMetabolic = code === "metabolic" || code === "MC";
        return (
          <SequenceTable
            key={seq.program_category_id}
            seq={seq}
            si={si}
            level={level}
            isMetabolic={isMetabolic}
            editing={editing}
            typeOptions={typeOptions}
            movementOptions={movementOptions}
            movementMap={movementMap}
            types={types}
            tierPackages={tierPackages}
            equipUpperOptions={equipUpperOptions}
            equipLowerOptions={equipLowerOptions}
            onUpdateSeq={(p) => updateSeq(si, p)}
            onAddSet={() => addSet(si)}
            onRemoveSet={(seti) => removeSet(si, seti)}
            onUpdateSet={(seti, p) => updateSet(si, seti, p)}
            onAddItem={(seti, bp) => addItem(si, seti, bp)}
            onRemoveItem={(seti, ii) => removeItem(si, seti, ii)}
            onUpdateItem={(seti, ii, p) => updateItem(si, seti, ii, p)}
          />
        );
      })}
    </div>
  );
}

function SequenceTable({
  seq, si, level, isMetabolic, editing, typeOptions, movementOptions, movementMap, types,
  tierPackages, equipUpperOptions, equipLowerOptions,
  onUpdateSeq, onAddSet, onRemoveSet, onUpdateSet, onAddItem, onRemoveItem, onUpdateItem,
}: {
  seq: CardSequence; si: number; level: string; isMetabolic: boolean; editing: boolean;
  typeOptions: { value: string; label: string; sublabel?: string }[];
  movementOptions: { value: string; label: string; sublabel?: string; pattern?: string | null }[];
  movementMap: Record<string, string>;
  types: any[];
  tierPackages: TierPackage[];
  equipUpperOptions: { value: string; label: string }[];
  equipLowerOptions: { value: string; label: string }[];
  onUpdateSeq: (p: Partial<CardSequence>) => void;
  onAddSet: () => void;
  onRemoveSet: (seti: number) => void;
  onUpdateSet: (seti: number, p: Partial<CardSet>) => void;
  onAddItem: (seti: number, bodyPart: string) => void;
  onRemoveItem: (seti: number, ii: number) => void;
  onUpdateItem: (seti: number, ii: number, p: Partial<CardItem>) => void;
}) {
  const [expanded, setExpanded] = useState(true);
  const code = seq.program_category_code || "";

  // Resolve options based on Cardio / Metabolic / Functional
  let upperOptions = equipUpperOptions;
  let lowerOptions = equipLowerOptions;

  if (code === "cardiorespiratory" || code === "CC") {
    upperOptions = [
      { value: "0.25 kg", label: "0.25 kg" },
      { value: "0.5 kg", label: "0.5 kg" },
      { value: "0.75 kg", label: "0.75 kg" },
      { value: "1 kg", label: "1 kg" },
      { value: "1.5 kg", label: "1.5 kg" },
    ];
    lowerOptions = [
      { value: "0.75 kg", label: "0.75 kg" },
      { value: "1 kg", label: "1 kg" },
      { value: "1.5 kg", label: "1.5 kg" },
      { value: "2 kg", label: "2 kg" },
      { value: "3 kg", label: "3 kg" },
    ];
  } else if (code === "metabolic" || code === "MC") {
    upperOptions = [
      { value: "1 kg", label: "1 kg" },
      { value: "1.5 kg", label: "1.5 kg" },
      { value: "2 kg", label: "2 kg" },
      { value: "3 kg", label: "3 kg" },
      { value: "4 kg", label: "4 kg" },
    ];
    lowerOptions = [
      { value: "1.5 kg", label: "1.5 kg" },
      { value: "2 kg", label: "2 kg" },
      { value: "2.5 kg", label: "2.5 kg" },
      { value: "3 kg", label: "3 kg" },
      { value: "4 kg", label: "4 kg" },
    ];
  }

  const seqBg =
    code === "functional" || code === "FC" ? "bg-blue-600" :
    code === "cardiorespiratory" || code === "CC" ? "bg-orange-500" :
    code === "metabolic" || code === "MC" ? "bg-purple-600" : "bg-slate-600";

  return (
    <div className="border border-slate-200 rounded-lg overflow-hidden shadow-sm">
      <div className={cn("text-white px-4 py-2 flex items-center justify-between cursor-pointer select-none", seqBg)}
           onClick={() => setExpanded(!expanded)}>
         <div className="flex items-center gap-2">
           {expanded ? <ChevronDown className="h-4 w-4" /> : <ChevronRight className="h-4 w-4" />}
           <span className="font-bold text-sm tracking-wide uppercase">{seq.program_category_name || "Sequence"}</span>
         </div>
         <div className="flex items-center gap-3 text-xs">
           {editing ? (
             <input
               value={seq.duration || ""}
               onChange={(e) => onUpdateSeq({ duration: e.target.value })}
               onClick={(e) => e.stopPropagation()}
               className="bg-white/20 rounded-md px-2.5 py-1 text-xs text-white placeholder-white/50 w-28 focus:outline-none focus:bg-white/30"
               placeholder="10-15 mins"
             />
           ) : (
             seq.duration && <span className="bg-white/20 rounded-md px-2.5 py-1">{seq.duration}</span>
           )}
         </div>
      </div>

      {expanded && (
        <div className="p-4 space-y-4 bg-slate-50/50">
          {seq.sets.map((set, seti) => (
            <SetBlock
              key={seti}
              set={set}
              seti={seti}
              level={level}
              isMetabolic={isMetabolic}
              editing={editing}
              typeOptions={typeOptions}
              movementOptions={movementOptions}
              movementMap={movementMap}
              types={types}
              tierPackages={tierPackages}
              upperOptions={upperOptions}
              lowerOptions={lowerOptions}
              onUpdateSet={(p) => onUpdateSet(seti, p)}
              onRemoveSet={() => onRemoveSet(seti)}
              onAddItem={(bp) => onAddItem(seti, bp)}
              onRemoveItem={(ii) => onRemoveItem(seti, ii)}
              onUpdateItem={(ii, p) => onUpdateItem(seti, ii, p)}
            />
          ))}

          {seq.sets.length === 0 && !editing && (
            <div className="text-center py-6 text-slate-400">
              Tidak ada set
            </div>
          )}

          {/* Add Set */}
          {editing && (
            <button onClick={onAddSet} className="w-full py-2.5 mt-2 rounded-lg border-2 border-dashed border-slate-300 text-slate-500 hover:text-sf-deepNavy hover:border-sf-deepNavy hover:bg-sf-deepNavy/5 font-medium flex items-center justify-center gap-2 transition-colors">
              <Plus className="h-4 w-4" /> Tambah Set Baru
            </button>
          )}
        </div>
      )}
    </div>
  );
}

function SetBlock({
  set, seti, level, isMetabolic, editing, typeOptions, movementOptions, movementMap, types,
  tierPackages, upperOptions, lowerOptions,
  onUpdateSet, onRemoveSet, onAddItem, onRemoveItem, onUpdateItem,
}: {
  set: CardSet; seti: number; level: string; isMetabolic: boolean; editing: boolean;
  typeOptions: { value: string; label: string; sublabel?: string }[];
  movementOptions: { value: string; label: string; sublabel?: string; pattern?: string | null }[];
  movementMap: Record<string, string>;
  types: any[];
  tierPackages: TierPackage[];
  upperOptions: { value: string; label: string }[];
  lowerOptions: { value: string; label: string }[];
  onUpdateSet: (p: Partial<CardSet>) => void;
  onRemoveSet: () => void;
  onAddItem: (bodyPart: string) => void;
  onRemoveItem: (ii: number) => void;
  onUpdateItem: (ii: number, p: Partial<CardItem>) => void;
}) {
  const items = set.items || [];
  const selectedPatterns = set.pattern ? set.pattern.split(",").map(p => p.trim()).filter(Boolean) : [];

  return (
    <div className="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden flex flex-col">
      {/* HEADER CARD */}
      <div className="bg-slate-100 border-b border-slate-200 px-4 py-3 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <span className="bg-sf-deepNavy text-white font-bold text-xs px-2.5 py-1 rounded-md">
            SET {set.set_number}
          </span>
        </div>
        {editing && (
          <button onClick={onRemoveSet} className="text-slate-400 hover:text-red-500 hover:bg-red-50 p-1.5 rounded transition-colors" title="Hapus Set">
            <Trash2 className="h-4 w-4" />
          </button>
        )}
      </div>

      <div className="p-4 flex flex-col md:flex-row gap-6">
        {/* LEFT COLUMN: Properties */}
        <div className="md:w-1/3 space-y-4">
          <div className="grid grid-cols-2 gap-4">
            {/* Pattern */}
            <div className="space-y-1.5 col-span-2">
              <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Pola Gerak</label>
              {editing ? (
                <Popover.Root>
                  <Popover.Trigger asChild>
                    <button type="button" className="text-left truncate bg-white border border-slate-200 rounded-lg px-3 py-2 text-sm text-slate-700 w-full flex items-center justify-between hover:border-slate-300 transition-colors">
                      <span className="truncate">{selectedPatterns.length > 0 ? selectedPatterns.join(", ") : "Pilih Pola..."}</span>
                      <ChevronDown className="h-4 w-4 text-slate-400 shrink-0 ml-1" />
                    </button>
                  </Popover.Trigger>
                  <Popover.Portal>
                    <Popover.Content align="start" className="z-50 bg-white rounded-lg shadow-xl border border-slate-200 p-2 space-y-1 w-[220px]">
                      {[
                        "Isolate FC", "Dynamic FC", "Isolate CC", "Dynamic CC", "Metabolic Basic", "Metabolic Core"
                      ].map((p) => {
                        const isChecked = selectedPatterns.includes(p);
                        return (
                          <label key={p} className="flex items-center gap-3 px-3 py-2 hover:bg-slate-50 rounded-md cursor-pointer select-none transition-colors">
                            <input
                              type="checkbox"
                              checked={isChecked}
                              onChange={() => {
                                let next;
                                if (isChecked) {
                                  next = selectedPatterns.filter(x => x !== p);
                                } else {
                                  next = [...selectedPatterns, p];
                                }
                                onUpdateSet({ pattern: next.join(",") });
                              }}
                              className="rounded border-slate-300 text-sf-deepNavy focus:ring-sf-warmGold/40 h-4 w-4"
                            />
                            <span className="text-sm font-medium text-slate-700">{p}</span>
                          </label>
                        );
                      })}
                    </Popover.Content>
                  </Popover.Portal>
                </Popover.Root>
              ) : (
                <div className="text-sm font-medium text-slate-800 bg-slate-50 border border-slate-100 rounded-lg px-3 py-2">
                  {set.pattern ? set.pattern.split(",").join(", ") : "-"}
                </div>
              )}
            </div>

            {/* Breathing */}
            <div className="space-y-1.5 col-span-2 md:col-span-1">
              <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Breathing</label>
              {editing ? (
                <select
                  value={set.breathing_core || ""}
                  onChange={(e) => onUpdateSet({ breathing_core: e.target.value })}
                  className="w-full bg-white border border-slate-200 rounded-lg px-3 py-2 text-sm text-slate-700 focus:outline-none focus:ring-2 focus:ring-sf-deepNavy/20 focus:border-sf-deepNavy transition-all"
                >
                  <option value="">Pilih...</option>
                  <option value="Core">Core</option>
                  <option value="Diafragma">Diafragma</option>
                </select>
              ) : (
                <div className="text-sm font-medium text-slate-800 bg-slate-50 border border-slate-100 rounded-lg px-3 py-2">
                  {set.breathing_core || "-"}
                </div>
              )}
            </div>

            {/* Duration */}
            <div className="space-y-1.5 col-span-1">
              <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Durasi</label>
              {editing ? (
                <input 
                  value={set.duration || ""} 
                  onChange={(e) => onUpdateSet({ duration: e.target.value })} 
                  className="w-full bg-white border border-slate-200 rounded-lg px-3 py-2 text-sm text-slate-700 focus:outline-none focus:ring-2 focus:ring-sf-deepNavy/20 focus:border-sf-deepNavy transition-all" 
                  placeholder="e.g. 5 mins" 
                />
              ) : (
                <div className="text-sm font-medium text-slate-800 bg-slate-50 border border-slate-100 rounded-lg px-3 py-2">{set.duration || "-"}</div>
              )}
            </div>

            {/* BPM / Extra Load */}
            <div className="space-y-1.5 col-span-1">
              <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">{isMetabolic ? "Extra Load" : "BPM / Zona"}</label>
              {editing ? (
                <input
                  value={isMetabolic ? (set.extra_load || "") : (set.bpm || "")}
                  onChange={(e) => isMetabolic ? onUpdateSet({ extra_load: e.target.value }) : onUpdateSet({ bpm: e.target.value })}
                  className="w-full bg-white border border-slate-200 rounded-lg px-3 py-2 text-sm text-slate-700 focus:outline-none focus:ring-2 focus:ring-sf-deepNavy/20 focus:border-sf-deepNavy transition-all"
                  placeholder={isMetabolic ? "10kg" : "120 bpm"}
                />
              ) : (
                <div className="text-sm font-medium text-slate-800 bg-slate-50 border border-slate-100 rounded-lg px-3 py-2">
                  {isMetabolic ? (set.extra_load || "-") : (set.bpm || "-")}
                </div>
              )}
            </div>
          </div>

          <div className="space-y-3 pt-3 border-t border-slate-100">
            <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Peralatan (Equipment)</label>
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5">
                <span className="text-[11px] font-semibold text-slate-500">Upper</span>
                {editing ? (
                  <SearchableSelect
                    options={upperOptions}
                    value={set.equipment_upper || ""}
                    onChange={(v) => onUpdateSet({ equipment_upper: v })}
                    placeholder="Pilih..."
                    searchPlaceholder="Cari..."
                  />
                ) : (
                  <div className="text-sm font-medium text-slate-700">{set.equipment_upper ? formatWeight(set.equipment_upper) : "-"}</div>
                )}
              </div>
              <div className="space-y-1.5">
                <span className="text-[11px] font-semibold text-slate-500">Lower</span>
                {editing ? (
                  <SearchableSelect
                    options={lowerOptions}
                    value={set.equipment_lower || ""}
                    onChange={(v) => onUpdateSet({ equipment_lower: v })}
                    placeholder="Pilih..."
                    searchPlaceholder="Cari..."
                  />
                ) : (
                  <div className="text-sm font-medium text-slate-700">{set.equipment_lower ? formatWeight(set.equipment_lower) : "-"}</div>
                )}
              </div>
            </div>
          </div>

          {/* Notes */}
          <div className="space-y-1.5 pt-3 border-t border-slate-100">
            <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Catatan Khusus (Notes)</label>
            {editing ? (
              <textarea
                value={set.notes || ""}
                onChange={(e) => onUpdateSet({ notes: e.target.value })}
                className="w-full bg-white border border-slate-200 rounded-lg px-3 py-2 text-sm text-slate-700 focus:outline-none focus:ring-2 focus:ring-sf-deepNavy/20 focus:border-sf-deepNavy transition-all min-h-[80px]"
                placeholder="Tulis instruksi tambahan..."
              />
            ) : (
              <div className="text-sm text-slate-600 bg-amber-50/50 border border-amber-100 rounded-lg px-3 py-2 min-h-[60px] whitespace-pre-wrap">
                {set.notes || <span className="text-slate-400 italic">Tidak ada catatan</span>}
              </div>
            )}
          </div>
        </div>

        {/* RIGHT COLUMN: Movements */}
        <div className="md:w-2/3 border-t md:border-t-0 md:border-l border-slate-100 md:pl-6 pt-4 md:pt-0">
          <div className="flex items-center justify-between mb-4">
            <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Daftar Gerakan (Movements)</label>
            {editing && (
              <div className="flex gap-2">
                <button onClick={() => onAddItem("upper")} className="px-2.5 py-1 text-[11px] font-bold rounded bg-blue-50 text-blue-600 hover:bg-blue-100 transition-colors">
                  + Upper
                </button>
                <button onClick={() => onAddItem("lower")} className="px-2.5 py-1 text-[11px] font-bold rounded bg-green-50 text-green-600 hover:bg-green-100 transition-colors">
                  + Lower
                </button>
                {isMetabolic && (
                  <button onClick={() => onAddItem("core")} className="px-2.5 py-1 text-[11px] font-bold rounded bg-amber-50 text-amber-600 hover:bg-amber-100 transition-colors">
                    + Core
                  </button>
                )}
              </div>
            )}
          </div>

          <div className="space-y-3">
            {items.length === 0 ? (
              <div className="text-center py-8 bg-slate-50 border border-dashed border-slate-200 rounded-xl">
                <p className="text-sm text-slate-400 font-medium">Belum ada gerakan di set ini.</p>
              </div>
            ) : (
              items.map((item, ii) => (
                <div key={ii} className="bg-slate-50 border border-slate-200 rounded-xl p-3 flex flex-col md:flex-row gap-4 relative group hover:border-slate-300 transition-colors">
                  
                  {/* Bagian Tubuh Badge */}
                  <div className="shrink-0 pt-1">
                    <span className={cn(
                      "inline-block px-2 py-1 text-[10px] font-bold rounded uppercase tracking-wider",
                      item.body_part === "upper" ? "bg-blue-100 text-blue-700" :
                      item.body_part === "lower" ? "bg-green-100 text-green-700" :
                      "bg-amber-100 text-amber-700"
                    )}>
                      {item.body_part}
                    </span>
                  </div>

                  <div className="flex-1 space-y-3">
                    {/* Gerakan */}
                    <div className="flex items-start justify-between gap-4">
                      <div className="flex-1">
                        {editing ? (
                          <MovementSelect
                            options={movementOptions}
                            movementMap={movementMap}
                            item={item}
                            bodyPart={item.body_part || ""}
                            selectedPatterns={selectedPatterns}
                            onUpdate={(p) => onUpdateItem(ii, p)}
                          />
                        ) : (
                          <div className="font-bold text-slate-800 text-base">{item.movement_name || "Gerakan tidak diketahui"}</div>
                        )}
                      </div>
                      
                      {editing && (
                        <button onClick={() => onRemoveItem(ii)} className="text-slate-400 hover:text-red-500 hover:bg-red-50 p-1.5 rounded transition-colors shrink-0" title="Hapus Gerakan">
                          <Trash2 className="h-4 w-4" />
                        </button>
                      )}
                    </div>

                    {/* Metrik: Reps & Sets & Paket */}
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                      <div>
                        <span className="text-[10px] text-slate-500 font-medium block mb-1">Reps</span>
                        {editing ? (
                          <input type="number" value={item.reps ?? ""} onChange={(e) => onUpdateItem(ii, { reps: e.target.value ? +e.target.value : null })} className="w-full bg-white border border-slate-200 rounded px-2 py-1 text-sm text-center focus:outline-none focus:border-sf-deepNavy" />
                        ) : (
                          <div className="font-bold text-slate-700 text-sm bg-white border border-slate-100 rounded px-2 py-1 text-center">{item.reps ?? "-"}</div>
                        )}
                      </div>
                      <div>
                        <span className="text-[10px] text-slate-500 font-medium block mb-1">Sets</span>
                        {editing ? (
                          <input type="number" value={item.sets_count ?? ""} onChange={(e) => onUpdateItem(ii, { sets_count: e.target.value ? +e.target.value : null })} className="w-full bg-white border border-slate-200 rounded px-2 py-1 text-sm text-center focus:outline-none focus:border-sf-deepNavy" />
                        ) : (
                          <div className="font-bold text-slate-700 text-sm bg-white border border-slate-100 rounded px-2 py-1 text-center">{item.sets_count ?? "-"}</div>
                        )}
                      </div>
                      <div className="col-span-2">
                        <span className="text-[10px] text-slate-500 font-medium block mb-1">Paket yang Tersedia</span>
                        {editing ? (
                          <div className="flex flex-wrap gap-1">
                            {tierPackages.map((pkg) => {
                              const active = (item.allowed_tiers || []).includes(pkg.code);
                              return (
                                <button
                                  key={pkg.code}
                                  type="button"
                                  title={`${pkg.name} — ${pkg.label}`}
                                  onClick={() => {
                                    const cur = item.allowed_tiers || [];
                                    onUpdateItem(ii, { allowed_tiers: active ? cur.filter((t) => t !== pkg.code) : [...cur, pkg.code] });
                                  }}
                                  className={cn(
                                    "px-2 py-1 rounded text-[10px] font-bold border transition-colors",
                                    active ? "bg-sf-warmGold text-white border-sf-warmGold" : "bg-white text-slate-400 border-slate-200 hover:border-slate-300"
                                  )}
                                >
                                  {pkg.label}
                                </button>
                              );
                            })}
                            {(item.allowed_tiers || []).length === 0 && <span className="text-[10px] text-slate-400 py-1 px-1 font-medium bg-white border border-slate-200 rounded">Semua Paket</span>}
                          </div>
                        ) : (
                          <div className="flex flex-wrap gap-1">
                            {(item.allowed_tiers || []).length === 0 ? (
                              <span className="px-2 py-1 rounded bg-slate-100 border border-slate-200 text-slate-500 text-[10px] font-bold">Semua Paket</span>
                            ) : (item.allowed_tiers || []).map((t) => {
                              const pkg = tierPackages.find((p) => p.code === t);
                              return (
                                <span key={t} title={pkg?.name || t} className="px-2 py-1 rounded bg-sf-warmGold/10 border border-sf-warmGold/20 text-sf-warmGold text-[10px] font-bold">
                                  {pkg?.label || t}
                                </span>
                              );
                            })}
                          </div>
                        )}
                      </div>
                    </div>

                    {/* Level 1 Only: Breathing */}
                    {level === "1" && (
                      <div className="pt-2 border-t border-slate-200/60 flex flex-col md:flex-row gap-4">
                         <div className="flex-1 flex items-center gap-2">
                            <span className="text-[10px] font-bold text-slate-400 uppercase w-20">Breathing</span>
                            {editing ? (
                              <select
                                value={item.breathing_core || ""}
                                onChange={(e) => onUpdateItem(ii, { breathing_core: e.target.value })}
                                className="flex-1 bg-white border border-slate-200 rounded px-2 py-1 text-xs text-slate-700 focus:outline-none"
                              >
                                <option value="">Pilih...</option>
                                <option value="Core">Core</option>
                                <option value="Diafragma">Diafragma</option>
                              </select>
                            ) : (
                              <span className="text-xs font-medium text-slate-700">{item.breathing_core || "-"}</span>
                            )}
                         </div>
                      </div>
                    )}
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
//  MovementSelect — SearchableSelect for picking a movement
// ═══════════════════════════════════════════════════════════════

function MovementSelect({
  options, movementMap, item, bodyPart, selectedPatterns, onUpdate
}: {
  options: { value: string; label: string; sublabel?: string; pattern?: string | null; section?: string; extractedCategory?: string }[];
  movementMap: Record<string, string>;
  item: CardItem;
  bodyPart: string;
  selectedPatterns: string[];
  onUpdate: (p: Partial<CardItem>) => void;
}) {
  let filtered = [...options];

  if (selectedPatterns && selectedPatterns.length > 0) {
    filtered = filtered.filter(m => {
      const p = (m.pattern || "").trim().toLowerCase();
      const c = (m.extractedCategory || "").trim().toLowerCase();
      
      return selectedPatterns.some(sp => {
        const spLower = sp.toLowerCase();
        
        let match = false;
        if (p) {
          if (!spLower.includes(p) && !p.includes(spLower)) return false;
          match = true;
        }
        if (c) {
          if (!spLower.includes(c)) return false;
          match = true;
        }
        return match;
      });
    });
  }
  const customLabel = item.movement_name || "";
  const allOpts = [
    ...(customLabel && !item.movement_id ? [{ value: "__custom", label: customLabel, sublabel: "custom" }] : []),
    ...filtered,
  ];

  return (
    <div className="min-w-[140px]">
      <SearchableSelect
        options={allOpts}
        value={item.movement_id || (customLabel ? "__custom" : "")}
        onChange={(val) => {
          if (val === "__custom" || val === "") {
            onUpdate({ movement_id: null });
          } else {
            const selectedOpt = allOpts.find(o => o.value === val);
            const bp = selectedOpt?.sublabel || "upper";
            onUpdate({ movement_id: val, movement_name: movementMap[val] || "", body_part: bp });
          }
        }}
        placeholder="Pilih gerakan..."
        searchPlaceholder="Cari gerakan..."
      />
      {!item.movement_id && (
        <input
          value={item.movement_name || ""}
          onChange={(e) => onUpdate({ movement_name: e.target.value })}
          className="mt-1.5 w-full border border-slate-200 rounded px-2 py-1 text-xs focus:outline-none focus:ring-1 focus:ring-sf-deepNavy bg-white"
          placeholder="Atau ketik manual..."
        />
      )}
    </div>
  );
}

const formatWeight = (w: string | null | undefined): string => {
  if (!w) return "";
  return w.replace(/(\d+)\.00/g, "$1").replace(/(\d+\.\d)0/g, "$1");
};
