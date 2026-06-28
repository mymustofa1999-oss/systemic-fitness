"use client";

import { useState } from "react";
import { useChallenges, useCreateChallenge } from "@/hooks/useNewFeatures";
import { ImageUpload } from "@/components/shared/ImageUpload";
import { EmptyState } from "@/components/shared/EmptyState";
import { SearchInput } from "@/components/shared/SearchInput";
import {
  Trophy, Plus, Calendar, Users, X, Loader2,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { SearchableSelect } from "@/components/shared/SearchableSelect";

const STATUS_TABS = ["all", "draft", "active", "completed"] as const;

const statusBadge: Record<string, string> = {
  draft: "bg-slate-100 text-slate-600",
  active: "bg-emerald-50 text-emerald-700",
  completed: "bg-blue-50 text-blue-700",
  cancelled: "bg-rose-50 text-rose-700",
};

export default function ChallengesPage() {
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [statusFilter, setStatusFilter] = useState<string>("all");
  const [createOpen, setCreateOpen] = useState(false);

  const { data, isLoading } = useChallenges({
    page,
    limit: 20,
    search,
    status: statusFilter !== "all" ? statusFilter : undefined,
  });
  const challenges = (data?.data ?? []) as any[];
  const meta = data?.meta;

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Challenges</h1>
          <p className="text-sm text-slate-500 mt-1">
            {meta?.total != null ? `${meta.total} challenges` : "Motivate clients with time-bound fitness challenges"}
          </p>
        </div>
        <button onClick={() => setCreateOpen(true)} className="btn-primary">
          <Plus className="h-4 w-4" /> Create Challenge
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
        placeholder="Search challenges..."
      />

      {isLoading ? (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {Array.from({ length: 4 }).map((_, i) => (
            <div key={i} className="card p-5">
              <div className="skeleton h-40 w-full rounded-lg mb-3" />
              <div className="skeleton h-4 w-3/4 mb-2" />
              <div className="skeleton h-3 w-1/2" />
            </div>
          ))}
        </div>
      ) : challenges.length === 0 ? (
        <EmptyState
          icon={Trophy}
          title={search ? "No challenges match" : "No challenges yet"}
          description={search ? "Try a different search term" : "Create your first challenge to engage and motivate your clients."}
          action={!search ? <button onClick={() => setCreateOpen(true)} className="btn-primary"><Plus className="h-4 w-4" /> Create Challenge</button> : undefined}
        />
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {challenges.map((challenge: any) => {
            const badge = statusBadge[challenge.status] ?? "bg-slate-100 text-slate-600";
            return (
              <div key={challenge.id} className="card overflow-hidden cursor-pointer group">
                {/* Image */}
                <div className="h-40 bg-slate-50 flex items-center justify-center overflow-hidden">
                  {challenge.image_url ? (
                    <img src={challenge.image_url} alt={challenge.name} className="w-full h-full object-cover" />
                  ) : (
                    <Trophy className="h-10 w-10 text-slate-200" />
                  )}
                </div>

                <div className="p-5">
                  <div className="flex items-start justify-between mb-1">
                    <h3 className="font-medium text-slate-900 text-sm">{challenge.name}</h3>
                    <span className={cn("shrink-0 ml-2 px-2 py-0.5 rounded-full text-[10px] font-medium capitalize", badge)}>
                      {challenge.status}
                    </span>
                  </div>

                  {challenge.description && (
                    <p className="text-xs text-slate-500 line-clamp-2 mb-3">{challenge.description}</p>
                  )}

                  <div className="flex items-center gap-4 text-xs text-slate-400">
                    {(challenge.start_date || challenge.end_date) && (
                      <span className="flex items-center gap-1">
                        <Calendar className="h-3.5 w-3.5" />
                        {challenge.start_date
                          ? new Date(challenge.start_date).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" })
                          : "TBD"}
                        {" - "}
                        {challenge.end_date
                          ? new Date(challenge.end_date).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" })
                          : "TBD"}
                      </span>
                    )}
                    <span className="flex items-center gap-1">
                      <Users className="h-3.5 w-3.5" />
                      {challenge.participant_count ?? 0} participants
                    </span>
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

      {createOpen && <CreateChallengeModal onClose={() => setCreateOpen(false)} />}
    </div>
  );
}

function CreateChallengeModal({ onClose }: { onClose: () => void }) {
  const createChallenge = useCreateChallenge();
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [status, setStatus] = useState("draft");
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");
  const [goalType, setGoalType] = useState("");
  const [goalValue, setGoalValue] = useState("");
  const [maxParticipants, setMaxParticipants] = useState("");
  const [imageUrl, setImageUrl] = useState<string | null>(null);
  const [imageId, setImageId] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim()) return;

    await createChallenge.mutateAsync({
      name: name.trim(),
      description: description || undefined,
      status,
      start_date: startDate || undefined,
      end_date: endDate || undefined,
      goal_type: goalType || undefined,
      goal_value: goalValue ? Number(goalValue) : undefined,
      max_participants: maxParticipants ? Number(maxParticipants) : undefined,
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
          <h2 className="text-lg font-semibold text-slate-900">Create Challenge</h2>
          <button onClick={onClose} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400"><X className="h-5 w-5" /></button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-5 max-h-[75vh] overflow-y-auto">
          {/* Image Upload */}
          <div>
            <label className="label">Challenge Banner</label>
            <ImageUpload
              value={imageUrl}
              onChange={(url, id) => { setImageUrl(url); setImageId(id); }}
              entityType="challenge"
              aspectRatio="banner"
              placeholder="Upload challenge banner"
            />
          </div>

          <div>
            <label className="label">Name *</label>
            <input value={name} onChange={(e) => setName(e.target.value)} required className="input" placeholder="e.g. 30-Day Consistency Challenge" autoFocus />
          </div>

          <div>
            <label className="label">Description</label>
            <textarea value={description} onChange={(e) => setDescription(e.target.value)} className="input" rows={3} placeholder="Describe the challenge goals and rules..." />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Status</label>
              <SearchableSelect
                options={[{ value: "draft", label: "Draft" }, { value: "active", label: "Active" }]}
                value={status}
                onChange={setStatus}
                placeholder="Pilih status..."
              />
            </div>
            <div>
              <label className="label">Max Participants</label>
              <input type="number" min="1" value={maxParticipants} onChange={(e) => setMaxParticipants(e.target.value)} className="input" placeholder="Unlimited" />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Start Date</label>
              <input type="date" value={startDate} onChange={(e) => setStartDate(e.target.value)} className="input" />
            </div>
            <div>
              <label className="label">End Date</label>
              <input type="date" value={endDate} onChange={(e) => setEndDate(e.target.value)} className="input" />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Goal Type</label>
              <input value={goalType} onChange={(e) => setGoalType(e.target.value)} className="input" placeholder="mis. sesi, langkah, kalori" />
            </div>
            <div>
              <label className="label">Goal Value</label>
              <input type="number" min="1" value={goalValue} onChange={(e) => setGoalValue(e.target.value)} className="input" placeholder="e.g. 20" />
            </div>
          </div>

          <div className="flex justify-end gap-3 pt-2">
            <button type="button" onClick={onClose} className="btn-secondary">Cancel</button>
            <button type="submit" disabled={createChallenge.isPending || !name.trim()} className="btn-primary">
              {createChallenge.isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Plus className="h-4 w-4" />}
              {createChallenge.isPending ? "Creating..." : "Create Challenge"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
