import Image from "next/image";
import fs from "node:fs";
import path from "node:path";

interface OptionalBgImageProps {
  src: string;
  alt?: string;
  className?: string;
  priority?: boolean;
}

/**
 * Decorative background image that renders nothing if the file
 * doesn't exist in /public/images. Safe to use behind solid colors.
 */
export function OptionalBgImage({
  src,
  alt = "",
  className = "",
  priority = false,
}: OptionalBgImageProps) {
  const abs = path.join(process.cwd(), "public", "images", src);
  let exists = false;
  try {
    exists = fs.existsSync(abs);
  } catch {
    exists = false;
  }
  if (!exists) return null;

  return (
    <Image
      src={`/images/${src}`}
      alt={alt}
      fill
      priority={priority}
      className={`object-cover ${className}`}
      sizes="100vw"
    />
  );
}
