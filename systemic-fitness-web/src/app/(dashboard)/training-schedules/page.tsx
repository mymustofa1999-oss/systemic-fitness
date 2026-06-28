"use client";

import { useState } from "react";
import {
  useTrainingSchedules,
  useCreateTrainingSchedule,
  useUpdateTrainingSchedule,
  useDeleteTrainingSchedule,
  useTrainingSessions,
  useCreateTrainingSession,
  useUpdateTrainingSession,
  useDeleteTrainingSession,
  useSubstituteTrainer,
  TrainingSchedule,
  TrainingSession,
} from "@/hooks/useTrainingSchedules";
import { useClients, useTeam } from "@/hooks/useNewFeatures";
import { useAuth } from "@/hooks/useAuth";
import { EmptyState } from "@/components/shared/EmptyState";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { SearchInput } from "@/components/shared/SearchInput";
import { DataTable, Column } from "@/components/shared/DataTable";
import { SearchableSelect, SearchableSelectOption } from "@/components/shared/SearchableSelect";
import {
  CalendarClock, Plus, X, Loader2, Pencil, Trash2, MoreVertical,
  Check, XCircle, ArrowRightLeft, Shield,
} from "lucide-react";
import { cn } from "@/lib/utils";

const DAY_NAMES = ["Minggu", "Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu"];

const STATUS_MAP: Record<string, { label: string; cls: string }> = {
  scheduled:   { label: "Terjadwal",   cls: "bg-blue-50 text-blue-700" },
  completed:   { label: "Selesai",     cls: "bg-emerald-50 text-emerald-700" },
  cancelled:   { label: "Dibatalkan",  cls: "bg-rose-50 text-rose-700" },
  substituted: { label: "Digantikan",  cls: "bg-amber-50 text-amber-700" },
};

type TabType = "schedules" | "sessions";

export default function TrainingSchedulesPage() {
  const { isAdmin, isTrainer, user } = useAuth();
  const [activeTab, setActiveTab] = useState<TabType>("schedules");

  if (!isAdmin && !isTrainer) {
    return (
      <EmptyState
        icon={Shield}
        title="Akses Ditolak"
        description="Hanya konsultan/owner dan admin yang dapat mengakses halaman ini."
      />
    );
  }

  // Trainers can view their own schedule, but only admins/owner can manage it.
  const canEdit = isAdmin;
  const trainerId = isTrainer && !isAdmin ? user?.id : undefined;

  return (
    <div className="space-y-5">
      <div>
        <h1 className="text-2xl font-bold text-slate-900">Training Schedules</h1>
        <p className="text-sm text-slate-500 mt-1">
          {canEdit
            ? "Kelola jadwal sesi Certified Trainer ke klien"
            : "Lihat jadwal sesi kamu (mode lihat saja)"}
        </p>
      </div>

      <div className="flex gap-1 bg-slate-100 rounded-lg p-1 w-fit">
        <button
          onClick={() => setActiveTab("schedules")}
          className={cn(
            "px-4 py-2 rounded-md text-sm font-medium transition-colors",
            activeTab === "schedules" ? "bg-white text-slate-900 shadow-sm" : "text-slate-500 hover:text-slate-700"
          )}
        >
          Jadwal Mingguan
        </button>
        <button
          onClick={() => setActiveTab("sessions")}
          className={cn(
            "px-4 py-2 rounded-md text-sm font-medium transition-colors",
            activeTab === "sessions" ? "bg-white text-slate-900 shadow-sm" : "text-slate-500 hover:text-slate-700"
          )}
        >
          Sesi Individual
        </button>
      </div>

      {activeTab === "schedules"
        ? <SchedulesTab canEdit={canEdit} trainerId={trainerId} />
        : <SessionsTab canEdit={canEdit} trainerId={trainerId} />}
    </div>
  );
}

// ════════════════════════════════════════════════════════════════════
//  Tab 1: Recurring Schedules
// ════════════════════════════════════════════════════════════════════

function SchedulesTab({ canEdit, trainerId }: { canEdit: boolean; trainerId?: string }) {
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [modalItem, setModalItem] = useState<any | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<any | null>(null);
  const [menuOpen, setMenuOpen] = useState<string | null>(null);

  const params: Record<string, unknown> = { page, limit: 50, search };
  if (trainerId) params.trainer_id = trainerId;
  const { data, isLoading } = useTrainingSchedules(params);
  const deleteSchedule = useDeleteTrainingSchedule();
  const schedules = (data?.data ?? []) as TrainingSchedule[];
  const meta = data?.meta;

  async function confirmDelete() {
    if (!deleteTarget) return;
    await deleteSchedule.mutateAsync(deleteTarget.id);
    setDeleteTarget(null);
  }

  return (
    <>
      <div className="flex items-center gap-3">
        <div className="flex-1">
          <SearchInput value={search} onChange={(v) => { setSearch(v); setPage(1); }} placeholder="Cari nama klien atau Certified Trainer..." />
        </div>
        {canEdit && (
          <button onClick={() => setModalItem({})} className="btn-primary">
            <Plus className="h-4 w-4" /> Tambah Jadwal
          </button>
        )}
      </div>

      {!isLoading && schedules.length === 0 ? (
        <EmptyState
          icon={CalendarClock}
          title={search ? "Tidak ditemukan" : "Belum ada jadwal"}
          description={search ? "Coba kata kunci lain" : canEdit ? "Buat jadwal sesi mingguan untuk klien." : "Belum ada jadwal sesi untuk kamu."}
          action={!search && canEdit ? <button onClick={() => setModalItem({})} className="btn-primary"><Plus className="h-4 w-4" /> Tambah Jadwal</button> : undefined}
        />
      ) : (
        <DataTable
          columns={scheduleColumns(menuOpen, setMenuOpen, setModalItem, setDeleteTarget, canEdit)}
          data={schedules}
          loading={isLoading}
          page={page}
          pageSize={50}
          totalPages={meta?.total_pages ?? 1}
          total={meta?.total ?? 0}
          onPageChange={setPage}
        />
      )}

      {modalItem !== null && <ScheduleFormModal schedule={modalItem.id ? modalItem : null} onClose={() => setModalItem(null)} />}
      <ConfirmDialog open={!!deleteTarget} onClose={() => setDeleteTarget(null)} onConfirm={confirmDelete} title="Hapus Jadwal" description={`Hapus jadwal "${deleteTarget?.client_name} - ${DAY_NAMES[deleteTarget?.day_of_week ?? 0]}"?`} confirmLabel="Hapus" variant="danger" loading={deleteSchedule.isPending} />
    </>
  );
}

// ════════════════════════════════════════════════════════════════════
//  Tab 2: Individual Sessions
// ════════════════════════════════════════════════════════════════════

function SessionsTab({ canEdit, trainerId }: { canEdit: boolean; trainerId?: string }) {
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [modalItem, setModalItem] = useState<any | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<any | null>(null);
  const [substituteTarget, setSubstituteTarget] = useState<TrainingSession | null>(null);
  const [menuOpen, setMenuOpen] = useState<string | null>(null);

  const params: Record<string, unknown> = { page, limit: 50, search };
  if (trainerId) params.trainer_id = trainerId;
  const { data, isLoading } = useTrainingSessions(params);
  const deleteSession = useDeleteTrainingSession();
  const sessions = (data?.data ?? []) as TrainingSession[];
  const meta = data?.meta;

  async function confirmDelete() {
    if (!deleteTarget) return;
    await deleteSession.mutateAsync(deleteTarget.id);
    setDeleteTarget(null);
  }

  return (
    <>
      <div className="flex items-center gap-3">
        <div className="flex-1">
          <SearchInput value={search} onChange={(v) => { setSearch(v); setPage(1); }} placeholder="Cari nama klien atau Certified Trainer..." />
        </div>
        {canEdit && (
          <button onClick={() => setModalItem({})} className="btn-primary">
            <Plus className="h-4 w-4" /> Tambah Sesi
          </button>
        )}
      </div>

      {!isLoading && sessions.length === 0 ? (
        <EmptyState
          icon={CalendarClock}
          title={search ? "Tidak ditemukan" : "Belum ada sesi"}
          description={search ? "Coba kata kunci lain" : canEdit ? "Buat sesi individual." : "Belum ada sesi untuk kamu."}
          action={!search && canEdit ? <button onClick={() => setModalItem({})} className="btn-primary"><Plus className="h-4 w-4" /> Tambah Sesi</button> : undefined}
        />
      ) : (
        <DataTable
          columns={sessionColumns(menuOpen, setMenuOpen, setModalItem, setDeleteTarget, setSubstituteTarget, canEdit)}
          data={sessions}
          loading={isLoading}
          page={page}
          pageSize={50}
          totalPages={meta?.total_pages ?? 1}
          total={meta?.total ?? 0}
          onPageChange={setPage}
        />
      )}

      {modalItem !== null && <SessionFormModal session={modalItem.id ? modalItem : null} onClose={() => setModalItem(null)} />}
      {substituteTarget && <SubstituteModal session={substituteTarget} onClose={() => setSubstituteTarget(null)} />}
      <ConfirmDialog open={!!deleteTarget} onClose={() => setDeleteTarget(null)} onConfirm={confirmDelete} title="Hapus Sesi" description={`Hapus sesi "${deleteTarget?.client_name} - ${deleteTarget?.session_date}"?`} confirmLabel="Hapus" variant="danger" loading={deleteSession.isPending} />
    </>
  );
}

// ── Schedule Columns ───────────────────────────────────────────

function scheduleColumns(
  menuOpenId: string | null,
  setMenuOpen: (id: string | null) => void,
  setModalItem: (s: any) => void,
  setDeleteTarget: (s: any) => void,
  canEdit: boolean,
): Column<any>[] {
  return [
    { key: "client_name", label: "Client", render: (s) => <span className="font-medium text-slate-900 text-sm">{s.client_name || s.client_id}</span> },
    { key: "trainer_name", label: "Trainer", render: (s) => <span className="text-sm text-slate-700">{s.trainer_name || s.trainer_id}</span> },
    { key: "day_of_week", label: "Hari", className: "w-28", render: (s) => <span className="px-2 py-0.5 rounded-md bg-sf-iceBlue text-sf-deepNavy text-xs font-medium">{DAY_NAMES[s.day_of_week]}</span> },
    { key: "start_time", label: "Jam", className: "w-32", render: (s) => <span className="text-sm text-slate-600 font-mono">{s.start_time?.slice(0, 5)} - {s.end_time?.slice(0, 5)}</span> },
    { key: "location", label: "Lokasi", render: (s) => <span className="text-sm text-slate-600">{s.location || "—"}</span> },
    { key: "is_active", label: "Status", className: "w-20", render: (s) => s.is_active ? <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700 text-xs font-medium"><Check className="h-3 w-3" /> Aktif</span> : <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-slate-100 text-slate-500 text-xs font-medium"><XCircle className="h-3 w-3" /> Off</span> },
    ...(canEdit ? [{
      key: "actions", label: "", className: "w-12",
      render: (s: any) => (
        <div className="relative">
          <button onClick={(e) => { e.stopPropagation(); setMenuOpen(menuOpenId === s.id ? null : s.id); }} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400"><MoreVertical className="h-4 w-4" /></button>
          {menuOpenId === s.id && (
            <>
              <div className="fixed inset-0 z-10" onClick={() => setMenuOpen(null)} />
              <div className="absolute right-4 top-10 bg-white rounded-lg shadow-lg border border-slate-100 py-1 min-w-[140px] z-20">
                <button onClick={(e) => { e.stopPropagation(); setMenuOpen(null); setModalItem(s); }} className="w-full px-3 py-2 text-left text-sm text-slate-700 hover:bg-slate-50 flex items-center gap-2"><Pencil className="h-3.5 w-3.5" /> Edit</button>
                <button onClick={(e) => { e.stopPropagation(); setMenuOpen(null); setDeleteTarget(s); }} className="w-full px-3 py-2 text-left text-sm text-rose-600 hover:bg-rose-50 flex items-center gap-2"><Trash2 className="h-3.5 w-3.5" /> Hapus</button>
              </div>
            </>
          )}
        </div>
      ),
    }] : []),
  ];
}

// ── Session Columns ────────────────────────────────────────────

function sessionColumns(
  menuOpenId: string | null,
  setMenuOpen: (id: string | null) => void,
  setModalItem: (s: any) => void,
  setDeleteTarget: (s: any) => void,
  setSubstituteTarget: (s: any) => void,
  canEdit: boolean,
): Column<any>[] {
  return [
    { key: "session_date", label: "Tanggal", render: (s) => <span className="text-sm font-medium text-slate-900">{s.session_date}</span> },
    { key: "client_name", label: "Client", render: (s) => <span className="text-sm text-slate-700">{s.client_name || s.client_id}</span> },
    {
      key: "trainer_name", label: "Trainer",
      render: (s) => (
        <div>
          <span className="text-sm text-slate-700">{s.trainer_name || s.trainer_id}</span>
          {s.is_substitute && s.original_trainer_name && <span className="block text-xs text-amber-600 mt-0.5">Menggantikan {s.original_trainer_name}</span>}
        </div>
      ),
    },
    { key: "start_time", label: "Jam", className: "w-32", render: (s) => <span className="text-sm text-slate-600 font-mono">{s.start_time?.slice(0, 5)} - {s.end_time?.slice(0, 5)}</span> },
    { key: "location", label: "Lokasi", render: (s) => <span className="text-sm text-slate-600">{s.location || "—"}</span> },
    {
      key: "status", label: "Status", className: "w-28",
      render: (s) => {
        const st = STATUS_MAP[s.status] || STATUS_MAP.scheduled;
        return <span className={cn("inline-block px-2 py-0.5 rounded-full text-xs font-medium", st.cls)}>{st.label}</span>;
      },
    },
    {
      key: "is_substitute", label: "Substitusi", className: "w-24",
      render: (s) => s.is_substitute ? <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-amber-50 text-amber-700 text-xs font-medium"><ArrowRightLeft className="h-3 w-3" /> Ya</span> : <span className="text-xs text-slate-400">—</span>,
    },
    ...(canEdit ? [{
      key: "actions", label: "", className: "w-12",
      render: (s: any) => (
        <div className="relative">
          <button onClick={(e) => { e.stopPropagation(); setMenuOpen(menuOpenId === s.id ? null : s.id); }} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400"><MoreVertical className="h-4 w-4" /></button>
          {menuOpenId === s.id && (
            <>
              <div className="fixed inset-0 z-10" onClick={() => setMenuOpen(null)} />
              <div className="absolute right-4 top-10 bg-white rounded-lg shadow-lg border border-slate-100 py-1 min-w-[160px] z-20">
                <button onClick={(e) => { e.stopPropagation(); setMenuOpen(null); setModalItem(s); }} className="w-full px-3 py-2 text-left text-sm text-slate-700 hover:bg-slate-50 flex items-center gap-2"><Pencil className="h-3.5 w-3.5" /> Edit</button>
                {!s.is_substitute && s.status === "scheduled" && (
                  <button onClick={(e) => { e.stopPropagation(); setMenuOpen(null); setSubstituteTarget(s); }} className="w-full px-3 py-2 text-left text-sm text-amber-600 hover:bg-amber-50 flex items-center gap-2"><ArrowRightLeft className="h-3.5 w-3.5" /> Ganti Certified Trainer</button>
                )}
                <button onClick={(e) => { e.stopPropagation(); setMenuOpen(null); setDeleteTarget(s); }} className="w-full px-3 py-2 text-left text-sm text-rose-600 hover:bg-rose-50 flex items-center gap-2"><Trash2 className="h-3.5 w-3.5" /> Hapus</button>
              </div>
            </>
          )}
        </div>
      ),
    }] : []),
  ];
}

// ════════════════════════════════════════════════════════════════════
//  Schedule Form Modal
// ════════════════════════════════════════════════════════════════════

function ScheduleFormModal({ schedule, onClose }: { schedule: TrainingSchedule | null; onClose: () => void }) {
  const isEdit = !!schedule?.id;
  const create = useCreateTrainingSchedule();
  const update = useUpdateTrainingSchedule();
  const saving = create.isPending || update.isPending;

  const { data: clientsData } = useClients({ limit: 100 });
  const { data: teamData } = useTeam({ limit: 100 });
  const clients = (clientsData?.data ?? []) as any[];
  const trainers = ((teamData?.data ?? []) as any[]).filter((u: any) => u.role === "trainer");

  const clientOptions: SearchableSelectOption[] = clients.map((c: any) => ({
    value: c.id, label: c.full_name, sublabel: c.email,
  }));
  const trainerOptions: SearchableSelectOption[] = trainers.map((t: any) => ({
    value: t.id, label: t.full_name, sublabel: t.email,
  }));
  const dayOptions: SearchableSelectOption[] = DAY_NAMES.map((d, i) => ({
    value: String(i), label: d,
  }));

  const [clientId, setClientId] = useState(schedule?.client_id ?? "");
  const [trainerId, setTrainerId] = useState(schedule?.trainer_id ?? "");
  const [dayOfWeek, setDayOfWeek] = useState(schedule?.day_of_week ?? 1);
  const [startTime, setStartTime] = useState(schedule?.start_time?.slice(0, 5) ?? "08:00");
  const [endTime, setEndTime] = useState(schedule?.end_time?.slice(0, 5) ?? "09:00");
  const [location, setLocation] = useState(schedule?.location ?? "");
  const [notes, setNotes] = useState(schedule?.notes ?? "");
  const [isActive, setIsActive] = useState(schedule?.is_active ?? true);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!clientId || !trainerId) return;
    const payload: Record<string, unknown> = {
      client_id: clientId, trainer_id: trainerId, day_of_week: dayOfWeek,
      start_time: startTime, end_time: endTime,
      location: location || null, notes: notes || null, is_active: isActive,
    };
    if (isEdit) await update.mutateAsync({ id: schedule!.id, ...payload });
    else await create.mutateAsync(payload);
    onClose();
  }

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center pt-[5vh] overflow-y-auto" onClick={onClose}>
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" />
      <div className="relative bg-white rounded-2xl shadow-xl max-w-lg w-full mx-4 mb-12 animate-slide-in" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
          <h2 className="text-lg font-semibold text-slate-900">{isEdit ? "Edit Jadwal" : "Tambah Jadwal Mingguan"}</h2>
          <button onClick={onClose} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400"><X className="h-5 w-5" /></button>
        </div>
        <form onSubmit={handleSubmit} className="p-6 space-y-5 max-h-[75vh] overflow-y-auto">
          <div>
            <label className="label">Client *</label>
            <SearchableSelect
              options={clientOptions}
              value={clientId}
              onChange={setClientId}
              placeholder="Pilih client..."
              searchPlaceholder="Cari nama client..."
            />
          </div>
          <div>
            <label className="label">Trainer *</label>
            <SearchableSelect
              options={trainerOptions}
              value={trainerId}
              onChange={setTrainerId}
              placeholder="Pilih trainer..."
              searchPlaceholder="Cari nama trainer..."
            />
          </div>
          <div>
            <label className="label">Hari *</label>
            <SearchableSelect
              options={dayOptions}
              value={String(dayOfWeek)}
              onChange={(v) => setDayOfWeek(parseInt(v) || 0)}
              placeholder="Pilih hari..."
              searchPlaceholder="Cari hari..."
            />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Jam Mulai *</label>
              <input type="time" value={startTime} onChange={(e) => setStartTime(e.target.value)} required className="input" />
            </div>
            <div>
              <label className="label">Jam Selesai *</label>
              <input type="time" value={endTime} onChange={(e) => setEndTime(e.target.value)} required className="input" />
            </div>
          </div>
          <div>
            <label className="label">Lokasi</label>
            <input value={location} onChange={(e) => setLocation(e.target.value)} className="input" placeholder="e.g. Studio A" />
          </div>
          <div>
            <label className="label">Catatan</label>
            <textarea value={notes} onChange={(e) => setNotes(e.target.value)} className="input" rows={2} placeholder="Catatan tambahan..." />
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
          <div className="flex justify-end gap-3 pt-2">
            <button type="button" onClick={onClose} className="btn-secondary">Batal</button>
            <button type="submit" disabled={saving || !clientId || !trainerId} className="btn-primary">
              {saving ? <Loader2 className="h-4 w-4 animate-spin" /> : <Plus className="h-4 w-4" />}
              {saving ? "Menyimpan..." : isEdit ? "Simpan" : "Tambah"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

// ════════════════════════════════════════════════════════════════════
//  Session Form Modal
// ════════════════════════════════════════════════════════════════════

function SessionFormModal({ session, onClose }: { session: TrainingSession | null; onClose: () => void }) {
  const isEdit = !!session?.id;
  const create = useCreateTrainingSession();
  const update = useUpdateTrainingSession();
  const saving = create.isPending || update.isPending;

  const { data: clientsData } = useClients({ limit: 100 });
  const { data: teamData } = useTeam({ limit: 100 });
  const clients = (clientsData?.data ?? []) as any[];
  const trainers = ((teamData?.data ?? []) as any[]).filter((u: any) => u.role === "trainer");

  const clientOptions: SearchableSelectOption[] = clients.map((c: any) => ({
    value: c.id, label: c.full_name, sublabel: c.email,
  }));
  const trainerOptions: SearchableSelectOption[] = trainers.map((t: any) => ({
    value: t.id, label: t.full_name, sublabel: t.email,
  }));

  const [clientId, setClientId] = useState(session?.client_id ?? "");
  const [trainerId, setTrainerId] = useState(session?.trainer_id ?? "");
  const [sessionDate, setSessionDate] = useState(session?.session_date ?? "");
  const [startTime, setStartTime] = useState(session?.start_time?.slice(0, 5) ?? "08:00");
  const [endTime, setEndTime] = useState(session?.end_time?.slice(0, 5) ?? "09:00");
  const [status, setStatus] = useState<string>(session?.status ?? "scheduled");
  const [location, setLocation] = useState(session?.location ?? "");
  const [notes, setNotes] = useState(session?.notes ?? "");

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!clientId || !trainerId || !sessionDate) return;
    const payload: Record<string, unknown> = {
      client_id: clientId, trainer_id: trainerId, session_date: sessionDate,
      start_time: startTime, end_time: endTime, status,
      location: location || null, notes: notes || null,
    };
    if (isEdit) await update.mutateAsync({ id: session!.id, ...payload });
    else await create.mutateAsync(payload);
    onClose();
  }

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center pt-[5vh] overflow-y-auto" onClick={onClose}>
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" />
      <div className="relative bg-white rounded-2xl shadow-xl max-w-lg w-full mx-4 mb-12 animate-slide-in" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
          <h2 className="text-lg font-semibold text-slate-900">{isEdit ? "Edit Sesi" : "Tambah Sesi"}</h2>
          <button onClick={onClose} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400"><X className="h-5 w-5" /></button>
        </div>
        <form onSubmit={handleSubmit} className="p-6 space-y-5 max-h-[75vh] overflow-y-auto">
          <div>
            <label className="label">Client *</label>
            <SearchableSelect
              options={clientOptions}
              value={clientId}
              onChange={setClientId}
              placeholder="Pilih client..."
              searchPlaceholder="Cari nama client..."
            />
          </div>
          <div>
            <label className="label">Trainer *</label>
            <SearchableSelect
              options={trainerOptions}
              value={trainerId}
              onChange={setTrainerId}
              placeholder="Pilih trainer..."
              searchPlaceholder="Cari nama trainer..."
            />
          </div>
          <div>
            <label className="label">Tanggal *</label>
            <input type="date" value={sessionDate} onChange={(e) => setSessionDate(e.target.value)} required className="input" />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Jam Mulai *</label>
              <input type="time" value={startTime} onChange={(e) => setStartTime(e.target.value)} required className="input" />
            </div>
            <div>
              <label className="label">Jam Selesai *</label>
              <input type="time" value={endTime} onChange={(e) => setEndTime(e.target.value)} required className="input" />
            </div>
          </div>
          {isEdit && (
            <div>
              <label className="label">Status</label>
              <SearchableSelect
                options={[{ value: "scheduled", label: "Terjadwal" }, { value: "completed", label: "Selesai" }, { value: "cancelled", label: "Dibatalkan" }]}
                value={status}
                onChange={setStatus}
                placeholder="Pilih status..."
              />
            </div>
          )}
          <div>
            <label className="label">Lokasi</label>
            <input value={location} onChange={(e) => setLocation(e.target.value)} className="input" placeholder="e.g. Studio A" />
          </div>
          <div>
            <label className="label">Catatan</label>
            <textarea value={notes} onChange={(e) => setNotes(e.target.value)} className="input" rows={2} />
          </div>
          <div className="flex justify-end gap-3 pt-2">
            <button type="button" onClick={onClose} className="btn-secondary">Batal</button>
            <button type="submit" disabled={saving || !clientId || !trainerId || !sessionDate} className="btn-primary">
              {saving ? <Loader2 className="h-4 w-4 animate-spin" /> : <Plus className="h-4 w-4" />}
              {saving ? "Menyimpan..." : isEdit ? "Simpan" : "Tambah"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

// ════════════════════════════════════════════════════════════════════
//  Substitute Trainer Modal
// ════════════════════════════════════════════════════════════════════

function SubstituteModal({ session, onClose }: { session: TrainingSession; onClose: () => void }) {
  const substitute = useSubstituteTrainer();
  const { data: teamData } = useTeam({ limit: 100 });
  const trainers = ((teamData?.data ?? []) as any[]).filter((u: any) => u.role === "trainer" && u.id !== session.trainer_id);

  const trainerOptions: SearchableSelectOption[] = trainers.map((t: any) => ({
    value: t.id, label: t.full_name, sublabel: t.email,
  }));

  const [substituteId, setSubstituteId] = useState("");
  const [reason, setReason] = useState("");

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!substituteId || !reason.trim()) return;
    await substitute.mutateAsync({ sessionId: session.id, substitute_trainer_id: substituteId, reason: reason.trim() });
    onClose();
  }

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center pt-[10vh] overflow-y-auto" onClick={onClose}>
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" />
      <div className="relative bg-white rounded-2xl shadow-xl max-w-md w-full mx-4 mb-12 animate-slide-in" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
          <h2 className="text-lg font-semibold text-slate-900">Ganti Trainer</h2>
          <button onClick={onClose} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400"><X className="h-5 w-5" /></button>
        </div>
        <form onSubmit={handleSubmit} className="p-6 space-y-5">
          <div className="p-3 bg-amber-50 rounded-lg text-sm text-amber-800">
            <p className="font-medium">Sesi: {session.client_name} — {session.session_date}</p>
            <p>Trainer saat ini: <strong>{session.trainer_name}</strong></p>
          </div>
          <div>
            <label className="label">Trainer Pengganti *</label>
            <SearchableSelect
              options={trainerOptions}
              value={substituteId}
              onChange={setSubstituteId}
              placeholder="Pilih trainer pengganti..."
              searchPlaceholder="Cari nama trainer..."
            />
          </div>
          <div>
            <label className="label">Alasan Penggantian *</label>
            <textarea value={reason} onChange={(e) => setReason(e.target.value)} required className="input" rows={3} placeholder="e.g. Trainer Lisa sakit, digantikan oleh Fajar" />
          </div>
          <div className="flex justify-end gap-3 pt-2">
            <button type="button" onClick={onClose} className="btn-secondary">Batal</button>
            <button type="submit" disabled={substitute.isPending || !substituteId || !reason.trim()} className="btn-primary">
              {substitute.isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <ArrowRightLeft className="h-4 w-4" />}
              {substitute.isPending ? "Mengganti..." : "Ganti Trainer"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

// ════════════════════════════════════════════════════════════════════
//  Shared Skeleton
// ════════════════════════════════════════════════════════════════════

function TableSkeleton() {
  return (
    <div className="space-y-3">
      {Array.from({ length: 6 }).map((_, i) => (
        <div key={i} className="card p-4">
          <div className="flex gap-4">
            <div className="skeleton h-5 w-32" />
            <div className="skeleton h-5 w-28" />
            <div className="skeleton h-5 w-20" />
            <div className="skeleton h-5 w-24" />
            <div className="skeleton h-5 w-16 ml-auto" />
          </div>
        </div>
      ))}
    </div>
  );
}
