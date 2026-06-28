import type { Config } from "tailwindcss";

const config: Config = {
  darkMode: "class",
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          50:  "#EEF2FF",
          100: "#E0E7FF",
          200: "#C7D2FE",
          300: "#A5B4FC",
          400: "#818CF8",
          500: "#6366F1",
          600: "#4F46E5",
          700: "#4338CA",
          800: "#3730A3",
          900: "#312E81",
          950: "#1E1B4B",
        },
        accent: {
          DEFAULT: "#10B981",
          light: "#34D399",
          dark: "#059669",
        },
        sidebar: {
          bg: "#1E1B4B",
          hover: "#312E81",
          active: "#4338CA",
          text: "#C7D2FE",
          muted: "#818CF8",
        },
        // Systemic Fitness brand palette (SF Master Platform Spec v1.0 / 2026)
        // Added in Phase 0 — coexists with legacy brand.*/accent.* tokens.
        sf: {
          deepNavy:     "#0A1628",
          charcoal:     "#444444",
          midnightBlue: "#1B3A5C",
          systemBlue:   "#2E6DA4",
          warmGold:     "#B8922E",
          warmGoldDark: "#A07828",
          deepTeal:     "#0B5C5C",
          iceBlue:      "#E8F0F8",
          warmWhite:    "#F8F6F1",
        },
      },
      fontFamily: {
        heading: ['"Plus Jakarta Sans"', "sans-serif"],
        body: ['"Inter"', "sans-serif"],
        mono: ['"JetBrains Mono"', "monospace"],
        // SF brand fonts (loaded via next/font in src/app/layout.tsx)
        "dm-serif": ['var(--font-dm-serif)', '"DM Serif Display"', "serif"],
        "dm-sans":  ['var(--font-dm-sans)',  '"DM Sans"',          "sans-serif"],
        "dm-mono":  ['var(--font-dm-mono)',  '"DM Mono"',          "monospace"],
      },
      borderRadius: {
        xl: "0.75rem",
        "2xl": "1rem",
      },
      boxShadow: {
        card: "0 1px 3px 0 rgb(0 0 0 / 0.04), 0 1px 2px -1px rgb(0 0 0 / 0.04)",
        "card-hover": "0 4px 6px -1px rgb(0 0 0 / 0.07), 0 2px 4px -2px rgb(0 0 0 / 0.05)",
      },
      animation: {
        "fade-in": "fadeIn 0.3s ease-out",
        "slide-in": "slideIn 0.2s ease-out",
      },
      keyframes: {
        fadeIn: {
          "0%": { opacity: "0" },
          "100%": { opacity: "1" },
        },
        slideIn: {
          "0%": { opacity: "0", transform: "translateY(-10px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
};
export default config;
