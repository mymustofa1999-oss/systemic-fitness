"use client";

import { motion, type MotionProps } from "framer-motion";
import type { ReactNode } from "react";

interface RevealProps {
  children: ReactNode;
  className?: string;
  delay?: number;
  y?: number;
  once?: boolean;
}

const EASE = [0.25, 0.1, 0.25, 1] as const;

export function Reveal({
  children,
  className,
  delay = 0,
  y = 20,
  once = true,
}: RevealProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once, margin: "-40px" }}
      transition={{ duration: 0.6, delay, ease: EASE }}
      className={className}
    >
      {children}
    </motion.div>
  );
}

export function RevealStagger({
  children,
  className,
  delayStart = 0,
  step = 0.08,
  ...rest
}: {
  children: ReactNode[];
  className?: string;
  delayStart?: number;
  step?: number;
} & Omit<MotionProps, "children">) {
  return (
    <div className={className} {...(rest as object)}>
      {children.map((child, i) => (
        <Reveal key={i} delay={delayStart + i * step}>
          {child}
        </Reveal>
      ))}
    </div>
  );
}
