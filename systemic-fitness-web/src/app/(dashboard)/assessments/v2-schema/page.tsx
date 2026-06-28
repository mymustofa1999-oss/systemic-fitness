"use client";

import {
  ClipboardCheck, Activity, Apple, Moon, AlertTriangle, ArrowRight, Eye,
} from "lucide-react";
import { cn } from "@/lib/utils";

// SF Phase 3 — Skema Asesmen v2 (preview form layout).
//
// Halaman ini menampilkan pertanyaan + pilihan persis seperti yang dilihat
// klien di mobile app — tapi dalam mode preview / read-only. Tujuannya:
// admin & Consultant bisa simulasi bagaimana asesmen v2 terlihat sebelum
// klien mengisinya. Bukan editor — pertanyaan masih hard-coded di engine
// (lihat systemic-fitness-api/internal/service/assessment_v2_engine.go).

export default function AssessmentV2SchemaPage() {
  return (
    <div className="space-y-6 bg-sf-warmWhite min-h-full -m-6 p-6 rounded-xl">
      {/* Header */}
      <div className="flex items-start justify-between gap-4">
        <div>
          <p className="font-dm-sans text-xs uppercase tracking-widest text-sf-warmGold">
            PREVIEW ASESMEN
          </p>
          <h1 className="sf-headline text-3xl mt-1">Asesmen v2 — Phase A · B · C</h1>
          <p className="sf-body text-sm text-slate-500 mt-1 max-w-3xl">
            Tampilan ini adalah preview pertanyaan yang akan klien isi dari mobile app.
            Admin dapat simulasi pilihan untuk memahami flow — pilihan tidak tersimpan ke DB.
          </p>
        </div>
        <div className="hidden md:flex items-center gap-2 bg-sf-iceBlue px-3 py-1.5 rounded-full">
          <Eye className="h-3.5 w-3.5 text-sf-systemBlue" />
          <span className="font-dm-sans text-xs text-sf-systemBlue">Read-only</span>
        </div>
      </div>

      {/* Phase A */}
      <PhaseHeader index="A" title="Penilaian Kondisi" subtitle="3 pertanyaan · ~2 menit" icon={ClipboardCheck} accent="text-sf-warmGold" />

      <FormCard
        no="A1"
        label="Bagaimana kondisi gerak Anda saat ini?"
        description="Pilih yang paling mendekati keadaan sekarang."
      >
        <RadioGroup
          options={[
            { value: "level_0_1", label: "Saya hanya bisa berbaring atau duduk. Berdiri sendiri sangat sulit.", note: "Level 0–1 → Waitlist program" },
            { value: "level_2_3", label: "Saya bisa berdiri, tapi berjalan masih terbatas atau butuh bantuan.", note: "Level 2–3 → Waitlist program" },
            { value: "level_4_5_perf", label: "Saya bisa berjalan, tapi gerakan fisik saya masih sangat terbatas dan stamina rendah.", note: "Level 4–5 / Performance → Lanjut ke Q2" },
          ]}
        />
      </FormCard>

      <FormCard
        no="A2"
        label="Apakah Anda memiliki kondisi medis yang sedang ditangani?"
        description="Jawaban ini membantu kami mencocokkan Anda dengan program yang tepat."
      >
        <RadioGroup
          options={[
            { value: "yes_serious", label: "Ya — kondisi serius atau khusus lainnya", note: "Akan diminta deskripsi singkat & program perlu Consultant approve." },
            { value: "yes_known", label: "Ya — ada gangguan kesehatan dengan diagnosis", note: "Lanjut pilih klasifikasi → kondisi spesifik." },
            { value: "yes_unknown", label: "Ya, tapi belum tahu pasti diagnosanya", note: "Diarahkan ke Konsultasi Online Gratis 15 menit." },
            { value: "no", label: "Tidak ada kondisi medis aktif", note: "Lanjut pilih gender → usia → Performance Program." },
          ]}
        />
      </FormCard>

      {/* Sub-form cabang Q2: klasifikasi */}
      <FormCard
        no="A2.1"
        label="(Cabang) Pilih klasifikasi kondisi"
        description="Hanya muncul kalau A2 = Ya. Master 5 klasifikasi dari /master/condition-classifications."
        muted
      >
        <RadioGroup
          options={[
            { value: "imun-inflamasi", label: "Imun & Inflamasi", note: "Autoimun · Alergi kronis · Inflamasi sistemik · Kista · Tumor jinak" },
            { value: "renal-uric", label: "Renal & Uric System", note: "Gangguan ginjal (CKD 1–3) · Asam urat · Hiperkalemia ringan" },
            { value: "cardiorespiratory", label: "Cardiorespiratory", note: "Hipertensi · Penyakit jantung · Asma · PPOK · Kolesterol" },
            { value: "metabolic", label: "Metabolic", note: "Diabetes T2 · PCOS · Tiroid · Pre-diabetes · Resistensi insulin" },
            { value: "musculoskeletal", label: "Musculoskeletal", note: "Osteoarthritis · Osteoporosis · HNP · Frozen shoulder · Neuropati" },
          ]}
        />
        <p className="font-dm-sans text-xs text-slate-500 mt-3 italic">
          Setelah memilih klasifikasi, klien diminta pilih kondisi spesifik (sub-list dari master).
        </p>
      </FormCard>

      {/* Sub-form cabang Q2: gender + usia */}
      <FormCard
        no="A2.2"
        label="(Cabang) Pilih program & kelompok usia"
        description="Hanya muncul kalau A2 = Tidak ada kondisi medis."
        muted
      >
        <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
          <div>
            <p className="font-dm-sans text-xs uppercase tracking-wider text-slate-500 mb-2">Pilih program</p>
            <RadioGroup
              options={[
                { value: "women", label: "Program Wanita", note: "Optimasi hormon, stamina & vitalitas feminitas" },
                { value: "men", label: "Program Pria", note: "Optimasi testosteron, massa otot & stamina maskulin" },
              ]}
            />
          </div>
          <div>
            <p className="font-dm-sans text-xs uppercase tracking-wider text-slate-500 mb-2">Kelompok usia</p>
            <RadioGroup
              options={[
                { value: "35_45", label: "35–45 tahun" },
                { value: "46_60", label: "46–60 tahun" },
              ]}
            />
          </div>
        </div>
      </FormCard>

      <FormCard
        no="A3"
        label="Apa yang paling ingin Anda capai?"
        description="Hanya untuk klien dengan kondisi medis di A2."
      >
        <RadioGroup
          options={[
            { value: "control_medical", label: "Mengontrol kondisi medis saya", note: "Full Program 60 mnt 2×/minggu + Daily Reset 30 mnt 2–3×/minggu" },
            { value: "hormonal_feminine", label: "Menyeimbangkan hormon dan feminitas saya", note: "Performance Program Wanita" },
            { value: "stamina_masculine", label: "Meningkatkan stamina dan performa fisik pria", note: "Performance Program Pria" },
          ]}
        />
      </FormCard>

      <PhaseOutcome>
        <strong className="font-dm-sans text-sm text-sf-charcoal">Output Phase A:</strong>{" "}
        <span className="font-dm-sans text-sm text-slate-600">
          Program Type ditentukan otomatis (Condition-Specific / Preventive / Performance W/M 35–45 / 46–60 / Waitlist).
          Routing ke Phase B kecuali Level 0–3 (waitlist) atau Preventive (basic movement test dulu).
        </span>
      </PhaseOutcome>

      {/* Phase B */}
      <PhaseHeader index="B" title="Rest Audit & Chronobiology" subtitle="10 pertanyaan · ~3 menit" icon={Moon} accent="text-sf-systemBlue" />

      <FormCard no="B1" label="Rata-rata berapa jam Anda tidur per malam?">
        <SliderPreview
          min={4} max={10} step={0.5}
          stops={[
            { v: 4, label: "4.0" },
            { v: 6, label: "6.0" },
            { v: 7, label: "7.0", highlight: true },
            { v: 8, label: "8.0", highlight: true },
            { v: 9, label: "9.0" },
            { v: 10, label: "10.0" },
          ]}
        />
        <p className="font-dm-sans text-xs text-slate-500 mt-2 italic">
          Kurang dari 6 jam → flag <code className="font-dm-mono">REST_RECOVERY_ALERT</code>. Bobot maks: 22 poin.
        </p>
      </FormCard>

      <FormCard no="B2" label="Seberapa konsisten jam tidur dan bangun Anda setiap hari?" weight={18}>
        <RadioGroup
          options={[
            { value: 1, label: "Sangat tidak teratur — berbeda lebih dari 2 jam setiap hari" },
            { value: 2, label: "Kadang berubah — berbeda sekitar 1–2 jam" },
            { value: 3, label: "Teratur setiap hari — hampir selalu di jam yang sama" },
          ]}
        />
      </FormCard>

      <FormCard
        no="B3"
        label="Berapa lama biasanya Anda butuh untuk tertidur setelah berbaring?"
        description="Indikator kortisol & gula darah malam."
        weight={15}
      >
        <RadioGroup
          options={[
            { value: 1, label: "Kurang dari 15 menit — langsung mengantuk (optimal)" },
            { value: 2, label: "15–30 menit — cukup normal" },
            { value: 3, label: "30–45 menit — agak sulit tidur" },
            { value: 4, label: "Lebih dari 45 menit — sulit sekali tidur", note: "Trigger override Chronobiology ke sore (kecuali kondisi hard-lock)" },
          ]}
        />
      </FormCard>

      <FormCard
        no="B4"
        label="Bagaimana perasaan Anda saat bangun pagi?"
        description="Menentukan apakah opsi pagi valid untuk jadwal sesi."
        weight={15}
      >
        <RadioGroup
          options={[
            { value: 1, label: "Lelah / pusing — tidak terasa sudah tidur", note: "Hapus opsi pagi dari Chronobiology Window" },
            { value: 2, label: "Biasa saja — butuh beberapa menit untuk segar" },
            { value: 3, label: "Segar & langsung bertenaga" },
          ]}
        />
      </FormCard>

      <FormCard
        no="B5"
        label="Seberapa sering Anda terbangun di tengah malam?"
        description="Indikator hipertensi atau fluktuasi gula darah."
        weight={15}
      >
        <RadioGroup
          options={[
            { value: 1, label: "Tidak pernah — tidur nyenyak sampai pagi" },
            { value: 2, label: "1–2 kali — bisa tidur lagi dengan mudah" },
            { value: 3, label: "3+ kali — sering terbangun" },
            { value: 4, label: "Sering terbangun dan sulit tidur lagi" },
          ]}
        />
      </FormCard>

      <FormCard no="B6" label="Apa yang biasanya Anda lakukan 1 jam sebelum tidur?" weight={15}>
        <RadioGroup
          options={[
            { value: 1, label: "Gadget aktif / kerja / makan berat / pikiran sibuk" },
            { value: 2, label: "Campuran — kadang santai, kadang masih aktif" },
            { value: 3, label: "Rutinitas relaksasi — baca, meditasi, stretching ringan" },
          ]}
        />
      </FormCard>

      <FormCard
        no="B7"
        label="Biasanya Anda tidur jam berapa malam?"
        description="Dasar perhitungan 5-Hour Recovery Window."
      >
        <RadioGroup
          options={[
            { value: 1, label: "Sebelum jam 21.00", note: "Window ideal: 15.30–16.00" },
            { value: 2, label: "Jam 21.00–22.00", note: "Window ideal: 16.00–17.00" },
            { value: 3, label: "Jam 22.00–23.00", note: "Window ideal: 17.00–18.00" },
            { value: 4, label: "Jam 23.00–00.00", note: "Window ideal: 18.00–19.00" },
            { value: 5, label: "Setelah jam 00.00", note: "Window ideal: 19.00–20.00 (hard cap 21.00)" },
          ]}
        />
      </FormCard>

      <FormCard no="B8" label="Biasanya Anda bangun jam berapa?">
        <RadioGroup
          options={[
            { value: 1, label: "Sebelum jam 05.00" },
            { value: 2, label: "Jam 05.00–06.00" },
            { value: 3, label: "Jam 06.00–07.00" },
            { value: 4, label: "Jam 07.00–08.00" },
            { value: 5, label: "Setelah jam 08.00" },
          ]}
        />
      </FormCard>

      <FormCard
        no="B9"
        label="Mana yang paling menggambarkan rutinitas harian Anda?"
        description="Menentukan window waktu yang realistis bisa digunakan."
      >
        <RadioGroup
          options={[
            { value: "executive", label: "Pekerja eksekutif / kantoran — jadwal rutin, pagi sampai sore" },
            { value: "creative", label: "Pekerja kreatif / freelancer — jam kerja tidak menentu" },
            { value: "traveller", label: "Frequent traveller — sering beda zona waktu", note: "Anchor sore 15.00–17.00 lokal" },
            { value: "homemaker", label: "Ibu rumah tangga — aktif pagi, fleksibel siang" },
            { value: "shift_worker", label: "Pekerja shift — siang sampai malam atau malam sampai pagi", note: "OVERRIDE ke malam 19.00–20.30 (hard cap 21.00)" },
            { value: "mixed", label: "Campuran / tidak menentu" },
          ]}
        />
      </FormCard>

      <FormCard
        no="B10"
        label="Biasanya Anda makan malam jam berapa?"
        description="Makan malam larut + sleep latency tinggi = sinyal gula darah spike."
      >
        <RadioGroup
          options={[
            { value: 1, label: "Sebelum jam 18.00" },
            { value: 2, label: "Jam 18.00–19.00" },
            { value: 3, label: "Jam 19.00–20.00" },
            { value: 4, label: "Setelah jam 20.00", note: "Bila B3 ≥ 30 mnt → flag META_BLOOD_SUGAR_RISK" },
            { value: 5, label: "Tidak menentu / sering skip" },
          ]}
        />
      </FormCard>

      <PhaseOutcome>
        <strong className="font-dm-sans text-sm text-sf-charcoal">Output Phase B:</strong>{" "}
        <span className="font-dm-sans text-sm text-slate-600">
          Rest Score (jumlah B1–B6, max 100) + Chronobiology Window personal.
        </span>
      </PhaseOutcome>

      <ChronobiologyHierarchy />

      {/* Phase C */}
      <PhaseHeader index="C" title="Pola Makan & Gizi" subtitle="7 pertanyaan · ~2 menit" icon={Apple} accent="text-sf-deepTeal" />

      <FormCard no="C1" label="Bagaimana gambaran pola makan Anda sehari-hari?" weight={20}>
        <RadioGroup
          options={[
            { value: 1, label: "Makan besar 3 kali sehari, jarang snack" },
            { value: 2, label: "Makan 4–5 kali dalam porsi lebih kecil" },
            { value: 3, label: "Sering skip makan — tidak teratur" },
            { value: 4, label: "Intermittent fasting — ada jeda makan tertentu (mis. 16/8)" },
            { value: 5, label: "Tidak ada pola tetap" },
          ]}
        />
      </FormCard>

      <FormCard no="C2" label="Apa yang paling sering ada di piring Anda?" weight={20}>
        <RadioGroup
          options={[
            { value: 1, label: "Nasi / karbohidrat sebagai porsi terbesar" },
            { value: 2, label: "Protein (ayam, ikan, telur, daging) sebagai fokus utama" },
            { value: 3, label: "Sayur dan buah mendominasi" },
            { value: 4, label: "Campuran seimbang antara karbo, protein, dan sayur" },
            { value: 5, label: "Makanan olahan / fast food cukup sering" },
          ]}
        />
      </FormCard>

      <FormCard
        no="C3"
        label="Berapa gelas air putih yang biasanya Anda minum per hari?"
        description="1 gelas = 250 ml."
        weight={20}
      >
        <RadioGroup
          options={[
            { value: 1, label: "Kurang dari 4 gelas (< 1 liter) — sangat kurang", note: "+ kondisi ginjal/asam urat → flag RENAL_HYDRATION_CRITICAL" },
            { value: 2, label: "4–6 gelas (1–1.5 liter) — kurang" },
            { value: 3, label: "7–8 gelas (1.75–2 liter) — cukup" },
            { value: 4, label: "Lebih dari 8 gelas (> 2 liter) — baik" },
          ]}
        />
      </FormCard>

      <FormCard
        no="C4"
        label="Pilih semua yang sering ada dalam konsumsi harian Anda."
        description="Boleh pilih lebih dari satu."
        weight={20}
      >
        <CheckboxGroup
          options={[
            { value: "coffee", label: "Kopi (1+ cangkir per hari)" },
            { value: "sweet_drinks", label: "Teh manis atau minuman manis lainnya" },
            { value: "soda_energy", label: "Minuman bersoda / energi drink" },
            { value: "alcohol", label: "Alkohol" },
            { value: "fried", label: "Makanan digoreng / berminyak" },
            { value: "high_salt", label: "Makanan tinggi garam (keripik, acar, saus instan)" },
            { value: "organ_meat", label: "Jeroan (hati, ampela, dll)" },
            { value: "seafood", label: "Seafood (udang, cumi, kerang, dll)" },
            { value: "dairy", label: "Susu & produk susu (keju, yogurt, es krim)" },
            { value: "fermented", label: "Makanan fermentasi (tape, kimchi, tempe, dll)" },
          ]}
        />
        <p className="font-dm-sans text-xs text-slate-500 mt-2 italic">
          Item risiko (jeroan, seafood, alkohol, soda, gorengan, tinggi garam, sweet drinks) menurunkan Nutrition Score.
        </p>
      </FormCard>

      <FormCard
        no="C5"
        label="Apakah Anda memiliki pantangan atau alergi makanan tertentu?"
        description="Filter untuk seluruh rekomendasi gizi. Boleh pilih lebih dari satu + isi catatan bebas."
        weight={5}
      >
        <CheckboxGroup
          options={[
            { value: "none", label: "Tidak ada" },
            { value: "specific_allergy", label: "Alergi spesifik" },
            { value: "religious", label: "Pantangan agama / keyakinan (halal, vegan, vegetarian, dll)" },
            { value: "lactose", label: "Intoleransi laktosa" },
            { value: "gluten", label: "Intoleransi / sensitivitas gluten" },
            { value: "other", label: "Pantangan lainnya" },
          ]}
        />
        <TextInputPreview placeholder="Tuliskan detail alergi atau pantangan lain (opsional)…" />
      </FormCard>

      <FormCard
        no="C6"
        label="Suplemen / obat yang sedang Anda konsumsi"
        description="Memberi konteks tambahan untuk Health Consultant."
        weight={5}
      >
        <CheckboxGroup
          options={[
            { value: "none", label: "Tidak ada" },
            { value: "multivitamin", label: "Multivitamin umum" },
            { value: "vitamin_d", label: "Vitamin D" },
            { value: "omega_3", label: "Omega-3 / Fish oil" },
            { value: "protein", label: "Suplemen protein (whey, plant-based)" },
            { value: "other", label: "Suplemen spesifik lainnya" },
            { value: "rx_metabolic", label: "Obat dokter yang mempengaruhi metabolisme" },
          ]}
        />
        <TextInputPreview placeholder="Sebutkan nama suplemen / obat lain (opsional)…" />
      </FormCard>

      <FormCard no="C7" label="Apa yang paling ingin Anda perbaiki dari pola makan?" weight={10}>
        <RadioGroup
          options={[
            { value: "blood_sugar", label: "Mengontrol gula darah dan metabolisme" },
            { value: "anti_inflammation", label: "Mengurangi peradangan, bloating, dan ketidaknyamanan pencernaan" },
            { value: "energy_vitality", label: "Meningkatkan energi dan vitalitas sepanjang hari" },
            { value: "hormonal_balance", label: "Mendukung keseimbangan hormonal" },
            { value: "weight", label: "Menjaga berat badan yang sehat" },
            { value: "muscle_recovery", label: "Mendukung performa, pemulihan otot, dan kebugaran" },
            { value: "organ_health", label: "Mendukung kesehatan organ spesifik (ginjal, jantung, dll)" },
          ]}
        />
      </FormCard>

      <PhaseOutcome>
        <strong className="font-dm-sans text-sm text-sf-charcoal">Output Phase C:</strong>{" "}
        <span className="font-dm-sans text-sm text-slate-600">
          Nutrition Score (weighted average C1–C7). C5 & C6 tidak mempengaruhi score, hanya filter guidance.
        </span>
      </PhaseOutcome>

      <SystemScoreSection />
      <FlagsSection />
    </div>
  );
}

// ════════════════════════════════════════════════════════════════════
//  Form preview building blocks
// ════════════════════════════════════════════════════════════════════

function PhaseHeader({
  index, title, subtitle, icon: Icon, accent,
}: {
  index: string;
  title: string;
  subtitle: string;
  icon: React.ComponentType<{ className?: string }>;
  accent: string;
}) {
  return (
    <div className="flex items-center gap-3 pt-2">
      <div className={`h-10 w-10 rounded-full bg-sf-iceBlue flex items-center justify-center ${accent}`}>
        <Icon className="h-5 w-5" />
      </div>
      <div>
        <p className="font-dm-sans text-[11px] uppercase tracking-widest text-slate-400">
          Phase {index}
        </p>
        <h2 className="sf-headline text-xl">{title}</h2>
        <p className="font-dm-sans text-xs text-slate-500">{subtitle}</p>
      </div>
    </div>
  );
}

function FormCard({
  no, label, description, weight, muted, children,
}: {
  no: string;
  label: string;
  description?: string;
  weight?: number;
  muted?: boolean;
  children: React.ReactNode;
}) {
  return (
    <div
      className={cn(
        "card p-5 sm:p-6",
        muted ? "bg-sf-iceBlue/40 border-dashed border-2 border-sf-systemBlue/20" : "bg-white",
      )}
    >
      <div className="flex items-start justify-between gap-4 mb-3">
        <div className="flex items-baseline gap-3">
          <span className="font-dm-mono text-xs text-sf-warmGoldDark whitespace-nowrap mt-0.5">
            {no}
          </span>
          <div>
            <p className="font-dm-sans text-base font-medium text-sf-charcoal leading-snug">
              {label}
            </p>
            {description && (
              <p className="font-dm-sans text-xs text-slate-500 mt-1">{description}</p>
            )}
          </div>
        </div>
        {weight !== undefined && (
          <span className="inline-flex items-center px-2 py-0.5 rounded-full bg-sf-warmGold/10 text-sf-warmGoldDark font-dm-mono text-[11px] whitespace-nowrap">
            bobot {weight}%
          </span>
        )}
      </div>
      <div className="pl-7 sm:pl-8">{children}</div>
    </div>
  );
}

interface OptionDef {
  value: string | number;
  label: string;
  note?: string;
}

/** Radio button preview — semua opsi terlihat, none selected. */
function RadioGroup({ options }: { options: OptionDef[] }) {
  return (
    <ul className="space-y-2">
      {options.map((o) => (
        <li
          key={String(o.value)}
          className="flex items-start gap-3 rounded-lg border border-slate-200 hover:border-sf-systemBlue/40 hover:bg-sf-iceBlue/30 p-3 transition-colors cursor-default"
        >
          <span className="h-5 w-5 rounded-full border-2 border-slate-300 bg-white shrink-0 mt-0.5" />
          <div>
            <p className="font-dm-sans text-sm text-sf-charcoal">{o.label}</p>
            {o.note && (
              <p className="font-dm-sans text-xs text-slate-500 mt-0.5 italic">→ {o.note}</p>
            )}
          </div>
        </li>
      ))}
    </ul>
  );
}

/** Checkbox preview — multi-select, none checked. */
function CheckboxGroup({ options }: { options: OptionDef[] }) {
  return (
    <ul className="grid grid-cols-1 sm:grid-cols-2 gap-2">
      {options.map((o) => (
        <li
          key={String(o.value)}
          className="flex items-center gap-3 rounded-lg border border-slate-200 hover:border-sf-systemBlue/40 hover:bg-sf-iceBlue/30 p-3 transition-colors cursor-default"
        >
          <span className="h-5 w-5 rounded border-2 border-slate-300 bg-white shrink-0" />
          <p className="font-dm-sans text-sm text-sf-charcoal">{o.label}</p>
        </li>
      ))}
    </ul>
  );
}

/** Slider preview untuk B1 (durasi tidur). */
function SliderPreview({
  min, max, step, stops,
}: {
  min: number;
  max: number;
  step: number;
  stops: { v: number; label: string; highlight?: boolean }[];
}) {
  return (
    <div className="space-y-3">
      <div className="relative">
        <div className="h-1.5 rounded-full bg-slate-200" />
        <div className="absolute inset-0 flex items-center">
          <div className="w-full flex justify-between">
            {stops.map((s, i) => (
              <div key={i} className="flex flex-col items-center">
                <div
                  className={cn(
                    "h-3 w-3 rounded-full -mt-0.5",
                    s.highlight ? "bg-sf-warmGold ring-2 ring-sf-warmGold/30" : "bg-slate-300",
                  )}
                />
              </div>
            ))}
          </div>
        </div>
      </div>
      <div className="flex justify-between font-dm-mono text-[11px] text-slate-500">
        {stops.map((s, i) => (
          <span key={i} className={s.highlight ? "text-sf-warmGoldDark font-medium" : ""}>
            {s.label}
          </span>
        ))}
      </div>
      <p className="font-dm-sans text-xs text-slate-500">
        Geser untuk menyesuaikan · range {min}–{max} jam · increment {step} jam
      </p>
    </div>
  );
}

function TextInputPreview({ placeholder }: { placeholder: string }) {
  return (
    <div className="mt-3">
      <input
        type="text"
        readOnly
        placeholder={placeholder}
        className="w-full px-3 py-2.5 rounded-lg border border-slate-200 text-sm bg-slate-50 text-slate-400 placeholder:text-slate-400 cursor-default font-dm-sans"
      />
    </div>
  );
}

function PhaseOutcome({ children }: { children: React.ReactNode }) {
  return (
    <div className="rounded-xl border-l-4 border-sf-warmGold bg-sf-warmGold/5 px-4 py-3">
      {children}
    </div>
  );
}

// ════════════════════════════════════════════════════════════════════
//  Existing meta sections (Chronobiology, System Score, Flags)
// ════════════════════════════════════════════════════════════════════

function ChronobiologyHierarchy() {
  const steps = [
    { title: "1. Kondisi medis", body: "Base window dari klasifikasi/specific-condition (mis. Hipertensi → 15:00–17:00 LOCK SORE)." },
    { title: "2. B9 Activity Profile", body: "shift_worker → 19:00–20:30 · traveller → 15:00–17:00 anchor." },
    { title: "3. B3 Sleep Latency", body: "&gt;45 mnt → geser ke sore (kecuali kondisi sudah hard-lock sore)." },
    { title: "4. B4 Morning Readiness", body: "Lelah/pusing → hapus opsi pagi (kecuali hard-lock sore)." },
  ];
  return (
    <section className="card p-6 bg-sf-deepNavy border-sf-deepNavy text-white">
      <h2 className="sf-headline text-xl text-white">Hierarki Override Chronobiology</h2>
      <p className="font-dm-sans text-sm text-white/70 mt-1">
        Engine resolver mengikuti urutan ini. Kondisi yang hard-lock sore (Hipertensi, Penyakit Jantung,
        Asma, Autoimun, HNP, dst.) tidak bisa digeser ke pagi oleh Phase B.
      </p>
      <ol className="mt-4 space-y-2">
        {steps.map((s, i) => (
          <li key={i} className="flex gap-3">
            <ArrowRight className="h-4 w-4 text-sf-warmGold mt-0.5 shrink-0" />
            <div>
              <p className="font-dm-sans text-sm font-medium text-white">{s.title}</p>
              <p className="font-dm-sans text-xs text-white/60" dangerouslySetInnerHTML={{ __html: s.body }} />
            </div>
          </li>
        ))}
      </ol>
    </section>
  );
}

function SystemScoreSection() {
  return (
    <section className="card p-6 bg-white">
      <div className="flex items-center gap-3">
        <Activity className="h-5 w-5 text-sf-warmGold" />
        <h2 className="sf-headline text-xl">System Score</h2>
      </div>
      <p className="font-dm-sans text-sm text-slate-500 mt-1">
        Weighted average tiga dimensi. Bila Movement belum ada (klien baru, belum sesi),
        engine reweight Nutrition + Rest agar System Score tetap dapat dihitung.
      </p>
      <div className="mt-4 grid grid-cols-3 gap-3">
        <DimensionTile
          icon={Activity}
          label="Movement"
          color="bg-sf-deepTeal text-white"
          desc="Completion rate sesi · movement test · progress metrics"
        />
        <DimensionTile
          icon={Apple}
          label="Nutrition"
          color="bg-sf-systemBlue text-white"
          desc="Phase C · konsistensi update pola makan"
        />
        <DimensionTile
          icon={Moon}
          label="Rest"
          color="bg-sf-warmGold text-white"
          desc="Phase B · post-session sleep feedback · konsistensi log"
        />
      </div>
      <p className="font-dm-sans text-xs text-slate-500 mt-4">
        Bobot default <span className="font-dm-mono">35 / 35 / 30</span> (lihat menu{" "}
        <a className="text-sf-systemBlue underline" href="/system-score">Bobot System Score</a>{" "}
        untuk owner-tunable).
      </p>
    </section>
  );
}

function DimensionTile({
  icon: Icon, label, color, desc,
}: {
  icon: React.ComponentType<{ className?: string }>;
  label: string;
  color: string;
  desc: string;
}) {
  return (
    <div className="rounded-xl overflow-hidden">
      <div className={`p-4 ${color}`}>
        <Icon className="h-5 w-5 mb-1 opacity-80" />
        <p className="font-dm-sans text-sm font-medium">{label}</p>
      </div>
      <p className="px-4 py-3 font-dm-sans text-xs text-slate-600 bg-sf-iceBlue/40">{desc}</p>
    </div>
  );
}

function FlagsSection() {
  const flags = [
    { code: "WAITLIST_LEVEL_0_3", desc: "Level 0–1 / 2–3 — program belum tersedia, klien masuk waitlist." },
    { code: "REST_RECOVERY_ALERT", desc: "Durasi tidur &lt;6 jam + wake frequency ≥3 — pertimbangkan turunkan intensitas sesi." },
    { code: "META_BLOOD_SUGAR_RISK", desc: "Makan malam &gt;20:00 + sleep latency ≥30 mnt — sinyal gula darah spike malam." },
    { code: "RENAL_HYDRATION_CRITICAL", desc: "Hidrasi &lt;4 gelas + kondisi CKD/asam urat/batu ginjal — flag utama untuk Consultant." },
  ];
  return (
    <section className="card p-6 bg-white">
      <div className="flex items-center gap-3">
        <AlertTriangle className="h-5 w-5 text-amber-500" />
        <h2 className="sf-headline text-xl">Flags klinis</h2>
      </div>
      <p className="font-dm-sans text-sm text-slate-500 mt-1">
        Engine memunculkan flag berikut. Consultant dashboard akan memprioritaskan klien dengan flag aktif.
      </p>
      <ul className="mt-4 space-y-2">
        {flags.map((f) => (
          <li key={f.code} className="flex gap-3 items-baseline">
            <span className="font-dm-mono text-[11px] bg-amber-50 text-amber-700 px-2 py-0.5 rounded-full whitespace-nowrap">
              {f.code}
            </span>
            <span className="font-dm-sans text-xs text-slate-600" dangerouslySetInnerHTML={{ __html: f.desc }} />
          </li>
        ))}
      </ul>
    </section>
  );
}
