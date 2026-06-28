import { useTranslations } from "next-intl";
import { ArrowRight } from "lucide-react";
import { Reveal } from "../Reveal";
import { OptionalBgImage } from "../OptionalBgImage";
import { StoreBadges } from "../StoreBadges";

export function FinalCta() {
  const t = useTranslations("finalCta");

  return (
    <section
      id="assessment"
      className="bg-navy py-32 px-[5%] text-center relative overflow-hidden"
    >
      {/* Optional atmospheric background image (silently no-ops if file missing) */}
      <div className="absolute inset-0 opacity-30 mix-blend-luminosity pointer-events-none">
        <OptionalBgImage src="final-cta-background.webp" />
      </div>

      <div
        className="absolute left-1/2 -translate-x-1/2 -top-[30%] w-[600px] h-[600px] rounded-full pointer-events-none opacity-50"
        style={{
          background:
            "radial-gradient(circle, rgba(184,146,46,0.15) 0%, transparent 70%)",
        }}
      />
      <div
        className="absolute left-[10%] bottom-0 w-[400px] h-[400px] rounded-full pointer-events-none opacity-40"
        style={{
          background:
            "radial-gradient(circle, rgba(46,109,164,0.15) 0%, transparent 70%)",
        }}
      />

      <Reveal>
        <div className="relative z-[2] max-w-[640px] mx-auto">
          <p className="text-[11px] font-medium tracking-[0.14em] text-brand-gold-light mb-5">
            {t("tag")}
          </p>
          <h2 className="font-display font-normal text-white text-[clamp(32px,5vw,52px)] leading-[1.2] mb-5">
            {t("headline1")}
            {t("headline2") ? (
              <>
                <br />
                {t("headline2")}
              </>
            ) : null}{" "}
            <em className="not-italic italic text-brand-gold-light">
              {t("headlineEm")}
            </em>
          </h2>
          <p className="text-base text-white/55 leading-[1.7] mb-12">
            {t("sub")}
          </p>
          <div className="flex gap-4 justify-center flex-wrap">
            <a
              href="/get"
              className="inline-flex items-center gap-2 bg-brand-gold text-white text-base px-11 py-[18px] rounded-lg font-medium no-underline transition-all hover:bg-[#a07828] hover:-translate-y-px focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-gold-light focus-visible:ring-offset-2 focus-visible:ring-offset-navy"
            >
              {t("cta")}
              <ArrowRight className="w-4 h-4" strokeWidth={2} />
            </a>
          </div>

          <div className="mt-10 flex flex-col items-center gap-3">
            <span className="text-[11px] tracking-[0.14em] text-white/45 uppercase">
              {t("download")}
            </span>
            <StoreBadges align="center" />
          </div>

          <p className="mt-8 text-[13px] text-white/35">{t("note")}</p>
        </div>
      </Reveal>
    </section>
  );
}
