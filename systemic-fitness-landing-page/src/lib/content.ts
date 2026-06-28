import type { AbstractIntlMessages } from "next-intl";
import type { Locale } from "@/i18n/routing";

interface LandingPayload {
  locale: string;
  published_at?: string;
  settings: Record<string, unknown>;
  sections: Record<string, Record<string, unknown>>;
  collections: {
    testimonials: Array<{
      id: string;
      name: string;
      role: string;
      title: string;
      description: string;
      rating: number;
      image_url?: string;
    }>;
    programs: Array<{
      id: string;
      tier_label: string;
      tier_color: string;
      name: string;
      description: string;
      features: string[];
      meta: Array<{ strong: string; span: string }>;
      image_url?: string;
    }>;
    pricing: Array<{
      id: string;
      name: string;
      for_whom: string;
      amount_monthly: string;
      per_monthly: string;
      amount_yearly?: string;
      per_yearly?: string;
      equiv_yearly?: string;
      original_yearly?: string;
      savings_yearly?: string;
      features: string[];
      cta_label: string;
      cta_style: string;
      is_featured: boolean;
    }>;
  };
}

type Messages = AbstractIntlMessages;

/**
 * Fetches landing-page content from the CMS API and transforms it into the
 * flat messages shape expected by next-intl. Falls back to the bundled
 * messages/{locale}.json if the API is unreachable or returns an error.
 */
export async function loadContent(locale: Locale): Promise<Messages> {
  // Gate the CMS fetch behind an explicit flag — until the admin CMS is
  // published-ready, always serve the bundled messages so we don't risk
  // showing half-built API content. Flip CMS_ENABLED=true on the VPS once
  // the admin side is verified.
  const apiUrl = process.env.CMS_API_URL;
  const cmsEnabled = process.env.CMS_ENABLED === "true";
  if (!apiUrl || !cmsEnabled) {
    return loadFallback(locale);
  }

  try {
    const res = await fetch(`${apiUrl}/api/public/cms/landing?locale=${locale}`, {
      next: { revalidate: 300, tags: [`cms:${locale}`] },
    });
    if (!res.ok) throw new Error(`CMS API returned ${res.status}`);
    const envelope = await res.json();
    if (!envelope?.data) throw new Error("CMS envelope missing data field");
    return transform(envelope.data as LandingPayload);
  } catch (err) {
    console.warn(`[cms] falling back to bundled messages for ${locale}:`, err);
    return loadFallback(locale);
  }
}

async function loadFallback(locale: Locale): Promise<Messages> {
  return (await import(`../../messages/${locale}.json`)).default;
}

// Translates the CMS payload back to the flat key structure currently used
// by next-intl / useTranslations. Kept local so section components stay
// unchanged in Phase 1.
function transform(payload: LandingPayload): Messages {
  const sections = payload.sections ?? {};

  const programCards: Record<string, string> = {};
  payload.collections.programs.forEach((p, i) => {
    const n = i + 1;
    programCards[`p${n}Tier`] = p.tier_label;
    programCards[`p${n}Name`] = p.name;
    programCards[`p${n}Desc`] = p.description;
    (p.features ?? []).forEach((f, j) => {
      programCards[`p${n}F${j + 1}`] = f;
    });
    (p.meta ?? []).forEach((m, j) => {
      programCards[`p${n}M${j + 1}Strong`] = m.strong;
      programCards[`p${n}M${j + 1}Span`] = m.span;
    });
  });

  const testimonialItems: Record<string, string> = {};
  payload.collections.testimonials.forEach((t, i) => {
    const n = i + 1;
    testimonialItems[`t${n}Name`] = t.name;
    testimonialItems[`t${n}Role`] = t.role;
    testimonialItems[`t${n}Title`] = t.title;
    testimonialItems[`t${n}Desc`] = t.description;
    if (t.image_url) testimonialItems[`t${n}Image`] = t.image_url;
  });

  const pricingCards: Record<string, string> = {};
  payload.collections.pricing.forEach((p, i) => {
    const n = i + 1;
    pricingCards[`pr${n}Name`] = p.name;
    pricingCards[`pr${n}For`] = p.for_whom;
    pricingCards[`pr${n}Amount`] = p.amount_monthly;
    pricingCards[`pr${n}Per`] = p.per_monthly;
    if (p.amount_yearly) pricingCards[`pr${n}AmountYearly`] = p.amount_yearly;
    if (p.per_yearly) pricingCards[`pr${n}PerYearly`] = p.per_yearly;
    if (p.equiv_yearly) pricingCards[`pr${n}EquivYearly`] = p.equiv_yearly;
    if (p.original_yearly) pricingCards[`pr${n}OriginalYearly`] = p.original_yearly;
    if (p.savings_yearly) pricingCards[`pr${n}SavingsYearly`] = p.savings_yearly;
    (p.features ?? []).forEach((f, j) => {
      pricingCards[`pr${n}F${j + 1}`] = f;
    });
    pricingCards[`pr${n}Cta`] = p.cta_label;
  });

  return {
    ...sections,
    programs: {
      ...(sections.programs ?? {}),
      cards: programCards,
    },
    testimonials: {
      ...(sections.testimonials ?? {}),
      items: testimonialItems,
    },
    pricing: {
      ...(sections.pricing ?? {}),
      cards: pricingCards,
    },
  };
}
