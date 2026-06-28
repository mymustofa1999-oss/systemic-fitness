"use client";

import { useTranslations } from "next-intl";
import { Menu, X } from "lucide-react";
import Image from "next/image";
import { useState } from "react";
import { LanguageSwitcher } from "./LanguageSwitcher";
import { ThemeToggle } from "./ThemeToggle";
import { Link } from "@/i18n/routing";

export function Nav() {
  const t = useTranslations("nav");
  const [open, setOpen] = useState(false);

  const links = [
    { href: "/#method", label: t("method") },
    { href: "/#programs", label: t("programs") },
    { href: "/#partner", label: t("partner") },
    // { href: "/#pricing", label: t("pricing") },
    // { href: "/payment-guide", label: t("paymentGuide") },
  ];

  return (
    <nav className="fixed top-0 left-0 right-0 z-[100] px-[5%] h-16 flex items-center justify-between bg-white/95 dark:bg-navy/95 backdrop-blur-xl border-b border-[rgba(10,22,40,0.08)] dark:border-white/10 transition-colors">
      <Link
        href="/"
        aria-label="Systemic Fitness — Home"
        className="flex items-center gap-2.5 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-gold rounded"
      >
        <Image
          src="/logo_only_1.png"
          alt="Systemic Fitness"
          width={160}
          height={160}
          priority
          className="hidden dark:block h-9 w-9 object-contain"
        />
        <Image
          src="/logo_only_2.png"
          alt="Systemic Fitness"
          width={160}
          height={160}
          priority
          className="block dark:hidden h-9 w-9 object-contain"
        />
        <span className="text-[13px] leading-none tracking-tight">
          <span className="text-navy dark:text-white">SYSTEMIC</span>{" "}
          <span className="text-brand-gold">FITNESS</span>
        </span>
      </Link>

      <ul className="hidden md:flex items-center gap-8 list-none m-0 p-0">
        {links.map((l) => (
          <li key={l.href}>
            <Link
              href={l.href as any}
              className="text-[13px] text-navy/65 dark:text-white/60 hover:text-navy dark:hover:text-white transition-colors no-underline focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-gold rounded"
            >
              {l.label}
            </Link>
          </li>
        ))}
        <li>
          <LanguageSwitcher />
        </li>
        <li>
          <ThemeToggle />
        </li>
        <li>
          <a
            href="/get"
            className="bg-brand-gold text-white px-5 py-2 rounded-md text-[13px] font-medium no-underline transition-colors hover:bg-[#a07828] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-gold-light"
          >
            {t("cta")}
          </a>
        </li>
      </ul>

      <div className="flex md:hidden items-center gap-3">
        <LanguageSwitcher />
        <ThemeToggle />
        <button
          type="button"
          onClick={() => setOpen((v) => !v)}
          aria-expanded={open}
          aria-label="Toggle menu"
          className="w-9 h-9 flex items-center justify-center rounded-md text-navy/70 dark:text-white/70 hover:text-navy dark:hover:text-white hover:bg-navy/5 dark:hover:bg-white/10 transition-colors"
        >
          {open ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
        </button>
      </div>

      {open && (
        <div className="md:hidden absolute top-16 left-0 right-0 bg-white dark:bg-navy border-t border-[rgba(10,22,40,0.08)] dark:border-white/10 px-[5%] py-6 flex flex-col gap-4">
          {links.map((l) => (
            <Link
              key={l.href}
              href={l.href as any}
              onClick={() => setOpen(false)}
              className="text-sm text-navy/70 dark:text-white/70 hover:text-navy dark:hover:text-white no-underline"
            >
              {l.label}
            </Link>
          ))}
          <a
            href="/get"
            onClick={() => setOpen(false)}
            className="bg-brand-gold text-white text-center px-5 py-2.5 rounded-md text-sm font-medium no-underline"
          >
            {t("cta")}
          </a>
        </div>
      )}
    </nav>
  );
}
