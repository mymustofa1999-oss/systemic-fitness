"use client";

import { useState, useMemo } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useUser } from "@/hooks/useUsers";
import { useTrainerCard } from "@/hooks/useNewFeatures";
import { useDLMovements } from "@/hooks/useDigitalLibrary";
import { ArrowLeft, SkipForward, SkipBack, CheckCircle2, ChevronRight, Video, X, Activity, ListOrdered } from "lucide-react";
import { cn } from "@/lib/utils";
import { toast } from "@/stores/toastStore";
import { useAuth } from "@/hooks/useAuth";

function formatMovementName(rawName: string, gender: string | undefined): string {
  if (!rawName) return "-";
  if (!rawName.includes(" | ")) return rawName;

  const normalizedGender = (gender || "").toLowerCase();
  
  // Extract level suffix if present
  let levelSuffix = "";
  let baseName = rawName;
  const levelMatch = rawName.match(/(\s*\[L\d+\])$/i);
  if (levelMatch) {
    levelSuffix = levelMatch[1];
    baseName = rawName.replace(/(\s*\[L\d+\])$/i, "");
  }

  const parts = baseName.split(" | ");
  if (parts.length === 2) {
    const femaleName = parts[0].trim();
    const maleName = parts[1].trim();

    if (normalizedGender === "female" || normalizedGender === "wanita" || normalizedGender === "women") {
      return femaleName + levelSuffix;
    } else if (normalizedGender === "male" || normalizedGender === "pria" || normalizedGender === "men") {
      return maleName + levelSuffix;
    }
  }

  return rawName;
}

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

function extractYouTubeId(url: string): string | null {
  if (!url) return null;
  const shortMatch = url.match(/youtu\.be\/([a-zA-Z0-9_-]{11})/);
  if (shortMatch) return shortMatch[1];
  const longMatch = url.match(/[?&]v=([a-zA-Z0-9_-]{11})/);
  if (longMatch) return longMatch[1];
  const embedMatch = url.match(/embed\/([a-zA-Z0-9_-]{11})/);
  if (embedMatch) return embedMatch[1];
  return null;
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
    <div className="w-full max-w-[1600px] mx-auto space-y-4 pb-20 px-4 md:px-8">
      <div className="flex items-center justify-between">
        <Link href={`/clients/${customerId}/training-card`} className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-slate-700 transition-colors bg-white px-4 py-2 rounded-full shadow-sm border border-slate-200 font-medium">
          <ArrowLeft className="h-4 w-4" /> Batal / Kembali
        </Link>
        <span className="px-4 py-2 bg-green-100 text-green-700 font-bold text-xs uppercase tracking-wider rounded-full flex items-center gap-2 shadow-sm border border-green-200">
          <span className="w-2.5 h-2.5 rounded-full bg-green-500 animate-pulse" /> Live Session
        </span>
      </div>

      <div className="grid lg:grid-cols-12 gap-8">
        
        {/* LEFT COLUMN: Video & Controls */}
        <div className="lg:col-span-8 space-y-4 flex flex-col">
          
          {/* Header Title Out of Video */}
          <div className="bg-sf-deepNavy text-white px-5 py-4 md:px-6 md:py-5 rounded-2xl shadow-xl ring-1 ring-slate-900/10 shrink-0">
            <p className="text-sf-warmGold text-xs font-bold uppercase tracking-widest mb-1.5 flex items-center gap-2">
              <span className="w-1.5 h-1.5 rounded-full bg-sf-warmGold" /> {currentItem.sequenceName}
            </p>
            <h2 className="text-2xl md:text-3xl font-extrabold leading-tight tracking-tight truncate">
              {formatMovementName(currentItem.movementName, (userData?.data as any)?.profile?.gender)}
            </h2>
          </div>

          {/* Video Player */}
          <div className="bg-black rounded-2xl overflow-hidden shadow-2xl ring-1 ring-slate-900/10 aspect-video relative flex items-center justify-center group w-full">
            {currentItem.videoUrl ? (
              extractYouTubeId(currentItem.videoUrl) ? (
                <iframe
                  key={currentItem.videoUrl}
                  src={`https://www.youtube.com/embed/${extractYouTubeId(currentItem.videoUrl)}?autoplay=1&mute=1&loop=1&playlist=${extractYouTubeId(currentItem.videoUrl)}`}
                  title={currentItem.movementName}
                  className="w-full h-full object-contain"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowFullScreen
                />
              ) : (
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
              )
            ) : (
              <div className="flex flex-col items-center justify-center text-slate-500 space-y-4">
                <div className="w-20 h-20 rounded-full bg-slate-900 flex items-center justify-center">
                  <Video className="w-10 h-10 opacity-50" />
                </div>
                <p className="font-medium text-lg">Video tidak tersedia</p>
              </div>
            )}
          </div>

          {/* Large Navigation Controls */}
          <div className="bg-white rounded-3xl p-6 md:p-8 shadow-xl border border-slate-100 flex items-center justify-between mt-auto">
            <button 
              disabled={isFirst}
              onClick={() => setCurrentIndex(prev => prev - 1)}
              className="w-16 h-16 md:w-20 md:h-20 flex items-center justify-center rounded-full bg-slate-100 hover:bg-slate-200 disabled:opacity-50 disabled:cursor-not-allowed transition-colors text-slate-700"
            >
              <SkipBack className="w-6 h-6 md:w-8 md:h-8" />
            </button>
            
            <div className="text-xl md:text-2xl font-bold text-slate-400 tabular-nums tracking-widest">
              <span className="text-sf-deepNavy">{currentIndex + 1}</span> <span className="mx-2 opacity-50">/</span> {playlist.length}
            </div>

            {!isLast ? (
              <button 
                onClick={() => setCurrentIndex(prev => prev + 1)}
                className="w-20 h-20 md:w-24 md:h-24 flex items-center justify-center rounded-full bg-sf-warmGold hover:bg-yellow-500 text-slate-900 transition-all transform hover:scale-105 hover:-translate-y-1 shadow-xl shadow-sf-warmGold/30"
              >
                <SkipForward className="w-8 h-8 md:w-10 md:h-10 ml-1.5" />
              </button>
            ) : (
              <button 
                onClick={() => isTrainer ? handleFinish(0, "") : setShowEndModal(true)}
                className="px-8 md:px-10 h-20 md:h-24 flex items-center justify-center gap-3 rounded-full bg-green-500 hover:bg-green-400 text-white font-extrabold text-xl md:text-2xl transition-all transform hover:scale-105 hover:-translate-y-1 shadow-xl shadow-green-500/30 tracking-wide"
              >
                Selesai <CheckCircle2 className="w-7 h-7 md:w-8 md:h-8" />
              </button>
            )}
          </div>

          {/* Queue Panel (Moved to Left Column) */}
          <div className="bg-white rounded-3xl p-6 md:p-8 shadow-xl border border-slate-100 mt-8">
            <h3 className="text-lg font-extrabold text-slate-800 uppercase tracking-widest mb-6 flex items-center gap-2">
              <ListOrdered className="h-6 w-6 text-sf-deepNavy" /> Antrean Selanjutnya
            </h3>
            
            {playlist.length - currentIndex - 1 > 0 ? (
              <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
                {playlist.slice(currentIndex + 1).map((item, i) => (
                  <div key={item.id} className="flex items-start gap-3 p-3 bg-slate-50 hover:bg-slate-100 transition-colors rounded-2xl group cursor-pointer border border-slate-100 hover:border-slate-200 hover:shadow-md" onClick={() => setCurrentIndex(currentIndex + 1 + i)}>
                    {/* Thumbnail */}
                    <div className="relative w-28 md:w-32 shrink-0 aspect-video bg-slate-200 rounded-xl overflow-hidden shadow-sm flex items-center justify-center border border-slate-200/60 transition-all">
                      {(() => {
                        const ytId = extractYouTubeId(item.videoUrl || "");
                        if (ytId) {
                          return <img src={`https://img.youtube.com/vi/${ytId}/mqdefault.jpg`} alt="" className="w-full h-full object-cover" />;
                        }
                        return <Video className="w-6 h-6 text-slate-400" />;
                      })()}
                      <div className="absolute bottom-1 right-1 bg-black/80 text-white text-[10px] font-bold px-1.5 py-0.5 rounded backdrop-blur-sm">
                        #{currentIndex + 2 + i}
                      </div>
                    </div>

                    {/* Info */}
                    <div className="flex-1 min-w-0 pt-1">
                      <h4 className="text-sm md:text-base font-bold text-slate-800 line-clamp-2 leading-tight group-hover:text-sf-deepNavy transition-colors">
                        {formatMovementName(item.movementName, (userData?.data as any)?.profile?.gender)}
                      </h4>
                      <p className="text-[10px] text-sf-warmGold font-bold uppercase tracking-widest mt-1.5 line-clamp-1">{item.sequenceName}</p>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="h-40 flex flex-col items-center justify-center text-slate-400 space-y-3 bg-slate-50 rounded-2xl border border-slate-100 border-dashed">
                <CheckCircle2 className="w-10 h-10 text-green-400/50" />
                <p className="text-sm font-medium">Ini adalah gerakan terakhir</p>
              </div>
            )}
          </div>

        </div>

        {/* RIGHT COLUMN: Details */}
        <div className="lg:col-span-4 space-y-6 flex flex-col">
          
          {/* Workout Parameters Panel */}
          <div className="bg-sf-deepNavy rounded-3xl p-6 md:p-8 shadow-xl ring-1 ring-slate-900/10 relative overflow-hidden">
            {/* Background accent */}
            <div className="absolute -top-24 -right-24 w-48 h-48 bg-sf-warmGold/10 rounded-full blur-3xl pointer-events-none" />
            
            <h3 className="text-white font-extrabold text-xl mb-6 flex items-center gap-2.5">
              <Activity className="h-6 w-6 text-sf-warmGold" /> Parameter Latihan
            </h3>
            
            <div className="space-y-4 relative z-10">
              
              {/* Sets / Reps */}
              <div className="bg-slate-800/60 p-5 rounded-2xl border border-slate-700/50 backdrop-blur-sm transition-colors hover:bg-slate-800">
                <p className="text-xs text-slate-400 font-bold uppercase tracking-widest mb-1.5">Sets / Reps</p>
                <p className="text-3xl font-extrabold text-white">{currentItem.sets} <span className="text-slate-500 font-normal mx-2">x</span> {currentItem.reps}</p>
              </div>
              
              {/* Duration & Rest */}
              <div className="grid grid-cols-2 gap-4">
                <div className="bg-slate-800/60 p-5 rounded-2xl border border-slate-700/50 backdrop-blur-sm transition-colors hover:bg-slate-800">
                  <p className="text-xs text-slate-400 font-bold uppercase tracking-widest mb-1.5">Duration</p>
                  <p className="text-xl font-bold text-sf-warmGold">{currentItem.duration}</p>
                </div>
                <div className="bg-slate-800/60 p-5 rounded-2xl border border-slate-700/50 backdrop-blur-sm transition-colors hover:bg-slate-800">
                  <p className="text-xs text-slate-400 font-bold uppercase tracking-widest mb-1.5">Rest</p>
                  <p className="text-xl font-bold text-white">{currentItem.rest}</p>
                </div>
              </div>

              {/* Equip / Beban */}
              <div className="bg-slate-800/60 p-5 rounded-2xl border border-slate-700/50 backdrop-blur-sm transition-colors hover:bg-slate-800">
                <p className="text-xs text-slate-400 font-bold uppercase tracking-widest mb-1.5">Equip / Beban</p>
                <p className="text-xl font-bold text-white truncate" title={currentItem.beban}>{currentItem.beban}</p>
              </div>

              {/* Breathing & BPM */}
              <div className="grid grid-cols-2 gap-4">
                <div className="bg-slate-800/60 p-5 rounded-2xl border border-slate-700/50 backdrop-blur-sm transition-colors hover:bg-slate-800">
                  <p className="text-xs text-slate-400 font-bold uppercase tracking-widest mb-1.5">Breathing</p>
                  <p className="text-sm font-bold text-slate-200 capitalize leading-relaxed">
                    {currentItem.breathing_core && currentItem.breathing_core !== "-" ? <span className="block"><span className="text-slate-500">C:</span> {currentItem.breathing_core}</span> : null}
                    {currentItem.breathing_diaphragm && currentItem.breathing_diaphragm !== "-" ? <span className="block"><span className="text-slate-500">D:</span> {currentItem.breathing_diaphragm}</span> : null}
                    {(!currentItem.breathing_core || currentItem.breathing_core === "-") && (!currentItem.breathing_diaphragm || currentItem.breathing_diaphragm === "-") ? "-" : null}
                  </p>
                </div>
                <div className="bg-slate-800/60 p-5 rounded-2xl border border-slate-700/50 backdrop-blur-sm transition-colors hover:bg-slate-800 flex flex-col justify-center">
                  <p className="text-xs text-slate-400 font-bold uppercase tracking-widest mb-1.5">BPM Zone</p>
                  <p className="text-lg font-bold text-white leading-tight">{currentItem.bpm}</p>
                </div>
              </div>
            </div>
          </div>
          {/* The queue was moved to the left column */}
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
