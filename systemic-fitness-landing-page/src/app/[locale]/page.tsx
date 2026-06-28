import { setRequestLocale } from "next-intl/server";
import { Nav } from "@/components/Nav";
import { Hero } from "@/components/sections/Hero";
import { Signals } from "@/components/sections/Signals";
import { Method } from "@/components/sections/Method";
import { Classification } from "@/components/sections/Classification";
import { Programs } from "@/components/sections/Programs";
import { Score } from "@/components/sections/Score";
import { HowItWorks } from "@/components/sections/HowItWorks";
import { Testimonials } from "@/components/sections/Testimonials";
import { Partner } from "@/components/sections/Partner";
import { Pricing } from "@/components/sections/Pricing";
import { FinalCta } from "@/components/sections/FinalCta";
import { Footer } from "@/components/sections/Footer";

export default async function LandingPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);

  return (
    <>
      <Nav />
      <main>
        <Hero />
        <Signals />
        <Method />
        <Classification />
        <Programs />
        <Score />
        <HowItWorks />
        <Testimonials />
        <Partner />
        <Pricing />
        <FinalCta />
      </main>
      <Footer />
    </>
  );
}
