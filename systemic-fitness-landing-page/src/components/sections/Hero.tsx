import { useTranslations } from "next-intl";
import { ArrowRight } from "lucide-react";
import { Reveal } from "../Reveal";
import { ImagePlaceholder } from "../ImagePlaceholder";
import { OptionalBgImage } from "../OptionalBgImage";

export function Hero() {
  const t = useTranslations("hero");

  const metrics = [
    { num: t("metrics.m1Num"), label: t("metrics.m1Label") },
    { num: t("metrics.m2Num"), label: t("metrics.m2Label") },
  ];

  return (
    <section className="min-h-screen bg-navy flex items-center px-[5%] pt-[120px] pb-20 relative overflow-hidden">
      {/* Optional full-bleed decorative background (renders only if file exists) */}
      <div className="absolute inset-0 opacity-25 mix-blend-luminosity pointer-events-none">
        <OptionalBgImage src="hero-background.webp" />
      </div>

      {/* Orbs */}
      <div
        className="absolute -top-[10%] -right-[5%] w-[500px] h-[500px] rounded-full pointer-events-none"
        style={{
          background:
            "radial-gradient(circle, rgba(184,146,46,0.18) 0%, transparent 70%)",
        }}
      />
      <div
        className="absolute -bottom-[10%] -left-[5%] w-[400px] h-[400px] rounded-full pointer-events-none"
        style={{
          background:
            "radial-gradient(circle, rgba(46,109,164,0.18) 0%, transparent 70%)",
        }}
      />
      {/* Grid pattern */}
      <div
        className="absolute inset-0 pointer-events-none opacity-60"
        style={{
          backgroundImage:
            "linear-gradient(rgba(255,255,255,0.035) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.035) 1px, transparent 1px)",
          backgroundSize: "60px 60px",
        }}
      />

      <div className="grid lg:grid-cols-[minmax(0,1fr)_minmax(0,460px)] gap-12 items-center w-full max-w-[1400px] mx-auto relative z-[2]">
        {/* Copy column */}
        <div className="max-w-[720px]">
          <Reveal>
            <div className="inline-flex items-center gap-2 bg-brand-gold/15 border border-brand-gold/40 text-brand-gold-light text-[11px] tracking-[0.14em] px-3.5 py-1.5 rounded-full mb-8">
              <span className="w-1.5 h-1.5 rounded-full bg-brand-gold-light" />
              {t("badge")}
            </div>
          </Reveal>
          <Reveal delay={0.1}>
            <h1 className="font-display font-normal text-white leading-[1.1] mb-6 text-hero">
              {t("headline1")}
              <br />
              {t("headline2")}{" "}
              <em className="not-italic italic text-brand-gold-light">
                {t("headlineEm")}
              </em>
            </h1>
          </Reveal>
          <Reveal delay={0.2}>
            <p className="text-[17px] text-white/60 leading-[1.7] max-w-[520px] mb-12">
              {t("sub")}
            </p>
          </Reveal>
          <Reveal delay={0.3}>
            <div className="flex gap-4 flex-wrap">
              <a
                href="/get"
                className="inline-flex items-center gap-2 bg-brand-gold text-white px-9 py-4 rounded-lg text-[15px] font-medium no-underline transition-all hover:bg-[#a07828] hover:-translate-y-px focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-gold-light focus-visible:ring-offset-2 focus-visible:ring-offset-navy"
              >
                {t("ctaPrimary")}
                <ArrowRight className="w-4 h-4" strokeWidth={2} />
              </a>
              <a
                href="#method"
                className="bg-transparent text-white/70 px-9 py-4 rounded-lg text-[15px] border border-white/25 no-underline inline-block transition-all hover:border-white/50 hover:text-white focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/40"
              >
                {t("ctaSecondary")}
              </a>
            </div>
          </Reveal>
          <Reveal delay={0.4}>
            <div className="mt-16 flex gap-12 flex-wrap">
              {metrics.map((m, idx) => (
                <div
                  key={idx}
                  className="border-l-2 border-brand-gold/40 pl-4"
                >
                  <div className="font-mono text-[28px] text-brand-gold-light">
                    {m.num}
                  </div>
                  <div className="text-xs text-white/50 mt-0.5 leading-[1.4] whitespace-pre-line">
                    {m.label}
                  </div>
                </div>
              ))}
            </div>
          </Reveal>
        </div>

        {/* Figure column */}
        <Reveal delay={0.25} className="hidden lg:block">
          <div className="relative">
            <ImagePlaceholder
              src="hero-figure-new.webp"
              alt="Systemic Fitness practitioner — editorial portrait"
              spec="Portrait 4/5 · Editorial-medical · Natural light · Subject 35-55 · Introspective tone"
              aspect="aspect-[4/5]"
              tone="dark"
              priority
            />
          </div>
        </Reveal>
      </div>
    </section>
  );
}
