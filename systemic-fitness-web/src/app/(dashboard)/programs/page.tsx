"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import { apiGet } from "@/lib/api";
import { DataTable, type Column } from "@/components/shared/DataTable";
import { SearchInput } from "@/components/shared/SearchInput";
import { EmptyState } from "@/components/shared/EmptyState";
import { CalendarDays, Plus, Users } from "lucide-react";
import { cn, formatDate } from "@/lib/utils";

export default function ProgramsPage() {
  const router = useRouter();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState("");

  const { data, isLoading } = useQuery({
    queryKey: ["programs", { page, search }],
    queryFn: () => apiGet("/api/programs", { page, limit: 20, search }),
  });
  const programs = (data?.data ?? []) as any[];
  const meta = data?.meta;

  const columns: Column<any>[] = [
    {
      key: "name", label: "Program", sortable: true,
      render: (r) => (
        <div>
          <p className="font-medium text-slate-900">{r.name}</p>
          <p className="text-xs text-slate-400">{r.duration_weeks} weeks · {r.difficulty}</p>
        </div>
      ),
    },
    { key: "goal", label: "Goal", render: (r) => <span className="capitalize text-sm">{r.goal?.replace(/_/g, " ")}</span> },
    {
      key: "is_template", label: "Type",
      render: (r) => r.is_template ? <span className="text-xs text-sf-deepNavy font-medium">Template</span> : <span className="text-xs text-slate-400">Custom</span>,
    },
    { key: "created_at", label: "Created", sortable: true, render: (r) => formatDate(r.created_at) },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Programs</h1>
          <p className="text-sm text-slate-500 mt-1">Multi-week training programs</p>
        </div>
        <button onClick={() => router.push("/programs/create")} className="btn-primary">
          <Plus className="h-4 w-4" /> Create Program
        </button>
      </div>

      <SearchInput value={search} onChange={setSearch} placeholder="Search programs..." />

      {!isLoading && programs.length === 0 && !search ? (
        <EmptyState icon={CalendarDays} title="No programs" description="Create your first training program." action={<button onClick={() => router.push("/programs/create")} className="btn-primary"><Plus className="h-4 w-4" /> Create Program</button>} />
      ) : (
        <DataTable columns={columns} data={programs} loading={isLoading} page={page} totalPages={meta?.total_pages} total={meta?.total} onPageChange={setPage} onRowClick={(r) => router.push(`/programs/${r.id}`)} />
      )}
    </div>
  );
}
