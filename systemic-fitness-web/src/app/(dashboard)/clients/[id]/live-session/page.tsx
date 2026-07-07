"use client";

import { useState, useMemo } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useUser } from "@/hooks/useUsers";
import { useTrainerCard } from "@/hooks/useNewFeatures";
import { useDLMovements } from "@/hooks/useDigitalLibrary";
import { ArrowLeft, SkipForward, SkipBack, CheckCircle2, ChevronRight, Video, X } from "lucide-react";
import { cn } from "@/lib/utils";
import { toast } from "@/stores/toastStore";
import { useAuth } from "@/hooks/useAuth";

// ─── Modal Rating ────────────────────────────────────────────────────────
function EndSessionModal({ isOpen, onClose, onFinish, isTrainer }: { isOpen: boolean; onClose: () => void; onFinish: (rating: number, notes: string) => void; isTrainer: boolean }) {
  const [rating, setRating] = useState(0);
  const [notes, setNotes] = useState("");

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
      <div className="bg-white rounded-2xl shadow-xl w-full max-w-md overflow-hidden">
        <div className="p-5 border-b border-slate-100 flex items-center justify-between">
          <h2 className="font-bold text-lg text-slate-800">Akhiri Sesi Latihan</h2>
          <button onClick={onClose} className="p-1 hover:bg-slate-100 rounded-full text-slate-400 hover:text-slate-600"><X className="h-5 w-5" /></button>
        </div>
        
        <div className="p-6 space-y-6">
          <div className="text-center">
            <div className="mx-auto w-16 h-16 bg-green-100 text-green-600 rounded-full flex items-center justify-center mb-3">
              <CheckCircle2 className="h-8 w-8" />
            </div>
            <h3 className="font-bold text-xl text-slate-800">Latihan Selesai!</h3>
            <p className="text-sm text-slate-500 mt-1">Laporan sesi ini akan disimpan ke dalam jurnal klien.</p>
          </div>

          {!isTrainer && (
            <div className="bg-slate-50 p-4 rounded-xl border border-slate-100">
              <p className="text-sm font-semibold text-slate-700 mb-3 text-center">Beri Penilaian untuk Trainer Anda</p>
              <div className="flex justify-center gap-2 mb-4">
                {[1, 2, 3, 4, 5].map((star) => (
                  <button
                    key={star}
                    onClick={() => setRating(star)}
                    className={cn("p-1 transition-colors", rating >= star ? "text-yellow-400" : "text-slate-300")}
                  >
                    <svg className="h-8 w-8" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                  </button>
                ))}
              </div>
              <div className="space-y-1">
                <label className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Catatan Tambahan</label>
                <textarea
                  value={notes}
                  onChange={(e) => setNotes(e.target.value)}
                  placeholder="Bagaimana performa trainer hari ini?"
                  className="w-full text-sm border border-slate-200 rounded-lg p-3 h-24 focus:outline-none focus:ring-2 focus:ring-sf-warmGold/50"
                />
              </div>
            </div>
          )}

          {isTrainer && (
            <div className="bg-slate-50 p-4 rounded-xl border border-slate-100">
              <p className="text-sm text-slate-600 text-center mb-3">Sesi telah selesai direkam. Mintalah klien Anda untuk mengisi form evaluasi/rating dari portal mereka untuk absensi.</p>
              <div className="space-y-1">
                <label className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Catatan Sesi (Opsional)</label>
                <textarea
                  value={notes}
                  onChange={(e) => setNotes(e.target.value)}
                  placeholder="Catatan latihan hari ini untuk klien..."
                  className="w-full text-sm border border-slate-200 rounded-lg p-3 h-24 focus:outline-none focus:ring-2 focus:ring-sf-warmGold/50"
                />
              </div>
            </div>
          )}

        </div>

        <div className="p-5 border-t border-slate-100 bg-slate-50 flex justify-end gap-3">
          <button onClick={onClose} className="px-5 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-200 bg-slate-100 rounded-lg transition-colors">Batal</button>
          <button onClick={() => onFinish(rating, notes)} className="px-5 py-2 text-sm font-bold text-white bg-sf-deepNavy hover:bg-slate-800 rounded-lg transition-colors">
            Simpan & Selesai
          </button>
        </div>
      </div>
    </div>
  );
}

// ─── Main Page ────────────────────────────────────────────────────────
export default function LiveSessionPage({ params }: { params: { id: string } }) {
  const customerId = params.id;
  const router = useRouter();
  const { isTrainer } = useAuth();
  const { data: userData } = useUser(customerId);
  const { data: cardData } = useTrainerCard(customerId);
  const { data: movementsData } = useDLMovements({ limit: 1000 });

  const [currentIndex, setCurrentIndex] = useState(0);
  const [showEndModal, setShowEndModal] = useState(false);

  const playlist = useMemo(() => {
    const data = cardData?.data as any;
    if (!data?.sequences) return [];
    
    const clientGender = (userData?.data as any)?.profile?.gender?.toLowerCase() === "male" ? "male" : "female";
    const allMovements = (movementsData?.data ?? []) as any[];
    
    const items: any[] = [];
    
    data.sequences.forEach((seq: any, sIdx: number) => {
      seq.sets?.forEach((set: any, setIdx: number) => {
        set.items?.forEach((item: any, itemIdx: number) => {
          // Find movement details
          const movement = allMovements.find((m) => m.id === item.movement_id);
          
          let videoUrl = null;
          if (movement) {
            videoUrl = clientGender === "male" ? movement.video_url_male : movement.video_url_female;
            // fallback if preferred gender video is missing
            if (!videoUrl) videoUrl = movement.video_url_male || movement.video_url_female;
          }

          items.push({
            id: `${sIdx}-${setIdx}-${itemIdx}`,
            sequenceName: seq.name || `Bagian ${sIdx + 1}`,
            movementName: movement?.name || item.movement_name || "Gerakan tidak diketahui",
            videoUrl,
            reps: item.reps || set.parameter_reps || "-",
            sets: item.sets_count || set.parameter_sets || "-",
            duration: set.duration || set.parameter_duration || "-",
            rest: set.parameter_rest || "-",
            bpm: set.bpm || ((set.bpm_lower && set.bpm_upper) ? `${set.bpm_lower}-${set.bpm_upper}` : "-"),
            beban: item.extra_load || set.extra_load || ((set.beban_lower_value && set.beban_upper_value) ? `${set.beban_lower_value}-${set.beban_upper_value}` : "-"),
            isLevel1: !!set.breathing_core,
            breathing_core: set.breathing_core || "-",
            breathing_diaphragm: set.breathing_diaphragm || "-",
            seqIndex: sIdx,
            setIndex: setIdx,
            itemIndex: itemIdx
          });
        });
      });
    });

    return items;
  }, [cardData, userData, movementsData]);

  if (!cardData || !movementsData) return <div className="p-8 text-center text-slate-500">Memuat sesi...</div>;
  if (playlist.length === 0) return (
    <div className="p-8 text-center space-y-4">
      <p className="text-slate-500">Training Card kosong atau belum dibuat.</p>
      <Link href={`/clients/${customerId}/training-card`} className="text-sf-deepNavy font-bold">Kembali</Link>
    </div>
  );

  const currentItem = playlist[currentIndex];
  const isFirst = currentIndex === 0;
  const isLast = currentIndex === playlist.length - 1;

  const handleFinish = async (_rating: number, _notes: string) => {
    // TODO: Connect this to actual backend endpoint when available
    toast.success("Sesi latihan berhasil diselesaikan!");
    router.push(`/clients/${customerId}/training-card`);
  };

  return (
    <div className="max-w-4xl mx-auto space-y-6 pb-20">
      <div className="flex items-center justify-between">
        <Link href={`/clients/${customerId}/training-card`} className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-slate-700">
          <ArrowLeft className="h-4 w-4" /> Batal / Kembali
        </Link>
        <span className="px-3 py-1 bg-green-100 text-green-700 font-bold text-xs uppercase tracking-wider rounded-full flex items-center gap-1.5">
          <span className="w-2 h-2 rounded-full bg-green-500 animate-pulse" /> Live Session
        </span>
      </div>

      <div className="bg-sf-deepNavy rounded-2xl overflow-hidden shadow-xl ring-1 ring-slate-900/10">
        
        {/* VIDEO PLAYER AREA */}
        <div className="aspect-video bg-black relative flex items-center justify-center">
          {currentItem.videoUrl ? (
            <video 
              key={currentItem.videoUrl} 
              src={currentItem.videoUrl} 
              className="w-full h-full object-contain"
              controls
              autoPlay
              muted
              loop
              playsInline
            />
          ) : (
            <div className="flex flex-col items-center justify-center text-slate-400 space-y-3">
              <Video className="w-16 h-16 opacity-30" />
              <p>Video tidak tersedia untuk gerakan ini</p>
            </div>
          )}
          
          {/* Top overlay sequence name */}
          <div className="absolute top-0 left-0 right-0 p-4 bg-gradient-to-b from-black/80 to-transparent pointer-events-none">
            <p className="text-sf-warmGold text-xs font-bold uppercase tracking-wider">{currentItem.sequenceName}</p>
            <h2 className="text-white text-xl md:text-2xl font-bold truncate">{currentItem.movementName}</h2>
          </div>
        </div>

        {/* CONTROLS & INFO AREA */}
        <div className="p-5 md:p-8 bg-slate-900 text-white">
          <div className="flex flex-col md:flex-row md:items-center justify-between gap-6 mb-8">
            
            {/* Quick Stats */}
            <div className="flex flex-wrap items-center gap-x-8 gap-y-4">
              <div>
                <p className="text-xs text-slate-400 font-medium uppercase tracking-widest mb-1">Sets / Reps</p>
                <p className="text-xl font-bold">{currentItem.sets} <span className="text-slate-500 font-normal mx-1">x</span> {currentItem.reps}</p>
              </div>
              <div>
                <p className="text-xs text-slate-400 font-medium uppercase tracking-widest mb-1">Duration</p>
                <p className="text-xl font-bold text-sf-warmGold">{currentItem.duration}</p>
              </div>
              <div>
                <p className="text-xs text-slate-400 font-medium uppercase tracking-widest mb-1">Rest</p>
                <p className="text-xl font-bold">{currentItem.rest}</p>
              </div>
            </div>

            {/* Navigation Controls */}
            <div className="flex items-center gap-3 shrink-0">
              <button 
                disabled={isFirst}
                onClick={() => setCurrentIndex(prev => prev - 1)}
                className="w-12 h-12 flex items-center justify-center rounded-full bg-slate-800 hover:bg-slate-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                <SkipBack className="w-5 h-5" />
              </button>
              
              <div className="text-sm font-bold text-slate-400 px-4 tabular-nums">
                {currentIndex + 1} / {playlist.length}
              </div>

              {!isLast ? (
                <button 
                  onClick={() => setCurrentIndex(prev => prev + 1)}
                  className="w-14 h-14 flex items-center justify-center rounded-full bg-sf-warmGold hover:bg-yellow-500 text-slate-900 transition-colors shadow-lg shadow-sf-warmGold/20"
                >
                  <SkipForward className="w-6 h-6 ml-1" />
                </button>
              ) : (
                <button 
                  onClick={() => isTrainer ? handleFinish(0, "") : setShowEndModal(true)}
                  className="px-6 h-14 flex items-center justify-center gap-2 rounded-full bg-green-500 hover:bg-green-400 text-slate-900 font-bold transition-colors shadow-lg shadow-green-500/20"
                >
                  Akhiri <CheckCircle2 className="w-5 h-5" />
                </button>
              )}
            </div>
          </div>

          {/* Details Table */}
          <div className="bg-slate-800/50 rounded-xl overflow-hidden border border-slate-700/50">
            <div className="grid grid-cols-2 md:grid-cols-4 divide-y md:divide-y-0 md:divide-x divide-slate-700/50">
              <div className="p-4">
                <p className="text-[10px] text-slate-400 font-bold uppercase tracking-wider mb-1">Beban (Kg)</p>
                <p className="font-medium text-slate-200">{currentItem.beban}</p>
              </div>
              <div className="p-4">
                <p className="text-[10px] text-slate-400 font-bold uppercase tracking-wider mb-1">BPM Zone</p>
                <p className="font-medium text-slate-200">{currentItem.bpm}</p>
              </div>
              {currentItem.isLevel1 && (
                <>
                  <div className="p-4">
                    <p className="text-[10px] text-slate-400 font-bold uppercase tracking-wider mb-1">Breathing Core</p>
                    <p className="font-medium text-slate-200 capitalize">{currentItem.breathing_core || "-"}</p>
                  </div>
                  <div className="p-4">
                    <p className="text-[10px] text-slate-400 font-bold uppercase tracking-wider mb-1">Breathing Diaphragm</p>
                    <p className="font-medium text-slate-200 capitalize">{currentItem.breathing_diaphragm || "-"}</p>
                  </div>
                </>
              )}
            </div>
          </div>

        </div>
      </div>

      {/* Playlist Preview */}
      <div>
        <h3 className="text-sm font-bold text-slate-800 uppercase tracking-wider mb-3">Antrean Gerakan Selanjutnya</h3>
        <div className="space-y-2">
          {playlist.slice(currentIndex + 1, currentIndex + 4).map((item, i) => (
            <div key={item.id} className="flex items-center gap-4 p-3 bg-white border border-slate-200 rounded-xl shadow-sm opacity-70">
              <div className="w-10 h-10 bg-slate-100 rounded-lg flex items-center justify-center shrink-0 font-bold text-slate-400 text-sm">
                {currentIndex + 2 + i}
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-[10px] text-sf-warmGold font-bold uppercase tracking-wider">{item.sequenceName}</p>
                <p className="text-sm font-bold text-slate-800 truncate">{item.movementName}</p>
              </div>
              <ChevronRight className="w-5 h-5 text-slate-300 shrink-0" />
            </div>
          ))}
          {playlist.length - currentIndex - 4 > 0 && (
            <div className="text-center py-2 text-xs font-semibold text-slate-400">
              + {playlist.length - currentIndex - 4} gerakan lainnya
            </div>
          )}
        </div>
      </div>

      <EndSessionModal 
        isOpen={showEndModal} 
        onClose={() => setShowEndModal(false)} 
        onFinish={handleFinish} 
        isTrainer={!!isTrainer}
      />
    </div>
  );
}
