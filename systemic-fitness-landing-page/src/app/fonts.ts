import { DM_Mono, Montserrat, Playfair_Display } from "next/font/google";

export const playfair = Playfair_Display({
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
  style: ["normal", "italic"],
  display: "swap",
  variable: "--font-playfair",
});

export const montserrat = Montserrat({
  subsets: ["latin"],
  weight: ["300", "400", "500", "600", "700"],
  display: "swap",
  variable: "--font-montserrat",
});

export const dmMono = DM_Mono({
  subsets: ["latin"],
  weight: ["400"],
  display: "swap",
  variable: "--font-dm-mono",
});
