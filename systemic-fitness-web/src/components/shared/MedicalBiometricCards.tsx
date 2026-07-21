"use client";

import { useState } from "react";
import { Loader2, Save, Plus, Check, X, ChevronDown, Info, Trash2, Pill, ExternalLink } from "lucide-react";
import { useUpsertHRZone, useAddCustomerMedicine, useRemoveCustomerMedicine, useMedicines } from "@/hooks/useNewFeatures";
import { SearchableSelect } from "@/components/shared/SearchableSelect";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { cn } from "@/lib/utils";

// ═══════════════════════════════════════════════════════════════
//  HR Zone Card
// ═══════════════════════════════════════════════════════════════
export function HRZoneCard({ customerId, data }: { customerId: string; data: any }) {
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

//  Medicines Card (dropdown-style list like spreadsheet)

// ═══════════════════════════════════════════════════════════════
//  Medicines Card
// ═══════════════════════════════════════════════════════════════
export function MedicinesCard({ customerId, data }: { customerId: string; data: any[] }) {
  const [showAdd, setShowAdd] = useState(false);
  const [selectedMed, setSelectedMed] = useState("");
  const [removeTarget, setRemoveTarget] = useState<any>(null);
  const [infoMed, setInfoMed] = useState<any>(null);

  const addMed = useAddCustomerMedicine();
  const removeMed = useRemoveCustomerMedicine();
  const { data: allMeds } = useMedicines({ limit: 100 });
  const medicinesList = (allMeds?.data ?? []) as any[];

  function handleAdd() {
    if (!selectedMed) return;
    addMed.mutate({ customerId, medicine_id: selectedMed }, {
      onSuccess: () => { setShowAdd(false); setSelectedMed(""); },
    });
  }

  return (
    <div className="bg-white overflow-hidden border border-slate-200 shadow-sm rounded-xl h-full flex flex-col">
      <div className="flex items-center justify-between px-3 py-2 bg-slate-50 border-b border-slate-100">
        <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Daftar Obat</span>
        <button onClick={() => setShowAdd(!showAdd)} className="text-xs text-sf-deepNavy hover:text-sf-deepNavy font-medium flex items-center gap-1">
          <Plus className="h-3 w-3" /> Tambah
        </button>
      </div>

      <div className="flex-1 overflow-y-auto">
        {/* Add row */}
        {showAdd && (
          <div className="p-2 border-b border-slate-100 bg-blue-50/50">
            <SearchableSelect
              options={medicinesList
                .filter((m: any) => !data.some((d: any) => d.medicine_id === m.id))
                .map((m: any) => ({ value: m.id, label: m.name, sublabel: m.category || undefined }))}
              value={selectedMed}
              onChange={setSelectedMed}
              placeholder="Pilih obat..."
              searchPlaceholder="Cari nama obat..."
              className="mb-1.5"
            />
            <div className="flex gap-1">
              <button onClick={handleAdd} disabled={!selectedMed || addMed.isPending} className="btn-primary text-xs px-2 py-1 flex-1">
                {addMed.isPending ? <Loader2 className="h-3 w-3 animate-spin" /> : <Check className="h-3 w-3" />} Tambah
              </button>
              <button onClick={() => setShowAdd(false)} className="btn-secondary text-xs px-2 py-1">
                <X className="h-3 w-3" />
              </button>
            </div>
          </div>
        )}

        {/* Medicine list — styled like dropdown items */}
        {data.length === 0 && !showAdd ? (
          <p className="text-xs text-slate-400 text-center py-6">Belum ada obat</p>
        ) : (
          data.map((cm: any, i: number) => {
            const fullMed = medicinesList.find((m: any) => m.id === cm.medicine_id);
            return (
            <div key={cm.id} className={cn(
              "flex items-center justify-between px-3 py-2 text-sm group hover:bg-slate-50 transition-colors",
              i < data.length - 1 && "border-b border-slate-50"
            )}>
              <div className="flex items-center gap-2 min-w-0">
                <span className="text-slate-800 truncate">{cm.medicine_name}</span>
                <ChevronDown className="h-3 w-3 text-slate-400 shrink-0" />
              </div>
              <div className="flex items-center gap-0.5 shrink-0">
                <button onClick={() => setInfoMed(fullMed || cm)}
                  className="p-1 rounded opacity-0 group-hover:opacity-100 hover:bg-blue-50 text-slate-400 hover:text-blue-600 transition-all"
                  title="Info obat">
                  <Info className="h-3 w-3" />
                </button>
                <button onClick={() => setRemoveTarget(cm)}
                  className="p-1 rounded opacity-0 group-hover:opacity-100 hover:bg-rose-50 text-slate-400 hover:text-rose-500 transition-all">
                  <Trash2 className="h-3 w-3" />
                </button>
              </div>
            </div>
            );
          })
        )}
      </div>

      {/* Medicine Info Modal */}
      {infoMed && (
        <div className="fixed inset-0 z-50 flex items-start justify-center pt-[10vh] overflow-y-auto" onClick={() => setInfoMed(null)}>
          <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" />
          <div className="relative bg-white rounded-2xl shadow-xl max-w-md w-full mx-4 mb-12 animate-slide-in" onClick={(e) => e.stopPropagation()}>
            {/* Image */}
            {infoMed.image_url ? (
              <div className="h-48 bg-slate-100 rounded-t-2xl overflow-hidden">
                <img src={infoMed.image_url} alt={infoMed.name || infoMed.medicine_name} className="w-full h-full object-cover" />
              </div>
            ) : (
              <div className="h-32 bg-slate-50 rounded-t-2xl flex items-center justify-center">
                <Pill className="h-12 w-12 text-slate-200" />
              </div>
            )}

            <div className="p-5 space-y-3">
              {/* Name & category */}
              <div>
                <h3 className="text-lg font-bold text-slate-900">{infoMed.name || infoMed.medicine_name}</h3>
                {infoMed.category && (
                  <span className="inline-block mt-1 px-2 py-0.5 rounded-md bg-indigo-50 text-indigo-700 text-xs font-medium">{infoMed.category}</span>
                )}
              </div>

              {/* Main function */}
              {infoMed.main_function && (
                <div>
                  <p className="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-1">Fungsi Utama</p>
                  <p className="text-sm text-slate-700">{infoMed.main_function}</p>
                </div>
              )}

              {/* Side effects */}
              {infoMed.side_effects && (
                <div>
                  <p className="text-xs font-semibold text-amber-500 uppercase tracking-wider mb-1">Efek Samping</p>
                  <p className="text-sm text-slate-600 whitespace-pre-line leading-relaxed">{infoMed.side_effects}</p>
                </div>
              )}

              {/* Detail link */}
              {infoMed.detail_url && (
                <a href={infoMed.detail_url} target="_blank" rel="noopener noreferrer"
                  className="inline-flex items-center gap-1.5 text-sm text-sf-deepNavy hover:text-sf-deepNavy font-medium">
                  <ExternalLink className="h-3.5 w-3.5" /> Lihat referensi lengkap
                </a>
              )}

              {/* Close button */}
              <div className="pt-2">
                <button onClick={() => setInfoMed(null)} className="btn-secondary w-full">Tutup</button>
              </div>
            </div>
          </div>
        </div>
      )}

      <ConfirmDialog
        open={!!removeTarget}
        onClose={() => setRemoveTarget(null)}
        onConfirm={() => {
          removeMed.mutate({ customerId, medicineId: removeTarget.medicine_id }, {
            onSuccess: () => setRemoveTarget(null),
          });
        }}
        title="Hapus Obat"
        description={`Hapus "${removeTarget?.medicine_name}" dari daftar obat client?`}
        confirmLabel="Hapus"
        variant="danger"
        loading={removeMed.isPending}
      />
    </div>
  );
}

//  Programs Card (table with checkboxes like spreadsheet)
