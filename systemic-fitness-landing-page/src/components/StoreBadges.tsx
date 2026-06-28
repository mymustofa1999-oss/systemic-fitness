import type { SVGProps } from "react";

interface StoreBadgesProps {
  className?: string;
  size?: "sm" | "md";
  align?: "start" | "center";
  appStoreHref?: string;
  playStoreHref?: string;
  labels?: {
    appStoreSmall: string;
    appStoreLarge: string;
    playStoreSmall: string;
    playStoreLarge: string;
  };
}

const DEFAULT_LABELS = {
  appStoreSmall: "Download on the",
  appStoreLarge: "App Store",
  playStoreSmall: "GET IT ON",
  playStoreLarge: "Google Play",
};

export function StoreBadges({
  className = "",
  size = "md",
  align = "center",
  appStoreHref = "/get",
  playStoreHref = "/get",
  labels = DEFAULT_LABELS,
}: StoreBadgesProps) {
  const isSm = size === "sm";
  const iconSize = isSm ? "w-5 h-5" : "w-7 h-7";
  const padding = isSm ? "px-4 py-2" : "px-5 py-3";
  const smallText = isSm ? "text-[9px]" : "text-[11px]";
  const largeText = isSm ? "text-[13px]" : "text-[17px]";

  return (
    <div
      className={`flex flex-wrap gap-3 ${
        align === "center" ? "justify-center" : "justify-start"
      } ${className}`}
    >
      <a
        href={appStoreHref}
        aria-label={`${labels.appStoreSmall} ${labels.appStoreLarge}`}
        className={`group inline-flex items-center gap-3 rounded-xl bg-black border border-white/15 text-white ${padding} transition-all hover:bg-white/[0.07] hover:border-white/25 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-gold-light focus-visible:ring-offset-2 focus-visible:ring-offset-navy`}
      >
        <AppleIcon className={iconSize} />
        <div className="text-left leading-tight">
          <div className={`${smallText} text-white/70 font-sans`}>
            {labels.appStoreSmall}
          </div>
          <div className={`${largeText} font-semibold tracking-tight`}>
            {labels.appStoreLarge}
          </div>
        </div>
      </a>

      <a
        href={playStoreHref}
        aria-label={`${labels.playStoreSmall} ${labels.playStoreLarge}`}
        className={`group inline-flex items-center gap-3 rounded-xl bg-black border border-white/15 text-white ${padding} transition-all hover:bg-white/[0.07] hover:border-white/25 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-gold-light focus-visible:ring-offset-2 focus-visible:ring-offset-navy`}
      >
        <PlayIcon className={iconSize} />
        <div className="text-left leading-tight">
          <div className={`${smallText} text-white/70 font-sans tracking-wider`}>
            {labels.playStoreSmall}
          </div>
          <div className={`${largeText} font-semibold tracking-tight`}>
            {labels.playStoreLarge}
          </div>
        </div>
      </a>
    </div>
  );
}

function AppleIcon(props: SVGProps<SVGSVGElement>) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="currentColor"
      aria-hidden="true"
      {...props}
    >
      <path d="M17.05 12.536c-.02-2.112 1.724-3.127 1.803-3.176-.984-1.438-2.513-1.635-3.056-1.658-1.302-.132-2.54.768-3.2.768-.66 0-1.679-.749-2.763-.728-1.421.021-2.732.826-3.463 2.098-1.477 2.56-.377 6.35 1.062 8.424.703 1.019 1.542 2.165 2.64 2.125 1.062-.043 1.463-.687 2.747-.687 1.285 0 1.642.687 2.764.664 1.142-.02 1.867-1.036 2.566-2.06.81-1.18 1.143-2.325 1.162-2.384-.026-.011-2.23-.858-2.253-3.386zM15.01 6.327c.585-.708.979-1.691.872-2.672-.843.035-1.863.562-2.469 1.268-.541.625-1.015 1.625-.888 2.587.94.073 1.9-.479 2.485-1.183z" />
    </svg>
  );
}

function PlayIcon(props: SVGProps<SVGSVGElement>) {
  return (
    <svg
      viewBox="0 0 512 512"
      aria-hidden="true"
      {...props}
    >
      <defs>
        <linearGradient id="ps-a" x1="56" y1="42" x2="318" y2="42" gradientTransform="matrix(1,0,0,-1,0,298)" gradientUnits="userSpaceOnUse">
          <stop offset="0" stopColor="#00A1FF" />
          <stop offset="0.26" stopColor="#00BEFF" />
          <stop offset="0.51" stopColor="#00D2FF" />
          <stop offset="0.76" stopColor="#00DFFF" />
          <stop offset="1" stopColor="#00E3FF" />
        </linearGradient>
        <linearGradient id="ps-b" x1="472" y1="158" x2="241" y2="158" gradientTransform="matrix(1,0,0,-1,0,414)" gradientUnits="userSpaceOnUse">
          <stop offset="0" stopColor="#FFE000" />
          <stop offset="0.41" stopColor="#FFBD00" />
          <stop offset="0.78" stopColor="#FFA500" />
          <stop offset="1" stopColor="#FF9C00" />
        </linearGradient>
        <linearGradient id="ps-c" x1="394" y1="106" x2="91" y2="-305" gradientTransform="matrix(1,0,0,-1,0,414)" gradientUnits="userSpaceOnUse">
          <stop offset="0" stopColor="#FF3A44" />
          <stop offset="1" stopColor="#C31162" />
        </linearGradient>
        <linearGradient id="ps-d" x1="109" y1="396" x2="255" y2="213" gradientTransform="matrix(1,0,0,-1,0,414)" gradientUnits="userSpaceOnUse">
          <stop offset="0" stopColor="#32A071" />
          <stop offset="0.07" stopColor="#2DA771" />
          <stop offset="0.48" stopColor="#15CF74" />
          <stop offset="0.8" stopColor="#06E775" />
          <stop offset="1" stopColor="#00F076" />
        </linearGradient>
      </defs>
      <path d="M73.5,71.2a27.8,27.8,0,0,0-6.3,19.5V421.3a27.8,27.8,0,0,0,6.3,19.5l1.1,1.1L264.9,252V247.4L74.6,70.1Z" fill="url(#ps-a)" />
      <path d="M328.3,315.3l-63.4-63.4v-4.6l63.4-63.4,1.4.8L405,227c21.4,12.1,21.4,32.1,0,44.3L329.7,314.5Z" fill="url(#ps-b)" />
      <path d="M329.7,314.5,264.9,249.7,73.5,441a22.8,22.8,0,0,0,29.2.9L329.7,314.5" fill="url(#ps-c)" />
      <path d="M329.7,184.9,102.7,57a22.8,22.8,0,0,0-29.2.9L264.9,249.7l64.8-64.8Z" fill="url(#ps-d)" />
    </svg>
  );
}
