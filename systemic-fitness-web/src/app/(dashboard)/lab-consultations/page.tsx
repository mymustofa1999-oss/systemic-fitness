"use client";

import { useState, useMemo } from "react";
import {
  useLabConsultations,
  useUpdateLabConsultation,
  type LabConsultation,
  type LabStatus,
} from "@/hooks/usePhaseSix";
import { useAssignLabConsultant } from "@/hooks/useConsultant";
import { useUsers } from "@/hooks/useUsers";
import { Loader2, FlaskConical, X, UserCheck } from "lucide-react";
import { SearchableSelect } from "@/components/shared/SearchableSelect";
import { EmptyState } from "@/components/shared/EmptyState";
import { cn } from "@/lib/utils";

// SF Phase 6 — Daftar booking Lab Consultation untuk konsultasi & hasil.
// Tier 3 wajib book sebelum program aktif.

const STATUS_OPTIONS = [
  { value: "", label: "Semua status" },
  { value: "pending", label: "Pending" },
  { value: "scheduled", label: "Dijadwalkan" },
  { value: "completed", label: "Selesai" },
  { value: "cancelled", label: "Batal" },
  { value: "no_show", label: "Tidak hadir" },
];

function statusColor(s: LabStatus) {
  switch (s) {
    case "pending": return "bg-amber-50 text-amber-700";
    case "scheduled": return "bg-sky-50 text-sky-700";
    case "completed": return "bg-emerald-50 text-emerald-700";
    case "cancelled": return "bg-rose-50 text-rose-700";
    case "no_show": return "bg-slate-100 text-slate-500";
  }
}

function fmtDateTime(iso: string | null | undefined) {
  if (!iso) return "—";
  return new Date(iso).toLocaleString("id-ID", {
    dateStyle: "medium",
    timeStyle: "short",
  });
}

export default function LabConsultationsPage() {
  const [status, setStatus] = useState("");
  const { data, isLoading } = useLabConsultations({ status: status || undefined });
  const update = useUpdateLabConsultation();
  const assign = useAssignLabConsultant();

  // SF Phase 7d — fetch consultants for assign dropdown.
  const { data: consultantsData } = useUsers({ role: "consultant", limit: 100 });
  const consultantOptions = useMemo(() => {
    const list = ((consultantsData as any)?.data ?? []) as Array<{
      id: string;
      full_name: string;
      email: string;
    }>;
    return [
      { value: "", label: "— Belum di-assign —" },
      ...list.map((u) => ({ value: u.id, label: `${u.full_name} (${u.email})` })),
    ];
  }, [consultantsData]);

  const items = (data?.data ?? []) as LabConsultation[];

  const [detail, setDetail] = useState<LabConsultation | null>(null);
  const [draftStatus, setDraftStatus] = useState<LabStatus>("pending");
  const [scheduledAt, setScheduledAt] = useState("");
  const [resultSummary, setResultSummary] = useState("");
  const [draftConsultantId, setDraftConsultantId] = useState("");

  function openDetail(item: LabConsultation) {
    setDetail(item);
    setDraftStatus(item.status);
    setScheduledAt(item.scheduled_at ? item.scheduled_at.slice(0, 16) : "");
    setResultSummary(item.result_summary ?? "");
    setDraftConsultantId(item.consultant_id ?? "");
  }

  async function handleAssignConsultant() {
    if (!detail || !draftConsultantId) return;
    await assign.mutateAsync({ id: detail.id, consultant_id: draftConsultantId });
    setDetail(null);
  }

  async function handleSave() {
    if (!detail) return;
    await update.mutateAsync({
      id: detail.id,
      status: draftStatus,
      scheduled_at: scheduledAt ? new Date(scheduledAt).toISOString() : undefined,
      result_summary: resultSummary.trim() || undefined,
      completed_at: draftStatus === "completed" ? new Date().toISOString() : undefined,
      // consultant_id always sent so empty string clears assignment when needed
      consultant_id: draftConsultantId || undefined,
    });
    setDetail(null);
  }

  return (
    <div className="space-y-5 bg-sf-warmWhite min-h-full -m-6 p-6 rounded-xl">
      <div>
        <h1 className="sf-headline text-3xl">Lab Consultations</h1>
        <p className="sf-body text-sm text-slate-500 mt-1 max-w-3xl">
          Booking pembacaan biomarker oleh Health Consultant. Wajib untuk Tier 3 sebelum program aktif,
          opsional untuk Tier 1–2. Fee default Rp 350.000.
        </p>
      </div>

      <div className="flex items-center gap-3">
        <div className="w-56">
          <SearchableSelect
            options={STATUS_OPTIONS}
            value={status}
            onChange={setStatus}
            placeholder="Filter status"
          />
        </div>
      </div>

      {isLoading ? (
        <div className="flex justify-center py-20">
          <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
        </div>
      ) : items.length === 0 ? (
        <EmptyState
          icon={FlaskConical}
          title="Belum ada Lab Consultation"
          description="Booking dari klien akan muncul di sini."
        />
      ) : (
        <div className="card overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 border-b border-slate-200">
              <tr>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Klien</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Email</th>
                <th className="text-center px-4 py-3 font-semibold text-slate-600">Status</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Preferred</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Scheduled</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Konsultan</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Booking pada</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {items.map((l) => (
                <tr
                  key={l.id}
                  onClick={() => openDetail(l)}
                  className="hover:bg-sf-iceBlue/40 cursor-pointer"
                >
                  <td className="px-4 py-3 font-medium text-sf-charcoal font-dm-sans">
                    {l.user_name ?? "—"}
                  </td>
                  <td className="px-4 py-3 text-slate-600 font-dm-sans text-xs">
                    {l.user_email ?? "—"}
                  </td>
                  <td className="px-4 py-3 text-center">
                    <span
                      className={cn(
                        "inline-flex px-2 py-0.5 text-xs font-semibold rounded-full uppercase tracking-wider",
                        statusColor(l.status),
                      )}
                    >
                      {l.status}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-xs font-dm-mono text-slate-600">
                    {fmtDateTime(l.preferred_at)}
                  </td>
                  <td className="px-4 py-3 text-xs font-dm-mono text-slate-600">
                    {fmtDateTime(l.scheduled_at)}
                  </td>
                  <td className="px-4 py-3 text-xs text-slate-600 font-dm-sans">
                    {l.consultant_name ?? "—"}
                  </td>
                  <td className="px-4 py-3 text-xs font-dm-mono text-slate-500">
                    {fmtDateTime(l.created_at)}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Detail / update modal */}
      {detail && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
          <div className="bg-white rounded-xl shadow-xl w-full max-w-lg mx-4 p-6 space-y-4 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between">
              <h2 className="sf-headline text-xl">{detail.user_name ?? "Lab Consultation"}</h2>
              <button onClick={() => setDetail(null)} className="p-1 rounded hover:bg-slate-100">
                <X className="h-5 w-5 text-slate-400" />
              </button>
            </div>

            <div className="rounded-lg bg-slate-50 p-3 space-y-1 text-xs font-dm-sans">
              <div>
                <span className="text-slate-500">Email: </span>
                <span>{detail.user_email ?? "—"}</span>
              </div>
              <div>
                <span className="text-slate-500">Fee: </span>
                <span className="font-dm-mono">
                  Rp {detail.fee_amount.toLocaleString("id-ID")}
                </span>
              </div>
              <div>
                <span className="text-slate-500">Preferred at: </span>
                <span>{fmtDateTime(detail.preferred_at)}</span>
              </div>
              {detail.booking_note && (
                <div>
                  <span className="text-slate-500">Catatan klien: </span>
                  <span className="italic">&ldquo;{detail.booking_note}&rdquo;</span>
                </div>
              )}
            </div>

            {/* SF Phase 7d — Assign Consultant */}
            <div>
              <label className="block text-xs font-medium text-slate-600 mb-1.5 font-dm-sans flex items-center gap-1.5">
                <UserCheck className="h-3.5 w-3.5" /> Health Consultant
              </label>
              <div className="flex items-center gap-2">
                <div className="flex-1">
                  <SearchableSelect
                    options={consultantOptions}
                    value={draftConsultantId}
                    onChange={setDraftConsultantId}
                    placeholder="Pilih consultant"
                  />
                </div>
                <button
                  onClick={handleAssignConsultant}
                  disabled={
                    assign.isPending ||
                    !draftConsultantId ||
                    draftConsultantId === (detail.consultant_id ?? "")
                  }
                  className="btn-secondary text-xs whitespace-nowrap"
                  title="Assign saja, tanpa ubah field lain (auto-bump status pending → scheduled)"
                >
                  {assign.isPending ? <Loader2 className="h-3.5 w-3.5 animate-spin" /> : "Assign"}
                </button>
              </div>
              {detail.consultant_name && (
                <p className="text-[11px] text-slate-500 font-dm-sans mt-1">
                  Saat ini: <span className="font-semibold">{detail.consultant_name}</span>
                </p>
              )}
            </div>

            <div>
              <label className="block text-xs font-medium text-slate-600 mb-1.5 font-dm-sans">
                Status
              </label>
              <SearchableSelect
                options={STATUS_OPTIONS.filter((o) => o.value !== "")}
                value={draftStatus}
                onChange={(v) => setDraftStatus(v as LabStatus)}
              />
            </div>

            <div>
              <label className="block text-xs font-medium text-slate-600 mb-1.5 font-dm-sans">
                Jadwal sesi
              </label>
              <input
                type="datetime-local"
                value={scheduledAt}
                onChange={(e) => setScheduledAt(e.target.value)}
                className="input w-full font-dm-sans"
              />
            </div>

            <div>
              <label className="block text-xs font-medium text-slate-600 mb-1.5 font-dm-sans">
                Ringkasan hasil (Consultant fill)
              </label>
              <textarea
                value={resultSummary}
                onChange={(e) => setResultSummary(e.target.value)}
                rows={4}
                className="input w-full font-dm-sans"
                placeholder="Hasil pembacaan biomarker, rekomendasi program awal, catatan medis..."
              />
            </div>

            <div className="flex justify-end gap-2 pt-2">
              <button onClick={() => setDetail(null)} className="btn-secondary">
                Batal
              </button>
              <button
                onClick={handleSave}
                disabled={update.isPending}
                className="sf-cta-primary"
              >
                {update.isPending && <Loader2 className="h-4 w-4 animate-spin" />}
                Simpan
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
