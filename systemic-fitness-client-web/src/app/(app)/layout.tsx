"use client";

import { useSession } from "next-auth/react";
import { useRouter, usePathname } from "next/navigation";
import { useEffect, useState } from "react";
import { BottomNav } from "@/components/layout/BottomNav";
import { AppHeader } from "@/components/layout/AppHeader";
import { ThemeProvider } from "@/components/ThemeProvider";
import { Loader2 } from "lucide-react";
import { useMySubscription } from "@/hooks/useSubscription";
import { useQuery } from "@tanstack/react-query";
import { apiGet, apiPut } from "@/lib/api";

export default function AppLayout({ children }: { children: React.ReactNode }) {
  const { data: session, status } = useSession();
  const router = useRouter();
  const pathname = usePathname();
  const { isFree, isLoading: isSubLoading } = useMySubscription();

  const { data: assessmentRes, isLoading: isAssLoading } = useQuery({
    queryKey: ["latest-assessment"],
    queryFn: async () => {
      try {
        return await apiGet<any>("/api/v2/assessments/latest");
      } catch (err: any) {
        const msg = err.message?.toLowerCase() || "";
        if (msg.includes("not found") || msg.includes("no v2 assessment") || msg.includes("404")) {
          return { success: true, data: null };
        }
        throw err;
      }
    },
    retry: false,
    refetchOnMount: false,
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
    staleTime: Infinity,
    gcTime: Infinity,
    enabled: status === "authenticated",
  });

  const { data: cardRes, isLoading: isCardLoading } = useQuery({
    queryKey: ["client-training-card"],
    queryFn: async () => {
      try {
        return await apiGet<any>("/api/v2/assessments/training-card");
      } catch (err: any) {
        return { success: true, data: null };
      }
    },
    retry: false,
    refetchOnMount: false,
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
    staleTime: Infinity,
    gcTime: Infinity,
    enabled: status === "authenticated",
  });

  // Profile completeness check for client role
  const { data: profileRes, isLoading: isProfileLoading, refetch: refetchProfile } = useQuery({
    queryKey: ["profile-me"],
    queryFn: () => apiGet<any>("/api/auth/me"),
    enabled: status === "authenticated" && session?.user?.role === "client",
    retry: false,
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
    staleTime: 60_000,
  });

  const profile = profileRes?.data?.profile;
  const isProfileComplete = !session || session.user.role !== "client" || (
    profile &&
    profile.date_of_birth &&
    profile.gender &&
    profile.weight_kg &&
    profile.height_cm &&
    profile.date_of_birth !== "" &&
    profile.gender !== "" &&
    profile.weight_kg > 0 &&
    profile.height_cm > 0 &&
    profile.regional &&
    profile.city &&
    profile.regional !== "" &&
    profile.city !== "" &&
    profile.street_address &&
    profile.sub_district &&
    profile.district &&
    profile.province &&
    profile.postal_code &&
    profile.country
  );

  const hasAssessment = !!assessmentRes?.data;
  const hasCard = !!cardRes?.data;
  const isLayoutLoading = isSubLoading || isAssLoading || isCardLoading || (status === "authenticated" && session?.user?.role === "client" && isProfileLoading);

  const [dob, setDob] = useState("");
  const [gender, setGender] = useState("");
  const [weight, setWeight] = useState("");
  const [height, setHeight] = useState("");
  const [regional, setRegional] = useState("");
  const [city, setCity] = useState("");
  const [streetAddress, setStreetAddress] = useState("");
  const [additionalAddress, setAdditionalAddress] = useState("");
  const [subDistrict, setSubDistrict] = useState("");
  const [district, setDistrict] = useState("");
  const [province, setProvince] = useState("");
  const [postalCode, setPostalCode] = useState("");
  const [country, setCountry] = useState("Indonesia");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState("");
  const [lang, setLang] = useState("id");

  // Detect browser language on mount
  useEffect(() => {
    if (typeof window !== "undefined" && window.navigator) {
      const browserLang = window.navigator.language;
      if (browserLang && browserLang.toLowerCase().startsWith("en")) {
        setLang("en");
      }
    }
  }, []);

  const t = {
    id: {
      title: "Lengkapi Profil Anda",
      subtitle: "Sebelum melanjutkan, Anda wajib melengkapi data profil berikut sebagai acuan perhitungan beban latihan (load/weight reference) pada Training Card Anda.",
      dob: "Tanggal Lahir",
      gender: "Jenis Kelamin",
      genderPlaceholder: "Pilih Jenis Kelamin...",
      male: "Pria",
      female: "Wanita",
      weight: "Berat Badan (kg)",
      weightPlaceholder: "Contoh: 70.5",
      height: "Tinggi Badan (cm)",
      heightPlaceholder: "Contoh: 170",
      regional: "Regional",
      regionalPlaceholder: "Contoh: Jabodetabek / Jawa Barat",
      city: "Asal Kota",
      cityPlaceholder: "Contoh: Jakarta Selatan",
      streetAddress: "Alamat Jalan",
      streetAddressPlaceholder: "Contoh: Jl. Sudirman No. 1, RT 01/RW 02",
      additionalAddress: "Detail Tambahan Alamat",
      additionalAddressPlaceholder: "Contoh: Apartemen, Lantai, Unit",
      optional: "opsional",
      subDistrict: "Kelurahan/Desa",
      subDistrictPlaceholder: "Contoh: Senayan",
      district: "Kecamatan",
      districtPlaceholder: "Contoh: Kebayoran Baru",
      province: "Provinsi",
      provincePlaceholder: "Contoh: DKI Jakarta",
      postalCode: "Kode Pos",
      postalCodePlaceholder: "Contoh: 12190",
      country: "Negara",
      countryPlaceholder: "Contoh: Indonesia",
      saving: "Menyimpan...",
      saveBtn: "Simpan & Lanjutkan",
      errorRequired: "Mohon lengkapi semua data.",
      errorWeight: "Berat badan harus lebih besar dari 0.",
      errorHeight: "Tinggi badan harus lebih besar dari 0.",
      errorFailed: "Gagal memperbarui profil."
    },
    en: {
      title: "Complete Your Profile",
      subtitle: "Before continuing, you are required to complete the following profile data as a reference for calculating the workout load (load/weight reference) on your Training Card.",
      dob: "Date of Birth",
      gender: "Gender",
      genderPlaceholder: "Select Gender...",
      male: "Male",
      female: "Female",
      weight: "Weight (kg)",
      weightPlaceholder: "Example: 70.5",
      height: "Height (cm)",
      heightPlaceholder: "Example: 170",
      regional: "Regional",
      regionalPlaceholder: "Example: Jabodetabek",
      city: "City of Origin",
      cityPlaceholder: "Example: South Jakarta",
      streetAddress: "Street Address",
      streetAddressPlaceholder: "Example: Jl. Sudirman No. 1",
      additionalAddress: "Additional Address",
      additionalAddressPlaceholder: "Example: Apartment, Floor, Unit",
      optional: "optional",
      subDistrict: "Sub-district / Village",
      subDistrictPlaceholder: "Example: Senayan",
      district: "District",
      districtPlaceholder: "Example: Kebayoran Baru",
      province: "Province",
      provincePlaceholder: "Example: DKI Jakarta",
      postalCode: "Postal Code",
      postalCodePlaceholder: "Example: 12190",
      country: "Country",
      countryPlaceholder: "Example: Indonesia",
      saving: "Saving...",
      saveBtn: "Save & Continue",
      errorRequired: "Please complete all fields.",
      errorWeight: "Weight must be greater than 0.",
      errorHeight: "Height must be greater than 0.",
      errorFailed: "Failed to update profile."
    }
  }[lang as "id" | "en"];

  // Sync state with profile data once loaded
  useEffect(() => {
    if (profile) {
      if (profile.date_of_birth) setDob(profile.date_of_birth.substring(0, 10)); // YYYY-MM-DD format
      if (profile.gender) setGender(profile.gender);
      if (profile.weight_kg) setWeight(profile.weight_kg.toString());
      if (profile.height_cm) setHeight(profile.height_cm.toString());
      if (profile.regional) setRegional(profile.regional);
      if (profile.city) setCity(profile.city);
      if (profile.street_address) setStreetAddress(profile.street_address);
      if (profile.additional_address) setAdditionalAddress(profile.additional_address);
      if (profile.sub_district) setSubDistrict(profile.sub_district);
      if (profile.district) setDistrict(profile.district);
      if (profile.province) setProvince(profile.province);
      if (profile.postal_code) setPostalCode(profile.postal_code);
      if (profile.country) setCountry(profile.country);
    }
  }, [profile]);

  useEffect(() => {
    if (status === "unauthenticated") {
      router.replace("/login");
    }
  }, [status, router]);

  useEffect(() => {
    if (status === "authenticated" && !isLayoutLoading && isProfileComplete) {
      let isAllowed = true;

      if (!hasAssessment && !hasCard) {
        // If no assessment AND no card, they cannot access training card or assessment results
        if (pathname.startsWith("/training-card") || pathname.startsWith("/assessment/result")) {
          isAllowed = false;
        }
      } else if (hasAssessment) {
        // If they already have an assessment, they shouldn't access the assessment taking pages
        if (pathname === "/assessment" || pathname.startsWith("/assessment/phase")) {
          isAllowed = false;
        }
      }

      if (!isAllowed) {
        router.replace(hasAssessment ? "/dashboard" : "/assessment");
      }
    }
  }, [status, isLayoutLoading, hasAssessment, hasCard, isProfileComplete, pathname, router]);

  // Loading state
  if (status === "loading" || (status === "authenticated" && isLayoutLoading)) {
    return (
      <div className="min-h-screen bg-sf-warmWhite flex items-center justify-center">
        <div className="text-center animate-fade-in">
          <div className="w-14 h-14 mx-auto mb-4 rounded-2xl bg-gradient-to-br from-sf-warmGold to-sf-warmGoldDark flex items-center justify-center shadow-glow-gold animate-pulse-soft">
            <span className="text-white font-heading text-xl">SF</span>
          </div>
          <Loader2 size={24} className="animate-spin text-sf-warmGold mx-auto" />
          <p className="text-sm text-gray-400 mt-3">Memuat...</p>
        </div>
      </div>
    );
  }

  // Not authenticated
  if (!session) return null;

  // Profile blocking modal if client profile details are incomplete
  if (status === "authenticated" && !isLayoutLoading && !isProfileComplete) {
    const handleProfileSubmit = async (e: React.FormEvent) => {
      e.preventDefault();
      if (!dob || !gender || !weight || !height || !regional || !city || !streetAddress || !subDistrict || !district || !province || !postalCode || !country) {
        setSubmitError(t.errorRequired);
        return;
      }
      const weightNum = parseFloat(weight);
      if (isNaN(weightNum) || weightNum <= 0) {
        setSubmitError(t.errorWeight);
        return;
      }
      const heightNum = parseFloat(height);
      if (isNaN(heightNum) || heightNum <= 0) {
        setSubmitError(t.errorHeight);
        return;
      }
      setIsSubmitting(true);
      setSubmitError("");
      try {
        await apiPut(`/api/users/${session.user.id}`, {
          date_of_birth: dob,
          gender: gender,
          weight_kg: weightNum,
          height_cm: heightNum,
          regional: regional,
          city: city,
          street_address: streetAddress,
          additional_address: additionalAddress,
          sub_district: subDistrict,
          district: district,
          province: province,
          postal_code: postalCode,
          country: country,
        });
        refetchProfile();
      } catch (err: any) {
        setSubmitError(err.message || t.errorFailed);
      } finally {
        setIsSubmitting(false);
      }
    };

    return (
      <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
        <div className="fixed inset-0 z-[9999] bg-slate-900/90 backdrop-blur-md overflow-y-auto">
          <div className="min-h-full flex items-center justify-center p-4 py-8">
            <div className="bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-3xl w-full max-w-md md:max-w-2xl p-6 shadow-soft shadow-glow-gold/10">
            <div className="flex justify-between items-center mb-4">
              <div className="w-10 h-10 rounded-xl bg-sf-warmGold/10 flex items-center justify-center">
                <span className="text-sf-warmGold font-bold text-base">SF</span>
              </div>
              <button
                type="button"
                onClick={() => setLang(lang === "id" ? "en" : "id")}
                className="px-2.5 py-1 text-[10px] font-bold rounded-lg border border-slate-200 dark:border-slate-800 text-slate-600 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors"
              >
                {lang === "id" ? "ENGLISH" : "INDONESIA"}
              </button>
            </div>
            <h2 className="text-xl font-bold text-sf-deepNavy dark:text-white mb-2">{t.title}</h2>
            <p className="text-xs text-slate-500 dark:text-slate-400 mb-6 leading-relaxed">
              {t.subtitle}
            </p>

            <form onSubmit={handleProfileSubmit} className="space-y-4 text-left">
              {submitError && (
                <div className="p-3 text-xs bg-rose-50 text-rose-600 rounded-xl border border-rose-100 font-medium">
                  {submitError}
                </div>
              )}

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-bold text-slate-600 dark:text-slate-400 uppercase tracking-wider mb-1.5">
                  {t.dob}
                </label>
                <input
                  type="date"
                  required
                  value={dob}
                  onChange={(e) => setDob(e.target.value)}
                  className="w-full border border-slate-200 dark:border-slate-700 rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-sf-warmGold/40 bg-slate-50 dark:bg-slate-800 text-slate-900 dark:text-white"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-600 dark:text-slate-400 uppercase tracking-wider mb-1.5">
                  {t.gender}
                </label>
                <select
                  required
                  value={gender}
                  onChange={(e) => setGender(e.target.value)}
                  className="w-full border border-slate-200 dark:border-slate-700 rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-sf-warmGold/40 bg-slate-50 dark:bg-slate-800 text-slate-900 dark:text-white"
                >
                  <option value="" className="bg-slate-50 dark:bg-slate-800 text-slate-900 dark:text-white">{t.genderPlaceholder}</option>
                  <option value="male" className="bg-slate-50 dark:bg-slate-800 text-slate-900 dark:text-white">{t.male}</option>
                  <option value="female" className="bg-slate-50 dark:bg-slate-800 text-slate-900 dark:text-white">{t.female}</option>
                </select>
              </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-bold text-slate-600 dark:text-slate-400 uppercase tracking-wider mb-1.5">
                  {t.weight}
                </label>
                <input
                  type="number"
                  step="0.1"
                  required
                  placeholder={t.weightPlaceholder}
                  value={weight}
                  onChange={(e) => setWeight(e.target.value)}
                  className="w-full border border-slate-200 dark:border-slate-700 rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-sf-warmGold/40 bg-slate-50 dark:bg-slate-800 text-slate-900 dark:text-white"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-600 dark:text-slate-400 uppercase tracking-wider mb-1.5">
                  {t.height}
                </label>
                <input
                  type="number"
                  step="0.1"
                  required
                  placeholder={t.heightPlaceholder}
                  value={height}
                  onChange={(e) => setHeight(e.target.value)}
                  className="w-full border border-slate-200 dark:border-slate-700 rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-sf-warmGold/40 bg-slate-50 dark:bg-slate-800 text-slate-900 dark:text-white"
                />
              </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-600 dark:text-slate-400 uppercase tracking-wider mb-1.5">
                  {t.regional}
                </label>
                <input
                  type="text"
                  required
                  placeholder={t.regionalPlaceholder}
                  value={regional}
                  onChange={(e) => setRegional(e.target.value)}
                  className="w-full border border-slate-200 dark:border-slate-700 rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-sf-warmGold/40 bg-slate-50 dark:bg-slate-800 text-slate-900 dark:text-white"
                />
              </div>

              <div className="pt-2">
                <div className="h-px bg-slate-200 dark:bg-slate-700 w-full mb-4"></div>
                <h3 className="text-sm font-bold text-sf-deepNavy dark:text-white mb-4">Alamat Tempat Tinggal</h3>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-600 dark:text-slate-400 uppercase tracking-wider mb-1.5">
                  {t.streetAddress}
                </label>
                <input
                  type="text"
                  required
                  placeholder={t.streetAddressPlaceholder}
                  value={streetAddress}
                  onChange={(e) => setStreetAddress(e.target.value)}
                  className="w-full border border-slate-200 dark:border-slate-700 rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-sf-warmGold/40 bg-slate-50 dark:bg-slate-800 text-slate-900 dark:text-white"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-600 dark:text-slate-400 uppercase tracking-wider mb-1.5">
                  {t.additionalAddress} <span className="text-slate-400 font-normal capitalize">({t.optional})</span>
                </label>
                <input
                  type="text"
                  placeholder={t.additionalAddressPlaceholder}
                  value={additionalAddress}
                  onChange={(e) => setAdditionalAddress(e.target.value)}
                  className="w-full border border-slate-200 dark:border-slate-700 rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-sf-warmGold/40 bg-slate-50 dark:bg-slate-800 text-slate-900 dark:text-white"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-600 dark:text-slate-400 uppercase tracking-wider mb-1.5">
                    {t.subDistrict}
                  </label>
                  <input
                    type="text"
                    required
                    placeholder={t.subDistrictPlaceholder}
                    value={subDistrict}
                    onChange={(e) => setSubDistrict(e.target.value)}
                    className="w-full border border-slate-200 dark:border-slate-700 rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-sf-warmGold/40 bg-slate-50 dark:bg-slate-800 text-slate-900 dark:text-white"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-600 dark:text-slate-400 uppercase tracking-wider mb-1.5">
                    {t.district}
                  </label>
                  <input
                    type="text"
                    required
                    placeholder={t.districtPlaceholder}
                    value={district}
                    onChange={(e) => setDistrict(e.target.value)}
                    className="w-full border border-slate-200 dark:border-slate-700 rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-sf-warmGold/40 bg-slate-50 dark:bg-slate-800 text-slate-900 dark:text-white"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-600 dark:text-slate-400 uppercase tracking-wider mb-1.5">
                    {t.city}
                  </label>
                  <input
                    type="text"
                    required
                    placeholder={t.cityPlaceholder}
                    value={city}
                    onChange={(e) => setCity(e.target.value)}
                    className="w-full border border-slate-200 dark:border-slate-700 rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-sf-warmGold/40 bg-slate-50 dark:bg-slate-800 text-slate-900 dark:text-white"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-600 dark:text-slate-400 uppercase tracking-wider mb-1.5">
                    {t.province}
                  </label>
                  <input
                    type="text"
                    required
                    placeholder={t.provincePlaceholder}
                    value={province}
                    onChange={(e) => setProvince(e.target.value)}
                    className="w-full border border-slate-200 dark:border-slate-700 rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-sf-warmGold/40 bg-slate-50 dark:bg-slate-800 text-slate-900 dark:text-white"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-600 dark:text-slate-400 uppercase tracking-wider mb-1.5">
                    {t.postalCode}
                  </label>
                  <input
                    type="text"
                    required
                    placeholder={t.postalCodePlaceholder}
                    value={postalCode}
                    onChange={(e) => setPostalCode(e.target.value)}
                    className="w-full border border-slate-200 dark:border-slate-700 rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-sf-warmGold/40 bg-slate-50 dark:bg-slate-800 text-slate-900 dark:text-white"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-600 dark:text-slate-400 uppercase tracking-wider mb-1.5">
                    {t.country}
                  </label>
                  <input
                    type="text"
                    required
                    placeholder={t.countryPlaceholder}
                    value={country}
                    onChange={(e) => setCountry(e.target.value)}
                    className="w-full border border-slate-200 dark:border-slate-700 rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-sf-warmGold/40 bg-slate-50 dark:bg-slate-800 text-slate-900 dark:text-white"
                  />
                </div>
              </div>

              <button
                type="submit"
                disabled={isSubmitting}
                className="w-full mt-6 py-3.5 bg-gradient-to-r from-sf-warmGold to-sf-warmGoldDark hover:opacity-90 disabled:opacity-50 text-white font-bold text-sm rounded-2xl flex items-center justify-center gap-2 shadow-glow-gold transition-all duration-200"
              >
                {isSubmitting ? (
                  <>
                    <Loader2 size={16} className="animate-spin" />
                    {t.saving}
                  </>
                ) : (
                  t.saveBtn
                )}
              </button>
            </form>
          </div>
        </div>
        </div>
      </ThemeProvider>
    );
  }

  return (
    <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
      <div className="min-h-screen bg-bg-primary transition-colors duration-200">
        <AppHeader />
        <main className="pb-24 max-w-lg mx-auto">
          {children}
        </main>
        <BottomNav />
      </div>
    </ThemeProvider>
  );
}
