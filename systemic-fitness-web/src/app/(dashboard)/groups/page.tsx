"use client";

import { useState } from "react";
import { useGroups, useCreateGroup } from "@/hooks/useNewFeatures";
import { ImageUpload } from "@/components/shared/ImageUpload";
import { EmptyState } from "@/components/shared/EmptyState";
import { SearchInput } from "@/components/shared/SearchInput";
import {
  UsersRound, Plus, X, Loader2,
} from "lucide-react";
import { cn } from "@/lib/utils";

export default function GroupsPage() {
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [createOpen, setCreateOpen] = useState(false);

  const { data, isLoading } = useGroups({ page, limit: 20, search });
  const groups = (data?.data ?? []) as any[];
  const meta = data?.meta;

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Groups</h1>
          <p className="text-sm text-slate-500 mt-1">
            {meta?.total != null ? `${meta.total} groups` : "Organize clients into groups for classes and programs"}
          </p>
        </div>
        <button onClick={() => setCreateOpen(true)} className="btn-primary">
          <Plus className="h-4 w-4" /> Create Group
        </button>
      </div>

      <SearchInput
        value={search}
        onChange={(v) => { setSearch(v); setPage(1); }}
        placeholder="Search groups..."
      />

      {isLoading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {Array.from({ length: 6 }).map((_, i) => (
            <div key={i} className="card p-5">
              <div className="skeleton h-36 w-full rounded-lg mb-3" />
              <div className="skeleton h-4 w-3/4 mb-2" />
              <div className="skeleton h-3 w-1/2" />
            </div>
          ))}
        </div>
      ) : groups.length === 0 ? (
        <EmptyState
          icon={UsersRound}
          title={search ? "No groups match" : "No groups yet"}
          description={search ? "Try a different search term" : "Create groups to manage classes, challenges, and team training."}
          action={!search ? <button onClick={() => setCreateOpen(true)} className="btn-primary"><Plus className="h-4 w-4" /> Create Group</button> : undefined}
        />
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {groups.map((group: any) => (
            <div key={group.id} className="card p-5 cursor-pointer group">
              {/* Image */}
              <div className="h-36 rounded-lg bg-slate-50 flex items-center justify-center mb-3 overflow-hidden">
                {group.image_url ? (
                  <img src={group.image_url} alt={group.name} className="w-full h-full object-cover" />
                ) : (
                  <UsersRound className="h-8 w-8 text-slate-200" />
                )}
              </div>

              <div className="flex items-start justify-between mb-1">
                <h3 className="font-medium text-slate-900 text-sm">{group.name}</h3>
                <span className="shrink-0 ml-2 px-2 py-0.5 rounded-full bg-sf-iceBlue text-sf-deepNavy text-[10px] font-medium">
                  {group.member_count ?? 0} members
                </span>
              </div>

              {group.description && (
                <p className="text-xs text-slate-500 line-clamp-2 mb-3">{group.description}</p>
              )}

              {group.max_members && (
                <div className="space-y-1.5 mt-auto pt-3 border-t border-slate-50">
                  <div className="flex items-center justify-between text-xs">
                    <span className="text-slate-400">Capacity</span>
                    <span className="font-medium text-slate-600">
                      {group.member_count ?? 0}/{group.max_members}
                    </span>
                  </div>
                  <div className="h-1.5 bg-slate-100 rounded-full overflow-hidden">
                    <div
                      className="h-full rounded-full bg-sf-deepNavy transition-all"
                      style={{ width: `${Math.min(((group.member_count ?? 0) / group.max_members) * 100, 100)}%` }}
                    />
                  </div>
                </div>
              )}
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

      {createOpen && <CreateGroupModal onClose={() => setCreateOpen(false)} />}
    </div>
  );
}

function CreateGroupModal({ onClose }: { onClose: () => void }) {
  const createGroup = useCreateGroup();
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [maxMembers, setMaxMembers] = useState("");
  const [imageUrl, setImageUrl] = useState<string | null>(null);
  const [imageId, setImageId] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim()) return;

    await createGroup.mutateAsync({
      name: name.trim(),
      description: description || undefined,
      max_members: maxMembers ? Number(maxMembers) : undefined,
      image_id: imageId || undefined,
      image_url: !imageId && imageUrl ? imageUrl : undefined,
    });
    onClose();
  }

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center pt-[5vh] overflow-y-auto" onClick={onClose}>
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" />
      <div className="relative bg-white rounded-2xl shadow-xl max-w-lg w-full mx-4 mb-12 animate-slide-in" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
          <h2 className="text-lg font-semibold text-slate-900">Create Group</h2>
          <button onClick={onClose} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400"><X className="h-5 w-5" /></button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-5 max-h-[75vh] overflow-y-auto">
          {/* Image Upload */}
          <div>
            <label className="label">Group Image</label>
            <ImageUpload
              value={imageUrl}
              onChange={(url, id) => { setImageUrl(url); setImageId(id); }}
              entityType="group"
              aspectRatio="video"
              placeholder="Upload group image"
            />
          </div>

          <div>
            <label className="label">Name *</label>
            <input value={name} onChange={(e) => setName(e.target.value)} required className="input" placeholder="e.g. Morning Bootcamp" autoFocus />
          </div>

          <div>
            <label className="label">Description</label>
            <textarea value={description} onChange={(e) => setDescription(e.target.value)} className="input" rows={3} placeholder="Describe what this group is about..." />
          </div>

          <div>
            <label className="label">Max Members</label>
            <input type="number" min="1" value={maxMembers} onChange={(e) => setMaxMembers(e.target.value)} className="input" placeholder="e.g. 30 (leave empty for unlimited)" />
          </div>

          <div className="flex justify-end gap-3 pt-2">
            <button type="button" onClick={onClose} className="btn-secondary">Cancel</button>
            <button type="submit" disabled={createGroup.isPending || !name.trim()} className="btn-primary">
              {createGroup.isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Plus className="h-4 w-4" />}
              {createGroup.isPending ? "Creating..." : "Create Group"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
