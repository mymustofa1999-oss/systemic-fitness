"use client";

import { useState } from "react";
import {
  useTier4Waitlist,
  useUpdateTier4WaitlistStatus,
  type Tier4WaitlistEntry,
  type WaitlistStatus,
} from "@/hooks/usePhaseSix";
import { Loader2, Hourglass, Mail, Phone, MapPin, X } from "lucide-react";
import { SearchableSelect } from "@/components/shared/SearchableSelect";
import { EmptyState } from "@/components/shared/EmptyState";
import { cn } from "@/lib/utils";

// SF Phase 6 — Daftar minat Tier 4 (Trainer on-site) + Level 0–3 mobility.

const STATUS_OPTIONS = [
  { value: "", label: "Semua status" },
  { value: "new", label: "Baru" },
  { value: "contacted", label: "Sudah dihubungi" },
  { value: "converted", label: "Convert" },
  { value: "closed", label: "Closed" },
];

const SOURCE_OPTIONS = [
  { value: "", label: "Semua source" },
  { value: "tier4", label: "Tier 4 — System Elite" },
  { value: "level_0_3", label: "Level 0–3 mobility" },
  { value: "other", label: "Lainnya" },
];

function statusColor(s: WaitlistStatus) {
  switch (s) {
    case "new": return "bg-amber-50 text-amber-700";
    case "contacted": return "bg-sky-50 text-sky-700";
    case "converted": return "bg-emerald-50 text-emerald-700";
    case "closed": return "bg-slate-100 text-slate-500";
  }
}

function sourceLabel(s: string) {
  return s === "tier4"
    ? "Tier 4"
    : s === "level_0_3"
    ? "Level 0–3"
    : s;
}

export default function Tier4WaitlistPage() {
  const [status, setStatus] = useState("");
  const [source, setSource] = useState("");

  const { data, isLoading } = useTier4Waitlist({
    status: status || undefined,
    source: source || undefined,
  });
  const update = useUpdateTier4WaitlistStatus();
  const items = (data?.data ?? []) as Tier4WaitlistEntry[];

  const [detail, setDetail] = useState<Tier4WaitlistEntry | null>(null);
  const [adminNote, setAdminNote] = useState("");
  const [draftStatus, setDraftStatus] = useState<WaitlistStatus>("new");

  function openDetail(item: Tier4WaitlistEntry) {
    setDetail(item);
    setDraftStatus(item.status);
    setAdminNote(item.admin_note ?? "");
  }

  async function handleSave() {
    if (!detail) return;
    await update.mutateAsync({
      id: detail.id,
      status: draftStatus,
      admin_note: adminNote.trim() || undefined,
    });
    setDetail(null);
  }

  return (
    <div className="space-y-5 bg-sf-warmWhite min-h-full -m-6 p-6 rounded-xl">
      <div>
        <h1 className="sf-headline text-3xl">Tier 4 Waitlist</h1>
        <p className="sf-body text-sm text-slate-500 mt-1 max-w-3xl">
          Daftar klien yang ingin menjadi prioritas saat program Tier 4 (System Elite — Trainer on-site)
          atau program Level 0–3 dibuka. Hubungi mereka secara berkala dan tandai status di sini.
        </p>
      </div>

      <div className="flex flex-wrap items-center gap-3">
        <div className="w-56">
          <SearchableSelect
            options={STATUS_OPTIONS}
            value={status}
            onChange={setStatus}
            placeholder="Filter status"
          />
        </div>
        <div className="w-56">
          <SearchableSelect
            options={SOURCE_OPTIONS}
            value={source}
            onChange={setSource}
            placeholder="Filter source"
          />
        </div>
      </div>

      {isLoading ? (
        <div className="flex justify-center py-20">
          <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
        </div>
      ) : items.length === 0 ? (
        <EmptyState
          icon={Hourglass}
          title="Belum ada entri waitlist"
          description="Klien yang daftar via mobile akan muncul di sini."
        />
      ) : (
        <div className="card overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 border-b border-slate-200">
              <tr>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Nama</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Email</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Telepon</th>
                <th className="text-center px-4 py-3 font-semibold text-slate-600">Source</th>
                <th className="text-center px-4 py-3 font-semibold text-slate-600">Status</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Daftar pada</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {items.map((e) => (
                <tr
                  key={e.id}
                  onClick={() => openDetail(e)}
                  className="hover:bg-sf-iceBlue/40 cursor-pointer"
                >
                  <td className="px-4 py-3 font-medium text-sf-charcoal font-dm-sans">
                    {e.full_name}
                  </td>
                  <td className="px-4 py-3 text-slate-600 font-dm-sans text-xs">{e.email}</td>
                  <td className="px-4 py-3 text-slate-600 font-dm-mono text-xs">
                    {e.phone ?? "—"}
                  </td>
                  <td className="px-4 py-3 text-center">
                    <span className="inline-flex px-2 py-0.5 text-xs font-medium rounded-full bg-slate-100 text-slate-700">
                      {sourceLabel(e.source)}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-center">
                    <span
                      className={cn(
                        "inline-flex px-2 py-0.5 text-xs font-semibold rounded-full uppercase tracking-wider",
                        statusColor(e.status),
                      )}
                    >
                      {e.status}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-slate-500 text-xs font-dm-mono">
                    {new Date(e.created_at).toLocaleString("id-ID", {
                      dateStyle: "medium",
                      timeStyle: "short",
                    })}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Detail / status update modal */}
      {detail && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
          <div className="bg-white rounded-xl shadow-xl w-full max-w-lg mx-4 p-6 space-y-4 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between">
              <h2 className="sf-headline text-xl">{detail.full_name}</h2>
              <button onClick={() => setDetail(null)} className="p-1 rounded hover:bg-slate-100">
                <X className="h-5 w-5 text-slate-400" />
              </button>
            </div>

            <div className="space-y-2 text-sm font-dm-sans">
              <div className="flex items-center gap-2 text-slate-600">
                <Mail className="h-4 w-4" />
                <span>{detail.email}</span>
              </div>
              {detail.phone && (
                <div className="flex items-center gap-2 text-slate-600">
                  <Phone className="h-4 w-4" />
                  <span>{detail.phone}</span>
                </div>
              )}
              {detail.city && (
                <div className="flex items-center gap-2 text-slate-600">
                  <MapPin className="h-4 w-4" />
                  <span>{detail.city}</span>
                </div>
              )}
            </div>

            <div className="rounded-lg bg-slate-50 p-3 text-xs font-dm-sans space-y-1">
              <div>
                <span className="text-slate-500">Source: </span>
                <span className="font-medium">{sourceLabel(detail.source)}</span>
              </div>
              {detail.note && (
                <div>
                  <span className="text-slate-500">Catatan klien: </span>
                  <span className="italic">&ldquo;{detail.note}&rdquo;</span>
                </div>
              )}
              {detail.contacted_at && (
                <div>
                  <span className="text-slate-500">Dihubungi: </span>
                  <span>
                    {new Date(detail.contacted_at).toLocaleString("id-ID", {
                      dateStyle: "medium",
                      timeStyle: "short",
                    })}
                  </span>
                </div>
              )}
            </div>

            <div>
              <label className="block text-xs font-medium text-slate-600 mb-1.5 font-dm-sans">
                Status
              </label>
              <SearchableSelect
                options={STATUS_OPTIONS.filter((o) => o.value !== "")}
                value={draftStatus}
                onChange={(v) => setDraftStatus(v as WaitlistStatus)}
                placeholder="Pilih status..."
              />
            </div>

            <div>
              <label className="block text-xs font-medium text-slate-600 mb-1.5 font-dm-sans">
                Catatan admin (opsional)
              </label>
              <textarea
                value={adminNote}
                onChange={(e) => setAdminNote(e.target.value)}
                rows={3}
                className="input w-full font-dm-sans"
                placeholder="Hasil percakapan, alasan close, dll..."
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
