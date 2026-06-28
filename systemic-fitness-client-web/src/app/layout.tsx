import type { Metadata, Viewport } from "next";
import { DM_Sans, DM_Serif_Display, DM_Mono, Bebas_Neue } from "next/font/google";
import { Providers } from "./providers";
import "./globals.css";

// SF brand fonts (Phase 0 — Spec Lock & Branding Tokens).
// Exposed as CSS variables; consumed by Tailwind fontFamily tokens.
const dmSans = DM_Sans({
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
  variable: "--font-dm-sans",
  display: "swap",
});
const dmSerif = DM_Serif_Display({
  subsets: ["latin"],
  weight: ["400"],
  variable: "--font-dm-serif",
  display: "swap",
});
const dmMono = DM_Mono({
  subsets: ["latin"],
  weight: ["400", "500"],
  variable: "--font-dm-mono",
  display: "swap",
});
const bebasNeue = Bebas_Neue({
  subsets: ["latin"],
  weight: ["400"],
  variable: "--font-bebas-neue",
  display: "swap",
});

export const metadata: Metadata = {
  title: {
    default: "Systemic Fitness — Your Training Companion",
    template: "%s | Systemic Fitness",
  },
  description:
    "Akses program latihan, nutrisi, dan progress tracking Anda di mana saja. Systemic Fitness — we train your body system.",
  keywords: ["fitness", "training", "nutrition", "systemic fitness", "workout", "health"],
  authors: [{ name: "Systemic Fitness" }],
  openGraph: {
    type: "website",
    locale: "id_ID",
    siteName: "Systemic Fitness",
  },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
  themeColor: "#0A1628",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html
      lang="id"
      className={`${dmSans.variable} ${dmSerif.variable} ${dmMono.variable} ${bebasNeue.variable}`}
    >
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
