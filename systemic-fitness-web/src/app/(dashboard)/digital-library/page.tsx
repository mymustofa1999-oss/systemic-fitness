"use client";

import { useState } from "react";
import {
  BookOpen, Plus, Pencil, Trash2, Video, Image, Info,
  ChevronDown, Loader2, X, ArrowLeftRight, Eye,
} from "lucide-react";
import { cn } from "@/lib/utils";
import {
  useDLMovements, useDLCategories, useDLLevels,
  useDLMenuItems, useDLIsolateItems, useDLDynamicItems,
  useCreateDLMovement, useUpdateDLMovement, useDeleteDLMovement,
} from "@/hooks/useDigitalLibrary";
import { DataTable, Column } from "@/components/shared/DataTable";
import { SearchInput } from "@/components/shared/SearchInput";
import { EmptyState } from "@/components/shared/EmptyState";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { SearchableSelect } from "@/components/shared/SearchableSelect";

// ── Constants ───────────────────────────────────────────────────

const TABS = [
  { key: "movements", label: "Movements" },
  { key: "menu",      label: "Menu Program" },
  { key: "isolate",   label: "Isolate" },
  { key: "dynamic",   label: "Dynamic" },
] as const;

type TabKey = typeof TABS[number]["key"];

const BODY_PARTS = [
  { value: "upper", label: "Upper", color: "bg-blue-100 text-blue-700" },
  { value: "lower", label: "Lower", color: "bg-emerald-100 text-emerald-700" },
  { value: "core",  label: "Core",  color: "bg-amber-100 text-amber-700" },
  { value: "whole body", label: "Whole Body", color: "bg-purple-100 text-purple-700" },
];

const CATEGORY_COLORS: Record<string, string> = {
  fc: "bg-indigo-100 text-indigo-700",
  cc: "bg-rose-100 text-rose-700",
  mc: "bg-teal-100 text-teal-700",
};

const CAT_BUTTON_STYLES: Record<string, { active: string; inactive: string }> = {
  fc: { active: "bg-indigo-600 text-white shadow-sm shadow-indigo-200", inactive: "bg-white text-indigo-600 border-indigo-200 hover:bg-indigo-50" },
  cc: { active: "bg-rose-600 text-white shadow-sm shadow-rose-200", inactive: "bg-white text-rose-600 border-rose-200 hover:bg-rose-50" },
  mc: { active: "bg-teal-600 text-white shadow-sm shadow-teal-200", inactive: "bg-white text-teal-600 border-teal-200 hover:bg-teal-50" },
};

const LEVEL_THEMES: Record<number, { headerBg: string; accent: string }> = {
  0: { headerBg: "bg-slate-600",   accent: "bg-slate-50" },
  1: { headerBg: "bg-amber-500",   accent: "bg-amber-50" },
  2: { headerBg: "bg-sky-600",     accent: "bg-sky-50" },
  3: { headerBg: "bg-emerald-600", accent: "bg-emerald-50" },
  4: { headerBg: "bg-violet-600",  accent: "bg-violet-50" },
  5: { headerBg: "bg-rose-600",    accent: "bg-rose-50" },
};

function bodyPartBadge(bp: string) {
  const found = BODY_PARTS.find((b) => b.value === bp);
  return found ? found.color : "bg-slate-100 text-slate-600";
}

// ── Shared Components ──────────────────────────────────────────

function CategorySelector({
  categories,
  active,
  onChange,
}: {
  categories: any[];
  active: string;
  onChange: (code: string) => void;
}) {
  return (
    <div className="flex gap-2">
      {categories.map((c: any) => {
        const styles = CAT_BUTTON_STYLES[c.code] || CAT_BUTTON_STYLES.fc;
        const isActive = active === c.code;
        return (
          <button
            key={c.code}
            onClick={() => onChange(c.code)}
            className={cn(
              "px-4 py-2 rounded-xl text-sm font-semibold border transition-all",
              isActive ? styles.active : styles.inactive
            )}
          >
            <span className="font-bold uppercase">{c.code}</span>
            <span className="ml-1.5 text-xs font-normal opacity-75 hidden sm:inline">
              {c.name}
            </span>
          </button>
        );
      })}
    </div>
  );
}

function TabSkeleton({ rows = 5 }: { rows?: number }) {
  return (
    <div className="card overflow-hidden">
      <div className="px-4 py-3 bg-slate-50 border-b border-slate-100">
        <div className="skeleton h-5 w-36" />
      </div>
      {Array.from({ length: rows }).map((_, i) => (
        <div key={i} className="px-4 py-2.5 border-b border-slate-50 flex items-center gap-3">
          <div className="skeleton h-3 w-5" />
          <div className="skeleton h-3 w-32" />
          <div className="skeleton h-3 w-12 ml-auto" />
        </div>
      ))}
    </div>
  );
}

// ── Information Guide ──────────────────────────────────────────

function GuidePanel() {
  const [open, setOpen] = useState(false);

  return (
    <div className="rounded-xl border border-sky-200 bg-sky-50/50 overflow-hidden">
      <button
        onClick={() => setOpen(!open)}
        className="w-full flex items-center gap-3 px-5 py-3 text-left hover:bg-sky-50 transition-colors"
      >
        <Info className="h-5 w-5 text-sky-600 shrink-0" />
        <div className="flex-1">
          <p className="font-semibold text-sm text-sky-900">Panduan Digital Library</p>
          <p className="text-xs text-sky-600">Klik untuk melihat panduan cara pengisian data</p>
        </div>
        <ChevronDown className={cn("h-4 w-4 text-sky-400 transition-transform", open && "rotate-180")} />
      </button>

      {open && (
        <div className="px-5 pb-5 pt-1 border-t border-sky-200 space-y-5">
          {/* Alur Kerja */}
          <div>
            <h4 className="text-sm font-bold text-slate-800 mb-2">Alur Pengisian Data</h4>
            <div className="grid grid-cols-1 sm:grid-cols-4 gap-2">
              {[
                { step: "1", title: "Tambah Gerakan", desc: "Buat data gerakan di tab Movements dengan nama, body part, dan kategori." },
                { step: "2", title: "Isi Menu Program", desc: "Masukkan gerakan ke setiap level (0-5) per kategori. Ini adalah tahapan utama deteksi." },
                { step: "3", title: "Isi Isolate", desc: "Tentukan gerakan individual per posisi (Duduk / Berdiri) untuk latihan terfokus." },
                { step: "4", title: "Isi Dynamic", desc: "Buat pasangan gerakan Upper + Lower body yang dilakukan bergantian." },
              ].map((s) => (
                <div key={s.step} className="rounded-lg bg-white border border-sky-100 p-3">
                  <div className="flex items-center gap-2 mb-1.5">
                    <span className="w-5 h-5 rounded-full bg-sky-600 text-white text-[10px] font-bold flex items-center justify-center shrink-0">
                      {s.step}
                    </span>
                    <p className="text-xs font-bold text-slate-800">{s.title}</p>
                  </div>
                  <p className="text-[11px] text-slate-500 leading-relaxed">{s.desc}</p>
                </div>
              ))}
            </div>
          </div>

          {/* 3 Kategori */}
          <div>
            <h4 className="text-sm font-bold text-slate-800 mb-2">3 Kategori Latihan</h4>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-2">
              <div className="rounded-lg bg-indigo-50 border border-indigo-200 p-3">
                <p className="text-xs font-bold text-indigo-700 mb-1">FC — Functional Conditioning</p>
                <p className="text-[11px] text-indigo-600/80 leading-relaxed">Pola gerakan fungsional, stabilitas sendi, dan mobilitas progresif.</p>
              </div>
              <div className="rounded-lg bg-rose-50 border border-rose-200 p-3">
                <p className="text-xs font-bold text-rose-700 mb-1">CC — Cardio Conditioning</p>
                <p className="text-[11px] text-rose-600/80 leading-relaxed">Daya tahan kardiovaskular dan latihan aerobik.</p>
              </div>
              <div className="rounded-lg bg-teal-50 border border-teal-200 p-3">
                <p className="text-xs font-bold text-teal-700 mb-1">MC — Metabolic Conditioning</p>
                <p className="text-[11px] text-teal-600/80 leading-relaxed">Pembentukan otot dengan resistance band, bodyweight, dan core.</p>
              </div>
            </div>
          </div>

          {/* 6 Level */}
          <div>
            <h4 className="text-sm font-bold text-slate-800 mb-2">6 Level Progresif</h4>
            <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-2">
              {[
                { n: 0, name: "Berbaring", desc: "Bed-bound", color: "bg-slate-600" },
                { n: 1, name: "Duduk", desc: "Seated", color: "bg-amber-500" },
                { n: 2, name: "Berdiri", desc: "Standing", color: "bg-sky-600" },
                { n: 3, name: "Jalan Terbatas", desc: "Limited walk", color: "bg-emerald-600" },
                { n: 4, name: "Jalan Normal", desc: "Normal walk", color: "bg-violet-600" },
                { n: 5, name: "Dynamic BPM", desc: "Full dynamic", color: "bg-rose-600" },
              ].map((l) => (
                <div key={l.n} className="rounded-lg overflow-hidden border border-slate-200">
                  <div className={cn("px-2.5 py-1.5 text-white text-center", l.color)}>
                    <p className="text-[10px] font-bold">Level {l.n}</p>
                  </div>
                  <div className="px-2.5 py-2 bg-white text-center">
                    <p className="text-[11px] font-semibold text-slate-800">{l.name}</p>
                    <p className="text-[10px] text-slate-400">{l.desc}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Body Parts */}
          <div>
            <h4 className="text-sm font-bold text-slate-800 mb-2">Bagian Tubuh</h4>
            <div className="flex gap-2">
              <span className="px-3 py-1.5 rounded-lg bg-blue-100 text-blue-700 text-xs font-medium">Upper — Tubuh bagian atas (tangan, bahu, dada)</span>
              <span className="px-3 py-1.5 rounded-lg bg-emerald-100 text-emerald-700 text-xs font-medium">Lower — Tubuh bagian bawah (kaki, paha, lutut)</span>
              <span className="px-3 py-1.5 rounded-lg bg-amber-100 text-amber-700 text-xs font-medium">Core — Otot inti (perut, punggung bawah)</span>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// ── Main Page ───────────────────────────────────────────────────

export default function DigitalLibraryPage() {
  const [tab, setTab] = useState<TabKey>("movements");

  return (
    <div className="space-y-5">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-slate-900">Digital Library</h1>
        <p className="text-sm text-slate-500 mt-1">
          Master data gerakan fitness — kategorisasi, level, dan tahapan latihan
        </p>
      </div>

      {/* Guide */}
      <GuidePanel />

      {/* Tabs */}
      <div className="flex gap-1 border-b border-slate-200">
        {TABS.map((t) => (
          <button
            key={t.key}
            onClick={() => setTab(t.key)}
            className={cn(
              "px-4 py-2.5 text-sm font-medium border-b-2 transition-colors -mb-px",
              tab === t.key
                ? "border-sf-deepNavy text-sf-deepNavy"
                : "border-transparent text-slate-500 hover:text-slate-700"
            )}
          >
            {t.label}
          </button>
        ))}
      </div>

      {/* Tab Content */}
      {tab === "movements" && <MovementsTab />}
      {tab === "menu"      && <MenuTab />}
      {tab === "isolate"   && <IsolateTab />}
      {tab === "dynamic"   && <DynamicTab />}
    </div>
  );
}

// ════════════════════════════════════════════════════════════════
//  MOVEMENTS TAB — Full CRUD
// ════════════════════════════════════════════════════════════════

function MovementsTab() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState("");
  const [bodyPartFilter, setBodyPartFilter] = useState("");
  const [categoryFilter, setCategoryFilter] = useState("");
  const [createOpen, setCreateOpen] = useState(false);
  const [editTarget, setEditTarget] = useState<any>(null);
  const [deleteTarget, setDeleteTarget] = useState<any>(null);
  const [previewTarget, setPreviewTarget] = useState<any>(null);

  const { data: catData } = useDLCategories();
  const categories = (catData?.data ?? []) as any[];

  const { data, isLoading } = useDLMovements({
    page, limit: 20, search,
    body_part: bodyPartFilter || undefined,
    category: categoryFilter || undefined,
  });
  const movements = (data?.data ?? []) as any[];
  const meta = data?.meta;

  const deleteMutation = useDeleteDLMovement();

  const columns: Column<any>[] = [
    {
      key: "name",
      label: "Name",
      sortable: true,
      render: (row) => (
        <div className="flex items-center gap-3">
          <div className="h-9 w-9 rounded-lg bg-sf-iceBlue flex items-center justify-center shrink-0">
            {row.image_url ? (
              <img src={row.image_url} alt="" className="h-9 w-9 rounded-lg object-cover" />
            ) : (
              <BookOpen className="h-4 w-4 text-sf-systemBlue" />
            )}
          </div>
          <div>
            <p className="font-medium text-slate-900">{row.name}</p>
          </div>
        </div>
      ),
    },
    {
      key: "type",
      label: "Type",
      render: (row) => (
        <span className="px-2 py-0.5 rounded-full text-xs font-semibold capitalize bg-indigo-50 text-indigo-700">
          {row.type || "—"}
        </span>
      ),
    },
    {
      key: "pattern",
      label: "Pattern",
      render: (row) => (
        <span className="text-xs text-slate-600">{row.pattern || "—"}</span>
      ),
    },
    {
      key: "level",
      label: "Level",
      render: (row) => (
        <span className="px-2 py-0.5 rounded-full text-xs font-semibold bg-amber-50 text-amber-700">
          Level {row.level || "—"}
        </span>
      ),
    },
    {
      key: "body_part",
      label: "Body Part",
      render: (row) => (
        <span className={cn("px-2 py-0.5 rounded-full text-xs font-medium capitalize", bodyPartBadge(row.body_part))}>
          {row.body_part}
        </span>
      ),
    },
    {
      key: "categories",
      label: "Categories",
      render: (row) => (
        <div className="flex gap-1">
          {row.categories?.map((c: string) => (
            <span key={c} className={cn("px-1.5 py-0.5 rounded text-[10px] font-bold uppercase", CATEGORY_COLORS[c] || "bg-slate-100")}>
              {c}
            </span>
          ))}
        </div>
      ),
    },
    {
      key: "media",
      label: "Media",
      render: (row) => (
        <div className="flex gap-2">
          {row.video_url_male && (
            <div className="flex items-center gap-1 text-[10px] font-bold text-blue-600 bg-blue-50 px-1.5 py-0.5 rounded">
              <Video className="h-3 w-3" /> Male
            </div>
          )}
          {row.video_url_female && (
            <div className="flex items-center gap-1 text-[10px] font-bold text-rose-600 bg-rose-50 px-1.5 py-0.5 rounded">
              <Video className="h-3 w-3" /> Female
            </div>
          )}
          {row.image_url && <Image className="h-4 w-4 text-slate-400" />}
          {!row.video_url_male && !row.video_url_female && !row.image_url && <span className="text-xs text-slate-300">—</span>}
        </div>
      ),
    },
    {
      key: "actions",
      label: "",
      className: "w-32",
      render: (row) => (
        <div className="flex items-center gap-1" onClick={(e) => e.stopPropagation()}>
          {(row.video_url_male || row.video_url_female) && (
            <button
              onClick={() => setPreviewTarget(row)}
              className="p-1.5 rounded-lg hover:bg-violet-50 text-slate-400 hover:text-violet-600"
              title="Preview Video"
            >
              <Eye className="h-3.5 w-3.5" />
            </button>
          )}
          <button
            onClick={() => setEditTarget(row)}
            className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400 hover:text-sf-deepNavy"
          >
            <Pencil className="h-3.5 w-3.5" />
          </button>
          <button
            onClick={() => setDeleteTarget(row)}
            className="p-1.5 rounded-lg hover:bg-rose-50 text-slate-400 hover:text-rose-600"
          >
            <Trash2 className="h-3.5 w-3.5" />
          </button>
        </div>
      ),
    },
  ];

  return (
    <>
      {/* Filters */}
      <div className="flex items-center gap-3 flex-wrap">
        <SearchInput value={search} onChange={(v) => { setSearch(v); setPage(1); }} placeholder="Search movements..." />
        <SearchableSelect
          options={[{ value: "", label: "All Body Parts" }, ...BODY_PARTS.map((b) => ({ value: b.value, label: b.label }))]}
          value={bodyPartFilter}
          onChange={(v) => { setBodyPartFilter(v); setPage(1); }}
          placeholder="All Body Parts"
          className="w-48"
        />
        <SearchableSelect
          options={[{ value: "", label: "All Categories" }, ...categories.map((c: any) => ({ value: c.code, label: c.name }))]}
          value={categoryFilter}
          onChange={(v) => { setCategoryFilter(v); setPage(1); }}
          placeholder="All Categories"
          className="w-48"
        />
        <div className="flex-1" />
        <button onClick={() => setCreateOpen(true)} className="btn-primary">
          <Plus className="h-4 w-4" /> Add Movement
        </button>
      </div>

      {/* Table */}
      {movements.length === 0 && !isLoading ? (
        <EmptyState
          icon={BookOpen}
          title={search ? "No movements match" : "No movements yet"}
          description={search ? "Try a different search term" : "Add your first movement to the digital library."}
          action={!search ? <button onClick={() => setCreateOpen(true)} className="btn-primary"><Plus className="h-4 w-4" /> Add Movement</button> : undefined}
        />
      ) : (
        <DataTable
          columns={columns}
          data={movements}
          loading={isLoading}
          page={page}
          pageSize={20}
          totalPages={meta?.total_pages ?? 1}
          total={meta?.total ?? 0}
          onPageChange={setPage}
        />
      )}

      {/* Create Modal */}
      {createOpen && <MovementFormModal onClose={() => setCreateOpen(false)} />}

      {/* Edit Modal */}
      {editTarget && <MovementFormModal movement={editTarget} onClose={() => setEditTarget(null)} />}

      {/* Delete Confirm */}
      <ConfirmDialog
        open={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        onConfirm={() => {
          deleteMutation.mutate(deleteTarget.id, { onSuccess: () => setDeleteTarget(null) });
        }}
        title="Delete Movement"
        description={`Are you sure you want to delete "${deleteTarget?.name}"? This will also remove it from all menu, isolate, and dynamic items.`}
        confirmLabel="Delete"
        variant="danger"
        loading={deleteMutation.isPending}
      />

      {/* Video Preview Modal */}
      {previewTarget && <VideoPreviewModal movement={previewTarget} onClose={() => setPreviewTarget(null)} />}
    </>
  );
}

// ════════════════════════════════════════════════════════════════
//  MOVEMENT FORM MODAL (Create / Edit)
// ════════════════════════════════════════════════════════════════

function MovementFormModal({ movement, onClose }: { movement?: any; onClose: () => void }) {
  const isEdit = !!movement;
  const createMutation = useCreateDLMovement();
  const updateMutation = useUpdateDLMovement();
  const loading = createMutation.isPending || updateMutation.isPending;

  const [name, setName] = useState(movement?.name ?? "");
  const [bodyPart, setBodyPart] = useState(movement?.body_part ?? "upper");
  const [cats, setCats] = useState<string[]>(movement?.categories ?? []);
  const [videoUrlMale, setVideoUrlMale] = useState(movement?.video_url_male ?? "");
  const [videoUrlFemale, setVideoUrlFemale] = useState(movement?.video_url_female ?? "");
  const [imageUrl, setImageUrl] = useState(movement?.image_url ?? "");
  const [type, setType] = useState(movement?.type ?? "sit");
  const [pattern, setPattern] = useState(movement?.pattern ?? "Isolate FC");
  const [level, setLevel] = useState<number>(movement?.level ?? 1);
  const [instructions, setInstructions] = useState<string[]>(
    movement?.instructions?.length ? movement.instructions : [""]
  );

  function toggleCat(c: string) {
    setCats((prev) => prev.includes(c) ? prev.filter((x) => x !== c) : [...prev, c]);
  }

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim() || cats.length === 0) return;

    const payload = {
      name: name.trim(),
      body_part: bodyPart,
      categories: cats,
      video_url_male: videoUrlMale || undefined,
      video_url_female: videoUrlFemale || undefined,
      image_url: imageUrl || undefined,
      instructions: instructions.filter((s) => s.trim()),
      type,
      pattern,
      level: Number(level),
    };

    if (isEdit) {
      updateMutation.mutate({ id: movement.id, data: payload }, { onSuccess: () => onClose() });
    } else {
      createMutation.mutate(payload, { onSuccess: () => onClose() });
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center pt-[5vh] overflow-y-auto" onClick={onClose}>
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" />
      <div className="relative bg-white rounded-2xl shadow-xl max-w-2xl w-full mx-4 mb-12 animate-slide-in" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
          <h2 className="text-lg font-semibold text-slate-900">
            {isEdit ? "Edit Movement" : "Create Movement"}
          </h2>
          <button onClick={onClose} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400">
            <X className="h-5 w-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-5 max-h-[75vh] overflow-y-auto">
          {/* Name */}
          <div>
            <label className="label">Movement Name *</label>
            <input value={name} onChange={(e) => setName(e.target.value)} required className="input" placeholder="e.g. Arm Rotation" autoFocus />
          </div>

          {/* Body Part */}
          <div>
            <label className="label">Body Part *</label>
            <div className="flex gap-2">
              {BODY_PARTS.map((bp) => (
                <button
                  key={bp.value}
                  type="button"
                  onClick={() => setBodyPart(bp.value)}
                  className={cn(
                    "px-4 py-2 rounded-lg text-sm font-medium transition-colors",
                    bodyPart === bp.value
                      ? "bg-sf-deepNavy text-white"
                      : "bg-slate-50 text-slate-600 hover:bg-slate-100"
                  )}
                >
                  {bp.label}
                </button>
              ))}
            </div>
          </div>

          {/* Categories */}
          <div>
            <label className="label">Categories *</label>
            <div className="flex gap-2">
              {[
                { code: "fc", label: "Functional Conditioning" },
                { code: "cc", label: "Cardio Conditioning" },
                { code: "mc", label: "Metabolic Conditioning" },
              ].map((c) => (
                <button
                  key={c.code}
                  type="button"
                  onClick={() => toggleCat(c.code)}
                  className={cn(
                    "px-3 py-2 rounded-lg text-xs font-medium transition-colors",
                    cats.includes(c.code)
                      ? "bg-sf-deepNavy text-white"
                      : "bg-slate-50 text-slate-600 hover:bg-slate-100"
                  )}
                >
                  <span className="font-bold uppercase">{c.code}</span> — {c.label}
                </button>
              ))}
            </div>
          </div>

          {/* Video URLs + Image URL */}
          <div className="grid grid-cols-1 gap-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="label">Video URL (Male)</label>
                <input value={videoUrlMale} onChange={(e) => setVideoUrlMale(e.target.value)} className="input" placeholder="https://youtube.com/..." />
              </div>
              <div>
                <label className="label">Video URL (Female)</label>
                <input value={videoUrlFemale} onChange={(e) => setVideoUrlFemale(e.target.value)} className="input" placeholder="https://youtube.com/..." />
              </div>
            </div>
            <div>
              <label className="label">Image URL</label>
              <input value={imageUrl} onChange={(e) => setImageUrl(e.target.value)} className="input" placeholder="https://..." />
            </div>
          </div>

          {/* Type + Level */}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Type *</label>
              <div className="flex gap-2">
                {[
                  { value: "sit", label: "Sit" },
                  { value: "stand", label: "Stand" },
                  { value: "mat", label: "Mat" },
                ].map((item) => (
                  <button
                    key={item.value}
                    type="button"
                    onClick={() => setType(item.value)}
                    className={cn(
                      "flex-1 px-4 py-2 rounded-lg text-sm font-medium transition-colors border",
                      type === item.value
                        ? "bg-sf-deepNavy text-white border-sf-deepNavy"
                        : "bg-slate-50 text-slate-600 border-slate-200 hover:bg-slate-100"
                    )}
                  >
                    {item.label}
                  </button>
                ))}
              </div>
            </div>
            <div>
              <label className="label">Level *</label>
              <SearchableSelect
                options={[1, 2, 3, 4, 5, 6].map((l) => ({ value: String(l), label: `Level ${l}` }))}
                value={String(level)}
                onChange={(val) => setLevel(Number(val))}
                placeholder="Pilih Level..."
              />
            </div>
          </div>

          {/* Pattern */}
          <div>
            <label className="label">Pattern *</label>
            <SearchableSelect
              options={[
                "Isolate FC",
                "Dynamic FC",
                "Isolate CC",
                "Dynamic CC",
                "Metabolic Basic",
                "Metabolic Core",
              ].map((p) => ({ value: p, label: p }))}
              value={pattern}
              onChange={(val) => setPattern(val)}
              placeholder="Pilih Pattern..."
            />
          </div>

          {/* Instructions */}
          <div>
            <div className="flex items-center justify-between mb-1.5">
              <label className="label mb-0">Instructions</label>
              <button type="button" onClick={() => setInstructions([...instructions, ""])} className="text-xs text-sf-deepNavy hover:text-sf-deepNavy font-medium">
                + Add Step
              </button>
            </div>
            <div className="space-y-2">
              {instructions.map((step, i) => (
                <div key={i} className="flex items-center gap-2">
                  <span className="w-6 h-6 rounded-full bg-slate-100 text-slate-500 flex items-center justify-center text-xs font-bold shrink-0">
                    {i + 1}
                  </span>
                  <input
                    value={step}
                    onChange={(e) => setInstructions(instructions.map((s, idx) => idx === i ? e.target.value : s))}
                    className="input flex-1"
                    placeholder={`Step ${i + 1}...`}
                  />
                  {instructions.length > 1 && (
                    <button type="button" onClick={() => setInstructions(instructions.filter((_, idx) => idx !== i))} className="p-1 text-slate-400 hover:text-rose-500">
                      <X className="h-4 w-4" />
                    </button>
                  )}
                </div>
              ))}
            </div>
          </div>

          {/* Submit */}
          <div className="flex justify-end gap-3 pt-2">
            <button type="button" onClick={onClose} className="btn-secondary">Cancel</button>
            <button type="submit" disabled={loading || !name.trim() || cats.length === 0} className="btn-primary">
              {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : isEdit ? <Pencil className="h-4 w-4" /> : <Plus className="h-4 w-4" />}
              {loading ? "Saving..." : isEdit ? "Update Movement" : "Create Movement"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

// ════════════════════════════════════════════════════════════════
//  VIDEO PREVIEW MODAL
// ════════════════════════════════════════════════════════════════

function extractYouTubeId(url: string): string | null {
  if (!url) return null;
  // Handle youtu.be/XXXX
  const shortMatch = url.match(/youtu\.be\/([a-zA-Z0-9_-]{11})/);
  if (shortMatch) return shortMatch[1];
  // Handle youtube.com/watch?v=XXXX
  const longMatch = url.match(/[?&]v=([a-zA-Z0-9_-]{11})/);
  if (longMatch) return longMatch[1];
  // Handle youtube.com/embed/XXXX
  const embedMatch = url.match(/embed\/([a-zA-Z0-9_-]{11})/);
  if (embedMatch) return embedMatch[1];
  return null;
}

function VideoPreviewModal({ movement, onClose }: { movement: any; onClose: () => void }) {
  const maleId = extractYouTubeId(movement.video_url_male || "");
  const femaleId = extractYouTubeId(movement.video_url_female || "");
  const hasBoth = maleId && femaleId;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center" onClick={onClose}>
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" />
      <div
        className={cn(
          "relative bg-white rounded-2xl shadow-2xl mx-4 mb-12 animate-slide-in overflow-hidden",
          hasBoth ? "max-w-5xl w-full" : "max-w-2xl w-full"
        )}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
          <div className="flex items-center gap-3">
            <div className="h-9 w-9 rounded-lg bg-violet-100 flex items-center justify-center">
              <Video className="h-4.5 w-4.5 text-violet-600" />
            </div>
            <div>
              <h2 className="text-lg font-semibold text-slate-900">{movement.name}</h2>
              <div className="flex items-center gap-2 mt-0.5">
                <span className={cn("px-2 py-0.5 rounded-full text-[10px] font-medium capitalize", bodyPartBadge(movement.body_part))}>
                  {movement.body_part}
                </span>
                {movement.categories?.map((c: string) => (
                  <span key={c} className={cn("px-1.5 py-0.5 rounded text-[10px] font-bold uppercase", CATEGORY_COLORS[c] || "bg-slate-100")}>
                    {c}
                  </span>
                ))}
              </div>
            </div>
          </div>
          <button onClick={onClose} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400 hover:text-slate-600 transition-colors">
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* Video Content */}
        <div className={cn("p-6", hasBoth ? "grid grid-cols-2 gap-5" : "")}>
          {maleId && (
            <div>
              <div className="flex items-center gap-2 mb-3">
                <div className="h-6 w-6 rounded-full bg-blue-100 flex items-center justify-center">
                  <span className="text-[10px] font-bold text-blue-600">M</span>
                </div>
                <p className="text-sm font-semibold text-slate-700">Male Version</p>
              </div>
              <div className="relative w-full rounded-xl overflow-hidden bg-slate-900 shadow-lg" style={{ paddingBottom: "56.25%" }}>
                <iframe
                  className="absolute inset-0 w-full h-full"
                  src={`https://www.youtube.com/embed/${maleId}?rel=0`}
                  title={`${movement.name} — Male`}
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowFullScreen
                />
              </div>
              <a
                href={movement.video_url_male}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-1.5 mt-2.5 text-xs text-blue-600 hover:text-blue-800 transition-colors"
              >
                <Video className="h-3 w-3" /> Open in YouTube ↗
              </a>
            </div>
          )}
          {femaleId && (
            <div>
              <div className="flex items-center gap-2 mb-3">
                <div className="h-6 w-6 rounded-full bg-rose-100 flex items-center justify-center">
                  <span className="text-[10px] font-bold text-rose-600">F</span>
                </div>
                <p className="text-sm font-semibold text-slate-700">Female Version</p>
              </div>
              <div className="relative w-full rounded-xl overflow-hidden bg-slate-900 shadow-lg" style={{ paddingBottom: "56.25%" }}>
                <iframe
                  className="absolute inset-0 w-full h-full"
                  src={`https://www.youtube.com/embed/${femaleId}?rel=0`}
                  title={`${movement.name} — Female`}
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowFullScreen
                />
              </div>
              <a
                href={movement.video_url_female}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-1.5 mt-2.5 text-xs text-rose-600 hover:text-rose-800 transition-colors"
              >
                <Video className="h-3 w-3" /> Open in YouTube ↗
              </a>
            </div>
          )}
          {!maleId && !femaleId && (
            <div className="text-center py-12">
              <Video className="h-10 w-10 text-slate-300 mx-auto mb-3" />
              <p className="text-sm text-slate-500">No video available for this movement</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

// ════════════════════════════════════════════════════════════════
//  MENU TAB — 2-column grid with compact level cards
// ════════════════════════════════════════════════════════════════

function MenuTab() {
  const [category, setCategory] = useState("fc");
  const [level, setLevel] = useState<number | undefined>(undefined);
  const [collapsedLevels, setCollapsedLevels] = useState<string[]>([]);

  const { data: catData } = useDLCategories();
  const { data: levelData } = useDLLevels();
  const { data, isLoading } = useDLMenuItems(category, level);

  const categories = (catData?.data ?? []) as any[];
  const levels = (levelData?.data ?? []) as any[];
  const items = (data?.data ?? []) as any[];

  // Group by level_id, sorted by level_number
  const grouped = items.reduce((acc: Record<string, any[]>, item: any) => {
    const key = item.level_id;
    if (!acc[key]) acc[key] = [];
    acc[key].push(item);
    return acc;
  }, {});

  const sortedGroups = Object.entries(grouped).sort(([aId], [bId]) => {
    const aLevel = levels.find((l: any) => l.id === aId);
    const bLevel = levels.find((l: any) => l.id === bId);
    return (aLevel?.level_number ?? 0) - (bLevel?.level_number ?? 0);
  });

  function toggleLevel(levelId: string) {
    setCollapsedLevels((prev) =>
      prev.includes(levelId) ? prev.filter((id) => id !== levelId) : [...prev, levelId]
    );
  }

  return (
    <div className="space-y-4">
      {/* Filters */}
      <div className="flex items-center gap-3 flex-wrap">
        <CategorySelector categories={categories} active={category} onChange={setCategory} />
        <SearchableSelect
          options={[{ value: "", label: "Semua Level" }, ...levels.map((l: any) => ({ value: String(l.level_number), label: `Level ${l.level_number} — ${l.name_id}` }))]}
          value={level != null ? String(level) : ""}
          onChange={(v) => setLevel(v ? Number(v) : undefined)}
          placeholder="Semua Level"
          className="w-56"
        />
      </div>

      {/* Content — 2-column grid */}
      {isLoading ? (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-3">
          <TabSkeleton rows={5} />
          <TabSkeleton rows={5} />
          <TabSkeleton rows={5} />
          <TabSkeleton rows={5} />
        </div>
      ) : items.length === 0 ? (
        <EmptyState icon={BookOpen} title="Belum ada data" description="Tidak ada gerakan untuk kategori dan level ini." />
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-3">
          {sortedGroups.map(([levelId, levelItems]) => {
            const levelInfo = levels.find((l: any) => l.id === levelId);
            const levelNum = levelInfo?.level_number ?? 0;
            const theme = LEVEL_THEMES[levelNum] || LEVEL_THEMES[0];
            const isExpanded = !collapsedLevels.includes(levelId);
            const sorted = (levelItems as any[]).sort((a, b) => (a.sort_order ?? 0) - (b.sort_order ?? 0));

            return (
              <div key={levelId} className="rounded-xl overflow-hidden border border-slate-200 flex flex-col">
                {/* Level Header */}
                <button
                  onClick={() => toggleLevel(levelId)}
                  className={cn(
                    "w-full flex items-center gap-3 px-4 py-3 text-white transition-colors",
                    theme.headerBg
                  )}
                >
                  <span className="flex items-center justify-center w-8 h-8 rounded-lg bg-white/20 text-sm font-bold shrink-0">
                    {levelNum}
                  </span>
                  <div className="flex-1 text-left min-w-0">
                    <p className="font-semibold text-sm leading-tight">{levelInfo?.name_id}</p>
                    {levelInfo?.description && (
                      <p className="text-[11px] text-white/70 truncate">{levelInfo.description}</p>
                    )}
                  </div>
                  <span className="text-[11px] text-white/80 font-medium shrink-0">
                    {sorted.length}
                  </span>
                  <ChevronDown
                    className={cn(
                      "h-3.5 w-3.5 shrink-0 transition-transform",
                      isExpanded && "rotate-180"
                    )}
                  />
                </button>

                {/* Compact movement list */}
                {isExpanded && (
                  <div className="divide-y divide-slate-50 max-h-[360px] overflow-y-auto flex-1">
                    {sorted.map((item: any) => (
                      <div
                        key={item.id}
                        className="flex items-center gap-2 px-3 py-2 hover:bg-slate-50/80 transition-colors text-sm"
                      >
                        <span className="text-[11px] text-slate-400 w-5 text-right shrink-0 font-medium">
                          {item.sort_order}
                        </span>
                        <span className="flex-1 font-medium text-slate-900 truncate">
                          {item.movement?.name}
                        </span>
                        <span className={cn(
                          "px-1.5 py-0.5 rounded-full text-[10px] font-medium capitalize shrink-0",
                          bodyPartBadge(item.body_part)
                        )}>
                          {item.body_part}
                        </span>
                        {item.movement?.video_url_male && (
                          <Video className="h-3 w-3 text-blue-400 shrink-0" />
                        )}
                        {item.movement?.video_url_female && (
                          <Video className="h-3 w-3 text-rose-400 shrink-0" />
                        )}
                      </div>
                    ))}
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

// ════════════════════════════════════════════════════════════════
//  ISOLATE TAB — 2-column grid (Duduk | Berdiri)
// ════════════════════════════════════════════════════════════════

const POSITION_THEMES = {
  sit: {
    headerBg: "bg-amber-500",
    label: "Duduk (Sit)",
    sublabel: "Gerakan dalam posisi duduk",
  },
  stand: {
    headerBg: "bg-sky-600",
    label: "Berdiri (Stand)",
    sublabel: "Gerakan dalam posisi berdiri",
  },
} as const;

function IsolateTab() {
  const [category, setCategory] = useState("fc");
  const [position, setPosition] = useState<string | undefined>(undefined);

  const { data: catData } = useDLCategories();
  const { data, isLoading } = useDLIsolateItems(category, position);

  const categories = (catData?.data ?? []) as any[];
  const items = (data?.data ?? []) as any[];

  const sitItems = items.filter((i: any) => i.position === "sit");
  const standItems = items.filter((i: any) => i.position === "stand");

  function renderPositionCard(posItems: any[], pos: "sit" | "stand") {
    const theme = POSITION_THEMES[pos];
    const sorted = [...posItems].sort((a: any, b: any) => (a.sort_order ?? 0) - (b.sort_order ?? 0));

    const upperCount = sorted.filter((i: any) => i.movement?.body_part === "upper").length;
    const lowerCount = sorted.filter((i: any) => i.movement?.body_part === "lower").length;

    return (
      <div className="rounded-xl overflow-hidden border border-slate-200 flex flex-col">
        {/* Position Header */}
        <div className={cn("px-4 py-3 text-white", theme.headerBg)}>
          <div className="flex items-center justify-between">
            <div>
              <p className="font-semibold text-sm">{theme.label}</p>
              <p className="text-[11px] text-white/70">{theme.sublabel}</p>
            </div>
            <div className="flex items-center gap-1.5">
              {upperCount > 0 && (
                <span className="px-2 py-0.5 rounded-full bg-white/20 text-[10px] font-medium">
                  Upper {upperCount}
                </span>
              )}
              {lowerCount > 0 && (
                <span className="px-2 py-0.5 rounded-full bg-white/20 text-[10px] font-medium">
                  Lower {lowerCount}
                </span>
              )}
            </div>
          </div>
        </div>

        {/* Movement list */}
        <div className="divide-y divide-slate-50 max-h-[450px] overflow-y-auto flex-1">
          {sorted.map((item: any) => (
            <div
              key={item.id}
              className="flex items-center gap-2 px-3 py-2 hover:bg-slate-50/80 transition-colors text-sm"
            >
              <span className="text-[11px] text-slate-400 w-5 text-right shrink-0 font-medium">
                {item.sort_order}
              </span>
              <span className="flex-1 font-medium text-slate-900 truncate">
                {item.movement?.name}
              </span>
              <span className={cn(
                "px-1.5 py-0.5 rounded-full text-[10px] font-medium capitalize shrink-0",
                bodyPartBadge(item.movement?.body_part)
              )}>
                {item.movement?.body_part}
              </span>
              {item.movement?.video_url_male && (
                <Video className="h-3 w-3 text-blue-400 shrink-0" />
              )}
              {item.movement?.video_url_female && (
                <Video className="h-3 w-3 text-rose-400 shrink-0" />
              )}
            </div>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {/* Filters */}
      <div className="flex items-center gap-3 flex-wrap">
        <CategorySelector categories={categories} active={category} onChange={setCategory} />
        <SearchableSelect
          options={[{ value: "", label: "Semua Posisi" }, { value: "sit", label: "Duduk (Sit)" }, { value: "stand", label: "Berdiri (Stand)" }]}
          value={position ?? ""}
          onChange={(v) => setPosition(v || undefined)}
          placeholder="Semua Posisi"
          className="w-48"
        />
      </div>

      {/* Content — 2-column grid */}
      {isLoading ? (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          <TabSkeleton rows={6} />
          <TabSkeleton rows={6} />
        </div>
      ) : items.length === 0 ? (
        <EmptyState icon={BookOpen} title="Belum ada data" description="Tidak ada gerakan isolasi untuk kategori ini." />
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {sitItems.length > 0 && renderPositionCard(sitItems, "sit")}
          {standItems.length > 0 && renderPositionCard(standItems, "stand")}
        </div>
      )}
    </div>
  );
}

// ════════════════════════════════════════════════════════════════
//  DYNAMIC TAB — Paired upper + lower with color-coded columns
// ════════════════════════════════════════════════════════════════

function DynamicTab() {
  const [category, setCategory] = useState("fc");

  const { data: catData } = useDLCategories();
  const { data, isLoading } = useDLDynamicItems(category);

  const categories = (catData?.data ?? []) as any[];
  const items = (data?.data ?? []) as any[];

  return (
    <div className="space-y-4">
      {/* Filters + Legend */}
      <div className="flex items-center gap-3 flex-wrap">
        <CategorySelector categories={categories} active={category} onChange={setCategory} />
        <div className="flex-1" />
        <div className="flex items-center gap-4 text-sm">
          <span className="flex items-center gap-1.5">
            <span className="w-3 h-3 rounded bg-blue-200" />
            <span className="text-slate-500">Upper Body</span>
          </span>
          <span className="flex items-center gap-1.5">
            <span className="w-3 h-3 rounded bg-emerald-200" />
            <span className="text-slate-500">Lower Body</span>
          </span>
          <span className="text-sm font-medium text-slate-700">{items.length} pasangan</span>
        </div>
      </div>

      {/* Content */}
      {isLoading ? (
        <TabSkeleton rows={8} />
      ) : items.length === 0 ? (
        <EmptyState icon={BookOpen} title="Belum ada data" description="Tidak ada gerakan dynamic untuk kategori ini." />
      ) : (
        <div className="card overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr>
                  <th className="px-4 py-3 text-left font-semibold text-slate-500 w-16 bg-slate-50 border-b border-slate-100">
                    #
                  </th>
                  <th className="px-4 py-3 text-left font-semibold bg-blue-50 border-b border-blue-100">
                    <span className="flex items-center gap-2 text-blue-700">
                      <span className="w-2 h-2 rounded-full bg-blue-500" />
                      Upper Body
                    </span>
                  </th>
                  <th className="w-10 bg-slate-50 border-b border-slate-100" />
                  <th className="px-4 py-3 text-left font-semibold bg-emerald-50 border-b border-emerald-100">
                    <span className="flex items-center gap-2 text-emerald-700">
                      <span className="w-2 h-2 rounded-full bg-emerald-500" />
                      Lower Body
                    </span>
                  </th>
                </tr>
              </thead>
              <tbody>
                {items.map((item: any, idx: number) => (
                  <tr
                    key={item.id}
                    className={cn(
                      "transition-colors hover:bg-slate-50/50",
                      idx % 2 === 0 ? "bg-white" : "bg-slate-50/30"
                    )}
                  >
                    <td className="px-4 py-3 font-medium text-slate-400 border-r border-slate-50">
                      {item.sort_order}
                    </td>
                    <td className="px-4 py-3 bg-blue-50/20">
                      {item.upper_movement ? (
                        <span className="font-medium text-slate-900">{item.upper_movement.name}</span>
                      ) : (
                        <span className="text-slate-300 italic">—</span>
                      )}
                    </td>
                    <td className="text-center text-slate-300">
                      <ArrowLeftRight className="h-3.5 w-3.5 mx-auto" />
                    </td>
                    <td className="px-4 py-3 bg-emerald-50/20">
                      {item.lower_movement ? (
                        <span className="font-medium text-slate-900">{item.lower_movement.name}</span>
                      ) : (
                        <span className="text-slate-300 italic">—</span>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
}
