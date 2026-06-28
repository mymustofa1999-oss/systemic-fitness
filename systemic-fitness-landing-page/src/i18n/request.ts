import { getRequestConfig } from "next-intl/server";
import { notFound } from "next/navigation";
import { routing, type Locale } from "./routing";
import { loadContent } from "@/lib/content";

export default getRequestConfig(async ({ requestLocale }) => {
  const requested = await requestLocale;
  const locale: Locale =
    requested && routing.locales.includes(requested as Locale)
      ? (requested as Locale)
      : routing.defaultLocale;

  if (!routing.locales.includes(locale)) notFound();

  return {
    locale,
    messages: await loadContent(locale),
  };
});
