"use client";

import Link from "next/link";
import Image from "next/image";
import { usePathname } from "next/navigation";
import { useSession } from "next-auth/react";
import { cn } from "@/lib/utils";
import { useUIStore } from "@/stores/uiStore";
import { useState } from "react";
import { useMyMenus, MenuItem } from "@/hooks/useMenus";
import {
  LayoutDashboard, Users, MessageSquare, Trophy, UserCheck, UsersRound,
  CreditCard, Settings, ChevronLeft, Activity, ChevronRight, Megaphone,
  CalendarDays, Dumbbell, ClipboardList, CalendarRange, Apple, UtensilsCrossed,
  Cookie, Repeat, FileText, TrendingUp, Zap, Library, BookOpen, Pill, Layers,
  ClipboardCheck, Shield, Star, CalendarClock, ArrowRightLeft,
  HeartPulse, Stethoscope, type LucideIcon,
} from "lucide-react";

// ─── Icon Map ──────────────────────────────────────────────────

const iconMap: Record<string, LucideIcon> = {
  LayoutDashboard,
  Users,
  MessageSquare,
  Trophy,
  UserCheck,
  UsersRound,
  CreditCard,
  Settings,
  Megaphone,
  CalendarDays,
  Dumbbell,
  ClipboardList,
  CalendarRange,
  Apple,
  UtensilsCrossed,
  Cookie,
  Repeat,
  FileText,
  TrendingUp,
  Zap,
  Library,
  BookOpen,
  Pill,
  Layers,
  ClipboardCheck,
  Shield,
  Star,
  Activity,
  CalendarClock,
  ArrowRightLeft,
  HeartPulse,
  Stethoscope,
};

function getIcon(iconName: string | null): LucideIcon {
  if (!iconName) return Star;
  return iconMap[iconName] || Star;
}

// ─── Fallback navigation (used when API is loading or fails) ───

const fallbackNavigation: MenuItem[] = [
  { id: "1", parent_id: null, code: "dashboard", label: "Dashboard", icon: "LayoutDashboard", href: "/", sort_order: 1, is_active: true, created_at: "", updated_at: "", children: [] },
  { id: "2", parent_id: null, code: "settings", label: "Settings", icon: "Settings", href: "/settings", sort_order: 99, is_active: true, created_at: "", updated_at: "", children: [] },
];

// ─── SidebarItem Component ──────────────────────────────────────

const SidebarItem = ({
  entry,
  pathname,
  sidebarCollapsed,
  expandedGroups,
  toggleGroup,
  level = 0
}: {
  entry: MenuItem;
  pathname: string;
  sidebarCollapsed: boolean;
  expandedGroups: string[];
  toggleGroup: (code: string) => void;
  level?: number;
}) => {
  const hasChildren = entry.children && entry.children.length > 0;
  const isExpanded = expandedGroups.includes(entry.code) && !sidebarCollapsed;

  // We need to know if any child (recursive) is active
  const isChildActive = (item: MenuItem): boolean => {
    if (item.href && item.href !== "/" && pathname.startsWith(item.href)) return true;
    if (item.children) return item.children.some(isChildActive);
    return false;
  };

  const isActive = entry.href === "/" ? pathname === "/" : entry.href ? pathname.startsWith(entry.href) : false;
  const hasActiveChild = hasChildren && isChildActive(entry);
  const Icon = getIcon(entry.icon);

  if (hasChildren) {
    return (
      <div key={entry.id}>
        <button
          onClick={() => sidebarCollapsed ? undefined : toggleGroup(entry.code)}
          className={cn(
            "w-full flex items-center gap-3 py-2.5 rounded-lg text-sm font-medium transition-colors",
            level === 0 ? "px-3" : "px-3",
            hasActiveChild
              ? "text-sf-systemBlue"
              : "text-sidebar-text hover:bg-sidebar-hover hover:text-white",
            sidebarCollapsed && "justify-center px-2"
          )}
          style={{ paddingLeft: !sidebarCollapsed ? `${12 + level * 16}px` : undefined }}
          title={sidebarCollapsed ? entry.label : undefined}
        >
          <Icon className={cn("shrink-0", level === 0 ? "h-5 w-5" : "h-4 w-4")} />
          {!sidebarCollapsed && (
            <>
              <span className="flex-1 text-left">{entry.label}</span>
              <ChevronRight
                className={cn(
                  "h-4 w-4 transition-transform",
                  isExpanded && "rotate-90"
                )}
              />
            </>
          )}
        </button>

        {isExpanded && (
          <div className="border-l border-white/5 space-y-0.5 mt-0.5" style={{ marginLeft: `${22 + level * 16}px`, paddingLeft: "12px" }}>
            {entry.children!.map((child) => (
              <SidebarItem
                key={child.id}
                entry={child}
                pathname={pathname}
                sidebarCollapsed={sidebarCollapsed}
                expandedGroups={expandedGroups}
                toggleGroup={toggleGroup}
                level={level + 1}
              />
            ))}
          </div>
        )}
      </div>
    );
  }

  // Regular nav item
  return (
    <Link
      key={entry.id}
      href={entry.href || "#"}
      className={cn(
        "flex items-center gap-3 py-2 rounded-lg text-sm transition-colors",
        level === 0 ? "px-3 font-medium py-2.5" : "px-3",
        isActive
          ? "bg-sidebar-active text-white"
          : "text-sidebar-text hover:bg-sidebar-hover hover:text-white",
        sidebarCollapsed && "justify-center px-2"
      )}
      style={{ paddingLeft: !sidebarCollapsed && level > 0 ? `${12 + level * 16}px` : undefined }}
      title={sidebarCollapsed ? entry.label : undefined}
    >
      <Icon className={cn("shrink-0", level === 0 ? "h-5 w-5" : "h-4 w-4")} />
      {!sidebarCollapsed && <span>{entry.label}</span>}
    </Link>
  );
};

// ─── Component ──────────────────────────────────────────────────

export function Sidebar() {
  const pathname = usePathname();
  const { data: session } = useSession();
  const { sidebarCollapsed, toggleCollapse } = useUIStore();
  const [expandedGroups, setExpandedGroups] = useState<string[]>([]);

  // Fetch menus from API
  const { data: menuResponse, isLoading } = useMyMenus();
  const rawMenus: MenuItem[] = menuResponse?.data || fallbackNavigation;
  
  // Ensure Dashboard is always present at the top
  const hasDashboard = rawMenus.some((m) => m.code === "dashboard" || m.href === "/");
  const menus: MenuItem[] = hasDashboard 
    ? rawMenus 
    : [
        { id: "static-dashboard", parent_id: null, code: "dashboard", label: "Dashboard", icon: "LayoutDashboard", href: "/", sort_order: 0, is_active: true, created_at: "", updated_at: "", children: [] },
        ...rawMenus
      ];

  function toggleGroup(code: string) {
    setExpandedGroups((prev) =>
      prev.includes(code) ? prev.filter((g) => g !== code) : [...prev, code]
    );
  }

  const isAuthenticated = session?.user?.role;

  return (
    <aside
      className={cn(
        "fixed left-0 top-0 z-40 h-screen bg-sidebar-bg flex flex-col transition-all duration-300",
        sidebarCollapsed ? "w-[72px]" : "w-[280px]"
      )}
    >
      {/* Logo */}
      <div className="flex items-center h-16 px-5 border-b border-white/5">
        <Image
          src="/logo.jpeg"
          alt="Systemic Fitness"
          width={36}
          height={36}
          className="rounded-lg shrink-0"
        />
        {!sidebarCollapsed && (
          <span className="ml-3 text-lg font-heading font-bold text-white tracking-tight">
            Systemic Fitness
          </span>
        )}
      </div>

      {/* Navigation */}
      <nav className="flex-1 overflow-y-auto py-4 px-3 space-y-1">
        {isLoading && !isAuthenticated ? (
          // Skeleton
          <div className="space-y-2">
            {[...Array(6)].map((_, i) => (
              <div key={i} className="h-10 bg-white/5 rounded-lg animate-pulse" />
            ))}
          </div>
        ) : (
          menus.map((entry) => (
            <SidebarItem
              key={entry.id}
              entry={entry}
              pathname={pathname}
              sidebarCollapsed={sidebarCollapsed}
              expandedGroups={expandedGroups}
              toggleGroup={toggleGroup}
              level={0}
            />
          ))
        )}
      </nav>

      {/* Collapse Toggle */}
      <button
        onClick={toggleCollapse}
        className="flex items-center justify-center h-12 border-t border-white/5
                   text-sidebar-muted hover:text-white transition-colors"
      >
        <ChevronLeft
          className={cn(
            "h-5 w-5 transition-transform",
            sidebarCollapsed && "rotate-180"
          )}
        />
      </button>
    </aside>
  );
}
