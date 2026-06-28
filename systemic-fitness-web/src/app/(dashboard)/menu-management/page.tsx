"use client";

import { useState } from "react";
import {
  useMenus,
  useMenuTree,
  useMenuPrivileges,
  useCreateMenu,
  useUpdateMenu,
  useDeleteMenu,
  useBulkUpsertPrivileges,
  MenuItem,
  MenuRolePrivilege,
} from "@/hooks/useMenus";
import { useAuth } from "@/hooks/useAuth";
import { EmptyState } from "@/components/shared/EmptyState";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { SearchInput } from "@/components/shared/SearchInput";
import { DataTable, Column } from "@/components/shared/DataTable";
import { SearchableSelect } from "@/components/shared/SearchableSelect";
import {
  Shield, Plus, X, Loader2, Pencil, Trash2, MoreVertical,
  Check, XCircle, Save, ChevronRight, ChevronDown,
} from "lucide-react";
import { cn } from "@/lib/utils";

const ALL_ROLES = ["owner", "admin", "finance", "trainer", "client"] as const;

const ROLE_LABELS: Record<string, string> = {
  owner: "Owner",
  admin: "Admin",
  finance: "Finance",
  trainer: "Trainer",
  client: "Client",
};

const ROLE_COLORS: Record<string, string> = {
  owner: "bg-purple-100 text-purple-700",
  admin: "bg-blue-100 text-blue-700",
  finance: "bg-amber-100 text-amber-700",
  trainer: "bg-emerald-100 text-emerald-700",
  client: "bg-slate-100 text-slate-600",
};

// ── Tab type ───────────────────────────────���────────────────────

type TabType = "menus" | "privileges";

export default function MenuManagementPage() {
  const { isOwner } = useAuth();
  const [activeTab, setActiveTab] = useState<TabType>("menus");

  if (!isOwner) {
    return (
      <EmptyState
        icon={Shield}
        title="Akses Ditolak"
        description="Hanya konsultan/owner yang dapat mengelola menu dan hak akses."
      />
    );
  }

  return (
    <div className="space-y-5">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-slate-900">Menu Management</h1>
        <p className="text-sm text-slate-500 mt-1">
          Kelola menu sidebar dan hak akses per role
        </p>
      </div>

      {/* Tabs */}
      <div className="flex gap-1 bg-slate-100 rounded-lg p-1 w-fit">
        <button
          onClick={() => setActiveTab("menus")}
          className={cn(
            "px-4 py-2 rounded-md text-sm font-medium transition-colors",
            activeTab === "menus"
              ? "bg-white text-slate-900 shadow-sm"
              : "text-slate-500 hover:text-slate-700"
          )}
        >
          Daftar Menu
        </button>
        <button
          onClick={() => setActiveTab("privileges")}
          className={cn(
            "px-4 py-2 rounded-md text-sm font-medium transition-colors",
            activeTab === "privileges"
              ? "bg-white text-slate-900 shadow-sm"
              : "text-slate-500 hover:text-slate-700"
          )}
        >
          Hak Akses
        </button>
      </div>

      {activeTab === "menus" ? <MenuListTab /> : <PrivilegesTab />}
    </div>
  );
}

// ════════════════════════════════════════════════════════════════════
//  Tab 1: Menu List (CRUD + Table)
// ════════════════════════════════════════════════════════════��═══════

function MenuListTab() {
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [modalMenu, setModalMenu] = useState<any | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<any | null>(null);
  const [menuOpen, setMenuOpen] = useState<string | null>(null);

  const params: Record<string, unknown> = { page, limit: 50, search };
  const { data, isLoading } = useMenus(params);
  const deleteMenu = useDeleteMenu();
  const menus = (data?.data ?? []) as MenuItem[];
  const meta = data?.meta;

  function openCreate() { setModalMenu({}); }
  function openEdit(m: any) { setMenuOpen(null); setModalMenu(m); }
  function openDelete(m: any) { setMenuOpen(null); setDeleteTarget(m); }

  async function confirmDelete() {
    if (!deleteTarget) return;
    await deleteMenu.mutateAsync(deleteTarget.id);
    setDeleteTarget(null);
  }

  return (
    <>
      {/* Toolbar */}
      <div className="flex items-center gap-3">
        <div className="flex-1">
          <SearchInput
            value={search}
            onChange={(v) => { setSearch(v); setPage(1); }}
            placeholder="Cari menu berdasarkan nama atau kode..."
          />
        </div>
        <button onClick={openCreate} className="btn-primary">
          <Plus className="h-4 w-4" /> Tambah Menu
        </button>
      </div>

      {/* Table */}
      {!isLoading && menus.length === 0 ? (
        <EmptyState
          icon={Shield}
          title={search ? "Tidak ditemukan" : "Belum ada menu"}
          description={search ? "Coba kata kunci lain" : "Tambahkan menu untuk navigasi sidebar."}
          action={!search ? (
            <button onClick={openCreate} className="btn-primary">
              <Plus className="h-4 w-4" /> Tambah Menu
            </button>
          ) : undefined}
        />
      ) : (
        <DataTable
          columns={menuColumns(menuOpen, setMenuOpen, openEdit, openDelete)}
          data={menus}
          loading={isLoading}
          page={page}
          pageSize={50}
          totalPages={meta?.total_pages ?? 1}
          total={meta?.total ?? 0}
          onPageChange={setPage}
        />
      )}

      {/* Create / Edit Modal */}
      {modalMenu !== null && (
        <MenuFormModal
          menu={modalMenu.id ? modalMenu : null}
          allMenus={menus}
          onClose={() => setModalMenu(null)}
        />
      )}

      {/* Delete Confirm */}
      <ConfirmDialog
        open={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        onConfirm={confirmDelete}
        title="Hapus Menu"
        description={`Apakah Anda yakin ingin menghapus "${deleteTarget?.label}"? Menu anak juga akan terhapus.`}
        confirmLabel="Hapus"
        variant="danger"
        loading={deleteMenu.isPending}
      />
    </>
  );
}

// ── Menu List Columns ──────────────────────────────────────────

function menuColumns(
  menuOpenId: string | null,
  setMenuOpen: (id: string | null) => void,
  openEdit: (m: any) => void,
  openDelete: (m: any) => void,
): Column<any>[] {
  return [
    { key: "label", label: "Label", render: (m) => <span className="font-medium text-slate-900 text-sm">{m.label}</span> },
    { key: "code", label: "Code", className: "w-36", render: (m) => <span className="inline-block px-2 py-0.5 rounded-md bg-slate-100 text-slate-600 text-xs font-mono">{m.code}</span> },
    { key: "icon", label: "Icon", render: (m) => <span className="text-sm text-slate-600">{m.icon || "—"}</span> },
    { key: "href", label: "Href", render: (m) => m.href ? <span className="text-sm text-sf-deepNavy font-mono">{m.href}</span> : <span className="text-xs text-slate-400 italic">group</span> },
    { key: "parent_id", label: "Parent", className: "w-20", render: (m) => m.parent_id ? <span className="px-1.5 py-0.5 bg-amber-50 text-amber-600 rounded text-xs">child</span> : <span className="px-1.5 py-0.5 bg-blue-50 text-blue-600 rounded text-xs">root</span> },
    { key: "sort_order", label: "Order", className: "w-16 text-center", render: (m) => <span className="text-sm text-slate-600">{m.sort_order}</span> },
    { key: "is_active", label: "Status", className: "w-20", render: (m) => m.is_active ? <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700 text-xs font-medium"><Check className="h-3 w-3" /> Aktif</span> : <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-slate-100 text-slate-500 text-xs font-medium"><XCircle className="h-3 w-3" /> Off</span> },
    {
      key: "actions", label: "", className: "w-12",
      render: (m) => (
        <div className="relative">
          <button onClick={(e) => { e.stopPropagation(); setMenuOpen(menuOpenId === m.id ? null : m.id); }} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400 transition-colors"><MoreVertical className="h-4 w-4" /></button>
          {menuOpenId === m.id && (
            <>
              <div className="fixed inset-0 z-10" onClick={() => setMenuOpen(null)} />
              <div className="absolute right-4 top-10 bg-white rounded-lg shadow-lg border border-slate-100 py-1 min-w-[140px] z-20">
                <button onClick={(e) => { e.stopPropagation(); openEdit(m); }} className="w-full px-3 py-2 text-left text-sm text-slate-700 hover:bg-slate-50 flex items-center gap-2"><Pencil className="h-3.5 w-3.5" /> Edit</button>
                <button onClick={(e) => { e.stopPropagation(); openDelete(m); }} className="w-full px-3 py-2 text-left text-sm text-rose-600 hover:bg-rose-50 flex items-center gap-2"><Trash2 className="h-3.5 w-3.5" /> Hapus</button>
              </div>
            </>
          )}
        </div>
      ),
    },
  ];
}

// ════════════════════════════════════════════════════════════════════
//  Tab 2: Privileges (Role × Menu matrix)
// ════════════════════════════════════════════════════════════════════

function PrivilegesTab() {
  const { data: treeData, isLoading: treeLoading } = useMenuTree();
  const { data: privData, isLoading: privLoading } = useMenuPrivileges();
  const bulkUpsert = useBulkUpsertPrivileges();

  const menus = (treeData?.data ?? []) as MenuItem[];
  const privileges = (privData?.data ?? []) as MenuRolePrivilege[];

  // Build a lookup: { menuId: { role: can_access } }
  const [localPrivs, setLocalPrivs] = useState<Record<string, Record<string, boolean>>>({});
  const [initialized, setInitialized] = useState(false);
  const [expandedGroups, setExpandedGroups] = useState<string[]>([]);

  // Initialize local state from API data
  if (!initialized && privileges.length > 0) {
    const map: Record<string, Record<string, boolean>> = {};
    privileges.forEach((p) => {
      if (!map[p.menu_id]) map[p.menu_id] = {};
      map[p.menu_id][p.role] = p.can_access;
    });
    setLocalPrivs(map);
    setInitialized(true);
  }

  function togglePriv(menuId: string, role: string) {
    setLocalPrivs((prev) => {
      const menuPrivs = { ...(prev[menuId] || {}) };
      menuPrivs[role] = !menuPrivs[role];
      return { ...prev, [menuId]: menuPrivs };
    });
  }

  function toggleGroup(menuId: string) {
    setExpandedGroups((prev) =>
      prev.includes(menuId) ? prev.filter((g) => g !== menuId) : [...prev, menuId]
    );
  }

  async function handleSave() {
    const items = Object.entries(localPrivs).map(([menuId, roles]) => ({
      menu_id: menuId,
      privileges: Object.entries(roles).map(([role, can_access]) => ({
        role,
        can_access,
      })),
    }));
    await bulkUpsert.mutateAsync(items);
  }

  const isLoading = treeLoading || privLoading;

  if (isLoading) {
    return (
      <div className="space-y-3">
        {Array.from({ length: 8 }).map((_, i) => (
          <div key={i} className="card p-4">
            <div className="flex gap-4">
              <div className="skeleton h-5 w-40" />
              {ALL_ROLES.map((r) => (
                <div key={r} className="skeleton h-5 w-12" />
              ))}
            </div>
          </div>
        ))}
      </div>
    );
  }

  function hasAccess(menuId: string, role: string): boolean {
    return localPrivs[menuId]?.[role] ?? false;
  }

  // Flatten tree for display
  function renderMenuRow(menu: MenuItem, depth: number = 0) {
    const hasChildren = menu.children && menu.children.length > 0;
    const isExpanded = expandedGroups.includes(menu.id);

    return (
      <tr key={menu.id} className={cn("hover:bg-slate-50/80 transition-colors", depth > 0 && "bg-slate-25")}>
        <td className="px-4 py-3">
          <div className="flex items-center gap-2" style={{ paddingLeft: depth * 24 }}>
            {hasChildren ? (
              <button onClick={() => toggleGroup(menu.id)} className="p-0.5 rounded hover:bg-slate-200">
                {isExpanded ? <ChevronDown className="h-4 w-4 text-slate-400" /> : <ChevronRight className="h-4 w-4 text-slate-400" />}
              </button>
            ) : (
              <span className="w-5" />
            )}
            <span className={cn("text-sm", depth === 0 ? "font-medium text-slate-900" : "text-slate-700")}>
              {menu.label}
            </span>
            <span className="text-xs text-slate-400 font-mono">{menu.code}</span>
          </div>
        </td>
        {ALL_ROLES.map((role) => (
          <td key={role} className="px-3 py-3 text-center">
            <button
              onClick={() => togglePriv(menu.id, role)}
              className={cn(
                "w-7 h-7 rounded-lg flex items-center justify-center transition-all",
                hasAccess(menu.id, role)
                  ? "bg-emerald-100 text-emerald-600 hover:bg-emerald-200"
                  : "bg-slate-100 text-slate-300 hover:bg-slate-200 hover:text-slate-400"
              )}
            >
              {hasAccess(menu.id, role) ? (
                <Check className="h-4 w-4" />
              ) : (
                <XCircle className="h-3.5 w-3.5" />
              )}
            </button>
          </td>
        ))}
      </tr>
    );
  }

  function renderMenuRows(menuList: MenuItem[], depth: number = 0): React.ReactNode[] {
    const rows: React.ReactNode[] = [];
    for (const menu of menuList) {
      rows.push(renderMenuRow(menu, depth));
      const hasChildren = menu.children && menu.children.length > 0;
      const isExpanded = expandedGroups.includes(menu.id);
      if (hasChildren && isExpanded) {
        rows.push(...renderMenuRows(menu.children!, depth + 1));
      }
    }
    return rows;
  }

  return (
    <>
      {/* Save bar */}
      <div className="flex items-center justify-between">
        <p className="text-sm text-slate-500">
          Klik checkbox untuk mengubah hak akses. Jangan lupa simpan perubahan.
        </p>
        <button
          onClick={handleSave}
          disabled={bulkUpsert.isPending}
          className="btn-primary"
        >
          {bulkUpsert.isPending ? (
            <Loader2 className="h-4 w-4 animate-spin" />
          ) : (
            <Save className="h-4 w-4" />
          )}
          {bulkUpsert.isPending ? "Menyimpan..." : "Simpan Perubahan"}
        </button>
      </div>

      {/* Matrix table */}
      <div className="card overflow-hidden overflow-x-auto">
        <table className="w-full">
          <thead>
            <tr className="border-b border-slate-100 bg-slate-50/50">
              <th className="text-left px-4 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wider min-w-[300px]">
                Menu
              </th>
              {ALL_ROLES.map((role) => (
                <th key={role} className="px-3 py-3 text-center min-w-[80px]">
                  <span className={cn("inline-block px-2 py-1 rounded-full text-xs font-semibold", ROLE_COLORS[role])}>
                    {ROLE_LABELS[role]}
                  </span>
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-50">
            {renderMenuRows(menus)}
          </tbody>
        </table>
      </div>
    </>
  );
}

// ═════════════════════════════════════════════════════════════════���══
//  Menu Form Modal (Create / Edit)
// ════════════════════════════════════════════════════════════════════

interface MenuFormModalProps {
  menu: MenuItem | null;
  allMenus: MenuItem[];
  onClose: () => void;
}

function MenuFormModal({ menu, allMenus, onClose }: MenuFormModalProps) {
  const isEdit = !!menu?.id;
  const createMenu = useCreateMenu();
  const updateMenu = useUpdateMenu();
  const saving = createMenu.isPending || updateMenu.isPending;

  const [label, setLabel] = useState(menu?.label ?? "");
  const [code, setCode] = useState(menu?.code ?? "");
  const [icon, setIcon] = useState(menu?.icon ?? "");
  const [href, setHref] = useState(menu?.href ?? "");
  const [parentId, setParentId] = useState<string>(menu?.parent_id ?? "");
  const [sortOrder, setSortOrder] = useState<number>(menu?.sort_order ?? 0);
  const [isActive, setIsActive] = useState<boolean>(menu?.is_active ?? true);

  // Only root menus (no parent) can be parents
  const parentOptions = allMenus.filter((m) => !m.parent_id && m.id !== menu?.id);

  function handleLabelChange(val: string) {
    setLabel(val);
    if (!isEdit) {
      setCode(val.toLowerCase().replace(/\s+/g, "-").replace(/[^a-z0-9-]/g, ""));
    }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!label.trim() || !code.trim()) return;

    const payload: Record<string, unknown> = {
      label: label.trim(),
      code: code.trim(),
      icon: icon.trim() || null,
      href: href.trim() || null,
      parent_id: parentId || null,
      sort_order: sortOrder,
      is_active: isActive,
    };

    if (isEdit) {
      await updateMenu.mutateAsync({ id: menu!.id, ...payload });
    } else {
      await createMenu.mutateAsync(payload);
    }
    onClose();
  }

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center pt-[5vh] overflow-y-auto" onClick={onClose}>
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" />
      <div className="relative bg-white rounded-2xl shadow-xl max-w-lg w-full mx-4 mb-12 animate-slide-in" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
          <h2 className="text-lg font-semibold text-slate-900">
            {isEdit ? "Edit Menu" : "Tambah Menu"}
          </h2>
          <button onClick={onClose} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400">
            <X className="h-5 w-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-5 max-h-[75vh] overflow-y-auto">
          <div>
            <label className="label">Label *</label>
            <input
              value={label}
              onChange={(e) => handleLabelChange(e.target.value)}
              required
              className="input"
              placeholder="e.g. Dashboard"
              autoFocus
            />
          </div>

          <div>
            <label className="label">Code *</label>
            <input
              value={code}
              onChange={(e) => setCode(e.target.value)}
              required
              className="input font-mono"
              placeholder="e.g. dashboard"
            />
            <p className="text-xs text-slate-400 mt-1">Kode unik (lowercase, tanpa spasi)</p>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Icon (Lucide)</label>
              <input
                value={icon}
                onChange={(e) => setIcon(e.target.value)}
                className="input"
                placeholder="e.g. LayoutDashboard"
              />
              <p className="text-xs text-slate-400 mt-1">Nama icon dari Lucide React</p>
            </div>
            <div>
              <label className="label">Href (Route)</label>
              <input
                value={href}
                onChange={(e) => setHref(e.target.value)}
                className="input font-mono"
                placeholder="e.g. /dashboard"
              />
              <p className="text-xs text-slate-400 mt-1">Kosongkan untuk parent group</p>
            </div>
          </div>

          <div>
            <label className="label">Parent Menu</label>
            <SearchableSelect
              options={[{ value: "", label: "— Root (Top-level) —" }, ...parentOptions.map((p) => ({ value: p.id, label: `${p.label} (${p.code})` }))]}
              value={parentId}
              onChange={setParentId}
              placeholder="Pilih parent menu..."
              searchPlaceholder="Cari menu..."
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Sort Order</label>
              <input
                type="number"
                value={sortOrder}
                onChange={(e) => setSortOrder(parseInt(e.target.value) || 0)}
                className="input"
                min={0}
              />
            </div>
            <div>
              <label className="label">Status</label>
              <SearchableSelect
                options={[{ value: "active", label: "Aktif" }, { value: "inactive", label: "Nonaktif" }]}
                value={isActive ? "active" : "inactive"}
                onChange={(v) => setIsActive(v === "active")}
                placeholder="Pilih status..."
              />
            </div>
          </div>

          <div className="flex justify-end gap-3 pt-2">
            <button type="button" onClick={onClose} className="btn-secondary">Batal</button>
            <button type="submit" disabled={saving || !label.trim() || !code.trim()} className="btn-primary">
              {saving ? <Loader2 className="h-4 w-4 animate-spin" /> : isEdit ? <Pencil className="h-4 w-4" /> : <Plus className="h-4 w-4" />}
              {saving ? "Menyimpan..." : isEdit ? "Simpan" : "Tambah Menu"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
