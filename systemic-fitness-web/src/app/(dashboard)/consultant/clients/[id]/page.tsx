"use client";

import { useState, useMemo } from "react";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { useUser } from "@/hooks/useUsers";
import { useLatestAssessmentV2 } from "@/hooks/useAssessmentV2";
import { useLabConsultations } from "@/hooks/usePhaseSix";
import {
  useClinicalNotes,
  useCreateClinicalNote,
  useUpdateClinicalNote,
  useDeleteClinicalNote,
  type ClinicalNote,
} from "@/hooks/useConsultant";
import { useAuth } from "@/hooks/useAuth";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { EmptyState } from "@/components/shared/EmptyState";
import {
  ArrowLeft, Loader2, FileText, Plus, Pencil, Trash2,
  ExternalLink, Save, X, Lock, Globe,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { MedicinesCard } from "@/components/shared/MedicinesCard";
import { ClientSubscriptionSection } from "@/components/shared/ClientSubscriptionSection";
import { useCustomerSetup } from "@/hooks/useNewFeatures";

// SF Phase 7d — Consultant client detail.
// Layout:
//   Header (back link, client info)
//   2-col: Latest Asesmen v2 summary | Lab Consultation history
//   Catatan Klinis (full width: form + list)

function fmtDate(iso: string | null | undefined): string {
  if (!iso) return "—";
  return new Date(iso).toLocaleDateString("id-ID", {
    day: "numeric",
    month: "short",
    year: "numeric",
  });
}

function fmtDateTime(iso: string | null | undefined): string {
  if (!iso) return "—";
  return new Date(iso).toLocaleString("id-ID", {
    dateStyle: "medium",
    timeStyle: "short",
  });
}

const PROGRAM_TYPE_LABEL: Record<string, string> = {
  condition_specific: "Kondisi Spesifik",
  preventive: "Preventif",
  performance_women_35_45: "Perf · Wanita 35–45",
  performance_women_46_60: "Perf · Wanita 46–60",
  performance_men_35_45: "Perf · Pria 35–45",
  performance_men_46_60: "Perf · Pria 46–60",
  waitlist: "Waitlist",
};

const LAB_STATUS_COLOR: Record<string, string> = {
  pending: "bg-amber-50 text-amber-700",
  scheduled: "bg-sky-50 text-sky-700",
  completed: "bg-emerald-50 text-emerald-700",
  cancelled: "bg-rose-50 text-rose-700",
  no_show: "bg-slate-100 text-slate-500",
};

export default function ConsultantClientDetailPage({ params }: { params: { id: string } }) {
  const sp = useSearchParams();
  const prefilledAssessmentId = sp.get("assessment");

  const { data: userData, isLoading: userLoading } = useUser(params.id);
  const { data: assessmentData, isLoading: assessmentLoading } = useLatestAssessmentV2(params.id);
  const { data: setupData } = useCustomerSetup(params.id);
  const { data: labData } = useLabConsultations({ user_id: params.id });
  const { data: notesData, isLoading: notesLoading } = useClinicalNotes({
    client_id: params.id,
  });

  const detail = (userData?.data as any) ?? null;
  const user = detail?.user;
  const assessment = assessmentData?.data;
  const setup = setupData?.data;
  const labs = (labData?.data ?? []) as any[];
  const notes = (notesData?.data ?? []) as ClinicalNote[];

  if (userLoading) return <PageSkeleton />;
  if (!user) {
    return (
      <div className="text-center py-20">
        <p className="text-slate-500">Klien tidak ditemukan.</p>
        <Link
          href="/consultant/clients"
          className="text-sf-deepNavy hover:text-sf-warmGold text-sm mt-2 inline-block"
        >
          Kembali ke Klien Saya
        </Link>
      </div>
    );
  }

  return (
    <div className="space-y-5 bg-sf-warmWhite min-h-full -m-6 p-6 rounded-xl">
      <Link
        href="/consultant/clients"
        className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-sf-deepNavy"
      >
        <ArrowLeft className="h-4 w-4" /> Kembali ke Klien Saya
      </Link>

      {/* ─── Header ───────────────────────────────────────────── */}
      <div className="card p-5 flex flex-col md:flex-row md:items-start justify-between gap-4">
        <div>
          <h1 className="sf-headline text-2xl">{user.full_name}</h1>
          <div className="flex flex-wrap items-center gap-4 mt-1 text-sm text-slate-500 font-dm-sans">
            <span>{user.email}</span>
            {user.phone && <span>· {user.phone}</span>}
            <span>· Bergabung {fmtDate(user.created_at)}</span>
          </div>
        </div>
        <Link
          href={`/clients/${params.id}`}
          className="inline-flex items-center gap-2 px-4 py-2 bg-sf-warmGold hover:bg-sf-warmGoldDark text-sf-deepNavy font-semibold rounded-lg text-sm transition-colors shadow-sm"
        >
          Buat Modul Card & Assign Trainer <ExternalLink size={16} />
        </Link>
      </div>

      {/* ─── Asesmen v2 + Lab History ────────────────────────── */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <div className="space-y-4">
          <AssessmentSummaryCard
            isLoading={assessmentLoading}
            assessment={assessment as any}
          />
          <MedicinesCard customerId={params.id} data={(setupData?.data as any)?.medicines ?? []} />
        </div>
        <div className="space-y-4">
          <LabHistoryCard labs={labs} />
          <ClientSubscriptionSection clientId={params.id} clientName={user.full_name} />
        </div>
      </div>

      {/* ─── Clinical Notes ───────────────────────────────────── */}
      <ClinicalNotesSection
        clientId={params.id}
        prefilledAssessmentId={prefilledAssessmentId}
        currentAssessmentId={(assessment as any)?.id}
        notes={notes}
        isLoading={notesLoading}
      />
    </div>
  );
}

// ─── Assessment Summary Card ──────────────────────────────────────

function AssessmentSummaryCard({
  isLoading,
  assessment,
}: {
  isLoading: boolean;
  assessment: any;
}) {
  if (isLoading) {
    return (
      <div className="card p-5 flex items-center justify-center min-h-[160px]">
        <Loader2 className="h-5 w-5 animate-spin text-slate-400" />
      </div>
    );
  }
  if (!assessment) {
    return (
      <div className="card p-5">
        <h2 className="sf-headline text-lg mb-2">Asesmen v2</h2>
        <p className="text-sm text-slate-500 font-dm-sans">
          Klien belum mengisi Asesmen v2.
        </p>
      </div>
    );
  }

  return (
    <div className="card p-5 space-y-3">
      <div className="flex items-start justify-between gap-3">
        <div>
          <h2 className="sf-headline text-lg">Asesmen v2 Terakhir</h2>
          <p className="text-xs text-slate-500 font-dm-mono mt-0.5">
            Submit · {fmtDateTime(assessment.created_at)}
          </p>
        </div>
        <Link
          href={`/assessments/${assessment.id}`}
          className="inline-flex items-center gap-1 text-xs font-semibold text-sf-deepNavy hover:text-sf-warmGold"
        >
          Lihat detail <ExternalLink className="h-3 w-3" />
        </Link>
      </div>

      <div className="grid grid-cols-2 gap-2 pt-2 border-t border-slate-100">
        <Metric label="System Score" value={assessment.system_score} />
        <div className="text-center rounded-md bg-slate-50 py-2">
          <div className="text-[10px] uppercase tracking-wider text-slate-500 font-dm-sans">Phase</div>
          <div className="font-dm-mono text-sm font-semibold text-sf-charcoal">
            {assessment.physical_status_level || "-"}
          </div>
        </div>
      </div>

      <div className="text-xs text-slate-600 font-dm-sans space-y-1">
        <div>
          <span className="text-slate-500">Program: </span>
          <span className="font-semibold">
            {assessment.program_type
              ? PROGRAM_TYPE_LABEL[assessment.program_type] ?? assessment.program_type
              : "—"}
          </span>
        </div>
        <div>
          <span className="text-slate-500">Level Fisik: </span>
          <span className="font-semibold">{assessment.physical_status_level ?? "—"}</span>
        </div>
      </div>
    </div>
  );
}

function Metric({ label, value }: { label: string; value: number | null | undefined }) {
  return (
    <div className="text-center rounded-md bg-slate-50 py-2">
      <div className="text-[10px] uppercase tracking-wider text-slate-500 font-dm-sans">
        {label}
      </div>
      <div className="font-dm-mono text-sm font-semibold text-sf-charcoal">
        {value != null ? Number(value).toFixed(1) : "—"}
      </div>
    </div>
  );
}

// ─── Lab History Card ────────────────────────────────────────────

function LabHistoryCard({ labs }: { labs: any[] }) {
  return (
    <div className="card p-5">
      <h2 className="sf-headline text-lg mb-3">Lab Consultation</h2>
      {labs.length === 0 ? (
        <p className="text-sm text-slate-500 font-dm-sans">
          Belum ada Lab Consultation untuk klien ini.
        </p>
      ) : (
        <div className="space-y-2">
          {labs.slice(0, 5).map((l) => (
            <div
              key={l.id}
              className="flex items-center justify-between gap-3 py-2 border-b border-slate-100 last:border-0"
            >
              <div className="min-w-0">
                <div className="text-sm font-medium text-sf-charcoal font-dm-sans truncate">
                  {l.scheduled_at
                    ? `Sesi ${fmtDateTime(l.scheduled_at)}`
                    : `Booking ${fmtDate(l.created_at)}`}
                </div>
                <div className="text-xs text-slate-500 font-dm-sans truncate">
                  {l.consultant_name ? `dr. ${l.consultant_name}` : "Belum di-assign"}
                </div>
              </div>
              <span
                className={cn(
                  "shrink-0 inline-flex px-2 py-0.5 text-[10px] font-semibold rounded-full uppercase tracking-wider",
                  LAB_STATUS_COLOR[l.status] ?? "bg-slate-100 text-slate-600",
                )}
              >
                {l.status}
              </span>
            </div>
          ))}
          {labs.length > 5 && (
            <Link
              href="/lab-consultations"
              className="block text-xs font-semibold text-sf-deepNavy hover:text-sf-warmGold pt-1"
            >
              Lihat semua ({labs.length}) →
            </Link>
          )}
        </div>
      )}
    </div>
  );
}

// ─── Clinical Notes Section ──────────────────────────────────────

function ClinicalNotesSection({
  clientId,
  prefilledAssessmentId,
  currentAssessmentId,
  notes,
  isLoading,
}: {
  clientId: string;
  prefilledAssessmentId: string | null;
  currentAssessmentId: string | undefined;
  notes: ClinicalNote[];
  isLoading: boolean;
}) {
  const [showForm, setShowForm] = useState(!!prefilledAssessmentId);

  // Auto-prefill from query string only on first load
  const initialAssessmentId = useMemo(
    () => prefilledAssessmentId || currentAssessmentId || "",
    [prefilledAssessmentId, currentAssessmentId],
  );

  return (
    <div className="card p-5 space-y-4">
      <div className="flex items-center justify-between">
        <h2 className="sf-headline text-lg">Catatan Klinis</h2>
        <button
          onClick={() => setShowForm((v) => !v)}
          className="inline-flex items-center gap-1.5 text-xs font-semibold text-sf-deepNavy hover:text-sf-warmGold"
        >
          {showForm ? (
            <>
              <X className="h-3.5 w-3.5" /> Batal
            </>
          ) : (
            <>
              <Plus className="h-3.5 w-3.5" /> Tulis Baru
            </>
          )}
        </button>
      </div>

      {showForm && (
        <NoteForm
          clientId={clientId}
          initialAssessmentId={initialAssessmentId}
          onClose={() => setShowForm(false)}
        />
      )}

      {isLoading ? (
        <div className="flex justify-center py-10">
          <Loader2 className="h-5 w-5 animate-spin text-slate-400" />
        </div>
      ) : notes.length === 0 ? (
        <EmptyState
          icon={FileText}
          title="Belum ada catatan klinis"
          description="Tulis catatan pertama untuk klien ini — bisa terkait Asesmen v2 atau stand-alone."
        />
      ) : (
        <div className="space-y-3">
          {notes.map((n) => (
            <NoteCard key={n.id} note={n} />
          ))}
        </div>
      )}
    </div>
  );
}

// ─── Note Form (create) ──────────────────────────────────────────

function NoteForm({
  clientId,
  initialAssessmentId,
  onClose,
}: {
  clientId: string;
  initialAssessmentId: string;
  onClose: () => void;
}) {
  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");
  const [assessmentId, setAssessmentId] = useState(initialAssessmentId);
  const [isVisibleToClient, setIsVisibleToClient] = useState(false);

  const create = useCreateClinicalNote();

  async function handleSubmit() {
    if (!content.trim()) return;
    await create.mutateAsync({
      client_id: clientId,
      assessment_id: assessmentId.trim() || undefined,
      title: title.trim() || undefined,
      content: content.trim(),
      is_visible_to_client: isVisibleToClient,
    });
    setTitle("");
    setContent("");
    setIsVisibleToClient(false);
    onClose();
  }

  return (
    <div className="rounded-lg bg-sf-iceBlue/30 p-4 space-y-3 border border-slate-200">
      <input
        type="text"
        placeholder="Judul catatan (opsional)"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        className="input w-full font-dm-sans"
      />
      <textarea
        placeholder="Tulis catatan klinis di sini... (markdown didukung)"
        value={content}
        onChange={(e) => setContent(e.target.value)}
        rows={6}
        className="input w-full font-dm-sans"
      />
      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
        <input
          type="text"
          placeholder="Assessment ID (opsional)"
          value={assessmentId}
          onChange={(e) => setAssessmentId(e.target.value)}
          className="input w-full font-dm-mono text-xs"
        />
        <label className="flex items-center gap-2 text-xs font-dm-sans text-slate-700">
          <input
            type="checkbox"
            checked={isVisibleToClient}
            onChange={(e) => setIsVisibleToClient(e.target.checked)}
            className="rounded border-slate-300 text-sf-deepNavy focus:ring-sf-warmGold/30"
          />
          Publish ke klien (klien bisa lihat di mobile)
        </label>
      </div>
      <div className="flex justify-end gap-2 pt-1">
        <button onClick={onClose} className="btn-secondary text-xs">
          Batal
        </button>
        <button
          onClick={handleSubmit}
          disabled={create.isPending || !content.trim()}
          className="sf-cta-primary text-xs"
        >
          {create.isPending ? (
            <Loader2 className="h-3.5 w-3.5 animate-spin" />
          ) : (
            <Save className="h-3.5 w-3.5" />
          )}
          Simpan
        </button>
      </div>
    </div>
  );
}

// ─── Note Card (display + edit + delete) ─────────────────────────

function NoteCard({ note }: { note: ClinicalNote }) {
  const { user } = useAuth();
  const [editing, setEditing] = useState(false);
  const [confirmDelete, setConfirmDelete] = useState(false);
  const del = useDeleteClinicalNote();

  const canEdit =
    user?.role === "owner" ||
    user?.role === "admin" ||
    (user?.role === "consultant" && (user as any).id === note.consultant_id);

  return (
    <div className="rounded-lg border border-slate-200 bg-white p-4">
      <div className="flex items-start justify-between gap-3 mb-2">
        <div className="min-w-0">
          {note.title && (
            <h3 className="font-semibold text-sf-charcoal font-dm-sans truncate">
              {note.title}
            </h3>
          )}
          <div className="flex flex-wrap items-center gap-2 text-[11px] text-slate-500 font-dm-sans mt-0.5">
            <span>{fmtDateTime(note.created_at)}</span>
            <span>·</span>
            <span>oleh {note.consultant_name ?? "—"}</span>
            {note.assessment_id && (
              <>
                <span>·</span>
                <Link
                  href={`/assessments/${note.assessment_id}`}
                  className="text-sf-deepNavy hover:text-sf-warmGold inline-flex items-center gap-0.5"
                >
                  Asesmen <ExternalLink className="h-2.5 w-2.5" />
                </Link>
              </>
            )}
            <VisibilityBadge visible={note.is_visible_to_client} />
          </div>
        </div>
        {canEdit && !editing && (
          <div className="flex items-center gap-1 shrink-0">
            <button
              onClick={() => setEditing(true)}
              className="p-1.5 rounded hover:bg-slate-100 text-slate-500 hover:text-sf-deepNavy"
              title="Edit"
            >
              <Pencil className="h-3.5 w-3.5" />
            </button>
            <button
              onClick={() => setConfirmDelete(true)}
              className="p-1.5 rounded hover:bg-rose-50 text-slate-400 hover:text-rose-600"
              title="Hapus"
            >
              <Trash2 className="h-3.5 w-3.5" />
            </button>
          </div>
        )}
      </div>

      {editing ? (
        <NoteEditForm note={note} onClose={() => setEditing(false)} />
      ) : (
        <p className="text-sm text-slate-700 font-dm-sans whitespace-pre-wrap leading-relaxed">
          {note.content}
        </p>
      )}

      <ConfirmDialog
        open={confirmDelete}
        onClose={() => setConfirmDelete(false)}
        title="Hapus catatan klinis?"
        description="Catatan akan di-soft-delete (audit history tetap tersimpan, tidak terlihat dari UI)."
        confirmLabel="Hapus"
        variant="danger"
        onConfirm={async () => {
          await del.mutateAsync(note.id);
          setConfirmDelete(false);
        }}
      />
    </div>
  );
}

function VisibilityBadge({ visible }: { visible: boolean }) {
  return visible ? (
    <span className="inline-flex items-center gap-0.5 text-emerald-700">
      <Globe className="h-2.5 w-2.5" /> Published
    </span>
  ) : (
    <span className="inline-flex items-center gap-0.5 text-amber-700">
      <Lock className="h-2.5 w-2.5" /> Draft
    </span>
  );
}

// ─── Edit form ───────────────────────────────────────────────────

function NoteEditForm({ note, onClose }: { note: ClinicalNote; onClose: () => void }) {
  const [title, setTitle] = useState(note.title);
  const [content, setContent] = useState(note.content);
  const [isVisibleToClient, setIsVisibleToClient] = useState(note.is_visible_to_client);
  const update = useUpdateClinicalNote();

  async function save() {
    await update.mutateAsync({
      id: note.id,
      title: title.trim() || undefined,
      content: content.trim(),
      is_visible_to_client: isVisibleToClient,
    });
    onClose();
  }

  return (
    <div className="space-y-2 mt-2">
      <input
        type="text"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        placeholder="Judul (opsional)"
        className="input w-full font-dm-sans text-sm"
      />
      <textarea
        value={content}
        onChange={(e) => setContent(e.target.value)}
        rows={5}
        className="input w-full font-dm-sans text-sm"
      />
      <div className="flex items-center justify-between">
        <label className="flex items-center gap-2 text-xs font-dm-sans text-slate-700">
          <input
            type="checkbox"
            checked={isVisibleToClient}
            onChange={(e) => setIsVisibleToClient(e.target.checked)}
            className="rounded border-slate-300 text-sf-deepNavy focus:ring-sf-warmGold/30"
          />
          Publish ke klien
        </label>
        <div className="flex gap-2">
          <button onClick={onClose} className="btn-secondary text-xs">
            Batal
          </button>
          <button
            onClick={save}
            disabled={update.isPending || !content.trim()}
            className="sf-cta-primary text-xs"
          >
            {update.isPending ? (
              <Loader2 className="h-3.5 w-3.5 animate-spin" />
            ) : (
              <Save className="h-3.5 w-3.5" />
            )}
            Simpan
          </button>
        </div>
      </div>
    </div>
  );
}

// ─── Skeleton ────────────────────────────────────────────────────

function PageSkeleton() {
  return (
    <div className="space-y-4">
      <div className="h-4 w-40 bg-slate-100 rounded animate-pulse" />
      <div className="h-20 bg-slate-100 rounded-xl animate-pulse" />
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <div className="h-48 bg-slate-100 rounded-xl animate-pulse" />
        <div className="h-48 bg-slate-100 rounded-xl animate-pulse" />
      </div>
      <div className="h-64 bg-slate-100 rounded-xl animate-pulse" />
    </div>
  );
}
