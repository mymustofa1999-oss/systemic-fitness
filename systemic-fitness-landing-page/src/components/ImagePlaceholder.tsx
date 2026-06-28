import { ImageIcon } from "lucide-react";
import Image from "next/image";
import fs from "node:fs";
import path from "node:path";

interface ImagePlaceholderProps {
  /** Filename under /public/images, e.g. "hero-background.webp". Auto-detected; placeholder shown if missing. */
  src?: string;
  alt: string;
  /** Recommended spec shown in the placeholder state */
  spec: string;
  /** Tailwind aspect ratio utility, e.g. "aspect-[4/5]" */
  aspect?: string;
  className?: string;
  tone?: "light" | "dark";
  priority?: boolean;
  /** If true, the Image fills the parent with object-cover */
  fill?: boolean;
}

function imageExists(src: string): boolean {
  try {
    const abs = path.join(process.cwd(), "public", "images", src);
    return fs.existsSync(abs);
  } catch {
    return false;
  }
}

export function ImagePlaceholder({
  src,
  alt,
  spec,
  aspect = "aspect-[4/5]",
  className = "",
  tone = "light",
  priority = false,
  fill = true,
}: ImagePlaceholderProps) {
  const isDark = tone === "dark";
  const exists = src ? imageExists(src) : false;

  if (src && exists) {
    return (
      <div
        className={`relative overflow-hidden rounded-2xl ${aspect} ${className}`}
      >
        <Image
          src={`/images/${src}`}
          alt={alt}
          fill={fill}
          priority={priority}
          className="object-cover"
          sizes="(max-width: 768px) 100vw, 50vw"
        />
      </div>
    );
  }

  return (
    <div
      className={`relative overflow-hidden rounded-2xl ${aspect} ${className} flex items-center justify-center border ${
        isDark
          ? "bg-white/[0.04] border-white/10"
          : "bg-[rgba(10,22,40,0.04)] border-[rgba(10,22,40,0.1)]"
      }`}
    >
      <div
        className="absolute inset-0 pointer-events-none"
        style={{
          backgroundImage: isDark
            ? "linear-gradient(135deg, rgba(184,146,46,0.06) 0%, rgba(46,109,164,0.06) 100%)"
            : "linear-gradient(135deg, rgba(184,146,46,0.08) 0%, rgba(46,109,164,0.06) 100%)",
        }}
      />
      <div className="relative z-10 text-center px-6 py-6">
        <div
          className={`mx-auto w-10 h-10 rounded-lg flex items-center justify-center mb-3 ${
            isDark ? "bg-white/10" : "bg-[rgba(10,22,40,0.06)]"
          }`}
        >
          <ImageIcon
            className={`w-4 h-4 ${isDark ? "text-white/60" : "text-navy/60"}`}
            strokeWidth={1.5}
          />
        </div>
        <div
          className={`font-mono text-[11px] tracking-[0.12em] ${
            isDark ? "text-white/50" : "text-navy/50"
          }`}
        >
          IMAGE PLACEHOLDER
        </div>
        {src ? (
          <div
            className={`mt-2 font-mono text-[10px] ${
              isDark ? "text-brand-gold-light/80" : "text-brand-gold"
            }`}
          >
            /images/{src}
          </div>
        ) : null}
        {spec ? (
          <div
            className={`mt-2 text-[12px] max-w-[280px] mx-auto leading-[1.5] ${
              isDark ? "text-white/65" : "text-navy/65"
            }`}
          >
            {spec}
          </div>
        ) : null}
      </div>
    </div>
  );
}
