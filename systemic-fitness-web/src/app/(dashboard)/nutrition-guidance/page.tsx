"use client";

import { useState } from "react";
import Link from "next/link";
import { Apple, ChevronRight, Mail, Search } from "lucide-react";

import { useClients } from "@/hooks/useNewFeatures";
import { EmptyState } from "@/components/shared/EmptyState";
import { SearchInput } from "@/components/shared/SearchInput";
import { getInitials } from "@/lib/utils";

/**
 * Admin/trainer entry point for the Nutrition Guidance & Monitoring Engine.
 * Shows the list of customers; clicking a row navigates to the per-customer
 * detail page where the health profile can be viewed/edited.
 */
export default function NutritionGuidanceListPage() {
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);

  const { data, isLoading } = useClients({ page, limit: 20, search });
  const clients = (data?.data ?? []) as any[];
  const meta = data?.meta;

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 flex items-center gap-2">
            <Apple className="h-6 w-6 text-emerald-600" />
            Nutrition Guidance
          </h1>
          <p className="text-sm text-slate-500 mt-1">
            Kelola profil kesehatan, rencana nutrisi, dan log harian customer.
          </p>
        </div>
      </div>

      <div className="flex items-center gap-3">
        <div className="flex-1 max-w-md">
          <SearchInput
            value={search}
            onChange={(v) => {
              setSearch(v);
              setPage(1);
            }}
            placeholder="Cari nama atau email customer..."
          />
        </div>
      </div>

      {isLoading ? (
        <div className="card divide-y divide-slate-50 overflow-hidden">
          {Array.from({ length: 8 }).map((_, i) => (
            <div key={i} className="px-5 py-3.5 flex items-center gap-4">
              <div className="skeleton h-10 w-10 rounded-full" />
              <div className="flex-1 space-y-1.5">
                <div className="skeleton h-4 w-40" />
                <div className="skeleton h-3 w-56" />
              </div>
            </div>
          ))}
        </div>
      ) : clients.length === 0 ? (
        <EmptyState
          icon={Search}
          title={search ? "Tidak ditemukan" : "Belum ada customer"}
          description={
            search
              ? "Coba kata kunci lain"
              : "Customer akan muncul di sini setelah terdaftar."
          }
        />
      ) : (
        <div className="card divide-y divide-slate-50 overflow-hidden">
          {clients.map((c: any) => (
            <Link
              key={c.id}
              href={`/nutrition-guidance/${c.id}`}
              className="px-5 py-3.5 flex items-center gap-4 hover:bg-slate-50/60 transition-colors"
            >
              <div className="h-10 w-10 rounded-full bg-emerald-100 flex items-center justify-center shrink-0">
                <span className="text-sm font-semibold text-emerald-700">
                  {getInitials(c.full_name || c.email)}
                </span>
              </div>
              <div className="flex-1 min-w-0">
                <p className="font-medium text-slate-900 text-sm">
                  {c.full_name || c.email}
                </p>
                <p className="flex items-center gap-1 text-xs text-slate-400 mt-0.5">
                  <Mail className="h-3 w-3" /> {c.email}
                </p>
              </div>
              <ChevronRight className="h-4 w-4 text-slate-300" />
            </Link>
          ))}
        </div>
      )}

      {(meta?.total_pages ?? 1) > 1 && (
        <div className="flex items-center justify-between">
          <p className="text-sm text-slate-500">
            Halaman {meta!.page} dari {meta!.total_pages} ({meta!.total} data)
          </p>
          <div className="flex gap-1">
            <button
              onClick={() => setPage((p) => Math.max(1, p - 1))}
              disabled={page <= 1}
              className="px-3 py-1.5 rounded-lg text-sm font-medium text-slate-600 hover:bg-slate-100 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
            >
              Sebelumnya
            </button>
            <button
              onClick={() => setPage((p) => p + 1)}
              disabled={page >= (meta?.total_pages ?? 1)}
              className="px-3 py-1.5 rounded-lg text-sm font-medium text-slate-600 hover:bg-slate-100 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
            >
              Berikutnya
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
