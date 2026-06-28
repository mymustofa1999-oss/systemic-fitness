import type { CSSProperties } from "react";
import { useTranslations } from "next-intl";
import { Reveal } from "../Reveal";
import { ImagePlaceholder } from "../ImagePlaceholder";
import { TraceCard } from "../TraceCard";

type ProgramDef = {
  id: "p1" | "p2" | "p3";
  tierBg: string;
  tierColor: string;
  tierColorDark: string;
  image: string;
  imageAlt: string;
  imageSpec: string;
};

const PROGRAMS: readonly ProgramDef[] = [
  {
    id: "p1",
    tierBg: "rgba(46,109,164,0.1)",
    tierColor: "#185FA5",
    tierColorDark: "#85B7EB",
    image: "level1.webp",
    imageAlt: "Person performing controlled movement in a clinical setting",
    imageSpec:
      "Controlled movement · 3/4 portrait · Home or clinic, warm light · Subject 40-60",
  },
  {
    id: "p2",
    tierBg: "rgba(11,92,92,0.1)",
    tierColor: "#2b2b2b",
    tierColorDark: "#5DCAA5",
    image: "level2.webp",
    imageAlt: "Morning functional movement outdoors",
    imageSpec:
      "Preventive training outdoor · 3/4 · Morning mist · Subject 30-45",
  },
  {
    id: "p3",
    tierBg: "rgba(184,146,46,0.12)",
    tierColor: "#7A5000",
    tierColorDark: "#fdd84a",
    image: "level3.webp",
    imageAlt: "Mature athlete performing strength training",
    imageSpec:
      "Mature athlete strength training · 3/4 · Studio · Subject 45-60",
  },
];

export function Programs() {
  const t = useTranslations("programs");

  return (
    <section
      id="programs"
      className="bg-warm-white dark:bg-navy py-24 px-[5%] transition-colors"
    >
      <Reveal>
        <div className="max-w-[600px] mb-14">
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

      <div className="grid gap-5 grid-cols-1 md:grid-cols-2 lg:grid-cols-3">
        {PROGRAMS.map((prog, idx) => (
          <Reveal key={prog.id} delay={idx * 0.1}>
            <TraceCard
              color={prog.tierColor}
              className="h-full bg-white dark:bg-white/5 border border-[rgba(10,22,40,0.12)] dark:border-white/10 rounded-2xl overflow-hidden transition-all hover:-translate-y-[3px] hover:shadow-[0_12px_40px_rgba(10,22,40,0.1)]"
            >
              <ImagePlaceholder
                src={prog.image}
                alt={prog.imageAlt}
                spec={prog.imageSpec}
                aspect="aspect-[4/3]"
                className="rounded-none"
              />
              <div className="px-7 pt-6 pb-5 border-b border-[rgba(10,22,40,0.12)] dark:border-white/10">
                <div
                  className="inline-block text-[10px] font-medium tracking-[0.1em] px-2.5 py-1 rounded-full mb-3.5 text-[var(--tier-color)] dark:text-[var(--tier-color-dark)]"
                  style={
                    {
                      background: prog.tierBg,
                      "--tier-color": prog.tierColor,
                      "--tier-color-dark": prog.tierColorDark,
                    } as CSSProperties
                  }
                >
                  {t(`cards.${prog.id}Tier` as const)}
                </div>
                <div className="font-display font-normal text-xl text-navy dark:text-white mb-2 leading-[1.3]">
                  {t(`cards.${prog.id}Name` as const)}
                </div>
                <div className="text-[13px] text-brand-gray dark:text-white/55 leading-[1.6]">
                  {t(`cards.${prog.id}Desc` as const)}
                </div>
              </div>
              <div className="px-7 pt-5 pb-6">
                {[1, 2, 3, 4].map((n) => (
                  <div
                    key={n}
                    className="flex items-start gap-2.5 mb-2.5 text-[13px] text-charcoal dark:text-white/80"
                  >
                    <span className="text-brand-gray dark:text-white/40 flex-shrink-0 mt-0.5">
                      —
                    </span>
                    <span>
                      {t(`cards.${prog.id}F${n}` as const)}
                    </span>
                  </div>
                ))}
              </div>
            </TraceCard>
          </Reveal>
        ))}
      </div>
    </section>
  );
}
