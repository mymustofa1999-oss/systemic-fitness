"use client";

import { useState } from "react";
import Link from "next/link";
import { useTemplates, useDeleteTemplate } from "@/hooks/useTrainerCardTemplates";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { Plus, Pencil, Trash2, Loader2, Layers } from "lucide-react";

// Tiers that own a training-card template. "free" is the program shown to
// registered-but-unpaid clients; "5-6" is the paid performance tier.
const LEVELS = ["free", "5-6"];

const LEVEL_LABELS: Record<string, string> = {
  free: "Free",
  "5-6": "Level 5-6",
};

const LEVEL_DESCRIPTIONS: Record<string, string> = {
  free: "Program yang tampil untuk client yang sudah daftar tapi belum berlangganan (tier Free).",
  "5-6": "Program untuk client tier berbayar level fisik 5-6.",
};

const levelLabel = (lvl: string) => LEVEL_LABELS[lvl] ?? `Level ${lvl}`;

export default function TemplatesListPage() {
  const { data: templatesResponse, isLoading } = useTemplates();
  const deleteTemplate = useDeleteTemplate();

  const [deleteLevel, setDeleteLevel] = useState<string | null>(null);

  const templates = (templatesResponse?.data as any) || [];
  const activeLevelMap = new Map(templates.map((t: any) => [t.level, t]));

  async function handleDelete() {
    if (!deleteLevel) return;
    await deleteTemplate.mutateAsync(deleteLevel);
    setDeleteLevel(null);
  }

  if (isLoading) {
    return (
      <div className="flex justify-center py-20">
        <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
      </div>
    );
  }

  return (
    <div className="space-y-6 max-w-[1200px]">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">Training Card Templates</h1>
          <p className="text-sm text-slate-500 mt-1">
            Kelola template default untuk sequence, set, durasi, dan gerakan di setiap level fisik client.
          </p>
        </div>
      </div>

      <div className="bg-white border border-slate-200 rounded-lg overflow-hidden shadow-sm">
        <table className="w-full text-sm border-collapse text-left">
          <thead>
            <tr className="bg-slate-50 border-b border-slate-200 text-xs font-bold text-slate-600 uppercase tracking-wider">
              <th className="px-6 py-4">Level</th>
              <th className="px-6 py-4">Status</th>
              <th className="px-6 py-4">Catatan</th>
              <th className="px-6 py-4 text-right">Aksi</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {LEVELS.map((lvl) => {
              const tmpl = activeLevelMap.get(lvl) as any;
              const isCreated = !!tmpl;

              return (
                <tr key={lvl} className="hover:bg-slate-50/50 transition-colors">
                  <td className="px-6 py-4 font-semibold text-slate-900">
                    <span className="flex items-center gap-2">
                      <Layers className="h-4 w-4 text-sf-warmGold" />
                      {levelLabel(lvl)}
                      {lvl === "free" && (
                        <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold bg-sf-warmGold/10 text-sf-warmGold border border-sf-warmGold/20 uppercase tracking-wide">
                          Tanpa Bayar
                        </span>
                      )}
                    </span>
                    <span className="block text-xs font-normal text-slate-400 mt-1 max-w-md">
                      {LEVEL_DESCRIPTIONS[lvl]}
                    </span>
                  </td>
                  <td className="px-6 py-4">
                    {isCreated ? (
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-emerald-50 text-emerald-700 border border-emerald-200">
                        Aktif
                      </span>
                    ) : (
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-500 border border-slate-200">
                        Belum Dibuat
                      </span>
                    )}
                  </td>
                  <td className="px-6 py-4 text-slate-600 italic text-xs max-w-md truncate">
                    {isCreated && tmpl.notes ? tmpl.notes : "-"}
                  </td>
                  <td className="px-6 py-4 text-right">
                    <div className="flex items-center justify-end gap-2">
                      {isCreated ? (
                        <>
                          <Link
                            href={`/training-card-templates/${lvl}`}
                            className="inline-flex items-center gap-1 px-3 py-1.5 text-xs font-medium text-slate-700 hover:text-slate-900 bg-slate-100 hover:bg-slate-200 rounded-md transition-colors"
                          >
                            <Pencil className="h-3 w-3" /> Edit
                          </Link>
                          <button
                            onClick={() => setDeleteLevel(lvl)}
                            className="inline-flex items-center gap-1 px-3 py-1.5 text-xs font-medium text-white bg-red-500 hover:bg-red-600 rounded-md transition-colors"
                          >
                            <Trash2 className="h-3 w-3" /> Hapus
                          </button>
                        </>
                      ) : (
                        <Link
                          href={`/training-card-templates/${lvl}`}
                          className="inline-flex items-center gap-1 px-3 py-1.5 text-xs font-medium text-white bg-sf-deepNavy hover:bg-sf-deepNavy/90 rounded-md transition-colors"
                        >
                          <Plus className="h-3 w-3" /> Buat Template
                        </Link>
                      )}
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      <ConfirmDialog
        open={!!deleteLevel}
        onClose={() => setDeleteLevel(null)}
        onConfirm={handleDelete}
        title="Hapus Template?"
        description={`Semua data sequence, set, dan gerakan template untuk ${deleteLevel ? levelLabel(deleteLevel) : ""} akan dihapus secara permanen.`}
        confirmLabel="Hapus"
        variant="danger"
        loading={deleteTemplate.isPending}
      />
    </div>
  );
}
