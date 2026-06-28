"use client";

import { useState, useCallback } from "react";
import { useRouter } from "next/navigation";
import { useUsers, useDeleteUser } from "@/hooks/useUsers";
import { DataTable, type Column } from "@/components/shared/DataTable";
import { SearchInput } from "@/components/shared/SearchInput";
import { EmptyState } from "@/components/shared/EmptyState";
import { InviteUserModal } from "@/components/shared/InviteUserModal";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { Users, UserPlus, MoreHorizontal, Eye, Edit, Trash2 } from "lucide-react";
import { cn, formatDate, formatRelative, getInitials } from "@/lib/utils";
import { SearchableSelect } from "@/components/shared/SearchableSelect";

// ── Badge color maps ────────────────────────────────────────────

const roleColors: Record<string, string> = {
  owner: "bg-purple-100 text-purple-700",
  admin: "bg-blue-100 text-blue-700",
  finance: "bg-amber-100 text-amber-700",
  trainer: "bg-emerald-100 text-emerald-700",
  client: "bg-slate-100 text-slate-600",
};

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

// ── Page ────────────────────────────────────────────────────────

export default function UsersPage() {
  const router = useRouter();

  // Filters
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState("");
  const [roleFilter, setRoleFilter] = useState("");
  const [statusFilter, setStatusFilter] = useState("");
  const [sortBy, setSortBy] = useState("created_at");
  const [sortOrder, setSortOrder] = useState<"asc" | "desc">("desc");

  // Modals
  const [inviteOpen, setInviteOpen] = useState(false);
  const [deleteTarget, setDeleteTarget] = useState<{ id: string; name: string } | null>(null);

  // Data
  const { data, isLoading } = useUsers({
    page, limit: 20, search,
    role: roleFilter || undefined,
    status: statusFilter || undefined,
    sort_by: sortBy,
    sort_order: sortOrder,
  });
  const users = (data?.data ?? []) as any[];
  const meta = data?.meta;

  const { mutate: deleteUser, isPending: deleting } = useDeleteUser();

  const handleSort = useCallback((key: string) => {
    if (sortBy === key) {
      setSortOrder((prev) => (prev === "asc" ? "desc" : "asc"));
    } else {
      setSortBy(key);
      setSortOrder("asc");
    }
    setPage(1);
  }, [sortBy]);

  // ── Columns ─────────────────────────────────────────────────

  const columns: Column<any>[] = [
    {
      key: "full_name",
      label: "Name",
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
        <span className={cn("px-2.5 py-0.5 rounded-full text-xs font-medium capitalize", roleColors[row.role])}>
          {row.role}
        </span>
      ),
    },
    {
      key: "status",
      label: "Status",
      render: (row) => (
        <span className={cn("inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium capitalize", statusColors[row.status])}>
          <span className={cn("w-1.5 h-1.5 rounded-full", statusDot[row.status])} />
          {row.status}
        </span>
      ),
    },
    {
      key: "created_at",
      label: "Joined",
      sortable: true,
      render: (row) => (
        <span className="text-slate-600">{formatDate(row.created_at)}</span>
      ),
    },
    {
      key: "updated_at",
      label: "Last Active",
      render: (row) => (
        <span className="text-xs text-slate-400">{formatRelative(row.updated_at)}</span>
      ),
    },
    {
      key: "actions",
      label: "",
      className: "w-12",
      render: (row) => (
        <ActionMenu
          onView={() => router.push(`/users/${row.id}`)}
          onEdit={() => router.push(`/users/${row.id}`)}
          onDelete={() => setDeleteTarget({ id: row.id, name: row.full_name })}
          isOwner={row.role === "owner"}
        />
      ),
    },
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">User Management</h1>
          <p className="text-sm text-slate-500 mt-1">
            {meta?.total != null ? `${meta.total} users total` : "Manage platform users and roles"}
          </p>
        </div>
        <button onClick={() => setInviteOpen(true)} className="btn-primary">
          <UserPlus className="h-4 w-4" /> Invite User
        </button>
      </div>

      {/* Filters */}
      <div className="flex items-center gap-3 flex-wrap">
        <SearchInput value={search} onChange={(v) => { setSearch(v); setPage(1); }} placeholder="Search by name or email..." />
        <SearchableSelect
          options={[
            { value: "", label: "All Roles" },
            { value: "owner", label: "Owner" },
            { value: "admin", label: "Admin" },
            { value: "finance", label: "Finance" },
            { value: "trainer", label: "Trainer" },
            { value: "client", label: "Client" },
          ]}
          value={roleFilter}
          onChange={(v) => { setRoleFilter(v); setPage(1); }}
          placeholder="All Roles"
          className="w-48"
        />
        <SearchableSelect
          options={[
            { value: "", label: "All Status" },
            { value: "active", label: "Active" },
            { value: "pending", label: "Pending" },
            { value: "suspended", label: "Suspended" },
            { value: "inactive", label: "Inactive" },
          ]}
          value={statusFilter}
          onChange={(v) => { setStatusFilter(v); setPage(1); }}
          placeholder="All Status"
          className="w-48"
        />
      </div>

      {/* Table */}
      {!isLoading && users.length === 0 && !search && !roleFilter && !statusFilter ? (
        <EmptyState
          icon={Users}
          title="No users yet"
          description="Invite your first team member or client to get started."
          action={
            <button onClick={() => setInviteOpen(true)} className="btn-primary">
              <UserPlus className="h-4 w-4" /> Invite User
            </button>
          }
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
          onRowClick={(row) => router.push(`/users/${row.id}`)}
        />
      )}

      {/* Invite Modal */}
      <InviteUserModal open={inviteOpen} onClose={() => setInviteOpen(false)} />

      {/* Delete Confirm */}
      <ConfirmDialog
        open={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        onConfirm={() => {
          if (deleteTarget) {
            deleteUser(deleteTarget.id, { onSuccess: () => setDeleteTarget(null) });
          }
        }}
        title="Delete User"
        description={`Are you sure you want to delete ${deleteTarget?.name}? This action will soft-delete their account. They will no longer be able to sign in.`}
        confirmLabel="Delete User"
        variant="danger"
        loading={deleting}
      />
    </div>
  );
}

// ── Action dropdown (3-dot menu per row) ────────────────────────

function ActionMenu({
  onView, onEdit, onDelete, isOwner,
}: {
  onView: () => void;
  onEdit: () => void;
  onDelete: () => void;
  isOwner: boolean;
}) {
  const [open, setOpen] = useState(false);

  return (
    <div className="relative" onClick={(e) => e.stopPropagation()}>
      <button
        onClick={() => setOpen(!open)}
        className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400 hover:text-slate-600 transition-colors"
      >
        <MoreHorizontal className="h-4 w-4" />
      </button>

      {open && (
        <>
          <div className="fixed inset-0 z-40" onClick={() => setOpen(false)} />
          <div className="absolute right-0 top-full mt-1 w-44 bg-white rounded-xl shadow-lg border border-slate-100 py-1 z-50 animate-fade-in">
            <button
              onClick={() => { onView(); setOpen(false); }}
              className="w-full flex items-center gap-2.5 px-3 py-2 text-sm text-slate-600 hover:bg-slate-50"
            >
              <Eye className="h-3.5 w-3.5" /> View Details
            </button>
            <button
              onClick={() => { onEdit(); setOpen(false); }}
              className="w-full flex items-center gap-2.5 px-3 py-2 text-sm text-slate-600 hover:bg-slate-50"
            >
              <Edit className="h-3.5 w-3.5" /> Edit User
            </button>
            {!isOwner && (
              <>
                <hr className="my-1 border-slate-100" />
                <button
                  onClick={() => { onDelete(); setOpen(false); }}
                  className="w-full flex items-center gap-2.5 px-3 py-2 text-sm text-rose-600 hover:bg-rose-50"
                >
                  <Trash2 className="h-3.5 w-3.5" /> Delete User
                </button>
              </>
            )}
          </div>
        </>
      )}
    </div>
  );
}
