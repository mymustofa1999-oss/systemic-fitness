"use client";

import { useQuery } from "@tanstack/react-query";
import { apiGet } from "@/lib/api";
import { Dumbbell, Info, Loader2, Lock, Music, Pause, Play, X, Clock } from "lucide-react";
import { useState, useEffect, useMemo, useRef } from "react";
import { useMySubscription } from "@/hooks/useSubscription";
import { useLogWorkoutSession } from "@/hooks/useWorkout";
import Link from "next/link";
import { toast } from "@/stores/toastStore";
import { useRouter } from "next/navigation";

// ════════════════════════════════════════════════════════════════════
//  Types — API Response
// ════════════════════════════════════════════════════════════════════

interface TrainingMovement {
  id: string;
  sequence: number;
  title: string;
  video_url: string;
  movement_tag: string; // "Diafragma 1:1" | "Core" | ""
  allowed_tiers?: string[]; // package tiers allowed to access; empty/undefined = all
}

interface TrainingSet {
  set_name: string;
  duration_mins: number;
  bpm_range: string;
  tags: string[];
  movements: TrainingMovement[];
}

interface ProgramCategory {
  type: string; // "FUNCTIONAL" | "CARDIO" | "METABOLIC"
  duration: string;
  sets: TrainingSet[];
}

interface CardItem {
  movement_id?: string | null;
  movement_name?: string | null;
  body_part: string;
  equipment?: string | null;
  reps?: number | null;
  sets_count?: number | null;
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

interface TrainerCard {
  id: string;
  customer_id: string;
  customer_name?: string;
  level: string;
  notes?: string | null;
	sequences: CardSequence[];
	full_program?: ProgramCategory[];
	daily_reset?: ProgramCategory[];
	is_preview?: boolean;
}

// ════════════════════════════════════════════════════════════════════
//  Constants — Pillar Colors & Labels
// ════════════════════════════════════════════════════════════════════

const PILLAR_COLORS: Record<string, string> = {
  FUNCTIONAL: "#5fd68a",
  CARDIO: "#fb923c",
  METABOLIC: "#f87171",
  FC: "#5fd68a",
  CC: "#fb923c",
  MC: "#f87171",
};

const PILLAR_NAMES: Record<string, string> = {
  FUNCTIONAL: "Functional",
  CARDIO: "Cardio",
  METABOLIC: "Metabolic",
  FC: "Functional",
  CC: "Cardio",
  MC: "Metabolic",
};

// ── Package access ───────────────────────────────────────────────────
// A movement is gated per subscription package. Empty/undefined allowed_tiers
// means it is open to every package (default).
const TIER_LABELS: Record<string, string> = {
  sf_tier_2: "499K",
  sf_tier_3: "799K",
};

function isMovementLocked(allowedTiers: string[] | undefined, userTier: string): boolean {
  if (!allowedTiers || allowedTiers.length === 0) return false;
  return !allowedTiers.includes(userTier);
}

function tierLabels(allowedTiers: string[] | undefined): string {
  return (allowedTiers || []).map((t) => TIER_LABELS[t] || t).join(" / ");
}

// ── Breath Tag Config ──────────────────────────────────────────────
const BREATH_CONFIG: Record<string, { label: string; icon: string; color: string }> = {
  "Diafragma 1:1": { label: "Diafragma 1:1", icon: "🌬", color: "#93c5fd" },
  "Core":          { label: "Core",           icon: "⚡", color: "#86efac" },
};

const CLASSIFICATION_LABELS: Record<string, string> = {
  "imun-inflamasi": "Imun & Inflamasi",
  "renal-uric": "Renal & Uric",
  "cardiorespiratory": "Cardiorespiratory",
  "metabolic-syndrome": "Metabolic Syndrome",
  "preventive": "Preventive",
};

const CONDITION_LABELS: Record<string, string> = {
  "autoimun": "Autoimun",
  "alergi-kronis": "Alergi Kronis",
  "inflamasi-sistemik": "Inflamasi Sistemik",
  "kista": "Kista",
  "tumor-jinak": "Tumor Jinak",
  "fibromyalgia": "Fibromyalgia",
  "diabetes-type-2": "Diabetes Tipe 2",
  "hipertensi": "Hipertensi",
  "obesitas": "Obesitas",
  "jantung-koroner": "Jantung Koroner",
  "asma": "Asma",
  "gerd": "GERD",
  "gout": "Asam Urat",
  "ginjal-kronis": "Ginjal Kronis",
};

function formatSlug(slug: string) {
  return slug
    .split("-")
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(" ");
}

interface ProfileHeaderProps {
  user: any;
  profile: any;
  card: any;
  assessment: any;
  session: "full" | "daily";
  lang: string;
}

function ProfileHeader({
  user,
  profile,
  card,
  assessment,
  session,
  lang,
}: ProfileHeaderProps) {
  const getAge = (dobString?: string) => {
    if (!dobString) return null;
    try {
      const today = new Date();
      const birthDate = new Date(dobString);
      if (isNaN(birthDate.getTime())) return null;
      let age = today.getFullYear() - birthDate.getFullYear();
      const m = today.getMonth() - birthDate.getMonth();
      if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
        age--;
      }
      return age;
    } catch {
      return null;
    }
  };

  const age = getAge(profile?.date_of_birth);
  
  const getGenderLabel = (gender?: string) => {
    if (!gender) return "";
    if (gender.toLowerCase() === "male" || gender.toLowerCase() === "men") {
      return lang === "en" ? "Male" : "Pria";
    }
    if (gender.toLowerCase() === "female" || gender.toLowerCase() === "women") {
      return lang === "en" ? "Female" : "Wanita";
    }
    return gender;
  };

  const genderLabel = getGenderLabel(profile?.gender);

  const metaParts: string[] = [];
  if (age) metaParts.push(`${age}yr`);
  if (genderLabel) metaParts.push(genderLabel);
  if (profile?.height_cm) metaParts.push(`${profile.height_cm}cm`);
  const metadataText = metaParts.join(" · ");

  const classificationSlug = assessment?.phase_a?.classification_slug;
  const specificConditionSlug = assessment?.phase_a?.specific_condition_slug;

  const classificationLabel = classificationSlug
    ? (CLASSIFICATION_LABELS[classificationSlug] || formatSlug(classificationSlug))
    : null;

  const conditionLabel = specificConditionSlug
    ? (CONDITION_LABELS[specificConditionSlug] || formatSlug(specificConditionSlug))
    : null;

  const dayLabels = lang === "en"
    ? ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    : ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"];

  const weekDays = [
    { label: dayLabels[0], type: "60", val: "60'" },
    { label: dayLabels[1], type: "rest", val: "" },
    { label: dayLabels[2], type: "30", val: "30'" },
    { label: dayLabels[3], type: "rest", val: "" },
    { label: dayLabels[4], type: "60", val: "60'" },
    { label: dayLabels[5], type: "30", val: "30'" },
    { label: dayLabels[6], type: "rest", val: "" }
  ];

  return (
    <div
      style={{
        background: "var(--tc-card)",
        border: "1px solid var(--tc-border)",
        borderRadius: 18,
        padding: "16px 18px",
        marginBottom: 12,
        display: "flex",
        flexDirection: "row",
        justifyContent: "space-between",
        alignItems: "center",
        gap: 16,
        flexWrap: "wrap",
      }}
    >
      <div style={{ flex: "1 1 200px" }}>
        <h2
          style={{
            fontSize: 22,
            fontWeight: 700,
            color: "var(--tc-text)",
            lineHeight: 1.2,
            marginBottom: 6,
          }}
        >
          {user?.full_name || "Client Name"}
        </h2>
        
        {metadataText && (
          <p
            style={{
              fontSize: 13,
              color: "var(--tc-text-secondary)",
              marginBottom: 12,
            }}
          >
            {metadataText}
          </p>
        )}

        <div style={{ display: "flex", flexWrap: "wrap", gap: 6 }}>
          {card?.level && (
            <span
              style={{
                border: "1px solid var(--tc-gold-border)",
                background: "var(--tc-gold-bg)",
                color: "var(--tc-gold)",
                borderRadius: 9999,
                padding: "3px 10px",
                fontSize: 11,
                fontWeight: 700,
              }}
            >
              Level {card.level}
            </span>
          )}
          {classificationLabel && (
            <span
              style={{
                border: "1px solid #10b98133",
                background: "#10b9810d",
                color: "#10b981",
                borderRadius: 9999,
                padding: "3px 10px",
                fontSize: 11,
                fontWeight: 600,
              }}
            >
              {classificationLabel}
            </span>
          )}
          {conditionLabel && (
            <span
              style={{
                border: "1px solid #10b98133",
                background: "#10b9810d",
                color: "#10b981",
                borderRadius: 9999,
                padding: "3px 10px",
                fontSize: 11,
                fontWeight: 600,
              }}
            >
              {conditionLabel}
            </span>
          )}
        </div>


      </div>

      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "flex-start",
          minWidth: "240px",
        }}
      >
        <span
          style={{
            fontSize: 9,
            fontWeight: 800,
            color: "var(--tc-text-muted)",
            letterSpacing: 1.2,
            marginBottom: 10,
            textTransform: "uppercase",
          }}
        >
          {lang === "en" ? "WEEKLY SCHEDULE" : "JADWAL MINGGUAN"}
        </span>

        <div
          style={{
            display: "flex",
            gap: 6,
            alignItems: "center",
          }}
        >
          {weekDays.map((day, idx) => {
            const is60 = day.type === "60";
            const is30 = day.type === "30";
            const isRest = day.type === "rest";

            const isActive60 = is60 && session === "full";
            const isActive30 = is30 && session === "daily";
            const isActive = isActive60 || isActive30;

            let borderStyle = "1px solid var(--tc-border)";
            let bgStyle = "transparent";
            let colorStyle = "var(--tc-text-muted)";
            let shadowStyle = "none";

            if (isRest) {
              borderStyle = "1px solid var(--tc-border)";
              bgStyle = "transparent";
            } else if (is60) {
              borderStyle = `1px solid ${isActive ? "var(--tc-gold)" : "var(--tc-gold-border)"}`;
              bgStyle = isActive ? "var(--tc-gold-bg)" : "transparent";
              colorStyle = isActive ? "var(--tc-gold)" : "var(--tc-gold-dim)";
              shadowStyle = isActive ? "0 0 0 2px var(--tc-bg), 0 0 0 4px var(--tc-gold)" : "none";
            } else if (is30) {
              borderStyle = `1px solid ${isActive ? "#10b981" : "#10b98133"}`;
              bgStyle = isActive ? "#10b98115" : "#10b98105";
              colorStyle = "#10b981";
              shadowStyle = isActive ? "0 0 0 2px var(--tc-bg), 0 0 0 4px var(--tc-gold)" : "none";
            }

            return (
              <div
                key={idx}
                style={{
                  display: "flex",
                  flexDirection: "column",
                  alignItems: "center",
                }}
              >
                <div
                  style={{
                    width: 32,
                    height: 32,
                    borderRadius: "50%",
                    border: borderStyle,
                    background: bgStyle,
                    color: colorStyle,
                    boxShadow: shadowStyle,
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    fontSize: 10,
                    fontWeight: 700,
                    transition: "all 0.2s ease",
                    marginBottom: 6,
                  }}
                >
                  {day.val}
                </div>
                <span
                  style={{
                    fontSize: 10,
                    color: "var(--tc-text-muted)",
                    fontWeight: 500,
                  }}
                >
                  {day.label}
                </span>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}

// ════════════════════════════════════════════════════════════════════
//  Sub-Components
// ════════════════════════════════════════════════════════════════════

// ── Chip ───────────────────────────────────────────────────────────
function Chip({
  children,
  color,
  bg,
  border,
}: {
  children: React.ReactNode;
  color?: string;
  bg?: string;
  border?: string;
}) {
  return (
    <span
      style={{
        background: bg || "var(--tc-chip-bg)",
        border: `1px solid ${border || "var(--tc-chip-border)"}`,
        borderRadius: 5,
        padding: "2px 8px",
        fontSize: 10,
        color: color || "var(--tc-chip-text)",
        display: "inline-flex",
        alignItems: "center",
        gap: 3,
      }}
    >
      {children}
    </span>
  );
}

// ── Breath Badge ───────────────────────────────────────────────────
function BreathBadge({ type }: { type: string }) {
  const b = BREATH_CONFIG[type] || BREATH_CONFIG["Core"];
  const bgVar = type === "Diafragma 1:1" ? "var(--tc-breath-d-bg)" : "var(--tc-breath-c-bg)";
  return (
    <span
      style={{
        background: bgVar,
        color: b.color,
        border: `1px solid ${b.color}30`,
        borderRadius: 5,
        padding: "2px 8px",
        fontSize: 10,
        fontWeight: 700,
        display: "inline-flex",
        alignItems: "center",
        gap: 3,
        flexShrink: 0,
      }}
    >
      {b.icon} {b.label}
    </span>
  );
}

// ── Exercise Card (for dynamic full_program / daily_reset) ─────────
interface ExerciseCardProps {
  category: ProgramCategory;
  set: TrainingSet;
  pillarColor: string;
  pillarName: string;
  userTier: string;
  onMovementClick: (mv: TrainingMovement, isLocked: boolean) => void;
  tier3PlanName?: string;
}

function getDefaultBpm(bpmRange?: string | null): string {
  if (!bpmRange || bpmRange === '—' || bpmRange === '') {
    return 'No BPM';
  }
  const match = bpmRange.match(/(\d+)/);
  if (match) {
    const bpmVal = parseInt(match[1], 10);
    if (!isNaN(bpmVal)) {
      let clamped = bpmVal;
      if (clamped < 60) clamped = 60;
      if (clamped > 200) clamped = 200;
      // Round to nearest 10
      clamped = Math.round(clamped / 10) * 10;
      return clamped.toString();
    }
  }
  return 'No BPM';
}

function ExerciseCard({
  category,
  set,
  pillarColor,
  pillarName,
  userTier,
  onMovementClick,
  tier3PlanName,
}: ExerciseCardProps) {
  const [expandedMovementId, setExpandedMovementId] = useState<string | null>(null);
  const pc = pillarColor;
  const hasBPM = set.bpm_range && set.bpm_range !== "—" && set.bpm_range !== "";

  // BPM Player State
  const [selectedBpm, setSelectedBpm] = useState<string>("No BPM");
  const [isBpmPlaying, setIsBpmPlaying] = useState<boolean>(false);
  const [playingMovementId, setPlayingMovementId] = useState<string | null>(null);
  const audioRef = useRef<HTMLAudioElement | null>(null);

  // Initialize selectedBpm when set changes
  useEffect(() => {
    if (audioRef.current) {
      audioRef.current.pause();
      audioRef.current = null;
    }
    setIsBpmPlaying(false);
    setPlayingMovementId(null);
    setSelectedBpm("No BPM");
  }, [set]);

  // Clean up audio on unmount or when expanded movement changes
  useEffect(() => {
    if (audioRef.current) {
      audioRef.current.pause();
      audioRef.current = null;
    }
    setIsBpmPlaying(false);
    setPlayingMovementId(null);
  }, [expandedMovementId]);

  useEffect(() => {
    return () => {
      if (audioRef.current) {
        audioRef.current.pause();
        audioRef.current = null;
      }
    };
  }, []);

  const playBpmAudio = (bpm: string) => {
    if (!bpm || bpm === 'No BPM') {
      if (audioRef.current) {
        audioRef.current.pause();
        audioRef.current = null;
      }
      setIsBpmPlaying(false);
      return;
    }

    if (audioRef.current) {
      audioRef.current.pause();
    }

    const baseUrl = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8080";
    const url = `${baseUrl}/uploads/bpm/${bpm}.mp3`;
    const audio = new Audio(url);
    audio.loop = true;
    audioRef.current = audio;
    audio.play()
      .then(() => {
        setIsBpmPlaying(true);
      })
      .catch((err) => {
        console.error("Error playing BPM audio:", err);
        setIsBpmPlaying(false);
      });
  };

  const stopBpmAudio = () => {
    if (audioRef.current) {
      audioRef.current.pause();
      audioRef.current = null;
    }
    setIsBpmPlaying(false);
  };

  // Determine breath type from movement tags
  const breathTypes = Array.from(new Set(set.movements.map((m) => m.movement_tag).filter(Boolean)));
  const hasMixedBreath = breathTypes.length > 1;

  return (
    <div
      style={{
        background: "var(--tc-card)",
        border: `1px solid ${pc}22`,
        borderRadius: 14,
        overflow: "hidden",
      }}
    >
      {/* ── Header ────────────────────────────────────────── */}
      <div
        style={{
          background: `linear-gradient(135deg,${pc}10,transparent)`,
          borderBottom: `1px solid ${pc}15`,
          padding: "11px 14px",
          display: "flex",
          justifyContent: "space-between",
          alignItems: "flex-start",
          gap: 8,
        }}
      >
        <div style={{ flex: 1 }}>
          <div
            className="font-bebas"
            style={{
              fontSize: 16,
              color: pc,
              letterSpacing: 2,
              lineHeight: 1,
              marginBottom: 7,
            }}
          >
            {pillarName} · {set.set_name}
          </div>
          <div style={{ display: "flex", flexWrap: "wrap", gap: 5 }}>
            <Chip>⏱ {set.duration_mins} menit</Chip>
            {set.tags?.map((tag, i) => {
              const cleanedTag = formatWeight(tag);
              if (cleanedTag.toLowerCase().includes("wrist")) {
                return (
                  <Chip key={i} color="#93c5fd" bg="var(--tc-breath-d-bg)" border="#93c5fd30">
                    💪 {cleanedTag}
                  </Chip>
                );
              }
              if (cleanedTag.toLowerCase().includes("ankle")) {
                return (
                  <Chip key={i} color="#86efac" bg="var(--tc-breath-c-bg)" border="#86efac30">
                    🦵 {cleanedTag}
                  </Chip>
                );
              }
              return <Chip key={i}>{cleanedTag}</Chip>;
            })}
            {!hasMixedBreath && breathTypes.length === 1 && (
              <BreathBadge type={breathTypes[0]} />
            )}
          </div>
        </div>
        {hasBPM && (
          <div style={{ textAlign: "right", flexShrink: 0 }}>
            <div style={{ fontSize: 8, color: "var(--tc-text-dim)", letterSpacing: 0.8 }}>BPM</div>
            <div
              className="font-bebas"
              style={{ fontSize: 12, color: pc, lineHeight: 1 }}
            >
              {set.bpm_range}
            </div>
          </div>
        )}
      </div>

      {/* ── Exercises ─────────────────────────────────────── */}
      {set.movements.map((mv, i) => {
        const isLocked = isMovementLocked(mv.allowed_tiers, userTier);
        const isExpanded = expandedMovementId === (mv.id || mv.title || i.toString());
        return (
          <div key={mv.id || i} style={{ display: "flex", flexDirection: "column" }}>
            <div
              onClick={() => {
                if (isLocked) {
                  onMovementClick(mv, isLocked);
                } else if (mv.video_url) {
                  setExpandedMovementId(isExpanded ? null : (mv.id || mv.title || i.toString()));
                }
              }}
              style={{
                display: "flex",
                alignItems: "center",
                gap: 10,
                padding: "9px 14px",
                borderBottom:
                  !isExpanded && i < set.movements.length - 1 ? "1px solid var(--tc-divider)" : "none",
                cursor: "pointer",
                transition: "background-color 0.2s ease",
              }}
              className={!isLocked ? "hover:bg-slate-50 dark:hover:bg-slate-800/40" : "opacity-60"}
            >
              <div
                style={{
                  width: 22,
                  height: 22,
                  borderRadius: 5,
                  flexShrink: 0,
                  background: isLocked ? "var(--tc-toggle-bg)" : `${pc}12`,
                  border: `1px solid ${isLocked ? "var(--tc-border)" : `${pc}20`}`,
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  fontSize: 10,
                  fontWeight: 700,
                  color: isLocked ? "var(--tc-text-muted)" : pc,
                }}
              >
                {isLocked ? <Lock size={10} /> : (mv.sequence || i + 1)}
              </div>
              <span style={{ flex: 1, fontSize: 13, color: isLocked ? "var(--tc-text-muted)" : "var(--tc-text)" }}>
                {mv.title}
              </span>
              {isLocked ? (
                <span style={{ fontSize: 10, color: "var(--tc-gold)", fontWeight: 600, display: "inline-flex", alignItems: "center", gap: 2 }}>
                  🔒 Locked ({tierLabels(mv.allowed_tiers) || tier3PlanName || "SF Tier 3"})
                </span>
              ) : (
                mv.video_url && (
                  <span style={{ fontSize: 10, color: isExpanded ? "var(--tc-text-muted)" : "var(--tc-gold)", fontWeight: 600, display: "inline-flex", alignItems: "center", gap: 2 }} className="hover:underline">
                    {isExpanded ? <X size={10} /> : <Play size={10} />}
                    {isExpanded ? "Close" : "Play Video"}
                  </span>
                )
              )}
              {hasMixedBreath && mv.movement_tag && (
                <BreathBadge type={mv.movement_tag} />
              )}
            </div>
            {isExpanded && mv.video_url && (
              <div
                style={{
                  padding: "0 14px 12px 14px",
                  backgroundColor: "transparent",
                  borderBottom: i < set.movements.length - 1 ? "1px solid var(--tc-divider)" : "none"
                }}
                onContextMenu={(e) => e.preventDefault()}
              >
                <div
                  style={{ position: 'relative', width: '100%', aspectRatio: '16/9', borderRadius: 10, overflow: 'hidden', backgroundColor: '#000', marginBottom: 8 }}
                >
                  <SecureYoutubePlayer
                    url={mv.video_url}
                    title={mv.title}
                    onPlayStateChanged={(isPlaying) => {
                      if (isPlaying) {
                        setPlayingMovementId(mv.id || mv.title || i.toString());
                        playBpmAudio(selectedBpm);
                      } else {
                        if (playingMovementId === (mv.id || mv.title || i.toString())) {
                          setPlayingMovementId(null);
                          stopBpmAudio();
                        }
                      }
                    }}
                  />
                </div>

                {/* ── BPM Metronome Player Box ── */}
                <div
                  style={{
                    display: "flex",
                    alignItems: "center",
                    gap: 12,
                    padding: "8px 12px",
                    background: "var(--tc-toggle-bg)",
                    border: "1px solid var(--tc-border)",
                    borderRadius: 10,
                  }}
                >
                  <div style={{ color: isBpmPlaying ? pc : "var(--tc-text-muted)", display: "flex", alignItems: "center" }}>
                    <Music size={18} className={isBpmPlaying ? "animate-pulse" : ""} />
                  </div>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div
                      style={{
                        fontSize: 8,
                        fontWeight: 700,
                        color: "var(--tc-text-muted)",
                        letterSpacing: 0.8,
                        textTransform: "uppercase",
                        lineHeight: 1.2,
                      }}
                    >
                      BPM MUSIC PLAYER
                    </div>
                    <div
                      style={{
                        fontSize: 11,
                        fontWeight: 600,
                        color: "var(--tc-text)",
                        lineHeight: 1.3,
                        marginTop: 1,
                      }}
                    >
                      {isBpmPlaying
                        ? `Playing · ${selectedBpm} BPM`
                        : selectedBpm === "No BPM"
                        ? "Muted (No BPM)"
                        : `Paused · ${selectedBpm} BPM`}
                    </div>
                  </div>
                  <div style={{ display: "flex", alignItems: "center" }}>
                    <select
                      value={selectedBpm}
                      onChange={(e) => {
                        const val = e.target.value;
                        setSelectedBpm(val);
                        if (isBpmPlaying || playingMovementId) {
                          playBpmAudio(val);
                        }
                      }}
                      style={{
                        background: "var(--tc-card)",
                        border: "1px solid var(--tc-border)",
                        borderRadius: 6,
                        padding: "3px 20px 3px 8px",
                        fontSize: 11,
                        fontWeight: "bold",
                        color: pc,
                        cursor: "pointer",
                        outline: "none",
                        appearance: "none",
                        WebkitAppearance: "none",
                        backgroundImage: `url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='${encodeURIComponent(pc)}' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><polyline points='6 9 12 15 18 9'></polyline></svg>")`,
                        backgroundRepeat: "no-repeat",
                        backgroundPosition: "right 4px center",
                        backgroundSize: "12px",
                      }}
                    >
                      <option value="No BPM" style={{ color: "var(--tc-text-secondary)" }}>
                        No BPM
                      </option>
                      {["60", "70", "80", "90", "100", "110", "120", "130", "140", "150", "160", "170", "180", "190", "200"].map((val) => (
                        <option key={val} value={val}>
                          {val} BPM
                        </option>
                      ))}
                    </select>
                  </div>
                  <button
                    onClick={() => {
                      if (selectedBpm === "No BPM") return;
                      if (isBpmPlaying) {
                        stopBpmAudio();
                      } else {
                        playBpmAudio(selectedBpm);
                      }
                    }}
                    disabled={selectedBpm === "No BPM"}
                    style={{
                      width: 28,
                      height: 28,
                      borderRadius: "50%",
                      background: selectedBpm === "No BPM" ? "var(--tc-chip-bg)" : `${pc}25`,
                      border: `1px solid ${selectedBpm === "No BPM" ? "var(--tc-chip-border)" : `${pc}40`}`,
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                      color: selectedBpm === "No BPM" ? "var(--tc-text-muted)" : pc,
                      cursor: selectedBpm === "No BPM" ? "default" : "pointer",
                      padding: 0,
                    }}
                  >
                    {isBpmPlaying ? <Pause size={14} /> : <Play size={14} fill={selectedBpm === "No BPM" ? "none" : "currentColor"} />}
                  </button>
                </div>
              </div>
            )}
          </div>
        );
      })}

      {/* Breath note at bottom */}
      {!hasMixedBreath && breathTypes.length === 1 && set.movements.length > 0 && (
        <div
          style={{
            padding: "7px 14px",
            borderTop: "1px solid var(--tc-divider)",
            display: "flex",
            alignItems: "center",
            gap: 6,
          }}
        >
          <span style={{ fontSize: 10, color: "var(--tc-text-muted)" }}>Napas:</span>
          <BreathBadge type={breathTypes[0]} />
        </div>
      )}

      {/* ── BPM Target Block ──────────────────────────────── */}
      {hasBPM && (
        <div
          style={{
            borderTop: `1px solid ${pc}20`,
            background: `${pc}08`,
            padding: "10px 14px",
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
          }}
        >
          <div>
            <div
              style={{
                fontSize: 9,
                color: "var(--tc-text-muted)",
                letterSpacing: 1,
                marginBottom: 2,
              }}
            >
              TARGET BPM SESI INI
            </div>
            <div
              className="font-bebas"
              style={{
                fontSize: 28,
                color: pc,
                lineHeight: 1,
                letterSpacing: 1,
              }}
            >
              {set.bpm_range}
            </div>
          </div>
          <div style={{ textAlign: "right" }}>
            <div style={{ fontSize: 9, color: "var(--tc-text-muted)", marginBottom: 4 }}>
              RANGE
            </div>
            <div style={{ display: "flex", gap: 4 }}>
              {(set.bpm_range.includes("–")
                ? set.bpm_range.split("–")
                : set.bpm_range.split("-")
              ).map((v, i) => (
                <div
                  key={i}
                  className="font-bebas"
                  style={{
                    background: `${pc}15`,
                    border: `1px solid ${pc}30`,
                    borderRadius: 6,
                    padding: "4px 8px",
                    fontSize: 16,
                    color: pc,
                    letterSpacing: 0.5,
                  }}
                >
                  {v.trim()}
                </div>
              ))}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// ── Legacy Exercise Card (for trainer-created sequences) ───────────
function LegacyExerciseCard({
  set,
  catCode,
  catName,
}: {
  set: CardSet;
  catCode: string;
  catName: string;
}) {
  const pc = PILLAR_COLORS[catCode] || "var(--tc-gold)";

  return (
    <div
      style={{
        background: "var(--tc-card)",
        border: `1px solid ${pc}22`,
        borderRadius: 14,
        overflow: "hidden",
      }}
    >
      {/* ── Header */}
      <div
        style={{
          background: `linear-gradient(135deg,${pc}10,transparent)`,
          borderBottom: `1px solid ${pc}15`,
          padding: "11px 14px",
          display: "flex",
          justifyContent: "space-between",
          alignItems: "flex-start",
          gap: 8,
        }}
      >
        <div style={{ flex: 1 }}>
          <div
            className="font-bebas"
            style={{
              fontSize: 16,
              color: pc,
              letterSpacing: 2,
              lineHeight: 1,
              marginBottom: 7,
            }}
          >
            {catName} · Set {set.set_number}
          </div>
          <div style={{ display: "flex", flexWrap: "wrap", gap: 5 }}>
            {set.duration && <Chip>⏱ {set.duration}</Chip>}
            {set.type_name && <Chip>{set.type_name}</Chip>}
            {set.equipment_upper && (
              <Chip color="#93c5fd" bg="var(--tc-breath-d-bg)" border="#93c5fd30">
                💪 {formatWeight(set.equipment_upper)}
              </Chip>
            )}
            {set.equipment_lower && (
              <Chip color="#86efac" bg="var(--tc-breath-c-bg)" border="#86efac30">
                🦵 {formatWeight(set.equipment_lower)}
              </Chip>
            )}
            {set.extra_load && (
              <Chip color="#facc15" bg="var(--tc-gold-bg)" border="#facc1530">
                ⚖️ {formatWeight(set.extra_load)}
              </Chip>
            )}
            {!set.equipment_upper && !set.equipment_lower && !set.extra_load && (
              <Chip>Bodyweight / TRX</Chip>
            )}
          </div>
        </div>
        {set.bpm && set.bpm !== "—" && (
          <div style={{ textAlign: "right", flexShrink: 0 }}>
            <div style={{ fontSize: 8, color: "var(--tc-text-dim)", letterSpacing: 0.8 }}>BPM</div>
            <div
              className="font-bebas"
              style={{ fontSize: 12, color: pc, lineHeight: 1 }}
            >
              {set.bpm}
            </div>
          </div>
        )}
      </div>

      {/* ── Exercises */}
      {set.items?.map((item, i) => (
        <div
          key={i}
          style={{
            display: "flex",
            alignItems: "center",
            gap: 10,
            padding: "9px 14px",
            borderBottom:
              i < set.items.length - 1 ? "1px solid var(--tc-divider)" : "none",
          }}
        >
          <div
            style={{
              width: 22,
              height: 22,
              borderRadius: 5,
              flexShrink: 0,
              background: `${pc}12`,
              border: `1px solid ${pc}20`,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontSize: 10,
              fontWeight: 700,
              color: pc,
            }}
          >
            {i + 1}
          </div>
          <span style={{ flex: 1, fontSize: 13, color: "var(--tc-text)" }}>
            {item.movement_name || "Exercise"}
          </span>
          {item.body_part && (
            <span
              style={{
                fontSize: 9,
                color: "var(--tc-text-muted)",
                textTransform: "uppercase",
                letterSpacing: 0.5,
              }}
            >
              {item.body_part}
            </span>
          )}
        </div>
      ))}

      {/* ── Notes */}
      {set.notes && (
        <div
          style={{
            padding: "7px 14px",
            borderTop: "1px solid var(--tc-divider)",
            display: "flex",
            alignItems: "center",
            gap: 6,
          }}
        >
          <span style={{ fontSize: 10, color: "var(--tc-text-muted)" }}>📝</span>
          <span style={{ fontSize: 10, color: "var(--tc-text-secondary)" }}>{set.notes}</span>
        </div>
      )}

      {/* ── BPM Target Block */}
      {set.bpm && set.bpm !== "—" && (
        <div
          style={{
            borderTop: `1px solid ${pc}20`,
            background: `${pc}08`,
            padding: "10px 14px",
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
          }}
        >
          <div>
            <div
              style={{
                fontSize: 9,
                color: "var(--tc-text-muted)",
                letterSpacing: 1,
                marginBottom: 2,
              }}
            >
              TARGET BPM SESI INI
            </div>
            <div
              className="font-bebas"
              style={{
                fontSize: 28,
                color: pc,
                lineHeight: 1,
                letterSpacing: 1,
              }}
            >
              {set.bpm}
            </div>
          </div>
          <div style={{ textAlign: "right" }}>
            <div style={{ fontSize: 9, color: "var(--tc-text-muted)", marginBottom: 4 }}>
              RANGE
            </div>
            <div style={{ display: "flex", gap: 4 }}>
              {(set.bpm.includes("–") ? set.bpm.split("–") : set.bpm.split("-")).map(
                (v, i) => (
                  <div
                    key={i}
                    className="font-bebas"
                    style={{
                      background: `${pc}15`,
                      border: `1px solid ${pc}30`,
                      borderRadius: 6,
                      padding: "4px 8px",
                      fontSize: 16,
                      color: pc,
                      letterSpacing: 0.5,
                    }}
                  >
                    {v.trim()}
                  </div>
                )
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// ════════════════════════════════════════════════════════════════════
//  Session Toggle
// ════════════════════════════════════════════════════════════════════

function SessionToggle({
  session,
  setSession,
  lang,
}: {
  session: "full" | "daily";
  setSession: (s: "full" | "daily") => void;
  lang: string;
}) {
  const options: [string, string, string][] =
    lang === "en"
      ? [
          ["full", "Full Program", "60 min · 2×/week"],
          ["daily", "Daily Reset", "30 min · 2×/week"],
        ]
      : [
          ["full", "Full Program", "60 min · 2×/minggu"],
          ["daily", "Daily Reset", "30 min · 2×/minggu"],
        ];

  return (
    <div
      style={{
        display: "flex",
        gap: 0,
        background: "var(--tc-toggle-bg)",
        borderRadius: 10,
        border: "1px solid var(--tc-toggle-border)",
        overflow: "hidden",
        marginBottom: 10,
      }}
    >
      {options.map(([v, lbl, sub]) => (
        <button
          key={v}
          onClick={() => setSession(v as "full" | "daily")}
          style={{
            flex: 1,
            padding: "10px 8px",
            border: "none",
            cursor: "pointer",
            background: session === v ? "var(--tc-toggle-active)" : "transparent",
            borderRight: v === "full" ? "1px solid var(--tc-toggle-border)" : "none",
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            gap: 2,
          }}
        >
          <span
            style={{
              fontSize: 11,
              fontWeight: 700,
              color: session === v ? "var(--tc-gold)" : "var(--tc-text-muted)",
              letterSpacing: 0.3,
            }}
          >
            {lbl}
          </span>
          <span style={{ fontSize: 9, color: session === v ? "var(--tc-gold-dim)" : "var(--tc-text-dim)" }}>
            {sub}
          </span>
        </button>
      ))}
    </div>
  );
}

// ════════════════════════════════════════════════════════════════════
//  Main Page
// ════════════════════════════════════════════════════════════════════

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

function getYoutubeEmbedUrl(url: string): string {
  if (!url) return "";
  let videoId = "";
  if (url.includes("youtu.be/")) {
    videoId = url.split("youtu.be/")[1]?.split("?")[0] || "";
  } else if (url.includes("v=")) {
    videoId = url.split("v=")[1]?.split("&")[0] || "";
  } else if (url.includes("embed/")) {
    videoId = url.split("embed/")[1]?.split("?")[0] || "";
  } else {
    videoId = url;
  }
  return `https://www.youtube.com/embed/${videoId}?controls=1&modestbranding=1&rel=0&showinfo=0&iv_load_policy=3&disablekb=1&fs=0`;
}

interface SecureYoutubePlayerProps {
  url: string;
  title: string;
  className?: string;
  style?: React.CSSProperties;
  onPlayStateChanged?: (isPlaying: boolean) => void;
}

function SecureYoutubePlayer({ url, title, className, style, onPlayStateChanged }: SecureYoutubePlayerProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const iframeRef = useRef<HTMLIFrameElement>(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [isMuted, setIsMuted] = useState(false);
  const [isFullscreen, setIsFullscreen] = useState(false);

  useEffect(() => {
    const handleFullscreenChange = () => {
      setIsFullscreen(!!document.fullscreenElement);
    };
    document.addEventListener("fullscreenchange", handleFullscreenChange);
    return () => {
      document.removeEventListener("fullscreenchange", handleFullscreenChange);
    };
  }, []);

  const videoId = useMemo(() => {
    if (!url) return "";
    let id = "";
    if (url.includes("youtu.be/")) {
      id = url.split("youtu.be/")[1]?.split("?")[0] || "";
    } else if (url.includes("v=")) {
      id = url.split("v=")[1]?.split("&")[0] || "";
    } else if (url.includes("embed/")) {
      id = url.split("embed/")[1]?.split("?")[0] || "";
    } else {
      id = url;
    }
    return id;
  }, [url]);

  const embedUrl = useMemo(() => {
    if (!videoId) return "";
    return `https://www.youtube.com/embed/${videoId}?enablejsapi=1&controls=0&modestbranding=1&rel=0&showinfo=0&iv_load_policy=3&disablekb=1&fs=0`;
  }, [videoId]);

  const sendPlayerCommand = (func: string, args: any = "") => {
    if (iframeRef.current && iframeRef.current.contentWindow) {
      iframeRef.current.contentWindow.postMessage(
        JSON.stringify({ event: "command", func, args }),
        "*"
      );
    }
  };

  const handleOverlayClick = () => {
    if (isPlaying) {
      sendPlayerCommand("pauseVideo");
      setIsPlaying(false);
      onPlayStateChanged?.(false);
    } else {
      sendPlayerCommand("playVideo");
      setIsPlaying(true);
      onPlayStateChanged?.(true);
    }
  };

  const toggleMute = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (isMuted) {
      sendPlayerCommand("unMute");
      setIsMuted(false);
    } else {
      sendPlayerCommand("mute");
      setIsMuted(true);
    }
  };

  const toggleFullscreen = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (!containerRef.current) return;
    if (!document.fullscreenElement) {
      containerRef.current.requestFullscreen?.()
        .catch((err) => console.error("Error enabling fullscreen:", err));
    } else {
      document.exitFullscreen?.();
    }
  };

  if (!videoId) return null;

  return (
    <div
      ref={containerRef}
      className={className}
      style={{
        position: "relative",
        width: "100%",
        height: "100%",
        backgroundColor: "#000",
        userSelect: "none",
        WebkitUserSelect: "none",
        ...style,
      }}
      onContextMenu={(e) => e.preventDefault()}
    >
      <iframe
        ref={iframeRef}
        src={embedUrl}
        title={title}
        style={{ width: "100%", height: "100%", border: "none" }}
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope"
        sandbox="allow-scripts allow-same-origin allow-presentation"
      />
      
      {/* Full transparent overlay blocking all click/right-click actions on the iframe */}
      <div
        onClick={handleOverlayClick}
        style={{
          position: "absolute",
          inset: 0,
          zIndex: 10,
          cursor: "pointer",
          backgroundColor: "transparent",
        }}
      />

      {/* Play / Pause indicator overlay (centered) */}
      {!isPlaying && (
        <div
          onClick={handleOverlayClick}
          style={{
            position: "absolute",
            top: "50%",
            left: "50%",
            transform: "translate(-50%, -50%)",
            zIndex: 11,
            pointerEvents: "none",
            backgroundColor: "rgba(0, 0, 0, 0.6)",
            borderRadius: "50%",
            width: 60,
            height: 60,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            color: "#fff",
            boxShadow: "0 4px 10px rgba(0,0,0,0.3)",
          }}
        >
          <svg
            viewBox="0 0 24 24"
            width="32"
            height="32"
            fill="currentColor"
          >
            <path d="M8 5v14l11-7z" />
          </svg>
        </div>
      )}

      {/* Control bar overlay at the bottom */}
      <div
        style={{
          position: "absolute",
          bottom: 10,
          left: 10,
          right: 10,
          zIndex: 12,
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          pointerEvents: "none",
        }}
      >
        {/* Play/Pause Button */}
        <button
          onClick={handleOverlayClick}
          style={{
            pointerEvents: "auto",
            backgroundColor: "rgba(0, 0, 0, 0.6)",
            border: "none",
            borderRadius: "50%",
            width: 36,
            height: 36,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            color: "#fff",
            cursor: "pointer",
          }}
        >
          {isPlaying ? (
            <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor">
              <path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z" />
            </svg>
          ) : (
            <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor">
              <path d="M8 5v14l11-7z" />
            </svg>
          )}
        </button>

        {/* Right Buttons group */}
        <div style={{ display: "flex", gap: 8, pointerEvents: "none" }}>
          {/* Mute/Unmute Button */}
          <button
            onClick={toggleMute}
            style={{
              pointerEvents: "auto",
              backgroundColor: "rgba(0, 0, 0, 0.6)",
              border: "none",
              borderRadius: "50%",
              width: 36,
              height: 36,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              color: "#fff",
              cursor: "pointer",
            }}
          >
            {isMuted ? (
              <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor">
                <path d="M19 12c0-1.2-.49-2.28-1.29-3.06l-1.42 1.42c.43.43.71 1.03.71 1.64s-.28 1.21-.71 1.64l1.42 1.42C18.51 14.28 19 13.2 19 12zm-3.5 0c0-.56-.23-1.07-.6-1.43l-1.43 1.43v.01l1.43 1.43c.37-.36.6-.87.6-1.44zm-11.5-3v6h4l5 5V4L9 9H4zm14.5 3c0-2.89-1.89-5.36-4.5-6.22v12.43c2.61-.85 4.5-3.32 4.5-6.21z" />
              </svg>
            ) : (
              <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor">
                <path d="M16.5 12c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02zM14 3.23v2.06c2.89.86 5 3.54 5 6.71s-2.11 5.85-5 6.71v2.06c4.01-.91 7-4.49 7-8.77s-2.99-7.86-7-8.77zM3 9v6h4l5 5V4L7 9H3z" />
              </svg>
            )}
          </button>

          {/* Fullscreen Button */}
          <button
            onClick={toggleFullscreen}
            style={{
              pointerEvents: "auto",
              backgroundColor: "rgba(0, 0, 0, 0.6)",
              border: "none",
              borderRadius: "50%",
              width: 36,
              height: 36,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              color: "#fff",
              cursor: "pointer",
            }}
          >
            {isFullscreen ? (
              <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor">
                <path d="M5 16h3v3h2v-5H5v2zm3-8H5v2h5V5H8v3zm6 11h2v-3h3v-2h-5v5zm2-11V5h-2v5h5V8h-3z" />
              </svg>
            ) : (
              <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor">
                <path d="M7 14H5v5h5v-2H7v-3zm-2-4h2V7h3V5H5v5zm12 7h-3v2h5v-5h-2v3zM14 5v2h3v3h2V5h-5z" />
              </svg>
            )}
          </button>
        </div>
      </div>
    </div>
  );
}

const formatWeight = (w: string | null | undefined): string => {
  if (!w) return "";
  return w.replace(/(\d+)\.00/g, "$1").replace(/(\d+\.\d)0/g, "$1");
};

// ── Level parsing ────────────────────────────────────────────────────
// Card level can be a single value ("5") or a range ("5-6", "4-5") — see the
// trainer_card_templates.level convention. The "Level 5/6" workout session is
// for performance-tier clients, whose level resolves to 5 or 6 (the backend
// emits "5-6" for physical_status_level = level_4_5_perf). Match on either
// bound so the range form "5-6" is recognised, not just a bare "5"/"6".
function isPerformanceLevel(level: string | null | undefined): boolean {
  if (!level) return false;
  return level
    .split(/[-–]/)
    .map((part) => parseInt(part.trim(), 10))
    .some((n) => n === 5 || n === 6);
}

export default function TrainingCardPage() {
  const { subscription, isFree, isLoading: subLoading } = useMySubscription();
  const [lang, setLang] = useState("id");
  const [session, setSession] = useState<"full" | "daily">("full");
  const [activePillarIdx, setActivePillarIdx] = useState(0);
  const [activeSetIdx, setActiveSetIdx] = useState(0);
  const [activeTab, setActiveTab] = useState<string>("");
  const [selectedVideo, setSelectedVideo] = useState<{ title: string; url: string } | null>(null);

  const router = useRouter();
  const logWorkoutSession = useLogWorkoutSession();
  const [sessionStarted, setSessionStarted] = useState(false);
  const [isPaused, setIsPaused] = useState(false);
  const [sessionDurationSeconds, setSessionDurationSeconds] = useState(0);
  const [showFinishConfirm, setShowFinishConfirm] = useState(false);
  const timerRef = useRef<NodeJS.Timeout | null>(null);
  // Seconds already accrued before the current running segment, plus the epoch
  // timestamp the timer was last resumed at (null while paused). Tracking the
  // resume time lets us recompute real wall-clock elapsed time even after the
  // page unmounts (e.g. the user switched to another menu) and remounts.
  const accumulatedRef = useRef(0);
  const resumedAtRef = useRef<number | null>(null);

  const SESSION_STORAGE_KEY = "tc_workout_session";

  const persistSession = (paused: boolean) => {
    if (typeof window === "undefined") return;
    localStorage.setItem(
      SESSION_STORAGE_KEY,
      JSON.stringify({
        active: true,
        paused,
        accumulatedSeconds: accumulatedRef.current,
        resumedAt: resumedAtRef.current,
      })
    );
  };

  // Restore an in-progress session on mount — lets the user navigate to another
  // menu and come back without losing the timer (resumes if it was paused).
  useEffect(() => {
    if (typeof window === "undefined") return;
    try {
      const raw = localStorage.getItem(SESSION_STORAGE_KEY);
      if (!raw) return;
      const saved = JSON.parse(raw);
      if (!saved?.active) return;
      accumulatedRef.current = saved.accumulatedSeconds || 0;
      resumedAtRef.current = saved.paused ? null : saved.resumedAt ?? Date.now();
      const elapsed = saved.paused
        ? accumulatedRef.current
        : accumulatedRef.current +
          Math.floor((Date.now() - (saved.resumedAt || Date.now())) / 1000);
      setSessionStarted(true);
      setIsPaused(!!saved.paused);
      setSessionDurationSeconds(elapsed);
    } catch {
      /* ignore malformed persisted state */
    }
  }, []);

  // Tick every second while the session is running and not paused.
  useEffect(() => {
    if (sessionStarted && !isPaused) {
      timerRef.current = setInterval(() => {
        const since = resumedAtRef.current
          ? Math.floor((Date.now() - resumedAtRef.current) / 1000)
          : 0;
        setSessionDurationSeconds(accumulatedRef.current + since);
      }, 1000);
    }
    return () => {
      if (timerRef.current) {
        clearInterval(timerRef.current);
        timerRef.current = null;
      }
    };
  }, [sessionStarted, isPaused]);

  const startSession = () => {
    accumulatedRef.current = 0;
    resumedAtRef.current = Date.now();
    setSessionStarted(true);
    setIsPaused(false);
    setSessionDurationSeconds(0);
    persistSession(false);
  };

  const pauseSession = () => {
    const since = resumedAtRef.current
      ? Math.floor((Date.now() - resumedAtRef.current) / 1000)
      : 0;
    accumulatedRef.current += since;
    resumedAtRef.current = null;
    setIsPaused(true);
    setSessionDurationSeconds(accumulatedRef.current);
    persistSession(true);
  };

  const resumeSession = () => {
    resumedAtRef.current = Date.now();
    setIsPaused(false);
    persistSession(false);
  };

  const finishSession = () => {
    // Final elapsed = accrued + time since last resume (0 while paused).
    const finalSeconds =
      accumulatedRef.current +
      (resumedAtRef.current
        ? Math.floor((Date.now() - resumedAtRef.current) / 1000)
        : 0);

    // Record the completed session (fire-and-forget; navigation continues
    // regardless so a network hiccup never traps the user on the card).
    logWorkoutSession.mutate({
      session_type: session,
      duration_seconds: finalSeconds,
      level: cardLevel,
    });

    if (typeof window !== "undefined") {
      localStorage.removeItem(SESSION_STORAGE_KEY);
    }
    accumulatedRef.current = 0;
    resumedAtRef.current = null;
    setSessionStarted(false);
    setIsPaused(false);
    setShowFinishConfirm(false);
    router.push("/progress");
  };

  // Detect browser language / locale on mount
  useEffect(() => {
    const saved = localStorage.getItem("locale");
    if (saved === "en" || saved === "id") {
      setLang(saved);
    } else if (typeof window !== "undefined" && window.navigator) {
      const browserLang = window.navigator.language;
      if (browserLang && browserLang.toLowerCase().startsWith("en")) {
        setLang("en");
      }
    }
  }, []);

  const t = {
    id: {
      title: "Kartu Latihan",
      subtitle:
        "Program latihan terarah disesuaikan dengan profil metabolisme & kesehatan Anda.",
      level: "Level",
      notes: "Catatan Trainer",
      loading: "Memuat Kartu Latihan...",
      errorSubscriptionTitle: "Akses Dibatasi",
      errorSubscriptionDesc:
        "Silakan berlangganan paket program terlebih dahulu untuk melihat Kartu Latihan Anda.",
      noCardTitle: "Kartu Belum Dibuat",
      noCardDesc:
        "Trainer Anda belum merumuskan Kartu Latihan untuk Anda saat ini.",
      subscribeBtn: "Ambil Paket Program",
    },
    en: {
      title: "Training Card",
      subtitle:
        "Personalized training program customized to your metabolic & health profile.",
      level: "Level",
      notes: "Trainer Notes",
      loading: "Loading Training Card...",
      errorSubscriptionTitle: "Access Restricted",
      errorSubscriptionDesc:
        "Please subscribe to a program package to view your Training Card.",
      noCardTitle: "Card Not Created Yet",
      noCardDesc:
        "Your trainer has not generated a Training Card for you at this time.",
      subscribeBtn: "Choose Program Package",
    },
  }[lang as "id" | "en"];

  // Fetch latest assessment
  const { data: assessmentRes, isLoading: assessmentLoading } = useQuery({
    queryKey: ["latest-assessment"],
    queryFn: async () => {
      try {
        return await apiGet<any>("/api/v2/assessments/latest");
      } catch (err: any) {
        const msg = err.message?.toLowerCase() || "";
        if (msg.includes("not found") || msg.includes("no v2 assessment") || msg.includes("404")) {
          return { success: true, data: null };
        }
        throw err;
      }
    },
    retry: false,
    refetchOnMount: false,
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
    staleTime: Infinity,
    gcTime: Infinity,
    enabled: true,
  });

  // Fetch user profile
  const { data: profileRes, isLoading: profileLoading } = useQuery({
    queryKey: ["profile-me"],
    queryFn: () => apiGet<any>("/api/auth/me"),
    enabled: true,
  });

  const isTier2 = subscription?.tier === "sf_tier_2";
  const isTier3 = subscription?.tier === "sf_tier_3";
  const isOverriddenTier = isTier2 || isTier3;

  // Fetch available subscription plans
  const { data: plansRes } = useQuery({
    queryKey: ["subscription-plans"],
    queryFn: () => apiGet<any>("/api/subscription/plans"),
  });

  const tier3PlanName = useMemo(() => {
    const groups = plansRes?.data || [];
    const tier3Group = groups.find((g: any) => g.tier === "sf_tier_3");
    if (tier3Group) {
      return tier3Group.monthly?.name || tier3Group.quarterly?.name || tier3Group.annual?.name || "SF Tier 3";
    }
    return "SF Tier 3";
  }, [plansRes]);

  // Fetch Training Card
  const { data: cardRes, isLoading: cardLoading } = useQuery({
    queryKey: ["client-training-card"],
    queryFn: () => apiGet<TrainerCard>("/api/v2/assessments/training-card"),
    retry: false,
    enabled: true,
  });

  const presetCard = useMemo(() => {
    if (!isOverriddenTier) return null;
    
    const userGender = profileRes?.data?.profile?.gender || "female";
    const getMovementVideo = (mv: any) => {
      if (userGender.toLowerCase() === "male" || userGender.toLowerCase() === "men") {
        return mv.video_url_male || mv.video_url_female || "";
      }
      return mv.video_url_female || mv.video_url_male || "";
    };

    const movements = TIER2_MOVEMENTS.map((mv, index) => ({
      id: mv.id,
      sequence: index + 1,
      title: mv.title,
      video_url: getMovementVideo(mv),
      movement_tag: mv.movement_tag,
    }));

    const fullProgram: ProgramCategory[] = [
      {
        type: "FUNCTIONAL",
        duration: "10'",
        sets: [
          {
            set_name: "Set 1",
            duration_mins: 3,
            bpm_range: "80",
            tags: ["Group AG", "Wrist 0.25 kg", "Ankle 0.5 kg"],
            movements: movements,
          }
        ]
      },
      {
        type: "CARDIO",
        duration: "20'",
        sets: [
          {
            set_name: "Set 1",
            duration_mins: 5,
            bpm_range: "",
            tags: ["1.00 kg", "2.00 kg"],
            movements: movements,
          }
        ]
      },
      {
        type: "METABOLIC",
        duration: "30'",
        sets: [
          {
            set_name: "Set 1",
            duration_mins: 5,
            bpm_range: "",
            tags: ["3.00 kg", "3.00 kg"],
            movements: movements,
          }
        ]
      }
    ];

    return {
      id: "preset-card",
      customer_id: profileRes?.data?.user?.id || "preset-user",
      level: "1",
      notes: "",
      sequences: [],
      full_program: fullProgram,
      daily_reset: fullProgram,
    } as TrainerCard;
  }, [isOverriddenTier, profileRes]);

  const card = cardRes?.data || null;
  const cardLevel = card?.level || "";
  const isLevel5or6 = isPerformanceLevel(cardLevel);

  // ── Determine which data format to use ───────────────────────────
  const hasNewFormat =
    card &&
    ((card.full_program && card.full_program.length > 0) ||
      (card.daily_reset && card.daily_reset.length > 0));

  const activePillars = useMemo(() => {
    if (!hasNewFormat || !card) return [];
    return session === "full"
      ? card.full_program || []
      : card.daily_reset || [];
  }, [hasNewFormat, card, session]);

  useEffect(() => {
    setActivePillarIdx(0);
    setActiveSetIdx(0);
  }, [session, hasNewFormat]);

  useEffect(() => {
    if (
      !hasNewFormat &&
      card?.sequences &&
      card.sequences.length > 0 &&
      !activeTab
    ) {
      const firstSeq = card.sequences[0];
      setActiveTab(
        firstSeq.program_category_code || firstSeq.program_category_id
      );
    }
  }, [card, hasNewFormat, activeTab]);

  const activePillar = activePillars[activePillarIdx];
  const activeSet = activePillar?.sets[activeSetIdx];

  const activeSequence = card?.sequences?.find(
    (s) =>
      s.program_category_code === activeTab ||
      s.program_category_id === activeTab
  );

  const handleMovementClick = (mv: TrainingMovement, isLocked: boolean) => {
    if (isLocked) {
      const pkgs = tierLabels(mv.allowed_tiers) || tier3PlanName || "SF Tier 3";
      toast.error(
        lang === "en"
          ? `Upgrade to package ${pkgs} to unlock this exercise video.`
          : `Upgrade ke paket ${pkgs} untuk membuka video gerakan ini.`
      );
      return;
    }
    if (mv.video_url) {
      setSelectedVideo({ title: mv.title, url: mv.video_url });
    }
  };

  // ── Render: Loading ──────────────────────────────────────────────
  if (subLoading || cardLoading || assessmentLoading || profileLoading) {
    return (
      <div className="px-5 py-24 flex flex-col items-center justify-center min-h-[500px]">
        <Loader2 size={32} className="animate-spin text-sf-warmGold mb-3" />
        <p className="text-sm text-slate-500 dark:text-slate-400">{t.loading}</p>
      </div>
    );
  }

  // Free (registered-but-unpaid) clients are NOT blocked here anymore — the API
  // serves them the shared "free" program template, which renders below with an
  // upgrade banner.
  const freeBanner = (isFree || card?.is_preview) ? (
    <div className="mb-4 rounded-2xl border border-sf-warmGold/30 bg-sf-warmGold/10 px-4 py-3 flex flex-col sm:flex-row sm:items-start gap-3">
      <div className="shrink-0 w-9 h-9 rounded-xl bg-sf-warmGold/20 flex items-center justify-center text-sf-warmGold">
        <Info size={18} />
      </div>
      <div className="flex-1 min-w-0 mb-2 sm:mb-0">
        <p className="text-sm font-bold text-sf-deepNavy dark:text-white">
          {lang === "en" ? "Free Preview" : "Cuplikan Gratis"}
        </p>
        <p className="text-xs text-slate-600 dark:text-slate-300 mt-0.5 leading-relaxed">
          {lang === "en"
            ? "You're viewing a free preview of your Training Card. Subscribe to unlock your full personalized program."
            : "Anda sedang melihat cuplikan gratis 3 latihan dari program Anda. Berlangganan untuk membuka seluruh Training Card yang dipersonalisasi."}
        </p>
      </div>
      <div className="flex shrink-0 gap-2 self-start sm:self-center">
        <a
          href="https://wa.me/"
          target="_blank"
          rel="noopener noreferrer"
          className="shrink-0 px-3 py-1.5 bg-green-500 hover:bg-green-600 text-white font-bold text-xs rounded-lg shadow-soft transition-transform active:scale-95 flex items-center gap-1.5"
        >
          Hubungi Consultant
        </a>
        <Link
          href="/dashboard"
          className="shrink-0 px-3 py-1.5 bg-gradient-to-r from-sf-warmGold to-sf-warmGoldDark text-white font-bold text-xs rounded-lg shadow-glow-gold transition-transform active:scale-95 flex items-center"
        >
          Upgrade
        </Link>
      </div>
    </div>
  ) : null;

  // ── Render: No Card ──────────────────────────────────────────────
  if (!card || (!hasNewFormat && (!card.sequences || card.sequences.length === 0))) {
    return (
      <div className="px-5 py-12 flex flex-col items-center justify-center min-h-[450px] animate-fade-in-up text-center">
        <div className="w-16 h-16 rounded-2xl bg-amber-50 dark:bg-amber-950/20 flex items-center justify-center mb-5 text-amber-500 shadow-soft">
          <Dumbbell size={32} />
        </div>
        <h2 className="text-lg font-bold text-sf-deepNavy dark:text-white mb-2">
          {t.noCardTitle}
        </h2>
        <p className="text-sm text-slate-500 dark:text-slate-400 max-w-sm mb-8 leading-relaxed">
          {t.noCardDesc}
        </p>
      </div>
    );
  }

  // ── Level 5-6 Workout Session UI (start overlay, floating timer bar with
  // pause/resume, finish modal). Defined once and reused in both render paths.
  const workoutSessionOverlay = (
    <>
      {!sessionStarted && (
        <div className="fixed bottom-20 left-0 right-0 z-40 px-4 pointer-events-none animate-slide-in-up">
          <div className="max-w-lg mx-auto bg-slate-900/90 dark:bg-slate-900/95 backdrop-blur-md border border-sf-warmGold/30 rounded-2xl p-4 shadow-xl flex items-center justify-between gap-3 pointer-events-auto">
            <div className="flex items-center gap-3 min-w-0">
              <div className="w-10 h-10 rounded-xl bg-sf-warmGold/10 flex items-center justify-center border border-sf-warmGold/20 shrink-0">
                <Dumbbell size={20} className="text-sf-warmGold animate-pulse" />
              </div>
              <div className="text-left min-w-0">
                <h3 className="text-white font-bold text-sm truncate">
                  {lang === "en" ? "Ready to Workout?" : "Mulai Latihan?"}
                </h3>
                <p className="text-white/70 text-xs truncate">
                  {lang === "en" ? "Start the timer now." : "Mulai timer sesi ini."}
                </p>
              </div>
            </div>
            <button
              onClick={startSession}
              className="shrink-0 bg-gradient-to-r from-sf-warmGold to-sf-warmGoldDark hover:from-sf-warmGoldDark hover:to-sf-warmGold text-white font-bold py-2.5 px-5 rounded-xl text-xs transition-transform active:scale-95 duration-200 shadow-lg shadow-sf-warmGold/20 uppercase tracking-wider"
            >
              {lang === "en" ? "Start" : "Mulai"}
            </button>
          </div>
        </div>
      )}

      {sessionStarted && (
        <div className="fixed bottom-20 left-0 right-0 z-40 px-4 pointer-events-none">
          <div className="max-w-lg mx-auto bg-slate-900/90 dark:bg-slate-900/95 backdrop-blur-md border border-sf-warmGold/30 rounded-2xl p-4 shadow-xl flex items-center justify-between gap-3 pointer-events-auto">
            <div className="flex items-center gap-3 min-w-0">
              <div className="w-10 h-10 rounded-xl bg-sf-warmGold/10 flex items-center justify-center border border-sf-warmGold/20 shrink-0">
                <Clock size={20} className={`text-sf-warmGold ${isPaused ? "opacity-60" : "animate-pulse"}`} />
              </div>
              <div className="min-w-0">
                <p className="text-[10px] font-extrabold tracking-widest text-sf-warmGold uppercase truncate">
                  {isPaused
                    ? lang === "en" ? "PAUSED" : "DIJEDA"
                    : lang === "en" ? "SESSION DURATION" : "DURASI SESI LATIHAN"}
                </p>
                <p className="text-base font-black text-white font-mono leading-none mt-1">
                  {(() => {
                    const minutes = Math.floor(sessionDurationSeconds / 60);
                    const seconds = sessionDurationSeconds % 60;
                    const padZero = (num: number) => num.toString().padStart(2, "0");
                    return `${padZero(minutes)}:${padZero(seconds)}`;
                  })()}
                </p>
              </div>
            </div>
            <div className="flex items-center gap-2 shrink-0">
              <button
                onClick={isPaused ? resumeSession : pauseSession}
                className="flex items-center gap-1.5 bg-sf-warmGold/15 hover:bg-sf-warmGold/25 text-sf-warmGold border border-sf-warmGold/30 font-bold px-3.5 py-2.5 rounded-xl text-xs transition-transform active:scale-95 duration-200 uppercase tracking-wide"
              >
                {isPaused ? <Play size={14} fill="currentColor" /> : <Pause size={14} fill="currentColor" />}
                {isPaused
                  ? lang === "en" ? "Resume" : "Lanjut"
                  : lang === "en" ? "Pause" : "Jeda"}
              </button>
              <button
                onClick={() => setShowFinishConfirm(true)}
                className="bg-red-600 hover:bg-red-700 text-white font-bold px-3.5 py-2.5 rounded-xl text-xs transition-transform active:scale-95 duration-200 uppercase tracking-wide"
              >
                {lang === "en" ? "Finish" : "Akhiri"}
              </button>
            </div>
          </div>
        </div>
      )}

      {showFinishConfirm && (
        <div className="fixed inset-0 z-[70] flex items-center justify-center bg-black/80 p-4 animate-fade-in">
          <div className="max-w-sm w-full bg-slate-900 border border-sf-warmGold/35 rounded-3xl p-6 shadow-2xl text-white space-y-6 text-center">
            <div className="w-12 h-12 rounded-full bg-red-500/10 flex items-center justify-center mx-auto text-red-500">
              <Info size={24} />
            </div>
            <div className="space-y-2">
              <h3 className="text-lg font-bold font-dm-serif text-white">
                {lang === "en" ? "Finish Session?" : "Akhiri Sesi Latihan?"}
              </h3>
              <p className="text-xs text-white/70 leading-relaxed">
                {lang === "en"
                  ? "Are you sure you want to finish this training session and record your progress?"
                  : "Apakah Anda yakin ingin mengakhiri sesi latihan ini dan mencatat progress Anda?"}
              </p>
            </div>
            <div className="flex gap-3">
              <button
                onClick={() => setShowFinishConfirm(false)}
                className="flex-1 border border-white/20 hover:bg-white/5 py-3 rounded-xl text-xs font-bold transition-colors text-white"
              >
                {lang === "en" ? "Cancel" : "Batal"}
              </button>
              <button
                onClick={finishSession}
                className="flex-1 bg-red-600 hover:bg-red-700 py-3 rounded-xl text-xs font-bold transition-colors text-white"
              >
                {lang === "en" ? "Finish" : "Selesai"}
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );

  // ════════════════════════════════════════════════════════════════
  //  RENDER: New Format (full_program / daily_reset)
  // ════════════════════════════════════════════════════════════════
  if (hasNewFormat) {
    return (
      <div
        className="animate-fade-in-up pb-24 rounded-2xl"
        style={{
          background: "var(--tc-bg)",
          color: "var(--tc-text)",
          minHeight: "80vh",
          padding: "20px 16px",
        }}
      >
        {freeBanner}
        {/* ── Client Info Header ───────────────────────────────── */}
        <ProfileHeader
          user={profileRes?.data?.user}
          profile={profileRes?.data?.profile}
          card={card}
          assessment={assessmentRes?.data}
          session={session}
          lang={lang}
        />

        {/* ── Session Toggle ──────────────────────────────── */}
        <SessionToggle session={session} setSession={setSession} lang={lang} />

        {/* ── Pillar Tabs ───────────────────────────────────── */}
        <div
          style={{
            display: "flex",
            gap: 5,
            marginBottom: 8,
          }}
        >
          {activePillars.map((p, i) => {
            const clr = PILLAR_COLORS[p.type] || "var(--tc-gold)";
            const name = PILLAR_NAMES[p.type] || p.type;
            const isActive = activePillarIdx === i;
            return (
              <button
                key={p.type}
                onClick={() => {
                  setActivePillarIdx(i);
                  setActiveSetIdx(0);
                }}
                style={{
                  flex: 1,
                  padding: "8px 4px",
                  cursor: "pointer",
                  background: isActive ? `${clr}12` : "var(--tc-card)",
                  border: `${isActive ? 2 : 1}px solid ${isActive ? clr : "var(--tc-border)"}`,
                  borderRadius: 9,
                  display: "flex",
                  flexDirection: "column",
                  alignItems: "center",
                  gap: 2,
                }}
              >
                <span
                  style={{
                    fontSize: 10,
                    fontWeight: 700,
                    textTransform: "uppercase",
                    color: isActive ? clr : "var(--tc-text-muted)",
                  }}
                >
                  {name}
                </span>
                <span style={{ fontSize: 9, color: "var(--tc-text-dim)" }}>
                  {p.duration}
                </span>
              </button>
            );
          })}
        </div>

        {/* ── Set Tabs ──────────────────────────────────────── */}
        {activePillar && activePillar.sets.length > 1 && (
          <div
            style={{
              display: "flex",
              gap: 5,
              marginBottom: 10,
            }}
          >
            {activePillar.sets.map((s, i) => {
              const clr = PILLAR_COLORS[activePillar.type] || "var(--tc-gold)";
              const isActive = activeSetIdx === i;
              return (
                <button
                  key={s.set_name}
                  onClick={() => setActiveSetIdx(i)}
                  style={{
                    flex: 1,
                    padding: "6px 4px",
                    cursor: "pointer",
                    background: isActive ? `${clr}12` : "var(--tc-card)",
                    border: `1px solid ${isActive ? clr : "var(--tc-border)"}`,
                    borderRadius: 8,
                    display: "flex",
                    flexDirection: "column",
                    alignItems: "center",
                  }}
                >
                  <span
                    style={{
                      fontSize: 10,
                      fontWeight: 700,
                      color: isActive ? clr : "var(--tc-text-muted)",
                    }}
                  >
                    {s.set_name}
                  </span>
                  <span style={{ fontSize: 9, color: "var(--tc-text-dim)" }}>
                    {s.duration_mins}&apos;
                  </span>
                </button>
              );
            })}
          </div>
        )}

        {/* ── Exercise Card ─────────────────────────────────── */}
        {activePillar && activeSet && (
          <ExerciseCard
            category={activePillar}
            set={activeSet}
            pillarColor={PILLAR_COLORS[activePillar.type] || "var(--tc-gold)"}
            pillarName={PILLAR_NAMES[activePillar.type] || activePillar.type}
            userTier={subscription?.tier || ""}
            onMovementClick={handleMovementClick}
            tier3PlanName={tier3PlanName}
          />
        )}

        {/* ── Video Modal ── */}
        {selectedVideo && (
          <div
            className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 p-4"
            onClick={() => setSelectedVideo(null)}
          >
            <div
              className="relative w-full max-w-3xl bg-slate-900 rounded-2xl overflow-hidden aspect-video shadow-2xl"
              onClick={(e) => e.stopPropagation()}
            >
              <SecureYoutubePlayer url={selectedVideo.url} title={selectedVideo.title} />
              <button
                onClick={() => setSelectedVideo(null)}
                style={{
                  position: "absolute",
                  top: 12,
                  right: 12,
                  width: 32,
                  height: 32,
                  borderRadius: "50%",
                  backgroundColor: "rgba(0,0,0,0.5)",
                  color: "#fff",
                  border: "none",
                  cursor: "pointer",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  zIndex: 20,
                  fontSize: 14,
                  fontWeight: "bold",
                }}
              >
                ✕
              </button>
            </div>
          </div>
        )}

        {workoutSessionOverlay}
      </div>
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  RENDER: Legacy Format (sequences → sets → items)
  // ════════════════════════════════════════════════════════════════
  return (
    <div
      className="animate-fade-in-up pb-24 rounded-2xl"
      style={{
        background: "var(--tc-bg)",
        color: "var(--tc-text)",
        minHeight: "80vh",
        padding: "20px 16px",
      }}
    >
      {freeBanner}
      {/* ── Client Info Header ─────────────────────────────── */}
      <ProfileHeader
        user={profileRes?.data?.user}
        profile={profileRes?.data?.profile}
        card={card}
        assessment={assessmentRes?.data}
        session={session}
        lang={lang}
      />

      {/* ── Sequence Tabs ───────────────────────────────────── */}
      <div
        style={{
          display: "flex",
          gap: 5,
          marginBottom: 10,
        }}
      >
        {card.sequences.map((seq) => {
          const code =
            seq.program_category_code || seq.program_category_id;
          const isActive = activeTab === code;
          const clr = PILLAR_COLORS[code] || PILLAR_COLORS[seq.program_category_name?.toUpperCase() || ""] || "var(--tc-gold)";
          return (
            <button
              key={seq.program_category_id}
              onClick={() => setActiveTab(code)}
              style={{
                flex: 1,
                padding: "8px 4px",
                cursor: "pointer",
                background: isActive ? `${clr}12` : "var(--tc-card)",
                border: `${isActive ? 2 : 1}px solid ${
                  isActive ? clr : "var(--tc-border)"
                }`,
                borderRadius: 9,
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
                gap: 2,
              }}
            >
              <span
                style={{
                  fontSize: 10,
                  fontWeight: 700,
                  textTransform: "uppercase",
                  color: isActive ? clr : "var(--tc-text-muted)",
                }}
              >
                {seq.program_category_name}
              </span>
              {seq.duration && (
                <span style={{ fontSize: 9, color: "var(--tc-text-dim)" }}>
                  {seq.duration}
                </span>
              )}
            </button>
          );
        })}
      </div>

      {/* ── Active Sequence Sets ─────────────────────────────── */}
      {activeSequence && (
        <div>
          {/* Duration info */}
          {activeSequence.duration && (
            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: 8,
                padding: "8px 12px",
                borderRadius: 10,
                background: "var(--tc-gold-bg)",
                border: "1px solid var(--tc-gold-border)",
                marginBottom: 10,
              }}
            >
              <span style={{ fontSize: 10, color: "var(--tc-gold)", fontWeight: 700 }}>
                ⏱ {lang === "en" ? "Session Duration" : "Durasi Sesi"}:{" "}
                {activeSequence.duration}
              </span>
            </div>
          )}

          {/* Sets */}
          <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
            {activeSequence.sets?.map((set, idx) => {
              const catCode =
                activeSequence.program_category_code || "";
              const catName =
                activeSequence.program_category_name || "";
              return (
                <LegacyExerciseCard
                  key={set.set_number || idx}
                  set={set}
                  catCode={catCode}
                  catName={catName}
                />
              );
            })}
          </div>
        </div>
      )}

      {workoutSessionOverlay}
    </div>
  );
}
