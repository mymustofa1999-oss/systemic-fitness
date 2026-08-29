"use client";

import { useState } from "react";
import { Plus, Trash2, Loader2, Video, Search, ChevronRight, X, Pencil, Save, PlusCircle } from "lucide-react";
import { cn } from "@/lib/utils";
import {
  useDLLevels,
  useDLMenuItems,
  useDLMovements,
  useUpdateDLMenuItem,
  useCreateDLMovement
} from "@/hooks/useDigitalLibrary";
import { EmptyState } from "@/components/shared/EmptyState";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { apiPost, apiDelete } from "@/lib/api";
import { toast } from "@/stores/toastStore";

// Hooks
function useAddModulCardItem() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data: { level_id: string; movement_id: string; category_code?: string; set_name?: string; group_type?: string; section?: string; target_gender?: string }) =>
      apiPost(`/api/digital-library/modul-cards`, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["dl-menu"] });
      toast.success("Exercise added successfully");
    },
    onError: () => {
      toast.error("Failed to add exercise");
    }
  });
}

function useDeleteModulCardItem() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => apiDelete(`/api/digital-library/menu/${id}`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["dl-menu"] });
      toast.success("Exercise deleted");
    },
  });
}

// Sub-components
function EditVideoModal({ item, onClose }: { item: any; onClose: () => void }) {
  const updateMutation = useUpdateDLMenuItem();
  const gender = item.target_gender === 'female' ? 'Female' : 'Male';
  const initialUrl = item.target_gender === 'female' ? item.video_url_female : item.video_url_male;
  const [url, setUrl] = useState(initialUrl || "");

  const handleSave = async () => {
    try {
      if (item.target_gender === 'female') {
        await updateMutation.mutateAsync({ id: item.id, data: { video_url_female: url } });
      } else {
        await updateMutation.mutateAsync({ id: item.id, data: { video_url_male: url } });
      }
      onClose();
    } catch (err) {}
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/50 backdrop-blur-sm">
      <div className="bg-white rounded-2xl shadow-xl w-full max-w-md overflow-hidden flex flex-col">
        <div className="p-4 border-b border-slate-100 flex justify-between items-center bg-slate-50">
          <h3 className="font-semibold text-slate-900">Edit Video URL ({gender})</h3>
          <button onClick={onClose} className="text-slate-400 hover:text-slate-600"><X className="h-5 w-5" /></button>
        </div>
        <div className="p-4 space-y-4">
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Video URL</label>
            <input type="text" value={url} onChange={(e) => setUrl(e.target.value)} className="w-full border border-slate-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 outline-none" placeholder="https://..." />
          </div>
          <div className="flex justify-end gap-2 pt-2">
            <button onClick={onClose} className="px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-100 rounded-lg">Batal</button>
            <button onClick={handleSave} disabled={updateMutation.isPending} className="px-4 py-2 text-sm font-medium bg-blue-600 text-white rounded-lg flex items-center gap-2">
              {updateMutation.isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />} Simpan
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

function AddMovementModal({
  level,
  gender,
  onClose,
  onAdd,
  isLoading,
}: {
  level: any;
  gender: string;
  onClose: () => void;
  onAdd: (data: any) => void;
  isLoading: boolean;
}) {
  const [tab, setTab] = useState<'search'|'create'>('search');
  
  // Search state
  const [search, setSearch] = useState("");
  const { data: movementsData } = useDLMovements({ page: 1, limit: 50, search: search.length >= 2 ? search : undefined });
  const movements = (movementsData?.data || []) as any[];
  const [selectedMovementId, setSelectedMovementId] = useState("");

  // Create state
  const [newName, setNewName] = useState("");
  const [newBodyPart, setNewBodyPart] = useState("upper");
  const [newVideoUrl, setNewVideoUrl] = useState("");
  const createMutation = useCreateDLMovement();

  // Position state
  const [sequence, setSequence] = useState("FC");
  const [setTrack, setSetTrack] = useState("Set 1");
  const [groupType, setGroupType] = useState("Isolate");
  const [section, setSection] = useState("Sit Upper");

  const handleSubmit = async () => {
    if (tab === 'search') {
      if (!selectedMovementId) return toast.error("Please select an exercise");
      onAdd({
        movement_id: selectedMovementId,
        category_code: sequence,
        set_name: setTrack,
        group_type: groupType,
        section: section,
        target_gender: gender.toLowerCase()
      });
    } else {
      if (!newName.trim()) return toast.error("Please enter exercise name");
      try {
        const res = await createMutation.mutateAsync({
          name: newName,
          body_part: newBodyPart,
          video_url_male: gender.toLowerCase() === 'male' ? newVideoUrl : undefined,
          video_url_female: gender.toLowerCase() === 'female' ? newVideoUrl : undefined,
          target_gender: "universal"
        });
        const newMovId = res.data?.id;
        if (newMovId) {
          onAdd({
            movement_id: newMovId,
            category_code: sequence,
            set_name: setTrack,
            group_type: groupType,
            section: section,
            target_gender: gender.toLowerCase()
          });
        }
      } catch (err) {
        toast.error("Failed to create exercise");
      }
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm">
      <div className="bg-white rounded-2xl shadow-xl w-full max-w-3xl flex flex-col max-h-[90vh]">
        <div className="p-4 border-b border-slate-100 flex justify-between items-center bg-slate-50/50 rounded-t-2xl">
          <div>
            <h3 className="font-bold text-lg text-slate-900">Add Exercise to {level.name} {gender}</h3>
          </div>
          <button onClick={onClose} className="text-slate-400 hover:text-slate-600"><X className="h-6 w-6" /></button>
        </div>

        <div className="flex border-b border-slate-200">
          <button onClick={() => setTab('search')} className={cn("flex-1 py-3 text-sm font-medium border-b-2 transition-colors", tab === 'search' ? "border-sf-warmGold text-sf-warmGold" : "border-transparent text-slate-500 hover:text-slate-700")}>
            Search Existing
          </button>
          <button onClick={() => setTab('create')} className={cn("flex-1 py-3 text-sm font-medium border-b-2 transition-colors", tab === 'create' ? "border-sf-warmGold text-sf-warmGold" : "border-transparent text-slate-500 hover:text-slate-700")}>
            Create New Exercise
          </button>
        </div>

        <div className="p-6 overflow-y-auto space-y-8">
          {tab === 'create' ? (
            <div className="space-y-4">
              <h4 className="text-sm font-bold text-slate-800 uppercase tracking-wider">1. New Exercise Details</h4>
              <div className="grid grid-cols-2 gap-4">
                <div className="col-span-2">
                  <label className="block text-xs font-medium text-slate-500 mb-1">Exercise Name</label>
                  <input type="text" value={newName} onChange={e => setNewName(e.target.value)} className="w-full border border-slate-200 rounded-lg p-2 text-sm" placeholder="e.g., Push Up" />
                </div>
                <div>
                  <label className="block text-xs font-medium text-slate-500 mb-1">Body Part</label>
                  <select value={newBodyPart} onChange={e => setNewBodyPart(e.target.value)} className="w-full border border-slate-200 rounded-lg p-2 text-sm bg-white">
                    <option value="upper">Upper</option>
                    <option value="lower">Lower</option>
                    <option value="core">Core</option>
                    <option value="full">Full Body</option>
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-medium text-slate-500 mb-1">Video URL ({gender})</label>
                  <input type="text" value={newVideoUrl} onChange={e => setNewVideoUrl(e.target.value)} className="w-full border border-slate-200 rounded-lg p-2 text-sm" placeholder="https://..." />
                </div>
              </div>
            </div>
          ) : (
            <div className="space-y-4">
              <h4 className="text-sm font-bold text-slate-800 uppercase tracking-wider">1. Select Existing Exercise</h4>
              <div className="relative">
                <Search className="absolute left-3 top-2.5 h-4 w-4 text-slate-400" />
                <input type="text" placeholder="Search exercises..." value={search} onChange={e => setSearch(e.target.value)} className="w-full pl-9 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-sf-warmGold" />
              </div>
              <div className="border border-slate-200 rounded-lg max-h-[150px] overflow-y-auto divide-y divide-slate-100">
                {movements.length === 0 ? (
                  <div className="p-3 text-center text-sm text-slate-500">No exercises found.</div>
                ) : (
                  movements.map(m => (
                    <button key={m.id} onClick={() => setSelectedMovementId(m.id)} className={cn("w-full text-left p-3 text-sm hover:bg-slate-50 flex justify-between items-center", selectedMovementId === m.id && "bg-blue-50 hover:bg-blue-50")}>
                      <span className="font-medium text-slate-800">{m.name}</span>
                      <span className="text-xs text-slate-500 capitalize">{m.body_part}</span>
                    </button>
                  ))
                )}
              </div>
            </div>
          )}

          <div className="space-y-4">
            <h4 className="text-sm font-bold text-slate-800 uppercase tracking-wider">2. Position in Training Module</h4>
            <div className="grid grid-cols-4 gap-4">
              <div>
                <label className="block text-xs font-medium text-slate-500 mb-1">Sequence (Category)</label>
                <select value={sequence} onChange={e => setSequence(e.target.value)} className="w-full border border-slate-200 rounded-lg p-2 text-sm bg-white">
                  <option value="FC">FC (Floor Conditioning)</option>
                  <option value="CC">CC (Core Conditioning)</option>
                  <option value="MC">MC (Muscle Conditioning)</option>
                  <option value="CD">CD (Cool Down)</option>
                </select>
              </div>
              <div>
                <label className="block text-xs font-medium text-slate-500 mb-1">Set / Track</label>
                <select value={setTrack} onChange={e => setSetTrack(e.target.value)} className="w-full border border-slate-200 rounded-lg p-2 text-sm bg-white">
                  <option value="Set 1">Set 1</option>
                  <option value="Set 2">Set 2</option>
                  <option value="Set 3">Set 3</option>
                  <option value="Set 4">Set 4</option>
                  <option value="Set 5">Set 5</option>
                </select>
              </div>
              <div>
                <label className="block text-xs font-medium text-slate-500 mb-1">Type (Group)</label>
                <select value={groupType} onChange={e => setGroupType(e.target.value)} className="w-full border border-slate-200 rounded-lg p-2 text-sm bg-white">
                  <option value="Isolate">Isolate</option>
                  <option value="Dynamic">Dynamic</option>
                  <option value="Static">Static</option>
                </select>
              </div>
              <div>
                <label className="block text-xs font-medium text-slate-500 mb-1">Section (Pattern)</label>
                <select value={section} onChange={e => setSection(e.target.value)} className="w-full border border-slate-200 rounded-lg p-2 text-sm bg-white">
                  <option value="Sit Upper">Sit Upper</option>
                  <option value="Sit Lower">Sit Lower</option>
                  <option value="Stand Upper">Stand Upper</option>
                  <option value="Stand Lower">Stand Lower</option>
                  <option value="Core">Core</option>
                </select>
              </div>
            </div>
          </div>
        </div>

        <div className="p-4 border-t border-slate-100 flex justify-end gap-3 bg-slate-50/50 rounded-b-2xl">
          <button onClick={onClose} className="px-5 py-2 text-sm font-medium text-slate-600 hover:bg-slate-200 rounded-lg transition-colors">
            Cancel
          </button>
          <button onClick={handleSubmit} disabled={isLoading || createMutation.isPending} className="px-5 py-2 text-sm font-medium bg-sf-warmGold text-white hover:bg-sf-warmGold/90 rounded-lg transition-colors flex items-center gap-2">
            {(isLoading || createMutation.isPending) ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />}
            Save Exercise
          </button>
        </div>
      </div>
    </div>
  );
}

export default function ModulCardPage() {
  const { data: levelsData, isLoading: isLoadingLevels } = useDLLevels();
  const activeLevels = (levelsData?.data || []).filter((l: any) => l.is_active).sort((a: any, b: any) => a.level_number - b.level_number);

  const tabs = activeLevels.flatMap((lvl: any) => [
    { level: lvl, gender: "Female", label: \`\${lvl.name} Female\` },
    { level: lvl, gender: "Male", label: \`\${lvl.name} Male\` }
  ]);

  const [activeTabIndex, setActiveTabIndex] = useState(0);
  const activeTab = tabs[activeTabIndex] || null;
  const selectedLevel = activeTab?.level?.level_number;
  const selectedGender = activeTab?.gender;
  
  const { data: fcData, isLoading: isLoadingFC } = useDLMenuItems("fc", selectedLevel, selectedGender?.toLowerCase());
  const { data: ccData, isLoading: isLoadingCC } = useDLMenuItems("cc", selectedLevel, selectedGender?.toLowerCase());
  const { data: mcData, isLoading: isLoadingMC } = useDLMenuItems("mc", selectedLevel, selectedGender?.toLowerCase());
  const { data: cdData, isLoading: isLoadingCD } = useDLMenuItems("cd", selectedLevel, selectedGender?.toLowerCase());

  const isLoadingItems = isLoadingFC || isLoadingCC || isLoadingMC || isLoadingCD;
  const addMutation = useAddModulCardItem();
  const deleteMutation = useDeleteModulCardItem();
  
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [itemToDelete, setItemToDelete] = useState<any>(null);
  const [itemToEdit, setItemToEdit] = useState<any>(null);

  if (isLoadingLevels) {
    return (
      <div className="p-8 flex items-center justify-center min-h-[400px]">
        <Loader2 className="h-8 w-8 animate-spin text-sf-warmGold" />
      </div>
    );
  }

  if (tabs.length === 0) {
    return (
      <div className="p-8">
        <EmptyState icon={Search} title="Tidak Ada Level" description="Belum ada level yang aktif di Digital Library." />
      </div>
    );
  }

  // Combine and group data
  const allItems = [
    ...(fcData?.data || []).map((i: any) => ({ ...i, sequence: "FC" })),
    ...(ccData?.data || []).map((i: any) => ({ ...i, sequence: "CC" })),
    ...(mcData?.data || []).map((i: any) => ({ ...i, sequence: "MC" })),
    ...(cdData?.data || []).map((i: any) => ({ ...i, sequence: "CD" }))
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
        const patternName = item.group_type || "Uncategorized";
        if (!patternsMap.has(patternName)) patternsMap.set(patternName, []);
        patternsMap.get(patternName)!.push(item);
      }

      let isFirstSetRow = true;
      const setRowspan = setItems.length;

      for (const [patternName, patternItems] of Array.from(patternsMap.entries())) {
        const sectionsMap = new Map<string, any[]>();
        for (const item of patternItems) {
          const sectionName = item.body_part || "Uncategorized";
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

  return (
    <div className="p-8 max-w-[1400px] mx-auto space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Training Module</h1>
        <p className="text-slate-500 mt-1">Manage exercise lists by Level exactly like Excel format.</p>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
        {tabs.map((tab, idx) => {
          const isActive = activeTabIndex === idx;
          return (
            <button
              key={idx}
              onClick={() => setActiveTabIndex(idx)}
              className={cn(
                "px-5 py-2.5 rounded-full text-sm font-medium transition-all whitespace-nowrap border",
                isActive
                  ? "bg-[#f09a1a] border-[#f09a1a] text-white shadow-md shadow-[#f09a1a]/20"
                  : "bg-white border-slate-200 text-slate-600 hover:border-[#f09a1a] hover:text-[#f09a1a]"
              )}
            >
              {tab.label}
            </button>
          );
        })}
      </div>

      {/* Main Card */}
      <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
        {/* Orange Banner Header */}
        <div className="bg-[#f09a1a] p-4 flex justify-between items-center text-white">
          <div>
            <h2 className="text-xl font-bold">{activeTab?.label}</h2>
            <p className="text-sm opacity-90">{activeTab?.level?.name} - {activeTab?.gender}</p>
          </div>
          <button 
            onClick={() => setIsAddModalOpen(true)}
            className="flex items-center gap-2 px-4 py-2 bg-white/20 hover:bg-white/30 transition-colors rounded-lg text-sm font-medium border border-white/20"
          >
            <Plus className="h-4 w-4" /> Add Exercise
          </button>
        </div>

        {/* Content */}
        {isLoadingItems ? (
          <div className="p-12 flex justify-center">
            <Loader2 className="h-8 w-8 animate-spin text-[#f09a1a]" />
          </div>
        ) : groupedData.length === 0 ? (
          <div className="p-12">
            <EmptyState icon={Search} title="Tidak Ada Latihan" description={`Belum ada latihan untuk ${activeTab?.label}.`} />
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm text-left border-collapse">
              <thead className="bg-white text-slate-600 border-b border-slate-200">
                <tr>
                  <th className="px-4 py-3 font-semibold border-r border-slate-200 w-16 text-center text-xs uppercase tracking-wider">SEQUENCE</th>
                  <th className="px-4 py-3 font-semibold border-r border-slate-200 w-24 text-center text-xs uppercase tracking-wider">SET/TRACK</th>
                  <th className="px-4 py-3 font-semibold border-r border-slate-200 w-24 text-center text-xs uppercase tracking-wider">TYPE</th>
                  <th className="px-4 py-3 font-semibold border-r border-slate-200 w-32 text-center text-xs uppercase tracking-wider">SECTION</th>
                  <th className="px-4 py-3 font-semibold text-xs uppercase tracking-wider">EXERCISE</th>
                  <th className="px-4 py-3 w-32"></th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {groupedData.map((row) => (
                  <tr key={row.id} className="hover:bg-slate-50 transition-colors group">
                    {row.renderSeq && (
                      <td rowSpan={row.renderSeq.span} className="px-4 py-3 border-r border-slate-200 text-center font-bold text-slate-700 align-top bg-white">
                        {row.renderSeq.name}
                      </td>
                    )}
                    {row.renderSet && (
                      <td rowSpan={row.renderSet.span} className="px-4 py-3 border-r border-slate-200 text-center text-slate-600 align-top font-medium bg-white">
                        {row.renderSet.name}
                      </td>
                    )}
                    {row.renderPattern && (
                      <td rowSpan={row.renderPattern.span} className="px-4 py-3 border-r border-slate-200 text-center text-slate-600 align-top bg-white">
                        {row.renderPattern.name}
                      </td>
                    )}
                    {row.renderSection && (
                      <td rowSpan={row.renderSection.span} className="px-4 py-3 border-r border-slate-200 text-center text-slate-600 align-top bg-white">
                        {row.renderSection.name}
                      </td>
                    )}
                    <td className="px-4 py-3">
                      <span className="font-medium text-slate-800">{row.movement?.name}</span>
                    </td>
                    <td className="px-4 py-3 text-right">
                      <div className="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                        <button onClick={() => setItemToEdit(row)} className="p-1.5 text-blue-500 hover:bg-blue-50 rounded" title="Edit Video">
                          <Video className="h-4 w-4" />
                        </button>
                        <button onClick={() => setItemToEdit(row)} className="p-1.5 text-slate-400 hover:bg-slate-100 rounded" title="Edit">
                          <Pencil className="h-4 w-4" />
                        </button>
                        <button onClick={() => setItemToDelete(row)} className="p-1.5 text-red-500 hover:bg-red-50 rounded" title="Hapus">
                          <Trash2 className="h-4 w-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {isAddModalOpen && activeTab && (
        <AddMovementModal
          level={activeTab.level}
          gender={activeTab.gender}
          onClose={() => setIsAddModalOpen(false)}
          onAdd={async (data) => {
            await addMutation.mutateAsync({
              level_id: activeTab.level.id,
              ...data
            });
            setIsAddModalOpen(false);
          }}
          isLoading={addMutation.isPending}
        />
      )}

      {itemToEdit && (
        <EditVideoModal item={itemToEdit} onClose={() => setItemToEdit(null)} />
      )}

      <ConfirmDialog
        open={!!itemToDelete}
        onClose={() => setItemToDelete(null)}
        onConfirm={async () => {
          if (itemToDelete) {
            await deleteMutation.mutateAsync(itemToDelete.id);
            setItemToDelete(null);
          }
        }}
        title="Hapus Latihan"
        description={`Hapus "${itemToDelete?.movement?.name}" dari ${activeTab?.label}?`}
        confirmLabel={deleteMutation.isPending ? "Menghapus..." : "Hapus"}
      />
    </div>
  );
}
