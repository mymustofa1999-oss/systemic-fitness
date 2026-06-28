import { getTranslations, setRequestLocale } from "next-intl/server";
import { Nav } from "@/components/Nav";
import { Footer } from "@/components/sections/Footer";
import { ImagePlaceholder } from "@/components/ImagePlaceholder";
import { Reveal } from "@/components/Reveal";

export default async function PaymentGuidePage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("paymentGuide");

  const steps = [
    {
      id: "step1",
      spec: "Screenshot of Mobile App: Program Selection Screen",
    },
    {
      id: "step2",
      spec: "Screenshot of Mobile App: Assessment Form",
    },
    {
      id: "step3",
      spec: "Screenshot of Mobile App: Checkout with Midtrans Options",
    },
    {
      id: "step4",
      spec: "Screenshot of Mobile App: Payment Success Screen",
    },
  ];

  return (
    <>
      <Nav />
      <main className="bg-warm-white dark:bg-navy min-h-screen pt-32 pb-24 px-[5%] transition-colors">
        <Reveal>
          <div className="max-w-3xl mx-auto text-center mb-16">
            <h1 className="font-display text-navy dark:text-white text-4xl md:text-5xl mb-6">
              {t("title")}
            </h1>
            <p className="text-brand-gray dark:text-white/60 text-lg leading-relaxed">
              {t("sub")}
            </p>
          </div>
        </Reveal>

        <div className="max-w-4xl mx-auto space-y-16">
          {steps.map((step, idx) => (
            <Reveal key={step.id} delay={idx * 0.1}>
              <div className="bg-white dark:bg-white/5 border border-[rgba(10,22,40,0.12)] dark:border-white/10 rounded-3xl p-8 md:p-12 flex flex-col md:flex-row items-center gap-10">
                <div className="w-full md:w-1/2 flex flex-col justify-center">
                  <div className="w-12 h-12 bg-brand-gold/10 text-brand-gold rounded-full flex items-center justify-center font-bold text-xl mb-6">
                    {idx + 1}
                  </div>
                  <h3 className="font-display text-navy dark:text-white text-2xl mb-4">
                    {t(`${step.id}Title` as any)}
                  </h3>
                  <p className="text-brand-gray dark:text-white/60 leading-relaxed">
                    {t(`${step.id}Desc` as any)}
                  </p>
                </div>
                <div className="w-full md:w-1/2">
                  <ImagePlaceholder
                    alt={`Step ${idx + 1} Screenshot`}
                    spec={step.spec}
                    aspect="aspect-[9/16]"
                    className="max-w-[280px] mx-auto shadow-xl"
                  />
                </div>
              </div>
            </Reveal>
          ))}
        </div>
      </main>
      <Footer />
    </>
  );
}
