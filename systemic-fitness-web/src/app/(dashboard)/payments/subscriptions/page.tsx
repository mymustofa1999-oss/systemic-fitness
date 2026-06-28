"use client";

import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { ArrowLeft, Check, Crown, Star, Zap, Users, Calendar, CreditCard, Clock } from "lucide-react";
import Link from "next/link";
import { formatCurrency, formatDate } from "@/lib/utils";
import { apiGet } from "@/lib/api";
import { DataTable, Column } from "@/components/shared/DataTable";
import { SearchableSelect } from "@/components/shared/SearchableSelect";
import { useSubscriptionPlans } from "@/hooks/useSubscription";

const tierIcons: Record<string, typeof Star> = {
  basic: Zap,
  pro: Star,
  elite: Crown,
  sf_free: Zap,
  sf_tier_1: Zap,
  sf_tier_2: Star,
  sf_tier_3: Crown,
  sf_tier_4_waitlist: Crown,
};

const tierColors: Record<string, { bg: string; border: string; badge: string; icon: string }> = {
  basic: { bg: "bg-slate-50", border: "border-slate-200", badge: "bg-slate-100 text-slate-700", icon: "text-slate-500" },
  pro: { bg: "bg-sf-iceBlue", border: "border-sf-iceBlue", badge: "bg-sf-iceBlue text-sf-deepNavy", icon: "text-sf-deepNavy" },
  elite: { bg: "bg-amber-50", border: "border-amber-200", badge: "bg-amber-100 text-amber-700", icon: "text-amber-600" },
  sf_free: { bg: "bg-slate-50", border: "border-slate-200", badge: "bg-slate-100 text-slate-700", icon: "text-slate-500" },
  sf_tier_1: { bg: "bg-blue-50", border: "border-blue-200", badge: "bg-blue-100 text-blue-700", icon: "text-blue-500" },
  sf_tier_2: { bg: "bg-sf-iceBlue", border: "border-sf-iceBlue", badge: "bg-sf-iceBlue text-sf-deepNavy", icon: "text-sf-deepNavy" },
  sf_tier_3: { bg: "bg-amber-50", border: "border-amber-200", badge: "bg-amber-100 text-amber-700", icon: "text-amber-600" },
  sf_tier_4_waitlist: { bg: "bg-purple-50", border: "border-purple-200", badge: "bg-purple-100 text-purple-700", icon: "text-purple-600" },
};

// Plan features come from the API as json.RawMessage and may arrive as a real
// array, a JSON-encoded string (double-encoded), or null. Normalize to a string[]
// so rendering never crashes on a non-array value.
function toFeatureList(features: unknown): string[] {
  if (Array.isArray(features)) return features.filter((f): f is string => typeof f === "string");
  if (typeof features === "string" && features.trim()) {
    try {
      const parsed = JSON.parse(features);
      return Array.isArray(parsed) ? parsed.filter((f): f is string => typeof f === "string") : [];
    } catch {
      return [];
    }
  }
  return [];
}

const statusColors: Record<string, string> = {
  active: "bg-emerald-100 text-emerald-700",
  cancelled: "bg-rose-100 text-rose-700",
  expired: "bg-slate-100 text-slate-500",
  past_due: "bg-amber-100 text-amber-700",
  pending: "bg-blue-100 text-blue-700",
  completed: "bg-emerald-100 text-emerald-700",
  failed: "bg-rose-100 text-rose-700",
  refunded: "bg-slate-100 text-slate-500",
};

export default function SubscriptionsPage() {
  const [tab, setTab] = useState<"plans" | "history" | "payments">("plans");

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center gap-3">
        <Link href="/payments" className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400">
          <ArrowLeft className="h-4 w-4" />
        </Link>
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Client Subscriptions</h1>
          <p className="text-sm text-slate-500">Kelola paket langganan untuk client</p>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex gap-1 p-1 bg-slate-100 rounded-lg w-fit">
        {([
          { key: "plans", label: "Plan Tiers", icon: CreditCard },
          { key: "history", label: "Semua Langganan", icon: Calendar },
          { key: "payments", label: "Semua Pembayaran", icon: Clock },
        ] as const).map(({ key, label, icon: Icon }) => (
          <button
            key={key}
            onClick={() => setTab(key)}
            className={`flex items-center gap-1.5 px-4 py-2 text-sm font-medium rounded-md transition ${
              tab === key ? "bg-white text-slate-900 shadow-sm" : "text-slate-500 hover:text-slate-700"
            }`}
          >
            <Icon className="h-4 w-4" />
            {label}
          </button>
        ))}
      </div>

      {tab === "plans" && <PlansView />}
      {tab === "history" && <HistoryView />}
      {tab === "payments" && <PaymentsView />}
    </div>
  );
}

// ── Plans View ──────────────────────────────────────────────────

function PlansView() {
  const { data, isLoading } = useSubscriptionPlans();
  const plans = (data?.data ?? []) as any[];

  if (isLoading) {
    return (
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {Array.from({ length: 3 }).map((_, i) => (
          <div key={i} className="skeleton h-[480px] rounded-2xl" />
        ))}
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Comparison banner */}
      <div className="bg-gradient-to-r from-brand-600 to-brand-700 rounded-2xl p-6 text-white">
        <div className="flex items-center gap-3 mb-2">
          <Users className="h-5 w-5" />
          <h3 className="font-bold text-lg">Posisi Harga vs Offline</h3>
        </div>
        <p className="text-sf-iceBlue text-sm">
          Harga 1 sesi PT offline = Rp 700.000 - Rp 900.000. Client mendapat 1 bulan full program + coaching mulai{" "}
          <span className="font-bold text-white">Rp 299.000</span>
        </p>
      </div>

      {/* Plan tiers */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {plans.map((group: any) => {
          const tier = group.tier;
          const monthly = group.monthly;
          const annual = group.annual;
          const colors = tierColors[tier] || tierColors.basic;
          const TierIcon = tierIcons[tier] || Zap;
          const isPopular = monthly?.is_popular;

          return (
            <div
              key={tier}
              className={`relative rounded-2xl border-2 ${colors.border} ${colors.bg} p-6 flex flex-col ${
                isPopular ? "ring-2 ring-sf-warmGold/40 ring-offset-2" : ""
              }`}
            >
              {isPopular && (
                <div className="absolute -top-3 left-1/2 -translate-x-1/2">
                  <span className="bg-sf-deepNavy text-white text-xs font-bold px-3 py-1 rounded-full">
                    MOST POPULAR
                  </span>
                </div>
              )}

              {/* Tier header */}
              <div className="flex items-center gap-2 mb-4">
                <div className={`p-2 rounded-lg ${colors.badge}`}>
                  <TierIcon className="h-5 w-5" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-slate-900 leading-tight">
                    {monthly?.name || tier.replace(/_/g, " ").replace(/\b\w/g, (c: string) => c.toUpperCase())}
                  </h3>
                  <p className="text-xs text-slate-500">{monthly?.description}</p>
                </div>
              </div>

              {/* Monthly price */}
              {monthly && (
                <div className="mb-4">
                  <div className="flex items-baseline gap-1">
                    <span className="text-3xl font-bold font-heading text-slate-900">
                      {formatCurrency(monthly.price, monthly.currency)}
                    </span>
                    <span className="text-sm text-slate-500">/ bulan</span>
                  </div>
                </div>
              )}

              {/* Annual price */}
              {annual && (
                <div className="mb-4 p-3 bg-white/60 rounded-xl border border-dashed border-slate-300">
                  <div className="flex items-center justify-between mb-1">
                    <span className="text-sm font-medium text-slate-700">Tahunan</span>
                    <span className="text-xs font-bold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded-full">
                      Hemat {annual.discount_pct}%
                    </span>
                  </div>
                  <div className="flex items-baseline gap-2">
                    <span className="text-lg font-bold text-slate-900">
                      {formatCurrency(annual.price, annual.currency)}
                    </span>
                    {annual.original_price && (
                      <span className="text-sm text-slate-400 line-through">
                        {formatCurrency(annual.original_price, annual.currency)}
                      </span>
                    )}
                  </div>
                  <p className="text-xs text-slate-500 mt-0.5">
                    = {formatCurrency(Math.round(annual.price / 12), annual.currency)} / bulan
                  </p>
                </div>
              )}

              {/* Features */}
              {(() => {
                const featureList = toFeatureList(monthly?.features);
                return featureList.length > 0 ? (
                  <ul className="space-y-2 flex-1 mb-4">
                    {featureList.map((f: string, i: number) => (
                      <li key={i} className="flex items-start gap-2 text-sm text-slate-600">
                        <Check className="h-4 w-4 text-emerald-500 shrink-0 mt-0.5" />
                        {f}
                      </li>
                    ))}
                  </ul>
                ) : null;
              })()}
            </div>
          );
        })}
      </div>
    </div>
  );
}

// ── Column Definitions ─────────────────────────────────────────

const historyColumns: Column<any>[] = [
  {
    key: "user_name", label: "Client",
    render: (sub) => (
      <div>
        <p className="font-medium text-slate-900">{sub.user_name || "—"}</p>
        <p className="text-xs text-slate-400">{sub.user_email || ""}</p>
      </div>
    ),
  },
  { key: "plan_name", label: "Plan", render: (sub) => <span className="font-medium text-slate-900">{sub.plan_name}</span> },
  {
    key: "status", label: "Status",
    render: (sub) => <span className={`text-xs font-medium px-2 py-0.5 rounded-full capitalize ${statusColors[sub.status] || ""}`}>{sub.status}</span>,
  },
  { key: "started_at", label: "Mulai", render: (sub) => <span className="text-slate-600">{formatDate(sub.started_at)}</span> },
  { key: "expires_at", label: "Berakhir", render: (sub) => <span className="text-slate-600">{formatDate(sub.expires_at)}</span> },
  { key: "payment_method", label: "Metode", render: (sub) => <span className="text-slate-500">{sub.payment_method || "-"}</span> },
];

const paymentColumns: Column<any>[] = [
  { key: "user_name", label: "Client", render: (p) => <span className="font-medium text-slate-900">{p.user_name || "—"}</span> },
  { key: "amount", label: "Amount", render: (p) => <span className="font-mono text-sm font-medium text-slate-900">{formatCurrency(p.amount, p.currency)}</span> },
  {
    key: "status", label: "Status",
    render: (p) => <span className={`text-xs font-medium px-2 py-0.5 rounded-full capitalize ${statusColors[p.status] || ""}`}>{p.status}</span>,
  },
  { key: "payment_method", label: "Metode", render: (p) => <span className="text-slate-600">{p.payment_method || "-"}</span> },
  { key: "external_id", label: "External ID", render: (p) => <span className="text-slate-500 font-mono text-xs">{p.external_id || "-"}</span> },
  { key: "created_at", label: "Tanggal", render: (p) => <span className="text-slate-600">{formatDate(p.created_at)}</span> },
];

// ── History View (Admin - all clients) ──────────────────────────

function HistoryView() {
  const [page, setPage] = useState(1);
  const [statusFilter, setStatusFilter] = useState("");
  const [planFilter, setPlanFilter] = useState("");

  const { data, isLoading } = useQuery({
    queryKey: ["admin-subscriptions", { page, limit: 20, status: statusFilter || undefined, plan_id: planFilter || undefined }],
    queryFn: () => apiGet("/api/payments/subscriptions", {
      page, limit: 20,
      ...(statusFilter && { status: statusFilter }),
      ...(planFilter && { plan_id: planFilter }),
    }),
  });
  const subs = (data?.data ?? []) as any[];
  const meta = data?.meta;

  // Stats summary
  const { data: statsData } = useQuery({
    queryKey: ["admin-sub-stats"],
    queryFn: () => apiGet("/api/payments/subscriptions", { limit: 1000 }),
  });
  const allSubs = (statsData?.data ?? []) as any[];
  const activeSubs = allSubs.filter((s: any) => s.status === "active");
  const cancelledSubs = allSubs.filter((s: any) => s.status === "cancelled");
  const expiredSubs = allSubs.filter((s: any) => s.status === "expired");

  return (
    <div className="space-y-4">
      {/* Stats cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="card p-4">
          <p className="text-xs text-slate-500 mb-1">Total Langganan</p>
          <p className="text-2xl font-bold text-slate-900">{allSubs.length}</p>
        </div>
        <div className="card p-4">
          <p className="text-xs text-slate-500 mb-1">Active</p>
          <p className="text-2xl font-bold text-emerald-600">{activeSubs.length}</p>
        </div>
        <div className="card p-4">
          <p className="text-xs text-slate-500 mb-1">Cancelled</p>
          <p className="text-2xl font-bold text-rose-600">{cancelledSubs.length}</p>
        </div>
        <div className="card p-4">
          <p className="text-xs text-slate-500 mb-1">Expired</p>
          <p className="text-2xl font-bold text-slate-500">{expiredSubs.length}</p>
        </div>
      </div>

      {/* Filters */}
      <div className="flex gap-3">
        <SearchableSelect
          options={[
            { value: "", label: "Semua Status" },
            { value: "active", label: "Active" },
            { value: "cancelled", label: "Cancelled" },
            { value: "expired", label: "Expired" },
            { value: "past_due", label: "Past Due" },
          ]}
          value={statusFilter}
          onChange={(v) => { setStatusFilter(v); setPage(1); }}
          placeholder="Semua Status"
          className="w-48"
        />
      </div>

      {!isLoading && subs.length === 0 ? (
        <div className="card p-12 text-center">
          <Calendar className="h-12 w-12 text-slate-300 mx-auto mb-3" />
          <h3 className="text-lg font-semibold text-slate-600">Tidak ada data</h3>
          <p className="text-sm text-slate-400 mt-1">Coba ubah filter untuk melihat data lain</p>
        </div>
      ) : (
        <DataTable
          columns={historyColumns}
          data={subs}
          loading={isLoading}
          page={page}
          totalPages={meta?.total_pages ?? 1}
          total={meta?.total ?? 0}
          onPageChange={setPage}
        />
      )}
    </div>
  );
}

// ── Payments View (Admin - all clients) ─────────────────────────

function PaymentsView() {
  const [page, setPage] = useState(1);
  const [statusFilter, setStatusFilter] = useState("");

  const { data, isLoading } = useQuery({
    queryKey: ["admin-payments", { page, limit: 20, status: statusFilter || undefined }],
    queryFn: () => apiGet("/api/payments", {
      page, limit: 20,
      ...(statusFilter && { status: statusFilter }),
    }),
  });
  const payments = (data?.data ?? []) as any[];
  const meta = data?.meta;

  // Revenue stats
  const { data: allPaymentsData } = useQuery({
    queryKey: ["admin-payments-stats"],
    queryFn: () => apiGet("/api/payments", { limit: 1000, status: "completed" }),
  });
  const completedPayments = (allPaymentsData?.data ?? []) as any[];
  const totalRevenue = completedPayments.reduce((sum: number, p: any) => sum + (p.amount || 0), 0);

  return (
    <div className="space-y-4">
      {/* Stats */}
      <div className="grid grid-cols-2 lg:grid-cols-3 gap-4">
        <div className="card p-4">
          <p className="text-xs text-slate-500 mb-1">Total Revenue</p>
          <p className="text-2xl font-bold text-emerald-600">{formatCurrency(totalRevenue)}</p>
        </div>
        <div className="card p-4">
          <p className="text-xs text-slate-500 mb-1">Total Transaksi</p>
          <p className="text-2xl font-bold text-slate-900">{completedPayments.length}</p>
        </div>
        <div className="card p-4">
          <p className="text-xs text-slate-500 mb-1">Rata-rata / Transaksi</p>
          <p className="text-2xl font-bold text-sf-deepNavy">
            {completedPayments.length > 0
              ? formatCurrency(Math.round(totalRevenue / completedPayments.length))
              : "Rp 0"}
          </p>
        </div>
      </div>

      {/* Filter */}
      <div className="flex gap-3">
        <SearchableSelect
          options={[
            { value: "", label: "Semua Status" },
            { value: "completed", label: "Completed" },
            { value: "pending", label: "Pending" },
            { value: "failed", label: "Failed" },
            { value: "refunded", label: "Refunded" },
          ]}
          value={statusFilter}
          onChange={(v) => { setStatusFilter(v); setPage(1); }}
          placeholder="Semua Status"
          className="w-48"
        />
      </div>

      {!isLoading && payments.length === 0 ? (
        <div className="card p-12 text-center">
          <CreditCard className="h-12 w-12 text-slate-300 mx-auto mb-3" />
          <h3 className="text-lg font-semibold text-slate-600">Tidak ada pembayaran</h3>
          <p className="text-sm text-slate-400 mt-1">Coba ubah filter untuk melihat data lain</p>
        </div>
      ) : (
        <DataTable
          columns={paymentColumns}
          data={payments}
          loading={isLoading}
          page={page}
          totalPages={meta?.total_pages ?? 1}
          total={meta?.total ?? 0}
          onPageChange={setPage}
        />
      )}
    </div>
  );
}
