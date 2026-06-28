"use client";

import { useState, useCallback } from "react";
import { useRouter } from "next/navigation";
import { useUsers } from "@/hooks/useUsers";
import { DataTable, type Column } from "@/components/shared/DataTable";
import { SearchInput } from "@/components/shared/SearchInput";
import { EmptyState } from "@/components/shared/EmptyState";
import { TrendingUp, Activity, Dumbbell, Flame, Eye } from "lucide-react";
import { cn, formatRelative, getInitials } from "@/lib/utils";
import { SearchableSelect } from "@/components/shared/SearchableSelect";

const statusColors: Record<string, string> = {
  active: "bg-emerald-100 text-emerald-700",
  pending: "bg-amber-100 text-amber-700",
  suspended: "bg-rose-100 text-rose-700",
  inactive: "bg-slate-100 text-slate-500",
};

const statusDot: Record<string, string> = {
  active: "bg-emerald-500",
  pending: "bg-amber-500",
  suspended: "bg-rose-500",
  inactive: "bg-slate-400",
};

const roleColors: Record<string, string> = {
  owner: "bg-purple-100 text-purple-700",
  admin: "bg-blue-100 text-blue-700",
  finance: "bg-amber-100 text-amber-700",
  trainer: "bg-emerald-100 text-emerald-700",
  client: "bg-slate-100 text-slate-600",
};

export default function ProgressPage() {
  const router = useRouter();

  const [page, setPage] = useState(1);
  const [search, setSearch] = useState("");
  const [roleFilter, setRoleFilter] = useState("");
  const [sortBy, setSortBy] = useState("created_at");
  const [sortOrder, setSortOrder] = useState<"asc" | "desc">("desc");

  const { data, isLoading } = useUsers({
    page,
    limit: 20,
    search,
    role: roleFilter || undefined,
    status: "active",
    sort_by: sortBy,
    sort_order: sortOrder,
  });

  const users = (data?.data ?? []) as any[];
  const meta = data?.meta;

  const handleSort = useCallback(
    (key: string) => {
      if (sortBy === key) {
        setSortOrder((prev) => (prev === "asc" ? "desc" : "asc"));
      } else {
        setSortBy(key);
        setSortOrder("asc");
      }
      setPage(1);
    },
    [sortBy]
  );

  const columns: Column<any>[] = [
    {
      key: "full_name",
      label: "User",
      sortable: true,
      render: (row) => (
        <div className="flex items-center gap-3">
          <div className="h-9 w-9 rounded-full bg-sf-iceBlue text-sf-deepNavy flex items-center justify-center text-xs font-bold shrink-0">
            {getInitials(row.full_name)}
          </div>
          <div className="min-w-0">
            <p className="font-medium text-slate-900 truncate">{row.full_name}</p>
            <p className="text-xs text-slate-400 truncate">{row.email}</p>
          </div>
        </div>
      ),
    },
    {
      key: "role",
      label: "Role",
      render: (row) => (
        <span
          className={cn(
            "px-2.5 py-0.5 rounded-full text-xs font-medium capitalize",
            roleColors[row.role]
          )}
        >
          {row.role}
        </span>
      ),
    },
    {
      key: "status",
      label: "Status",
      render: (row) => (
        <span
          className={cn(
            "inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium capitalize",
            statusColors[row.status]
          )}
        >
          <span className={cn("w-1.5 h-1.5 rounded-full", statusDot[row.status])} />
          {row.status}
        </span>
      ),
    },
    {
      key: "updated_at",
      label: "Last Active",
      sortable: true,
      render: (row) => (
        <span className="text-sm text-slate-500">{formatRelative(row.updated_at)}</span>
      ),
    },
    {
      key: "actions",
      label: "",
      className: "w-12",
      render: (row) => (
        <button
          onClick={(e) => {
            e.stopPropagation();
            router.push(`/progress/${row.id}`);
          }}
          className="p-2 rounded-lg hover:bg-sf-iceBlue text-slate-400 hover:text-sf-deepNavy transition-colors"
          title="View progress"
        >
          <Eye className="h-4 w-4" />
        </button>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-slate-900">User Progress</h1>
        <p className="text-sm text-slate-500 mt-1">
          {meta?.total != null
            ? `${meta.total} active users`
            : "Pantau log sesi, metrik tubuh, dan progres latihan"}
        </p>
      </div>

      {/* Filters */}
      <div className="flex items-center gap-3 flex-wrap">
        <SearchInput
          value={search}
          onChange={(v) => {
            setSearch(v);
            setPage(1);
          }}
          placeholder="Search by name or email..."
        />
        <SearchableSelect
          options={[
            { value: "", label: "All Roles" },
            { value: "client", label: "Client" },
            { value: "trainer", label: "Trainer" },
            { value: "admin", label: "Admin" },
            { value: "owner", label: "Owner" },
          ]}
          value={roleFilter}
          onChange={(v) => { setRoleFilter(v); setPage(1); }}
          placeholder="All Roles"
          className="w-48"
        />
      </div>

      {/* Table */}
      {!isLoading && users.length === 0 && !search && !roleFilter ? (
        <EmptyState
          icon={TrendingUp}
          title="No progress data yet"
          description="Setelah user mulai log sesi dan metrik tubuh, progres mereka akan muncul di sini."
        />
      ) : (
        <DataTable
          columns={columns}
          data={users}
          loading={isLoading}
          page={page}
          totalPages={meta?.total_pages ?? 1}
          total={meta?.total ?? 0}
          onPageChange={setPage}
          onSort={handleSort}
          sortBy={sortBy}
          sortOrder={sortOrder}
          onRowClick={(row) => router.push(`/progress/${row.id}`)}
        />
      )}
    </div>
  );
}
