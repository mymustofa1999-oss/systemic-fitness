"use client";

import Image from "next/image";
import { Star, User } from "lucide-react";

export type ResolvedTestimonial = {
  id: string;
  name: string;
  role: string;
  title: string;
  desc: string;
  imageSrc: string | null;
};

interface Props {
  items: ResolvedTestimonial[];
  ratingLabel: string;
}

export function TestimonialsMarquee({ items, ratingLabel }: Props) {
  // Duplicate items so the -50% loop is seamless
  const duplicated = [...items, ...items];

  return (
    <div className="marquee-wrap relative overflow-hidden">
      {/* Edge fade gradients */}
      <div className="pointer-events-none absolute left-0 top-0 bottom-0 w-20 sm:w-32 z-10 bg-gradient-to-r from-warm-white dark:from-navy to-transparent" />
      <div className="pointer-events-none absolute right-0 top-0 bottom-0 w-20 sm:w-32 z-10 bg-gradient-to-l from-warm-white dark:from-navy to-transparent" />

      <div className="marquee-track flex gap-5 w-max">
        {duplicated.map((item, idx) => (
          <TestimonialCard
            key={`${item.id}-${idx}`}
            item={item}
            ratingLabel={ratingLabel}
          />
        ))}
      </div>
    </div>
  );
}

function TestimonialCard({
  item,
  ratingLabel,
}: {
  item: ResolvedTestimonial;
  ratingLabel: string;
}) {
  return (
    <div className="w-[340px] sm:w-[380px] flex-shrink-0 bg-white dark:bg-white/5 border border-[rgba(10,22,40,0.12)] dark:border-white/10 rounded-2xl p-6">
      <div className="flex items-center gap-4 mb-4">
        <div className="relative w-12 h-12 rounded-full overflow-hidden flex-shrink-0 bg-gradient-to-br from-navy/10 to-brand-gold/15 border border-brand-gold/25 flex items-center justify-center">
          {item.imageSrc ? (
            <Image
              src={item.imageSrc}
              alt={item.name}
              fill
              className="object-cover"
              sizes="48px"
            />
          ) : (
            <User
              className="w-5 h-5 text-navy/40 dark:text-white/40"
              strokeWidth={1.5}
            />
          )}
        </div>
        <div
          className="flex items-center gap-0.5"
          aria-label={ratingLabel}
        >
          {Array.from({ length: 5 }).map((_, i) => (
            <Star
              key={i}
              className="w-4 h-4 text-brand-gold fill-brand-gold"
              strokeWidth={1.5}
            />
          ))}
        </div>
      </div>

      <div className="font-display text-[17px] text-navy dark:text-white leading-[1.4] mb-3">
        &ldquo;{item.title}&rdquo;
      </div>

      <p className="text-[13px] text-brand-gray dark:text-white/65 leading-[1.6] mb-5">
        {item.desc}
      </p>

      <div className="text-[13px] font-medium text-navy dark:text-white">
        {item.name}
        <span className="text-brand-gray dark:text-white/50 font-normal">
          {" · "}
          {item.role}
        </span>
      </div>
    </div>
  );
}
