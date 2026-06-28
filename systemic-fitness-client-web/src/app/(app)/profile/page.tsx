"use client";

import { useAuth } from "@/hooks/useAuth";
import { signOut } from "next-auth/react";
import { useRouter } from "next/navigation";
import { toast } from "@/stores/toastStore";
import {
  User,
  CreditCard,
  ClipboardList,
  TrendingUp,
  Target,
  Apple,
  Trophy,
  Users,
  Megaphone,
  BarChart3,
  BookOpen,
  CalendarDays,
  UtensilsCrossed,
  ClipboardCheck,
  ChevronRight,
  LogOut,
  Volume2,
  Bell,
} from "lucide-react";
import { useState, useEffect } from "react";
import { useQuery } from "@tanstack/react-query";
import { apiGet } from "@/lib/api";

import { useMySubscription } from "@/hooks/useSubscription";

// Toggle switch component (like CupertinoSwitch in mobile)
function ToggleSwitch({ enabled, onChange }: { enabled: boolean; onChange: (v: boolean) => void }) {
  return (
    <button
      role="switch"
      aria-checked={enabled}
      onClick={() => onChange(!enabled)}
      className={`relative inline-flex h-7 w-12 items-center rounded-full transition-colors duration-200 ${
        enabled ? "bg-green-500" : "bg-gray-300"
      }`}
    >
      <span
        className={`inline-block h-5 w-5 transform rounded-full bg-white shadow-sm transition-transform duration-200 ${
          enabled ? "translate-x-6" : "translate-x-1"
        }`}
      />
    </button>
  );
}

// Menu item component (matching mobile _buildSettingItem)
function MenuItem({
  icon: Icon,
  label,
  onClick,
}: {
  icon: React.ElementType;
  label: string;
  onClick?: () => void;
}) {
  return (
    <>
      <button onClick={onClick} className="menu-item w-full text-left">
        <div className="menu-item-icon">
          <Icon size={20} className="text-sf-charcoal" />
        </div>
        <span className="flex-1 text-sm font-medium text-sf-charcoal">{label}</span>
        <ChevronRight size={18} className="text-gray-300" />
      </button>
      <div className="divider ml-14" />
    </>
  );
}

// Toggle menu item (matching mobile _buildToggleItem)
function ToggleItem({
  label,
  enabled,
  onChange,
}: {
  label: string;
  enabled: boolean;
  onChange: (v: boolean) => void;
}) {
  return (
    <>
      <div className="flex items-center py-3 px-1">
        <span className="flex-1 text-sm font-medium text-sf-charcoal">{label}</span>
        <ToggleSwitch enabled={enabled} onChange={onChange} />
      </div>
      <div className="divider" />
    </>
  );
}

export default function ProfilePage() {
  const router = useRouter();
  const { user, role } = useAuth();
  const { isFree } = useMySubscription();
  const [soundOn, setSoundOn] = useState(true);
  const [ttsOn, setTtsOn] = useState(true);
  const [reminderOn, setReminderOn] = useState(true);
  const [locale, setLocale] = useState<"id" | "en">("id");

  useEffect(() => {
    const saved = localStorage.getItem("locale");
    if (saved === "en" || saved === "id") {
      setLocale(saved);
    }
  }, []);

  const handleLocaleChange = (enabled: boolean) => {
    const next = enabled ? "en" : "id";
    setLocale(next);
    localStorage.setItem("locale", next);
    window.location.reload();
  };

  const { data: assessmentRes } = useQuery({
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
  });
  const latestAssessment = assessmentRes?.data;

  const firstName = user?.name || "User";
  const initial = firstName.charAt(0).toUpperCase();

  const handleSoon = (feature: string) => {
    toast.info(`Fitur ${feature} akan segera hadir di web client. Gunakan mobile app untuk saat ini.`);
  };

  return (
    <div className="px-5 py-4 animate-fade-in-up">
      {/* ── User Header (centered, like mobile) ──────────── */}
      <div className="flex flex-col items-center mb-6">
        <div className="w-20 h-20 rounded-full bg-gray-100 flex items-center justify-center mb-3">
          <span className="text-2xl font-bold text-sf-charcoal">{initial}</span>
        </div>
        <h2 className="text-lg font-bold text-sf-charcoal">{user?.name || "User"}</h2>
        <p className="text-xs text-gray-400 mt-0.5">{user?.email || ""}</p>
        {role && (
          <span className="mt-2 px-3 py-1 rounded-full bg-gray-100 text-[11px] font-semibold text-sf-systemBlue uppercase tracking-wide">
            {role}
          </span>
        )}
      </div>

      {/* ── ACCOUNT Section ──────────────────────────────── */}
      <p className="section-label">ACCOUNT</p>
      <div className="mb-4">
        <MenuItem icon={User} label="Edit Profile" onClick={() => handleSoon("Edit Profile")} />
        <MenuItem icon={CreditCard} label="Subscription" onClick={() => handleSoon("Subscription")} />
        <MenuItem
          icon={ClipboardList}
          label="My Assessments"
          onClick={() => {
            if (latestAssessment?.id) {
              router.push(`/assessment/result?id=${latestAssessment.id}`);
            } else {
              router.push("/assessment");
            }
          }}
        />
        {!isFree && (
          <>
            <MenuItem icon={TrendingUp} label="Progress" onClick={() => router.push("/progress")} />
            <MenuItem icon={Target} label="Body Metrics" onClick={() => handleSoon("Body Metrics")} />
            <MenuItem icon={Apple} label="Nutrition" onClick={() => router.push("/nutrition")} />
            <MenuItem icon={Megaphone} label="Announcements" onClick={() => handleSoon("Announcements")} />
            <MenuItem icon={CalendarDays} label="Schedule" onClick={() => handleSoon("Schedule")} />
            <MenuItem icon={UtensilsCrossed} label="Foods" onClick={() => handleSoon("Foods")} />
            <MenuItem icon={ClipboardCheck} label="Forms" onClick={() => handleSoon("Forms")} />
          </>
        )}
      </div>

      {/* ── SETTINGS Section ─────────────────────────────── */}
      <p className="section-label">SETTINGS</p>
      <div className="mb-6">
        <ToggleItem label="Sound" enabled={soundOn} onChange={setSoundOn} />
        <ToggleItem label="Text to Speech" enabled={ttsOn} onChange={setTtsOn} />
        <ToggleItem label="Reminders" enabled={reminderOn} onChange={setReminderOn} />
        <ToggleItem label="English Language (Bahasa Inggris)" enabled={locale === "en"} onChange={handleLocaleChange} />
      </div>

      {/* ── Logout Button ────────────────────────────────── */}
      <button
        onClick={() => signOut({ callbackUrl: "/login" })}
        className="w-full sf-cta-danger py-3.5 rounded-2xl"
      >
        <LogOut size={18} />
        Logout
      </button>

      {/* ── App Version ──────────────────────────────────── */}
      <p className="text-center text-[10px] text-gray-300 mt-6 mb-4">
        Systemic Fitness Client Web v0.1.0
      </p>
    </div>
  );
}
