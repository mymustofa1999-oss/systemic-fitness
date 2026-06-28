"use client";

import Link from "next/link";
import { useState } from "react";
import { ClipboardCheck, Loader2, Eye, ListChecks } from "lucide-react";

import {
  usePendingReviewAssessments,
  useAllAssessments,
  Assessment,
  AssessmentTier,
} from "@/hooks/useAssessments";
import { EmptyState } from "@/components/shared/EmptyState";
import { cn } from "@/lib/utils";

// ─── Types & helpers ──────────────────────────────────────────

type TabKey = "pending" | "reviewed" | "all";

interface TabConfig {
  key: TabKey;
  label: string;
  description: string;
}

const TABS: TabConfig[] = [
  {
    key: "pending",
    label: "Pending Review",
    description: "Paid assessments yang menunggu review konsultan.",
  },
  {
    key: "reviewed",
    label: "Sudah Direview",
    description: "Paid assessments yang sudah diverifikasi atau direvisi.",
  },
  {
    key: "all",
    label: "Semua",
    description: "Semua submission assessment (free + paid, semua status).",
  },
];

const TIER_FILTERS: { value: AssessmentTier | ""; label: string }[] = [
  { value: "", label: "Semua tier" },
  { value: "free", label: "Free" },
  { value: "paid", label: "Paid" },
];

function formatDate(iso: string): string {
  return new Intl.DateTimeFormat("id-ID", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  }).format(new Date(iso));
}

function statusClass(status: string): string {
  switch (status) {
    case "submitted":
      return "bg-amber-50 text-amber-700";
    case "verified":
      return "bg-green-50 text-green-700";
    case "revised":
      return "bg-blue-50 text-blue-700";
    default:
      return "bg-slate-100 text-slate-600";
  }
}

function tierClass(tier: string): string {
  return tier === "paid"
    ? "bg-purple-50 text-purple-700"
    : "bg-slate-100 text-slate-600";
}

function scoreColor(score: number): string {
  if (score >= 80) return "text-green-600";
  if (score >= 60) return "text-amber-600";
  return "text-red-600";
}

// ─── Page ──────────────────────────────────────────────────────

export default function AssessmentsPage() {
  const [activeTab, setActiveTab] = useState<TabKey>("pending");
  const [page, setPage] = useState(1);
  const [tierFilter, setTierFilter] = useState<AssessmentTier | "">("");
  const limit = 20;

  // Pending tab uses the dedicated /pending-review endpoint (sorted ASC
  // by created_at so the oldest queue item is first). Reviewed + All
  // use the /all endpoint with status / tier filters.
  const pendingQuery = usePendingReviewAssessments(
    activeTab === "pending" ? { page, limit } : { page: 1, limit: 1 },
  );
  const reviewedQuery = useAllAssessments(
    activeTab === "reviewed"
      ? {
          page,
          limit,
          tier: "paid",
          status: "verified", // primary; "revised" is fetched separately if needed
        }
      : { page: 1, limit: 1 },
  );
  const allQuery = useAllAssessments(
    activeTab === "all"
      ? {
          page,
          limit,
          ...(tierFilter ? { tier: tierFilter as AssessmentTier } : {}),
        }
      : { page: 1, limit: 1 },
  );

  const activeQuery =
    activeTab === "pending"
      ? pendingQuery
      : activeTab === "reviewed"
        ? reviewedQuery
        : allQuery;

  const items: Assessment[] = (activeQuery.data?.data ?? []) as Assessment[];
  const meta = activeQuery.data?.meta;

  function changeTab(tab: TabKey) {
    setActiveTab(tab);
    setPage(1);
  }

  const activeConfig = TABS.find((t) => t.key === activeTab)!;

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Assessments</h1>
          <p className="text-sm text-slate-500 mt-1">{activeConfig.description}</p>
        </div>
        <div className="flex items-center gap-3">
          <Link
            href="/assessments/composition"
            className="inline-flex items-center gap-1.5 rounded-lg border border-slate-200 bg-white px-3 py-2 text-xs font-medium text-slate-700 hover:bg-slate-50"
          >
            <ListChecks className="h-3.5 w-3.5" />
            Komposisi Assessment
          </Link>
          {/* Pending count badge — always visible regardless of active tab */}
          <div className="bg-amber-50 border border-amber-200 rounded-lg px-4 py-2">
            <div className="text-xs text-amber-600 font-medium">Pending Review</div>
            <div className="text-2xl font-bold text-amber-700">
              {pendingQuery.data?.meta?.total ?? "—"}
            </div>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex items-center gap-1 border-b border-slate-200">
        {TABS.map((t) => (
          <button
            key={t.key}
            type="button"
            onClick={() => changeTab(t.key)}
            className={cn(
              "px-4 py-2.5 text-sm font-medium border-b-2 transition-colors -mb-px",
              activeTab === t.key
                ? "border-sf-deepNavy text-sf-deepNavy"
                : "border-transparent text-slate-500 hover:text-slate-700",
            )}
          >
            {t.label}
          </button>
        ))}
      </div>

      {/* Filter bar — only on "Semua" */}
      {activeTab === "all" && (
        <div className="flex items-center gap-3">
          <span className="text-xs text-slate-500 font-medium">Filter tier:</span>
          <div className="flex items-center gap-1 bg-slate-100 rounded-lg p-1">
            {TIER_FILTERS.map((f) => (
              <button
                key={f.value}
                type="button"
                onClick={() => {
                  setTierFilter(f.value);
                  setPage(1);
                }}
                className={cn(
                  "px-3 py-1.5 text-xs font-medium rounded-md transition-colors",
                  tierFilter === f.value
                    ? "bg-white text-slate-900 shadow-sm"
                    : "text-slate-500 hover:text-slate-700",
                )}
              >
                {f.label}
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Table */}
      {activeQuery.isLoading ? (
        <div className="flex justify-center py-20">
          <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
        </div>
      ) : activeQuery.isError ? (
        <div className="card p-6 text-center text-red-600">
          {activeQuery.error instanceof Error
            ? activeQuery.error.message
            : "Failed to load assessments"}
        </div>
      ) : items.length === 0 ? (
        <EmptyState
          icon={ClipboardCheck}
          title={
            activeTab === "pending"
              ? "Tidak ada assessment menunggu review"
              : activeTab === "reviewed"
                ? "Belum ada assessment yang direview"
                : "Belum ada submission assessment"
          }
          description={
            activeTab === "pending"
              ? "Semua paid assessment sudah direview. Antrian akan muncul di sini saat klien submit baru."
              : activeTab === "reviewed"
                ? "Setelah konsultan/admin verifikasi paid assessment, history-nya akan muncul di sini."
                : "Setelah klien submit assessment dari mobile app, datanya akan muncul di sini."
          }
        />
      ) : (
        <div className="card overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 border-b border-slate-200">
              <tr>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">User</th>
                <th className="text-center px-4 py-3 font-semibold text-slate-600">Tier</th>
                <th className="text-center px-4 py-3 font-semibold text-slate-600">System Score</th>
                <th className="text-center px-4 py-3 font-semibold text-slate-600">Flags</th>
                <th className="text-center px-4 py-3 font-semibold text-slate-600">Status</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Submitted</th>
                <th className="text-right px-4 py-3 font-semibold text-slate-600">Aksi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {items.map((a) => (
                <tr key={a.id} className="hover:bg-slate-50/50">
                  <td className="px-4 py-3 text-slate-700">
                    {a.user_name ?? "—"}
                  </td>
                  <td className="px-4 py-3 text-center">
                    <span
                      className={cn(
                        "inline-flex px-2 py-0.5 text-xs font-medium rounded-full",
                        tierClass(a.tier),
                      )}
                    >
                      {a.tier === "paid" ? "Paid" : "Free"}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-center">
                    <span className={cn("font-bold text-base", scoreColor(a.scores.system_score))}>
                      {a.scores.system_score}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-center">
                    {a.flags.length === 0 ? (
                      <span className="text-slate-300">—</span>
                    ) : (
                      <span className="inline-flex items-center px-2 py-0.5 text-xs font-medium rounded-full bg-red-50 text-red-700">
                        {a.flags.length} flag{a.flags.length > 1 ? "s" : ""}
                      </span>
                    )}
                  </td>
                  <td className="px-4 py-3 text-center">
                    <span
                      className={cn(
                        "inline-flex px-2 py-0.5 text-xs font-medium rounded-full",
                        statusClass(a.status),
                      )}
                    >
                      {a.status}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-slate-500 text-xs">
                    {formatDate(a.created_at)}
                  </td>
                  <td className="px-4 py-3 text-right">
                    <Link
                      href={`/assessments/${a.id}`}
                      className="inline-flex items-center gap-1 px-3 py-1.5 rounded-md bg-sf-iceBlue text-sf-deepNavy hover:bg-sf-iceBlue text-xs font-medium"
                    >
                      <Eye className="h-3.5 w-3.5" />
                      {activeTab === "pending" ? "Review" : "Lihat"}
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>

          {/* Pagination */}
          {meta && meta.total_pages > 1 && (
            <div className="flex items-center justify-between border-t border-slate-200 px-4 py-3">
              <div className="text-xs text-slate-500">
                Halaman {meta.page} dari {meta.total_pages} ({meta.total} total)
              </div>
              <div className="flex items-center gap-2">
                <button
                  onClick={() => setPage((p) => Math.max(1, p - 1))}
                  disabled={page <= 1}
                  className="px-3 py-1 text-xs rounded border border-slate-200 hover:bg-slate-50 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Prev
                </button>
                <button
                  onClick={() => setPage((p) => p + 1)}
                  disabled={page >= meta.total_pages}
                  className="px-3 py-1 text-xs rounded border border-slate-200 hover:bg-slate-50 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Next
                </button>
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
