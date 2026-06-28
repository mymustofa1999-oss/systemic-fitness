"use client";

import { useTranslations } from "next-intl";
import { AnimatePresence, motion } from "framer-motion";
import { Check, Sparkles } from "lucide-react";
import { useState } from "react";
import { Reveal } from "../Reveal";
import { TraceCard } from "../TraceCard";

type CtaStyle = "outline" | "solid" | "gold";
type Period = "monthly" | "yearly";

const PRICES: Array<{
  id: "pr1" | "pr2" | "pr3" | "pr4";
  featured: boolean;
  ctaStyle: CtaStyle;
  hasYearly: boolean;
  featureCount: number;
}> = [
  { id: "pr1", featured: false, ctaStyle: "outline", hasYearly: false, featureCount: 3 },
  { id: "pr2", featured: false, ctaStyle: "outline", hasYearly: true, featureCount: 7 },
  { id: "pr3", featured: true, ctaStyle: "solid", hasYearly: true, featureCount: 7 },
  { id: "pr4", featured: false, ctaStyle: "gold", hasYearly: true, featureCount: 10 },
];

const ctaClasses: Record<CtaStyle, string> = {
  outline:
    "border border-[rgba(10,22,40,0.12)] dark:border-white/15 text-navy dark:text-white hover:bg-warm-white dark:hover:bg-white/5",
  solid: "bg-navy text-white hover:bg-navy-mid",
  gold: "bg-brand-gold text-white hover:bg-[#a07828]",
};

export function Pricing() {
  const t = useTranslations("pricing");
  const [period, setPeriod] = useState<Period>("monthly");
  const showPrices = false;

  return (
    <section
      id="pricing"
      className="bg-white dark:bg-navy py-24 px-[5%] transition-colors"
    >
      <Reveal>
        <div className="max-w-[560px]">
          <p className="text-[11px] font-medium tracking-[0.12em] text-brand-gray dark:text-white/50 mb-3">
            {t("tag")}
          </p>
          <h2 className="font-display font-normal text-navy dark:text-white text-[clamp(28px,4vw,44px)] leading-[1.2] mb-4">
            {t("headline1")}
            <br />
            {t("headline2")}
          </h2>
          <p className="text-base text-brand-gray dark:text-white/55 leading-[1.7] max-w-[520px]">
            {t("sub")}
          </p>
        </div>
      </Reveal>

      {showPrices && (
        <>
          {/* Persistent discount banner — always visible */}
          <Reveal>
            <div className="mt-10 flex justify-center">
              <div className="inline-flex items-center gap-2.5 bg-brand-gold/10 dark:bg-brand-gold/15 border border-brand-gold/40 rounded-full px-5 py-2.5">
                <Sparkles
                  className="w-4 h-4 text-brand-gold"
                  strokeWidth={1.75}
                />
                <span className="text-[13px] font-medium text-brand-gold tracking-tight">
                  {t("discountBanner")}
                </span>
              </div>
            </div>
          </Reveal>

          {/* Period toggle with persistent yearly badge */}
          <Reveal>
            <div className="mt-5 flex items-center justify-center">
              <div
                role="tablist"
                aria-label="Billing period"
                className="relative inline-flex items-center bg-warm-white dark:bg-white/5 border border-[rgba(10,22,40,0.1)] dark:border-white/10 rounded-full p-1"
              >
                {(["monthly", "yearly"] as const).map((p) => {
                  const active = period === p;
                  const isYearly = p === "yearly";
                  return (
                    <button
                      key={p}
                      type="button"
                      role="tab"
                      aria-selected={active}
                      onClick={() => setPeriod(p)}
                      className="relative z-[1] px-6 py-2.5 text-[13px] font-medium rounded-full transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-gold"
                    >
                      {active && (
                        <motion.span
                          layoutId="period-pill"
                          className="absolute inset-0 bg-navy dark:bg-brand-gold rounded-full -z-[1]"
                          transition={{ type: "spring", stiffness: 400, damping: 30 }}
                        />
                      )}
                      <span
                        className={`relative flex items-center gap-2 ${
                          active
                            ? "text-white"
                            : "text-navy/70 dark:text-white/70"
                        }`}
                      >
                        {isYearly ? t("toggleYearly") : t("toggleMonthly")}
                        {isYearly && (
                          <span
                            className={`text-[10px] font-semibold px-1.5 py-0.5 rounded-full tracking-wide ${
                              active
                                ? "bg-white/20 text-white"
                                : "bg-brand-teal/15 dark:bg-[#5DCAA5]/15 text-brand-teal dark:text-[#5DCAA5]"
                            }`}
                          >
                            {t("toggleYearlyBadge")}
                          </span>
                        )}
                      </span>
                    </button>
                  );
                })}
              </div>
            </div>
          </Reveal>

          <div className="grid gap-4 grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 mt-12">
            {PRICES.map((p, idx) => {
              const features = Array.from({ length: p.featureCount }, (_, i) =>
                t(`cards.${p.id}F${i + 1}` as const)
              );
              const showYearly = period === "yearly" && p.hasYearly;
              const amount = showYearly
                ? t(`cards.${p.id}AmountYearly` as const)
                : t(`cards.${p.id}Amount` as const);
              const per = showYearly
                ? t(`cards.${p.id}PerYearly` as const)
                : t(`cards.${p.id}Per` as const);
              const equiv = showYearly
                ? t(`cards.${p.id}EquivYearly` as const)
                : null;
              const originalYearly = showYearly
                ? t(`cards.${p.id}OriginalYearly` as const)
                : null;
              const savingsYearly = showYearly
                ? t(`cards.${p.id}SavingsYearly` as const)
                : null;

              return (
                <Reveal key={p.id} delay={idx * 0.08}>
                  <TraceCard
                    color={
                      p.featured
                        ? "rgba(46,109,164,0.95)"
                        : "rgba(212, 168, 75, 0.95)"
                    }
                    className={`h-full rounded-2xl overflow-hidden transition-all hover:-translate-y-0.5 bg-white dark:bg-white/5 ${
                      p.featured
                        ? "border-[1.5px] border-brand-blue shadow-[0_8px_32px_rgba(46,109,164,0.15)]"
                        : "border border-[rgba(10,22,40,0.12)] dark:border-white/10"
                    }`}
                  >
                    <div className="px-6 pt-6 pb-5 border-b border-[rgba(10,22,40,0.12)] dark:border-white/10">
                      {p.featured && (
                        <div className="inline-block bg-light-blue dark:bg-brand-blue/15 text-[#185FA5] dark:text-brand-blue text-[10px] font-medium tracking-[0.08em] px-2.5 py-[3px] rounded-full mb-2.5">
                          {t("popular")}
                        </div>
                      )}
                      <div className="text-base font-medium text-navy dark:text-white mb-1">
                        {t(`cards.${p.id}Name` as const)}
                      </div>
                      <div className="text-xs text-brand-gray dark:text-white/50 mb-4 leading-[1.4] whitespace-pre-line">
                        {t(`cards.${p.id}For` as const)}
                      </div>

                      <AnimatePresence mode="wait">
                        <motion.div
                          key={period + p.id}
                          initial={{ opacity: 0, y: 6 }}
                          animate={{ opacity: 1, y: 0 }}
                          exit={{ opacity: 0, y: -6 }}
                          transition={{ duration: 0.22 }}
                        >
                          {originalYearly && (
                            <div className="font-mono text-[13px] text-brand-gray/70 dark:text-white/35 line-through leading-none mb-1">
                              {originalYearly}
                            </div>
                          )}
                          <div className="flex items-baseline gap-2">
                            <span className="font-mono text-[28px] text-navy dark:text-white leading-none">
                              {amount}
                            </span>
                            <span className="text-sm font-sans text-brand-gray dark:text-white/50">
                              {per}
                            </span>
                          </div>
                          {equiv && (
                            <div className="mt-1.5 font-mono text-[11px] text-brand-teal dark:text-[#5DCAA5]">
                              {equiv}
                            </div>
                          )}
                          {savingsYearly && (
                            <div className="mt-3 inline-flex items-center gap-1.5 bg-brand-teal text-white dark:bg-[#5DCAA5] dark:text-navy rounded-md px-3 py-2 text-[13px] font-semibold leading-none shadow-[0_4px_14px_rgba(11,92,92,0.25)]">
                              <Sparkles
                                className="w-3.5 h-3.5"
                                strokeWidth={2}
                              />
                              {savingsYearly}
                            </div>
                          )}
                        </motion.div>
                      </AnimatePresence>
                    </div>

                    <div className="px-6 pt-5 pb-6">
                      {features.map((feat, fi) => (
                        <div
                          key={fi}
                          className="flex items-start gap-2 text-[13px] text-charcoal dark:text-white/80 mb-2 leading-[1.5]"
                        >
                          <Check
                            className="w-4 h-4 text-brand-teal dark:text-[#5DCAA5] flex-shrink-0 mt-0.5"
                            strokeWidth={2.25}
                          />
                          <span>{feat}</span>
                        </div>
                      ))}
                      <a
                        href="/register"
                        className={`block text-center mt-5 py-[11px] rounded-lg text-[13px] font-medium no-underline transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-gold ${ctaClasses[p.ctaStyle]}`}
                      >
                        {t(`cards.${p.id}Cta` as const)}
                      </a>
                    </div>
                  </TraceCard>
                </Reveal>
              );
            })}
          </div>
        </>
      )}
    </section>
  );
}
