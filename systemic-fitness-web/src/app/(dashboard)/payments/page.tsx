"use client";

import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { apiGet } from "@/lib/api";
import { StatsCard, StatsCardSkeleton } from "@/components/shared/StatsCard";
import { RevenueChartSkeleton } from "@/components/charts/ChartSkeletons";
import { DataTable, type Column } from "@/components/shared/DataTable";
import dynamic from "next/dynamic";

const RevenueChart = dynamic(
  () => import("@/components/charts/RevenueChart").then((mod) => mod.RevenueChart),
  { ssr: false, loading: () => <RevenueChartSkeleton /> }
);
import {
  DollarSign,
  CreditCard,
  Users,
  TrendingUp,
  BarChart3,
  Pencil,
  Image as ImageIcon,
  Building2,
  CheckCircle2,
  Clock,
} from "lucide-react";
import { cn, formatCurrency, formatDate } from "@/lib/utils";
import Link from "next/link";
import { PaymentStatusModal } from "./PaymentStatusModal";

const statusColors: Record<string, string> = {
  completed: "bg-emerald-100 text-emerald-700",
  pending: "bg-amber-100 text-amber-700",
  failed: "bg-rose-100 text-rose-700",
  refunded: "bg-slate-100 text-slate-600",
};

const PAYMENT_STATUSES = ["all", "pending", "completed", "failed", "refunded"] as const;
type StatusFilter = (typeof PAYMENT_STATUSES)[number];

interface PaymentRecord {
  id: string;
  user_name?: string | null;
  user_email?: string | null;
  amount: number;
  currency: string;
  status: string;
  payment_method?: string | null;
  payment_type?: string | null;
  bank_name?: string | null;
  proof_image_url?: string | null;
  proof_uploaded_at?: string | null;
  created_at: string;
}

function paymentTypeLabel(type?: string | null): string {
  switch (type) {
    case "manual_transfer":
      return "Manual";
    case "midtrans_snap":
      return "Midtrans";
    default:
      return type || "—";
  }
}

export default function PaymentsPage() {
  const [page, setPage] = useState(1);
  const [statusFilter, setStatusFilter] = useState<StatusFilter>("all");
  const [editing, setEditing] = useState<PaymentRecord | null>(null);

  const { data: overview, isLoading: ovLoading } = useQuery({
    queryKey: ["dashboard", "overview"],
    queryFn: () => apiGet("/api/dashboard/overview"),
  });
  const stats = overview?.data as any;

  const { data: revenueData, isLoading: revLoading } = useQuery({
    queryKey: ["dashboard", "revenue"],
    queryFn: () => apiGet("/api/dashboard/revenue", { months: 12 }),
  });
  const revChart = (revenueData?.data as any)?.data ?? [];

  const { data: payments, isLoading: payLoading } = useQuery({
    queryKey: ["payments", page, statusFilter],
    queryFn: () =>
      apiGet<PaymentRecord[]>("/api/payments", {
        page,
        limit: 10,
        ...(statusFilter !== "all" ? { status: statusFilter } : {}),
      }),
  });
  const records = (payments?.data ?? []) as PaymentRecord[];
  const meta = payments?.meta;

  const columns: Column<PaymentRecord>[] = [
    {
      key: "user_name",
      label: "Customer",
      render: (r) => (
        <div className="min-w-0">
          <p className="font-medium text-slate-900 truncate">{r.user_name || "—"}</p>
          {r.user_email && (
            <p className="text-xs text-slate-400 truncate">{r.user_email}</p>
          )}
        </div>
      ),
    },
    {
      key: "amount",
      label: "Amount",
      render: (r) => (
        <span className="font-mono text-sm">{formatCurrency(r.amount, r.currency)}</span>
      ),
    },
    {
      key: "status",
      label: "Status",
      render: (r) => (
        <span
          className={cn(
            "px-2 py-0.5 rounded-full text-xs font-medium capitalize",
            statusColors[r.status]
          )}
        >
          {r.status}
        </span>
      ),
    },
    {
      key: "payment_type",
      label: "Type",
      render: (r) => (
        <div className="flex items-center gap-1.5">
          {r.payment_type === "midtrans_snap" ? (
            <CreditCard className="h-3.5 w-3.5 text-blue-500" />
          ) : (
            <Building2 className="h-3.5 w-3.5 text-emerald-500" />
          )}
          <span className="text-xs text-slate-600">{paymentTypeLabel(r.payment_type)}</span>
          {r.bank_name && (
            <span className="text-[10px] text-slate-400 ml-1">· {r.bank_name}</span>
          )}
        </div>
      ),
    },
    {
      key: "proof",
      label: "Proof",
      render: (r) => {
        if (r.payment_type === "midtrans_snap") {
          return <span className="text-[11px] text-slate-300">—</span>;
        }
        if (r.proof_image_url) {
          return (
            <span className="inline-flex items-center gap-1 text-[11px] font-medium text-emerald-700 bg-emerald-50 border border-emerald-200 px-1.5 py-0.5 rounded">
              <CheckCircle2 className="h-3 w-3" />
              Uploaded
            </span>
          );
        }
        if (r.status === "pending") {
          return (
            <span className="inline-flex items-center gap-1 text-[11px] font-medium text-amber-700 bg-amber-50 border border-amber-200 px-1.5 py-0.5 rounded">
              <Clock className="h-3 w-3" />
              Awaiting
            </span>
          );
        }
        return <span className="text-[11px] text-slate-300">—</span>;
      },
    },
    {
      key: "created_at",
      label: "Date",
      render: (r) => (
        <span className="text-sm text-slate-500">{formatDate(r.created_at)}</span>
      ),
    },
    {
      key: "actions",
      label: "",
      render: (r) => {
        const showVerify = r.status === "pending" && r.payment_type === "manual_transfer";
        return (
          <button
            type="button"
            onClick={() => setEditing(r)}
            className={cn(
              "inline-flex items-center gap-1 text-xs font-medium",
              showVerify
                ? "text-emerald-600 hover:text-emerald-700"
                : "text-sf-deepNavy hover:text-sf-deepNavy"
            )}
          >
            {showVerify ? (
              <>
                <ImageIcon className="h-3.5 w-3.5" /> Verify proof
              </>
            ) : (
              <>
                <Pencil className="h-3.5 w-3.5" /> Change status
              </>
            )}
          </button>
        );
      },
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Payments</h1>
          <p className="text-sm text-slate-500 mt-1">Revenue, subscriptions, and billing</p>
        </div>
        <div className="flex gap-2">
          <Link href="/payments/bank-accounts" className="btn-secondary">
            <Building2 className="h-4 w-4" /> Bank Accounts
          </Link>
          <Link href="/payments/subscriptions" className="btn-secondary">
            <Users className="h-4 w-4" /> Client Plans
          </Link>
          <Link href="/payments/plans" className="btn-secondary">
            <CreditCard className="h-4 w-4" /> Manage Plans
          </Link>
          <Link href="/payments/reports" className="btn-primary">
            <BarChart3 className="h-4 w-4" /> Reports
          </Link>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        {ovLoading ? (
          Array.from({ length: 4 }).map((_, i) => <StatsCardSkeleton key={i} />)
        ) : (
          <>
            <StatsCard label="Revenue (30d)" value={formatCurrency(stats?.revenue_30d ?? 0)} change={8} icon={DollarSign} iconColor="text-emerald-600" />
            <StatsCard label="Transactions" value={stats?.transaction_count_30d ?? 0} icon={CreditCard} iconColor="text-blue-600" />
            <StatsCard label="Active Subs" value={stats?.active_subscriptions ?? 0} icon={Users} iconColor="text-purple-600" />
            <StatsCard label="MRR" value={formatCurrency((stats?.revenue_30d ?? 0))} icon={TrendingUp} iconColor="text-sf-deepNavy" />
          </>
        )}
      </div>

      {/* Revenue Chart */}
      <div className="card p-6">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-sm font-semibold text-slate-700">Revenue Trend</h3>
          <span className="text-xs text-slate-400">Last 12 months</span>
        </div>
        {revLoading ? <RevenueChartSkeleton /> : <RevenueChart data={revChart} />}
      </div>

      {/* Recent Payments */}
      <div>
        <div className="flex items-center justify-between mb-3">
          <h3 className="text-sm font-semibold text-slate-700">Recent Payments</h3>
          <div className="flex items-center gap-1 bg-slate-100 rounded-lg p-1">
            {PAYMENT_STATUSES.map((s) => (
              <button
                key={s}
                type="button"
                onClick={() => {
                  setStatusFilter(s);
                  setPage(1);
                }}
                className={cn(
                  "px-3 py-1 text-xs font-medium rounded-md capitalize transition",
                  statusFilter === s
                    ? "bg-white text-slate-900 shadow-sm"
                    : "text-slate-500 hover:text-slate-700"
                )}
              >
                {s === "all" ? "All" : s}
              </button>
            ))}
          </div>
        </div>
        <DataTable
          columns={columns}
          data={records}
          loading={payLoading}
          page={page}
          totalPages={meta?.total_pages}
          total={meta?.total}
          onPageChange={setPage}
        />
      </div>

      <PaymentStatusModal
        open={!!editing}
        onClose={() => setEditing(null)}
        payment={editing}
      />
    </div>
  );
}
