"use client";

import { useState } from "react";
import { Plus, Trash2, Loader2, Video, Search, ChevronRight, X, Pencil, Save } from "lucide-react";
import { cn } from "@/lib/utils";
import {
  useDLLevels,
  useDLMenuItems,
  useDLMovements,
  useUpdateDLMovement
} from "@/hooks/useDigitalLibrary";
import { EmptyState } from "@/components/shared/EmptyState";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { apiPost, apiDelete } from "@/lib/api";

function useAddModulCardItem() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data: { level_id: string; movement_id: string }) =>
      apiPost(`/api/digital-library/modul-cards`, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["dl-menu"] });
    },
  });
}

function useDeleteModulCardItem() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data: { level_id: string; movement_id: string }) =>
      apiDelete(`/api/digital-library/modul-cards/${data.level_id}/${data.movement_id}`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["dl-menu"] });
    },
  });
}

const LEVEL_THEMES: Record<number, { headerBg: string; accent: string }> = {
  1: { headerBg: "bg-amber-500",   accent: "bg-amber-50" },
  2: { headerBg: "bg-sky-600",     accent: "bg-sky-50" },
  3: { headerBg: "bg-emerald-600", accent: "bg-emerald-50" },
  4: { headerBg: "bg-violet-600",  accent: "bg-violet-50" },
  5: { headerBg: "bg-rose-600",    accent: "bg-rose-50" },
};

function getYouTubeEmbedUrl(url: string) {
  if (!url) return '';
  let videoId = '';
  if (url.includes('youtu.be/')) {
    videoId = url.split('youtu.be/')[1]?.split('?')[0];
  } else if (url.includes('youtube.com/watch')) {
    const params = new URLSearchParams(url.split('?')[1]);
    videoId = params.get('v') || '';
  } else if (url.includes('youtube.com/shorts/')) {
    videoId = url.split('youtube.com/shorts/')[1]?.split('?')[0];
  }
  return videoId ? `https://www.youtube.com/embed/${videoId}` : '';
}

export default function ModulCardPage() {
  // force recompile
  const { data: levelsData, isLoading: isLoadingLevels } = useDLLevels();
  const levels = (levelsData?.data ?? []) as any[];
  
  const activeLevels = levels.filter((l: any) => l.level_number > 0).sort((a: any, b: any) => a.level_number - b.level_number);
  
  const [selectedLevel, setSelectedLevel] = useState<number>(1);
  const selectedLevelData = activeLevels.find((l: any) => l.level_number === selectedLevel);
  
  const [selectedGender, setSelectedGender] = useState<'Male'|'Female'>('Male');
  const { data: fcData, isLoading: isLoadingFC } = useDLMenuItems("fc", selectedLevel, selectedGender.toLowerCase());
  const { data: ccData, isLoading: isLoadingCC } = useDLMenuItems("cc", selectedLevel, selectedGender.toLowerCase());
  const { data: mcData, isLoading: isLoadingMC } = useDLMenuItems("mc", selectedLevel, selectedGender.toLowerCase());
  const { data: cdData, isLoading: isLoadingCD } = useDLMenuItems("cd", selectedLevel, selectedGender.toLowerCase());
  
  const isLoadingItems = isLoadingFC || isLoadingCC || isLoadingMC || isLoadingCD;
  
  const fcItems = Array.isArray(fcData?.data) ? fcData.data : [];
  const ccItems = Array.isArray(ccData?.data) ? ccData.data : [];
  const mcItems = Array.isArray(mcData?.data) ? mcData.data : [];
  const cdItems = Array.isArray(cdData?.data) ? cdData.data : [];

  const allItems = [
    ...fcItems.map((i: any) => ({ ...i, sequence: "FC" })),
    ...ccItems.map((i: any) => ({ ...i, sequence: "CC" })),
    ...mcItems.map((i: any) => ({ ...i, sequence: "MC" })),
    ...cdItems.map((i: any) => ({ ...i, sequence: "CD" }))
  ];

  const groupedData: any[] = [];
  const sequences = ["FC", "CC", "MC", "CD"];
  
  for (const seq of sequences) {
    const seqItems = allItems.filter(i => i.sequence === seq).sort((a,b) => a.sort_order - b.sort_order);
    if (seqItems.length === 0) continue;

    const setsMap = new Map<string, any[]>();
    for (const item of seqItems) {
      const setName = item.set_name || "Uncategorized";
      if (!setsMap.has(setName)) setsMap.set(setName, []);
      setsMap.get(setName)!.push(item);
    }

    let isFirstSeqRow = true;
    const seqRowspan = seqItems.length;

    for (const [setName, setItems] of Array.from(setsMap.entries())) {
      const patternsMap = new Map<string, any[]>();
      for (const item of setItems) {
        // Excel TYPE column is stored in item.group_type
        const typeName = item.group_type || "Isolate";
        if (!patternsMap.has(typeName)) patternsMap.set(typeName, []);
        patternsMap.get(typeName)!.push(item);
      }

      let isFirstSetRow = true;
      const setRowspan = setItems.length;

      for (const [patternName, patternItems] of Array.from(patternsMap.entries())) {
        const sectionsMap = new Map<string, any[]>();
        for (const item of patternItems) {
          // Excel SECTION column is stored in item.movement?.pattern
          const sectionName = item.movement?.pattern || "-";
          if (!sectionsMap.has(sectionName)) sectionsMap.set(sectionName, []);
          sectionsMap.get(sectionName)!.push(item);
        }

        let isFirstPatternRow = true;
        const patternRowspan = patternItems.length;

        for (const [sectionName, sectionItems] of Array.from(sectionsMap.entries())) {
          let isFirstSectionRow = true;
          const sectionRowspan = sectionItems.length;

          for (const item of sectionItems) {
            groupedData.push({
              ...item,
              renderSeq: isFirstSeqRow ? { name: seq, span: seqRowspan } : null,
              renderSet: isFirstSetRow ? { name: setName, span: setRowspan } : null,
              renderPattern: isFirstPatternRow ? { name: patternName, span: patternRowspan } : null,
              renderSection: isFirstSectionRow ? { name: sectionName, span: sectionRowspan } : null,
            });
            isFirstSeqRow = false;
            isFirstSetRow = false;
            isFirstPatternRow = false;
            isFirstSectionRow = false;
          }
        }
      }
    }
  }

  const addMutation = useAddModulCardItem();
  const deleteMutation = useDeleteModulCardItem();
  const updateMovementMutation = useUpdateDLMovement();
  
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [itemToDelete, setItemToDelete] = useState<any>(null);
  const [itemToEdit, setItemToEdit] = useState<any>(null);
  const [videoModalUrl, setVideoModalUrl] = useState<string | null>(null);

  const theme = LEVEL_THEMES[selectedLevel] || { headerBg: "bg-slate-600", accent: "bg-slate-50" };

  if (isLoadingLevels) {
    return (
      <div className="flex h-full items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-sf-systemBlue" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">Modul Card</h1>
          <p className="text-sm text-slate-500 mt-1">
            Kelola daftar latihan berdasarkan Level persis seperti format Excel.
          </p>
        </div>
      </div>

      <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
        {activeLevels.map((lvl) => {
          const isActive = selectedLevel === lvl.level_number;
          const lt = LEVEL_THEMES[lvl.level_number] || { headerBg: "bg-slate-600", accent: "bg-slate-50" };
          return (
            <button
              key={lvl.id}
              onClick={() => setSelectedLevel(lvl.level_number)}
              className={cn(
                "flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-semibold whitespace-nowrap transition-all border",
                isActive
                  ? `text-white ${lt.headerBg} shadow-sm border-transparent`
                  : "bg-white text-slate-600 border-slate-200 hover:bg-slate-50"
              )}
            >
              <span>{lvl.name}</span>
            </button>
          );
        })}
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
        <div className={cn("px-6 py-4 flex justify-between items-center text-white", theme.headerBg)}>
          <div>
            <h2 className="font-semibold text-lg">{selectedLevelData?.name}</h2>
            <p className="text-white/80 text-sm">{selectedLevelData?.name_id}</p>
          </div>
          <button
            onClick={() => setIsAddModalOpen(true)}
            className="flex items-center gap-2 px-4 py-2 bg-white/20 hover:bg-white/30 transition-colors rounded-lg text-sm font-medium"
          >
            <Plus className="h-4 w-4" />
            <span className="hidden sm:inline">Tambah Latihan</span>
          </button>
        </div>

        <div className="p-0 overflow-x-auto">
          {isLoadingItems ? (
            <div className="flex justify-center p-12">
              <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
            </div>
          ) : allItems.length === 0 ? (
            <EmptyState
              icon={Video}
              title="Belum ada latihan"
              description={`Tambahkan latihan pertama untuk ${selectedLevelData?.name}`}
              action={
                <button 
                  onClick={() => setIsAddModalOpen(true)}
                  className="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm"
                >
                  Tambah Latihan
                </button>
              }
            />
          ) : (
            <table className="w-full text-sm text-left border-collapse">
              <thead className="bg-slate-50 text-slate-600 border-b border-slate-200">
                <tr>
                  <th className="px-4 py-3 font-semibold border-r border-slate-200 w-16 text-center">SEQUENCE</th>
                  <th className="px-4 py-3 font-semibold border-r border-slate-200 w-24 text-center">SET/TRACK</th>
                  <th className="px-4 py-3 font-semibold border-r border-slate-200 w-24 text-center">TYPE</th>
                  <th className="px-4 py-3 font-semibold border-r border-slate-200 w-32 text-center">SECTION</th>
                  <th className="px-4 py-3 font-semibold border-r border-slate-200">FEMALE</th>
                  <th className="px-4 py-3 font-semibold border-r border-slate-200">MALE</th>
                  <th className="px-4 py-3 font-semibold w-20 text-center"></th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200">
                {groupedData.map((row, idx) => (
                  <tr key={row.id} className="hover:bg-slate-50/50 transition-colors">
                    {row.renderSeq && (
                      <td 
                        rowSpan={row.renderSeq.span} 
                        className="px-4 py-3 border-r border-slate-200 text-center font-bold text-slate-700 align-top"
                      >
                        {row.renderSeq.name}
                      </td>
                    )}
                    {row.renderSet && (
                      <td 
                        rowSpan={row.renderSet.span} 
                        className="px-4 py-3 border-r border-slate-200 text-center text-slate-600 align-top font-medium"
                      >
                        {row.renderSet.name}
                      </td>
                    )}
                    {row.renderPattern && (
                      <td 
                        rowSpan={row.renderPattern.span} 
                        className="px-4 py-3 border-r border-slate-200 text-center text-slate-600 align-top"
                      >
                        {row.renderPattern.name}
                      </td>
                    )}
                    {row.renderSection && (
                      <td 
                        rowSpan={row.renderSection.span} 
                        className="px-4 py-3 border-r border-slate-200 text-center text-slate-600 align-top"
                      >
                        {row.renderSection.name}
                      </td>
                    )}
                    <td className="px-4 py-3 border-r border-slate-200">
                      <div className="flex items-center justify-between gap-2">
                        <span className="font-medium text-slate-900">{row.movement?.name ? row.movement.name.split(" | ")[0].replace(/\s*\[L\d+\]$/, "") : ""}</span>
                        {row.movement?.video_url_female && (
                          <button onClick={() => setVideoModalUrl(row.movement.video_url_female)} className="text-blue-500 hover:text-blue-700 focus:outline-none">
                            <Video className="w-4 h-4" />
                          </button>
                        )}
                      </div>
                    </td>
                    <td className="px-4 py-3 border-r border-slate-200">
                      <div className="flex items-center justify-between gap-2">
                        <span className="font-medium text-slate-900">{row.movement?.name ? (row.movement.name.split(" | ").length > 1 ? row.movement.name.split(" | ")[1].replace(/\s*\[L\d+\]$/, "") : row.movement.name.split(" | ")[0].replace(/\s*\[L\d+\]$/, "")) : ""}</span>
                        {row.movement?.video_url_male && (
                          <button onClick={() => setVideoModalUrl(row.movement.video_url_male)} className="text-blue-500 hover:text-blue-700 focus:outline-none">
                            <Video className="w-4 h-4" />
                          </button>
                        )}
                      </div>
                    </td>
                    <td className="px-4 py-3 text-center align-top whitespace-nowrap">
                      <button
                        onClick={() => setItemToEdit(row)}
                        className="p-1.5 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-md transition-colors mr-1"
                        title="Edit URL Video"
                      >
                        <Pencil className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() => setItemToDelete(row)}
                        className="p-1.5 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-md transition-colors"
                        title="Hapus dari Modul"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>

      {isAddModalOpen && selectedLevelData && (
        <AddMovementModal
          level={selectedLevelData}
          onClose={() => setIsAddModalOpen(false)}
          onAdd={async (movementId) => {
            await addMutation.mutateAsync({
              level_id: selectedLevelData.id,
              movement_id: movementId,
            });
            setIsAddModalOpen(false);
          }}
          isLoading={addMutation.isPending}
        />
      )}

      <ConfirmDialog
        open={!!itemToDelete}
        onClose={() => setItemToDelete(null)}
        onConfirm={async () => {
          if (itemToDelete) {
            await deleteMutation.mutateAsync({
              level_id: itemToDelete.level_id,
              movement_id: itemToDelete.movement_id
            });
            setItemToDelete(null);
          }
        }}
        title="Hapus Latihan"
        description={`Apakah Anda yakin ingin menghapus "${itemToDelete?.movement?.name}"?`}
        confirmLabel={deleteMutation.isPending ? "Menghapus..." : "Hapus"}
      />

      {itemToEdit && (
        <EditVideoModal
          item={itemToEdit}
          onClose={() => setItemToEdit(null)}
          onSave={async (femaleUrl, maleUrl) => {
            await updateMovementMutation.mutateAsync({
              id: itemToEdit.movement_id,
              data: {
                video_url_female: femaleUrl,
                video_url_male: maleUrl
              }
            });
            setItemToEdit(null);
          }}
          isLoading={updateMovementMutation.isPending}
        />
      )}

      {/* Video Modal */}
      {videoModalUrl && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm" onClick={() => setVideoModalUrl(null)}>
          <div className="relative bg-black rounded-xl shadow-2xl w-full max-w-2xl overflow-hidden border border-slate-700" onClick={(e) => e.stopPropagation()}>
            <div className="flex justify-between items-center p-3 bg-slate-900 border-b border-slate-800">
              <h3 className="font-medium text-slate-200 text-sm">Video Preview</h3>
              <button 
                onClick={() => setVideoModalUrl(null)}
                className="p-1 hover:bg-slate-800 rounded-full transition-colors text-slate-400 hover:text-white"
              >
                <X className="w-4 h-4" />
              </button>
            </div>
            <div className="w-full aspect-video bg-black">
              <iframe
                src={getYouTubeEmbedUrl(videoModalUrl)}
                className="w-full h-full"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowFullScreen
              ></iframe>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// ─── Add Movement Modal ─────────────────────────────────────────

function AddMovementModal({
  level,
  onClose,
  onAdd,
  isLoading,
}: {
  level: any;
  onClose: () => void;
  onAdd: (movementId: string) => void;
  isLoading: boolean;
}) {
  const [search, setSearch] = useState("");
  const { data: movementsData, isLoading: isLoadingMovements } = useDLMovements({
    page: 1,
    limit: 50,
    search: search.length >= 2 ? search : undefined,
  });

  const movements = (movementsData?.data || []) as any[];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/50 backdrop-blur-sm">
      <div className="bg-white rounded-2xl shadow-xl w-full max-w-lg overflow-hidden flex flex-col max-h-[85vh]">
        <div className="p-4 border-b border-slate-100 flex justify-between items-center bg-slate-50/50">
          <div>
            <h3 className="font-semibold text-slate-900">Tambah Latihan</h3>
            <p className="text-xs text-slate-500">ke {level.name}</p>
          </div>
          <button onClick={onClose} className="p-2 text-slate-400 hover:text-slate-600 rounded-lg">
            <Trash2 className="h-4 w-4 hidden" /> {/* dummy to match size */}
            <span className="text-2xl leading-none">&times;</span>
          </button>
        </div>

        <div className="p-4 border-b border-slate-100">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
            <input
              type="text"
              placeholder="Cari latihan... (min. 2 karakter)"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full pl-9 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-sf-systemBlue/20 focus:border-sf-systemBlue"
            />
          </div>
        </div>

        <div className="flex-1 overflow-y-auto p-2">
          {isLoadingMovements ? (
            <div className="flex justify-center p-8">
              <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
            </div>
          ) : movements.length === 0 ? (
            <div className="text-center p-8 text-slate-500 text-sm">
              Tidak ada hasil ditemukan.
            </div>
          ) : (
            <div className="space-y-1">
              {movements.map((m: any) => (
                <button
                  key={m.id}
                  onClick={() => onAdd(m.id)}
                  disabled={isLoading}
                  className="w-full flex items-center justify-between p-3 rounded-xl hover:bg-slate-50 text-left transition-colors group disabled:opacity-50"
                >
                  <div>
                    <p className="font-medium text-slate-900">{m.name}</p>
                    <p className="text-xs text-slate-500 capitalize">{m.body_part}</p>
                  </div>
                  <ChevronRight className="h-4 w-4 text-slate-300 group-hover:text-sf-systemBlue transition-colors" />
                </button>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

function EditVideoModal({ item, onClose, onSave, isLoading }: { item: any, onClose: () => void, onSave: (f: string, m: string) => void, isLoading: boolean }) {
  const [fUrl, setFUrl] = useState(item?.movement?.video_url_female || "");
  const [mUrl, setMUrl] = useState(item?.movement?.video_url_male || "");

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm">
      <div className="bg-white rounded-2xl shadow-xl w-full max-w-md overflow-hidden flex flex-col">
        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50">
          <h3 className="font-semibold text-slate-800">Edit Video URL</h3>
          <button onClick={onClose} className="p-1 text-slate-400 hover:text-slate-600 rounded-lg hover:bg-slate-200/50">
            <X className="w-5 h-5" />
          </button>
        </div>
        <div className="p-6 space-y-4 flex-1 overflow-y-auto">
          <p className="text-sm font-medium text-slate-700 bg-slate-100 p-3 rounded-lg mb-4">{item?.movement?.name}</p>
          <div>
            <label className="block text-xs font-semibold text-slate-600 mb-1.5 uppercase tracking-wide">Video URL (Female)</label>
            <input type="url" value={fUrl} onChange={e => setFUrl(e.target.value)} placeholder="https://youtube.com/..." className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 text-sm" />
          </div>
          <div>
            <label className="block text-xs font-semibold text-slate-600 mb-1.5 uppercase tracking-wide">Video URL (Male)</label>
            <input type="url" value={mUrl} onChange={e => setMUrl(e.target.value)} placeholder="https://youtube.com/..." className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 text-sm" />
          </div>
        </div>
        <div className="p-4 border-t border-slate-100 bg-slate-50 flex justify-end gap-2">
          <button onClick={onClose} className="px-4 py-2 text-sm font-medium text-slate-600 hover:bg-slate-200 rounded-lg transition-colors">Batal</button>
          <button onClick={() => onSave(fUrl, mUrl)} disabled={isLoading} className="flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 disabled:opacity-50 rounded-lg transition-colors">
            {isLoading ? <Loader2 className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
            <span>Simpan</span>
          </button>
        </div>
      </div>
    </div>
  );
}

