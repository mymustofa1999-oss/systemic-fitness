"use client";

import { useState, useMemo, useEffect, useRef } from "react";
import Link from "next/link";
import { useUser } from "@/hooks/useUsers";
import { useAuth } from "@/hooks/useAuth";
import {
  useTrainerCard,
  useUpsertTrainerCard,
  usePublishTrainerCard,
  useDeleteTrainerCard,
  useTrainerCardTypes,
  useCustomerPrograms,
  useEquipments,
  useCustomerSetup,
} from "@/hooks/useNewFeatures";


function buildSetsFromMenuItems(menuItems: any[]) {
  if (!menuItems || menuItems.length === 0) return [];
  
  const setsMap = new Map<string, any[]>();
  for (const item of menuItems) {
    const setName = item.set_name || "Set 1";
    if (!setsMap.has(setName)) setsMap.set(setName, []);
    setsMap.get(setName)!.push(item);
  }
  
  const sets: any[] = [];
  let setNumber = 1;
  for (const [setName, items] of Array.from(setsMap.entries())) {
    const parsedSetNum = parseInt(setName.replace(/\D/g, '')) || setNumber;
    sets.push({
      set_number: parsedSetNum,
      duration: "",
      equipment_upper: "",
      equipment_lower: "",
      type_id: "",
      type_name: "",
      bpm: "",
      extra_load: "",
      pattern: "",
      breathing_core: "",
      breathing_diaphragm: "",
      notes: "",
      sort_order: setNumber - 1,
      items: items.map((item, ii) => ({
        movement_id: item.movement_id || null,
        movement_name: item.movement?.name || "",
        body_part: item.movement?.body_part || "upper",
        equipment: item.movement?.equipment || "",
        reps: null,
        sets_count: 1,
        breathing_core: "",
        breathing_diaphragm: "",
        sort_order: ii,
      }))
    });
    setNumber++;
  }
  return sets;
}

import { useTemplate } from "@/hooks/useTrainerCardTemplates";
import { useDLMovements, useDLMenuItems } from "@/hooks/useDigitalLibrary";
import { useLatestAssessmentV2 } from "@/hooks/useAssessmentV2";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { SearchableSelect } from "@/components/shared/SearchableSelect";
import * as Popover from "@radix-ui/react-popover";
import {
  ArrowLeft, Plus, Trash2, Save, Loader2, Pencil, X,
  ChevronDown, ChevronRight, Send,
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
  breathing_core?: string | null;
  breathing_diaphragm?: string | null;
  sort_order: number;
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
  pattern?: string | null;
  breathing_core?: string | null;
  breathing_diaphragm?: string | null;
  notes?: string | null;
  sort_order: number;
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

interface CardForm {
  level: string;
  notes: string;
  sequences: CardSequence[];
}

const LEVELS = [
  { value: "1", label: "Level 1" },
  { value: "1-499", label: "Level 1 (499)" },
  { value: "1-799", label: "Level 1 (799)" },
  { value: "5-6", label: "Level group (5-6)" },
  { value: "level_0_1", label: "Level 0-1" },
  { value: "level_2_3", label: "Level 2-3" },
  { value: "level_4_5_perf", label: "Level 4-5 / Performance" },
  { value: "level_4_5_health", label: "Level 4-5 / Health" },
  { value: "level_6_perf", label: "Level 6 / Performance" },
  { value: "level_6_health", label: "Level 6 / Health" },
];

const getLevelLabel = (val: string) => {
  const l = LEVELS.find((x) => x.value === val);
  return l ? l.label : val;
};

const BODY_PARTS = [
  { value: "upper", label: "Upper" },
  { value: "lower", label: "Lower" },
  { value: "core", label: "Core" },
  { value: "whole body", label: "Whole Body" },
];

const TIER2_MOVEMENTS = [
  { id: "m1", title: "Arm Rotation", movement_tag: "FC", video_url_male: "https://youtu.be/Gv0JzAjI4wE", video_url_female: "https://youtu.be/CDkR0Hqu_B4" },
  { id: "m2", title: "Arm Rotation Stand", movement_tag: "FC", video_url_male: "https://youtu.be/Gv0JzAjI4wE", video_url_female: "https://youtu.be/CDkR0Hqu_B4" },
  { id: "m3", title: "Arm Rotation Stand Weight", movement_tag: "CC", video_url_male: "https://youtu.be/Gv0JzAjI4wE", video_url_female: "https://youtu.be/CDkR0Hqu_B4" },
  { id: "m4", title: "Barbel Row", movement_tag: "MC", video_url_male: "https://youtu.be/dQPys_dgoGY", video_url_female: "https://youtu.be/dQPys_dgoGY" },
  { id: "m5", title: "Bent Over Fly", movement_tag: "MC", video_url_male: "https://youtu.be/prz4V9AacSE", video_url_female: "https://youtu.be/prz4V9AacSE" },
  { id: "m6", title: "Bicep Curls", movement_tag: "MC", video_url_male: "https://youtu.be/SZKOhGoXcTI", video_url_female: "https://youtu.be/SZKOhGoXcTI" },
  { id: "m7", title: "Chest Press", movement_tag: "MC", video_url_male: "https://youtu.be/wuH_zwLy6EM", video_url_female: "https://youtu.be/wuH_zwLy6EM" },
  { id: "m8", title: "Cross Up", movement_tag: "MC", video_url_male: "https://youtu.be/qy2ldvISD2Y", video_url_female: "https://youtu.be/qy2ldvISD2Y" }
];

const cellBase = "px-2 py-1.5 text-xs border-r border-slate-100 last:border-r-0";
const inpCell = "w-full border border-slate-200 rounded px-1.5 py-1 text-xs focus:outline-none focus:ring-1 focus:ring-sf-warmGold/40 bg-white";

// ─── Weight Load Calculation Functions ──────────────────────────

interface WeightLoads {
  categoryText: string;
  cardio: { upper: string; lower: string };
  metabolic: { upper: string; lower: string };
}

function getClientCategoryAndLoads(
  gender: string | undefined,
  age: number | null,
  height: number | null
): WeightLoads {
  const isMale = gender === "male" || gender === "men";
  const isFemale = gender === "female" || gender === "women";

  const defaultResult = {
    categoryText: "",
    cardio: { upper: "", lower: "" },
    metabolic: { upper: "", lower: "" },
  };

  if (!gender) {
    return {
      categoryText: "Gender belum diisi di profil",
      cardio: { upper: "", lower: "" },
      metabolic: { upper: "", lower: "" },
    };
  }

  const isTeenager = age !== null && age <= 20;

  if (isFemale) {
    if (isTeenager) {
      return {
        categoryText: "Teenager Wanita (≤ 20 tahun)",
        cardio: { upper: "0.25 kg", lower: "0.75 kg" },
        metabolic: { upper: "1 kg", lower: "1.5 kg" },
      };
    } else {
      if (height !== null && height > 175) {
        return {
          categoryText: "Wanita Dewasa (tinggi > 175 cm)",
          cardio: { upper: "0.75 kg", lower: "1.5 kg" },
          metabolic: { upper: "2 kg", lower: "2.5 kg" },
        };
      } else {
        const hText = height ? `tinggi ${height} cm` : "tinggi belum diisi, default 155-175 cm";
        return {
          categoryText: `Wanita Dewasa (${hText})`,
          cardio: { upper: "0.5 kg", lower: "1 kg" },
          metabolic: { upper: "1.5 kg", lower: "2 kg" },
        };
      }
    }
  } else if (isMale) {
    if (isTeenager) {
      return {
        categoryText: "Teenager Pria (≤ 20 tahun)",
        cardio: { upper: "0.5 kg", lower: "1.5 kg" },
        metabolic: { upper: "2 kg", lower: "2 kg" },
      };
    } else {
      if (height !== null && height > 185) {
        return {
          categoryText: "Pria Dewasa (tinggi > 185 cm)",
          cardio: { upper: "1.5 kg", lower: "3 kg" },
          metabolic: { upper: "4 kg", lower: "4 kg" },
        };
      } else {
        const hText = height ? `tinggi ${height} cm` : "tinggi belum diisi, default 160-185 cm";
        return {
          categoryText: `Pria Dewasa (${hText})`,
          cardio: { upper: "1 kg", lower: "2 kg" },
          metabolic: { upper: "3 kg", lower: "3 kg" },
        };
      }
    }
  }

  return defaultResult;
}

// ─── Page ───────────────────────────────────────────────────────

export default function TrainingCardPage({ params }: { params: { id: string } }) {
  const customerId = params.id;
  const { isTrainer, isConsultant, isAdmin, isOwner, role } = useAuth();
  const { data: userData, isLoading: userLoading } = useUser(customerId);
  const subscriptionTier = (userData?.data as any)?.subscription?.tier;
  const isTier1 = !subscriptionTier || subscriptionTier === "sf_tier_1";
  
  // Explicitly check role string to bypass any useAuth state issues
  const currentRole = (role || "").toLowerCase();
  const canEdit = isOwner || isAdmin || isConsultant || isTrainer || currentRole === "consultant";
  const { data: cardData, isLoading: cardLoading } = useTrainerCard(customerId);
  const { data: typesData } = useTrainerCardTypes();
  const { data: programsData, isLoading: isLoadingPrograms } = useCustomerPrograms(customerId);
  const { data: movementsData } = useDLMovements({ limit: 500 });
  const { data: equipUpperData } = useEquipments({ category: "upper", limit: 100 });
  const { data: equipLowerData } = useEquipments({ category: "lower", limit: 100 });
  const { data: latestAssessmentData, isLoading: isLoadingAssessment } = useLatestAssessmentV2(customerId);
  const physicalLevel = latestAssessmentData?.data?.physical_status_level;
  
  const mappedLevel = useMemo(() => {
    if (!physicalLevel) return "";
    if (physicalLevel.includes("0_1")) return "1";
    if (physicalLevel.includes("2_3")) return "1"; // Map point 2 to level 1
    if (physicalLevel.includes("4_5")) return "4";
    if (physicalLevel.includes("6")) return "6";
    const match = physicalLevel.match(/\d+/);
    return match ? match[0] : "";
  }, [physicalLevel]);

  const parsedMappedLevel = parseInt(mappedLevel) || 1;
  const { data: fcData, isLoading: isLoadingFC } = useDLMenuItems("fc", parsedMappedLevel);
  const { data: ccData, isLoading: isLoadingCC } = useDLMenuItems("cc", parsedMappedLevel);
  const { data: mcData, isLoading: isLoadingMC } = useDLMenuItems("mc", parsedMappedLevel);
  const isLoadingMenu = isLoadingFC || isLoadingCC || isLoadingMC;

  const { data: templateData, isLoading: isLoadingTemplate } = useTemplate(mappedLevel);
  const templateCard = templateData?.data as any;

  const upsertCard = useUpsertTrainerCard();
  const publishCard = usePublishTrainerCard();
  const deleteCard = useDeleteTrainerCard();

  const user = (userData?.data as any)?.user;
  const profile = (userData?.data as any)?.profile;
  const dbCard = cardData?.data as any;

  // Calculate age from DOB
  const age = useMemo(() => {
    if (!profile?.date_of_birth) return null;
    const dob = new Date(profile.date_of_birth);
    const now = new Date();
    let a = now.getFullYear() - dob.getFullYear();
    if (now.getMonth() < dob.getMonth() || (now.getMonth() === dob.getMonth() && now.getDate() < dob.getDate())) a--;
    return a;
  }, [profile?.date_of_birth]);

  const recs = useMemo(() => {
    return getClientCategoryAndLoads(profile?.gender, age, profile?.height_cm);
  }, [profile?.gender, age, profile?.height_cm]);
  const types = (typesData?.data ?? []) as any[];
  const customerPrograms = (programsData?.data ?? []) as any[];
  const movements = (movementsData?.data ?? []) as any[];
  const equipUpper = (equipUpperData?.data ?? []) as any[];
  const equipLower = (equipLowerData?.data ?? []) as any[];

  const isTier2 = (userData?.data as any)?.subscription?.tier === "sf_tier_2";
  const isTier3 = (userData?.data as any)?.subscription?.tier === "sf_tier_3";
  const isOverriddenTier = isTier2 || isTier3;

  const presetCard = useMemo(() => {
    if (!isOverriddenTier) return null;

    const presetItems = TIER2_MOVEMENTS.map((mv, index) => ({
      movement_id: mv.id,
      movement_name: mv.title,
      body_part: "upper",
      equipment: "",
      reps: 20,
      sets_count: 1,
      sort_order: index,
    }));

    const getCatInfo = (code: string) => {
      const p = customerPrograms.find((cp: any) => cp.program_category_code === code);
      return {
        id: p?.program_category_id || code,
        name: p?.program_category_name || (code === "functional" ? "Functional Conditioning" : code === "cardiorespiratory" ? "Cardio Conditioning" : "Metabolic Conditioning"),
        code: code,
      };
    };

    const fnInfo = getCatInfo("functional");
    const ccInfo = getCatInfo("cardiorespiratory");
    const mcInfo = getCatInfo("metabolic");

    const sequences = [
      {
        program_category_id: fnInfo.id,
        program_category_name: fnInfo.name,
        program_category_code: fnInfo.code,
        duration: "10'",
        sort_order: 0,
        sets: [
          {
            set_number: 1,
            duration: "3'",
            equipment_upper: "Wrist 0.25 kg",
            equipment_lower: "Ankle 0.5 kg",
            type_id: "",
            type_name: "",
            bpm: "80",
            extra_load: "",
            notes: "Group AG",
            sort_order: 0,
            items: presetItems,
          }
        ]
      },
      {
        program_category_id: ccInfo.id,
        program_category_name: ccInfo.name,
        program_category_code: ccInfo.code,
        duration: "20'",
        sort_order: 1,
        sets: [
          {
            set_number: 1,
            duration: "5'",
            equipment_upper: "1.00 kg",
            equipment_lower: "2.00 kg",
            type_id: "",
            type_name: "",
            bpm: "",
            extra_load: "",
            notes: "",
            sort_order: 0,
            items: presetItems,
          }
        ]
      },
      {
        program_category_id: mcInfo.id,
        program_category_name: mcInfo.name,
        program_category_code: mcInfo.code,
        duration: "30'",
        sort_order: 2,
        sets: [
          {
            set_number: 1,
            duration: "5'",
            equipment_upper: "3.00 kg",
            equipment_lower: "3.00 kg",
            type_id: "",
            type_name: "",
            bpm: "",
            extra_load: "",
            notes: "",
            sort_order: 0,
            items: presetItems,
          }
        ]
      }
    ];

    return {
      id: "preset-card",
      customer_id: customerId,
      level: "1",
      notes: "",
      sequences: sequences,
    };
  }, [isOverriddenTier, customerId, customerPrograms, profile]);

  const card = dbCard;

  const { data: equipData } = useEquipments();
  const equipments = (equipData?.data ?? []) as any[];

  const { data: setupData } = useCustomerSetup(customerId as string);
  const trainerName = setupData?.data?.staff?.trainer_name;

  const [editing, setEditing] = useState(false);
  const [form, setForm] = useState<CardForm | null>(null);
  const [deleteOpen, setDeleteOpen] = useState(false);

  const hasAutoStarted = useRef(false);
  useEffect(() => {
    if (
      !cardLoading &&
      !isLoadingTemplate &&
      !isLoadingMenu &&
      !isLoadingAssessment &&
      !isLoadingPrograms &&
      !card &&
      !editing &&
      canEdit &&
      !hasAutoStarted.current &&
      // auto-start if there is a template, or preset, or at least active customer programs to map Modul Card to
      (templateCard || presetCard || customerPrograms.length > 0)
    ) {
      hasAutoStarted.current = true;
      startEdit(fcData?.data as any[], ccData?.data as any[], mcData?.data as any[]);
    }
  }, [cardLoading, isLoadingTemplate, isLoadingMenu, isLoadingAssessment, isLoadingPrograms, card, editing, canEdit, templateCard, presetCard, customerPrograms, fcData, ccData, mcData]);

  // Build SearchableSelect options
  const typeOptions = useMemo(() =>
    types.filter((t: any) => t.is_active).map((t: any) => ({
      value: t.id, label: t.name, sublabel: t.description || "",
    })), [types]);

  const movementOptions = useMemo(() =>
    movements.map((m: any) => ({
      value: m.id, label: m.name, sublabel: m.body_part, pattern: m.pattern,
    })), [movements]);

  // Build a map for quick lookup of movement name by id
  const movementMap = useMemo(() => {
    const map: Record<string, string> = {};
    movements.forEach((m: any) => { map[m.id] = m.name; });
    return map;
  }, [movements]);

  // Equipment options for SearchableSelect
  const equipUpperOptions = useMemo(() =>
    equipUpper.filter((e: any) => e.is_active).map((e: any) => ({
      value: e.name, label: e.name,
    })), [equipUpper]);

  const equipLowerOptions = useMemo(() =>
    equipLower.filter((e: any) => e.is_active).map((e: any) => ({
      value: e.name, label: e.name,
    })), [equipLower]);

  // ── Form init ──────────────────────────────────────────────
  function startEdit(fcItemsParam?: any[], ccItemsParam?: any[], mcItemsParam?: any[]) {
    if (card) {
      setForm({
        level: card.level || "",
        notes: card.notes || "",
        sequences: (card.sequences || []).map((s: any, si: number) => ({
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
            pattern: set.pattern || "",
            breathing_core: set.breathing_core || "",
            breathing_diaphragm: set.breathing_diaphragm || "",
            notes: set.notes || "",
            sort_order: seti,
            items: (set.items || []).map((item: any, ii: number) => ({
              movement_id: item.movement_id || null,
              movement_name: item.movement_name || "",
              body_part: item.body_part || "upper",
              equipment: item.equipment || "",
              reps: item.reps ?? null,
              sets_count: item.sets_count ?? 1,
              breathing_core: item.breathing_core || "",
              breathing_diaphragm: item.breathing_diaphragm || "",
              sort_order: ii,
            })),
          })),
        })),
      });
    } else {
      const defaultLevel = physicalLevel || "";
      const defaultCard = templateCard || presetCard;

      setForm({
        level: defaultLevel,
        notes: defaultCard?.notes || "",
        sequences: defaultCard ? defaultCard.sequences.map((s: any, si: number) => ({
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
            pattern: set.pattern || "",
            breathing_core: set.breathing_core || "",
            breathing_diaphragm: set.breathing_diaphragm || "",
            notes: set.notes || "",
            sort_order: seti,
            items: (set.items || []).map((item: any, ii: number) => ({
              movement_id: item.movement_id || null,
              movement_name: item.movement_name || "",
              body_part: item.body_part || "upper",
              equipment: item.equipment || "",
              reps: item.reps ?? null,
              sets_count: item.sets_count ?? 1,
              breathing_core: item.breathing_core || "",
              breathing_diaphragm: item.breathing_diaphragm || "",
              sort_order: ii,
            })),
          })),
        })) : customerPrograms
          .filter((p: any) => p.is_active)
          .map((p: any, i: number) => {
            let menuItems: any[] = [];
            if (p.program_category_code === "functional") menuItems = fcItemsParam || (fcData as any)?.data || [];
            if (p.program_category_code === "cardiorespiratory") menuItems = ccItemsParam || (ccData as any)?.data || [];
            if (p.program_category_code === "metabolic") menuItems = mcItemsParam || (mcData as any)?.data || [];
            
            return {
              program_category_id: p.program_category_id,
              program_category_name: p.program_category_name,
              program_category_code: p.program_category_code,
              duration: "",
              sort_order: i,
              sets: buildSetsFromMenuItems(menuItems),
            };
          }),
      });
    }
    setEditing(true);
  }

  function cancelEdit() { setForm(null); setEditing(false); }

  async function handleSave() {
    if (!form) return;
    const payload = {
      customerId,
      level: form.level,
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
          pattern: set.pattern || null,
          breathing_core: set.breathing_core || null,
          breathing_diaphragm: set.breathing_diaphragm || null,
          notes: set.notes || null,
          sort_order: set.sort_order,
          items: set.items.map((item) => ({
            movement_id: item.movement_id || null,
            movement_name: item.movement_name || null,
            body_part: item.body_part,
            equipment: item.equipment || null,
            reps: item.reps || null,
            sets_count: item.sets_count || 1,
            breathing_core: item.breathing_core || null,
            breathing_diaphragm: item.breathing_diaphragm || null,
            sort_order: item.sort_order,
          })),
        })),
      })),
    };
    await upsertCard.mutateAsync(payload);
    setEditing(false);
    setForm(null);
  }

  async function handleDelete() {
    await deleteCard.mutateAsync(customerId);
    setDeleteOpen(false);
  }

  // ── Form mutation helpers ──────────────────────────────────
  function updateSeq(si: number, patch: Partial<CardSequence>) {
    if (!form) return;
    const seqs = [...form.sequences];
    seqs[si] = { ...seqs[si], ...patch };
    setForm({ ...form, sequences: seqs });
  }

  // Calculate recommended weights helper that respects level
  function addSet(si: number) {
    if (!form) return;
    const seqs = [...form.sequences];
    const sets = [...seqs[si].sets];
    
    // Calculate recommended weights
    const code = seqs[si].program_category_code || "";
    let equipUpper = "";
    let equipLower = "";
    if (code === "cardiorespiratory" && recs.cardio.upper) {
      equipUpper = recs.cardio.upper;
      equipLower = recs.cardio.lower;
    } else if (code === "metabolic" && recs.metabolic.upper) {
      equipUpper = recs.metabolic.upper;
      equipLower = recs.metabolic.lower;
    }

    sets.push({
      set_number: sets.length + 1,
      duration: "", equipment_upper: equipUpper, equipment_lower: equipLower,
      type_id: "", bpm: "", extra_load: "", pattern: "", breathing_core: "", breathing_diaphragm: "", notes: "",
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

  // Breathing & patterns update handles
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
      equipment: "", reps: 20, sets_count: 1, breathing_core: "", breathing_diaphragm: "", sort_order: items.length,
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
  if (userLoading || cardLoading) {
    return (
      <div className="flex justify-center py-20">
        <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
      </div>
    );
  }

  const displayData = editing ? form : card;
  const sequences: CardSequence[] = displayData?.sequences || [];

  // ─── Render ───────────────────────────────────────────────────

  return (
    <div className="space-y-4 max-w-[1400px]">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <Link href={`/clients/${customerId}`} className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-slate-700">
          <ArrowLeft className="h-4 w-4" /> Kembali ke Detail Client
        </Link>
        {card ? (
          <Link 
            href={`/clients/${customerId}/live-session`}
            className="inline-flex items-center gap-2 bg-sf-deepNavy text-white px-6 py-2.5 rounded-lg font-bold hover:bg-slate-800 transition-colors shadow-sm"
          >
            <svg className="w-4 h-4 text-sf-warmGold" fill="currentColor" viewBox="0 0 24 24"><path d="M8 5v14l11-7z" /></svg>
            Mulai Latihan (Live Session)
          </Link>
        ) : (
          <button 
            disabled
            className="inline-flex items-center gap-2 bg-slate-200 text-slate-400 px-6 py-2.5 rounded-lg font-bold cursor-not-allowed"
          >
            <svg className="w-4 h-4 text-slate-400" fill="currentColor" viewBox="0 0 24 24"><path d="M8 5v14l11-7z" /></svg>
            Simpan Kartu untuk Mulai Latihan
          </button>
        )}
      </div>
      {isTier1 && (
        <div className="bg-amber-50 border border-amber-200 text-amber-800 px-4 py-3 rounded-lg flex items-start gap-3">
          <div className="mt-0.5">
            <svg className="h-5 w-5 text-amber-500" viewBox="0 0 20 20" fill="currentColor">
              <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clipRule="evenodd" />
            </svg>
          </div>
          <div>
            <h4 className="text-sm font-semibold">Training Card Mandiri (Tier 1)</h4>
            <p className="text-xs mt-0.5">
              Program ini dibuat otomatis oleh sistem dan bersifat read-only. Client perlu mengupgrade paket untuk mendapatkan penyesuaian khusus dari Trainer.
            </p>
          </div>
        </div>
      )}

      {/* ═══ TRAINING CARD HEADER ═══════════════════════════════ */}
      <div className="border border-slate-200 rounded-lg overflow-hidden shadow-sm">
        {/* Title bar */}
        <div className="bg-slate-800 text-white px-5 py-3 flex items-center justify-between">
          <h1 className="text-lg font-bold tracking-widest">TRAINING CARD</h1>
          <div className="flex items-center gap-2">
            {isOverriddenTier && (
              <span className="px-3 py-1.5 text-xs font-bold bg-sf-warmGold/20 text-sf-warmGold rounded border border-sf-warmGold/35 mr-2">
                Preset Card (SF Tier {isTier2 ? "2" : "3"})
              </span>
            )}
            {card && (
              <span className={cn("px-3 py-1.5 text-xs font-bold rounded border mr-2", card.status === "published" ? "bg-green-500/20 text-green-400 border-green-500/30" : "bg-orange-500/20 text-orange-400 border-orange-500/30")}>
                {card.status === "published" ? "Published" : "Draft"}
              </span>
            )}
            {!canEdit ? (
              <span className="px-3 py-1.5 text-xs font-medium bg-white/10 text-white/80 rounded border border-white/15">
                Mode lihat saja
              </span>
            ) : editing ? (
              <>
                <button onClick={cancelEdit} className="px-3 py-1.5 text-xs rounded-md bg-white/10 hover:bg-white/20 flex items-center gap-1.5 transition-colors">
                  <X className="h-3.5 w-3.5" />Batal
                </button>
                <button
                  onClick={handleSave}
                  disabled={upsertCard.isPending || !form?.level}
                  className="px-4 py-1.5 text-xs rounded-md bg-sf-deepNavy hover:bg-sf-deepNavy disabled:opacity-50 flex items-center gap-1.5 font-medium transition-colors"
                >
                  {upsertCard.isPending ? <Loader2 className="h-3.5 w-3.5 animate-spin" /> : <Save className="h-3.5 w-3.5" />}
                  Simpan
                </button>
              </>
            ) : (
              <>
                <button onClick={() => startEdit()} className="px-3 py-1.5 text-xs rounded-md bg-white/10 hover:bg-white/20 flex items-center gap-1.5 transition-colors">
                  <Pencil className="h-3.5 w-3.5" /> Edit
                </button>
                {card && (
                  <button onClick={() => setDeleteOpen(true)} className="px-3 py-1.5 text-xs rounded-md bg-red-500/80 hover:bg-red-500 flex items-center gap-1.5 transition-colors">
                    <Trash2 className="h-3.5 w-3.5" /> Hapus
                  </button>
                )}
                {card && card.status !== "published" && (
                  <button 
                    onClick={() => publishCard.mutate(customerId as string)}
                    disabled={publishCard.isPending || !trainerName}
                    className="px-3 py-1.5 text-xs font-medium rounded-md bg-green-600 hover:bg-green-500 text-white flex items-center gap-1.5 transition-colors disabled:opacity-50"
                  >
                    {publishCard.isPending ? <Loader2 className="h-3.5 w-3.5 animate-spin" /> : <Send className="h-3.5 w-3.5" />}
                    Kirim ke Trainer {trainerName ? `(${trainerName})` : "(Belum ada Trainer)"}
                  </button>
                )}
              </>
            )}
          </div>
        </div>

        {/* NAMA + LEVEL — Excel-like table row */}
        <table className="w-full text-sm border-collapse">
          <tbody>
            <tr className="border-b border-slate-200">
              <td className="bg-slate-100 px-4 py-2.5 font-bold text-xs text-slate-600 w-20 border-r border-slate-200">NAMA</td>
              <td className="px-4 py-2.5 font-semibold text-slate-900" colSpan={3}>
                {user?.full_name || "-"}
              </td>
              <td className="bg-slate-100 px-4 py-2.5 font-bold text-xs text-slate-600 w-20 border-l border-r border-slate-200">LEVEL</td>
              <td className="px-4 py-2.5" colSpan={3}>
                {editing && form ? (
                  <div className="w-40">
                    <SearchableSelect
                      options={LEVELS}
                      value={form.level}
                      onChange={(v) => setForm({ ...form, level: v })}
                      placeholder="Pilih Level..."
                      searchPlaceholder="Cari level..."
                    />
                  </div>
                ) : (
                  <span className="inline-flex px-3 py-1 bg-sf-iceBlue text-sf-deepNavy font-bold text-sm rounded-md">
                    {getLevelLabel(displayData?.level || latestAssessmentData?.data?.physical_status_level || "") || "-"}
                  </span>
                )}
              </td>
            </tr>
            <tr className="border-b border-slate-200 bg-slate-50/50">
              <td className="bg-slate-100 px-4 py-2.5 font-bold text-xs text-slate-600 w-20 border-r border-slate-200">DATA CLIENT</td>
              <td className="px-4 py-2.5 text-xs text-slate-700 font-medium" colSpan={7}>
                <div className="flex flex-wrap gap-x-6 gap-y-1.5 items-center">
                  <div><strong>Gender:</strong> <span className="capitalize">{profile?.gender || "-"}</span></div>
                  <div><strong>Usia:</strong> {age !== null ? `${age} tahun` : "-"}</div>
                  <div><strong>Tinggi:</strong> {profile?.height_cm ? `${profile.height_cm} cm` : "-"}</div>
                  {recs.categoryText && (
                    <div className="text-sf-deepNavy font-bold bg-sf-iceBlue px-2.5 py-1 rounded-md border border-sf-iceBlue">
                      Kategori Weight: {recs.categoryText}
                    </div>
                  )}
                  {recs.cardio.upper && (
                    <div className="text-xs text-slate-600 bg-slate-100 px-2 py-1 rounded">
                      <strong>Rekomendasi Cardio:</strong> Upper {recs.cardio.upper} · Lower {recs.cardio.lower}
                    </div>
                  )}
                  {recs.metabolic.upper && (
                    <div className="text-xs text-slate-600 bg-slate-100 px-2 py-1 rounded">
                      <strong>Rekomendasi Metabolic:</strong> Upper {recs.metabolic.upper} · Lower {recs.metabolic.lower}
                    </div>
                  )}
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      {/* ═══ NO DATA STATE ═════════════════════════════════════ */}
      {!card && !editing && (
        <div className="border border-dashed border-slate-300 rounded-lg p-12 text-center">
          <p className="text-slate-400 text-sm mb-4">Belum ada Training Card untuk customer ini</p>
          <button onClick={() => startEdit()} className="btn-primary">
            <Plus className="h-4 w-4" /> Buat Training Card
          </button>
        </div>
      )}

      {/* ═══ SEQUENCES (FC / CC / MC) ═════════════════════════ */}
      {sequences.map((seq, si) => {
        const code = seq.program_category_code || "";
        const isMetabolic = code === "metabolic";
        return (
          <SequenceTable
            key={seq.program_category_id}
            seq={seq}
            si={si}
            level={displayData?.level || ""}
            isMetabolic={isMetabolic}
            editing={editing}
            typeOptions={typeOptions}
            movementOptions={movementOptions}
            movementMap={movementMap}
            types={types}
            equipUpperOptions={equipUpperOptions}
            equipLowerOptions={equipLowerOptions}
            recs={recs}
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

      {/* Cool Down placeholder */}
      {sequences.length > 0 && (
        <div className="border border-slate-200 rounded-lg overflow-hidden">
          <div className="bg-slate-200 px-4 py-2 text-xs font-bold text-slate-600 tracking-wider">
            COOL DOWN
          </div>
          {editing && form ? (
            <div className="px-4 py-3">
              <textarea
                value={form.notes}
                onChange={(e) => setForm({ ...form, notes: e.target.value })}
                className={cn(inpCell, "min-h-[50px]")}
                placeholder="Catatan cool down atau notes tambahan..."
              />
            </div>
          ) : (
            displayData?.notes && (
              <div className="px-4 py-3 text-sm text-slate-600">{displayData.notes}</div>
            )
          )}
        </div>
      )}

      {/* ═══ CONDITIONING REFERENCE TABLE ═══════════════════════ */}
      {(card || editing) && <ConditioningReferenceTable />}

      <ConfirmDialog
        open={deleteOpen}
        onClose={() => setDeleteOpen(false)}
        onConfirm={handleDelete}
        title="Hapus Training Card?"
        description="Semua data sequence, set, dan item akan dihapus. Tindakan ini tidak dapat dibatalkan."
        confirmLabel="Hapus"
        variant="danger"
        loading={deleteCard.isPending}
      />
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
//  Sequence Table — Excel-like table per FC / CC / MC
// ═══════════════════════════════════════════════════════════════

function SequenceTable({
  seq, si, level, isMetabolic, editing, typeOptions, movementOptions, movementMap, types,
  equipUpperOptions, equipLowerOptions, recs,
  onUpdateSeq, onAddSet, onRemoveSet, onUpdateSet, onAddItem, onRemoveItem, onUpdateItem,
}: {
  seq: CardSequence; si: number; level: string; isMetabolic: boolean; editing: boolean;
  typeOptions: { value: string; label: string; sublabel?: string }[];
  movementOptions: { value: string; label: string; sublabel?: string; pattern?: string | null }[];
  movementMap: Record<string, string>;
  types: any[];
  equipUpperOptions: { value: string; label: string }[];
  equipLowerOptions: { value: string; label: string }[];
  recs: any;
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
  let recommendedUpper = "";
  let recommendedLower = "";

  if (code === "cardiorespiratory") {
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
    recommendedUpper = recs.cardio.upper;
    recommendedLower = recs.cardio.lower;
  } else if (code === "metabolic") {
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
    recommendedUpper = recs.metabolic.upper;
    recommendedLower = recs.metabolic.lower;
  }
  const seqBg =
    code === "functional" ? "bg-blue-600" :
    code === "cardiorespiratory" ? "bg-orange-500" :
    code === "metabolic" ? "bg-purple-600" : "bg-slate-600";

  return (
    <div className="border border-slate-200 rounded-lg overflow-hidden shadow-sm">
      {/* Sequence header bar */}
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
              upperOptions={upperOptions}
              lowerOptions={lowerOptions}
              recommendedUpper={recommendedUpper}
              recommendedLower={recommendedLower}
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

// ═══════════════════════════════════════════════════════════════
//  Set Block — renders rows for a set (rowspan on set columns)
// ═══════════════════════════════════════════════════════════════

function SetBlock({
  set, seti, level, isMetabolic, editing, typeOptions, movementOptions, movementMap, types,
  upperOptions, lowerOptions, recommendedUpper, recommendedLower,
  onUpdateSet, onRemoveSet, onAddItem, onRemoveItem, onUpdateItem,
}: {
  set: CardSet; seti: number; level: string; isMetabolic: boolean; editing: boolean;
  typeOptions: { value: string; label: string; sublabel?: string }[];
  movementOptions: { value: string; label: string; sublabel?: string; pattern?: string | null }[];
  movementMap: Record<string, string>;
  types: any[];
  upperOptions: { value: string; label: string }[];
  lowerOptions: { value: string; label: string }[];
  recommendedUpper: string;
  recommendedLower: string;
  onUpdateSet: (p: Partial<CardSet>) => void;
  onRemoveSet: () => void;
  onAddItem: (bodyPart: string) => void;
  onRemoveItem: (ii: number) => void;
  onUpdateItem: (ii: number, p: Partial<CardItem>) => void;
}) {
  const selectedPatterns = set.pattern ? set.pattern.split(",").map(p => p.trim()).filter(Boolean) : [];
  const isLevel1 = level === "1" || level === "1-499" || level === "1-799";

  return (
    <div className="bg-white border border-slate-200 rounded-lg shadow-sm overflow-hidden flex flex-col">
      {/* Set Header */}
      <div className="bg-slate-100 px-4 py-2 border-b border-slate-200 flex items-center justify-between">
        <span className="font-bold text-slate-700">Set {set.set_number}</span>
        {editing && (
          <button onClick={onRemoveSet} className="text-red-500 hover:text-red-600 p-1 transition-colors" title="Hapus set">
            <Trash2 className="h-4 w-4" />
          </button>
        )}
      </div>

      {/* Set Properties Grid */}
      <div className="p-4 border-b border-slate-100">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {/* Pattern */}
          <div>
            <label className="block text-[10px] font-bold text-slate-500 mb-1.5 uppercase tracking-wider">Pattern</label>
            {editing ? (
              <Popover.Root>
                <Popover.Trigger asChild>
                  <button type="button" className="text-left truncate bg-white border border-slate-200 rounded-md px-3 py-1.5 text-slate-700 w-full flex items-center justify-between hover:border-slate-300 transition-colors">
                    <span className="truncate text-sm">{selectedPatterns.length > 0 ? selectedPatterns.join(", ") : "Pilih..."}</span>
                    <ChevronDown className="h-4 w-4 text-slate-400 shrink-0 ml-1" />
                  </button>
                </Popover.Trigger>
                <Popover.Portal>
                  <Popover.Content align="start" className="z-50 bg-white rounded-lg shadow-lg border border-slate-200 p-2 space-y-1 w-[200px]">
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
                        <label key={p} className="flex items-center gap-2 px-2 py-1.5 hover:bg-slate-50 rounded text-sm cursor-pointer select-none">
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
                          <span>{p}</span>
                        </label>
                      );
                    })}
                  </Popover.Content>
                </Popover.Portal>
              </Popover.Root>
            ) : (
              <span className="text-sm font-medium text-slate-800">{set.pattern ? set.pattern.split(",").join(", ") : "-"}</span>
            )}
          </div>

          {/* Breathing */}
          <div>
            <label className="block text-[10px] font-bold text-slate-500 mb-1.5 uppercase tracking-wider">Breathing</label>
            {editing ? (
              <select
                value={set.breathing_core || ""}
                onChange={(e) => onUpdateSet({ breathing_core: e.target.value })}
                className="w-full text-sm border border-slate-200 rounded-md px-2 py-1.5 focus:outline-none focus:border-sf-deepNavy bg-white"
              >
                <option value="">Pilih...</option>
                <option value="Core">Core</option>
                <option value="Diafragma">Diafragma</option>
              </select>
            ) : (
              <div className="text-sm font-medium text-slate-800">
                {set.breathing_core || "-"}
              </div>
            )}
          </div>

          {/* Duration & Load/BPM */}
          <div>
            <label className="block text-[10px] font-bold text-slate-500 mb-1.5 uppercase tracking-wider">Duration / {isMetabolic ? "Extra Load" : "BPM"}</label>
            {editing ? (
              <div className="flex gap-2">
                <input 
                  value={set.duration || ""} 
                  onChange={(e) => onUpdateSet({ duration: e.target.value })} 
                  className="w-1/2 text-sm border border-slate-200 rounded-md px-3 py-1.5 focus:outline-none focus:border-sf-deepNavy" 
                  placeholder="Durasi (3-5 min)" 
                />
                <input
                  value={isMetabolic ? (set.extra_load || "") : (set.bpm || "")}
                  onChange={(e) => isMetabolic ? onUpdateSet({ extra_load: e.target.value }) : onUpdateSet({ bpm: e.target.value })}
                  className="w-1/2 text-sm border border-slate-200 rounded-md px-3 py-1.5 focus:outline-none focus:border-sf-deepNavy"
                  placeholder={isMetabolic ? "Load" : "Zona 1-2"}
                />
              </div>
            ) : (
              <div className="text-sm space-y-0.5">
                <div><span className="text-slate-400">Durasi:</span> <span className="font-medium text-slate-700">{set.duration || "-"}</span></div>
                <div><span className="text-slate-400">{isMetabolic ? "Load:" : "BPM:"}</span> <span className="font-medium text-slate-700">{isMetabolic ? (set.extra_load || "-") : (set.bpm || "-")}</span></div>
              </div>
            )}
          </div>

          {/* Equipment */}
          <div>
             <label className="block text-[10px] font-bold text-slate-500 mb-1.5 uppercase tracking-wider">Equipment</label>
             {editing ? (
               <div className="flex gap-2">
                 <div className="flex-1 min-w-0">
                    <span className="text-[10px] text-slate-400 block mb-0.5">Upper {recommendedUpper && `(${recommendedUpper})`}</span>
                    <SearchableSelect
                      options={upperOptions}
                      value={set.equipment_upper || ""}
                      onChange={(v) => onUpdateSet({ equipment_upper: v })}
                      placeholder="Upper..."
                      searchPlaceholder="Cari..."
                    />
                 </div>
                 <div className="flex-1 min-w-0">
                    <span className="text-[10px] text-slate-400 block mb-0.5">Lower {recommendedLower && `(${recommendedLower})`}</span>
                    <SearchableSelect
                      options={lowerOptions}
                      value={set.equipment_lower || ""}
                      onChange={(v) => onUpdateSet({ equipment_lower: v })}
                      placeholder="Lower..."
                      searchPlaceholder="Cari..."
                    />
                 </div>
               </div>
             ) : (
               <div className="text-sm space-y-0.5">
                 <div><span className="text-slate-400">Upper:</span> <span className="font-semibold text-slate-600">{set.equipment_upper ? `💪 ${formatWeight(set.equipment_upper)}` : "-"}</span></div>
                 <div><span className="text-slate-400">Lower:</span> <span className="font-semibold text-slate-600">{set.equipment_lower ? `🦵 ${formatWeight(set.equipment_lower)}` : "-"}</span></div>
               </div>
             )}
          </div>

          {/* Notes */}
          <div className="md:col-span-2 lg:col-span-4 mt-2">
            <label className="block text-[10px] font-bold text-slate-500 mb-1.5 uppercase tracking-wider">Notes</label>
            {editing ? (
              <input
                value={set.notes || ""}
                onChange={(e) => onUpdateSet({ notes: e.target.value })}
                className="w-full text-sm border border-slate-200 rounded-md px-3 py-2 focus:outline-none focus:border-sf-deepNavy"
                placeholder="Tambahkan catatan khusus untuk set ini..."
              />
            ) : (
              <span className="text-sm text-slate-600">{set.notes || "-"}</span>
            )}
          </div>
        </div>
      </div>

      {/* Movements / Items List */}
      <div className="bg-slate-50 p-4">
        <h4 className="text-[11px] font-bold text-slate-600 mb-3 uppercase tracking-widest flex items-center gap-2">
          Gerakan (Movements)
          <span className="bg-slate-200 text-slate-600 px-2 py-0.5 rounded-full text-[9px]">{set.items.length}</span>
        </h4>
        
        {set.items.length === 0 ? (
          <div className="text-sm text-slate-400 italic mb-4 bg-white p-4 rounded border border-dashed border-slate-300 text-center">
            Belum ada gerakan
          </div>
        ) : (
          <div className="space-y-3 mb-4">
            {set.items.map((item, ii) => (
              <div key={ii} className="flex flex-col md:flex-row gap-4 bg-white p-3 border border-slate-200 rounded-md shadow-sm relative">
                
                {/* Bagian Nama & Body Part */}
                <div className="flex-1">
                  <div className="flex items-center justify-between mb-1.5">
                    <span className={cn(
                      "px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider",
                      item.body_part === "upper" ? "bg-blue-100 text-blue-700" :
                      item.body_part === "lower" ? "bg-green-100 text-green-700" :
                      "bg-amber-100 text-amber-700"
                    )}>
                      {item.body_part}
                    </span>
                    {editing && (
                      <button onClick={() => onRemoveItem(ii)} className="text-red-400 hover:text-red-600 transition-colors md:hidden">
                        <Trash2 className="h-4 w-4" />
                      </button>
                    )}
                  </div>
                  
                  {editing ? (
                    <MovementSelect
                      options={movementOptions}
                      movementMap={movementMap}
                      item={item}
                      bodyPart={item.body_part}
                      selectedPatterns={selectedPatterns}
                      onUpdate={(p) => onUpdateItem(ii, p)}
                    />
                  ) : (
                    <div className="font-semibold text-slate-800 text-sm mt-1">{item.movement_name || "-"}</div>
                  )}
                </div>

                {/* Bagian Reps & Breathing Khusus (Jika Level 1) */}
                <div className="flex items-end gap-3 md:w-auto w-full border-t border-slate-100 md:border-none pt-3 md:pt-0">
                  {/* Reps */}
                  <div className="w-20 shrink-0">
                    <label className="block text-[10px] text-slate-400 mb-1">Reps</label>
                    {editing ? (
                      <input 
                        type="number" 
                        value={item.reps ?? ""} 
                        onChange={(e) => onUpdateItem(ii, { reps: e.target.value ? +e.target.value : null })} 
                        className="w-full text-sm border border-slate-200 rounded px-2 py-1.5 focus:outline-none focus:border-sf-deepNavy text-center" 
                      />
                    ) : (
                      <div className="font-medium text-sm text-center">{item.reps ?? "-"}</div>
                    )}
                  </div>
                  
                  {/* Sets Count (Terkadang digunakan) */}
                  <div className="w-16 shrink-0">
                    <label className="block text-[10px] text-slate-400 mb-1">Set</label>
                    {editing ? (
                      <input 
                        type="number" 
                        value={item.sets_count ?? ""} 
                        onChange={(e) => onUpdateItem(ii, { sets_count: e.target.value ? +e.target.value : null })} 
                        className="w-full text-sm border border-slate-200 rounded px-2 py-1.5 focus:outline-none focus:border-sf-deepNavy text-center" 
                      />
                    ) : (
                      <div className="font-medium text-sm text-center">{item.sets_count ?? "-"}</div>
                    )}
                  </div>

                  {/* Breathing khusus level 1 per item */}
                  {isLevel1 && (
                    <div className="w-24 shrink-0 space-y-1">
                      <label className="block text-[10px] text-slate-400 mb-1">Breathing</label>
                      {editing ? (
                        <select
                          value={item.breathing_core || ""}
                          onChange={(e) => onUpdateItem(ii, { breathing_core: e.target.value })}
                          className="text-[10px] w-full border border-slate-200 rounded px-1.5 py-1 focus:outline-none bg-white"
                        >
                          <option value="">Pilih...</option>
                          <option value="Core">Core</option>
                          <option value="Diafragma">Diafragma</option>
                        </select>
                      ) : (
                        <div className="font-medium text-sm text-center">
                          {item.breathing_core || "-"}
                        </div>
                      )}
                    </div>
                  )}

                  {/* Desktop Delete button */}
                  {editing && (
                    <button onClick={() => onRemoveItem(ii)} className="hidden md:flex text-red-400 hover:text-red-600 transition-colors p-2 mb-0.5" title="Hapus gerakan">
                      <Trash2 className="h-4 w-4" />
                    </button>
                  )}
                </div>

              </div>
            ))}
          </div>
        )}

        {/* Add Movement Buttons */}
        {editing && (
          <div className="flex flex-wrap gap-2">
            <button
              onClick={() => onAddItem("upper")}
              className="px-4 py-2 text-xs rounded border border-blue-200 text-blue-700 bg-blue-50 hover:bg-blue-100 transition-colors flex items-center gap-1.5 font-medium shadow-sm"
            >
              <Plus className="h-3.5 w-3.5" /> Tambah Upper
            </button>
            <button
              onClick={() => onAddItem("lower")}
              className="px-4 py-2 text-xs rounded border border-green-200 text-green-700 bg-green-50 hover:bg-green-100 transition-colors flex items-center gap-1.5 font-medium shadow-sm"
            >
              <Plus className="h-3.5 w-3.5" /> Tambah Lower
            </button>
            {isMetabolic && (
              <button
                onClick={() => onAddItem("core")}
                className="px-4 py-2 text-xs rounded border border-amber-200 text-amber-700 bg-amber-50 hover:bg-amber-100 transition-colors flex items-center gap-1.5 font-medium shadow-sm"
              >
                <Plus className="h-3.5 w-3.5" /> Tambah Core
              </button>
            )}
          </div>
        )}
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
  options: { value: string; label: string; sublabel?: string; pattern?: string | null }[];
  movementMap: Record<string, string>;
  item: CardItem;
  bodyPart: string;
  selectedPatterns: string[];
  onUpdate: (p: Partial<CardItem>) => void;
}) {
  let filtered = options.filter(m => {
    const sub = (m.sublabel || "").toLowerCase();
    const bp = (bodyPart || "").toLowerCase();
    return sub === bp || sub === "whole body";
  });

  if (selectedPatterns && selectedPatterns.length > 0) {
    filtered = filtered.filter(m => {
      const p = (m.pattern || "").toLowerCase();
      if (!p) return false;
      return selectedPatterns.some(sp => 
        sp.toLowerCase().includes(p) || p.includes(sp.toLowerCase())
      );
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
          className="mt-1.5 w-full border border-slate-200 rounded px-2 py-1 text-xs focus:outline-none focus:ring-1 focus:ring-sf-deepNavy bg-white"
          placeholder="Atau ketik manual..."
        />
      )}
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
//  Conditioning Reference Table — static guideline at bottom
// ═══════════════════════════════════════════════════════════════

function ConditioningReferenceTable() {
  const thBase = "px-3 py-2 text-xs font-bold text-slate-600 border border-slate-300 text-center uppercase tracking-wider bg-slate-100";
  const tdBase = "px-3 py-1.5 text-xs border border-slate-200 text-center";

  return (
    <div className="space-y-4">
      <div className="bg-slate-800 text-white px-4 py-2.5 text-xs font-bold rounded-t-lg tracking-widest uppercase">
        ACUAN BEBAN / LOAD/WEIGHT REFERENCE
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {/* WOMAN COLUMN */}
        <div className="border border-slate-300 rounded-lg overflow-hidden shadow-sm bg-white">
          <table className="w-full text-xs border-collapse">
            <thead>
              <tr className="bg-pink-600 text-white">
                <th className="px-3 py-2 text-sm font-bold text-center uppercase tracking-widest" colSpan={3}>WOMAN</th>
              </tr>
              <tr className="bg-slate-100 border-b border-slate-200">
                <th className="px-3 py-2 text-xs font-bold text-slate-600 text-center uppercase tracking-wider" colSpan={3}>Cardio Conditioning</th>
              </tr>
              <tr className="bg-slate-50 border-b border-slate-200">
                <th className={cn(thBase, "text-left border-r border-slate-200")}>Kategori</th>
                <th className={cn(thBase, "border-r border-slate-200")}>Upper Body</th>
                <th className={thBase}>Lower Body</th>
              </tr>
            </thead>
            <tbody>
              <tr className="border-b border-slate-200">
                <td className={cn(tdBase, "text-left font-medium border-r border-slate-200")}>Teenager - 20 tahun</td>
                <td className={cn(tdBase, "border-r border-slate-200")}>0.25 kg</td>
                <td className={tdBase}>0.75 kg</td>
              </tr>
              <tr className="border-b border-slate-200">
                <td className={cn(tdBase, "text-left font-medium border-r border-slate-200")}>Wanita tinggi 155 - 175 cm</td>
                <td className={cn(tdBase, "border-r border-slate-200")}>0.5 kg</td>
                <td className={tdBase}>1 kg</td>
              </tr>
              <tr className="border-b border-slate-200">
                <td className={cn(tdBase, "text-left font-medium border-r border-slate-200")}>Wanita tinggi &gt; 175</td>
                <td className={cn(tdBase, "border-r border-slate-200")}>0.75 kg</td>
                <td className={tdBase}>1.5 kg</td>
              </tr>
              <tr className="bg-slate-100 border-b border-slate-200">
                <th className="px-3 py-2 text-xs font-bold text-slate-600 text-center uppercase tracking-wider" colSpan={3}>Metabolic Conditioning</th>
              </tr>
              <tr className="border-b border-slate-200">
                <td className={cn(tdBase, "text-left font-medium border-r border-slate-200")}>Teenager - 20 tahun</td>
                <td className={cn(tdBase, "border-r border-slate-200")}>1 kg</td>
                <td className={tdBase}>1.5 kg</td>
              </tr>
              <tr className="border-b border-slate-200">
                <td className={cn(tdBase, "text-left font-medium border-r border-slate-200")}>Dewasa tinggi 155 - 175 cm</td>
                <td className={cn(tdBase, "border-r border-slate-200")}>1.5 kg</td>
                <td className={tdBase}>2 kg</td>
              </tr>
              <tr>
                <td className={cn(tdBase, "text-left font-medium border-r border-slate-200")}>Wanita tinggi &gt; 175</td>
                <td className={cn(tdBase, "border-r border-slate-200")}>2 kg</td>
                <td className={tdBase}>2.5 kg</td>
              </tr>
            </tbody>
          </table>
        </div>

        {/* MAN COLUMN */}
        <div className="border border-slate-300 rounded-lg overflow-hidden shadow-sm bg-white">
          <table className="w-full text-xs border-collapse">
            <thead>
              <tr className="bg-blue-600 text-white">
                <th className="px-3 py-2 text-sm font-bold text-center uppercase tracking-widest" colSpan={3}>MAN</th>
              </tr>
              <tr className="bg-slate-100 border-b border-slate-200">
                <th className="px-3 py-2 text-xs font-bold text-slate-600 text-center uppercase tracking-wider" colSpan={3}>Cardio Conditioning</th>
              </tr>
              <tr className="bg-slate-50 border-b border-slate-200">
                <th className={cn(thBase, "text-left border-r border-slate-200")}>Kategori</th>
                <th className={cn(thBase, "border-r border-slate-200")}>Upper Body</th>
                <th className={thBase}>Lower Body</th>
              </tr>
            </thead>
            <tbody>
              <tr className="border-b border-slate-200">
                <td className={cn(tdBase, "text-left font-medium border-r border-slate-200")}>Teenager - 20 tahun</td>
                <td className={cn(tdBase, "border-r border-slate-200")}>0.5 kg</td>
                <td className={tdBase}>1.5 kg</td>
              </tr>
              <tr className="border-b border-slate-200">
                <td className={cn(tdBase, "text-left font-medium border-r border-slate-200")}>Dewasa tinggi 160 - 185 cm</td>
                <td className={cn(tdBase, "border-r border-slate-200")}>1 kg</td>
                <td className={tdBase}>2 kg</td>
              </tr>
              <tr className="border-b border-slate-200">
                <td className={cn(tdBase, "text-left font-medium border-r border-slate-200")}>Pria tinggi &gt; 185</td>
                <td className={cn(tdBase, "border-r border-slate-200")}>1.5 kg</td>
                <td className={tdBase}>3 kg</td>
              </tr>
              <tr className="bg-slate-100 border-b border-slate-200">
                <th className="px-3 py-2 text-xs font-bold text-slate-600 text-center uppercase tracking-wider" colSpan={3}>Metabolic Conditioning</th>
              </tr>
              <tr className="border-b border-slate-200">
                <td className={cn(tdBase, "text-left font-medium border-r border-slate-200")}>Teenager - 20 tahun</td>
                <td className={cn(tdBase, "border-r border-slate-200")}>2 kg</td>
                <td className={tdBase}>2 kg</td>
              </tr>
              <tr className="border-b border-slate-200">
                <td className={cn(tdBase, "text-left font-medium border-r border-slate-200")}>Dewasa tinggi 160 - 185 cm</td>
                <td className={cn(tdBase, "border-r border-slate-200")}>3 kg</td>
                <td className={tdBase}>3 kg</td>
              </tr>
              <tr>
                <td className={cn(tdBase, "text-left font-medium border-r border-slate-200")}>Pria tinggi &gt; 185</td>
                <td className={cn(tdBase, "border-r border-slate-200")}>4 kg</td>
                <td className={tdBase}>4 kg</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div className="bg-slate-50 border border-slate-200 rounded-lg p-4 space-y-2 text-xs text-slate-700">
        <div><strong>Breathing Pattern :</strong> Core, Diafragma</div>
        <div><strong>Tempo :</strong> BPM List / rekomendasi (bisa metronome atau musik bpm)</div>
      </div>
    </div>
  );
}

const formatWeight = (w: string | null | undefined): string => {
  if (!w) return "";
  return w.replace(/(\d+)\.00/g, "$1").replace(/(\d+\.\d)0/g, "$1");
};

