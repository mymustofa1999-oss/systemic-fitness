import type { Metadata } from "next";
import { DM_Sans, DM_Serif_Display, DM_Mono } from "next/font/google";
import { Providers } from "./providers";
import "./globals.css";

// SF brand fonts (Phase 0 — Spec Lock & Branding Tokens).
// Exposed as CSS variables; consumed by Tailwind fontFamily.dm-* tokens.
const dmSans = DM_Sans({
  subsets: ["latin"],
  weight: ["400", "500", "700"],
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

export const metadata: Metadata = {
  title: "Systemic Fitness Admin",
  description: "Systemic Fitness Platform — Admin Panel",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className={`${dmSans.variable} ${dmSerif.variable} ${dmMono.variable}`}>
      <body>
        <Providers>{children}</Providers>
        {/* Auto-recover from stale chunks after build/restart */}
        <script
          dangerouslySetInnerHTML={{
            __html: `
              (function() {
                if (typeof window === 'undefined') return;
                // Detect chunk load failures and auto-reload ONCE
                var reloaded = sessionStorage.getItem('__chunk_reload');
                window.addEventListener('error', function(e) {
                  var src = e.target && (e.target.src || e.target.href);
                  if (src && (src.includes('/_next/static/') || src.includes('layout.css'))) {
                    if (!reloaded) {
                      sessionStorage.setItem('__chunk_reload', '1');
                      window.location.reload();
                    }
                  }
                }, true);
                // Clear flag on successful page load
                if (reloaded) {
                  setTimeout(function() { sessionStorage.removeItem('__chunk_reload'); }, 3000);
                }
              })();
            `,
          }}
        />
      </body>
    </html>
  );
}
