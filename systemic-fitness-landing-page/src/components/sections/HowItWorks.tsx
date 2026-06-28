import { useTranslations } from "next-intl";
import { Reveal } from "../Reveal";

const STEPS = [
  { id: "s1", bg: "#2b2b2b" },
  { id: "s2", bg: "#2b2b2b" },
  { id: "s3", bg: "#a51700" },
  { id: "s4", bg: "#f9c509" },
] as const;

export function HowItWorks() {
  const t = useTranslations("how");

  return (
    <section className="bg-white dark:bg-navy-deep py-24 px-[5%] transition-colors">
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
        </div>
      </Reveal>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-0 mt-14 relative">
        <div
          className="hidden lg:block absolute top-7 left-[14%] right-[14%] h-px bg-[rgba(10,22,40,0.12)] dark:bg-white/15"
        />
        {STEPS.map((step, idx) => (
          <Reveal key={step.id} delay={idx * 0.12}>
            <div className="text-center px-5 relative py-4 lg:py-0">
              <div
                className="w-14 h-14 rounded-full text-white font-mono text-lg flex items-center justify-center mx-auto mb-5 relative z-[1] shadow-[0_4px_16px_rgba(10,22,40,0.15)]"
                style={{ background: step.bg }}
              >
                {idx + 1}
              </div>
              <div className="text-[15px] font-medium text-navy dark:text-white mb-2">
                {t(`steps.${step.id}Title` as const)}
              </div>
              <div className="text-[13px] text-brand-gray dark:text-white/55 leading-[1.6]">
                {t(`steps.${step.id}Desc` as const)}
              </div>
            </div>
          </Reveal>
        ))}
      </div>
    </section>
  );
}
