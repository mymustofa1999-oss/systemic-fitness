"use client";

import Link from "next/link";
import { useConsultantClients, type ConsultantClient } from "@/hooks/useConsultant";
import { EmptyState } from "@/components/shared/EmptyState";
import { UsersRound, Loader2, FileText, FlaskConical, ArrowRight } from "lucide-react";

// SF Phase 7c — Klien Saya.
// Distinct klien yang pernah Anda sentuh via clinical_notes ATAU lab_consultations.
// Sumber: GET /api/v2/consultant/clients.

function fmtDate(iso: string): string {
  return new Date(iso).toLocaleDateString("id-ID", {
    day: "numeric",
    month: "short",
    year: "numeric",
  });
}

export default function ConsultantClientsPage() {
  const { data, isLoading } = useConsultantClients();
  const items = (data?.data ?? []) as ConsultantClient[];

  return (
    <div className="space-y-5 bg-sf-warmWhite min-h-full -m-6 p-6 rounded-xl">
      <div>
        <h1 className="sf-headline text-3xl">Klien Saya</h1>
        <p className="sf-body text-sm text-slate-500 mt-1 max-w-3xl">
          Klien yang pernah Anda layani — entah lewat catatan klinis atau Lab
          Consultation. Klik salah satu untuk membuka histori interaksi dan
          menulis catatan baru.
        </p>
      </div>

      {isLoading ? (
        <div className="flex justify-center py-20">
          <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
        </div>
      ) : items.length === 0 ? (
        <EmptyState
          icon={UsersRound}
          title="Belum ada klien"
          description="Klien akan muncul di sini setelah Anda menulis catatan klinis pertama atau di-assign ke Lab Consultation."
        />
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          {items.map((c) => (
            <Link
              key={c.client_id}
              href={`/consultant/clients/${c.client_id}`}
              className="card p-5 hover:shadow-md hover:border-sf-warmGold/40 transition-all"
            >
              <div className="flex items-start justify-between gap-3 mb-3">
                <div className="min-w-0">
                  <h3 className="sf-headline text-lg truncate">{c.client_name ?? "—"}</h3>
                  <p className="text-xs text-slate-500 font-dm-sans truncate">
                    {c.client_email ?? "—"}
                  </p>
                </div>
                <ArrowRight className="h-4 w-4 text-slate-300 shrink-0 mt-1" />
              </div>

              <div className="flex items-center gap-3 text-xs font-dm-sans text-slate-600">
                <span className="inline-flex items-center gap-1.5">
                  <FileText className="h-3.5 w-3.5 text-sf-deepNavy" />
                  <span className="font-semibold">{c.note_count}</span>
                  <span className="text-slate-500">catatan</span>
                </span>
                <span className="text-slate-300">·</span>
                <span className="inline-flex items-center gap-1.5">
                  <FlaskConical className="h-3.5 w-3.5 text-sf-warmGold" />
                  <span className="font-semibold">{c.lab_count}</span>
                  <span className="text-slate-500">lab</span>
                </span>
              </div>

              <div className="mt-3 pt-3 border-t border-slate-100 text-[11px] text-slate-400 font-dm-mono">
                Interaksi terakhir · {fmtDate(c.last_interaction)}
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
