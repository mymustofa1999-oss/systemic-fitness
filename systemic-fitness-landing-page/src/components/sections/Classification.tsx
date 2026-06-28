import { useTranslations } from "next-intl";
import {
  ShieldCheck,
  Droplets,
  HeartPulse,
  Flame,
  Bone,
  type LucideIcon,
} from "lucide-react";
import { Reveal } from "../Reveal";
import { TraceCard } from "../TraceCard";

type CardDef = {
  id: "immune" | "renal" | "cardio" | "metabolic" | "musculo";
  color: string;
  Icon: LucideIcon;
};

const CARDS: readonly CardDef[] = [
  { id: "immune", color: "#5DCAA5", Icon: ShieldCheck },
  { id: "renal", color: "#85B7EB", Icon: Droplets },
  { id: "cardio", color: "#a51700", Icon: HeartPulse },
  { id: "metabolic", color: "#f9c509", Icon: Flame },
  { id: "musculo", color: "#8E44AD", Icon: Bone },
];

export function Classification() {
  const t = useTranslations("classification");

  return (
    <section className="bg-warm-white dark:bg-navy py-24 px-[5%] transition-colors">
      <Reveal>
        <div className="max-w-[880px] mb-14">
          <p className="text-[11px] font-medium tracking-[0.12em] text-brand-gray dark:text-white/50 mb-3">
            {t("tag")}
          </p>
          <h2 className="font-display font-normal text-navy dark:text-white text-[clamp(28px,4vw,44px)] leading-[1.2] mb-4">
            {t("headline1")}{" "}
            {t("headline2")}
          </h2>
          <p className="text-base text-brand-gray dark:text-white/55 leading-[1.7] max-w-[560px]">
            {t("sub")}
          </p>
        </div>
      </Reveal>

      <div className="grid gap-4 grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5">
        {CARDS.map((card, idx) => {
          const Icon = card.Icon;
          return (
            <Reveal key={card.id} delay={idx * 0.06}>
              <TraceCard
                color={card.color}
                className="h-full bg-white dark:bg-white/5 border border-[rgba(10,22,40,0.12)] dark:border-white/10 rounded-2xl px-6 py-7 transition-all hover:-translate-y-0.5 hover:shadow-[0_8px_32px_rgba(10,22,40,0.08)]"
              >
                <div
                  className="w-10 h-10 rounded-lg flex items-center justify-center mb-4"
                  style={{
                    background: `${card.color}1a`,
                    color: card.color,
                  }}
                >
                  <Icon className="w-5 h-5" strokeWidth={1.75} />
                </div>
                <div className="text-[15px] font-medium text-navy dark:text-white mb-2 leading-[1.4]">
                  {t(`cards.${card.id}Title` as const)}
                </div>
                <div className="text-[13px] text-brand-gray dark:text-white/60 leading-[1.6]">
                  {t(`cards.${card.id}Desc` as const)}
                </div>
              </TraceCard>
            </Reveal>
          );
        })}
      </div>
    </section>
  );
}
