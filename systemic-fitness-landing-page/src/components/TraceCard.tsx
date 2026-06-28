import type { ReactNode } from "react";

interface TraceCardProps {
  children: ReactNode;
  /** Inner card classes (background, border, layout) */
  className?: string;
  /** Wrapper classes (h-full, col-span, etc.) */
  wrapperClassName?: string;
  /** Trace stroke color */
  color?: string;
  /** Corner radius in px (must match inner card radius) */
  radius?: number;
  strokeWidth?: number;
}

/**
 * Wraps a card with an animated SVG border that traces around the perimeter
 * on hover and retracts when the cursor leaves. Uses stroke-dashoffset with
 * `pathLength="1"` for a normalized 0..1 draw progress.
 */
export function TraceCard({
  children,
  className = "",
  wrapperClassName = "",
  color = "rgba(212, 168, 75, 0.95)",
  radius = 16,
  strokeWidth = 1.5,
}: TraceCardProps) {
  return (
    <div className={`trace-wrap relative h-full ${wrapperClassName}`}>
      <div className={className}>{children}</div>
      <svg
        aria-hidden="true"
        className="absolute inset-0 w-full h-full pointer-events-none"
        preserveAspectRatio="none"
      >
        <rect
          x="1"
          y="1"
          width="calc(100% - 2px)"
          height="calc(100% - 2px)"
          rx={radius}
          ry={radius}
          fill="none"
          stroke={color}
          strokeWidth={strokeWidth}
          pathLength="1"
          className="trace-rect"
        />
      </svg>
    </div>
  );
}
