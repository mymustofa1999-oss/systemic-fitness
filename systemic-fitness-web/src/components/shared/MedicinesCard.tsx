"use client";

import { useState } from "react";
import { Plus, Check, X, ChevronDown, Info, Trash2, Loader2, Pill, AlertTriangle } from "lucide-react";
import { useAddCustomerMedicine, useRemoveCustomerMedicine, useMedicines } from "@/hooks/useNewFeatures";
import { SearchableSelect } from "@/components/shared/SearchableSelect";
import { cn } from "@/lib/utils";

export function MedicinesCard({ customerId, data, readOnly }: { customerId: string; data: any[]; readOnly?: boolean }) {
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
        <span className="text-xs font-bold text-slate-500 uppercase tracking-wider flex items-center gap-1.5"><Pill className="h-3.5 w-3.5 text-red-500" /> Daftar Obat</span>
        {!readOnly && (
          <button onClick={() => setShowAdd(!showAdd)} className="text-xs text-sf-deepNavy hover:text-sf-deepNavy font-medium flex items-center gap-1">
            <Plus className="h-3 w-3" /> Tambah
          </button>
        )}
      </div>

      <div className="flex-1 overflow-y-auto">
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
            />
            <div className="flex gap-1 mt-1.5">
              <button onClick={handleAdd} disabled={!selectedMed || addMed.isPending} className="inline-flex items-center justify-center rounded text-white bg-sf-deepNavy hover:bg-slate-800 disabled:opacity-50 text-xs px-2 py-1 flex-1">
                {addMed.isPending ? <Loader2 className="h-3 w-3 animate-spin mr-1" /> : <Check className="h-3 w-3 mr-1" />} Tambah
              </button>
              <button onClick={() => setShowAdd(false)} className="inline-flex items-center justify-center rounded border border-slate-200 bg-white hover:bg-slate-50 text-slate-700 text-xs px-2 py-1">
                <X className="h-3 w-3" />
              </button>
            </div>
          </div>
        )}

        {data.length === 0 && !showAdd ? (
          <p className="text-xs text-slate-400 text-center py-6">Belum ada obat</p>
        ) : (
          data.map((cm: any, i: number) => {
            const fullMed = medicinesList.find((m: any) => m.id === cm.medicine_id);
            return (
            <div key={cm.id} className={cn(
              "flex flex-col px-3 py-2 text-sm group hover:bg-slate-50 transition-colors",
              i < data.length - 1 && "border-b border-slate-50"
            )}>
              <div className="flex items-start justify-between gap-2">
                <div className="flex-1 min-w-0 flex flex-col gap-1.5">
                  <div className="flex items-center gap-2 flex-wrap">
                    <span className="text-slate-800 font-medium">{cm.medicine_name}</span>
                    {fullMed?.flag_level && (
                      fullMed.flag_level.trim().toUpperCase() === "MERAH" || 
                      fullMed.flag_level.trim().toUpperCase() === "KUNING" || 
                      fullMed.flag_level.trim().toUpperCase() === "HIJAU" ? (
                        <span className={cn(
                          "text-[9px] font-bold px-1.5 py-0.5 rounded uppercase tracking-wider shrink-0",
                          fullMed.flag_level.trim().toUpperCase() === "MERAH" ? "bg-red-100 text-red-700" :
                          fullMed.flag_level.trim().toUpperCase() === "KUNING" ? "bg-amber-100 text-amber-700" :
                          "bg-green-100 text-green-700"
                        )}>
                          {fullMed.flag_level}
                        </span>
                      ) : null
                    )}
                  </div>
                  
                  {fullMed?.category && (
                    <p className="text-[11px] text-slate-500 leading-tight mb-1">
                      <span className="font-semibold text-slate-600">Golongan:</span> {fullMed.category}
                    </p>
                  )}
                  {fullMed?.main_function && (
                    <p className="text-[11px] text-slate-500 leading-tight mb-1">
                      <span className="font-semibold text-slate-600">Fungsi Utama:</span> {fullMed.main_function}
                    </p>
                  )}
                  {fullMed?.exercise_implications && (
                    <div className="bg-amber-50/50 border border-amber-100 rounded p-1.5 mt-0.5">
                      <p className="text-[11px] text-amber-800 leading-tight">
                        <span className="font-semibold">Implikasi Latihan:</span> {fullMed.exercise_implications}
                      </p>
                    </div>
                  )}
                  {fullMed?.exercise_adjustments && (
                    <div className="bg-blue-50/50 border border-blue-100 rounded p-1.5 mt-1">
                      <p className="text-[11px] text-blue-800 leading-tight">
                        <span className="font-semibold">Penyesuaian Latihan:</span> {fullMed.exercise_adjustments}
                      </p>
                    </div>
                  )}
                </div>
                    <div className="flex items-center gap-2">
                      <button onClick={() => setInfoMed(fullMed || cm)} className="p-1 rounded bg-slate-100 hover:bg-slate-200 text-slate-600 transition-colors" title="Lihat detail">
                        <Info className="h-4 w-4" />
                      </button>
                      {!readOnly && (
                        <button onClick={() => setRemoveTarget(cm)} className="p-1 rounded bg-rose-50 hover:bg-rose-100 text-rose-500 transition-colors" title="Hapus obat">
                          <Trash2 className="h-4 w-4" />
                        </button>
                      )}
                    </div>
              </div>
            </div>
            );
          })
        )}
      </div>

      {infoMed && (
        <div className="fixed inset-0 z-[100] flex items-start justify-center pt-[10vh] overflow-y-auto" onClick={() => setInfoMed(null)}>
          <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" />
          <div className="relative bg-white rounded-2xl shadow-xl max-w-md w-full mx-4 mb-12 animate-slide-in" onClick={(e) => e.stopPropagation()}>
            <div className="p-5 border-b border-slate-100">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="font-bold text-xl text-slate-900">{infoMed.name || infoMed.medicine_name}</h3>
                  <p className="text-sm text-sf-warmGold font-medium mt-0.5">{infoMed.category || "General"}</p>
                </div>
                <button onClick={() => setInfoMed(null)} className="p-1.5 rounded-full hover:bg-slate-100 text-slate-400">
                  <X className="h-5 w-5" />
                </button>
              </div>
            </div>
            <div className="p-5 space-y-4 text-sm">
              <div>
                <p className="text-slate-500 text-xs uppercase tracking-wider mb-1">Kandungan Aktif</p>
                <p className="text-slate-800 font-medium">{infoMed.active_ingredient || "Tidak ada data"}</p>
              </div>
              {infoMed.exercise_implications && (
                <div className="bg-orange-50 border border-orange-100 p-3 rounded-lg">
                  <p className="text-orange-800 font-bold text-xs uppercase tracking-wider mb-1 flex items-center gap-1.5">
                    <AlertTriangle className="h-3.5 w-3.5" /> Implikasi Latihan
                  </p>
                  <p className="text-slate-700 leading-relaxed whitespace-pre-line">{infoMed.exercise_implications}</p>
                </div>
              )}
              {infoMed.exercise_adjustments && (
                <div className="bg-blue-50 border border-blue-100 p-3 rounded-lg">
                  <p className="text-blue-800 font-bold text-xs uppercase tracking-wider mb-1 flex items-center gap-1.5">
                    <Info className="h-3.5 w-3.5" /> Penyesuaian
                  </p>
                  <p className="text-slate-700 leading-relaxed whitespace-pre-line">{infoMed.exercise_adjustments}</p>
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {removeTarget && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center" onClick={() => setRemoveTarget(null)}>
          <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" />
          <div className="relative bg-white rounded-xl shadow-xl max-w-sm w-full mx-4 p-5" onClick={(e) => e.stopPropagation()}>
            <h3 className="font-bold text-lg mb-2">Hapus Obat?</h3>
            <p className="text-sm text-slate-600 mb-6">Yakin ingin menghapus <strong>{removeTarget.medicine_name}</strong> dari daftar obat klien ini?</p>
            <div className="flex justify-end gap-2">
              <button onClick={() => setRemoveTarget(null)} className="px-4 py-2 text-sm font-medium text-slate-600 hover:bg-slate-100 rounded-lg">Batal</button>
              <button onClick={() => {
                removeMed.mutate({ customerId, medicineId: removeTarget.medicine_id });
                setRemoveTarget(null);
              }} className="px-4 py-2 text-sm font-medium text-white bg-rose-500 hover:bg-rose-600 rounded-lg">Hapus</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
