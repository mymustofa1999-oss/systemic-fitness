"use client";

import { useState } from "react";
import { useAnnouncements, useCreateAnnouncement } from "@/hooks/useNewFeatures";
import { ImageUpload } from "@/components/shared/ImageUpload";
import { EmptyState } from "@/components/shared/EmptyState";
import { SearchInput } from "@/components/shared/SearchInput";
import {
  Megaphone, Plus, Clock, Users, X, Loader2,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { SearchableSelect } from "@/components/shared/SearchableSelect";

const STATUS_TABS = ["all", "draft", "published", "archived"] as const;

const statusBadge: Record<string, string> = {
  draft: "bg-slate-100 text-slate-600",
  published: "bg-emerald-50 text-emerald-700",
  archived: "bg-blue-50 text-blue-700",
};

const TARGET_ROLES = ["client", "trainer", "admin", "finance"] as const;

export default function AnnouncementsPage() {
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [statusFilter, setStatusFilter] = useState<string>("all");
  const [createOpen, setCreateOpen] = useState(false);

  const { data, isLoading } = useAnnouncements({
    page,
    limit: 20,
    search,
    status: statusFilter !== "all" ? statusFilter : undefined,
  });
  const announcements = (data?.data ?? []) as any[];
  const meta = data?.meta;

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Announcements</h1>
          <p className="text-sm text-slate-500 mt-1">
            {meta?.total != null ? `${meta.total} announcements` : "Send updates and notifications to your clients"}
          </p>
        </div>
        <button onClick={() => setCreateOpen(true)} className="btn-primary">
          <Plus className="h-4 w-4" /> New Announcement
        </button>
      </div>

      {/* Status Tabs */}
      <div className="flex items-center gap-1 border-b border-slate-100 pb-px">
        {STATUS_TABS.map((t) => (
          <button
            key={t}
            onClick={() => { setStatusFilter(t); setPage(1); }}
            className={cn(
              "px-3 py-2 text-sm font-medium rounded-t-lg transition-colors capitalize",
              statusFilter === t
                ? "text-sf-deepNavy border-b-2 border-sf-deepNavy"
                : "text-slate-500 hover:text-slate-700"
            )}
          >
            {t}
          </button>
        ))}
      </div>

      <SearchInput
        value={search}
        onChange={(v) => { setSearch(v); setPage(1); }}
        placeholder="Search announcements..."
      />

      {isLoading ? (
        <div className="space-y-3">
          {Array.from({ length: 4 }).map((_, i) => (
            <div key={i} className="card p-5">
              <div className="skeleton h-4 w-2/3 mb-2" />
              <div className="skeleton h-3 w-full mb-2" />
              <div className="skeleton h-3 w-1/3" />
            </div>
          ))}
        </div>
      ) : announcements.length === 0 ? (
        <EmptyState
          icon={Megaphone}
          title={search ? "No announcements match" : "No announcements yet"}
          description={search ? "Try a different search term" : "Create your first announcement to keep clients informed about updates and events."}
          action={!search ? <button onClick={() => setCreateOpen(true)} className="btn-primary"><Plus className="h-4 w-4" /> New Announcement</button> : undefined}
        />
      ) : (
        <div className="space-y-3">
          {announcements.map((announcement: any) => {
            const badge = statusBadge[announcement.status] ?? "bg-slate-100 text-slate-600";
            const roles = announcement.target_roles as string[] | undefined;
            return (
              <div key={announcement.id} className="card overflow-hidden cursor-pointer hover:shadow-md transition-shadow">
                {/* Image at top if exists */}
                {announcement.image_url && (
                  <div className="h-40 bg-slate-50 overflow-hidden">
                    <img src={announcement.image_url} alt={announcement.title} className="w-full h-full object-cover" />
                  </div>
                )}

                <div className="p-5">
                  <div className="flex items-start gap-4">
                    {!announcement.image_url && (
                      <div className="h-10 w-10 rounded-xl bg-violet-50 flex items-center justify-center shrink-0 mt-0.5">
                        <Megaphone className="h-5 w-5 text-violet-500" />
                      </div>
                    )}

                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <h3 className="font-medium text-slate-900 text-sm">{announcement.title}</h3>
                        <span className={cn("shrink-0 px-2 py-0.5 rounded-full text-[10px] font-medium capitalize", badge)}>
                          {announcement.status}
                        </span>
                      </div>

                      {announcement.body && (
                        <p className="text-xs text-slate-500 line-clamp-2 mb-3">{announcement.body}</p>
                      )}

                      <div className="flex items-center gap-4 text-xs text-slate-400">
                        {roles && roles.length > 0 && (
                          <span className="flex items-center gap-1">
                            <Users className="h-3.5 w-3.5" />
                            {roles.map((r) => r.charAt(0).toUpperCase() + r.slice(1)).join(", ")}
                          </span>
                        )}
                        {announcement.published_at && (
                          <span className="flex items-center gap-1">
                            <Clock className="h-3.5 w-3.5" />
                            {new Date(announcement.published_at).toLocaleDateString("en-US", {
                              month: "short", day: "numeric", year: "numeric",
                            })}
                          </span>
                        )}
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
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

      {createOpen && <CreateAnnouncementModal onClose={() => setCreateOpen(false)} />}
    </div>
  );
}

function CreateAnnouncementModal({ onClose }: { onClose: () => void }) {
  const createAnnouncement = useCreateAnnouncement();
  const [title, setTitle] = useState("");
  const [body, setBody] = useState("");
  const [status, setStatus] = useState("draft");
  const [targetRoles, setTargetRoles] = useState<string[]>([]);
  const [imageUrl, setImageUrl] = useState<string | null>(null);
  const [imageId, setImageId] = useState<string | null>(null);

  function toggleRole(role: string) {
    setTargetRoles((prev) =>
      prev.includes(role) ? prev.filter((r) => r !== role) : [...prev, role]
    );
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!title.trim()) return;

    await createAnnouncement.mutateAsync({
      title: title.trim(),
      body: body || undefined,
      status,
      target_roles: targetRoles.length > 0 ? targetRoles : undefined,
      image_id: imageId || undefined,
      image_url: !imageId && imageUrl ? imageUrl : undefined,
    });
    onClose();
  }

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center pt-[5vh] overflow-y-auto" onClick={onClose}>
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" />
      <div className="relative bg-white rounded-2xl shadow-xl max-w-2xl w-full mx-4 mb-12 animate-slide-in" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
          <h2 className="text-lg font-semibold text-slate-900">New Announcement</h2>
          <button onClick={onClose} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400"><X className="h-5 w-5" /></button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-5 max-h-[75vh] overflow-y-auto">
          {/* Image Upload */}
          <div>
            <label className="label">Banner Image</label>
            <ImageUpload
              value={imageUrl}
              onChange={(url, id) => { setImageUrl(url); setImageId(id); }}
              entityType="announcement"
              aspectRatio="banner"
              placeholder="Upload banner image"
            />
          </div>

          <div>
            <label className="label">Title *</label>
            <input value={title} onChange={(e) => setTitle(e.target.value)} required className="input" placeholder="e.g. Holiday Schedule Changes" autoFocus />
          </div>

          <div>
            <label className="label">Body</label>
            <textarea value={body} onChange={(e) => setBody(e.target.value)} className="input" rows={5} placeholder="Write your announcement content..." />
          </div>

          <div>
            <label className="label">Status</label>
            <SearchableSelect
              options={[{ value: "draft", label: "Draft" }, { value: "published", label: "Published" }]}
              value={status}
              onChange={setStatus}
              placeholder="Pilih status..."
            />
          </div>

          <div>
            <label className="label">Target Roles</label>
            <p className="text-xs text-slate-400 mb-2">Select which roles should see this announcement</p>
            <div className="flex flex-wrap gap-2">
              {TARGET_ROLES.map((role) => (
                <label
                  key={role}
                  className={cn(
                    "flex items-center gap-2 px-3 py-2 rounded-lg border cursor-pointer transition-colors text-sm",
                    targetRoles.includes(role)
                      ? "border-sf-systemBlue/40 bg-sf-iceBlue text-sf-deepNavy"
                      : "border-slate-200 bg-white text-slate-600 hover:bg-slate-50"
                  )}
                >
                  <input
                    type="checkbox"
                    checked={targetRoles.includes(role)}
                    onChange={() => toggleRole(role)}
                    className="sr-only"
                  />
                  <div className={cn(
                    "h-4 w-4 rounded border-2 flex items-center justify-center transition-colors",
                    targetRoles.includes(role)
                      ? "border-sf-deepNavy bg-sf-deepNavy"
                      : "border-slate-300"
                  )}>
                    {targetRoles.includes(role) && (
                      <svg className="h-2.5 w-2.5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={3}>
                        <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                      </svg>
                    )}
                  </div>
                  <span className="capitalize font-medium">{role}</span>
                </label>
              ))}
            </div>
          </div>

          <div className="flex justify-end gap-3 pt-2">
            <button type="button" onClick={onClose} className="btn-secondary">Cancel</button>
            <button type="submit" disabled={createAnnouncement.isPending || !title.trim()} className="btn-primary">
              {createAnnouncement.isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Plus className="h-4 w-4" />}
              {createAnnouncement.isPending ? "Creating..." : "Create Announcement"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
