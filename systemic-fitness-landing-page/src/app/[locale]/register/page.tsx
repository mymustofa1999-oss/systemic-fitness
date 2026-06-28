import { setRequestLocale } from "next-intl/server";
import { Nav } from "@/components/Nav";
import { Footer } from "@/components/sections/Footer";
import { RegisterForm } from "@/components/RegisterForm";
import { Reveal } from "@/components/Reveal";

export default async function RegisterPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);

  return (
    <>
      <Nav />
      <main className="bg-warm-white dark:bg-navy min-h-screen pt-32 pb-24 px-[5%] transition-colors">
        <Reveal>
          <div className="max-w-xl mx-auto text-center mb-10">
            <p className="text-[11px] font-medium tracking-[0.12em] text-brand-gray dark:text-white/50 mb-3">
              MULAI PERJALANAN ANDA
            </p>
            <h1 className="font-display text-navy dark:text-white text-[clamp(28px,4vw,42px)] leading-[1.2] mb-4">
              Daftar &amp; Berlangganan
            </h1>
            <p className="text-base text-brand-gray dark:text-white/55 leading-[1.7]">
              Buat akun, pilih program yang sesuai, dan mulai latih sistem tubuh
              Anda hari ini.
            </p>
          </div>
        </Reveal>

        <Reveal delay={0.1}>
          <RegisterForm />
        </Reveal>
      </main>
      <Footer />
    </>
  );
}
