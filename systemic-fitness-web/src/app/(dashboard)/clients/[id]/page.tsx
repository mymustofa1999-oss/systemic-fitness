"use client";

import { useState, useMemo, useEffect } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import { useUser, useUpdateUser } from "@/hooks/useUsers";
import { useTeam } from "@/hooks/useNewFeatures";
import {
  useCustomerSetup,
  useUpsertHRZone,
  useAddCustomerMedicine,
  useRemoveCustomerMedicine,
  useUpsertCustomerProgram,
  useRemoveCustomerProgram,
  useMedicines,
  useProgramCategories,
  useJournalSessions,
  useJournalMonths,
  useUpsertJournalSession,
  useFoods,
  useAssignStaff,
  useUpdateCustomerPriority,
} from "@/hooks/useNewFeatures";
import { useLatestAssessmentV2, type AssessmentV2 } from "@/hooks/useAssessmentV2";
import { useSubscriptionPlans, useCreateManualSubscription, useUpdateSubscriptionAttachment } from "@/hooks/useSubscription";
import { useAuth } from "@/hooks/useAuth";
import { MedicinesCard } from "@/components/shared/MedicinesCard";
import { apiGet } from "@/lib/api";
import axios from "axios";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { SearchableSelect } from "@/components/shared/SearchableSelect";
import {
  ArrowLeft, Plus, Trash2, Save, Loader2, Check, X, ChevronDown, Info, Pill, ExternalLink, ClipboardCheck,
  Crown, Star, Zap, Clock, CreditCard, FileText, User, Activity, Phone, ActivitySquare, Upload, File, ClipboardList
} from "lucide-react";
import { cn, formatCurrency, formatDate } from "@/lib/utils";

// ── Page ────────────────────────────────────────────────────────

export default function ClientDetailPage({ params }: { params: { id: string } }) {
  // Trainers may only view the Training Card, not the full client admin page.
  // Send them straight to the read-only training card.
  const { isTrainer } = useAuth();
  const router = useRouter();
  useEffect(() => {
    if (isTrainer) router.replace(`/clients/${params.id}/training-card`);
  }, [isTrainer, params.id, router]);

  const { data, isLoading } = useUser(params.id);
  const { data: setupData, isLoading: setupLoading } = useCustomerSetup(params.id);
  const { data: assessResp } = useLatestAssessmentV2(params.id);

  const detail = data?.data as any;
  const user = detail?.user;
  const profile = detail?.profile;
  const setup = setupData?.data as any;
  const assessmentData = assessResp?.data as AssessmentV2 | undefined;

  // Calculate age from DOB
  const age = useMemo(() => {
    if (!profile?.date_of_birth) return null;
    const dob = new Date(profile.date_of_birth);
    const now = new Date();
    let a = now.getFullYear() - dob.getFullYear();
    if (now.getMonth() < dob.getMonth() || (now.getMonth() === dob.getMonth() && now.getDate() < dob.getDate())) a--;
    return a;
  }, [profile?.date_of_birth]);

  if (isTrainer) return <PageSkeleton />; // redirecting to training card
  if (isLoading || setupLoading) return <PageSkeleton />;
  if (!user) {
    return (
      <div className="text-center py-20">
        <p className="text-slate-500">Client tidak ditemukan</p>
        <Link href="/clients" className="text-sf-deepNavy hover:text-sf-deepNavy text-sm mt-2 inline-block">Kembali ke Clients</Link>
      </div>
    );
  }

  return (
    <div className="space-y-6 pb-20">
      <Link href="/clients" className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-slate-700">
        <ArrowLeft className="h-4 w-4" /> Kembali ke Clients
      </Link>

      {/* ═══ 1. HERO PROFILE & QUICK ACTIONS ═══ */}
      <div className="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm">
        {/* Top Dark Banner */}
        <div className="bg-sf-deepNavy px-6 py-6 text-white flex flex-col md:flex-row md:items-end justify-between gap-4 relative overflow-hidden">
           <div className="absolute top-0 right-0 opacity-10 pointer-events-none">
              <Crown className="w-64 h-64 -mt-16 -mr-16" />
           </div>
           
           <div className="relative z-10">
              <h1 className="text-2xl font-bold mb-2 capitalize">{user.full_name}</h1>
              <div className="flex flex-wrap items-center gap-4 text-sm text-slate-300">
                <span className="flex items-center gap-1.5"><User className="h-4 w-4 text-sf-warmGold" /> {age ? `${age} tahun` : "-"} • {profile?.gender || "-"}</span>
                <span className="flex items-center gap-1.5"><ActivitySquare className="h-4 w-4 text-sf-warmGold" /> {profile?.height_cm || "-"} cm • {profile?.weight_kg || "-"} kg</span>
                <span className="flex items-center gap-1.5"><Phone className="h-4 w-4 text-sf-warmGold" /> {user.phone || "-"}</span>
              </div>
           </div>
        </div>

        {/* Quick Actions Bar */}
        <div className="bg-slate-50 border-t border-slate-100 p-4">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
             <Link href={`/clients/${params.id}/training-card`} className="bg-sf-deepNavy text-white hover:bg-slate-800 transition-colors rounded-xl p-3 flex items-center justify-between group shadow-sm">
               <div className="flex items-center gap-3">
                 <div className="bg-white/20 p-2 rounded-lg"><ClipboardCheck className="h-5 w-5 text-white" /></div>
                 <div className="text-left">
                   <p className="text-sm font-bold">Training Card</p>
                   <p className="text-[10px] text-slate-300">Set & lihat program latihan</p>
                 </div>
               </div>
               <ChevronDown className="h-4 w-4 text-slate-400 -rotate-90 group-hover:text-white transition-colors" />
             </Link>
             <Link href={`/clients/${params.id}/systemic-session-log`} className="bg-white border border-slate-200 hover:border-sf-deepNavy transition-colors rounded-xl p-3 flex items-center justify-between group shadow-sm">
                <div className="flex items-center gap-3">
                  <div className="p-2 rounded-lg bg-slate-100 text-sf-deepNavy group-hover:bg-sf-deepNavy/10 transition-colors"><ClipboardList className="h-5 w-5" /></div>
                  <div className="text-left">
                    <p className="text-sm font-bold text-slate-900">SYSTEMIC SESSION LOG</p>
                    <p className="text-[10px] text-slate-500">Record Meds, Vitals, Symptoms, & Habits</p>
                  </div>
                </div>
                <ChevronDown className="h-4 w-4 text-slate-300 -rotate-90 group-hover:text-sf-deepNavy transition-colors" />
              </Link>
             <Link href={`/clients/${params.id}/systemic-assessment`} className="bg-white border border-slate-200 hover:border-green-600 transition-colors rounded-xl p-3 flex items-center justify-between group shadow-sm">
               <div className="flex items-center gap-3">
                 <div className="p-2 rounded-lg bg-green-50 text-green-600 group-hover:bg-green-100 transition-colors"><FileText className="h-5 w-5" /></div>
                 <div className="text-left">
                   <p className="text-sm font-bold text-slate-900">Systemic Assesment</p>
                   <p className="text-[10px] text-slate-500">Quarterly Review (24 Sessions)</p>
                 </div>
               </div>
               <ChevronDown className="h-4 w-4 text-slate-300 -rotate-90 group-hover:text-green-600 transition-colors" />
             </Link>
          </div>
        </div>
      </div>

      {/* ═══ 2. MAIN GRID (LEFT: INFO/MEDIS/TIM | RIGHT: LANGGANAN/JURNAL) ═══ */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        
        {/* LEFT COLUMN (70%) */}
        <div className="lg:col-span-8 space-y-6">
          
          {/* Detail Profil & Edit */}
          <div>
            <h2 className="text-sm font-bold text-slate-800 uppercase tracking-wider mb-3 flex items-center gap-2">
              <User className="h-4 w-4 text-sf-deepNavy" /> Detail Profil
            </h2>
            <ClientInfoCard userId={params.id} user={user} profile={profile} age={age} />
          </div>

          {/* Daftar Obat */}
          <div>
             <div className="mb-6">
               <MedicinesCard customerId={params.id} data={setup?.medicines ?? []} />
             </div>
          </div>

          {/* Tim Penanganan */}
          <div>
             <h2 className="text-sm font-bold text-slate-800 uppercase tracking-wider mb-3 flex items-center gap-2">
               <Crown className="h-4 w-4 text-sf-warmGold" /> Tim Penanganan
             </h2>
              <div className="space-y-4">
                <StaffCard customerId={params.id} staff={setup?.staff} profile={profile} />
              </div>
          </div>
        </div>

        {/* RIGHT COLUMN (30%) */}
        <div className="lg:col-span-4 space-y-6">
           <ClientSubscriptionSection clientId={params.id} clientName={user.full_name} />
        </div>

      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
//  Client Info Card (editable)
// ═══════════════════════════════════════════════════════════════

function ClientInfoCard({ userId, user, profile, age }: { userId: string; user: any; profile: any; age: number | null }) {
  const { mutate: updateUser, isPending } = useUpdateUser();
  const [editing, setEditing] = useState(false);

  function initForm() {
    return {
      full_name: user.full_name ?? "",
      phone: user.phone ?? "",
      date_of_birth: profile?.date_of_birth ?? "",
      gender: profile?.gender ?? "",
      height_cm: profile?.height_cm ?? "",
      weight_kg: profile?.weight_kg ?? "",
      medical_notes: profile?.medical_notes ?? "",
      regional: profile?.regional ?? "",
      city: profile?.city ?? "",
      street_address: profile?.street_address ?? "",
      additional_address: profile?.additional_address ?? "",
      sub_district: profile?.sub_district ?? "",
      district: profile?.district ?? "",
      province: profile?.province ?? "",
      postal_code: profile?.postal_code ?? "",
      country: profile?.country ?? "Indonesia",
    };
  }
  const [form, setForm] = useState(initForm);

  // Re-sync form when props change (after save + refetch)
  const propsKey = `${user.full_name}|${user.phone}|${profile?.date_of_birth}|${profile?.gender}|${profile?.height_cm}|${profile?.weight_kg}|${profile?.medical_notes}|${profile?.regional}|${profile?.city}|${profile?.street_address}|${profile?.additional_address}|${profile?.sub_district}|${profile?.district}|${profile?.province}|${profile?.postal_code}|${profile?.country}`;
  useEffect(() => {
    if (!editing) setForm(initForm());
  }, [propsKey]);

  function handleSave() {
    updateUser({ id: userId, data: {
      full_name: form.full_name,
      phone: form.phone || undefined,
      date_of_birth: form.date_of_birth || undefined,
      gender: form.gender || undefined,
      height_cm: form.height_cm ? Number(form.height_cm) : undefined,
      weight_kg: form.weight_kg ? Number(form.weight_kg) : undefined,
      medical_notes: form.medical_notes || undefined,
      regional: form.regional || undefined,
      city: form.city || undefined,
      street_address: form.street_address || undefined,
      additional_address: form.additional_address || undefined,
      sub_district: form.sub_district || undefined,
      district: form.district || undefined,
      province: form.province || undefined,
      postal_code: form.postal_code || undefined,
      country: form.country || undefined,
    }}, { onSuccess: () => setEditing(false) });
  }

  const lbl = "px-3 py-2 font-semibold text-slate-500 bg-slate-50 w-28 text-xs";
  const val = "px-3 py-2 text-slate-700 text-sm";
  const inp = "w-full border border-slate-200 rounded px-2 py-1 text-sm focus:outline-none focus:ring-1 focus:ring-sf-warmGold/40";

  return (
    <div className="bg-white overflow-hidden border border-slate-200 shadow-sm rounded-xl">
      <div className="flex items-center justify-between px-3 py-2 bg-slate-50 border-b border-slate-100">
        <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Info Client</span>
        {!editing ? (
          <button onClick={() => setEditing(true)} className="text-xs text-sf-deepNavy hover:text-sf-deepNavy font-medium">Edit</button>
        ) : (
          <div className="flex gap-1.5">
            <button onClick={() => setEditing(false)} className="text-xs text-slate-500 hover:text-slate-700 font-medium">Batal</button>
            <button onClick={handleSave} disabled={isPending} className="text-xs text-sf-deepNavy hover:text-sf-deepNavy font-medium flex items-center gap-1">
              {isPending ? <Loader2 className="h-3 w-3 animate-spin" /> : <Save className="h-3 w-3" />} Simpan
            </button>
          </div>
        )}
      </div>
      <table className="w-full text-sm">
        <tbody>
          <tr className="border-b border-slate-100">
            <td className={lbl}>Nama</td>
            <td className={val} colSpan={3}>{editing ? <input value={form.full_name} onChange={(e) => setForm({ ...form, full_name: e.target.value })} className={inp} /> : user.full_name}</td>
          </tr>
          <tr className="border-b border-slate-100">
            <td className={lbl}>Tgl Lahir</td>
            <td className={val} colSpan={3}>{editing ? <input type="date" value={form.date_of_birth} onChange={(e) => setForm({ ...form, date_of_birth: e.target.value })} className={inp} /> : (profile?.date_of_birth || "-")}</td>
          </tr>
          <tr className="border-b border-slate-100">
            <td className={lbl}>Usia</td>
            <td className={cn(val, "font-bold")} colSpan={3}>{age ?? "-"}</td>
          </tr>
          <tr className="border-b border-slate-100">
            <td className={lbl}>Gender</td>
            <td className={val} colSpan={3}>{editing ? (
              <SearchableSelect
                options={[{ value: "", label: "-" }, { value: "male", label: "Male" }, { value: "female", label: "Female" }, { value: "other", label: "Other" }]}
                value={form.gender}
                onChange={(v) => setForm({ ...form, gender: v })}
                placeholder="Select gender..."
              />
            ) : (profile?.gender || "-")}</td>
          </tr>
          <tr className="border-b border-slate-100">
            <td className={lbl}>Tinggi</td>
            <td className={val} colSpan={3}>{editing ? <input type="number" value={form.height_cm} onChange={(e) => setForm({ ...form, height_cm: e.target.value })} className={inp} placeholder="cm" /> : (profile?.height_cm ? `${profile.height_cm} cm` : "-")}</td>
          </tr>
          <tr className="border-b border-slate-100">
            <td className={lbl}>Berat</td>
            <td className={val} colSpan={3}>{editing ? <input type="number" value={form.weight_kg} onChange={(e) => setForm({ ...form, weight_kg: e.target.value })} className={inp} placeholder="kg" /> : (profile?.weight_kg ? `${profile.weight_kg} kg` : "-")}</td>
          </tr>
          <tr className="border-b border-slate-100">
            <td className={lbl}>Alamat Jalan</td>
            <td className={val} colSpan={3}>{editing ? <input type="text" value={form.street_address} onChange={(e) => setForm({ ...form, street_address: e.target.value })} className={inp} placeholder="Alamat lengkap (nama jalan, rt/rw, nomor)" /> : (profile?.street_address || "-")}</td>
          </tr>
          <tr className="border-b border-slate-100">
            <td className={lbl}>Detail Tambahan</td>
            <td className={val} colSpan={3}>{editing ? <input type="text" value={form.additional_address} onChange={(e) => setForm({ ...form, additional_address: e.target.value })} className={inp} placeholder="Apartemen, lantai, dsb" /> : (profile?.additional_address || "-")}</td>
          </tr>
          <tr className="border-b border-slate-100">
            <td className={lbl}>Kelurahan</td>
            <td className={val} colSpan={3}>{editing ? <input type="text" value={form.sub_district} onChange={(e) => setForm({ ...form, sub_district: e.target.value })} className={inp} placeholder="Kelurahan" /> : (profile?.sub_district || "-")}</td>
          </tr>
          <tr className="border-b border-slate-100">
            <td className={lbl}>Kecamatan</td>
            <td className={val} colSpan={3}>{editing ? <input type="text" value={form.district} onChange={(e) => setForm({ ...form, district: e.target.value })} className={inp} placeholder="Kecamatan" /> : (profile?.district || "-")}</td>
          </tr>
          <tr className="border-b border-slate-100">
            <td className={lbl}>Asal Kota</td>
            <td className={val} colSpan={3}>{editing ? <input type="text" value={form.city} onChange={(e) => setForm({ ...form, city: e.target.value })} className={inp} placeholder="Asal Kota" /> : (profile?.city || "-")}</td>
          </tr>
          <tr className="border-b border-slate-100">
            <td className={lbl}>Provinsi</td>
            <td className={val} colSpan={3}>{editing ? <input type="text" value={form.province} onChange={(e) => setForm({ ...form, province: e.target.value })} className={inp} placeholder="Provinsi" /> : (profile?.province || "-")}</td>
          </tr>
          <tr className="border-b border-slate-100">
            <td className={lbl}>Kode Pos</td>
            <td className={val} colSpan={3}>{editing ? <input type="text" value={form.postal_code} onChange={(e) => setForm({ ...form, postal_code: e.target.value })} className={inp} placeholder="Kode Pos" /> : (profile?.postal_code || "-")}</td>
          </tr>
          <tr className="border-b border-slate-100">
            <td className={lbl}>Negara</td>
            <td className={val} colSpan={3}>{editing ? <input type="text" value={form.country} onChange={(e) => setForm({ ...form, country: e.target.value })} className={inp} placeholder="Negara" /> : (profile?.country || "-")}</td>
          </tr>
          <tr className="border-b border-slate-100">
            <td className={lbl}>Regional</td>
            <td className={val} colSpan={3}>{editing ? <input type="text" value={form.regional} onChange={(e) => setForm({ ...form, regional: e.target.value })} className={inp} placeholder="Regional" /> : (profile?.regional || "-")}</td>
          </tr>
          <tr className="border-b border-slate-100">
            <td className={lbl}>Telepon</td>
            <td className={val} colSpan={3}>{editing ? <input value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} className={inp} /> : (user.phone || "-")}</td>
          </tr>
          {(editing || profile?.medical_notes) && (
            <tr>
              <td className={lbl}>Medis</td>
              <td className={val} colSpan={3}>{editing ? <textarea value={form.medical_notes} onChange={(e) => setForm({ ...form, medical_notes: e.target.value })} className={cn(inp, "h-16")} /> : (profile?.medical_notes || "-")}</td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
//  Staff Card (Consultant + Trainer + Prioritas, editable)
// ═══════════════════════════════════════════════════════════════

function StaffCard({ customerId, staff, profile }: { customerId: string; staff: any; profile: any }) {
  const { data: teamData } = useTeam({ limit: 100 });
  const teamMembers = (teamData?.data ?? []) as any[];
  const assignStaff = useAssignStaff();
  const updateUser = useUpdateUser();

  function handleAssign(staffId: string, roleType: string) {
    if (!staffId) return;
    assignStaff.mutate({ customerId, staff_id: staffId, role_type: roleType });
  }

  function handleClassChange(e: React.ChangeEvent<HTMLSelectElement>) {
    const val = e.target.value;
    updateUser.mutate({ id: customerId, data: { classification: val } });
  }

  const staffOptions = teamMembers.map((m: any) => ({
    value: m.id, label: m.full_name, sublabel: m.role,
  }));

  const lbl = "px-3 py-2.5 font-semibold text-slate-500 bg-slate-50 text-xs border-r border-slate-100";
  const val = "px-3 py-2.5";

  return (
    <div className="bg-white overflow-hidden border border-slate-200 shadow-sm rounded-xl">
      <table className="w-full text-sm">
        <tbody>
          {/* Consultant */}
          <tr className="border-b border-slate-100">
            <td className={cn(lbl, "w-24")}>Consultant</td>
            <td colSpan={3} className={val}>
              <SearchableSelect
                options={staffOptions}
                value={staff?.consultant_id || ""}
                onChange={(v) => v && handleAssign(v, "consultant")}
                placeholder="- Pilih Consultant -"
                searchPlaceholder="Cari nama..."
                disabled={assignStaff.isPending}
              />
            </td>
          </tr>
          {/* Certified Trainer */}
          <tr className="border-b border-slate-100">
            <td className={cn(lbl, "w-24")}>Certified Trainer</td>
            <td colSpan={3} className={val}>
              <SearchableSelect
                options={staffOptions}
                value={staff?.trainer_id || ""}
                onChange={(v) => v && handleAssign(v, "trainer")}
                placeholder="- Pilih Certified Trainer -"
                searchPlaceholder="Cari nama..."
                disabled={assignStaff.isPending}
              />
            </td>
          </tr>
          {/* Client Classification */}
          <tr>
            <td className={cn(lbl, "w-24 align-middle")}>Classification</td>
            <td colSpan={3} className={val}>
              <select
                value={profile?.classification || ""}
                onChange={handleClassChange}
                disabled={updateUser.isPending}
                className="w-full border border-slate-200 rounded px-2 py-2 text-sm focus:outline-none focus:ring-1 focus:ring-sf-warmGold/40 bg-white"
              >
                <option value="">- Pilih Classification -</option>
                <option value="personal">Personal</option>
                <option value="group">Group</option>
                <option value="online">Online</option>
              </select>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
//  HR Zone Card (table layout like spreadsheet)
// ═══════════════════════════════════════════════════════════════

function HRZoneCard({ customerId, data }: { customerId: string; data: any }) {
  const upsert = useUpsertHRZone();
  const [editing, setEditing] = useState(false);
  const [form, setForm] = useState(() => initHRForm(data));

  function initHRForm(d: any) {
    return {
      max_hr_upper: d?.max_hr_upper ?? "", max_hr_lower: d?.max_hr_lower ?? "",
      zone5_upper: d?.zone5_upper ?? "", zone5_lower: d?.zone5_lower ?? "",
      zone4_upper: d?.zone4_upper ?? "", zone4_lower: d?.zone4_lower ?? "",
      zone3_upper: d?.zone3_upper ?? "", zone3_lower: d?.zone3_lower ?? "",
      zone2_upper: d?.zone2_upper ?? "", zone2_lower: d?.zone2_lower ?? "",
      zone1_upper: d?.zone1_upper ?? "", zone1_lower: d?.zone1_lower ?? "",
    };
  }

  function handleSave() {
    const payload: Record<string, unknown> = { customerId };
    for (const [k, v] of Object.entries(form)) {
      payload[k] = v === "" ? null : Number(v);
    }
    upsert.mutate(payload as any, {
      onSuccess: () => setEditing(false),
    });
  }

  const zones = [
    { label: "Max HR", upper: "max_hr_upper", lower: "max_hr_lower", bg: "bg-red-100 text-red-800" },
    { label: "Zona 5", upper: "zone5_upper", lower: "zone5_lower", bg: "bg-red-50 text-red-700" },
    { label: "Zona 4", upper: "zone4_upper", lower: "zone4_lower", bg: "bg-orange-50 text-orange-700" },
    { label: "Zona 3", upper: "zone3_upper", lower: "zone3_lower", bg: "bg-yellow-50 text-yellow-700" },
    { label: "Zona 2", upper: "zone2_upper", lower: "zone2_lower", bg: "bg-green-50 text-green-700" },
    { label: "Zona 1", upper: "zone1_upper", lower: "zone1_lower", bg: "bg-blue-50 text-blue-700" },
  ];

  return (
    <div className="bg-white overflow-hidden border border-slate-200 shadow-sm rounded-xl">
      <div className="flex items-center justify-between px-3 py-2 bg-slate-50 border-b border-slate-100">
        <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">HR Zone</span>
        {!editing ? (
          <button onClick={() => { setForm(initHRForm(data)); setEditing(true); }} className="text-xs text-sf-deepNavy hover:text-sf-deepNavy font-medium">Edit</button>
        ) : (
          <div className="flex gap-1.5">
            <button onClick={() => setEditing(false)} className="text-xs text-slate-500 hover:text-slate-700 font-medium">Batal</button>
            <button onClick={handleSave} disabled={upsert.isPending} className="text-xs text-sf-deepNavy hover:text-sf-deepNavy font-medium flex items-center gap-1">
              {upsert.isPending ? <Loader2 className="h-3 w-3 animate-spin" /> : <Save className="h-3 w-3" />} Simpan
            </button>
          </div>
        )}
      </div>
      <table className="w-full text-sm">
        <tbody>
          {zones.map((z) => (
            <tr key={z.label} className="border-b border-slate-50 last:border-0">
              <td className={cn("px-3 py-1.5 font-semibold text-xs w-20", z.bg)}>{z.label}</td>
              {editing ? (
                <>
                  <td className="px-1 py-1">
                    <input type="number" value={(form as any)[z.upper]}
                      onChange={(e) => setForm({ ...form, [z.upper]: e.target.value })}
                      className="w-full border border-slate-200 rounded px-2 py-1 text-sm text-center focus:outline-none focus:ring-1 focus:ring-sf-warmGold/40" />
                  </td>
                  <td className="px-1 py-1">
                    <input type="number" value={(form as any)[z.lower]}
                      onChange={(e) => setForm({ ...form, [z.lower]: e.target.value })}
                      className="w-full border border-slate-200 rounded px-2 py-1 text-sm text-center focus:outline-none focus:ring-1 focus:ring-sf-warmGold/40" />
                  </td>
                </>
              ) : (
                <>
                  <td className="px-3 py-1.5 text-center font-mono text-slate-800">{(data as any)?.[z.upper] ?? "-"}</td>
                  <td className="px-3 py-1.5 text-center font-mono text-slate-800">{(data as any)?.[z.lower] ?? "-"}</td>
                </>
              )}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}



// ═══════════════════════════════════════════════════════════════
//  Programs Card (table with checkboxes like spreadsheet)
// ═══════════════════════════════════════════════════════════════

function ProgramsCard({ customerId, data }: { customerId: string; data: any[] }) {
  const [showAdd, setShowAdd] = useState(false);
  const [removeTarget, setRemoveTarget] = useState<any>(null);

  const upsert = useUpsertCustomerProgram();
  const remove = useRemoveCustomerProgram();
  const { data: allCats } = useProgramCategories({ limit: 50 });
  const categories = (allCats?.data ?? []) as any[];

  const [form, setForm] = useState({
    program_category_id: "",
    bpm_upper: "", bpm_lower: "",
    beban_upper_value: "", beban_lower_value: "",
    has_resistance: false,
    parameter_notes: "",
  });

  const selectedCat = categories.find((c: any) => c.id === form.program_category_id);
  const paramTemplate = selectedCat?.parameter_template ?? {};

  function handleAdd() {
    if (!form.program_category_id) return;
    const bebanUpper = form.beban_upper_value ? Number(form.beban_upper_value) : null;
    const bebanLower = form.beban_lower_value ? Number(form.beban_lower_value) : null;
    upsert.mutate({
      customerId,
      program_category_id: form.program_category_id,
      is_active: true,
      bpm_upper: form.bpm_upper ? Number(form.bpm_upper) : null,
      bpm_lower: form.bpm_lower ? Number(form.bpm_lower) : null,
      has_beban_upper: bebanUpper != null && bebanUpper > 0,
      has_beban_lower: bebanLower != null && bebanLower > 0,
      beban_upper_value: bebanUpper,
      beban_lower_value: bebanLower,
      has_resistance: form.has_resistance,
      parameter_notes: form.parameter_notes || undefined,
    }, {
      onSuccess: () => {
        setShowAdd(false);
        setForm({ program_category_id: "", bpm_upper: "", bpm_lower: "", beban_upper_value: "", beban_lower_value: "", has_resistance: false, parameter_notes: "" });
      },
    });
  }

  return (
    <div className="bg-white overflow-hidden border border-slate-200 shadow-sm rounded-xl">
      <div className="flex items-center justify-between px-3 py-2 bg-slate-50 border-b border-slate-100">
        <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Program</span>
        <button onClick={() => setShowAdd(!showAdd)} className="text-xs text-sf-deepNavy hover:text-sf-deepNavy font-medium flex items-center gap-1">
          <Plus className="h-3 w-3" /> Tambah
        </button>
      </div>

      {/* Add form */}
      {showAdd && (
        <div className="p-3 border-b border-slate-100 bg-blue-50/50 space-y-2">
          <SearchableSelect
            options={categories
              .filter((c: any) => !data.some((d: any) => d.program_category_id === c.id))
              .map((c: any) => ({ value: c.id, label: c.name, sublabel: c.description || undefined }))}
            value={form.program_category_id}
            onChange={(v) => setForm({ ...form, program_category_id: v })}
            placeholder="Pilih program..."
            searchPlaceholder="Cari program..."
          />
          {selectedCat && (
            <div className="flex flex-wrap gap-x-4 gap-y-1 text-xs">
              {paramTemplate.bpm_range && (
                <div className="flex items-center gap-1">
                  <span className="text-slate-500">BPM:</span>
                  <input type="number" value={form.bpm_lower} onChange={(e) => setForm({ ...form, bpm_lower: e.target.value })}
                    className="w-14 border border-slate-200 rounded px-1 py-0.5 text-center" placeholder="min" />
                  <span>-</span>
                  <input type="number" value={form.bpm_upper} onChange={(e) => setForm({ ...form, bpm_upper: e.target.value })}
                    className="w-14 border border-slate-200 rounded px-1 py-0.5 text-center" placeholder="max" />
                </div>
              )}
              {paramTemplate.beban_upper && (
                <div className="flex items-center gap-1">
                  <span className="text-slate-500">Beban Upper:</span>
                  <input type="number" step="0.1" value={form.beban_upper_value} onChange={(e) => setForm({ ...form, beban_upper_value: e.target.value })}
                    className="w-16 border border-slate-200 rounded px-1 py-0.5 text-center" placeholder="0.0" />
                  <span className="text-slate-400">kg</span>
                </div>
              )}
              {paramTemplate.beban_lower && (
                <div className="flex items-center gap-1">
                  <span className="text-slate-500">Beban Lower:</span>
                  <input type="number" step="0.1" value={form.beban_lower_value} onChange={(e) => setForm({ ...form, beban_lower_value: e.target.value })}
                    className="w-16 border border-slate-200 rounded px-1 py-0.5 text-center" placeholder="0.0" />
                  <span className="text-slate-400">kg</span>
                </div>
              )}
              {paramTemplate.resistance && (
                <label className="flex items-center gap-1 cursor-pointer">
                  <input type="checkbox" checked={form.has_resistance} onChange={(e) => setForm({ ...form, has_resistance: e.target.checked })}
                    className="rounded border-slate-300 text-sf-deepNavy h-3.5 w-3.5" />
                  <span className="text-slate-600">Resistance</span>
                </label>
              )}
            </div>
          )}
          <div className="flex gap-1">
            <button onClick={handleAdd} disabled={!form.program_category_id || upsert.isPending} className="btn-primary text-xs px-2 py-1 flex-1">
              {upsert.isPending ? <Loader2 className="h-3 w-3 animate-spin" /> : <Check className="h-3 w-3" />} Simpan
            </button>
            <button onClick={() => setShowAdd(false)} className="btn-secondary text-xs px-2 py-1">Batal</button>
          </div>
        </div>
      )}

      {/* Program table */}
      {data.length === 0 && !showAdd ? (
        <p className="text-xs text-slate-400 text-center py-6">Belum ada program</p>
      ) : (
        <table className="w-full text-xs">
          <thead>
            <tr className="border-b border-slate-100 bg-slate-50/50">
              <th className="w-8" />
              <th className="px-2 py-2 text-left font-semibold text-slate-500">Program</th>
              <th className="px-2 py-2 text-left font-semibold text-slate-500">Parameter</th>
              <th className="w-8" />
            </tr>
          </thead>
          <tbody>
            {data.map((p: any) => (
              <tr key={p.id} className="border-b border-slate-50 last:border-0 group hover:bg-slate-50/50">
                <td className="px-2 py-2 text-center">
                  <div className={cn("h-4 w-4 rounded border-2 flex items-center justify-center",
                    p.is_active ? "bg-emerald-500 border-emerald-500" : "border-slate-300"
                  )}>
                    {p.is_active && <Check className="h-3 w-3 text-white" />}
                  </div>
                </td>
                <td className="px-2 py-2 font-medium text-slate-800">{p.program_category_name}</td>
                <td className="px-2 py-2 text-slate-600">
                  {[
                    p.beban_upper_value != null && `Beban Upper ${p.beban_upper_value}kg`,
                    p.beban_lower_value != null && `Beban Lower ${p.beban_lower_value}kg`,
                    !p.beban_upper_value && p.has_beban_upper && "beban upper",
                    !p.beban_lower_value && p.has_beban_lower && "beban lower",
                    p.bpm_upper != null && `BPM (Range ${p.bpm_lower}-${p.bpm_upper})`,
                    p.has_resistance && "resistance",
                    !p.has_beban_upper && !p.has_beban_lower && !p.bpm_upper && !p.has_resistance && !p.beban_upper_value && !p.beban_lower_value && (p.parameter_notes || "No BPM / BPM (Range X-X)"),
                  ].filter(Boolean).join(" | ")}
                </td>
                <td className="px-1 py-2">
                  <button onClick={() => setRemoveTarget(p)}
                    className="p-1 rounded opacity-0 group-hover:opacity-100 hover:bg-rose-50 text-slate-400 hover:text-rose-500 transition-all">
                    <Trash2 className="h-3 w-3" />
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      <ConfirmDialog
        open={!!removeTarget}
        onClose={() => setRemoveTarget(null)}
        onConfirm={() => {
          remove.mutate({ customerId, programCategoryId: removeTarget.program_category_id }, {
            onSuccess: () => setRemoveTarget(null),
          });
        }}
        title="Hapus Program"
        description={`Hapus "${removeTarget?.program_category_name}" dari client?`}
        confirmLabel="Hapus"
        variant="danger"
        loading={remove.isPending}
      />
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
//  Session Journal Table (monthly, like the spreadsheet)
// ═══════════════════════════════════════════════════════════════

function SessionJournalTable({ customerId }: { customerId: string }) {
  const now = new Date();
  const currentMonthStr = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}`;

  // Load months that have data from API
  const { data: monthsData } = useJournalMonths(customerId);
  const savedMonths = (monthsData?.data ?? []) as string[];

  // Merge current month + saved months (dedup, sorted desc)
  const [extraMonths, setExtraMonths] = useState<string[]>([]);
  const months = useMemo(() => {
    const all = new Set([currentMonthStr, ...savedMonths, ...extraMonths]);
    return Array.from(all).sort((a, b) => b.localeCompare(a));
  }, [currentMonthStr, savedMonths, extraMonths]);

  const [showPicker, setShowPicker] = useState(false);
  const [pickMonth, setPickMonth] = useState(String(now.getMonth() + 1).padStart(2, "0"));
  const [pickYear, setPickYear] = useState(String(now.getFullYear()));

  function addPickedMonth() {
    const val = `${pickYear}-${pickMonth}`;
    if (!extraMonths.includes(val)) {
      setExtraMonths((prev) => [...prev, val]);
    }
    setShowPicker(false);
  }

  const monthNames = ["Januari","Februari","Maret","April","Mei","Juni","Juli","Agustus","September","Oktober","November","Desember"];
  const yearOptions = Array.from({ length: 5 }, (_, i) => now.getFullYear() - i);

  return (
    <div className="space-y-4">
      {months.map((month) => (
        <MonthJournalBlock key={month} customerId={customerId} month={month} />
      ))}

      {/* Add month picker */}
      {showPicker ? (
        <div className="card p-4 flex items-center gap-3 flex-wrap">
          <SearchableSelect
            options={monthNames.map((name, i) => ({ value: String(i + 1).padStart(2, "0"), label: name }))}
            value={pickMonth}
            onChange={setPickMonth}
            placeholder="Pilih bulan..."
            searchPlaceholder="Cari bulan..."
            className="w-40"
          />
          <SearchableSelect
            options={yearOptions.map((yr) => ({ value: String(yr), label: String(yr) }))}
            value={pickYear}
            onChange={setPickYear}
            placeholder="Tahun"
            className="w-28"
          />
          <button onClick={addPickedMonth} className="btn-primary text-sm px-4">
            <Plus className="h-4 w-4" /> Tambah
          </button>
          <button onClick={() => setShowPicker(false)} className="btn-secondary text-sm px-4">
            Batal
          </button>
        </div>
      ) : (
        <button onClick={() => setShowPicker(true)}
          className="w-full py-3 border-2 border-dashed border-slate-200 rounded-xl text-sm font-medium text-slate-500 hover:border-sf-systemBlue/40 hover:text-sf-deepNavy transition-colors flex items-center justify-center gap-2">
          <Plus className="h-4 w-4" /> Tambah Bulan
        </button>
      )}
    </div>
  );
}

// ── Single Month Block ──────────────────────────────────────────

function MonthJournalBlock({ customerId, month }: { customerId: string; month: string }) {
  const [y, m] = month.split("-").map(Number);
  const monthLabel = new Date(y, m - 1, 1).toLocaleString("id-ID", { month: "long", year: "numeric" });
  const dateMin = `${month}-01`;
  const dateMax = `${y}-${String(m).padStart(2, "0")}-${String(new Date(y, m, 0).getDate()).padStart(2, "0")}`;

  const { data: journalData, isLoading } = useJournalSessions(customerId, month);
  const existingSessions = (journalData?.data ?? []) as any[];
  const upsert = useUpsertJournalSession();

  const [foodModalRow, setFoodModalRow] = useState<number | null>(null);
  const [foodModalMeals, setFoodModalMeals] = useState<any[]>([]);
  const [medModalRow, setMedModalRow] = useState<number | null>(null);
  const [medModalMeds, setMedModalMeds] = useState<any[]>([]);
  const [collapsed, setCollapsed] = useState(false);

  type RowType = { number: number; date: string; medicines: any[]; meals: any[]; mealTime: string; preSystolic: string; preDiastolic: string; preHeartrate: string; postSystolic: string; postDiastolic: string; postHeartrate: string; dirty: boolean; _id: string };

  function emptyRows(): RowType[] {
    return Array.from({ length: 8 }, (_, i) => ({
      number: i + 1, date: "", medicines: [] as any[], meals: [] as any[],
      mealTime: "", preSystolic: "", preDiastolic: "", preHeartrate: "",
      postSystolic: "", postDiastolic: "", postHeartrate: "", dirty: false, _id: "",
    }));
  }

  const [rows, setRows] = useState<RowType[]>(() => emptyRows());

  // eslint-disable-next-line react-hooks/exhaustive-deps
  const sessionKey = JSON.stringify(existingSessions.map((s: any) => s.id));
  useEffect(() => {
    const base = emptyRows();
    for (const s of existingSessions) {
      const idx = s.session_number - 1;
      if (idx < 0 || idx >= 8) continue;
      base[idx] = {
        ...base[idx],
        date: s.session_date?.slice(0, 10) ?? "",
        medicines: s.medicines ?? [],
        meals: s.meals ?? [],
        mealTime: s.meals?.[0]?.meal_time?.slice(0, 5) ?? "",
        preSystolic: s.pre_vital?.systolic ?? "",
        preDiastolic: s.pre_vital?.diastolic ?? "",
        preHeartrate: s.pre_vital?.heartrate ?? "",
        postSystolic: s.post_vital?.systolic ?? "",
        postDiastolic: s.post_vital?.diastolic ?? "",
        postHeartrate: s.post_vital?.heartrate ?? "",
        dirty: false, _id: s.id,
      };
    }
    setRows(base);
  }, [sessionKey]);

  function updateRow(idx: number, field: string, value: any) {
    setRows((prev) => prev.map((r, i) => i === idx ? { ...r, [field]: value, dirty: true } : r));
  }

  function saveRow(idx: number) {
    const r = rows[idx];
    if (!r.date) return;
    upsert.mutate({
      customerId,
      session_number: r.number,
      session_date: r.date,
      month_year: month,
      medicines: r.medicines.map((md: any) => ({ medicine_id: md.medicine_id || md.id })),
      meals: r.meals.map((ml: any) => ({
        meal_time: r.mealTime || undefined,
        food_description: ml.food_name || ml.food_description || ml.name,
        food_id: ml.food_id || ml.id || undefined,
      })),
      pre_vital: (r.preSystolic || r.preDiastolic || r.preHeartrate) ? {
        systolic: r.preSystolic ? Number(r.preSystolic) : null,
        diastolic: r.preDiastolic ? Number(r.preDiastolic) : null,
        heartrate: r.preHeartrate ? Number(r.preHeartrate) : null,
      } : undefined,
      post_vital: (r.postSystolic || r.postDiastolic || r.postHeartrate) ? {
        systolic: r.postSystolic ? Number(r.postSystolic) : null,
        diastolic: r.postDiastolic ? Number(r.postDiastolic) : null,
        heartrate: r.postHeartrate ? Number(r.postHeartrate) : null,
      } : undefined,
    });
  }

  const avg = useMemo(() => {
    const fields = ["preSystolic", "preDiastolic", "preHeartrate", "postSystolic", "postDiastolic", "postHeartrate"] as const;
    const result: Record<string, string> = {};
    for (const f of fields) {
      const vals = rows.map((r) => r[f]).filter((v) => v !== "" && v != null).map(Number);
      result[f] = vals.length ? (vals.reduce((a, b) => a + b, 0) / vals.length).toFixed(0) : "-";
    }
    return result;
  }, [rows]);

  const cellInput = "w-full border-0 bg-transparent text-sm text-center text-slate-700 focus:outline-none focus:ring-1 rounded px-1 py-1";

  return (
    <div className="card overflow-hidden">
      {/* Month header — click to collapse */}
      <button onClick={() => setCollapsed(!collapsed)}
        className="w-full px-4 py-2.5 bg-slate-800 text-white font-bold text-sm uppercase tracking-wide flex items-center justify-center gap-2 hover:bg-slate-700 transition-colors">
        <span>{monthLabel}</span>
        <ChevronDown className={cn("h-4 w-4 transition-transform", collapsed && "-rotate-90")} />
      </button>

      {!collapsed && (
      <>
      {isLoading ? (
        <div className="p-8 text-center text-sm text-slate-400">Memuat data...</div>
      ) : (
      <div className="overflow-x-auto">
        <table className="w-full text-xs min-w-[1050px]">
          <thead>
            <tr className="bg-slate-100 border-b border-slate-200">
              <th rowSpan={2} className="px-2 py-2 text-center font-bold text-slate-600 border-r border-slate-200 w-16">SESSION</th>
              <th rowSpan={2} className="px-2 py-2 text-center font-bold text-slate-600 border-r border-slate-200 w-28">DATE</th>
              <th rowSpan={2} className="px-2 py-2 text-center font-bold text-slate-600 border-r border-slate-200 w-20">Obat</th>
              <th colSpan={2} className="px-2 py-1.5 text-center font-bold text-slate-600 border-r border-slate-200 border-b border-slate-200">Last Meal</th>
              <th colSpan={3} className="px-2 py-1.5 text-center font-bold text-white bg-blue-400 border-r border-blue-300 border-b border-blue-300">BP Pre-Sesi</th>
              <th colSpan={3} className="px-2 py-1.5 text-center font-bold text-white bg-rose-400 border-b border-rose-300">BP Post-Sesi</th>
              <th rowSpan={2} className="w-10" />
            </tr>
            <tr className="bg-slate-50 border-b border-slate-200">
              <th className="px-2 py-1.5 text-center font-semibold text-slate-500 border-r border-slate-200 w-16">Jam</th>
              <th className="px-2 py-1.5 text-center font-semibold text-slate-500 border-r border-slate-200">Jenis Makanan</th>
              <th className="px-2 py-1.5 text-center font-semibold text-blue-700 bg-blue-50 border-r border-blue-100 w-20">Systolic</th>
              <th className="px-2 py-1.5 text-center font-semibold text-blue-700 bg-blue-50 border-r border-blue-100 w-20">Diastolic</th>
              <th className="px-2 py-1.5 text-center font-semibold text-blue-700 bg-blue-50 border-r border-slate-200 w-20">Heartrate</th>
              <th className="px-2 py-1.5 text-center font-semibold text-rose-700 bg-rose-50 border-r border-rose-100 w-20">Systolic</th>
              <th className="px-2 py-1.5 text-center font-semibold text-rose-700 bg-rose-50 border-r border-rose-100 w-20">Diastolic</th>
              <th className="px-2 py-1.5 text-center font-semibold text-rose-700 bg-rose-50 w-20">Heartrate</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((r, idx) => (
              <tr key={r.number} className="border-b border-slate-100 hover:bg-slate-50/50 transition-colors">
                <td className="px-2 py-2 text-center font-bold text-slate-700 border-r border-slate-100">{r.number}</td>
                <td className="px-1 py-1 border-r border-slate-100">
                  <input type="date" value={r.date} min={dateMin} max={dateMax}
                    onChange={(e) => updateRow(idx, "date", e.target.value)}
                    className={cn(cellInput, "focus:ring-sf-warmGold/40 text-left")} />
                </td>
                <td className="px-1 py-1 border-r border-slate-100">
                  <button onClick={() => { setMedModalRow(idx); setMedModalMeds([...r.medicines]); }}
                    className="w-full text-left px-1 py-1 text-xs rounded hover:bg-sf-iceBlue transition-colors">
                    {r.medicines.length > 0 ? (
                      <div>
                        <span className="block truncate text-slate-700">{r.medicines.map((md: any) => md.medicine_name || md.name).join(", ")}</span>
                        <span className="text-[10px] text-indigo-500 font-medium">{r.medicines.length} obat</span>
                      </div>
                    ) : <span className="text-slate-400 block text-center">+ Obat</span>}
                  </button>
                </td>
                <td className="px-1 py-1 border-r border-slate-100">
                  <input type="time" value={r.mealTime} onChange={(e) => updateRow(idx, "mealTime", e.target.value)}
                    className={cn(cellInput, "focus:ring-sf-warmGold/40")} />
                </td>
                <td className="px-1 py-1 border-r border-slate-100">
                  <button onClick={() => { setFoodModalRow(idx); setFoodModalMeals([...r.meals]); }}
                    className="w-full text-left px-1 py-1 text-xs rounded hover:bg-sf-iceBlue transition-colors">
                    {r.meals.length > 0 ? (
                      <div>
                        <span className="block truncate text-slate-700">{r.meals.map((ml: any) => ml.food_name || ml.food_description || ml.name).join(", ")}</span>
                        {r.meals.some((ml: any) => ml.calories) && (
                          <span className="text-[10px] font-semibold text-amber-600">{r.meals.reduce((s: number, ml: any) => s + (ml.calories ?? 0), 0)} kcal</span>
                        )}
                      </div>
                    ) : <span className="text-slate-400">+ Pilih makanan</span>}
                  </button>
                </td>
                <td className="px-1 py-1 border-r border-slate-100 bg-blue-50/30">
                  <input type="number" value={r.preSystolic} onChange={(e) => updateRow(idx, "preSystolic", e.target.value)} className={cn(cellInput, "focus:ring-blue-500")} />
                </td>
                <td className="px-1 py-1 border-r border-slate-100 bg-blue-50/30">
                  <input type="number" value={r.preDiastolic} onChange={(e) => updateRow(idx, "preDiastolic", e.target.value)} className={cn(cellInput, "focus:ring-blue-500")} />
                </td>
                <td className="px-1 py-1 border-r border-slate-200 bg-blue-50/30">
                  <input type="number" value={r.preHeartrate} onChange={(e) => updateRow(idx, "preHeartrate", e.target.value)} className={cn(cellInput, "focus:ring-blue-500")} />
                </td>
                <td className="px-1 py-1 border-r border-slate-100 bg-rose-50/30">
                  <input type="number" value={r.postSystolic} onChange={(e) => updateRow(idx, "postSystolic", e.target.value)} className={cn(cellInput, "focus:ring-rose-500")} />
                </td>
                <td className="px-1 py-1 border-r border-slate-100 bg-rose-50/30">
                  <input type="number" value={r.postDiastolic} onChange={(e) => updateRow(idx, "postDiastolic", e.target.value)} className={cn(cellInput, "focus:ring-rose-500")} />
                </td>
                <td className="px-1 py-1 bg-rose-50/30">
                  <input type="number" value={r.postHeartrate} onChange={(e) => updateRow(idx, "postHeartrate", e.target.value)} className={cn(cellInput, "focus:ring-rose-500")} />
                </td>
                <td className="px-1 py-1 text-center">
                  {r.dirty && r.date && (
                    <button onClick={() => saveRow(idx)} disabled={upsert.isPending}
                      className="p-1 rounded bg-sf-deepNavy text-white hover:bg-sf-deepNavy disabled:opacity-50 transition-colors" title="Simpan">
                      {upsert.isPending ? <Loader2 className="h-3 w-3 animate-spin" /> : <Save className="h-3 w-3" />}
                    </button>
                  )}
                </td>
              </tr>
            ))}
            <tr className="bg-slate-100 border-t-2 border-slate-300 font-bold">
              <td colSpan={3} className="px-2 py-2.5 border-r border-slate-200" />
              <td className="px-2 py-2.5 text-center text-slate-600 border-r border-slate-200">Average</td>
              <td className="border-r border-slate-200" />
              <td className="px-2 py-2.5 text-center text-blue-700 bg-blue-50 border-r border-blue-100">{avg.preSystolic}</td>
              <td className="px-2 py-2.5 text-center text-blue-700 bg-blue-50 border-r border-blue-100">{avg.preDiastolic}</td>
              <td className="px-2 py-2.5 text-center text-blue-700 bg-blue-50 border-r border-slate-200">{avg.preHeartrate}</td>
              <td className="px-2 py-2.5 text-center text-rose-700 bg-rose-50 border-r border-rose-100">{avg.postSystolic}</td>
              <td className="px-2 py-2.5 text-center text-rose-700 bg-rose-50 border-r border-rose-100">{avg.postDiastolic}</td>
              <td className="px-2 py-2.5 text-center text-rose-700 bg-rose-50">{avg.postHeartrate}</td>
              <td />
            </tr>
          </tbody>
        </table>
      </div>
      )}

      {foodModalRow !== null && (
        <FoodSelectionModal
          meals={foodModalMeals}
          onClose={() => setFoodModalRow(null)}
          onSave={(meals) => { updateRow(foodModalRow, "meals", meals); setFoodModalRow(null); }}
        />
      )}

      {medModalRow !== null && (
        <MedicineSelectionModal
          selected={medModalMeds}
          onClose={() => setMedModalRow(null)}
          onSave={(meds) => { updateRow(medModalRow, "medicines", meds); setMedModalRow(null); }}
        />
      )}
      </>
      )}
    </div>
  );
}

// ── Food Selection Modal (multi-select with checkbox) ──────────

function FoodSelectionModal({ meals, onClose, onSave }: { meals: any[]; onClose: () => void; onSave: (meals: any[]) => void }) {
  const { data: foodsData } = useFoods({ limit: 200 });
  const allFoods = (foodsData?.data ?? []) as any[];
  const [search, setSearch] = useState("");
  const [selected, setSelected] = useState<Set<string>>(() => new Set(meals.map((m: any) => m.food_id || m.id).filter(Boolean)));

  const filtered = allFoods.filter((f: any) =>
    f.name.toLowerCase().includes(search.toLowerCase())
  );

  function toggle(food: any) {
    setSelected((prev) => {
      const next = new Set(prev);
      if (next.has(food.id)) next.delete(food.id);
      else next.add(food.id);
      return next;
    });
  }

  // Total nutrition from selected foods
  const totals = useMemo(() => {
    const sel = allFoods.filter((f: any) => selected.has(f.id));
    return {
      calories: sel.reduce((sum, f) => sum + (f.calories ?? 0), 0),
      protein: sel.reduce((sum, f) => sum + (f.protein_g ?? 0), 0),
      carbs: sel.reduce((sum, f) => sum + (f.carbs_g ?? 0), 0),
      fat: sel.reduce((sum, f) => sum + (f.fat_g ?? 0), 0),
    };
  }, [selected, allFoods]);

  function handleSave() {
    const result = allFoods.filter((f: any) => selected.has(f.id)).map((f: any) => ({
      food_id: f.id, food_name: f.name, name: f.name,
      calories: f.calories, protein_g: f.protein_g, carbs_g: f.carbs_g, fat_g: f.fat_g,
    }));
    onSave(result);
  }

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center pt-[5vh] overflow-y-auto" onClick={onClose}>
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" />
      <div className="relative bg-white rounded-2xl shadow-xl max-w-md w-full mx-4 mb-12 animate-slide-in" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between px-5 py-3 border-b border-slate-100">
          <h3 className="font-semibold text-slate-900">Pilih Makanan</h3>
          <button onClick={onClose} className="p-1 rounded-lg hover:bg-slate-100 text-slate-400"><X className="h-5 w-5" /></button>
        </div>

        {/* Search */}
        <div className="px-4 pt-3">
          <input value={search} onChange={(e) => setSearch(e.target.value)} autoFocus
            className="w-full border border-slate-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-sf-warmGold/40"
            placeholder="Cari makanan..." />
          <p className="text-xs text-slate-400 mt-1">{selected.size} dipilih</p>
        </div>

        {/* Food list */}
        <div className="max-h-72 overflow-y-auto px-2 py-2">
          {filtered.length === 0 ? (
            <p className="text-center text-sm text-slate-400 py-6">Tidak ditemukan</p>
          ) : filtered.map((f: any) => (
            <label key={f.id}
              className={cn(
                "flex items-center gap-3 px-3 py-2.5 rounded-lg cursor-pointer transition-colors",
                selected.has(f.id) ? "bg-sf-iceBlue" : "hover:bg-slate-50"
              )}>
              <input type="checkbox" checked={selected.has(f.id)} onChange={() => toggle(f)}
                className="rounded border-slate-300 text-sf-deepNavy focus:ring-sf-warmGold/40 h-4 w-4 shrink-0" />
              <div className="min-w-0 flex-1">
                <span className="text-sm font-medium text-slate-800 block truncate">{f.name}</span>
                {f.calories != null && (
                  <span className="text-xs text-slate-400">{f.calories} kcal · P{f.protein_g}g · C{f.carbs_g}g · F{f.fat_g}g</span>
                )}
              </div>
              {f.calories != null && selected.has(f.id) && (
                <span className="text-xs font-bold text-sf-deepNavy shrink-0">{f.calories} kcal</span>
              )}
            </label>
          ))}
        </div>

        {/* Total nutrition summary */}
        {selected.size > 0 && (
          <div className="mx-4 mb-2 p-3 rounded-lg bg-amber-50 border border-amber-100">
            <div className="flex items-center justify-between">
              <span className="text-xs font-semibold text-amber-700 uppercase tracking-wider">Total Nutrisi</span>
              <span className="text-sm font-bold text-amber-800">{totals.calories} kcal</span>
            </div>
            <div className="flex gap-4 mt-1">
              <span className="text-xs text-amber-600">Protein <b>{totals.protein}g</b></span>
              <span className="text-xs text-amber-600">Carbs <b>{totals.carbs}g</b></span>
              <span className="text-xs text-amber-600">Fat <b>{totals.fat}g</b></span>
            </div>
          </div>
        )}

        {/* Actions */}
        <div className="flex gap-2 px-4 py-3 border-t border-slate-100">
          <button onClick={onClose} className="btn-secondary flex-1">Batal</button>
          <button onClick={handleSave} className="btn-primary flex-1">
            <Check className="h-4 w-4" /> Simpan ({selected.size})
          </button>
        </div>
      </div>
    </div>
  );
}

// ── Medicine Selection Modal (multi-select with checkbox) ───────

function MedicineSelectionModal({ selected, onClose, onSave }: { selected: any[]; onClose: () => void; onSave: (meds: any[]) => void }) {
  const { data: medsData } = useMedicines({ limit: 200 });
  const allMeds = (medsData?.data ?? []) as any[];
  const [search, setSearch] = useState("");
  const [checked, setChecked] = useState<Set<string>>(() => new Set(selected.map((m: any) => m.medicine_id || m.id).filter(Boolean)));

  const filtered = allMeds.filter((m: any) =>
    m.name.toLowerCase().includes(search.toLowerCase()) ||
    (m.category && m.category.toLowerCase().includes(search.toLowerCase()))
  );

  function toggle(med: any) {
    setChecked((prev) => {
      const next = new Set(prev);
      if (next.has(med.id)) next.delete(med.id);
      else next.add(med.id);
      return next;
    });
  }

  function handleSave() {
    const result = allMeds.filter((m: any) => checked.has(m.id)).map((m: any) => ({
      medicine_id: m.id, medicine_name: m.name, id: m.id, name: m.name, category: m.category,
    }));
    onSave(result);
  }

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center pt-[5vh] overflow-y-auto" onClick={onClose}>
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" />
      <div className="relative bg-white rounded-2xl shadow-xl max-w-md w-full mx-4 mb-12 animate-slide-in" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between px-5 py-3 border-b border-slate-100">
          <h3 className="font-semibold text-slate-900">Pilih Obat Hari Ini</h3>
          <button onClick={onClose} className="p-1 rounded-lg hover:bg-slate-100 text-slate-400"><X className="h-5 w-5" /></button>
        </div>

        <div className="px-4 pt-3">
          <input value={search} onChange={(e) => setSearch(e.target.value)} autoFocus
            className="w-full border border-slate-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-sf-warmGold/40"
            placeholder="Cari nama obat..." />
          <p className="text-xs text-slate-400 mt-1">{checked.size} dipilih</p>
        </div>

        <div className="max-h-72 overflow-y-auto px-2 py-2">
          {filtered.length === 0 ? (
            <p className="text-center text-sm text-slate-400 py-6">Tidak ditemukan</p>
          ) : filtered.map((m: any) => (
            <label key={m.id}
              className={cn(
                "flex items-center gap-3 px-3 py-2.5 rounded-lg cursor-pointer transition-colors",
                checked.has(m.id) ? "bg-indigo-50" : "hover:bg-slate-50"
              )}>
              <input type="checkbox" checked={checked.has(m.id)} onChange={() => toggle(m)}
                className="rounded border-slate-300 text-indigo-600 focus:ring-indigo-500 h-4 w-4 shrink-0" />
              <div className="min-w-0 flex-1">
                <span className="text-sm font-medium text-slate-800 block truncate">{m.name}</span>
                {m.category && (
                  <span className="text-xs text-slate-400">{m.category}</span>
                )}
              </div>
            </label>
          ))}
        </div>

        <div className="flex gap-2 px-4 py-3 border-t border-slate-100">
          <button onClick={onClose} className="btn-secondary flex-1">Batal</button>
          <button onClick={handleSave} className="btn-primary flex-1">
            <Check className="h-4 w-4" /> Simpan ({checked.size})
          </button>
        </div>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
//  Client Subscription & Payment History
// ═══════════════════════════════════════════════════════════════

const subStatusColors: Record<string, string> = {
  active: "bg-emerald-100 text-emerald-700",
  cancelled: "bg-rose-100 text-rose-700",
  expired: "bg-slate-100 text-slate-500",
  past_due: "bg-amber-100 text-amber-700",
  pending: "bg-blue-100 text-blue-700",
  completed: "bg-emerald-100 text-emerald-700",
  failed: "bg-rose-100 text-rose-700",
  refunded: "bg-slate-100 text-slate-500",
};

const tierStyle: Record<string, { icon: typeof Star; gradient: string; text: string }> = {
  basic: { icon: Zap, gradient: "from-slate-500 to-slate-600", text: "text-slate-600" },
  pro: { icon: Star, gradient: "from-brand-500 to-brand-700", text: "text-sf-deepNavy" },
  elite: { icon: Crown, gradient: "from-amber-500 to-amber-700", text: "text-amber-600" },
};

function ClientSubscriptionSection({ clientId, clientName }: { clientId: string; clientName: string }) {
  const [tab, setTab] = useState<"subscriptions" | "payments">("subscriptions");
  const [manualSubOpen, setManualSubOpen] = useState(false);
  const [selectedPlanId, setSelectedPlanId] = useState("");
  const [uploadingId, setUploadingId] = useState<string | null>(null);

  const { isFinance } = useAuth();
  const createManualSub = useCreateManualSubscription();
  const updateAttachment = useUpdateSubscriptionAttachment();

  const { data: subsData, isLoading: subsLoading } = useQuery({
    queryKey: ["client-subscriptions", clientId],
    queryFn: () => apiGet("/api/payments/subscriptions", { user_id: clientId, limit: 50 }),
  });
  const subs = (subsData?.data ?? []) as any[];

  const { data: payData, isLoading: payLoading } = useQuery({
    queryKey: ["client-payments", clientId],
    queryFn: () => apiGet("/api/payments", { user_id: clientId, limit: 50 }),
  });
  const payments = (payData?.data ?? []) as any[];

  const { data: plansData, isLoading: plansLoading } = useSubscriptionPlans();
  const plans = (plansData?.data ?? []) as any[];

  // Flatten the plans to show them in selector options
  const planOptions = useMemo(() => {
    const opts: { value: string; label: string }[] = [];
    plans.forEach((group: any) => {
      if (group.monthly) {
        opts.push({
          value: group.monthly.id,
          label: `${group.monthly.name} - ${formatCurrency(group.monthly.price)} / bulan`,
        });
      }
      if (group.annual) {
        opts.push({
          value: group.annual.id,
          label: `${group.annual.name} - ${formatCurrency(group.annual.price)} / tahun`,
        });
      }
    });
    return opts;
  }, [plans]);

  // Active subscription
  const activeSub = subs.find((s: any) => s.status === "active");
  const tier = activeSub?.plan_name?.toLowerCase()?.includes("elite") ? "elite"
    : activeSub?.plan_name?.toLowerCase()?.includes("pro") ? "pro"
    : activeSub ? "basic" : null;
  const ts = tier ? tierStyle[tier] : null;
  const TierIcon = ts?.icon || CreditCard;

  let daysLeft: number | null = null;
  if (activeSub?.expires_at) {
    daysLeft = Math.ceil((new Date(activeSub.expires_at).getTime() - Date.now()) / (1000 * 60 * 60 * 24));
  }

  // Total spent
  const totalSpent = payments
    .filter((p: any) => p.status === "completed")
    .reduce((sum: number, p: any) => sum + (p.amount || 0), 0);

  const handleCreateManualSub = async () => {
    if (!selectedPlanId) return;
    try {
      await createManualSub.mutateAsync({
        user_id: clientId,
        plan_id: selectedPlanId,
      });
      setManualSubOpen(false);
      setSelectedPlanId("");
    } catch (e) {
      // Error handled by toast in hook
    }
  };

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>, subId: string) => {
    const file = e.target.files?.[0];
    if (!file) return;
    if (file.size > 10 * 1024 * 1024) {
      alert("File too large. Maximum size is 10MB");
      return;
    }

    setUploadingId(subId);
    try {
      const formData = new FormData();
      formData.append("file", file);
      const res = await axios.post("/api/uploads", formData, {
        baseURL: process.env.NEXT_PUBLIC_API_URL || "http://localhost:8080",
      });
      const url = res.data?.data?.url;
      if (url) {
        await updateAttachment.mutateAsync({ id: subId, attachment_url: url });
      }
    } catch (err: any) {
      alert("Upload failed: " + err.message);
    } finally {
      setUploadingId(null);
      e.target.value = ""; // Reset input
    }
  };

  return (
    <div className="space-y-3">
      {/* Active Subscription Banner */}
      {activeSub ? (
        <div className={cn("rounded-xl p-5 text-white bg-gradient-to-r", ts?.gradient || "from-slate-500 to-slate-600")}>
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-white/20 rounded-lg">
                <TierIcon className="h-5 w-5" />
              </div>
              <div>
                <p className="text-sm text-white/70">Langganan Aktif</p>
                <p className="text-xl font-bold">{activeSub.plan_name}</p>
              </div>
            </div>
            <div className="text-right flex flex-col items-end gap-1.5">
              <div className="flex items-center gap-1.5 text-white/80 text-sm font-semibold">
                <Clock className="h-4 w-4" />
                {daysLeft != null && daysLeft > 0 ? `${daysLeft} hari tersisa` : "Expired"}
              </div>
              <p className="text-xs text-white/50">s/d {formatDate(activeSub.expires_at)}</p>
              {isFinance && (
                <button
                  onClick={() => setManualSubOpen(true)}
                  className="mt-2 px-2.5 py-1 text-xs bg-white text-sf-deepNavy font-bold rounded hover:bg-slate-100 transition-colors shadow-sm"
                >
                  Ubah / Set Paket
                </button>
              )}
            </div>
          </div>
          <div className="flex items-center gap-4 mt-3 pt-3 border-t border-white/20 text-sm text-white/70">
            <span>Mulai: {formatDate(activeSub.started_at)}</span>
            <span>Metode: {activeSub.payment_method || "-"}</span>
            <span>Total Langganan: {subs.length}x</span>
            <span>Total Bayar: {formatCurrency(totalSpent)}</span>
          </div>
        </div>
      ) : (
        <div className="card p-5 flex items-center justify-between border-dashed border-2 bg-slate-50/50">
          <div className="flex items-center gap-4">
            <div className="p-2 bg-slate-100 rounded-lg">
              <CreditCard className="h-5 w-5 text-slate-400" />
            </div>
            <div>
              <p className="text-sm font-semibold text-slate-700">Belum Berlangganan</p>
              <p className="text-xs text-slate-400">{clientName} belum memiliki langganan aktif</p>
            </div>
          </div>
          {isFinance && (
            <button
              onClick={() => setManualSubOpen(true)}
              className="btn-primary text-xs px-3 py-1.5 flex items-center gap-1"
            >
              <Plus className="h-3.5 w-3.5" /> Set Paket Langganan
            </button>
          )}
        </div>
      )}

      {/* Manual Subscription Modal */}
      {manualSubOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center" onClick={() => setManualSubOpen(false)}>
          <div className="absolute inset-0 bg-black/40 backdrop-blur-sm animate-fade-in" />
          <div className="relative bg-white rounded-2xl shadow-xl max-w-md w-full mx-4 p-6 animate-slide-in" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between border-b border-slate-100 pb-3 mb-4">
              <h3 className="font-bold text-slate-900 flex items-center gap-2">
                <Crown className="h-5 w-5 text-sf-warmGold" />
                Set Paket Langganan Manual
              </h3>
              <button onClick={() => setManualSubOpen(false)} className="p-1 rounded-lg hover:bg-slate-100 text-slate-400">
                <X className="h-5 w-5" />
              </button>
            </div>

            <div className="space-y-4">
              <p className="text-sm text-slate-500">
                Pilih paket berlangganan untuk client <strong>{clientName}</strong>.
                Tindakan ini akan langsung mengaktifkan status langganan dan membuat payment record berstatus completed secara manual.
              </p>

              <div>
                <label className="label">Pilih Paket *</label>
                {plansLoading ? (
                  <div className="skeleton h-10 w-full rounded-lg" />
                ) : (
                  <SearchableSelect
                    options={planOptions}
                    value={selectedPlanId}
                    onChange={setSelectedPlanId}
                    placeholder="Pilih paket..."
                    searchPlaceholder="Cari paket..."
                  />
                )}
              </div>
            </div>

            <div className="flex justify-end gap-3 pt-5 border-t border-slate-100 mt-6">
              <button onClick={() => setManualSubOpen(false)} className="btn-secondary text-sm">
                Batal
              </button>
              <button
                onClick={handleCreateManualSub}
                disabled={!selectedPlanId || createManualSub.isPending}
                className="btn-primary text-sm px-4 py-2 flex items-center gap-1.5"
              >
                {createManualSub.isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Check className="h-4 w-4" />}
                Aktifkan Paket
              </button>
            </div>
          </div>
        </div>
      )}



      {/* Tabs */}
      <div className="card overflow-hidden">
        <div className="flex border-b border-slate-100">
          <button
            onClick={() => setTab("subscriptions")}
            className={cn("flex-1 px-4 py-2.5 text-sm font-medium transition",
              tab === "subscriptions" ? "text-sf-deepNavy border-b-2 border-sf-deepNavy bg-sf-iceBlue/40" : "text-slate-500 hover:text-slate-700"
            )}
          >
            Riwayat Langganan ({subs.length})
          </button>
          <button
            onClick={() => setTab("payments")}
            className={cn("flex-1 px-4 py-2.5 text-sm font-medium transition",
              tab === "payments" ? "text-sf-deepNavy border-b-2 border-sf-deepNavy bg-sf-iceBlue/40" : "text-slate-500 hover:text-slate-700"
            )}
          >
            Riwayat Pembayaran ({payments.length})
          </button>
        </div>

        {tab === "subscriptions" && (
          subsLoading ? (
            <div className="p-4"><div className="skeleton h-32 w-full rounded-lg" /></div>
          ) : subs.length === 0 ? (
            <div className="p-8 text-center text-sm text-slate-400">Belum ada riwayat langganan</div>
          ) : (
            <table className="w-full text-sm">
              <thead>
                <tr className="bg-slate-50/50">
                  <th className="text-left px-4 py-2.5 font-medium text-slate-500">Plan</th>
                  <th className="text-left px-4 py-2.5 font-medium text-slate-500">Status</th>
                  <th className="text-left px-4 py-2.5 font-medium text-slate-500">Mulai</th>
                  <th className="text-left px-4 py-2.5 font-medium text-slate-500">Berakhir</th>
                  <th className="text-left px-4 py-2.5 font-medium text-slate-500">Metode</th>
                  <th className="text-left px-4 py-2.5 font-medium text-slate-500">Hasil Lab</th>
                </tr>
              </thead>
              <tbody>
                {subs.map((s: any) => (
                  <tr key={s.id} className="border-t border-slate-50 hover:bg-slate-50/50">
                    <td className="px-4 py-2.5 font-medium text-slate-900">{s.plan_name}</td>
                    <td className="px-4 py-2.5">
                      <span className={cn("text-xs font-medium px-2 py-0.5 rounded-full capitalize", subStatusColors[s.status] || "")}>
                        {s.status}
                      </span>
                    </td>
                    <td className="px-4 py-2.5 text-slate-600">{formatDate(s.started_at)}</td>
                    <td className="px-4 py-2.5 text-slate-600">{formatDate(s.expires_at)}</td>
                    <td className="px-4 py-2.5 text-slate-500">{s.payment_method || "-"}</td>
                    <td className="px-4 py-2.5">
                      {s.attachment_url ? (
                        <a href={s.attachment_url} target="_blank" rel="noreferrer" className="inline-flex items-center gap-1.5 text-xs text-sf-systemBlue hover:underline bg-blue-50 px-2 py-1 rounded">
                          <File className="h-3 w-3" /> Lihat File
                        </a>
                      ) : (
                        <label className="cursor-pointer inline-flex items-center gap-1.5 text-xs text-slate-500 hover:text-sf-deepNavy bg-slate-100 hover:bg-slate-200 px-2 py-1 rounded transition-colors">
                          {uploadingId === s.id ? <Loader2 className="h-3 w-3 animate-spin" /> : <Upload className="h-3 w-3" />}
                          Upload Lab
                          <input type="file" className="hidden" accept=".pdf,image/*" onChange={(e) => handleFileUpload(e, s.id)} disabled={uploadingId === s.id} />
                        </label>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )
        )}

        {tab === "payments" && (
          payLoading ? (
            <div className="p-4"><div className="skeleton h-32 w-full rounded-lg" /></div>
          ) : payments.length === 0 ? (
            <div className="p-8 text-center text-sm text-slate-400">Belum ada riwayat pembayaran</div>
          ) : (
            <table className="w-full text-sm">
              <thead>
                <tr className="bg-slate-50/50">
                  <th className="text-left px-4 py-2.5 font-medium text-slate-500">Jumlah</th>
                  <th className="text-left px-4 py-2.5 font-medium text-slate-500">Status</th>
                  <th className="text-left px-4 py-2.5 font-medium text-slate-500">Metode</th>
                  <th className="text-left px-4 py-2.5 font-medium text-slate-500">External ID</th>
                  <th className="text-left px-4 py-2.5 font-medium text-slate-500">Tanggal</th>
                </tr>
              </thead>
              <tbody>
                {payments.map((p: any) => (
                  <tr key={p.id} className="border-t border-slate-50 hover:bg-slate-50/50">
                    <td className="px-4 py-2.5 font-mono font-medium text-slate-900">
                      {formatCurrency(p.amount, p.currency)}
                    </td>
                    <td className="px-4 py-2.5">
                      <span className={cn("text-xs font-medium px-2 py-0.5 rounded-full capitalize", subStatusColors[p.status] || "")}>
                        {p.status}
                      </span>
                    </td>
                    <td className="px-4 py-2.5 text-slate-600">{p.payment_method || "-"}</td>
                    <td className="px-4 py-2.5 text-slate-500 font-mono text-xs">{p.external_id || "-"}</td>
                    <td className="px-4 py-2.5 text-slate-600">{formatDate(p.created_at)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )
        )}
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
//  Skeleton
// ═══════════════════════════════════════════════════════════════

function PageSkeleton() {
  return (
    <div className="space-y-4">
      <div className="skeleton h-4 w-28" />
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-4">
        <div className="lg:col-span-4 space-y-4">
          <div className="card p-4 space-y-2">{[1, 2, 3].map((i) => <div key={i} className="skeleton h-8 w-full" />)}</div>
          <div className="card p-4 space-y-2">{[1, 2, 3, 4, 5, 6].map((i) => <div key={i} className="skeleton h-6 w-full" />)}</div>
        </div>
        <div className="lg:col-span-3">
          <div className="card p-4 space-y-2">{[1, 2, 3, 4, 5].map((i) => <div key={i} className="skeleton h-6 w-full" />)}</div>
        </div>
        <div className="lg:col-span-5 space-y-4">
          <div className="card p-4 space-y-2">{[1, 2].map((i) => <div key={i} className="skeleton h-8 w-full" />)}</div>
          <div className="card p-4 space-y-2">{[1, 2, 3].map((i) => <div key={i} className="skeleton h-8 w-full" />)}</div>
        </div>
      </div>
      <div className="card p-4"><div className="skeleton h-64 w-full" /></div>
    </div>
  );
}
