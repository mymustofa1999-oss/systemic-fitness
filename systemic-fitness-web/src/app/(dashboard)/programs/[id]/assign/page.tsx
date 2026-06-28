"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import { apiGet } from "@/lib/api";
import { useAssignProgram } from "@/hooks/useWorkouts";
import { SearchInput } from "@/components/shared/SearchInput";
import {
  ArrowLeft, Users, Check, Calendar, Loader2, CheckCircle2,
} from "lucide-react";
import Link from "next/link";
import { cn, getInitials, formatDate } from "@/lib/utils";

export default function AssignProgramPage({ params }: { params: { id: string } }) {
  const router = useRouter();
  const { mutate: assign, isPending } = useAssignProgram();

  const [search, setSearch] = useState("");
  const [selected, setSelected] = useState<Set<string>>(new Set());
  const [startDate, setStartDate] = useState(new Date().toISOString().split("T")[0]);
  const [result, setResult] = useState<{ assigned: number; failed: string[] } | null>(null);

  // Fetch program info
  const { data: programData } = useQuery({
    queryKey: ["programs", params.id],
    queryFn: () => apiGet(`/api/programs/${params.id}`),
  });
  const program = programData?.data as any;

  // Fetch clients
  const { data: userData, isLoading: loadingUsers } = useQuery({
    queryKey: ["users", { role: "client", search, limit: 50 }],
    queryFn: () => apiGet("/api/users", { role: "client", search, limit: 50 }),
  });
  const clients = (userData?.data ?? []) as any[];

  function toggleClient(id: string) {
    setSelected((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id); else next.add(id);
      return next;
    });
  }

  function toggleAll() {
    if (selected.size === clients.length) {
      setSelected(new Set());
    } else {
      setSelected(new Set(clients.map((c: any) => c.id)));
    }
  }

  function handleAssign() {
    if (selected.size === 0) return;
    assign(
      { programId: params.id, data: { client_ids: Array.from(selected), start_date: startDate } },
      { onSuccess: (res: any) => setResult(res?.data ?? { assigned: selected.size, failed: [] }) }
    );
  }

  // Success state
  if (result) {
    return (
      <div className="max-w-lg mx-auto text-center py-16 space-y-4">
        <div className="mx-auto w-16 h-16 rounded-2xl bg-emerald-100 flex items-center justify-center">
          <CheckCircle2 className="h-8 w-8 text-emerald-600" />
        </div>
        <h2 className="text-xl font-bold text-slate-900">Program Assigned!</h2>
        <p className="text-sm text-slate-500">
          Successfully assigned to {result.assigned} client{result.assigned !== 1 ? "s" : ""}.
          {result.failed?.length > 0 && ` ${result.failed.length} failed.`}
        </p>
        <div className="flex justify-center gap-3 pt-2">
          <Link href={`/programs/${params.id}`} className="btn-secondary">View Program</Link>
          <Link href="/programs" className="btn-primary">Back to Programs</Link>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-5 max-w-3xl">
      <Link href={`/programs/${params.id}`} className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-slate-700">
        <ArrowLeft className="h-4 w-4" /> Back to Program
      </Link>

      <div>
        <h1 className="text-2xl font-bold text-slate-900">Assign Program</h1>
        {program && (
          <p className="text-sm text-slate-500 mt-1">
            {program.name} · {program.duration_weeks} weeks · {program.difficulty}
          </p>
        )}
      </div>

      {/* Start Date */}
      <div className="card p-4 flex items-center gap-4">
        <Calendar className="h-5 w-5 text-slate-400" />
        <div>
          <label className="label mb-0">Start Date</label>
          <input
            type="date"
            value={startDate}
            onChange={(e) => setStartDate(e.target.value)}
            min={new Date().toISOString().split("T")[0]}
            className="input w-48 mt-1"
          />
        </div>
      </div>

      {/* Client Selection */}
      <div className="card overflow-hidden">
        <div className="px-4 py-3 border-b border-slate-100 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <SearchInput value={search} onChange={setSearch} placeholder="Search clients..." />
            <span className="text-xs text-slate-400">{selected.size} selected</span>
          </div>
          <button onClick={toggleAll} className="btn-ghost text-xs">
            {selected.size === clients.length ? "Deselect All" : "Select All"}
          </button>
        </div>

        <div className="max-h-[400px] overflow-y-auto divide-y divide-slate-50">
          {loadingUsers ? (
            <div className="p-4 space-y-3">
              {Array.from({ length: 5 }).map((_, i) => <div key={i} className="skeleton h-12 w-full" />)}
            </div>
          ) : clients.length === 0 ? (
            <div className="py-12 text-center text-sm text-slate-400">
              {search ? "No clients match your search" : "No clients found"}
            </div>
          ) : (
            clients.map((client: any) => {
              const isSelected = selected.has(client.id);
              return (
                <button
                  key={client.id}
                  onClick={() => toggleClient(client.id)}
                  className={cn(
                    "w-full flex items-center gap-3 px-4 py-3 text-left transition-colors",
                    isSelected ? "bg-sf-iceBlue" : "hover:bg-slate-50"
                  )}
                >
                  {/* Checkbox */}
                  <div className={cn(
                    "w-5 h-5 rounded-md border-2 flex items-center justify-center shrink-0 transition-colors",
                    isSelected ? "bg-sf-deepNavy border-sf-deepNavy" : "border-slate-300"
                  )}>
                    {isSelected && <Check className="h-3 w-3 text-white" />}
                  </div>

                  {/* Avatar */}
                  <div className="h-9 w-9 rounded-full bg-sf-iceBlue text-sf-deepNavy flex items-center justify-center text-xs font-bold shrink-0">
                    {getInitials(client.full_name)}
                  </div>

                  {/* Info */}
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-slate-900">{client.full_name}</p>
                    <p className="text-xs text-slate-400">{client.email}</p>
                  </div>

                  <span className="text-xs text-slate-400 hidden sm:block">
                    Joined {formatDate(client.created_at)}
                  </span>
                </button>
              );
            })
          )}
        </div>
      </div>

      {/* Assign Button */}
      <div className="flex justify-end">
        <button
          onClick={handleAssign}
          disabled={isPending || selected.size === 0}
          className="btn-primary"
        >
          {isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Users className="h-4 w-4" />}
          {isPending
            ? "Assigning..."
            : `Assign to ${selected.size} Client${selected.size !== 1 ? "s" : ""}`}
        </button>
      </div>
    </div>
  );
}
