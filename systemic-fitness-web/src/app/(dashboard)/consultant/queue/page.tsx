"use client";

import Link from "next/link";
import { useConsultantQueue, type PendingReviewItem } from "@/hooks/useConsultant";
import { EmptyState } from "@/components/shared/EmptyState";
import { ClipboardCheck, Loader2, ArrowRight } from "lucide-react";

// SF Phase 7c — Antrian Review.
// List Asesmen v2 status='submitted' yang belum ada catatan klinis aktif.
// Sumber data: GET /api/v2/consultant/queue.

const PHYSICAL_LEVEL_LABEL: Record<string, string> = {
  level_0_1: "Level 0–1 · Sangat terbatas",
  level_2_3: "Level 2–3 · Mobilitas terbatas",
  level_4_5_perf: "Level 4–5 · Performa",
};

const PROGRAM_TYPE_LABEL: Record<string, string> = {
  condition_specific: "Kondisi Spesifik",
  preventive: "Preventif",
  performance_women_35_45: "Perf · Wanita 35–45",
  performance_women_46_60: "Perf · Wanita 46–60",
  performance_men_35_45: "Perf · Pria 35–45",
  performance_men_46_60: "Perf · Pria 46–60",
  waitlist: "Waitlist",
};

function fmtRelative(iso: string): string {
  const d = new Date(iso);
  const diffMs = Date.now() - d.getTime();
  const mins = Math.floor(diffMs / 60_000);
  if (mins < 60) return `${mins}m yang lalu`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs} jam yang lalu`;
  const days = Math.floor(hrs / 24);
  if (days < 30) return `${days} hari yang lalu`;
  return d.toLocaleDateString("id-ID", { day: "numeric", month: "short", year: "numeric" });
}

export default function ConsultantQueuePage() {
  const { data, isLoading } = useConsultantQueue(200);
  const items = (data?.data ?? []) as PendingReviewItem[];

  return (
    <div className="space-y-5 bg-sf-warmWhite min-h-full -m-6 p-6 rounded-xl">
      <div>
        <h1 className="sf-headline text-3xl">Antrian Review</h1>
        <p className="sf-body text-sm text-slate-500 mt-1 max-w-3xl">
          Daftar Asesmen v2 yang belum Anda tinjau. Buka detail klien untuk membaca
          jawaban Phase A/B/C dan menulis catatan klinis. Antrian diurutkan dari
          submisi terlama.
        </p>
      </div>

      {isLoading ? (
        <div className="flex justify-center py-20">
          <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
        </div>
      ) : items.length === 0 ? (
        <EmptyState
          icon={ClipboardCheck}
          title="Antrian kosong"
          description="Semua Asesmen v2 sudah ditinjau. Catatan klinis baru akan kembali memunculkan asesmen kalau dihapus."
        />
      ) : (
        <>
          <div className="text-xs text-slate-500 font-dm-sans">
            Total: <span className="font-semibold text-sf-charcoal">{items.length}</span> asesmen menunggu
          </div>
          <div className="card overflow-hidden">
            <table className="w-full text-sm">
              <thead className="bg-slate-50 border-b border-slate-200">
                <tr>
                  <th className="text-left px-4 py-3 font-semibold text-slate-600">Klien</th>
                  <th className="text-left px-4 py-3 font-semibold text-slate-600">Email</th>
                  <th className="text-left px-4 py-3 font-semibold text-slate-600">Level Fisik</th>
                  <th className="text-left px-4 py-3 font-semibold text-slate-600">Program</th>
                  <th className="text-center px-4 py-3 font-semibold text-slate-600">System Score</th>
                  <th className="text-left px-4 py-3 font-semibold text-slate-600">Submisi</th>
                  <th className="text-right px-4 py-3 font-semibold text-slate-600">Aksi</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {items.map((it) => (
                  <tr key={it.assessment_id} className="hover:bg-sf-iceBlue/40">
                    <td className="px-4 py-3 font-medium text-sf-charcoal font-dm-sans">
                      {it.user_name ?? "—"}
                    </td>
                    <td className="px-4 py-3 text-slate-600 font-dm-sans text-xs">
                      {it.user_email ?? "—"}
                    </td>
                    <td className="px-4 py-3 text-xs text-slate-600 font-dm-sans">
                      {it.physical_status_level
                        ? PHYSICAL_LEVEL_LABEL[it.physical_status_level] ?? it.physical_status_level
                        : "—"}
                    </td>
                    <td className="px-4 py-3 text-xs text-slate-600 font-dm-sans">
                      {it.program_type
                        ? PROGRAM_TYPE_LABEL[it.program_type] ?? it.program_type
                        : "—"}
                    </td>
                    <td className="px-4 py-3 text-center font-dm-mono text-sm text-sf-charcoal">
                      {it.system_score != null ? Number(it.system_score).toFixed(1) : "—"}
                    </td>
                    <td className="px-4 py-3 text-xs text-slate-500 font-dm-sans">
                      {fmtRelative(it.created_at)}
                    </td>
                    <td className="px-4 py-3 text-right">
                      {it.user_id ? (
                        <Link
                          href={`/consultant/clients/${it.user_id}?assessment=${it.assessment_id}`}
                          className="inline-flex items-center gap-1.5 text-xs font-semibold text-sf-deepNavy hover:text-sf-warmGold transition-colors"
                        >
                          Tinjau
                          <ArrowRight className="h-3.5 w-3.5" />
                        </Link>
                      ) : (
                        <span className="text-xs text-slate-400">—</span>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      )}
    </div>
  );
}
