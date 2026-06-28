"use client";

import { usePathname } from "next/navigation";
import { useAuth } from "@/hooks/useAuth";
import { Bell, Moon, Sun, LogOut } from "lucide-react";
import { getInitials } from "@/lib/utils";
import { useTheme } from "next-themes";
import { useEffect, useState } from "react";
import { useMySubscription } from "@/hooks/useSubscription";
import { signOut } from "next-auth/react";

const pageTitles: Record<string, string> = {
  "/dashboard": "Home",
  "/programs": "Workouts",
  "/messages": "Messages",
  "/profile": "Profile",
  "/progress": "Progress",
  "/nutrition": "Nutrisi",
  "/assessment": "Assessment",
};

export function AppHeader() {
  const { user } = useAuth();
  const pathname = usePathname();
  const { theme, setTheme } = useTheme();
  const [mounted, setMounted] = useState(false);
  const { isFree } = useMySubscription();

  useEffect(() => setMounted(true), []);

  let title = pageTitles[pathname] || "Systemic Fitness";
  if (pathname.startsWith("/assessment")) {
    title = "Assessment";
  }
  const isHome = pathname === "/dashboard";

  return (
    <header className="sticky top-0 z-40 bg-bg-primary border-b border-border-color transition-colors duration-200">
      <div className="flex items-center justify-between px-5 py-3 max-w-lg mx-auto">
        {/* Left: Page Title */}
        <h1 className="text-lg font-bold text-text-primary">{title}</h1>

        {/* Right: Actions */}
        <div className="flex items-center gap-2">
          {/* Theme Toggle */}
          {mounted && (
            <button
              onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
              className="relative w-10 h-10 rounded-xl bg-bg-card border border-border-color flex items-center justify-center
                         hover:bg-black/5 dark:hover:bg-white/5 transition-colors"
              aria-label="Toggle Theme"
            >
              {theme === "dark" ? (
                <Sun size={20} className="text-text-primary" />
              ) : (
                <Moon size={20} className="text-text-primary" />
              )}
            </button>
          )}

          {/* Logout Button for Free Tier */}
          {isFree && (
            <button
              onClick={() => signOut({ callbackUrl: "/login" })}
              className="relative w-10 h-10 rounded-xl bg-bg-card border border-border-color flex items-center justify-center
                         hover:bg-rose-500/10 hover:border-red-500/20 text-rose-500 transition-colors"
              aria-label="Logout"
              title="Logout"
            >
              <LogOut size={20} />
            </button>
          )}

          {/* Notification bell — only on Home tab like mobile */}
          {isHome && (
            <button
              className="relative w-10 h-10 rounded-xl bg-bg-card border border-border-color flex items-center justify-center
                         hover:bg-black/5 dark:hover:bg-white/5 transition-colors"
              aria-label="Notifikasi"
            >
              <Bell size={20} className="text-text-primary" />
              <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-rose-500 rounded-full" />
            </button>
          )}
        </div>
      </div>
    </header>
  );
}
