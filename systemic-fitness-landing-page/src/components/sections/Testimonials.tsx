import { useTranslations } from "next-intl";
import fs from "node:fs";
import path from "node:path";
import { Reveal } from "../Reveal";
import {
  TestimonialsMarquee,
  type ResolvedTestimonial,
} from "../TestimonialsMarquee";

const TESTIMONIAL_IDS = ["t1", "t2", "t3", "t4", "t5"] as const;

function resolveImage(filename: string): string | null {
  try {
    const abs = path.join(process.cwd(), "public", "images", filename);
    return fs.existsSync(abs) ? `/images/${filename}` : null;
  } catch {
    return null;
  }
}

export function Testimonials() {
  const t = useTranslations("testimonials");

  const items: ResolvedTestimonial[] = TESTIMONIAL_IDS.map((id) => {
    const filename = t(`items.${id}Image` as const);
    return {
      id,
      name: t(`items.${id}Name` as const),
      role: t(`items.${id}Role` as const),
      title: t(`items.${id}Title` as const),
      desc: t(`items.${id}Desc` as const),
      imageSrc: resolveImage(filename),
    };
  });

  return (
    <section
      id="testimonials"
      className="bg-warm-white dark:bg-navy py-24 border-t border-[rgba(10,22,40,0.08)] dark:border-white/5 transition-colors overflow-hidden"
    >
      <div className="px-[5%]">
        <Reveal>
          <div className="max-w-[620px] mb-14">
            <p className="text-[11px] font-medium tracking-[0.12em] text-brand-gray dark:text-white/50 mb-3">
              {t("tag")}
            </p>
            <h2 className="font-display font-normal text-navy dark:text-white text-[clamp(28px,4vw,44px)] leading-[1.2] mb-4">
              {t("headline1")}
              <br />
              {t("headline2")}
            </h2>
            <p className="text-base text-brand-gray dark:text-white/55 leading-[1.7] max-w-[540px]">
              {t("sub")}
            </p>
          </div>
        </Reveal>
      </div>

      <Reveal>
        <TestimonialsMarquee items={items} ratingLabel={t("ratingLabel")} />
      </Reveal>
    </section>
  );
}
