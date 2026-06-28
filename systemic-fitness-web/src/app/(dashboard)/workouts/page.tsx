"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useWorkouts } from "@/hooks/useWorkouts";
import { DataTable, type Column } from "@/components/shared/DataTable";
import { SearchInput } from "@/components/shared/SearchInput";
import { EmptyState } from "@/components/shared/EmptyState";
import { ClipboardList, Plus, Clock, Copy } from "lucide-react";
import { cn, formatDate } from "@/lib/utils";
import { SearchableSelect } from "@/components/shared/SearchableSelect";

export default function WorkoutsPage() {
  const router = useRouter();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState("");
  const [typeFilter, setTypeFilter] = useState("");

  const { data, isLoading } = useWorkouts({ page, limit: 20, search, type: typeFilter || undefined });
  const workouts = (data?.data ?? []) as any[];
  const meta = data?.meta;

  const typeColors: Record<string, string> = {
    strength: "bg-blue-100 text-blue-700", cardio: "bg-rose-100 text-rose-700",
    hiit: "bg-amber-100 text-amber-700", flexibility: "bg-emerald-100 text-emerald-700",
    custom: "bg-slate-100 text-slate-600",
  };

  const columns: Column<any>[] = [
    {
      key: "name", label: "Sesi", sortable: true,
      render: (r) => (
        <div>
          <p className="font-medium text-slate-900">{r.name}</p>
          {r.description && <p className="text-xs text-slate-400 truncate max-w-xs">{r.description}</p>}
        </div>
      ),
    },
    {
      key: "type", label: "Type",
      render: (r) => <span className={cn("px-2 py-0.5 rounded-full text-xs font-medium capitalize", typeColors[r.type])}>{r.type}</span>,
    },
    {
      key: "estimated_duration_min", label: "Duration",
      render: (r) => r.estimated_duration_min ? (
        <span className="flex items-center gap-1 text-slate-600"><Clock className="h-3.5 w-3.5" /> {r.estimated_duration_min} min</span>
      ) : "—",
    },
    {
      key: "is_template", label: "",
      render: (r) => r.is_template ? <span className="px-2 py-0.5 rounded-full bg-sf-iceBlue text-sf-deepNavy text-xs font-medium">Template</span> : null,
    },
    { key: "created_at", label: "Created", sortable: true, render: (r) => formatDate(r.created_at) },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Sesi</h1>
          <p className="text-sm text-slate-500 mt-1">Kelola template sesi</p>
        </div>
        <button onClick={() => router.push("/workouts/create")} className="btn-primary">
          <Plus className="h-4 w-4" /> Buat Sesi
        </button>
      </div>

      <div className="flex items-center gap-3">
        <SearchInput value={search} onChange={setSearch} placeholder="Cari sesi..." />
        <SearchableSelect
          options={[{ value: "", label: "All Types" }, ...["strength","cardio","hiit","flexibility","custom"].map(t => ({ value: t, label: t.charAt(0).toUpperCase() + t.slice(1) }))]}
          value={typeFilter}
          onChange={(v) => { setTypeFilter(v); setPage(1); }}
          placeholder="All Types"
          className="w-48"
        />
      </div>

      {!isLoading && workouts.length === 0 && !search ? (
        <EmptyState icon={ClipboardList} title="Belum ada sesi" description="Buat sesi pertama untuk di-assign ke program." action={<button onClick={() => router.push("/workouts/create")} className="btn-primary"><Plus className="h-4 w-4" /> Buat Sesi</button>} />
      ) : (
        <DataTable columns={columns} data={workouts} loading={isLoading} page={page} totalPages={meta?.total_pages} total={meta?.total} onPageChange={setPage} onRowClick={(r) => router.push(`/workouts/${r.id}`)} />
      )}
    </div>
  );
}
