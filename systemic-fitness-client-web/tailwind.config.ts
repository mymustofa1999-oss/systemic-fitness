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
        bg: {
          primary: "var(--bg-primary)",
          card: "var(--bg-card)",
        },
        text: {
          primary: "var(--text-primary)",
          secondary: "var(--text-secondary)",
        },
        border: {
          color: "var(--border-color)",
        },
        // Systemic Fitness brand palette (SF Master Platform Spec v1.0 / 2026)
        // Client-facing web app — uses SF brand as primary colors.
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
        // Semantic aliases for convenience
        primary: {
          DEFAULT: "#2E6DA4",
          light: "#4A8EC4",
          dark: "#1B3A5C",
        },
        accent: {
          DEFAULT: "#B8922E",
          light: "#D4AE4A",
          dark: "#A07828",
        },
        success: {
          DEFAULT: "#0B5C5C",
          light: "#0E7A7A",
        },
      },
      fontFamily: {
        // SF brand fonts (loaded via next/font in src/app/layout.tsx)
        "dm-serif": ['var(--font-dm-serif)', '"DM Serif Display"', "serif"],
        "dm-sans":  ['var(--font-dm-sans)',  '"DM Sans"',          "sans-serif"],
        "dm-mono":  ['var(--font-dm-mono)',  '"DM Mono"',          "monospace"],
        "bebas":    ['var(--font-bebas-neue)', '"Bebas Neue"',      "sans-serif"],
        heading: ['var(--font-dm-serif)', '"DM Serif Display"', "serif"],
        body: ['var(--font-dm-sans)', '"DM Sans"', "sans-serif"],
        mono: ['var(--font-dm-mono)', '"DM Mono"', "monospace"],
      },
      borderRadius: {
        xl: "0.75rem",
        "2xl": "1rem",
        "3xl": "1.5rem",
      },
      boxShadow: {
        card: "0 1px 3px 0 rgb(0 0 0 / 0.04), 0 1px 2px -1px rgb(0 0 0 / 0.04)",
        "card-hover": "0 4px 6px -1px rgb(0 0 0 / 0.07), 0 2px 4px -2px rgb(0 0 0 / 0.05)",
        "soft": "0 2px 15px -3px rgba(0, 0, 0, 0.07), 0 10px 20px -2px rgba(0, 0, 0, 0.04)",
        "glow-gold": "0 0 20px rgba(184, 146, 46, 0.3)",
      },
      animation: {
        "fade-in": "fadeIn 0.4s ease-out",
        "fade-in-up": "fadeInUp 0.5s ease-out",
        "slide-in": "slideIn 0.3s ease-out",
        "slide-up": "slideUp 0.3s ease-out",
        "pulse-soft": "pulseSoft 2s ease-in-out infinite",
        "shimmer": "shimmer 2s linear infinite",
      },
      keyframes: {
        fadeIn: {
          "0%": { opacity: "0" },
          "100%": { opacity: "1" },
        },
        fadeInUp: {
          "0%": { opacity: "0", transform: "translateY(16px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
        slideIn: {
          "0%": { opacity: "0", transform: "translateX(-10px)" },
          "100%": { opacity: "1", transform: "translateX(0)" },
        },
        slideUp: {
          "0%": { opacity: "0", transform: "translateY(100%)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
        pulseSoft: {
          "0%, 100%": { opacity: "1" },
          "50%": { opacity: "0.7" },
        },
        shimmer: {
          "0%": { backgroundPosition: "-200% 0" },
          "100%": { backgroundPosition: "200% 0" },
        },
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
};
export default config;
