import { useLocale, useTranslations } from "next-intl";
import { Building2, Quote, Stethoscope, Award, type LucideIcon } from "lucide-react";
import { Reveal } from "../Reveal";
import { ImagePlaceholder } from "../ImagePlaceholder";
import { getWhatsAppUrl } from "@/lib/whatsapp";

type ItemDef = { id: "i1" | "i2" | "i3"; Icon: LucideIcon };

const ITEMS: readonly ItemDef[] = [
  { id: "i1", Icon: Stethoscope },
  { id: "i2", Icon: Building2 },
  { id: "i3", Icon: Award },
];

export function Partner() {
  const t = useTranslations("partner");
  const locale = useLocale();
  const waUrl = getWhatsAppUrl(locale);

  return (
    <section
      id="partner"
      className="bg-warm-white dark:bg-navy-deep py-24 px-[5%] border-t border-[rgba(10,22,40,0.12)] dark:border-white/10 transition-colors"
    >
      <div className="grid grid-cols-1 md:grid-cols-2 gap-16 items-center">
        <Reveal>
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
          <div className="flex flex-col gap-3 mt-8">
            {ITEMS.map((item) => {
              const Icon = item.Icon;
              return (
                <div
                  key={item.id}
                  className="flex items-start gap-3.5 bg-white dark:bg-white/5 border border-[rgba(10,22,40,0.12)] dark:border-white/10 rounded-xl px-5 py-4"
                >
                  <div className="w-10 h-10 rounded-lg bg-light-blue dark:bg-brand-blue/15 flex items-center justify-center text-brand-blue flex-shrink-0">
                    <Icon className="w-5 h-5" strokeWidth={1.75} />
                  </div>
                  <div>
                    <strong className="block text-sm text-navy dark:text-white font-medium mb-[3px]">
                      {t(`items.${item.id}Title` as const)}
                    </strong>
                    <span className="text-xs text-brand-gray dark:text-white/60 leading-[1.5]">
                      {t(`items.${item.id}Desc` as const)}
                    </span>
                  </div>
                </div>
              );
            })}
          </div>
          <div className="mt-8 bg-white dark:bg-white/5 border border-[rgba(10,22,40,0.12)] dark:border-white/10 rounded-xl p-6 flex items-center justify-between gap-4 flex-wrap">
            <p className="text-sm text-charcoal dark:text-white/80 leading-[1.5]">
              <strong className="text-navy dark:text-white font-medium">
                {t("ctaText")}
              </strong>
              {t("ctaSub") ? (
                <>
                  <br />
                  {t("ctaSub")}
                </>
              ) : null}
            </p>
            <a
              href={waUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="bg-navy text-white px-5 py-2.5 rounded-md text-[13px] font-medium no-underline whitespace-nowrap transition-colors hover:bg-navy-mid focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-gold"
            >
              {t("ctaBtn")}
            </a>
          </div>
        </Reveal>

        <Reveal delay={0.1}>
          <div className="flex flex-col gap-6">
            <ImagePlaceholder
              alt="Founder portrait placeholder"
              spec="Portrait founder Citra Hann · 1:1 editorial · Lihat public/images/README.md"
              aspect="aspect-square"
              src="founder.webp"
            />
            <div className="bg-navy rounded-2xl p-10 relative">
              <Quote
                className="absolute top-6 right-6 w-6 h-6 text-brand-gold/40"
                strokeWidth={1.5}
              />
              <div className="text-[11px] font-medium tracking-[0.12em] text-brand-gold-light mb-5">
                {t("quoteTag")}
              </div>
              <div className="font-display italic text-[22px] font-normal text-white leading-[1.5] mb-6">
                {t("quoteText")}
              </div>
              <div className="text-[13px] text-white/45 pt-5 border-t border-white/10">
                <strong className="text-white/70 font-medium block mb-0.5">
                  {t("quoteName")}
                </strong>
                {t("quoteRole")}
                <br />
                {t("quoteCompany")}
              </div>
            </div>
          </div>
        </Reveal>
      </div>
    </section>
  );
}
