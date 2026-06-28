import { useTranslations } from "next-intl";
import { Dumbbell, GitBranch, Heart, Wind, type LucideIcon } from "lucide-react";
import { Reveal } from "../Reveal";

type VariableDef = {
  id: "v1" | "v2" | "v3" | "v4";
  num: string;
  color: string;
  Icon: LucideIcon;
};

const VARIABLES: readonly VariableDef[] = [
  { id: "v1", num: "01", color: "#a51700", Icon: Dumbbell },
  { id: "v2", num: "02", color: "#2b2b2b", Icon: GitBranch },
  { id: "v3", num: "03", color: "#f9c509", Icon: Heart },
  { id: "v4", num: "04", color: "#5B2D8E", Icon: Wind },
];

const PILLAR_DETAILS = [
  { id: "fc", num: "01", color: "#5DCAA5", border: "rgba(11,92,92,0.4)" },
  { id: "cc", num: "02", color: "#85B7EB", border: "rgba(46,109,164,0.4)" },
  { id: "mc", num: "03", color: "#fdd84a", border: "rgba(184,146,46,0.4)" },
] as const;

export function Method() {
  const t = useTranslations("method");

  return (
    <section
      id="method"
      className="bg-navy py-24 px-[5%] relative overflow-hidden"
    >
      <div
        className="absolute -top-[10%] -right-[5%] w-[500px] h-[500px] rounded-full pointer-events-none opacity-40"
        style={{
          background:
            "radial-gradient(circle, rgba(184,146,46,0.12) 0%, transparent 70%)",
        }}
      />
      <div
        className="absolute bottom-[10%] -left-[5%] w-[400px] h-[400px] rounded-full pointer-events-none opacity-30"
        style={{
          background:
            "radial-gradient(circle, rgba(46,109,164,0.15) 0%, transparent 70%)",
        }}
      />

      <div className="grid grid-cols-1 md:grid-cols-2 gap-16 md:gap-20 items-start relative z-[2]">
        <Reveal>
          <p className="text-[11px] font-medium tracking-[0.12em] text-brand-gold-light mb-3">
            {t("tag")}
          </p>
          <h2 className="font-display font-normal text-white text-[clamp(28px,4vw,44px)] leading-[1.2] mb-4">
            {t("headline1")}
            <br />
            {t("headline2")}
          </h2>
          <p className="text-base text-white/55 leading-[1.7] max-w-[520px]">
            {t("sub")}
          </p>
          <div className="bg-brand-gold/10 border border-brand-gold/30 rounded-[10px] px-6 py-5 mt-8">
            <p className="font-display italic text-[17px] text-brand-gold-light leading-[1.5]">
              {t("quote")}
            </p>
            <span className="block mt-2 text-xs text-white/45 font-sans not-italic">
              {t("quoteAuthor")}
            </span>
          </div>
        </Reveal>

        <div>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 mb-8">
            {PILLAR_DETAILS.map((p, idx) => (
              <Reveal key={p.id} delay={idx * 0.1}>
                <div
                  className="h-full bg-white/[0.04] border border-white/10 rounded-2xl p-5 relative overflow-hidden"
                  style={{ borderTop: `2px solid ${p.color}` }}
                >
                  <div className="flex items-baseline gap-2 mb-3">
                    <span
                      className="font-mono text-[11px]"
                      style={{ color: p.color }}
                    >
                      {p.num}
                    </span>
                    <h3 className="font-display text-white text-[15px] leading-[1.3]">
                      {t(`pillarDetails.${p.id}Title` as const)}
                    </h3>
                  </div>
                  <p className="text-[12px] text-white/75 leading-[1.55] mb-2">
                    {t(`pillarDetails.${p.id}Subtitle` as const)}
                  </p>
                  <p className="text-[12px] text-white/55 leading-[1.65]">
                    {t(`pillarDetails.${p.id}Desc` as const)}
                  </p>
                </div>
              </Reveal>
            ))}
          </div>

          <p className="text-sm font-medium text-white mb-4">
            {t("variablesIntro")}
          </p>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            {VARIABLES.map((v, idx) => {
              const Icon = v.Icon;
              return (
                <Reveal key={v.id} delay={idx * 0.08}>
                  <div className="h-full bg-white/[0.05] border border-white/10 rounded-xl px-4 py-5 relative overflow-hidden">
                    <div
                      className="absolute top-0 left-0 right-0 h-0.5"
                      style={{ background: v.color }}
                    />
                    <div className="flex items-start justify-between mb-3">
                      <div className="font-mono text-[11px] text-white/25">
                        {v.num}
                      </div>
                      <div
                        className="w-8 h-8 rounded-md flex items-center justify-center"
                        style={{
                          background: `${v.color}22`,
                          color: v.color,
                        }}
                      >
                        <Icon className="w-4 h-4" strokeWidth={1.75} />
                      </div>
                    </div>
                    <div className="text-sm font-medium text-white mb-1.5">
                      {t(`variables.${v.id}Name` as const)}
                    </div>
                    <div className="text-xs text-white/55 leading-[1.55]">
                      {t(`variables.${v.id}Desc` as const)}
                    </div>
                  </div>
                </Reveal>
              );
            })}
          </div>
        </div>
      </div>
    </section>
  );
}
