"use client";

import { useTheme } from "next-themes";
import { Moon, Sun } from "lucide-react";
import { useEffect, useState } from "react";

export function ThemeToggle() {
  const { resolvedTheme, setTheme } = useTheme();
  const [mounted, setMounted] = useState(false);

  useEffect(() => setMounted(true), []);

  const isDark = resolvedTheme === "dark";

  return (
    <button
      type="button"
      onClick={() => setTheme(isDark ? "light" : "dark")}
      aria-label={isDark ? "Switch to light mode" : "Switch to dark mode"}
      className="w-8 h-8 flex items-center justify-center rounded-md text-navy/60 dark:text-white/60 hover:text-navy dark:hover:text-white hover:bg-navy/5 dark:hover:bg-white/10 transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-gold"
    >
      {mounted ? (
        isDark ? (
          <Sun className="w-4 h-4" strokeWidth={1.75} />
        ) : (
          <Moon className="w-4 h-4" strokeWidth={1.75} />
        )
      ) : (
        <span className="w-4 h-4" />
      )}
    </button>
  );
}
