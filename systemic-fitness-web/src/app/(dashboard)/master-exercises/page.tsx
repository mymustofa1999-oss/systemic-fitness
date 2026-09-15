"use client";

import React, { useState } from "react";
import { Plus, Search, Video, Eye, Edit2, Archive, ArchiveRestore, Dumbbell, X } from "lucide-react";
import { useDLMovements, useCreateDLMovement, useUpdateDLMovement } from "@/hooks/useDigitalLibrary";
import { DataTable } from "@/components/shared/DataTable";
import { SearchInput } from "@/components/shared/SearchInput";
import { SearchableSelect } from "@/components/shared/SearchableSelect";
import { EmptyState } from "@/components/shared/EmptyState";
import { toast } from "@/stores/toastStore";

function Modal({ title, children, onClose, size = "md" }: { title: string, children: React.ReactNode, onClose: () => void, size?: "md" | "lg" }) {
  const maxWidth = size === "lg" ? "max-w-2xl" : "max-w-md";
  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center pt-[5vh] overflow-y-auto" onClick={onClose}>
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" />
      <div className={`relative bg-white rounded-2xl shadow-xl w-full mx-4 mb-12 animate-slide-in ${maxWidth}`} onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between p-4 border-b border-slate-100">
          <h2 className="text-lg font-bold text-slate-800">{title}</h2>
          <button onClick={onClose} className="p-1 text-slate-400 hover:text-slate-600 rounded-lg hover:bg-slate-100 transition-colors">
            <X className="h-5 w-5" />
          </button>
        </div>
        {children}
      </div>
    </div>
  );
}

const BODY_PARTS = [
  { value: "upper", label: "Upper Body" },
  { value: "lower", label: "Lower Body" },
  { value: "core", label: "Core" },
  { value: "whole body", label: "Whole Body" }
];

const GENDERS = [
  { value: "male", label: "Male" },
  { value: "female", label: "Female" },
  { value: "universal", label: "Universal" }
];

const STATUSES = [
  { value: "active", label: "Active" },
  { value: "inactive", label: "Inactive" }
];

export default function MasterExercisesPage() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState("");
  const [bodyPart, setBodyPart] = useState("");
  const [gender, setGender] = useState("");
  const [status, setStatus] = useState("");

  const { data, isLoading, refetch } = useDLMovements({
    page,
    limit: 20,
    search: search || undefined,
    body_part: bodyPart || undefined,
    target_gender: gender || undefined,
    status: status || undefined,
  });

  const movements = (data?.data as any[]) || [];
  const meta = data?.meta;

  const [createOpen, setCreateOpen] = useState(false);
  const [editMovement, setEditMovement] = useState<any>(null);
  const [viewMovement, setViewMovement] = useState<any>(null);
  const [previewTarget, setPreviewTarget] = useState<any>(null);

  const updateMut = useUpdateDLMovement();

  const handleToggleStatus = async (m: any) => {
    if (confirm(`Are you sure you want to ${m.is_active ? 'deactivate' : 'activate'} ${m.name}?`)) {
      try {
        await updateMut.mutateAsync({
          id: m.id,
          data: {
            name: m.name,
            body_part: m.body_part,
            categories: m.categories,
            target_gender: m.target_gender,
            is_active: !m.is_active,
            // Preserve other fields
            video_url_male: m.video_url_male || undefined,
            video_url_female: m.video_url_female || undefined,
            image_url: m.image_url || undefined,
            instructions: m.instructions || undefined,
            type: m.type || undefined,
            pattern: m.pattern || undefined,
            level: m.level || undefined,
            name_en: m.name_en || undefined,
            instructions_en: m.instructions_en || undefined,
            description_en: m.description_en || undefined,
          }
        });
        refetch();
      } catch (err: any) {
        // Error is handled in the hook's onError or toast
      }
    }
  };

  const columns = [
    {
      label: "Exercise",
      key: "name",
      render: (row: any) => (
        <div>
          <div className="font-medium text-slate-900">{row.name}</div>
          {row.name_en && <div className="text-xs text-slate-500">{row.name_en}</div>}
        </div>
      )
    },
    {
      label: "Body Part",
      key: "body_part",
      render: (row: any) => <span className="capitalize">{row.body_part}</span>
    },
    {
      label: "Gender",
      key: "target_gender",
      render: (row: any) => (
        <span className="capitalize px-2 py-0.5 bg-slate-100 text-slate-600 rounded text-xs font-medium">
          {row.target_gender || "Universal"}
        </span>
      )
    },
    {
      label: "Video",
      key: "video",
      render: (row: any) => (
        <div className="flex gap-2">
          {row.video_url_male && (
            <button onClick={() => setPreviewTarget(row)} className="flex items-center gap-1 text-[10px] font-bold text-blue-600 bg-blue-50 hover:bg-blue-100 px-1.5 py-0.5 rounded transition-colors">
              <Video className="h-3 w-3" /> Male
            </button>
          )}
          {row.video_url_female && (
            <button onClick={() => setPreviewTarget(row)} className="flex items-center gap-1 text-[10px] font-bold text-rose-600 bg-rose-50 hover:bg-rose-100 px-1.5 py-0.5 rounded transition-colors">
              <Video className="h-3 w-3" /> Female
            </button>
          )}
          {!row.video_url_male && !row.video_url_female && <span className="text-xs text-slate-300">—</span>}
        </div>
      )
    },
    {
      label: "Status",
      key: "is_active",
      render: (row: any) => (
        <span className={`px-2 py-1 rounded-full text-xs font-medium ${row.is_active ? 'bg-green-100 text-green-700' : 'bg-slate-100 text-slate-600'}`}>
          {row.is_active ? "Active" : "Inactive"}
        </span>
      )
    },
    {
      label: "Action",
      key: "id",
      render: (row: any) => (
        <div className="flex items-center gap-2">
          <button onClick={() => setViewMovement(row)} className="p-1 text-slate-400 hover:text-blue-600 transition-colors" title="View Details">
            <Eye className="h-4 w-4" />
          </button>
          <button onClick={() => setEditMovement(row)} className="p-1 text-slate-400 hover:text-amber-600 transition-colors" title="Edit">
            <Edit2 className="h-4 w-4" />
          </button>
          <button onClick={() => handleToggleStatus(row)} className={`p-1 transition-colors ${row.is_active ? 'text-slate-400 hover:text-red-600' : 'text-slate-400 hover:text-green-600'}`} title={row.is_active ? "Deactivate" : "Activate"}>
            {row.is_active ? <Archive className="h-4 w-4" /> : <ArchiveRestore className="h-4 w-4" />}
          </button>
        </div>
      )
    }
  ];

  return (
    <div className="space-y-6 max-w-7xl mx-auto pb-12">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Master Exercises</h1>
          <p className="text-slate-500 mt-1">Manage the core database of all movements across the platform.</p>
        </div>
        <button onClick={() => setCreateOpen(true)} className="btn-primary shrink-0">
          <Plus className="h-4 w-4" /> Add Exercise
        </button>
      </div>

      <div className="card p-4">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <SearchInput value={search} onChange={(v: any) => { setSearch(v); setPage(1); }} placeholder="Search exercises..." />
          <SearchableSelect options={[{value: "", label: "All Body Parts"}, ...BODY_PARTS]} value={bodyPart} onChange={(v: any) => { setBodyPart(v); setPage(1); }} placeholder="Body Part" />
          <SearchableSelect options={[{value: "", label: "All Genders"}, ...GENDERS]} value={gender} onChange={(v: any) => { setGender(v); setPage(1); }} placeholder="Gender" />
          <SearchableSelect options={[{value: "", label: "All Statuses"}, ...STATUSES]} value={status} onChange={(v: any) => { setStatus(v); setPage(1); }} placeholder="Status" />
        </div>
      </div>

      <div className="card overflow-hidden">
        {movements.length === 0 && !isLoading ? (
          <EmptyState
            icon={Dumbbell}
            title={search || bodyPart || gender || status ? "No exercises match" : "No master exercises yet"}
            description="Try adjusting your filters or add a new exercise."
          />
        ) : (
          <DataTable
            columns={columns}
            data={movements}
            loading={isLoading}
            page={page}
            totalPages={meta?.total_pages || 1}
            onPageChange={setPage}
          />
        )}
      </div>

      {createOpen && <MovementFormModal onClose={() => setCreateOpen(false)} onSaved={() => { setCreateOpen(false); refetch(); }} />}
      {editMovement && <MovementFormModal movement={editMovement} onClose={() => setEditMovement(null)} onSaved={() => { setEditMovement(null); refetch(); }} />}
      {viewMovement && <MovementDetailModal movement={viewMovement} onClose={() => setViewMovement(null)} />}
      {previewTarget && <VideoPreviewModal movement={previewTarget} onClose={() => setPreviewTarget(null)} />}
    </div>
  );
}

function MovementFormModal({ movement, onClose, onSaved }: { movement?: any, onClose: () => void, onSaved: () => void }) {
  const isEdit = !!movement;
  const [name, setName] = useState(movement?.name || "");
  const [nameEn, setNameEn] = useState(movement?.name_en || "");
  const [bodyPart, setBodyPart] = useState(movement?.body_part || "upper");
  const [targetGender, setTargetGender] = useState(movement?.target_gender || "universal");
  const [videoMale, setVideoMale] = useState(movement?.video_url_male || "");
  const [videoFemale, setVideoFemale] = useState(movement?.video_url_female || "");
  const [isActive, setIsActive] = useState(movement ? movement.is_active : true);

  const createMut = useCreateDLMovement();
  const updateMut = useUpdateDLMovement();

  const isSaving = createMut.isPending || updateMut.isPending;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) return toast.error("Name is required");

    const payload = {
      name: name.trim(),
      name_en: nameEn.trim() || null,
      body_part: bodyPart,
      target_gender: targetGender,
      video_url_male: videoMale.trim() || null,
      video_url_female: videoFemale.trim() || null,
      is_active: isActive,
      categories: movement?.categories || ["general"],
      instructions: movement?.instructions || [],
      // Preserve other fields by not sending them (undefined is dropped by JSON.stringify)
      image_url: movement?.image_url,
      type: movement?.type,
      pattern: movement?.pattern,
      level: movement?.level,
      instructions_en: movement?.instructions_en,
      description_en: movement?.description_en,
    };

    try {
      if (isEdit) {
        await updateMut.mutateAsync({ id: movement.id, data: payload });
      } else {
        await createMut.mutateAsync(payload);
      }
      onSaved();
    } catch (err) {}
  };

  return (
    <Modal title={isEdit ? "Edit Master Exercise" : "Add Master Exercise"} onClose={onClose} size="lg">
      <form onSubmit={handleSubmit} className="p-6 space-y-6 max-h-[80vh] overflow-y-auto">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Exercise Name (ID) *</label>
            <input type="text" className="input" value={name} onChange={e => setName(e.target.value)} required placeholder="e.g. Push Up" />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Exercise Name (EN)</label>
            <input type="text" className="input" value={nameEn} onChange={e => setNameEn(e.target.value)} placeholder="e.g. Push Up" />
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Body Part *</label>
            <select className="input" value={bodyPart} onChange={e => setBodyPart(e.target.value)}>
              {BODY_PARTS.map(b => <option key={b.value} value={b.value}>{b.label}</option>)}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Target Gender *</label>
            <select className="input" value={targetGender} onChange={e => setTargetGender(e.target.value)}>
              {GENDERS.map(g => <option key={g.value} value={g.value}>{g.label}</option>)}
            </select>
          </div>
        </div>

        <div className="space-y-4 pt-4 border-t border-slate-100">
          <h4 className="text-sm font-semibold text-slate-900">Video URLs</h4>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-medium text-slate-500 mb-1">Male Video (YouTube URL)</label>
              <input type="url" className="input" value={videoMale} onChange={e => setVideoMale(e.target.value)} placeholder="https://youtube.com/..." />
            </div>
            <div>
              <label className="block text-xs font-medium text-slate-500 mb-1">Female Video (YouTube URL)</label>
              <input type="url" className="input" value={videoFemale} onChange={e => setVideoFemale(e.target.value)} placeholder="https://youtube.com/..." />
            </div>
          </div>
        </div>

        <div className="pt-4 border-t border-slate-100 flex items-center justify-between">
          <div>
            <h4 className="text-sm font-semibold text-slate-900">Status</h4>
            <p className="text-xs text-slate-500">Inactive exercises won&apos;t appear in the consultant dropdowns.</p>
          </div>
          <label className="relative inline-flex items-center cursor-pointer">
            <input type="checkbox" className="sr-only peer" checked={isActive} onChange={e => setIsActive(e.target.checked)} />
            <div className="w-11 h-6 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
          </label>
        </div>

        <div className="flex justify-end gap-3 pt-6 border-t border-slate-100">
          <button type="button" onClick={onClose} className="btn-secondary">Cancel</button>
          <button type="submit" disabled={isSaving} className="btn-primary">
            {isSaving ? "Saving..." : isEdit ? "Update Exercise" : "Create Exercise"}
          </button>
        </div>
      </form>
    </Modal>
  );
}

function MovementDetailModal({ movement, onClose }: { movement: any, onClose: () => void }) {
  return (
    <Modal title="Exercise Details" onClose={onClose}>
      <div className="p-6 space-y-6">
        <div>
          <h3 className="text-xl font-bold text-slate-900">{movement.name}</h3>
          {movement.name_en && <p className="text-sm text-slate-500">{movement.name_en}</p>}
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div className="bg-slate-50 p-3 rounded-lg">
            <div className="text-xs text-slate-500 mb-1">Body Part</div>
            <div className="font-medium capitalize">{movement.body_part}</div>
          </div>
          <div className="bg-slate-50 p-3 rounded-lg">
            <div className="text-xs text-slate-500 mb-1">Gender</div>
            <div className="font-medium capitalize">{movement.target_gender || "Universal"}</div>
          </div>
          <div className="bg-slate-50 p-3 rounded-lg">
            <div className="text-xs text-slate-500 mb-1">Status</div>
            <div className={`font-medium ${movement.is_active ? 'text-green-600' : 'text-slate-500'}`}>
              {movement.is_active ? "Active" : "Inactive"}
            </div>
          </div>
          <div className="bg-slate-50 p-3 rounded-lg">
            <div className="text-xs text-slate-500 mb-1">Type & Level</div>
            <div className="font-medium capitalize">{movement.type || "-"} | Lvl {movement.level || "-"}</div>
          </div>
        </div>

        {(movement.video_url_male || movement.video_url_female) && (
          <div className="space-y-3">
            <h4 className="text-sm font-semibold text-slate-900">Videos</h4>
            <div className="flex gap-4">
              {movement.video_url_male && (
                <a href={movement.video_url_male} target="_blank" rel="noreferrer" className="flex items-center gap-2 px-3 py-2 bg-blue-50 text-blue-700 rounded-lg hover:bg-blue-100 transition-colors text-sm font-medium">
                  <Video className="h-4 w-4" /> Male Video
                </a>
              )}
              {movement.video_url_female && (
                <a href={movement.video_url_female} target="_blank" rel="noreferrer" className="flex items-center gap-2 px-3 py-2 bg-rose-50 text-rose-700 rounded-lg hover:bg-rose-100 transition-colors text-sm font-medium">
                  <Video className="h-4 w-4" /> Female Video
                </a>
              )}
            </div>
          </div>
        )}
      </div>
    </Modal>
  );
}

function VideoPreviewModal({ movement, onClose }: { movement: any; onClose: () => void }) {
  const extractId = (url: string) => {
    if (!url) return null;
    const match = url.match(/(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))([^&?]+)/);
    return match ? match[1] : null;
  };

  const maleId = extractId(movement.video_url_male || "");
  const femaleId = extractId(movement.video_url_female || "");

  return (
    <Modal title={`Preview: ${movement.name}`} onClose={onClose} size="lg">
      <div className="p-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {maleId ? (
            <div className="space-y-2">
              <div className="font-medium text-sm text-blue-700 flex items-center gap-2"><Video className="h-4 w-4"/> Male Video</div>
              <iframe className="w-full aspect-video rounded-lg shadow-sm" src={`https://www.youtube.com/embed/${maleId}`} allowFullScreen />
            </div>
          ) : (
            movement.video_url_male && (
              <div className="space-y-2">
                <div className="font-medium text-sm text-blue-700 flex items-center gap-2"><Video className="h-4 w-4"/> Male Video</div>
                <a href={movement.video_url_male} target="_blank" rel="noreferrer" className="text-sm text-blue-500 underline break-all">{movement.video_url_male}</a>
              </div>
            )
          )}

          {femaleId ? (
            <div className="space-y-2">
              <div className="font-medium text-sm text-rose-700 flex items-center gap-2"><Video className="h-4 w-4"/> Female Video</div>
              <iframe className="w-full aspect-video rounded-lg shadow-sm" src={`https://www.youtube.com/embed/${femaleId}`} allowFullScreen />
            </div>
          ) : (
            movement.video_url_female && (
              <div className="space-y-2">
                <div className="font-medium text-sm text-rose-700 flex items-center gap-2"><Video className="h-4 w-4"/> Female Video</div>
                <a href={movement.video_url_female} target="_blank" rel="noreferrer" className="text-sm text-blue-500 underline break-all">{movement.video_url_female}</a>
              </div>
            )
          )}
        </div>
      </div>
    </Modal>
  );
}
