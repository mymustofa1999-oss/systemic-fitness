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
    movements.map((m: any) => ({
      value: m.id, label: m.name, sublabel: m.body_part, pattern: m.pattern || "",
    })), [movements]);

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
        <div className="overflow-x-auto">
          <table className="w-full text-xs border-collapse min-w-[900px]">
            <thead>
              <tr className="bg-slate-100 border-b border-slate-200">
                <th className="px-2 py-1 text-center font-bold text-slate-500 border-r border-slate-200 w-[60px]" rowSpan={2}>SET</th>
                <th className="px-2 py-1 text-center font-bold text-slate-500 border-r border-slate-200 w-[120px]" rowSpan={2}>Pola</th>
                <th className="px-2 py-1 text-center font-bold text-slate-500 border-r border-slate-200 w-[120px]" rowSpan={2}>Napas</th>
                <th className="px-2 py-1 text-center font-bold text-slate-500 border-r border-slate-200 w-[80px]" rowSpan={2}>DURATION</th>
                <th className="px-2 py-1 text-center font-bold text-slate-500 border-r border-slate-200" colSpan={2}>EQUIPMENT</th>
                <th className="px-2 py-1 text-center font-bold text-slate-500 border-r border-slate-200" colSpan={isMetabolic ? 4 : 3}>KOMPONEN</th>
                <th className="px-2 py-1 text-center font-bold text-slate-500 border-r border-slate-200 w-[100px]" rowSpan={2}>{isMetabolic ? "Reps" : "Reps / Mins"}</th>
                <th className="px-2 py-1 text-center font-bold text-slate-500 border-r border-slate-200 w-[80px]" rowSpan={2}>Sets</th>
                <th className="px-2 py-1 text-center font-bold text-slate-500 border-r border-slate-200 w-[70px]" rowSpan={2}>Paket</th>
                <th className="px-2 py-1 text-center font-bold text-slate-500 border-r border-slate-200 w-[110px]" rowSpan={2}>{isMetabolic ? "Extra Load" : "Bpm"}</th>
                <th className="px-2 py-1 text-center font-bold text-slate-500 border-r border-slate-200 w-[100px]" rowSpan={2}>Notes</th>
                {editing && <th className="px-2 py-1 text-center font-bold text-slate-500 w-[50px]" rowSpan={2}>Aksi</th>}
              </tr>
              <tr className="bg-slate-50 border-b border-slate-200">
                <th className="px-2 py-1 text-center font-semibold text-slate-500 border-r border-slate-200 w-[100px]">Upper</th>
                <th className="px-2 py-1 text-center font-semibold text-slate-500 border-r border-slate-200 w-[100px]">Lower</th>
                <th className="px-2 py-1 text-center font-semibold text-slate-500 border-r border-slate-200 w-[90px]">Tipe</th>
                <th className="px-2 py-1 text-center font-semibold text-slate-500 border-r border-slate-200 w-[160px]">Upper</th>
                <th className="px-2 py-1 text-center font-semibold text-slate-500 border-r border-slate-200 w-[160px]">Lower</th>
                {isMetabolic && <th className="px-2 py-1 text-center font-semibold text-slate-500 border-r border-slate-200 w-[140px]">Core</th>}
              </tr>
            </thead>
            <tbody>
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
                <tr>
                  <td colSpan={20} className="text-center py-6 text-slate-400">
                    Tidak ada set
                  </td>
                </tr>
              )}
            </tbody>
          </table>
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
  const typeName = set.type_name || types.find((t: any) => t.id === set.type_id)?.name || "";
  const rowCount = Math.max(set.items.length, 1);
  const items = set.items.length > 0 ? set.items : [null];

  const selectedPatterns = set.pattern ? set.pattern.split(",").map(p => p.trim()).filter(Boolean) : [];

  return (
    <>
      {items.map((item, ii) => (
        <tr key={ii} className={cn(
          "border-b border-slate-100 hover:bg-slate-50/50 transition-colors",
          ii === 0 && "border-t border-slate-200"
        )}>
          {/* Set-level cells — only on first row (rowSpan) */}
          {ii === 0 && (
            <>
              {/* SEQUENCE (Set #) */}
              <td className={cn(cellBase, "text-center font-bold text-slate-700 bg-slate-50 border-r border-slate-200")} rowSpan={rowCount}>
                Set {set.set_number}
              </td>
              {/* PATTERN */}
              <td className={cn(cellBase, "border-r border-slate-200")} rowSpan={rowCount}>
                {editing ? (
                  <Popover.Root>
                    <Popover.Trigger asChild>
                      <button type="button" className={cn(inpCell, "text-left truncate bg-white border border-slate-200 rounded px-2 py-1 text-slate-700 w-full min-w-[120px] flex items-center justify-between")}>
                        <span className="truncate">{selectedPatterns.length > 0 ? selectedPatterns.join(", ") : "Pilih..."}</span>
                        <ChevronDown className="h-3 w-3 text-slate-400 shrink-0 ml-1" />
                      </button>
                    </Popover.Trigger>
                    <Popover.Portal>
                      <Popover.Content align="start" className="z-50 bg-white rounded-lg shadow-lg border border-slate-200 p-2 space-y-1 w-[180px]">
                        {[
                          "Isolate FC",
                          "Dynamic FC",
                          "Isolate CC",
                          "Dynamic CC",
                          "Metabolic Basic",
                          "Metabolic Core",
                        ].map((p) => {
                          const isChecked = selectedPatterns.includes(p);
                          return (
                            <label key={p} className="flex items-center gap-2 px-2 py-1 hover:bg-slate-50 rounded text-xs cursor-pointer select-none">
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
                                className="rounded border-slate-300 text-sf-deepNavy focus:ring-sf-warmGold/40 h-3.5 w-3.5"
                              />
                              <span>{p}</span>
                            </label>
                          );
                        })}
                      </Popover.Content>
                    </Popover.Portal>
                  </Popover.Root>
                ) : (
                  <span className="text-slate-600 block text-[11px] leading-tight font-medium">{set.pattern ? set.pattern.split(",").join(", ") : "-"}</span>
                )}
              </td>
              {/* BREATHING (SET) */}
              <td className={cn(cellBase, "border-r border-slate-200")} rowSpan={rowCount}>
                {editing ? (
                  <div className="space-y-1 min-w-[120px]">
                    <div className="flex items-center gap-1">
                      <span className="text-[10px] text-slate-400 font-medium shrink-0 w-8">Core:</span>
                      <select
                        value={set.breathing_core || ""}
                        onChange={(e) => onUpdateSet({ breathing_core: e.target.value })}
                        className={cn(inpCell, "flex-1 py-0.5")}
                      >
                        <option value="">Pilih...</option>
                        <option value="Tarik Napas">Tarik Napas</option>
                        <option value="Buang Napas">Buang Napas</option>
                        <option value="Tahan Napas">Tahan Napas</option>
                        <option value="Napas Normal">Napas Normal</option>
                      </select>
                    </div>
                    <div className="flex items-center gap-1">
                      <span className="text-[10px] text-slate-400 font-medium shrink-0 w-8">Diaf:</span>
                      <select
                        value={set.breathing_diaphragm || ""}
                        onChange={(e) => onUpdateSet({ breathing_diaphragm: e.target.value })}
                        className={cn(inpCell, "flex-1 py-0.5")}
                      >
                        <option value="">Pilih...</option>
                        <option value="Tarik Napas">Tarik Napas</option>
                        <option value="Buang Napas">Buang Napas</option>
                        <option value="Tahan Napas">Tahan Napas</option>
                        <option value="Napas Normal">Napas Normal</option>
                      </select>
                    </div>
                  </div>
                ) : (
                  <div className="text-[10px] space-y-0.5">
                    <div><span className="text-slate-400">Core:</span> <span className="font-medium text-slate-700">{set.breathing_core || "-"}</span></div>
                    <div><span className="text-slate-400">Diaf:</span> <span className="font-medium text-slate-700">{set.breathing_diaphragm || "-"}</span></div>
                  </div>
                )}
              </td>
              {/* DURATION */}
              <td className={cn(cellBase, "border-r border-slate-200")} rowSpan={rowCount}>
                {editing ? (
                  <input value={set.duration || ""} onChange={(e) => onUpdateSet({ duration: e.target.value })} className={cn(inpCell, "w-full")} placeholder="3-5 mins" />
                ) : <span className="text-slate-600">{set.duration || ""}</span>}
              </td>
              {/* EQUIPMENT Upper */}
              <td className={cn(cellBase, "border-r border-slate-200")} rowSpan={rowCount}>
                {editing ? (
                  <div className="min-w-[110px]">
                    <SearchableSelect
                      options={upperOptions}
                      value={set.equipment_upper || ""}
                      onChange={(v) => onUpdateSet({ equipment_upper: v })}
                      placeholder="Pilih..."
                      searchPlaceholder="Cari upper..."
                    />
                  </div>
                ) : <span className="text-slate-500 font-semibold">{set.equipment_upper ? `💪 ${formatWeight(set.equipment_upper)}` : ""}</span>}
              </td>
              {/* EQUIPMENT Lower */}
              <td className={cn(cellBase, "border-r border-slate-200")} rowSpan={rowCount}>
                {editing ? (
                  <div className="min-w-[110px]">
                    <SearchableSelect
                      options={lowerOptions}
                      value={set.equipment_lower || ""}
                      onChange={(v) => onUpdateSet({ equipment_lower: v })}
                      placeholder="Pilih..."
                      searchPlaceholder="Cari lower..."
                    />
                  </div>
                ) : <span className="text-slate-500 font-semibold">{set.equipment_lower ? `🦵 ${formatWeight(set.equipment_lower)}` : ""}</span>}
              </td>
              {/* TIPE */}
              <td className={cn(cellBase, "border-r border-slate-200")} rowSpan={rowCount}>
                {editing ? (
                  <SearchableSelect
                    options={typeOptions}
                    value={set.type_id || ""}
                    onChange={(v) => onUpdateSet({ type_id: v })}
                    placeholder="Tipe..."
                    searchPlaceholder="Cari tipe..."
                  />
                ) : (
                  <span className={cn(
                    "inline-flex px-2 py-0.5 rounded text-[10px] font-bold",
                    typeName === "Dynamic" ? "bg-blue-50 text-blue-700" :
                    typeName === "Isolate" ? "bg-amber-50 text-amber-700" :
                    "bg-slate-100 text-slate-600"
                  )}>{typeName || "-"}</span>
                )}
              </td>
            </>
          )}

          {/* Item-level cells */}
          {item ? (
            <>
              {/* Upper movement column */}
              <td className={cn(cellBase, "border-r border-slate-200")}>
                {item.body_part === "upper" ? (
                  editing ? (
                    <div className="space-y-1">
                      <MovementSelect
                        options={movementOptions}
                        movementMap={movementMap}
                        item={item}
                        bodyPart="upper"
                        selectedPatterns={selectedPatterns}
                        onUpdate={(p) => onUpdateItem(ii, p)}
                        onRemove={() => onRemoveItem(ii)}
                      />
                      {level === "1" && (
                        <div className="mt-1 pt-1 border-t border-slate-100 space-y-1">
                          <div className="flex items-center gap-1">
                            <span className="text-[9px] text-slate-400 font-medium w-8 shrink-0">Core:</span>
                            <select
                              value={item.breathing_core || ""}
                              onChange={(e) => onUpdateItem(ii, { breathing_core: e.target.value })}
                              className="text-[10px] w-full border border-slate-200 rounded px-1 py-0.5 focus:outline-none bg-white"
                            >
                              <option value="">Pilih...</option>
                              <option value="Tarik Napas">Tarik Napas</option>
                              <option value="Buang Napas">Buang Napas</option>
                              <option value="Tahan Napas">Tahan Napas</option>
                              <option value="Napas Normal">Napas Normal</option>
                            </select>
                          </div>
                          <div className="flex items-center gap-1">
                            <span className="text-[9px] text-slate-400 font-medium w-8 shrink-0">Diaf:</span>
                            <select
                              value={item.breathing_diaphragm || ""}
                              onChange={(e) => onUpdateItem(ii, { breathing_diaphragm: e.target.value })}
                              className="text-[10px] w-full border border-slate-200 rounded px-1 py-0.5 focus:outline-none bg-white"
                            >
                              <option value="">Pilih...</option>
                              <option value="Tarik Napas">Tarik Napas</option>
                              <option value="Buang Napas">Buang Napas</option>
                              <option value="Tahan Napas">Tahan Napas</option>
                              <option value="Napas Normal">Napas Normal</option>
                            </select>
                          </div>
                        </div>
                      )}
                    </div>
                  ) : (
                    <div>
                      <span className="text-slate-800 font-medium">{item.movement_name || ""}</span>
                      {level === "1" && (item.breathing_core || item.breathing_diaphragm) && (
                        <div className="mt-1 text-[9px] text-slate-500 bg-slate-50 p-1 rounded border border-slate-100">
                          {item.breathing_core && <div>Core: {item.breathing_core}</div>}
                          {item.breathing_diaphragm && <div>Diaf: {item.breathing_diaphragm}</div>}
                        </div>
                      )}
                    </div>
                  )
                ) : null}
              </td>
              {/* Lower movement column */}
              <td className={cn(cellBase, "border-r border-slate-200")}>
                {item.body_part === "lower" ? (
                  editing ? (
                    <div className="space-y-1">
                      <MovementSelect
                        options={movementOptions}
                        movementMap={movementMap}
                        item={item}
                        bodyPart="lower"
                        selectedPatterns={selectedPatterns}
                        onUpdate={(p) => onUpdateItem(ii, p)}
                        onRemove={() => onRemoveItem(ii)}
                      />
                      {level === "1" && (
                        <div className="mt-1 pt-1 border-t border-slate-100 space-y-1">
                          <div className="flex items-center gap-1">
                            <span className="text-[9px] text-slate-400 font-medium w-8 shrink-0">Core:</span>
                            <select
                              value={item.breathing_core || ""}
                              onChange={(e) => onUpdateItem(ii, { breathing_core: e.target.value })}
                              className="text-[10px] w-full border border-slate-200 rounded px-1 py-0.5 focus:outline-none bg-white"
                            >
                              <option value="">Pilih...</option>
                              <option value="Tarik Napas">Tarik Napas</option>
                              <option value="Buang Napas">Buang Napas</option>
                              <option value="Tahan Napas">Tahan Napas</option>
                              <option value="Napas Normal">Napas Normal</option>
                            </select>
                          </div>
                          <div className="flex items-center gap-1">
                            <span className="text-[9px] text-slate-400 font-medium w-8 shrink-0">Diaf:</span>
                            <select
                              value={item.breathing_diaphragm || ""}
                              onChange={(e) => onUpdateItem(ii, { breathing_diaphragm: e.target.value })}
                              className="text-[10px] w-full border border-slate-200 rounded px-1 py-0.5 focus:outline-none bg-white"
                            >
                              <option value="">Pilih...</option>
                              <option value="Tarik Napas">Tarik Napas</option>
                              <option value="Buang Napas">Buang Napas</option>
                              <option value="Tahan Napas">Tahan Napas</option>
                              <option value="Napas Normal">Napas Normal</option>
                            </select>
                          </div>
                        </div>
                      )}
                    </div>
                  ) : (
                    <div>
                      <span className="text-slate-800 font-medium">{item.movement_name || ""}</span>
                      {level === "1" && (item.breathing_core || item.breathing_diaphragm) && (
                        <div className="mt-1 text-[9px] text-slate-500 bg-slate-50 p-1 rounded border border-slate-100">
                          {item.breathing_core && <div>Core: {item.breathing_core}</div>}
                          {item.breathing_diaphragm && <div>Diaf: {item.breathing_diaphragm}</div>}
                        </div>
                      )}
                    </div>
                  )
                ) : null}
              </td>
              {/* Core movement column (Metabolic only) */}
              {isMetabolic && (
                <td className={cn(cellBase, "border-r border-slate-200")}>
                  {item.body_part === "core" ? (
                    editing ? (
                      <div className="space-y-1">
                        <MovementSelect
                          options={movementOptions}
                          movementMap={movementMap}
                          item={item}
                          bodyPart="core"
                          selectedPatterns={selectedPatterns}
                          onUpdate={(p) => onUpdateItem(ii, p)}
                          onRemove={() => onRemoveItem(ii)}
                        />
                        {level === "1" && (
                          <div className="mt-1 pt-1 border-t border-slate-100 space-y-1">
                            <div className="flex items-center gap-1">
                              <span className="text-[9px] text-slate-400 font-medium w-8 shrink-0">Core:</span>
                              <select
                                value={item.breathing_core || ""}
                                onChange={(e) => onUpdateItem(ii, { breathing_core: e.target.value })}
                                className="text-[10px] w-full border border-slate-200 rounded px-1 py-0.5 focus:outline-none bg-white"
                              >
                                <option value="">Pilih...</option>
                                <option value="Tarik Napas">Tarik Napas</option>
                                <option value="Buang Napas">Buang Napas</option>
                                <option value="Tahan Napas">Tahan Napas</option>
                                <option value="Napas Normal">Napas Normal</option>
                              </select>
                            </div>
                            <div className="flex items-center gap-1">
                              <span className="text-[9px] text-slate-400 font-medium w-8 shrink-0">Diaf:</span>
                              <select
                                value={item.breathing_diaphragm || ""}
                                onChange={(e) => onUpdateItem(ii, { breathing_diaphragm: e.target.value })}
                                className="text-[10px] w-full border border-slate-200 rounded px-1 py-0.5 focus:outline-none bg-white"
                              >
                                <option value="">Pilih...</option>
                                <option value="Tarik Napas">Tarik Napas</option>
                                <option value="Buang Napas">Buang Napas</option>
                                <option value="Tahan Napas">Tahan Napas</option>
                                <option value="Napas Normal">Napas Normal</option>
                              </select>
                            </div>
                          </div>
                        )}
                      </div>
                    ) : (
                      <div>
                        <span className="text-slate-800 font-medium">{item.movement_name || ""}</span>
                        {level === "1" && (item.breathing_core || item.breathing_diaphragm) && (
                          <div className="mt-1 text-[9px] text-slate-500 bg-slate-50 p-1 rounded border border-slate-100">
                            {item.breathing_core && <div>Core: {item.breathing_core}</div>}
                            {item.breathing_diaphragm && <div>Diaf: {item.breathing_diaphragm}</div>}
                          </div>
                        )}
                      </div>
                    )
                  ) : null}
                </td>
              )}
              {/* Reps */}
              <td className={cn(cellBase, "text-center border-r border-slate-200")}>
                {editing ? (
                  <input type="number" value={item.reps ?? ""} onChange={(e) => onUpdateItem(ii, { reps: e.target.value ? +e.target.value : null })} className={cn(inpCell, "w-full text-center min-w-[72px] h-9")} />
                ) : <span className="text-slate-700">{item.reps ?? ""}</span>}
              </td>
              {/* Sets count */}
              <td className={cn(cellBase, "text-center border-r border-slate-200")}>
                {editing ? (
                  <input type="number" value={item.sets_count ?? ""} onChange={(e) => onUpdateItem(ii, { sets_count: e.target.value ? +e.target.value : null })} className={cn(inpCell, "w-full text-center min-w-[60px] h-9")} />
                ) : <span className="text-slate-700">{item.sets_count ?? ""}</span>}
              </td>
              {/* PAKET — per-movement package access (empty = semua paket) */}
              <td className={cn(cellBase, "text-center border-r border-slate-200")}>
                {editing ? (
                  <div className="flex flex-col gap-1 min-w-[64px]">
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
                            "px-1 py-0.5 rounded text-[10px] font-bold border transition-colors",
                            active ? "bg-sf-warmGold text-white border-sf-warmGold" : "bg-white text-slate-400 border-slate-200 hover:border-slate-300"
                          )}
                        >
                          {pkg.label}
                        </button>
                      );
                    })}
                    {(item.allowed_tiers || []).length === 0 && <span className="text-[9px] text-slate-400">Semua paket</span>}
                  </div>
                ) : (
                  <div className="flex flex-wrap gap-0.5 justify-center">
                    {(item.allowed_tiers || []).length === 0 ? (
                      <span className="text-[10px] text-slate-400">Semua</span>
                    ) : (item.allowed_tiers || []).map((t) => {
                      const pkg = tierPackages.find((p) => p.code === t);
                      return (
                        <span key={t} title={pkg?.name || t} className="px-1 rounded bg-sf-warmGold/10 text-sf-warmGold text-[9px] font-bold">
                          {pkg?.label || t}
                        </span>
                      );
                    })}
                  </div>
                )}
              </td>
            </>
          ) : (
            <>
              {/* Empty placeholder */}
              <td className={cn(cellBase, "border-r border-slate-200 text-slate-400 italic text-center")} colSpan={isMetabolic ? 3 : 2}>
                {editing ? "Tambah gerakan di bawah" : "Belum ada gerakan"}
              </td>
              {/* Reps + Sets + Paket empty */}
              <td className={cn(cellBase, "border-r border-slate-200")} />
              <td className={cn(cellBase, "border-r border-slate-200")} />
              <td className={cn(cellBase, "border-r border-slate-200")} />
            </>
          )}

          {/* BPM / Extra Load — only on first row */}
          {ii === 0 ? (
            <td className={cn(cellBase, "border-r border-slate-200")} rowSpan={rowCount}>
              {editing ? (
                <input
                  value={isMetabolic ? (set.extra_load || "") : (set.bpm || "")}
                  onChange={(e) => isMetabolic ? onUpdateSet({ extra_load: e.target.value }) : onUpdateSet({ bpm: e.target.value })}
                  className={cn(inpCell, "w-full min-w-[90px] h-9")}
                  placeholder={isMetabolic ? "Extra load" : "zona 1-2"}
                />
              ) : (
                <span className="text-slate-500">{isMetabolic ? (set.extra_load || "") : (set.bpm || "")}</span>
              )}
            </td>
          ) : null}

          {/* Notes column */}
          {ii === 0 ? (
            <td className={cn(cellBase, "border-r border-slate-200")} rowSpan={rowCount}>
              {editing ? (
                <input
                  value={set.notes || ""}
                  onChange={(e) => onUpdateSet({ notes: e.target.value })}
                  className={cn(inpCell, "w-full")}
                  placeholder="Notes..."
                />
              ) : (
                set.notes && <span className="text-slate-500 text-[10px]">{set.notes}</span>
              )}
            </td>
          ) : null}
          {/* Aksi column (edit mode only) */}
          {editing && ii === 0 ? (
            <td className={cn(cellBase, "text-center")} rowSpan={rowCount}>
              <button onClick={onRemoveSet} className="p-1.5 rounded bg-red-500 text-white hover:bg-red-600 transition-colors" title="Hapus set">
                <Trash2 className="h-3.5 w-3.5" />
              </button>
            </td>
          ) : null}
        </tr>
      ))}

      {/* Add buttons aligned under each movement column */}
      {editing && (
        <tr className="border-b border-slate-200">
          {/* Empty columns (SET, Pola, Napas, DURATION, EQUIPMENT x2, TIPE) */}
          <td colSpan={7} className={cn(cellBase, "border-r border-slate-200 bg-slate-50/50")} />
          {/* + Upper */}
          <td className={cn(cellBase, "border-r border-slate-200 bg-slate-50/50 align-top")}>
            <button
              onClick={() => onAddItem("upper")}
              className="w-full py-1.5 text-[10px] rounded border border-dashed border-blue-300 text-blue-600 bg-blue-50 hover:bg-blue-100 transition-colors flex items-center justify-center gap-1 font-medium"
            >
              <Plus className="h-3 w-3" /> Tambah Upper
            </button>
          </td>
          {/* + Lower */}
          <td className={cn(cellBase, "border-r border-slate-200 bg-slate-50/50 align-top")}>
            <button
              onClick={() => onAddItem("lower")}
              className="w-full py-1.5 text-[10px] rounded border border-dashed border-green-300 text-green-600 bg-green-50 hover:bg-green-100 transition-colors flex items-center justify-center gap-1 font-medium"
            >
              <Plus className="h-3 w-3" /> Tambah Lower
            </button>
          </td>
          {/* + Core (Metabolic only) */}
          {isMetabolic && (
            <td className={cn(cellBase, "border-r border-slate-200 bg-slate-50/50 align-top")}>
              <button
                onClick={() => onAddItem("core")}
                className="w-full py-1.5 text-[10px] rounded border border-dashed border-amber-300 text-amber-600 bg-amber-50 hover:bg-amber-100 transition-colors flex items-center justify-center gap-1 font-medium"
              >
                <Plus className="h-3 w-3" /> Tambah Core
              </button>
            </td>
          )}
          {/* Empty trailing columns */}
          <td colSpan={6} className={cn(cellBase, "bg-slate-50/50")} />
        </tr>
      )}
    </>
  );
}

// ═══════════════════════════════════════════════════════════════
//  MovementSelect — SearchableSelect for picking a movement
// ═══════════════════════════════════════════════════════════════

function MovementSelect({
  options, movementMap, item, bodyPart, selectedPatterns, onUpdate, onRemove,
}: {
  options: { value: string; label: string; sublabel?: string; pattern?: string | null }[];
  movementMap: Record<string, string>;
  item: CardItem;
  bodyPart: string;
  selectedPatterns: string[];
  onUpdate: (p: Partial<CardItem>) => void;
  onRemove: () => void;
}) {
  let filtered = options.filter(m => m.sublabel === bodyPart || m.sublabel === "whole body");
  if (selectedPatterns && selectedPatterns.length > 0) {
    filtered = filtered.filter(m => selectedPatterns.includes(m.pattern || ""));
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
        onChange={(v) => {
          if (v === "__custom" || v === "") {
            onUpdate({ movement_id: null });
          } else {
            onUpdate({ movement_id: v, movement_name: movementMap[v] || "" });
          }
        }}
        placeholder="Pilih gerakan..."
        searchPlaceholder={`Cari ${bodyPart}...`}
      />
      {!item.movement_id && (
        <input
          value={item.movement_name || ""}
          onChange={(e) => onUpdate({ movement_name: e.target.value })}
          className="mt-1 w-full border border-slate-200 rounded px-1.5 py-0.5 text-xs focus:outline-none focus:ring-1 focus:ring-sf-warmGold/40"
          placeholder="Atau ketik manual..."
        />
      )}
      <button
        onClick={onRemove}
        className="mt-1 w-full py-1 rounded text-[11px] font-bold text-white bg-red-500 hover:bg-red-600 transition-colors flex items-center justify-center gap-1"
        title="Hapus gerakan"
      >
        <Trash2 className="h-3 w-3" /> Hapus
      </button>
    </div>
  );
}

const formatWeight = (w: string | null | undefined): string => {
  if (!w) return "";
  return w.replace(/(\d+)\.00/g, "$1").replace(/(\d+\.\d)0/g, "$1");
};
