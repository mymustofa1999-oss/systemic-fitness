"use client";

import { useState, useMemo, useEffect, useRef } from "react";
import { toast } from "@/stores/toastStore";
import { apiGet } from "@/lib/api";
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
  useProgramCategories,
  useAssignStaff,
  useUpdateCustomerPriority,
  useEquipments,
  useCustomerSetup,
} from "@/hooks/useNewFeatures";
import { MedicinesCard } from "@/components/shared/MedicinesCard";
import { HRZoneTable } from "@/components/shared/HRZoneTable";

function calculateBPM(age: number | null, intensityCode: string) {
  if (!age || !intensityCode) return "";
  const maxHR = 220 - age;
  let minPct = 0;
  let maxPct = 0;
  
  const code = intensityCode.toLowerCase();
  if (code === "functional") {
    minPct = 0.50;
    maxPct = 0.60;
  } else if (code === "cardiorespiratory") {
    minPct = 0.70;
    maxPct = 0.85;
  } else if (code === "metabolic") {
    minPct = 0.85;
    maxPct = 0.95;
  } else {
    return "";
  }
  
  const minBPM = Math.round(maxHR * minPct);
  const maxBPM = Math.round(maxHR * maxPct);
  
  const roundedMin = Math.round(minBPM / 10) * 10;
  const roundedMax = Math.round(maxBPM / 10) * 10;
  return `${roundedMin}-${roundedMax} BPM`;
}

function buildSetsFromMenuItems(menuItems: any[], gender: string | undefined, seqCode: string, age: number | null, recs: any) {
  if (!menuItems || menuItems.length === 0) return [];
  
  const setsMap = new Map<string, any[]>();
  for (const item of menuItems) {
    const setName = item.set_name || "Uncategorized";
    if (!setsMap.has(setName)) setsMap.set(setName, []);
    setsMap.get(setName)!.push(item);
  }
  
  const sets: any[] = [];
  let setNumber = 1;
  for (const [setName, items] of Array.from(setsMap.entries())) {
    const patternsMap = new Map<string, any[]>();
    for (const item of items) {
      const typeName = item.group_type || "Isolate";
      if (!patternsMap.has(typeName)) patternsMap.set(typeName, []);
      patternsMap.get(typeName)!.push(item);
    }
    
    for (const [patternName, patternItems] of Array.from(patternsMap.entries())) {
      sets.push({
        set_number: setNumber,
        duration: "",
        equipment_upper: (() => {
          if (!seqCode || !recs) return "";
          const code = seqCode.toLowerCase();
          if (code === "cardiorespiratory" || code === "functional") return recs.cardio?.upper || "";
          if (code === "metabolic") return recs.metabolic?.upper || "";
          return "";
        })(),
        equipment_lower: (() => {
          if (!seqCode || !recs) return "";
          const code = seqCode.toLowerCase();
          if (code === "cardiorespiratory" || code === "functional") return recs.cardio?.lower || "";
          if (code === "metabolic") return recs.metabolic?.lower || "";
          return "";
        })(),
        equipment: (() => {
          if (!seqCode || !recs) return "";
          const code = seqCode.toLowerCase();
          if (code === "cardiorespiratory" || code === "functional") return recs.cardio?.upper || "";
          if (code === "metabolic") return recs.metabolic?.upper || "";
          return "";
        })(),
        type_id: "",
        type_name: "",
        bpm: calculateBPM(age, seqCode),
        extra_load: "",
        pattern: patternName,
        breathing_core: "",
        breathing_diaphragm: "",
        notes: setName,
        sort_order: setNumber - 1,
        items: patternItems.map((item, ii) => ({
          movement_id: item.movement_id || null,
          movement_name: (() => {
            const nameStr = item.movement?.name || "";
            const parts = nameStr.split(" | ");
            if (parts.length > 1) {
              return gender === "male" || gender === "men" ? parts[1] : parts[0];
            }
            return nameStr;
          })(),
          body_part: item.movement?.body_part || "upper",
          equipment: item.movement?.equipment || "",
          reps: (() => {
            if (!seqCode) return null;
            const code = seqCode.toLowerCase();
            if (code === "functional" || code === "cardiorespiratory") return 20;
            if (code === "metabolic") return 15;
            return null;
          })(),
          sets_count: 1,
          breathing_core: item.movement?.pattern || "",
          breathing_diaphragm: "",
          sort_order: ii,
        })),
      });
      setNumber++;
    }
  }
  return sets;
}

import { useTemplate } from "@/hooks/useTrainerCardTemplates";
import { useDLMovements, useDLMenuItems } from "@/hooks/useDigitalLibrary";
import { useLatestAssessmentV2 } from "@/hooks/useAssessmentV2";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { SearchableSelect } from "@/components/shared/SearchableSelect";
import { MultiSearchableSelect } from "@/components/shared/MultiSearchableSelect";
import * as Popover from "@radix-ui/react-popover";
import { DndContext, closestCenter, PointerSensor, useSensor, useSensors, DragEndEvent } from "@dnd-kit/core";
import { SortableContext, verticalListSortingStrategy, useSortable, arrayMove } from "@dnd-kit/sortable";
import { CSS } from "@dnd-kit/utilities";


import { 
  ArrowLeft, Plus, Trash2, Save, Loader2, Pencil, X,
  ChevronDown, ChevronRight, Send, GripVertical, Info, Clock, Pill, AlertTriangle, Video
} from "lucide-react";
import { cn } from "@/lib/utils";

// ─── Types ──────────────────────────────────────────────────────

interface CardItem {
  _uid?: string;
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
  equipment?: string | null;
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
  { value: "2", label: "Level 2" },
  { value: "3", label: "Level 3" },
  { value: "4", label: "Level 4" },
  { value: "5", label: "Level 5" },
  { value: "6", label: "Level 6" },
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

function formatMovementName(rawName: string, gender: string | undefined): string {
  if (!rawName) return "-";
  if (!rawName.includes(" | ")) return rawName;

  const normalizedGender = (gender || "").toLowerCase();
  
  // Extract level suffix if present
  let levelSuffix = "";
  let baseName = rawName;
  const levelMatch = rawName.match(/(\s*\[L\d+\])$/i);
  if (levelMatch) {
    levelSuffix = levelMatch[1];
    baseName = rawName.replace(/(\s*\[L\d+\])$/i, "");
  }

  const parts = baseName.split(" | ");
  if (parts.length >= 2) {
    const femaleName = parts[0].trim();
    const maleName = parts[1].trim();
    
    // Fix: if maleName is a youtube link (which happens if data was entered incorrectly)
    // just return the female name (the actual movement name) for both genders.
    if (maleName.startsWith("http")) {
        return femaleName + levelSuffix;
    }

    if (normalizedGender === "male" || normalizedGender === "pria" || normalizedGender === "men" || normalizedGender === "laki-laki") {
      return maleName + levelSuffix;
    }
    
    // Default to female name for female, wanita, women, or if gender is unknown/empty.
    // This prevents the raw string with "|" from ever being shown to the user.
    return femaleName + levelSuffix;
  }

  return rawName;
}

// ─── Page ───────────────────────────────────────────────────────


function ensureUids(sequences: any[]) {
  return sequences.map(seq => ({
    ...seq,
    sets: (seq.sets || []).map((set: any) => ({
      ...set,
      items: (set.items || []).map((item: any) => ({
        ...item,
        _uid: item._uid || (typeof crypto !== "undefined" && crypto.randomUUID ? crypto.randomUUID() : Math.random().toString(36).substring(2, 9))
      }))
    }))
  }));
}

export default function TrainingCardPage({ params }: { params: { id: string } }) {
  const [previewTarget, setPreviewTarget] = useState<{ movement: any; bpm: string } | null>(null);
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
  const { data: allCategoriesData } = useProgramCategories();
  const { data: movementsData } = useDLMovements({ limit: 2000 });
  const { data: equipUpperData } = useEquipments({ category: "upper", limit: 100 });
  const { data: equipLowerData } = useEquipments({ category: "lower", limit: 100 });
  const { data: equipGeneralData } = useEquipments({ limit: 500 });
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

  const assessmentPayload = latestAssessmentData?.data?.phase_a;
  const assessmentGender = assessmentPayload?.gender === "women" ? "female" : assessmentPayload?.gender === "men" ? "male" : undefined;
  const effectiveGender = profile?.gender || assessmentGender;

  const parsedMappedLevel = parseInt(mappedLevel) || 1;
  const { data: fcData, isLoading: isLoadingFC } = useDLMenuItems("fc", parsedMappedLevel, effectiveGender?.toLowerCase());
  const { data: ccData, isLoading: isLoadingCC } = useDLMenuItems("cc", parsedMappedLevel, effectiveGender?.toLowerCase());
  const { data: mcData, isLoading: isLoadingMC } = useDLMenuItems("mc", parsedMappedLevel, effectiveGender?.toLowerCase());
  const { data: cdData, isLoading: isLoadingCD } = useDLMenuItems("cd", parsedMappedLevel, effectiveGender?.toLowerCase());
  const isLoadingMenu = isLoadingFC || isLoadingCC || isLoadingMC || isLoadingCD;

  const { data: templateData, isLoading: isLoadingTemplate } = useTemplate(mappedLevel);
  const templateCard = templateData?.data as any;

  const upsertCard = useUpsertTrainerCard();
  const publishCard = usePublishTrainerCard();
  const deleteCard = useDeleteTrainerCard();

  const recs = useMemo(() => {
    return getClientCategoryAndLoads(effectiveGender, age, profile?.height_cm);
  }, [effectiveGender, age, profile?.height_cm]);
  const types = (typesData?.data ?? []) as any[];
  const customerPrograms = (programsData?.data ?? []) as any[];
  const allCategories = (allCategoriesData?.data ?? []) as any[];
  const movements = (movementsData?.data ?? []) as any[];
  const equipUpper = (equipUpperData?.data ?? []) as any[];
  const equipLower = (equipLowerData?.data ?? []) as any[];
  const equipGeneral = (equipGeneralData?.data ?? []) as any[];

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
      const fallbackCat = allCategories.find((cat: any) => cat.code === code);
      return {
        id: p?.program_category_id || fallbackCat?.id || code,
        name: p?.program_category_name || fallbackCat?.name || (code === "functional" ? "Functional Conditioning" : code === "cardiorespiratory" ? "Cardio Conditioning" : code === "metabolic" ? "Metabolic Conditioning" : "Cool Down"),
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
            equipment: "Wrist 0.25 kg",
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
            equipment: "1.00 kg",
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
            equipment: "3.00 kg",
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
  }, [isOverriddenTier, customerId, customerPrograms, profile, allCategories]);

  const card = dbCard;

  const { data: equipData } = useEquipments();
  const equipments = (equipData?.data ?? []) as any[];

  const { data: setupData } = useCustomerSetup(customerId as string);
  const trainerName = (setupData?.data as any)?.staff?.trainer_name;

  const [editing, setEditing] = useState(false);
  const [formErrors, setFormErrors] = useState<Record<string, boolean>>({});
  const [form, _setForm] = useState<CardForm | null>(null);
  const setForm = (val: React.SetStateAction<CardForm | null>) => {
    if (typeof val === "function") {
      _setForm((prev: any) => {
        const nextVal = (val as any)(prev);
        if (nextVal && nextVal.sequences) nextVal.sequences = ensureUids(nextVal.sequences);
        return nextVal;
      });
    } else {
      if (val && val.sequences) val.sequences = ensureUids(val.sequences);
      _setForm(val);
    }
  };
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
      allCategories.length > 0 &&
      // auto-start if there is a template, or preset, or at least active customer programs to map Modul Card to
      (templateCard || presetCard || customerPrograms.length > 0)
    ) {
      hasAutoStarted.current = true;
      startEdit(fcData?.data as any[], ccData?.data as any[], mcData?.data as any[], cdData?.data as any[]);
    }
  }, [cardLoading, isLoadingTemplate, isLoadingMenu, isLoadingAssessment, isLoadingPrograms, card, editing, canEdit, templateCard, presetCard, customerPrograms, allCategories, fcData, ccData, mcData, cdData]);

  // Build SearchableSelect options
  const typeOptions = useMemo(() =>
    types.filter((t: any) => t.is_active).map((t: any) => ({
      value: t.id, label: t.name, sublabel: t.description || "",
    })), [types]);

  const menuGroupMap = useMemo(() => {
    const map = new Map<string, string>();
    const processItems = (items: any[]) => {
      items.forEach(item => {
        if (item.movement_id) {
          map.set(item.movement_id, item.group_type || "Lainnya");
        }
      });
    };
    processItems((fcData?.data as any) || []);
    processItems((ccData?.data as any) || []);
    processItems((mcData?.data as any) || []);
    return map;
  }, [fcData, ccData, mcData]);

  const menuCategoryMap = useMemo(() => {
    const map = new Map<string, string[]>();
    const addCat = (items: any[], cat: string) => {
      items.forEach(item => {
        if (item.movement_id) {
          const cats = map.get(item.movement_id) || [];
          if (!cats.includes(cat)) cats.push(cat);
          map.set(item.movement_id, cats);
        }
      });
    };
    addCat((fcData?.data as any) || [], "FC");
    addCat((ccData?.data as any) || [], "CC");
    addCat((mcData?.data as any) || [], "MC");
    return map;
  }, [fcData, ccData, mcData]);

  const movementOptions = useMemo(() =>
    movements
      .filter((m: any) => {
        const currentLevel = form?.level ? parseInt(form.level) : parsedMappedLevel;
        if (!currentLevel) return true;

        // Strict filtering: Only allow movements present in Training Module for this level/gender
        if (!menuCategoryMap.has(m.id)) {
            return false;
        }
        return true;
      })
      .map((m: any) => {
        const nameMatch = m.name.match(/\((FC|CC|MC)\s*-\s*Level\s*(\d+)\)/i);
        const altMatch = m.name.match(/\[L(\d+)\]/i);
        const mappedCats = menuCategoryMap.get(m.id) || [];
        const mCategory = nameMatch ? nameMatch[1].toUpperCase() : (mappedCats.length > 0 ? mappedCats[0] : "");
        
        let mLevelStr = "";
        if (nameMatch) mLevelStr = nameMatch[2];
        else if (altMatch) mLevelStr = altMatch[1];

        const mappedGroup = menuGroupMap.get(m.id);
        const sectionName = mappedGroup 
          ? mappedGroup 
          : (mLevelStr ? (mCategory ? `${mCategory} - Level ${mLevelStr}` : `Level ${mLevelStr}`) : (m.pattern ? "Pola: " + m.pattern : "Lainnya"));

        return {
          value: m.id, 
          label: formatMovementName(m.name, effectiveGender), 
          sublabel: m.body_part, 
          pattern: m.pattern, 
          section: sectionName,
          extractedCategory: mCategory
        };
      }), [movements, form?.level, parsedMappedLevel, menuGroupMap, effectiveGender]);

  // Build a map for quick lookup of movement name by id
  const movementMap = useMemo(() => {
    const map: Record<string, any> = {};
    movements.forEach((m: any) => { map[m.id] = m; });
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

  const equipGeneralOptions = useMemo(() =>
    equipGeneral.filter((e: any) => e.is_active).map((e: any) => ({
      value: e.name, label: e.name,
    })), [equipGeneral]);

  // ── Form init ──────────────────────────────────────────────
  function startEdit(fcItemsParam?: any[], ccItemsParam?: any[], mcItemsParam?: any[], cdItemsParam?: any[]) {
    if (card) {
      setForm({
        level: card.level ? String(parseInt(card.level.match(/\d+/)?.[0] || "") || parsedMappedLevel) : String(parsedMappedLevel),
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
            equipment: set.equipment || set.equipment_upper || "",
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
        level: String(parsedMappedLevel),
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
            equipment: set.equipment || set.equipment_upper || "",
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
        })) : (() => {
          let baseCategories = customerPrograms.filter((p: any) => p.is_active);
          if (baseCategories.length === 0) {
            baseCategories = allCategories.filter((c: any) => ["functional", "cardiorespiratory", "metabolic", "cooldown", "cd"].includes(c.code?.toLowerCase()));
          }
          return baseCategories.map((p: any, i: number) => {
            const code = (p.program_category_code || p.code || "").toLowerCase();
            const categoryId = p.program_category_id || p.id;
            const categoryName = p.program_category_name || p.name;

            let menuItems: any[] = [];
            if (code === "functional") menuItems = fcItemsParam || (fcData as any)?.data || [];
            if (code === "cardiorespiratory") menuItems = ccItemsParam || (ccData as any)?.data || [];
            if (code === "metabolic") menuItems = mcItemsParam || (mcData as any)?.data || [];
            if (code === "cooldown" || code === "cd") menuItems = cdItemsParam || (cdData as any)?.data || [];
            return {
              program_category_id: categoryId,
              program_category_name: categoryName,
              program_category_code: code,
              duration: "",
              sort_order: i,
              sets: buildSetsFromMenuItems(menuItems, profile?.gender, code, age, recs),
            };
          });
        })(),
      });
    }
    setEditing(true);
  }

  function cancelEdit() { setForm(null); setEditing(false); }

  const validateForm = () => {
    let isValid = true;
    const errors: Record<string, boolean> = {};

    if (!form?.level) {
      errors['level'] = true;
      isValid = false;
    }

    form?.sequences.forEach((seq, si) => {
      if (!seq.program_category_id) {
        errors[`seq_${si}_category`] = true;
        isValid = false;
      }
    });

    setFormErrors(errors);
    if (!isValid) {
      toast.error("Level dan Kategori Program wajib diisi");
    }
    return isValid;
  };

  async function handleSave() {
    if (!form) return;
    if (!validateForm()) return;
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
          equipment: set.equipment_upper || null,
          equipment_lower: set.equipment_lower || null,

          type_id: set.type_id || null,
          bpm: set.bpm || null,
          extra_load: set.extra_load || null,
          pattern: set.pattern || null,
          breathing_core: set.breathing_core || null,
          breathing_diaphragm: set.breathing_diaphragm || null,
          notes: set.notes || null,
          sort_order: set.sort_order,
          items: set.items.map((item) => {
            let validBodyPart = item.body_part;
            if (!["upper", "lower", "core"].includes(validBodyPart?.toLowerCase())) {
              validBodyPart = "core";
            }
            return {
              movement_id: item.movement_id || null,
              movement_name: item.movement_name || null,
              body_part: validBodyPart.toLowerCase(),
              equipment: item.equipment || null,
              reps: item.reps || null,
              sets_count: item.sets_count || 1,
              breathing_core: item.breathing_core || null,
              breathing_diaphragm: item.breathing_diaphragm || null,
              sort_order: item.sort_order,
            };
          }),
        })),
      })),
    };
    try {
      await upsertCard.mutateAsync(payload);
      setEditing(false);
      setForm(null);
    } catch (err: any) {
      toast.error("Gagal save: " + JSON.stringify(err?.response?.data || err?.message || err));
      console.error("Save error:", err);
    }
  }

  async function handleDelete() {
    await deleteCard.mutateAsync(customerId);
    setDeleteOpen(false);
  }

  // ── Form mutation helpers ──────────────────────────────────
  async function handleChangeLevel(newLevel: string) {
    if (!form) return;
    setForm({ ...form, level: newLevel });
    setFormErrors(prev => ({ ...prev, level: false }));

    const confirmMsg = form.sequences.some((s) => s.sets.length > 0)
      ? "Terapkan template untuk level ini? Data gerakan saat ini akan terganti."
      : null;

    if (confirmMsg && !window.confirm(confirmMsg)) {
      return;
    }

      try {
        const levelNum = parseInt(newLevel) || 1;
        
        const [fcRes, ccRes, mcRes, cdRes] = await Promise.all([
           apiGet(`/api/digital-library/categories/fc/menu`, { level: levelNum }),
           apiGet(`/api/digital-library/categories/cc/menu`, { level: levelNum }),
           apiGet(`/api/digital-library/categories/mc/menu`, { level: levelNum }),
           apiGet(`/api/digital-library/categories/cd/menu`, { level: levelNum })
        ]);

        let baseCategories = customerPrograms.filter((p: any) => p.is_active);
        if (baseCategories.length === 0) {
          baseCategories = allCategories.filter((c: any) => ["functional", "cardiorespiratory", "metabolic", "cooldown", "cd"].includes(c.code?.toLowerCase()));
        }

        const newSequences = baseCategories.map((p: any, i: number) => {
            const code = (p.program_category_code || p.code || "").toLowerCase();
            const categoryId = p.program_category_id || p.id;
            const categoryName = p.program_category_name || p.name;

            let menuItems: any[] = [];
            if (code === "functional") menuItems = (fcRes as any)?.data || [];
            if (code === "cardiorespiratory") menuItems = (ccRes as any)?.data || [];
            if (code === "metabolic") menuItems = (mcRes as any)?.data || [];
            if (code === "cooldown" || code === "cd") menuItems = (cdRes as any)?.data || [];
            
            return {
              program_category_id: categoryId,
              program_category_name: categoryName,
              program_category_code: code,
              duration: "",
              sort_order: i,
              sets: buildSetsFromMenuItems(menuItems, profile?.gender, code, age, recs),
            };
          });

        setForm(prev => {
          if (!prev) return prev;
          return { ...prev, sequences: newSequences };
        });
        toast.success("Gerakan otomatis dimuat dari Modul Card.");
      } catch (err2) {
        console.error("Gagal memuat Modul Card", err2);
        toast.error("Gagal memuat gerakan otomatis.");
      }
  }

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
      equipment: equipUpper,
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

  
  function reorderItem(si: number, seti: number, oldIndex: number, newIndex: number) {
    if (!form) return;
    const newSequences = [...form.sequences];
    const newSets = [...newSequences[si].sets];
    const newItems = [...newSets[seti].items];
    
    const reordered = arrayMove(newItems, oldIndex, newIndex);
    
    newSets[seti] = { ...newSets[seti], items: reordered };
    newSequences[si] = { ...newSequences[si], sets: newSets };
    
    setForm({ ...form, sequences: newSequences });
  }

  function addItem(si: number, seti: number, bodyPart: string = "upper") {
    if (!form) return;
    const seqs = [...form.sequences];
    const sets = [...seqs[si].sets];
    const items = [...sets[seti].items];
    const newUid = typeof crypto !== "undefined" && crypto.randomUUID ? crypto.randomUUID() : Math.random().toString(36).substring(2, 9);
    items.push({
      _uid: newUid,
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
                      onChange={handleChangeLevel}
                      placeholder="Pilih level..."
                      className={formErrors['level'] ? "!border-red-500 bg-red-50" : ""}
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
                  {/* Gender is intentionally hidden based on user request */}
                  {effectiveGender && !profile?.gender && (
                    <div className="text-xs text-amber-600 bg-amber-50 px-2 rounded-md font-medium">
                      Gender dari Assessment: {effectiveGender}
                    </div>
                  )}
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
        {/* MEDICINES & IMPLICATIONS */}
        <div className="mt-6 mb-6">
          <MedicinesCard customerId={params.id} data={(setupData?.data as any)?.medicines ?? []} />
        </div>

        {/* HR ZONES REFERENCE */}
        <div className="mb-6">
          {(() => {
            const setup = setupData?.data as any;
            const maxHrCalc = age !== null ? 220 - (age as number) : null;
            const hrZones = [
              { label: "Max HR", key: "max_hr_upper", value: setup?.hr_zone?.max_hr_upper ?? (maxHrCalc || "-") },
              { label: "Zona 5", key: "zone5_lower", value: setup?.hr_zone?.zone5_lower ?? (maxHrCalc ? Math.round(0.9 * maxHrCalc) : "-") },
              { label: "Zona 4", key: "zone4_lower", value: setup?.hr_zone?.zone4_lower ?? (maxHrCalc ? Math.round(0.8 * maxHrCalc) : "-") },
              { label: "Zona 3", key: "zone3_lower", value: setup?.hr_zone?.zone3_lower ?? (maxHrCalc ? Math.round(0.7 * maxHrCalc) : "-") },
              { label: "Zona 2", key: "zone2_lower", value: setup?.hr_zone?.zone2_lower ?? (maxHrCalc ? Math.round(0.6 * maxHrCalc) : "-") },
              { label: "Zona 1", key: "zone1_lower", value: setup?.hr_zone?.zone1_lower ?? (maxHrCalc ? Math.round(0.5 * maxHrCalc) : "-") },
            ];
            return <HRZoneTable hrZones={hrZones} />;
          })()}
        </div>
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
            equipGeneralOptions={equipGeneralOptions}
            gender={effectiveGender}
            recs={recs}
            age={age}
            onUpdateSeq={(p) => updateSeq(si, p)}
            onAddSet={() => addSet(si)}
            onRemoveSet={(seti) => removeSet(si, seti)}
            onUpdateSet={(seti, p) => updateSet(si, seti, p)}
            onAddItem={(seti, bp) => addItem(si, seti, bp)}
            onRemoveItem={(seti, ii) => removeItem(si, seti, ii)}
            onUpdateItem={(seti, ii, p) => updateItem(si, seti, ii, p)}
            onReorderItem={(seti, oldI, newI) => reorderItem(si, seti, oldI, newI)}
            onPreviewVideo={(m, bpm) => setPreviewTarget({ movement: m, bpm })}
            formErrors={formErrors}
          />
        );
      })}

      {/* Additional Notes removed per request */}

      {/* ═══ CONDITIONING REFERENCE TABLE ═══════════════════════ */}

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

      {previewTarget && (
        <VideoPreviewModal 
          movement={previewTarget.movement} 
          bpm={previewTarget.bpm} 
          gender={effectiveGender}
          onClose={() => setPreviewTarget(null)} 
        />
      )}
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
//  Sequence Table — Excel-like table per FC / CC / MC
// ═══════════════════════════════════════════════════════════════

function SequenceTable({
  seq, si, level, isMetabolic, editing, typeOptions, movementOptions, movementMap, types,
  equipUpperOptions, equipLowerOptions, equipGeneralOptions, recs,
  onUpdateSeq, onAddSet, onRemoveSet, onUpdateSet, onAddItem, onRemoveItem, onUpdateItem, onReorderItem, onPreviewVideo,
  formErrors, gender, age,
}: {
  seq: CardSequence; si: number; level: string; isMetabolic: boolean; editing: boolean;
  typeOptions: { value: string; label: string; sublabel?: string }[];
  movementOptions: { value: string; label: string; sublabel?: string; pattern?: string | null }[];
  movementMap: Record<string, string>;
  types: any[];
  equipUpperOptions: { value: string; label: string }[];
  equipLowerOptions: { value: string; label: string }[];
  equipGeneralOptions: { value: string; label: string }[];
  gender?: string;
  recs: any;
  age: number | null;
  onUpdateSeq: (p: Partial<CardSequence>) => void;
  onAddSet: () => void;
  onRemoveSet: (seti: number) => void;
  onUpdateSet: (seti: number, p: Partial<CardSet>) => void;
  onAddItem: (seti: number, bodyPart: string) => void;
  onRemoveItem: (seti: number, ii: number) => void;
  onUpdateItem: (seti: number, ii: number, p: Partial<CardItem>) => void;
  onReorderItem?: (seti: number, oldIndex: number, newIndex: number) => void;
  onPreviewVideo?: (m: any, bpm: string) => void;
  formErrors: Record<string, boolean>;
}) {
  const [expanded, setExpanded] = useState(true);
  const code = seq.program_category_code || "";

  // Resolve options based on Cardio / Metabolic / Functional
  let upperOptions = [...equipUpperOptions, ...equipGeneralOptions];
  let lowerOptions = [...equipLowerOptions, ...equipGeneralOptions];
  let generalOptions = equipGeneralOptions;
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
    generalOptions = equipGeneralOptions;
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
    code === "metabolic" ? "bg-purple-600" :
    code === "cooldown" ? "bg-teal-500" : "bg-slate-600";

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
              si={si}
              seti={seti}
              level={level}
              isMetabolic={isMetabolic}
              categoryCode={seq.program_category_code}
              editing={editing}
              typeOptions={typeOptions}
              movementOptions={movementOptions}
              movementMap={movementMap}
              types={types}
              upperOptions={upperOptions}
              lowerOptions={lowerOptions}
              generalOptions={generalOptions}
              recommendedUpper={recommendedUpper}
              recommendedLower={recommendedLower}
              onUpdateSet={(p) => onUpdateSet(seti, p)}
              onRemoveSet={() => onRemoveSet(seti)}
              onAddItem={(bp) => onAddItem(seti, bp)}
              onRemoveItem={(ii) => onRemoveItem(seti, ii)}
              onUpdateItem={(ii, p) => onUpdateItem(seti, ii, p)}
              onReorderItem={(oldI, newI) => onReorderItem && onReorderItem(seti, oldI, newI)}
              onPreviewVideo={onPreviewVideo}
              formErrors={formErrors}
              gender={gender}
              age={age}
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
  set, si, seti, level, isMetabolic, categoryCode, editing, typeOptions, movementOptions, movementMap, types,
  upperOptions, lowerOptions, generalOptions, recommendedUpper, recommendedLower,
  onUpdateSet, onRemoveSet, onAddItem, onRemoveItem, onUpdateItem, onReorderItem, onPreviewVideo,
  formErrors, gender, age,
}: {
  set: CardSet; si: number; seti: number; level: string; isMetabolic: boolean; categoryCode?: string; editing: boolean;
  typeOptions: { value: string; label: string; sublabel?: string }[];
  movementOptions: { value: string; label: string; sublabel?: string; pattern?: string | null }[];
  movementMap: Record<string, any>;
  types: any[];
  upperOptions: { value: string; label: string }[];
  lowerOptions: { value: string; label: string }[];
  generalOptions: { value: string; label: string }[];
  recommendedUpper: string;
  recommendedLower: string;
  gender?: string;
  age: number | null;
  onUpdateSet: (p: Partial<CardSet>) => void;
  onRemoveSet: () => void;
  onAddItem: (bodyPart: string) => void;
  onRemoveItem: (ii: number) => void;
  onUpdateItem: (ii: number, p: Partial<CardItem>) => void;
  onReorderItem?: (oldIndex: number, newIndex: number) => void;
  onPreviewVideo?: (m: any, bpm: string) => void;
  formErrors: Record<string, boolean>;
}) {
  const selectedPatterns = set.pattern ? set.pattern.split(",").map(p => p.trim()).filter(Boolean) : [];
  const isLevel1 = level === "1" || level === "1-499" || level === "1-799";

  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 5,
      },
    })
  );

  function handleDragEnd(event: DragEndEvent) {
    const { active, over } = event;
    if (over && active.id !== over.id) {
      const oldIndex = set.items.findIndex((i: any) => i._uid === active.id);
      const newIndex = set.items.findIndex((i: any) => i._uid === over.id);
      if (oldIndex !== -1 && newIndex !== -1 && onReorderItem) {
        onReorderItem(oldIndex, newIndex);
      }
    }
  }


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
        <div className="grid grid-cols-1 md:grid-cols-12 gap-5">
          {/* Pattern */}
          <div className="md:col-span-6 lg:col-span-2">
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
                      "Isolate",
                      "Dynamic",
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
          <div className="md:col-span-6 lg:col-span-2">
            <label className="block text-[10px] font-bold text-slate-500 mb-1.5 uppercase tracking-wider">Breathing</label>
            {editing ? (
              <MultiSearchableSelect
                  options={[
                    { value: "Core", label: "Core" },
                    { value: "Diafragma", label: "Diafragma" }
                  ]}
                  value={set.breathing_core || ""}
                  onChange={(val) => onUpdateSet({ breathing_core: val })}
                  placeholder="Pilih..."
                />
              ) : (
                <div className="text-sm font-medium text-slate-800">
                  {set.breathing_core ? (
                    <ul className="list-disc ml-4 space-y-0.5">
                      {set.breathing_core.split(',').map((s: string, idx: number) => <li key={idx}>{s.trim()}</li>)}
                    </ul>
                  ) : "-"}
                </div>
            )}
          </div>

          {/* Duration & Load/BPM */}
          <div className="md:col-span-6 lg:col-span-3">
            <label className="block text-[10px] font-bold text-slate-500 mb-1.5 uppercase tracking-wider">{isMetabolic ? "Extra Load" : "BPM"}</label>
            {editing ? (
              <div className="flex flex-col gap-1">
                <input
                  value={isMetabolic ? (set.extra_load || "") : (set.bpm || "")}
                  onChange={(e) => isMetabolic ? onUpdateSet({ extra_load: e.target.value }) : onUpdateSet({ bpm: e.target.value })}
                  className="w-full text-sm border border-slate-200 rounded-md px-3 py-1.5 focus:outline-none focus:border-sf-deepNavy"
                  placeholder={isMetabolic ? "Load" : "Zona 1-2"}
                />
                {!isMetabolic && (
                  <div className="text-[10px] text-violet-600 bg-violet-50 px-2 py-1 rounded font-medium flex items-center gap-1.5">
                    <Info className="h-3 w-3" /> Acuan BPM: {calculateBPM(age, categoryCode || "") || "-"}
                  </div>
                )}
              </div>
            ) : (
              <div className="text-sm space-y-1 mt-1">
                <div><span className="font-medium text-slate-700">{isMetabolic ? (set.extra_load || "-") : (set.bpm || "-")}</span></div>
                {!isMetabolic && (
                  <div className="text-[10px] text-slate-400">
                    Acuan: {calculateBPM(age, categoryCode || "") || "-"}
                  </div>
                )}
              </div>
            )}
          </div>

          {/* Equipment Upper */}
          <div className="md:col-span-6 lg:col-span-3">
             <label className="block text-[10px] font-bold text-slate-500 mb-1.5 uppercase tracking-wider">Equipment Upper</label>
             {editing ? (
               <div className="flex flex-col gap-1">
                 <MultiSearchableSelect
                   options={upperOptions}
                   value={set.equipment_upper || ""}
                   onChange={(v) => onUpdateSet({ equipment_upper: v })}
                   placeholder="Upper..."
                   searchPlaceholder="Cari..."
                 />
                 <div className="text-[10px] text-violet-600 bg-violet-50 px-2 py-1 rounded font-medium flex items-center gap-1.5">
                   <Info className="h-3 w-3" /> Acuan Beban: {recommendedUpper || "-"}
                 </div>
               </div>
             ) : (
               <div className="text-sm space-y-1 mt-1">
                 {set.equipment_upper ? (
                   <ul className="list-disc ml-4 text-slate-600 font-semibold space-y-0.5">
                     {set.equipment_upper.split(",").map((eq, idx) => (
                       <li key={idx}>{eq.trim()}</li>
                     ))}
                   </ul>
                 ) : (
                   <div><span className="font-semibold text-slate-600">-</span></div>
                 )}
                 <div className="text-[10px] text-slate-400">
                   Acuan: {recommendedUpper || "-"}
                 </div>
               </div>
             )}
          </div>

          {/* Equipment Lower */}
          <div className="md:col-span-6 lg:col-span-2">
             <label className="block text-[10px] font-bold text-slate-500 mb-1.5 uppercase tracking-wider">Equipment Lower</label>
             {editing ? (
               <div className="flex flex-col gap-1">
                 <MultiSearchableSelect
                   options={lowerOptions}
                   value={set.equipment_lower || ""}
                   onChange={(v) => onUpdateSet({ equipment_lower: v })}
                   placeholder="Lower..."
                   searchPlaceholder="Cari..."
                 />
                 <div className="text-[10px] text-violet-600 bg-violet-50 px-2 py-1 rounded font-medium flex items-center gap-1.5">
                   <Info className="h-3 w-3" /> Acuan Beban: {recommendedLower || "-"}
                 </div>
               </div>
             ) : (
               <div className="text-sm space-y-1 mt-1">
                  {set.equipment_lower ? (
                    <ul className="list-disc ml-4 text-slate-600 font-semibold space-y-0.5">
                      {set.equipment_lower.split(",").map((eq, idx) => (
                        <li key={idx}>{eq.trim()}</li>
                      ))}
                    </ul>
                  ) : (
                    <div><span className="font-semibold text-slate-600">-</span></div>
                  )}
                  <div className="text-[10px] text-slate-400">
                    Acuan: {recommendedLower || "-"}
                  </div>
                </div>
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
          
          <DndContext sensors={sensors} collisionDetection={closestCenter} onDragEnd={handleDragEnd}>
            <SortableContext items={set.items.map((i: any) => i._uid)} strategy={verticalListSortingStrategy}>
              <div className="space-y-3 mb-4">
                {set.items.map((item, ii) => (
                  <SortableItemRow
                    key={item._uid}
                    id={item._uid}
                    item={item}
                    ii={ii}
                    editing={editing}
                    isLevel1={isLevel1}
                    selectedPatterns={selectedPatterns}
                    categoryCode={categoryCode}
                    hasErrorReps={formErrors[`item_${si}_${seti}_${ii}_reps`]}
                    hasErrorSets={formErrors[`item_${si}_${seti}_${ii}_sets_count`]}
                    hasErrorMovement={formErrors[`item_${si}_${seti}_${ii}_movement`]}
                    movementOptions={movementOptions}
                    movementMap={movementMap}
                    onUpdateItem={onUpdateItem}
                    onRemoveItem={onRemoveItem}
                    onPreviewVideo={(m: any) => onPreviewVideo && onPreviewVideo(m, set.bpm || "")}
                    gender={gender}
                  />
                ))}
              </div>
            </SortableContext>
          </DndContext>
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
            <button
              onClick={() => onAddItem("core")}
              className="px-4 py-2 text-xs rounded border border-amber-200 text-amber-700 bg-amber-50 hover:bg-amber-100 transition-colors flex items-center gap-1.5 font-medium shadow-sm"
            >
              <Plus className="h-3.5 w-3.5" /> Tambah Core
            </button>
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
  options, movementMap, item, bodyPart, selectedPatterns, categoryCode, onUpdate, hasError, gender
}: {
  options: { value: string; label: string; sublabel?: string; pattern?: string | null; section?: string; extractedCategory?: string }[];
  movementMap: Record<string, any>;
  item: CardItem;
  bodyPart: string;
  selectedPatterns: string[];
  categoryCode?: string;
  onUpdate: (p: Partial<CardItem>) => void;
  hasError?: boolean;
  gender?: string;
}) {
  let filtered = [...options];

  // Filter by selected Patterns
  if (selectedPatterns && selectedPatterns.length > 0) {
    const patFiltered = filtered.filter(m => {
      const mPat = (m.pattern || "").trim().toLowerCase();
      const mCat = (m.extractedCategory || "").trim().toLowerCase();
      let currentCat = (categoryCode || "").trim().toLowerCase();
      if (currentCat === "functional") currentCat = "fc";
      if (currentCat === "cardiorespiratory") currentCat = "cc";
      if (currentCat === "metabolic") currentCat = "mc";
      if (currentCat === "cooldown") currentCat = "cd";
      
      return selectedPatterns.some(sp => {
        const spLower = sp.toLowerCase();
        
        // If the pattern is just "Isolate" or "Dynamic", enforce the current sequence category (FC, CC, etc) but allow if no category is assigned
        if (spLower === "isolate") return mPat === "isolate" && (!currentCat || !mCat || mCat === currentCat);
        if (spLower === "dynamic") return mPat === "dynamic" && (!currentCat || !mCat || mCat === currentCat);
        
        if (spLower === "metabolic basic") return mPat.includes("basic") || mCat === "mc";
        if (spLower === "metabolic core") return mPat.includes("core") || mCat === "mc";
        
        return true;
      });
    });
    
    // Fallback: Jika filter pattern membuat opsi jadi kosong, tampilkan semua agar user tidak stuck
    if (patFiltered.length > 0) {
      filtered = patFiltered;
    }
  }

  // Pastikan item.movement_id yang terpilih ada di allOpts meskipun terfilter!
  if (item.movement_id && !filtered.some(o => o.value === item.movement_id)) {
    const selectedInOptions = options.find(o => o.value === item.movement_id);
    if (selectedInOptions) {
      filtered.push(selectedInOptions);
    } else if (item.movement_name) {
      filtered.push({ value: item.movement_id, label: formatMovementName(item.movement_name, gender), sublabel: item.body_part });
    }
  }

  const customLabel = item.movement_name ? formatMovementName(item.movement_name, gender) : "";
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
            const selectedOpt = allOpts.find(o => o.value === v);
            const bp = selectedOpt?.sublabel || bodyPart || "upper";
            onUpdate({ movement_id: v, movement_name: movementMap[v]?.name || "", body_part: bp });
          }
        }}
        placeholder="Pilih gerakan..."
        searchPlaceholder="Cari gerakan..."
        className={hasError ? "!border-red-500 bg-red-50" : ""}
      />
      {!item.movement_id && (
        <input
          value={item.movement_name || ""}
          onChange={(e) => onUpdate({ movement_name: e.target.value })}
          className={`mt-1.5 w-full border rounded px-2 py-1 text-xs focus:outline-none focus:ring-1 focus:ring-sf-deepNavy bg-white ${hasError ? "border-red-500 bg-red-50" : "border-slate-200"}`}
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



function extractYouTubeId(url: string) {
  if (!url) return null;
  const regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/;
  const match = url.match(regExp);
  return (match && match[2].length === 11) ? match[2] : null;
}

function VideoPreviewModal({ movement, bpm, gender, onClose }: { movement: any; bpm?: string; gender?: string; onClose: () => void }) {
  const rawMaleId = extractYouTubeId(movement.video_url_male || "");
  const rawFemaleId = extractYouTubeId(movement.video_url_female || "");
  const normalizedGender = (gender || "").toLowerCase();
  
  const isFemale = normalizedGender === "female" || normalizedGender === "wanita" || normalizedGender === "women";
  const isMale = normalizedGender === "male" || normalizedGender === "pria" || normalizedGender === "men";

  let maleId = isFemale ? null : rawMaleId;
  let femaleId = isMale ? null : rawFemaleId;

  // Fallbacks just in case the specific gender video is missing but the other exists
  // For pipe-split exercises (Female Exercise | Male Exercise), never cross-fallback to the other gender!
  const isPipeSplit = (movement.name || "").includes("|");
  if (!isPipeSplit) {
    if (isMale && !maleId && rawFemaleId) maleId = rawFemaleId;
    if (isFemale && !femaleId && rawMaleId) femaleId = rawMaleId;
  }

  const hasBoth = maleId && femaleId;
  const audioRef = useRef<HTMLAudioElement | null>(null);

  useEffect(() => {
    let theBpm = bpm;
    if (theBpm && theBpm.includes("-")) {
      theBpm = theBpm.split("-")[0];
    }
    if (theBpm && theBpm !== "No BPM" && theBpm !== "0") {
      const baseUrl = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8080";
      const url = `${baseUrl}/uploads/bpm/${theBpm}.mp3`;
      const audio = new Audio(url);
      audio.loop = true;
      audio.play().catch(e => console.error("Error playing BPM", e));
      audioRef.current = audio;
    }
    return () => {
      if (audioRef.current) {
        audioRef.current.pause();
      }
    };
  }, [bpm]);

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center" onClick={onClose}>
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" />
      <div
        className={cn(
          "relative bg-white rounded-2xl shadow-2xl mx-4 animate-slide-in overflow-hidden",
          hasBoth ? "max-w-5xl w-full" : "max-w-2xl w-full"
        )}
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
          <div className="flex items-center gap-3">
            <div className="h-9 w-9 rounded-lg bg-violet-100 flex items-center justify-center">
              <Video className="h-4.5 w-4.5 text-violet-600" />
            </div>
            <div>
              <h2 className="text-lg font-semibold text-slate-900">{formatMovementName(movement.name, gender)}</h2>
              {bpm && <div className="text-xs text-sf-warmGold font-bold mt-1">BPM: {bpm}</div>}
            </div>
          </div>
          <button onClick={onClose} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400 hover:text-slate-600">
            <X className="h-5 w-5" />
          </button>
        </div>

        <div className={cn("p-6", hasBoth ? "grid grid-cols-2 gap-5" : "")}>
          {maleId && (
            <div>
              <p className="text-sm font-semibold text-slate-700 mb-2">Male Version</p>
              <div className="relative w-full rounded-xl overflow-hidden bg-slate-900 shadow-lg" style={{ paddingBottom: "56.25%" }}>
                <iframe
                  className="absolute inset-0 w-full h-full"
                  src={`https://www.youtube.com/embed/${maleId}?autoplay=1&mute=0`}
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowFullScreen
                />
              </div>
            </div>
          )}
          {femaleId && (
            <div>
              <p className="text-sm font-semibold text-slate-700 mb-2">Female Version</p>
              <div className="relative w-full rounded-xl overflow-hidden bg-slate-900 shadow-lg" style={{ paddingBottom: "56.25%" }}>
                <iframe
                  className="absolute inset-0 w-full h-full"
                  src={`https://www.youtube.com/embed/${femaleId}?autoplay=1&mute=0`}
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowFullScreen
                />
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}








function SortableItemRow({ 
  item, ii, editing, isLevel1, selectedPatterns, categoryCode, hasErrorReps, hasErrorSets, hasErrorMovement,
  movementOptions, movementMap, onUpdateItem, onRemoveItem, onPreviewVideo, gender, id
}: any) {
  const { attributes, listeners, setNodeRef, transform, transition, isDragging } = useSortable({ id });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    zIndex: isDragging ? 50 : "auto",
    opacity: isDragging ? 0.9 : 1,
    position: isDragging ? "relative" : "static",
  } as any;

  return (
    <div ref={setNodeRef} style={style} className={`flex flex-col md:flex-row gap-4 bg-white p-3 border ${isDragging ? "border-violet-400 shadow-md" : "border-slate-200"} rounded-md shadow-sm relative md:items-center items-start`}>
        {editing && (
          <div {...attributes} {...listeners} className="cursor-grab active:cursor-grabbing text-slate-400 hover:text-slate-600 p-1 md:block hidden shrink-0" title="Geser untuk mengatur urutan">
            <GripVertical className="h-5 w-5" />
          </div>
        )}
      {/* Bagian Nama & Body Part */}
      <div className="flex-1">
        <div className="flex items-center justify-end mb-1.5">
          {editing && (
            <div className="flex gap-2 items-center md:hidden">
              <div {...attributes} {...listeners} className="text-slate-400 hover:text-slate-600 transition-colors p-1 cursor-grab">
                <GripVertical className="h-4 w-4" />
              </div>
              <button onClick={() => {
                const m = item.movement_id ? movementMap[item.movement_id] : null;
                if (m && onPreviewVideo) onPreviewVideo(m, item.bpm || "");
              }} className="text-violet-500 hover:text-violet-700 transition-colors" title="Preview Video">
                <Video className="h-4 w-4" />
              </button>
              <button onClick={() => onRemoveItem(ii)} className="text-red-400 hover:text-red-600 transition-colors">
                <Trash2 className="h-4 w-4" />
              </button>
            </div>
          )}
        </div>
        
        {editing ? (
          <MovementSelect
            options={movementOptions}
            movementMap={movementMap}
            item={item}
            bodyPart={item.body_part || ""}
            selectedPatterns={selectedPatterns}
            categoryCode={categoryCode}
            onUpdate={(p) => onUpdateItem(ii, p)}
            hasError={hasErrorMovement}
            gender={gender}
          />
        ) : (
          <div className="flex items-center gap-2 mt-1">
            <div className="font-semibold text-slate-800 text-sm">{formatMovementName(item.movement_name || "-", gender)}</div>
            <button onClick={() => {
              const m = item.movement_id ? movementMap[item.movement_id] : null;
              if (m && onPreviewVideo) onPreviewVideo(m, item.bpm || "");
            }} className="p-1 rounded bg-slate-100 text-violet-600 hover:bg-violet-100" title="Preview Video">
              <Video className="h-4 w-4" />
            </button>
          </div>
        )}
      </div>

      {/* Bagian Reps & Breathing Khusus */}
      <div className="flex items-end gap-3 md:w-auto w-full border-t border-slate-100 md:border-none pt-3 md:pt-0 pl-0 md:pl-2">
        {/* Reps */}
        <div className="w-20 shrink-0">
          <label className="block text-[10px] text-slate-400 mb-1">Reps</label>
          {editing ? (
            <input 
              type="number" 
              value={item.reps ?? ""} 
              onChange={(e) => onUpdateItem(ii, { reps: e.target.value ? +e.target.value : null })} 
              className={`w-full text-sm border rounded px-2 py-1.5 focus:outline-none focus:ring-1 focus:ring-sf-deepNavy text-center ${hasErrorReps ? "border-red-500 bg-red-50 placeholder-red-300" : "border-slate-200"}`} 
            />
          ) : (
            <div className="font-medium text-sm text-center">{item.reps ?? "-"}</div>
          )}
        </div>
        
        {/* Sets Count */}
        <div className="w-16 shrink-0">
          <label className="block text-[10px] text-slate-400 mb-1">Set</label>
          {editing ? (
            <input 
              type="number" 
              value={item.sets_count ?? ""} 
              onChange={(e) => onUpdateItem(ii, { sets_count: e.target.value ? +e.target.value : null })} 
              className={`w-full text-sm border rounded px-2 py-1.5 focus:outline-none focus:ring-1 focus:ring-sf-deepNavy text-center ${hasErrorSets ? "border-red-500 bg-red-50 placeholder-red-300" : "border-slate-200"}`} 
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
              <MultiSearchableSelect
                  options={[
                    { value: "Core", label: "Core" },
                    { value: "Diafragma", label: "Diafragma" }
                  ]}
                  value={item.breathing_core || ""}
                  onChange={(val) => onUpdateItem(ii, { breathing_core: val })}
                  placeholder="Pilih..."
                />
              ) : (
                <div className="font-medium text-sm text-center">
                  {item.breathing_core ? (
                    <ul className="list-disc ml-4 space-y-0.5 text-slate-600 text-left">
                      {item.breathing_core.split(',').map((s: string, idx: number) => <li key={idx}>{s.trim()}</li>)}
                    </ul>
                  ) : "-"}
                </div>
            )}
          </div>
        )}

        {/* Desktop Actions */}
        {editing && (
          <div className="hidden md:flex flex-row gap-2 items-center justify-center p-2">
            <button onClick={() => {
              const m = item.movement_id ? movementMap[item.movement_id] : null;
              if (m && onPreviewVideo) onPreviewVideo(m, item.bpm || "");
            }} className="text-violet-500 hover:text-violet-700 transition-colors p-2 bg-slate-50 rounded" title="Preview Video">
              <Video className="h-4 w-4" />
            </button>
            <button onClick={() => onRemoveItem(ii)} className="text-red-400 hover:text-red-600 transition-colors" title="Hapus gerakan">
              <Trash2 className="h-4 w-4" />
            </button>
          </div>
        )}
      </div>

    </div>
  );
}
