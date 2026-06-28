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
        // Systemic brand palette
        brand: {
          yellow: "#f9c509",
          "yellow-light": "#fdd84a",
          "yellow-dark": "#d9a800",
          dark: "#2b2b2b",
          red: "#a51700",
          "red-light": "#c22a0e",
          cream: "#f9f1d7",
          "cream-dark": "#eee4c0",
          // Legacy slots remapped to new palette so existing classes still work
          blue: "#f9c509",
          gold: "#f9c509",
          "gold-light": "#fdd84a",
          teal: "#a51700",
        },
        navy: {
          DEFAULT: "#2b2b2b",
          mid: "#3f3f3f",
          deep: "#1a1a1a",
        },
        surface: {
          warm: "#f9f1d7",
          white: "#FFFFFF",
          charcoal: "#2b2b2b",
        },
        muted: "#6B6B68",
        "light-blue": "#fef7d4",

        // Root-level legacy aliases
        gold: "#f9c509",
        "gold-light": "#fdd84a",
        teal: "#a51700",
        "warm-white": "#f9f1d7",
        charcoal: "#2b2b2b",
        "brand-gray": "#6B6B68",
        "navy-mid": "#3f3f3f",
        blue: "#f9c509",
      },
      fontFamily: {
        display: ["var(--font-playfair)", "serif"],
        serif: ["var(--font-playfair)", "serif"],
        sans: ["var(--font-montserrat)", "sans-serif"],
        mono: ["var(--font-dm-mono)", "monospace"],
      },
      fontSize: {
        hero: ["clamp(40px, 6vw, 72px)", { lineHeight: "1.1" }],
        headline: ["clamp(28px, 4vw, 44px)", { lineHeight: "1.2" }],
      },
      letterSpacing: {
        tag: "0.12em",
        label: "0.1em",
      },
      keyframes: {
        fadeUp: {
          "0%": { opacity: "0", transform: "translateY(20px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
      },
      animation: {
        "fade-up": "fadeUp 0.6s ease both",
      },
    },
  },
  plugins: [],
};

export default config;
