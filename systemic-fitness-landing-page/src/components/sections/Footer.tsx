import { useTranslations } from "next-intl";
import Image from "next/image";
import { StoreBadges } from "../StoreBadges";
import { Link } from "@/i18n/routing";

export function Footer() {
  const tNav = useTranslations("nav");
  const t = useTranslations("footer");

  const links = [
    { href: "/#method", label: tNav("method") },
    { href: "/#programs", label: tNav("programs") },
    { href: "/#partner", label: tNav("partner") },
    // { href: "/#pricing", label: tNav("pricing") },
    // { href: "/payment-guide", label: tNav("paymentGuide") },
  ];

  return (
    <footer className="bg-navy border-t border-white/10 px-[5%] py-14">
      <div className="grid gap-10 md:grid-cols-[auto_1fr_auto] items-start">
        <div className="flex items-center gap-4">
          <Image
            src="/logo_only_1.png"
            alt="Systemic Fitness"
            width={64}
            height={64}
            className="h-14 w-auto rounded"
          />
          <span className="text-[10px] tracking-[0.08em] text-white/35">
            {t("tagline")}
          </span>
        </div>

        <ul className="flex gap-6 list-none m-0 p-0 flex-wrap md:justify-center">
          {links.map((l) => (
            <li key={l.href}>
              <Link
                href={l.href as any}
                className="text-xs text-white/35 hover:text-white/70 transition-colors no-underline"
              >
                {l.label}
              </Link>
            </li>
          ))}
        </ul>

        <StoreBadges size="sm" align="start" />
      </div>

      <div className="mt-10 pt-6 border-t border-white/10 flex flex-wrap justify-between items-center gap-4">
        <div className="text-xs text-white/25">{t("copy")}</div>
      </div>
    </footer>
  );
}
