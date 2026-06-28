import { useTranslations } from "next-intl";
import { Activity, HeartPulse, Waves, Zap, type LucideIcon } from "lucide-react";
import { Reveal } from "../Reveal";
import { ImagePlaceholder } from "../ImagePlaceholder";
import { TraceCard } from "../TraceCard";

type CardDef = {
  id: "c1" | "c2" | "c3" | "c4";
  color: string;
  Icon: LucideIcon;
  image: string;
  imageAlt: string;
  imageSpec: string;
};

const CARDS: readonly CardDef[] = [
  {
    id: "c1",
    color: "#E67E22",
    Icon: Activity,
    image: "signal-1-labs-rev.webp",
    imageAlt: "Close-up of medical lab report",
    imageSpec:
      "Lab report / vial close-up · 16/10 · Warm clinical, macro focus · Subtle orange accent",
  },
  {
    id: "c2",
    color: "#a51700",
    Icon: HeartPulse,
    image: "signal-2-joint-rev.webp",
    imageAlt: "Person holding knee or joint with warm light",
    imageSpec:
      "Joint / chronic care · 16/10 · Subject 45-60 hands on knee or physio-style · Natural light",
  },
  {
    id: "c3",
    color: "#8E44AD",
    Icon: Waves,
    image: "signal-3-hormonal-rev.webp",
    imageAlt: "Woman in meditative moment near window",
    imageSpec:
      "Hormonal wellbeing · 16/10 · Subject 35-50 in reflective pose · Soft warm window light",
  },
  {
    id: "c4",
    color: "#f9c509",
    Icon: Zap,
    image: "signal-4-performance-rev.webp",
    imageAlt: "Confident athlete mid-functional movement",
    imageSpec:
      "Performance / vitality · 16/10 · Mature athlete mid-movement · Studio or modern gym",
  },
];

export function Signals() {
  const t = useTranslations("signals");

  return (
    <section className="bg-white dark:bg-navy-deep py-24 px-[5%] transition-colors">
      <Reveal>
        <p className="text-[11px] font-medium tracking-[0.12em] text-brand-gray dark:text-white/50 mb-3">
          {t("tag")}
        </p>
        <h2 className="font-display font-normal text-navy dark:text-white text-[clamp(28px,4vw,44px)] leading-[1.2] mb-4">
          {t("headline1")}
          <br />
          {t("headline2")}
        </h2>
        <p className="text-base text-brand-gray dark:text-white/55 leading-[1.7] max-w-[520px] mb-14">
          {t("sub")}
        </p>
      </Reveal>

      <div className="grid gap-4 grid-cols-1 sm:grid-cols-2 lg:grid-cols-4">
        {CARDS.map((card, idx) => {
          const Icon = card.Icon;
          return (
            <Reveal key={card.id} delay={idx * 0.08}>
              <TraceCard
                color={card.color}
                className="h-full bg-warm-white dark:bg-white/5 border border-[rgba(10,22,40,0.12)] dark:border-white/10 rounded-2xl overflow-hidden relative transition-all hover:-translate-y-0.5 hover:shadow-[0_8px_32px_rgba(10,22,40,0.08)]"
              >
                <div
                  className="absolute top-0 left-0 right-0 h-[3px] z-[2]"
                  style={{ background: card.color }}
                />
                <ImagePlaceholder
                  src={card.image}
                  alt={card.imageAlt}
                  spec={card.imageSpec}
                  aspect="aspect-[16/10]"
                  className="rounded-none"
                  tone="light"
                />
                <div className="px-6 py-6">
                  <div
                    className="w-9 h-9 rounded-lg flex items-center justify-center mb-4"
                    style={{
                      background: `${card.color}1a`,
                      color: card.color,
                    }}
                  >
                    <Icon className="w-[18px] h-[18px]" strokeWidth={1.75} />
                  </div>
                  <div className="text-[15px] font-medium text-navy dark:text-white mb-2 leading-[1.4]">
                    {t(`cards.${card.id}Title` as const)}
                  </div>
                  <div className="text-[13px] text-brand-gray dark:text-white/55 leading-[1.6]">
                    {t(`cards.${card.id}Desc` as const)}
                  </div>
                </div>
              </TraceCard>
            </Reveal>
          );
        })}
      </div>
    </section>
  );
}
