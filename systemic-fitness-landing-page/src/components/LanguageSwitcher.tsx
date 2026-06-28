"use client";

import { useLocale } from "next-intl";
import { usePathname, useRouter } from "@/i18n/routing";
import { useTransition } from "react";

export function LanguageSwitcher() {
  const locale = useLocale();
  const router = useRouter();
  const pathname = usePathname();
  const [isPending, startTransition] = useTransition();

  const toggle = () => {
    const nextLocale = locale === "id" ? "en" : "id";
    startTransition(() => {
      router.replace(pathname, { locale: nextLocale });
    });
  };

  return (
    <button
      type="button"
      onClick={toggle}
      disabled={isPending}
      className="flex items-center gap-1.5 text-[11px] tracking-[0.14em] text-navy/55 dark:text-white/60 hover:text-navy dark:hover:text-white transition-colors disabled:opacity-50"
      aria-label="Switch language"
    >
      <span className={locale === "id" ? "text-navy dark:text-white font-medium" : ""}>ID</span>
      <span className="text-navy/30 dark:text-white/30">/</span>
      <span className={locale === "en" ? "text-navy dark:text-white font-medium" : ""}>EN</span>
    </button>
  );
}
