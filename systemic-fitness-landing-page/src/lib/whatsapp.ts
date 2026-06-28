export const WHATSAPP_NUMBER = "6282211111586";

const MESSAGE_ID =
  "Halo, saya tertarik memulai Assessment Systemic Fitness. Bisa dibantu?";
const MESSAGE_EN =
  "Hi, I'm interested in starting the Systemic Fitness Assessment. Could you help me?";

export function getWhatsAppUrl(locale: string): string {
  const message = locale === "en" ? MESSAGE_EN : MESSAGE_ID;
  return `https://wa.me/${WHATSAPP_NUMBER}?text=${encodeURIComponent(message)}`;
}
