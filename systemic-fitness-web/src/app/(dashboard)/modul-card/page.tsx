"use client";

import { useState } from "react";
import { Plus, Trash2, Loader2, Video, Search, ChevronRight } from "lucide-react";
import { cn } from "@/lib/utils";
import {
  useDLLevels,
  useDLMenuItems,
  useDLMovements,
  useAddModulCardItem,
  useDeleteModulCardItem,
} from "@/hooks/useDigitalLibrary";
import { EmptyState } from "@/components/shared/EmptyState";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";

const LEVEL_THEMES: Record<number, { headerBg: string; accent: string }> = {
  1: { headerBg: "bg-amber-500",   accent: "bg-amber-50" },
  2: { headerBg: "bg-sky-600",     accent: "bg-sky-50" },
  3: { headerBg: "bg-emerald-600", accent: "bg-emerald-50" },
  4: { headerBg: "bg-violet-600",  accent: "bg-violet-50" },
  5: { headerBg: "bg-rose-600",    accent: "bg-rose-50" },
};

export default function ModulCardPage() {
  const { data: levels = [], isLoading: isLoadingLevels } = useDLLevels();
  
  // Exclude level 0 based on user requirements
  const activeLevels = levels.filter(l => l.level_number > 0).sort((a, b) => a.level_number - b.level_number);
  
  const [selectedLevel, setSelectedLevel] = useState<number>(1);
  const selectedLevelData = activeLevels.find(l => l.level_number === selectedLevel);
  
  // We use 'fc' as the base category to fetch menu items since they are identical across FC, CC, MC
  const { data: menuItems = [], isLoading: isLoadingItems } = useDLMenuItems("fc", selectedLevel);
  
  const addMutation = useAddModulCardItem();
  const deleteMutation = useDeleteModulCardItem();
  
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [itemToDelete, setItemToDelete] = useState<any>(null);

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
            Kelola daftar latihan berdasarkan Level (Level 1 - 5).
          </p>
        </div>
      </div>

      {/* Level Tabs */}
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

      {/* Content Area */}
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

        <div className="p-0">
          {isLoadingItems ? (
            <div className="flex justify-center p-12">
              <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
            </div>
          ) : menuItems.length === 0 ? (
            <EmptyState
              icon={Video}
              title="Belum ada latihan"
              description={`Tambahkan latihan pertama untuk ${selectedLevelData?.name}`}
              actionLabel="Tambah Latihan"
              onAction={() => setIsAddModalOpen(true)}
            />
          ) : (
            <div className="divide-y divide-slate-100">
              {menuItems.map((item, idx) => (
                <div key={item.id} className="flex items-center justify-between p-4 hover:bg-slate-50 transition-colors">
                  <div className="flex items-center gap-4">
                    <div className={cn(
                      "w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold",
                      theme.accent, theme.headerBg.replace('bg-', 'text-')
                    )}>
                      {idx + 1}
                    </div>
                    <div>
                      <p className="font-semibold text-slate-900">{item.movement?.name}</p>
                      <div className="flex gap-2 text-xs mt-1">
                        <span className="text-slate-500 uppercase tracking-wider">{item.body_part}</span>
                        {item.movement?.type && (
                          <>
                            <span className="text-slate-300">•</span>
                            <span className="text-slate-500">{item.movement.type}</span>
                          </>
                        )}
                      </div>
                    </div>
                  </div>
                  
                  <button
                    onClick={() => setItemToDelete(item)}
                    className="p-2 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>
              ))}
            </div>
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
        isOpen={!!itemToDelete}
        onClose={() => setItemToDelete(null)}
        onConfirm={async () => {
          if (itemToDelete) {
            await deleteMutation.mutateAsync({
              level_id: itemToDelete.level_id,
              movement_id: itemToDelete.movement_id,
            });
            setItemToDelete(null);
          }
        }}
        title="Hapus Latihan"
        description={`Apakah Anda yakin ingin menghapus "${itemToDelete?.movement?.name}" dari Level ${selectedLevel}? Tindakan ini akan menghapusnya dari semua kategori (FC, CC, MC).`}
        confirmLabel={deleteMutation.isPending ? "Menghapus..." : "Hapus"}
        isDestructive
      />
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

  const movements = movementsData?.data || [];

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
