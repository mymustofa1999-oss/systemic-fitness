"use client";

import { useTranslations } from "next-intl";
import { motion } from "framer-motion";
import { ArrowRight } from "lucide-react";
import { Reveal } from "../Reveal";

const BARS = [
  { label: "barMove", value: 83, color: "#f9c509" },
  { label: "barNutrition", value: 79, color: "#a51700" },
  { label: "barRest", value: 80, color: "#2b2b2b" },
] as const;

const DOMAINS = [
  { label: "domainExercise", desc: "domainExerciseDesc", color: "#f9c509" },
  { label: "domainNutrition", desc: "domainNutritionDesc", color: "#a51700" },
  { label: "domainRest", desc: "domainRestDesc", color: "#2b2b2b" },
  { label: "domainUpdate", desc: "domainUpdateDesc", color: "#fdd84a" },
] as const;

export function Score() {
  const t = useTranslations("score");

  return (
    <section className="bg-navy py-24 px-[5%] relative overflow-hidden">
      <div
        className="absolute top-0 right-[5%] w-[400px] h-[400px] rounded-full pointer-events-none opacity-40"
        style={{
          background:
            "radial-gradient(circle, rgba(184,146,46,0.12) 0%, transparent 70%)",
        }}
      />
      <div className="grid grid-cols-1 md:grid-cols-2 gap-16 md:gap-20 items-center relative z-[2]">
        <Reveal>
          <div className="bg-white/[0.05] border border-white/10 rounded-[20px] p-8 md:p-10 backdrop-blur-sm">
            <div className="flex items-center gap-6 mb-8">
              <div className="w-[100px] h-[100px] rounded-full border-[3px] border-brand-gold flex flex-col items-center justify-center flex-shrink-0 relative">
                <div
                  className="absolute inset-0 rounded-full"
                  style={{
                    background:
                      "radial-gradient(circle, rgba(184,146,46,0.15) 0%, transparent 70%)",
                  }}
                />
                <div className="font-mono text-[32px] text-brand-gold-light leading-none relative">
                  81
                </div>
                <div className="text-[10px] text-[rgba(212,168,75,0.6)] tracking-[0.1em] mt-[3px] relative">
                  {t("word")}
                </div>
              </div>
              <div className="flex-1 flex flex-col gap-3">
                {BARS.map((bar) => (
                  <div key={bar.label} className="flex items-center gap-3">
                    <div className="text-xs text-white/55 w-16 flex-shrink-0">
                      {t(bar.label)}
                    </div>
                    <div className="flex-1 h-1.5 bg-white/10 rounded-[3px] overflow-hidden">
                      <motion.div
                        initial={{ width: 0 }}
                        whileInView={{ width: `${bar.value}%` }}
                        viewport={{ once: true, margin: "-40px" }}
                        transition={{ duration: 1.1, ease: "easeOut" }}
                        className="h-full rounded-[3px]"
                        style={{ background: bar.color }}
                      />
                    </div>
                    <div className="font-mono text-xs text-white/60 w-6 text-right">
                      {bar.value}
                    </div>
                  </div>
                ))}
              </div>
            </div>
            <div className="grid grid-cols-2 gap-2.5">
              {DOMAINS.map((d) => (
                <div
                  key={d.label}
                  className="bg-white/[0.04] border border-white/10 rounded-[10px] px-3.5 py-3 flex items-center gap-2.5"
                >
                  <div
                    className="w-2 h-2 rounded-full flex-shrink-0"
                    style={{ background: d.color }}
                  />
                  <div className="text-xs text-white/60 leading-[1.4]">
                    <strong className="block text-white/85 text-[13px] font-medium">
                      {t(d.label)}
                    </strong>
                    {t(d.desc)}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </Reveal>

        <Reveal delay={0.1}>
          <p className="text-[11px] font-medium tracking-[0.12em] text-brand-gold-light mb-3">
            {t("tag")}
          </p>
          <h2 className="font-display font-normal text-white text-[clamp(28px,4vw,42px)] leading-[1.2] mb-5">
            {t("headline1")}
            <br />
            {t("headline2")}
          </h2>
          <p className="text-base text-white/55 leading-[1.7] max-w-[520px] mb-8">
            {t("sub")}
          </p>
          <div className="bg-white/[0.05] border-l-[3px] border-brand-gold rounded-r-[10px] px-5 py-4 mb-8">
            <p className="text-sm text-white/75 leading-[1.6]">
              <strong className="text-brand-gold-light">{t("formulaTop")}</strong>
              <br />
              {t("formulaBottom")}
            </p>
          </div>
          <a
            href="/get"
            className="inline-flex items-center gap-2 bg-brand-gold text-white px-9 py-4 rounded-lg text-[15px] font-medium no-underline transition-all hover:bg-[#a07828] hover:-translate-y-px focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-gold-light focus-visible:ring-offset-2 focus-visible:ring-offset-navy"
          >
            {t("cta")}
            <ArrowRight className="w-4 h-4" strokeWidth={2} />
          </a>
        </Reveal>
      </div>
    </section>
  );
}
