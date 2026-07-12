"use client";

import { usePathname } from "next/navigation";
import Link from "next/link";
import {
  Home,
  Dumbbell,
  MessageCircle,
  User,
  ClipboardCheck,
  ClipboardList,
  TrendingUp,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { useMySubscription } from "@/hooks/useSubscription";
import { useQuery } from "@tanstack/react-query";
import { apiGet } from "@/lib/api";

const navItems = [
  { href: "/dashboard", label: "Home", icon: Home },
  { href: "/training-card", label: "Training Card", icon: ClipboardList },
  { href: "/progress", label: "Progress", icon: TrendingUp },
  { href: "/messages", label: "Messages", icon: MessageCircle },
  { href: "/profile", label: "Profile", icon: User },
];

export function BottomNav() {
  const pathname = usePathname();
  const { isFree } = useMySubscription();

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

  const { data: cardRes } = useQuery({
    queryKey: ["client-training-card"],
    queryFn: async () => {
      try {
        return await apiGet<any>("/api/v2/assessments/training-card");
      } catch (err: any) {
        return { success: true, data: null };
      }
    },
    retry: false,
    refetchOnMount: false,
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
    staleTime: Infinity,
    gcTime: Infinity,
  });

  const hasAssessment = !!assessmentRes?.data;
  const hasCard = !!cardRes?.data;

  // Free (registered-but-unpaid) clients keep access to the Training Card — it
  // serves the shared "free" program template.
  const items = isFree
    ? (hasAssessment || hasCard)
      ? [
          { href: "/dashboard", label: "Home", icon: Home },
          { href: "/training-card", label: "Training Card", icon: ClipboardList },
          { href: "/profile", label: "Profile", icon: User },
        ]
      : [
          { href: "/assessment", label: "Assessment", icon: ClipboardCheck },
          { href: "/training-card", label: "Training Card", icon: ClipboardList },
          { href: "/profile", label: "Profile", icon: User },
        ]
    : navItems;

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 bg-bg-primary border-t border-border-color pb-safe transition-colors duration-200">
      <div className="flex items-center justify-around max-w-lg mx-auto px-2 py-1.5">
        {items.map((item) => {
          const isActive = pathname === item.href || pathname.startsWith(item.href + "/");
          const Icon = item.icon;

          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "flex flex-col items-center gap-0.5 px-4 py-1.5 rounded-xl transition-all duration-200 min-w-[64px]",
                isActive
                  ? "text-sf-warmGold"
                  : "text-text-secondary hover:text-text-primary"
              )}
            >
              <div
                className={cn(
                  "p-1.5 rounded-xl transition-all duration-200",
                  isActive && "bg-sf-warmGold/10"
                )}
              >
                <Icon size={22} strokeWidth={isActive ? 2.5 : 1.5} />
              </div>
              <span
                className={cn(
                  "text-[10px] leading-tight",
                  isActive ? "font-bold" : "font-medium"
                )}
              >
                {item.label}
              </span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
