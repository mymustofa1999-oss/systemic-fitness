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
  
  const { data: fcData, isLoading: isLoadingFC } = useDLMenuItems("fc", selectedLevel);
  const { data: ccData, isLoading: isLoadingCC } = useDLMenuItems("cc", selectedLevel);
  const { data: mcData, isLoading: isLoadingMC } = useDLMenuItems("mc", selectedLevel);
  const { data: cdData, isLoading: isLoadingCD } = useDLMenuItems("cd", selectedLevel);
  
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

 f u n c t i o n   E d i t V i d e o M o d a l ( {   i t e m ,   o n C l o s e ,   o n S a v e ,   i s L o a d i n g   } :   {   i t e m :   a n y ,   o n C l o s e :   ( )   = >   v o i d ,   o n S a v e :   ( f :   s t r i n g ,   m :   s t r i n g )   = >   v o i d ,   i s L o a d i n g :   b o o l e a n   } )   { 
     c o n s t   [ f U r l ,   s e t F U r l ]   =   u s e S t a t e ( i t e m ? . m o v e m e n t ? . v i d e o _ u r l _ f e m a l e   | |   " " ) ; 
     c o n s t   [ m U r l ,   s e t M U r l ]   =   u s e S t a t e ( i t e m ? . m o v e m e n t ? . v i d e o _ u r l _ m a l e   | |   " " ) ; 
 
     r e t u r n   ( 
         < d i v   c l a s s N a m e = " f i x e d   i n s e t - 0   z - 5 0   f l e x   i t e m s - c e n t e r   j u s t i f y - c e n t e r   p - 4   b g - s l a t e - 9 0 0 / 6 0   b a c k d r o p - b l u r - s m " > 
             < d i v   c l a s s N a m e = " b g - w h i t e   r o u n d e d - 2 x l   s h a d o w - x l   w - f u l l   m a x - w - m d   o v e r f l o w - h i d d e n   f l e x   f l e x - c o l " > 
                 < d i v   c l a s s N a m e = " p x - 6   p y - 4   b o r d e r - b   b o r d e r - s l a t e - 1 0 0   f l e x   j u s t i f y - b e t w e e n   i t e m s - c e n t e r   b g - s l a t e - 5 0 " > 
                     < h 3   c l a s s N a m e = " f o n t - s e m i b o l d   t e x t - s l a t e - 8 0 0 " > E d i t   V i d e o   U R L < / h 3 > 
                     < b u t t o n   o n C l i c k = { o n C l o s e }   c l a s s N a m e = " p - 1   t e x t - s l a t e - 4 0 0   h o v e r : t e x t - s l a t e - 6 0 0   r o u n d e d - l g   h o v e r : b g - s l a t e - 2 0 0 / 5 0 " > 
                         < X   c l a s s N a m e = " w - 5   h - 5 "   / > 
                     < / b u t t o n > 
                 < / d i v > 
                 < d i v   c l a s s N a m e = " p - 6   s p a c e - y - 4   f l e x - 1   o v e r f l o w - y - a u t o " > 
                     < p   c l a s s N a m e = " t e x t - s m   f o n t - m e d i u m   t e x t - s l a t e - 7 0 0   b g - s l a t e - 1 0 0   p - 3   r o u n d e d - l g   m b - 4 " > { i t e m ? . m o v e m e n t ? . n a m e } < / p > 
                     < d i v > 
                         < l a b e l   c l a s s N a m e = " b l o c k   t e x t - x s   f o n t - s e m i b o l d   t e x t - s l a t e - 6 0 0   m b - 1 . 5   u p p e r c a s e   t r a c k i n g - w i d e " > V i d e o   U R L   ( F e m a l e ) < / l a b e l > 
                         < i n p u t   t y p e = " u r l "   v a l u e = { f U r l }   o n C h a n g e = { e   = >   s e t F U r l ( e . t a r g e t . v a l u e ) }   p l a c e h o l d e r = " h t t p s : / / y o u t u b e . c o m / . . . "   c l a s s N a m e = " w - f u l l   p x - 3   p y - 2   b o r d e r   b o r d e r - s l a t e - 2 0 0   r o u n d e d - l g   f o c u s : o u t l i n e - n o n e   f o c u s : r i n g - 2   f o c u s : r i n g - b l u e - 5 0 0 / 2 0   f o c u s : b o r d e r - b l u e - 5 0 0   t e x t - s m "   / > 
                     < / d i v > 
                     < d i v > 
                         < l a b e l   c l a s s N a m e = " b l o c k   t e x t - x s   f o n t - s e m i b o l d   t e x t - s l a t e - 6 0 0   m b - 1 . 5   u p p e r c a s e   t r a c k i n g - w i d e " > V i d e o   U R L   ( M a l e ) < / l a b e l > 
                         < i n p u t   t y p e = " u r l "   v a l u e = { m U r l }   o n C h a n g e = { e   = >   s e t M U r l ( e . t a r g e t . v a l u e ) }   p l a c e h o l d e r = " h t t p s : / / y o u t u b e . c o m / . . . "   c l a s s N a m e = " w - f u l l   p x - 3   p y - 2   b o r d e r   b o r d e r - s l a t e - 2 0 0   r o u n d e d - l g   f o c u s : o u t l i n e - n o n e   f o c u s : r i n g - 2   f o c u s : r i n g - b l u e - 5 0 0 / 2 0   f o c u s : b o r d e r - b l u e - 5 0 0   t e x t - s m "   / > 
                     < / d i v > 
                 < / d i v > 
                 < d i v   c l a s s N a m e = " p - 4   b o r d e r - t   b o r d e r - s l a t e - 1 0 0   b g - s l a t e - 5 0   f l e x   j u s t i f y - e n d   g a p - 2 " > 
                     < b u t t o n   o n C l i c k = { o n C l o s e }   c l a s s N a m e = " p x - 4   p y - 2   t e x t - s m   f o n t - m e d i u m   t e x t - s l a t e - 6 0 0   h o v e r : b g - s l a t e - 2 0 0   r o u n d e d - l g   t r a n s i t i o n - c o l o r s " > B a t a l < / b u t t o n > 
                     < b u t t o n   o n C l i c k = { ( )   = >   o n S a v e ( f U r l ,   m U r l ) }   d i s a b l e d = { i s L o a d i n g }   c l a s s N a m e = " f l e x   i t e m s - c e n t e r   g a p - 2   p x - 4   p y - 2   t e x t - s m   f o n t - m e d i u m   t e x t - w h i t e   b g - b l u e - 6 0 0   h o v e r : b g - b l u e - 7 0 0   d i s a b l e d : o p a c i t y - 5 0   r o u n d e d - l g   t r a n s i t i o n - c o l o r s " > 
                         { i s L o a d i n g   ?   < L o a d e r 2   c l a s s N a m e = " w - 4   h - 4   a n i m a t e - s p i n "   / >   :   < S a v e   c l a s s N a m e = " w - 4   h - 4 "   / > } 
                         < s p a n > S i m p a n < / s p a n > 
                     < / b u t t o n > 
                 < / d i v > 
             < / d i v > 
         < / d i v > 
     ) ; 
 } 
  
 