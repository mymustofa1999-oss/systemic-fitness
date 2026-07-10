"use client";

import { useState } from "react";
import { ChevronDown, Info, Pill, AlertTriangle } from "lucide-react";
import { cn } from "@/lib/utils";

export function MedicinesCard({ data }: { data: any[] }) {
  const [infoMed, setInfoMed] = useState<any>(null);

  return (
    <div className="bg-white rounded-xl shadow-sm border border-slate-100 overflow-hidden">
      <div className="bg-slate-50 px-4 py-3 border-b border-slate-100 flex items-center justify-between">
        <h3 className="font-semibold text-slate-800 flex items-center gap-2">
          <Pill className="w-4 h-4 text-emerald-500" />
          DAFTAR OBAT
        </h3>
        <span className="text-xs font-medium bg-emerald-100 text-emerald-700 px-2 py-0.5 rounded-full">
          {data?.length || 0} Obat
        </span>
      </div>

      <div className="p-4">
        {data.length === 0 ? (
          <div className="text-center py-6 text-slate-400">
            <Pill className="w-8 h-8 mx-auto mb-2 opacity-20" />
            <p className="text-sm">Tidak ada data obat tercatat</p>
          </div>
        ) : (
          <div className="space-y-3">
            {data.map((cm: any, i: number) => {
              // The API already populates ExerciseImplications, FlagLevel, etc. in cm directly.
              const fullMed = cm;
              return (
                <div key={cm.id} className={cn(
                  "pb-3",
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
                      
                      {fullMed?.exercise_implications && (
                        <p className="text-[11px] text-slate-500 leading-tight">
                          <span className="font-semibold text-slate-600">Info:</span> {fullMed.exercise_implications}
                        </p>
                      )}
                      {fullMed?.flag_level && 
                        !(fullMed.flag_level.trim().toUpperCase() === "MERAH" || 
                          fullMed.flag_level.trim().toUpperCase() === "KUNING" || 
                          fullMed.flag_level.trim().toUpperCase() === "HIJAU") && (
                        <div className="bg-amber-50/50 border border-amber-100 rounded p-1.5 mt-0.5">
                          <p className="text-[11px] text-amber-800 leading-tight">
                            <span className="font-semibold">Perhatian:</span> {fullMed.flag_level}
                          </p>
                        </div>
                      )}
                    </div>
                    <div className="flex items-center gap-2">
                      <button onClick={() => setInfoMed(fullMed)} className="p-1 rounded bg-slate-100 hover:bg-slate-200 text-slate-600 transition-colors" title="Lihat detail">
                        <Info className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* Info Modal */}
      {infoMed && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
          <div className="bg-white rounded-xl w-full max-w-md overflow-hidden shadow-xl" onClick={e => e.stopPropagation()}>
            <div className="bg-slate-50 px-4 py-3 border-b flex items-center justify-between">
              <h3 className="font-bold text-slate-800 flex items-center gap-2">
                <Info className="w-4 h-4 text-blue-500" />
                Detail Obat
              </h3>
              <button onClick={() => setInfoMed(null)} className="text-slate-400 hover:text-slate-600 bg-white shadow-sm border p-1 rounded-md transition-colors">
                <ChevronDown className="w-4 h-4" />
              </button>
            </div>
            
            <div className="p-4 space-y-4 max-h-[70vh] overflow-y-auto text-sm">
              <div>
                <label className="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-1 flex items-center gap-1.5">
                  <Pill className="w-3.5 h-3.5" /> Nama Obat
                </label>
                <div className="text-slate-800 font-medium bg-slate-50 p-2.5 rounded-lg border border-slate-100">
                  {infoMed.medicine_name}
                </div>
              </div>

              {infoMed.active_ingredient && (
                <div>
                  <label className="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-1 block">Kandungan Aktif</label>
                  <div className="text-slate-700 bg-slate-50 p-2.5 rounded-lg border border-slate-100 leading-relaxed">
                    {infoMed.active_ingredient}
                  </div>
                </div>
              )}

              {infoMed.exercise_implications && (
                <div>
                  <label className="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-1 flex items-center gap-1.5">
                    <AlertTriangle className="w-3.5 h-3.5 text-amber-500" /> Implikasi & Kategori
                  </label>
                  <div className="text-slate-700 bg-amber-50 p-2.5 rounded-lg border border-amber-100 leading-relaxed">
                    {infoMed.exercise_implications}
                  </div>
                </div>
              )}
              
              {infoMed.exercise_adjustments && (
                <div>
                  <label className="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-1 block">Penyesuaian Latihan</label>
                  <div className="text-slate-700 bg-slate-50 p-2.5 rounded-lg border border-slate-100 leading-relaxed">
                    {infoMed.exercise_adjustments}
                  </div>
                </div>
              )}

              {infoMed.flag_level && (
                <div>
                  <label className="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-1 block">Level Flag (Perhatian)</label>
                  <div className={cn(
                    "font-bold p-2.5 rounded-lg border",
                    infoMed.flag_level.trim().toUpperCase() === "MERAH" ? "bg-red-50 text-red-700 border-red-100" :
                    infoMed.flag_level.trim().toUpperCase() === "KUNING" ? "bg-amber-50 text-amber-700 border-amber-100" :
                    infoMed.flag_level.trim().toUpperCase() === "HIJAU" ? "bg-green-50 text-green-700 border-green-100" :
                    "bg-slate-50 text-slate-700 border-slate-100"
                  )}>
                    {infoMed.flag_level}
                  </div>
                </div>
              )}

              {infoMed.notes && (
                <div>
                  <label className="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-1 block">Catatan Trainer</label>
                  <div className="text-slate-700 bg-blue-50 p-2.5 rounded-lg border border-blue-100 leading-relaxed italic">
                    {infoMed.notes}
                  </div>
                </div>
              )}
            </div>
            
            <div className="p-3 border-t bg-slate-50 flex justify-end">
              <button 
                onClick={() => setInfoMed(null)}
                className="px-4 py-2 bg-white border border-slate-200 text-slate-700 text-sm font-medium rounded-lg hover:bg-slate-50 transition-colors w-full"
              >
                Tutup
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
