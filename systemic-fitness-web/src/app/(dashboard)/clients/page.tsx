"use client";

import { useState, useMemo } from "react";
import Link from "next/link";
import { useQuery } from "@tanstack/react-query";
import { useClients } from "@/hooks/useNewFeatures";
import { useAuth } from "@/hooks/useAuth";
import { apiGet } from "@/lib/api";
import { EmptyState } from "@/components/shared/EmptyState";
import { SearchInput } from "@/components/shared/SearchInput";
import {
  UserCheck, Mail, Phone, ChevronRight, ClipboardCheck,
  Crown, Star, Zap, Clock, UserPlus, Pencil,
} from "lucide-react";
import { cn, getInitials, formatDate } from "@/lib/utils";
import { ClientFormModal } from "@/components/shared/ClientFormModal";

const statusStyles: Record<string, string> = {
  active: "bg-emerald-50 text-emerald-700",
  inactive: "bg-slate-100 text-slate-500",
  pending: "bg-amber-50 text-amber-700",
  suspended: "bg-rose-50 text-rose-700",
};

const tierConfig: Record<string, { icon: typeof Star; color: string; bg: string }> = {
  basic: { icon: Zap, color: "text-slate-600", bg: "bg-slate-100" },
  pro: { icon: Star, color: "text-sf-deepNavy", bg: "bg-sf-iceBlue" },
  elite: { icon: Crown, color: "text-amber-700", bg: "bg-amber-50" },
};

export default function ClientsPage() {
  const { isTrainer } = useAuth();
  const canEdit = !isTrainer; // trainers get a read-only client list
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [modalOpen, setModalOpen] = useState(false);
  const [editClient, setEditClient] = useState<any | null>(null);

  const params: Record<string, unknown> = { page, limit: 20, search };
  const { data, isLoading } = useClients(params);
  const clients = (data?.data ?? []) as any[];
  const meta = data?.meta;

  // Fetch all active subscriptions to map to clients
  const { data: subsData } = useQuery({
    queryKey: ["admin-subscriptions-all", { status: "active", limit: 500 }],
    queryFn: () => apiGet("/api/payments/subscriptions", { status: "active", limit: 500 }),
  });

  // Build a map: user_id → subscription info
  const subMap = useMemo(() => {
    const subs = (subsData?.data ?? []) as any[];
    const map: Record<string, any> = {};
    for (const sub of subs) {
      map[sub.user_id] = sub;
    }
    return map;
  }, [subsData]);

  // Quick stats
  const totalClients = meta?.total ?? clients.length;
  const subscribedCount = clients.filter((c: any) => subMap[c.id]).length;

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Clients</h1>
          <p className="text-sm text-slate-500 mt-1">
            {meta?.total != null ? `${meta.total} total clients` : "Kelola klien Anda"}
          </p>
        </div>
        {canEdit && (
          <button
            onClick={() => { setEditClient(null); setModalOpen(true); }}
            className="btn-primary"
          >
            <UserPlus className="h-4 w-4" /> Tambah Client
          </button>
        )}
      </div>

      {/* Quick Stats */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <div className="card px-4 py-3">
          <p className="text-xs text-slate-500">Total Clients</p>
          <p className="text-xl font-bold text-slate-900">{totalClients}</p>
        </div>
        <div className="card px-4 py-3">
          <p className="text-xs text-slate-500">Berlangganan</p>
          <p className="text-xl font-bold text-emerald-600">{subscribedCount}</p>
        </div>
        <div className="card px-4 py-3">
          <p className="text-xs text-slate-500">Tanpa Plan</p>
          <p className="text-xl font-bold text-slate-400">{clients.length - subscribedCount}</p>
        </div>
        <div className="card px-4 py-3">
          <p className="text-xs text-slate-500">Conversion</p>
          <p className="text-xl font-bold text-sf-deepNavy">
            {clients.length > 0 ? Math.round((subscribedCount / clients.length) * 100) : 0}%
          </p>
        </div>
      </div>

      {/* Search */}
      <div className="flex items-center gap-3">
        <div className="flex-1 max-w-md">
          <SearchInput
            value={search}
            onChange={(v) => { setSearch(v); setPage(1); }}
            placeholder="Cari nama atau email client..."
          />
        </div>
      </div>

      {/* List */}
      {isLoading ? (
        <div className="card divide-y divide-slate-50 overflow-hidden">
          {Array.from({ length: 8 }).map((_, i) => (
            <div key={i} className="px-5 py-3.5 flex items-center gap-4">
              <div className="skeleton h-10 w-10 rounded-full" />
              <div className="flex-1 space-y-1.5">
                <div className="skeleton h-4 w-40" />
                <div className="skeleton h-3 w-56" />
              </div>
              <div className="skeleton h-5 w-16 rounded-full" />
            </div>
          ))}
        </div>
      ) : clients.length === 0 ? (
        <EmptyState
          icon={UserCheck}
          title={search ? "Tidak ditemukan" : "Belum ada client"}
          description={search ? "Coba kata kunci lain" : "Client akan muncul setelah di-assign oleh admin."}
        />
      ) : (
        <div className="card divide-y divide-slate-50 overflow-hidden">
          {clients.map((client: any) => {
            const sub = subMap[client.id];
            const tier = sub?.plan_name?.toLowerCase()?.includes("elite") ? "elite"
              : sub?.plan_name?.toLowerCase()?.includes("pro") ? "pro"
              : sub ? "basic" : null;
            const tc = tier ? tierConfig[tier] : null;
            const TierIcon = tc?.icon;

            // Calculate days remaining
            let daysLeft: number | null = null;
            if (sub?.expires_at) {
              daysLeft = Math.ceil((new Date(sub.expires_at).getTime() - Date.now()) / (1000 * 60 * 60 * 24));
            }

            return (
              <div
                key={client.id}
                className="px-5 py-3.5 flex items-center gap-4 hover:bg-slate-50/60 transition-colors"
              >
                {/* Avatar */}
                <Link href={`/clients/${client.id}`} className="h-10 w-10 rounded-full bg-sf-iceBlue flex items-center justify-center shrink-0">
                  <span className="text-sm font-semibold text-sf-deepNavy">
                    {getInitials(client.full_name || client.email)}
                  </span>
                </Link>

                {/* Info */}
                <Link href={`/clients/${client.id}`} className="flex-1 min-w-0">
                  <p className="font-medium text-slate-900 text-sm">{client.full_name || client.email}</p>
                  <div className="flex items-center gap-3 text-xs text-slate-400 mt-0.5">
                    <span className="flex items-center gap-1">
                      <Mail className="h-3 w-3" /> {client.email}
                    </span>
                    {client.phone && (
                      <span className="hidden sm:flex items-center gap-1">
                        <Phone className="h-3 w-3" /> {client.phone}
                      </span>
                    )}
                  </div>
                </Link>

                {/* Subscription Badge */}
                {sub ? (
                  <div className={cn("hidden lg:flex items-center gap-2 px-3 py-1.5 rounded-lg shrink-0", tc?.bg)}>
                    {TierIcon && <TierIcon className={cn("h-3.5 w-3.5", tc?.color)} />}
                    <div className="text-right">
                      <p className={cn("text-xs font-semibold", tc?.color)}>{sub.plan_name}</p>
                      <p className="text-[10px] text-slate-400 flex items-center gap-0.5">
                        <Clock className="h-2.5 w-2.5" />
                        {daysLeft != null && daysLeft > 0
                          ? `${daysLeft} hari lagi`
                          : "Expired"}
                      </p>
                    </div>
                  </div>
                ) : (
                  <span className="hidden lg:block text-xs text-slate-300 italic shrink-0">
                    No plan
                  </span>
                )}

                {/* Training Card Button */}
                <Link
                  href={`/clients/${client.id}/training-card`}
                  className="hidden sm:flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium bg-slate-800 text-white hover:bg-slate-700 transition-colors shrink-0"
                >
                  <ClipboardCheck className="h-3.5 w-3.5" />
                  Training Card
                </Link>

                {/* Status Badge */}
                <div className="flex flex-col gap-1 items-end shrink-0">
                  <span className={cn("px-2 py-0.5 rounded-full text-xs font-medium capitalize", statusStyles[client.status] || "bg-slate-100 text-slate-500")}>
                    {client.status}
                  </span>
                  {client.needs_reassessment && (
                    <span className="px-2 py-0.5 rounded-full text-[10px] font-medium bg-red-100 text-red-600 border border-red-200">
                      Re-assessment Due
                    </span>
                  )}
                </div>

                {canEdit && (
                  <button
                    onClick={() => { setEditClient(client); setModalOpen(true); }}
                    className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400 hover:text-slate-600 shrink-0"
                    title="Edit client"
                  >
                    <Pencil className="h-4 w-4" />
                  </button>
                )}

                <Link href={`/clients/${client.id}`}>
                  <ChevronRight className="h-4 w-4 text-slate-300" />
                </Link>
              </div>
            );
          })}
        </div>
      )}

      {/* Pagination */}
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
            {Array.from({ length: meta!.total_pages }, (_, i) => i + 1)
              .slice(Math.max(0, page - 3), page + 2)
              .map((p) => (
                <button key={p} onClick={() => setPage(p)}
                  className={cn("w-8 h-8 rounded-lg text-sm font-medium transition-colors",
                    p === page ? "bg-sf-deepNavy text-white" : "text-slate-500 hover:bg-slate-100"
                  )}>{p}</button>
              ))}
            <button
              onClick={() => setPage((p) => Math.min(meta!.total_pages, p + 1))}
              disabled={page >= meta!.total_pages}
              className="px-3 py-1.5 rounded-lg text-sm font-medium text-slate-600 hover:bg-slate-100 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
            >
              Selanjutnya
            </button>
          </div>
        </div>
      )}

      <ClientFormModal open={modalOpen} onClose={() => setModalOpen(false)} client={editClient} />
    </div>
  );
}
