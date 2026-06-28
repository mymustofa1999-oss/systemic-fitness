"use client";

import { useState } from "react";
import {
  useHabitFolders, useHabits, useCreateHabit, useCreateHabitFolder,
} from "@/hooks/useNewFeatures";
import { ImageUpload } from "@/components/shared/ImageUpload";
import { EmptyState } from "@/components/shared/EmptyState";
import { SearchInput } from "@/components/shared/SearchInput";
import {
  Target, Plus, Folder, X, Loader2,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { SearchableSelect } from "@/components/shared/SearchableSelect";

export default function HabitsPage() {
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [selectedFolder, setSelectedFolder] = useState<string | null>(null);
  const [createHabitOpen, setCreateHabitOpen] = useState(false);
  const [createFolderOpen, setCreateFolderOpen] = useState(false);

  const { data: foldersData, isLoading: foldersLoading } = useHabitFolders();
  const folders = (foldersData?.data ?? []) as any[];

  const { data, isLoading } = useHabits({
    page,
    limit: 50,
    folder_id: selectedFolder || undefined,
    search,
  });
  const habits = (data?.data ?? []) as any[];
  const meta = data?.meta;

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Master Habits</h1>
          <p className="text-sm text-slate-500 mt-1">
            {meta?.total != null ? `${meta.total} habits` : "Define habits to assign to clients"}
          </p>
        </div>
        <button onClick={() => setCreateHabitOpen(true)} className="btn-primary">
          <Plus className="h-4 w-4" /> Add Habit
        </button>
      </div>

      <div className="flex gap-5">
        {/* Folder Sidebar */}
        <div className="w-56 shrink-0">
          <div className="card p-2 space-y-0.5">
            {/* All option */}
            <button
              onClick={() => { setSelectedFolder(null); setPage(1); }}
              className={cn(
                "w-full flex items-center gap-2.5 px-3 py-2 rounded-lg text-sm transition-colors text-left",
                selectedFolder === null
                  ? "bg-sf-iceBlue text-sf-deepNavy font-medium"
                  : "text-slate-600 hover:bg-slate-50"
              )}
            >
              <Folder className={cn("h-4 w-4", selectedFolder === null ? "text-sf-deepNavy" : "text-slate-400")} />
              <span className="flex-1 truncate">All Habits</span>
            </button>

            {foldersLoading ? (
              Array.from({ length: 3 }).map((_, i) => (
                <div key={i} className="px-3 py-2">
                  <div className="skeleton h-4 w-full rounded" />
                </div>
              ))
            ) : (
              folders.map((folder: any) => (
                <button
                  key={folder.id}
                  onClick={() => { setSelectedFolder(folder.id); setPage(1); }}
                  className={cn(
                    "w-full flex items-center gap-2.5 px-3 py-2 rounded-lg text-sm transition-colors text-left",
                    selectedFolder === folder.id
                      ? "bg-sf-iceBlue text-sf-deepNavy font-medium"
                      : "text-slate-600 hover:bg-slate-50"
                  )}
                >
                  <Folder className={cn("h-4 w-4", selectedFolder === folder.id ? "text-sf-deepNavy" : "text-slate-400")} />
                  <span className="flex-1 truncate">{folder.name}</span>
                  {folder.habit_count != null && (
                    <span className={cn("text-xs", selectedFolder === folder.id ? "text-sf-deepNavy" : "text-slate-400")}>
                      {folder.habit_count}
                    </span>
                  )}
                </button>
              ))
            )}
          </div>

          <button
            onClick={() => setCreateFolderOpen(true)}
            className="mt-3 flex items-center gap-2 text-sm text-slate-500 hover:text-sf-deepNavy px-3 py-1.5 transition-colors"
          >
            <Plus className="h-3.5 w-3.5" /> Add Folder
          </button>
        </div>

        {/* Habit List */}
        <div className="flex-1 space-y-3">
          <SearchInput
            value={search}
            onChange={(v) => { setSearch(v); setPage(1); }}
            placeholder="Search habits..."
          />

          {isLoading ? (
            <div className="card divide-y divide-slate-50 overflow-hidden">
              {Array.from({ length: 6 }).map((_, i) => (
                <div key={i} className="px-4 py-3 flex items-center gap-3">
                  <div className="skeleton h-8 w-8 rounded-lg" />
                  <div className="flex-1">
                    <div className="skeleton h-4 w-2/3 mb-1" />
                    <div className="skeleton h-3 w-1/3" />
                  </div>
                </div>
              ))}
            </div>
          ) : habits.length === 0 ? (
            <EmptyState
              icon={Target}
              title={search ? "No habits match" : "No habits yet"}
              description={search ? "Try a different search term" : "Create habits to track your clients' daily routines and goals."}
              action={!search ? <button onClick={() => setCreateHabitOpen(true)} className="btn-primary"><Plus className="h-4 w-4" /> Add Habit</button> : undefined}
            />
          ) : (
            <div className="card divide-y divide-slate-50 overflow-hidden">
              {habits.map((habit: any) => (
                <div
                  key={habit.id}
                  className="px-4 py-3 flex items-center gap-3 hover:bg-slate-50/60 cursor-pointer transition-colors"
                >
                  {/* Icon: image or emoji/text fallback */}
                  <div className="h-8 w-8 rounded-lg bg-slate-50 flex items-center justify-center overflow-hidden shrink-0">
                    {habit.icon_image_url ? (
                      <img src={habit.icon_image_url} alt={habit.name} className="w-full h-full object-cover" />
                    ) : habit.icon ? (
                      <span className="text-lg">{habit.icon}</span>
                    ) : (
                      <Target className="h-4 w-4 text-slate-300" />
                    )}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="font-medium text-slate-900 text-sm">{habit.name}</p>
                    {habit.description && (
                      <p className="text-xs text-slate-400 line-clamp-1">{habit.description}</p>
                    )}
                  </div>
                </div>
              ))}
            </div>
          )}

          {(meta?.total_pages ?? 1) > 1 && (
            <div className="flex justify-center gap-1">
              {Array.from({ length: meta!.total_pages }, (_, i) => i + 1)
                .slice(Math.max(0, page - 3), page + 2)
                .map((p) => (
                  <button key={p} onClick={() => setPage(p)}
                    className={cn("w-8 h-8 rounded-lg text-sm font-medium transition-colors",
                      p === page ? "bg-sf-deepNavy text-white" : "text-slate-500 hover:bg-slate-100"
                    )}>{p}</button>
                ))}
            </div>
          )}
        </div>
      </div>

      {createHabitOpen && (
        <CreateHabitModal
          folders={folders}
          onClose={() => setCreateHabitOpen(false)}
        />
      )}
      {createFolderOpen && <CreateFolderModal onClose={() => setCreateFolderOpen(false)} />}
    </div>
  );
}

function CreateHabitModal({ folders, onClose }: { folders: any[]; onClose: () => void }) {
  const createHabit = useCreateHabit();
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [folderId, setFolderId] = useState("");
  const [iconText, setIconText] = useState("");
  const [imageUrl, setImageUrl] = useState<string | null>(null);
  const [imageId, setImageId] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim()) return;

    await createHabit.mutateAsync({
      name: name.trim(),
      description: description || undefined,
      folder_id: folderId || undefined,
      icon_image_id: imageId || undefined,
      icon: !imageId ? (iconText || undefined) : undefined,
    });
    onClose();
  }

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center pt-[5vh] overflow-y-auto" onClick={onClose}>
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" />
      <div className="relative bg-white rounded-2xl shadow-xl max-w-lg w-full mx-4 mb-12 animate-slide-in" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
          <h2 className="text-lg font-semibold text-slate-900">Add Habit</h2>
          <button onClick={onClose} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400"><X className="h-5 w-5" /></button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-5 max-h-[75vh] overflow-y-auto">
          {/* Icon Image Upload */}
          <div>
            <label className="label">Habit Icon</label>
            <ImageUpload
              value={imageUrl}
              onChange={(url, id) => { setImageUrl(url); setImageId(id); }}
              entityType="habit"
              aspectRatio="square"
              placeholder="Upload icon"
            />
          </div>

          {!imageId && (
            <div>
              <label className="label">Icon (emoji / text fallback)</label>
              <input value={iconText} onChange={(e) => setIconText(e.target.value)} className="input" placeholder="e.g. 💧 or 🏃" />
            </div>
          )}

          <div>
            <label className="label">Name *</label>
            <input value={name} onChange={(e) => setName(e.target.value)} required className="input" placeholder="e.g. Drink 8 glasses of water" autoFocus />
          </div>

          <div>
            <label className="label">Description</label>
            <textarea value={description} onChange={(e) => setDescription(e.target.value)} className="input" rows={3} placeholder="Describe the habit..." />
          </div>

          <div>
            <label className="label">Folder</label>
            <SearchableSelect
              options={[{ value: "", label: "No folder" }, ...folders.map((f: any) => ({ value: f.id, label: f.name }))]}
              value={folderId}
              onChange={setFolderId}
              placeholder="Select folder..."
              searchPlaceholder="Search folders..."
            />
          </div>

          <div className="flex justify-end gap-3 pt-2">
            <button type="button" onClick={onClose} className="btn-secondary">Cancel</button>
            <button type="submit" disabled={createHabit.isPending || !name.trim()} className="btn-primary">
              {createHabit.isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Plus className="h-4 w-4" />}
              {createHabit.isPending ? "Creating..." : "Add Habit"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

function CreateFolderModal({ onClose }: { onClose: () => void }) {
  const createFolder = useCreateHabitFolder();
  const [name, setName] = useState("");

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim()) return;

    await createFolder.mutateAsync({ name: name.trim() });
    onClose();
  }

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center pt-[5vh] overflow-y-auto" onClick={onClose}>
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" />
      <div className="relative bg-white rounded-2xl shadow-xl max-w-sm w-full mx-4 mb-12 animate-slide-in" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
          <h2 className="text-lg font-semibold text-slate-900">New Folder</h2>
          <button onClick={onClose} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400"><X className="h-5 w-5" /></button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-5">
          <div>
            <label className="label">Folder Name *</label>
            <input value={name} onChange={(e) => setName(e.target.value)} required className="input" placeholder="e.g. Morning Routine" autoFocus />
          </div>

          <div className="flex justify-end gap-3 pt-2">
            <button type="button" onClick={onClose} className="btn-secondary">Cancel</button>
            <button type="submit" disabled={createFolder.isPending || !name.trim()} className="btn-primary">
              {createFolder.isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Plus className="h-4 w-4" />}
              {createFolder.isPending ? "Creating..." : "Create Folder"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
