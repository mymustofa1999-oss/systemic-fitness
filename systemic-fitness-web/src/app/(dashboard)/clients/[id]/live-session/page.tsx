"use client";

import { useState, useMemo, useRef, useEffect } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useUser } from "@/hooks/useUsers";
import { useTrainerCard } from "@/hooks/useNewFeatures";
import { useDLMovements } from "@/hooks/useDigitalLibrary";
import { ArrowLeft, SkipForward, SkipBack, CheckCircle2, ChevronRight, Video, X, Activity, ListOrdered, Music } from "lucide-react";
import { cn } from "@/lib/utils";
import { toast } from "@/stores/toastStore";
import { useAuth } from "@/hooks/useAuth";
import { apiPost } from "@/lib/api";

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
  if (parts.length >= 2) {
    const femaleName = parts[0].trim();
    const maleName = parts[1].trim();
    
    // Fix: if maleName is a youtube link (which happens if data was entered incorrectly)
    // just return the female name (the actual movement name) for both genders.
    if (maleName.startsWith("http")) {
        return femaleName + levelSuffix;
    }

    if (normalizedGender === "male" || normalizedGender === "pria" || normalizedGender === "men" || normalizedGender === "laki-laki") {
      return maleName + levelSuffix;
    }
    
    // Default to female name for female, wanita, women, or if gender is unknown/empty.
    // This prevents the raw string with "|" from ever being shown to the user.
    return femaleName + levelSuffix;
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

function calculateBPM(age: number | null, intensityCode: string) {
  if (!age || !intensityCode) return "";
  const maxHR = 220 - age;
  let minPct = 0;
  let maxPct = 0;
  
  const code = intensityCode.toLowerCase();
  if (code === "functional" || code.includes("func")) {
    minPct = 0.50;
    maxPct = 0.60;
  } else if (code === "cardiorespiratory" || code.includes("cardio") || code.includes("resp")) {
    minPct = 0.70;
    maxPct = 0.85;
  } else if (code === "metabolic" || code.includes("meta")) {
    minPct = 0.85;
    maxPct = 0.95;
  } else {
    return "";
  }
  
  const minBPM = Math.round(maxHR * minPct);
  const maxBPM = Math.round(maxHR * maxPct);
  
  const roundedMin = Math.round(minBPM / 10) * 10;
  const roundedMax = Math.round(maxBPM / 10) * 10;
  return `${roundedMin}-${roundedMax} BPM`;
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
  const [selectedBpm, setSelectedBpm] = useState<string>("No BPM");
  const [isBpmPlaying, setIsBpmPlaying] = useState<boolean>(false);
  const audioRef = useRef<HTMLAudioElement | null>(null);

  useEffect(() => {
    if (audioRef.current) {
      audioRef.current.pause();
      audioRef.current = null;
    }
    setIsBpmPlaying(false);
    setSelectedBpm("No BPM");
  }, [currentIndex]);

  useEffect(() => {
    return () => {
      if (audioRef.current) {
        audioRef.current.pause();
        audioRef.current = null;
      }
    };
  }, []);

  const playBpmAudio = (bpm: string) => {
    if (!bpm || bpm === 'No BPM') {
      if (audioRef.current) {
        audioRef.current.pause();
        audioRef.current = null;
      }
      setIsBpmPlaying(false);
      return;
    }

    if (audioRef.current) {
      audioRef.current.pause();
    }

    const url = `/bpm/${bpm}.mp3`;
    const audio = new Audio(url);
    audio.loop = true;
    audioRef.current = audio;
    audio.play()
      .then(() => {
        setIsBpmPlaying(true);
      })
      .catch((err) => {
        console.error("Error playing BPM audio:", err);
        setIsBpmPlaying(false);
      });
  };

  const stopBpmAudio = () => {
    if (audioRef.current) {
      audioRef.current.pause();
      audioRef.current = null;
    }
    setIsBpmPlaying(false);
  };

  
  const sequenceNames = useMemo(() => {
    const data = cardData?.data as any;
    if (!data?.sequences) return [];
    return data.sequences.map((seq: any) => seq.program_category_name || seq.name || "Bagian");
  }, [cardData]);
  
  const playlist = useMemo(() => {
    const data = cardData?.data as any;
    if (!data?.sequences) return [];
    
    const clientGender = (userData?.data as any)?.profile?.gender?.toLowerCase() === "male" ? "male" : "female";
    const clientAge = (userData?.data as any)?.profile?.age || (userData?.data as any)?.profile?.age_years || null;
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
            sequenceName: seq.program_category_name || seq.name || `Bagian ${sIdx + 1}`,
            movementName: movement?.name || item.movement_name || "Gerakan tidak diketahui",
            videoUrl,
            reps: item.reps || set.reps || "-",
            sets: item.sets_count || set.sets_count || set.set_number || "-",
            duration: set.duration || (set.duration_mins ? `${set.duration_mins}'` : null) || seq.duration || "-",
            rest: set.rest || item.rest || set.notes || item.notes || "-",
            bpm: set.bpm || calculateBPM(clientAge, seq.program_category_code || seq.program_category_name || "") || ((set.bpm_lower && set.bpm_upper) ? `${set.bpm_lower}-${set.bpm_upper}` : "-"),
            beban: item.equipment || item.extra_load || set.equipment || set.extra_load || [set.equipment_upper, set.equipment_lower].filter(Boolean).join(" / ") || ((set.beban_lower_value && set.beban_upper_value) ? `${set.beban_lower_value}-${set.beban_upper_value}` : "-"),
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
    try {
      await apiPost("/api/v2/workout-sessions", {
        customer_id: customerId,
        session_type: "full",
        duration_seconds: 3600,
        level: (cardData?.data as any)?.level || "",
      });
    } catch (e) {
      console.error("Failed to log session:", e);
    }
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
        
        {/* LEFT COLUMN: Main Content */}
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

          {/* 🎵 BPM Metronome Player Box 🎵 */}
          <div className="bg-sf-deepNavy text-white rounded-2xl p-4 md:p-5 shadow-xl ring-1 ring-slate-900/10 flex flex-col sm:flex-row items-center justify-between gap-4 w-full shrink-0">
             <div className="flex items-center gap-3.5">
               <div className={cn("w-11 h-11 rounded-full flex items-center justify-center transition-all shrink-0", isBpmPlaying ? "bg-sf-warmGold text-slate-950 animate-pulse shadow-lg shadow-sf-warmGold/40" : "bg-white/10 text-slate-300")}>
                 <Music className="w-5 h-5" />
               </div>
               <div>
                 <p className="text-[10px] font-bold uppercase tracking-widest text-sf-warmGold flex items-center gap-2">
                   BPM MUSIC PLAYER {currentItem.bpm && currentItem.bpm !== "-" ? <span className="text-white/70">• Target: {currentItem.bpm}</span> : ""}
                 </p>
                 <p className="text-sm font-extrabold text-white mt-0.5">
                   {isBpmPlaying
                     ? `Playing @ ${selectedBpm} BPM`
                     : selectedBpm === "No BPM"
                     ? "Muted (No BPM Selected)"
                     : `Paused @ ${selectedBpm} BPM`}
                 </p>
               </div>
             </div>

             <div className="flex items-center gap-2.5 w-full sm:w-auto justify-end">
               <select
                 value={selectedBpm}
                 onChange={(e) => {
                   const val = e.target.value;
                   setSelectedBpm(val);
                   if (isBpmPlaying) {
                     playBpmAudio(val);
                   }
                 }}
                 className="bg-slate-800 border border-slate-700 hover:border-slate-600 rounded-xl px-3.5 py-2.5 text-xs font-bold text-white shadow-sm focus:outline-none focus:ring-2 focus:ring-sf-warmGold cursor-pointer transition-colors"
               >
                 <option value="No BPM" className="text-slate-400">No BPM</option>
                 {["60", "70", "80", "90", "100", "110", "120", "130", "140", "150", "160", "170", "180", "190", "200"].map((val) => (
                   <option key={val} value={val} className="text-white">
                     {val} BPM
                   </option>
                 ))}
               </select>

               <button
                 onClick={() => {
                   if (selectedBpm === "No BPM") return;
                   if (isBpmPlaying) {
                     stopBpmAudio();
                   } else {
                     playBpmAudio(selectedBpm);
                   }
                 }}
                 disabled={selectedBpm === "No BPM"}
                 className={cn(
                   "px-5 py-2.5 rounded-xl text-xs font-extrabold uppercase tracking-wider transition-all flex items-center gap-1.5 shadow-md",
                   selectedBpm === "No BPM"
                     ? "bg-slate-800 text-slate-500 cursor-not-allowed border border-slate-700/50"
                     : isBpmPlaying
                     ? "bg-red-500 hover:bg-red-600 text-white shadow-red-500/20 active:scale-95"
                     : "bg-sf-warmGold hover:bg-yellow-500 text-slate-950 shadow-sf-warmGold/20 active:scale-95"
                 )}
               >
                 {isBpmPlaying ? "Stop" : "Play"}
               </button>
             </div>
          </div>

          {/* Parameter Latihan (Wireframe Layout) */}
            <div className="bg-sf-deepNavy rounded-2xl p-5 md:p-6 shadow-xl ring-1 ring-slate-900/10 shrink-0">
              <h3 className="text-white font-extrabold text-lg mb-4 flex items-center gap-2">
                <Activity className="h-5 w-5 text-sf-warmGold" /> Parameter Latihan
              </h3>
              
              <div className="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-4">
                
                {/* SEQUENCE */}
                <div className="bg-slate-800/60 rounded-xl border border-slate-700/50 backdrop-blur-sm transition-colors hover:bg-slate-800 flex flex-col p-3 row-span-2">
                  <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest mb-3 text-center">Sequence</p>
                  <div className="flex flex-col gap-1.5 flex-1 justify-center">
                    {sequenceNames.map((name: string, i: number) => {
                      const isActive = i === currentItem.seqIndex;
                      return (
                        <div key={i} className={`text-xs font-semibold py-2 px-2.5 rounded text-center transition-all ${isActive ? "bg-sf-warmGold/20 text-sf-warmGold animate-pulse border border-sf-warmGold/50 shadow-sm" : "text-slate-400 bg-slate-900/40"}`}>
                          {name}
                        </div>
                      )
                    })}
                  </div>
                </div>

                {/* DURATION */}
                <div className="bg-slate-800/60 rounded-xl border border-slate-700/50 backdrop-blur-sm transition-colors hover:bg-slate-800 flex flex-col p-3 row-span-2">
                  <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest mb-1 text-center">Duration</p>
                  <div className="flex-1 flex items-center justify-center">
                    <p className="text-xl md:text-2xl font-bold text-sf-warmGold">{currentItem.duration}</p>
                  </div>
                </div>

                {/* EQUIPMENT */}
                <div className="bg-slate-800/60 rounded-xl border border-slate-700/50 backdrop-blur-sm transition-colors hover:bg-slate-800 flex flex-col overflow-hidden">
                  <div className="p-2 border-b border-slate-700/50 text-center bg-slate-900/30">
                    <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest">Equipment</p>
                  </div>
                  <div className="flex flex-1 divide-x divide-slate-700/50">
                    <div className="flex-1 p-2 flex flex-col items-center justify-center text-center">
                      <p className="text-[9px] text-slate-500 font-bold uppercase mb-1">Upper</p>
                      <p className="text-xs md:text-sm font-bold text-white leading-tight">
                        {currentItem.equip_upper !== "-" ? currentItem.equip_upper.split(",").map((s:string,idx:number)=><div key={idx}>{s.trim()}</div>) : "-"}
                      </p>
                    </div>
                    <div className="flex-1 p-2 flex flex-col items-center justify-center text-center">
                      <p className="text-[9px] text-slate-500 font-bold uppercase mb-1">Lower</p>
                      <p className="text-xs md:text-sm font-bold text-white leading-tight">
                        {currentItem.equip_lower !== "-" ? currentItem.equip_lower.split(",").map((s:string,idx:number)=><div key={idx}>{s.trim()}</div>) : "-"}
                      </p>
                    </div>
                  </div>
                </div>

                {/* SET / REPS */}
                <div className="bg-slate-800/60 p-4 rounded-xl border border-slate-700/50 backdrop-blur-sm transition-colors hover:bg-slate-800 flex flex-col items-center justify-center text-center">
                  <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest mb-1">Set/Reps</p>
                  <p className="text-xl md:text-2xl font-extrabold text-white">
                    {currentItem.sets} <span className="text-slate-500 font-normal mx-1 text-lg">x</span> {currentItem.reps}
                  </p>
                </div>

                {/* MAX HR (BPM Zone) */}
                <div className="bg-slate-800/60 p-3 rounded-xl border border-slate-700/50 backdrop-blur-sm transition-colors hover:bg-slate-800 flex flex-col items-center justify-center text-center">
                  <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest mb-1">Max HR / BPM</p>
                  <p className="text-lg md:text-xl font-bold text-white leading-tight">{currentItem.bpm}</p>
                </div>

                {/* BREATHING */}
                <div className="bg-slate-800/60 p-3 rounded-xl border border-slate-700/50 backdrop-blur-sm transition-colors hover:bg-slate-800 flex flex-col items-center justify-center text-center">
                  <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest mb-1">Breathing</p>
                  <div className="text-xs md:text-sm font-bold text-slate-200 capitalize leading-relaxed">
                    {currentItem.breathing_core && currentItem.breathing_core !== "-" && (
                      <div className="mb-1"><span className="text-slate-500 block text-[9px] uppercase">Core</span> {currentItem.breathing_core.split(',').join(', ')}</div>
                    )}
                    {currentItem.breathing_diaphragm && currentItem.breathing_diaphragm !== "-" && (
                      <div><span className="text-slate-500 block text-[9px] uppercase">Diaphragm</span> {currentItem.breathing_diaphragm.split(',').join(', ')}</div>
                    )}
                    {(!currentItem.breathing_core || currentItem.breathing_core === "-") && (!currentItem.breathing_diaphragm || currentItem.breathing_diaphragm === "-") && "-"}
                  </div>
                </div>

              </div>
            </div>

          {/* Navigation Controls (Compacted) */}
          <div className="bg-white rounded-2xl p-4 md:p-5 shadow-xl border border-slate-100 flex items-center justify-between mt-auto">
            <button 
              disabled={isFirst}
              onClick={() => setCurrentIndex(prev => prev - 1)}
              className="w-12 h-12 md:w-14 md:h-14 flex items-center justify-center rounded-full bg-slate-100 hover:bg-slate-200 disabled:opacity-50 disabled:cursor-not-allowed transition-colors text-slate-700"
            >
              <SkipBack className="w-5 h-5 md:w-6 md:h-6" />
            </button>
            
            <div className="text-lg md:text-xl font-bold text-slate-400 tabular-nums tracking-widest">
              <span className="text-sf-deepNavy">{currentIndex + 1}</span> <span className="mx-2 opacity-50">/</span> {playlist.length}
            </div>

            {!isLast ? (
              <button 
                onClick={() => setCurrentIndex(prev => prev + 1)}
                className="w-14 h-14 md:w-16 md:h-16 flex items-center justify-center rounded-full bg-sf-warmGold hover:bg-yellow-500 text-slate-900 transition-all transform hover:scale-105 hover:-translate-y-1 shadow-xl shadow-sf-warmGold/30"
              >
                <SkipForward className="w-6 h-6 md:w-7 md:h-7 ml-1" />
              </button>
            ) : (
              <button 
                onClick={() => isTrainer ? handleFinish(0, "") : setShowEndModal(true)}
                className="px-6 md:px-8 h-14 md:h-16 flex items-center justify-center gap-2 rounded-full bg-green-500 hover:bg-green-400 text-white font-extrabold text-lg md:text-xl transition-all transform hover:scale-105 hover:-translate-y-1 shadow-xl shadow-green-500/30 tracking-wide"
              >
                Selesai <CheckCircle2 className="w-6 h-6 md:w-7 md:h-7" />
              </button>
            )}
          </div>

        </div>

        {/* RIGHT COLUMN: Queue */}
        <div className="lg:col-span-4 space-y-4 flex flex-col lg:sticky lg:top-4 lg:h-[calc(100vh-8rem)]">
          <div className="bg-white rounded-3xl p-5 md:p-6 shadow-xl border border-slate-100 flex flex-col h-full overflow-hidden">
            <h3 className="text-lg font-extrabold text-slate-800 uppercase tracking-widest mb-4 flex items-center gap-2 shrink-0">
              <ListOrdered className="h-6 w-6 text-sf-deepNavy" /> Antrean
            </h3>
            
            {playlist.length - currentIndex - 1 > 0 ? (
              <div className="flex-1 overflow-y-auto pr-2 space-y-3 custom-scrollbar">
                {playlist.slice(currentIndex + 1).map((item, i) => (
                  <div key={item.id} className="flex flex-col xl:flex-row items-start xl:items-center gap-3 p-3 bg-slate-50 hover:bg-slate-100 transition-colors rounded-2xl group cursor-pointer border border-slate-100 hover:border-slate-200 hover:shadow-md" onClick={() => setCurrentIndex(currentIndex + 1 + i)}>
                    {/* Thumbnail */}
                    <div className="relative w-full xl:w-28 shrink-0 aspect-video bg-slate-200 rounded-xl overflow-hidden shadow-sm flex items-center justify-center border border-slate-200/60 transition-all">
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
                    <div className="flex-1 min-w-0 pt-1 xl:pt-0">
                      <h4 className="text-sm font-bold text-slate-800 line-clamp-2 leading-tight group-hover:text-sf-deepNavy transition-colors">
                        {formatMovementName(item.movementName, (userData?.data as any)?.profile?.gender)}
                      </h4>
                      <p className="text-[10px] text-sf-warmGold font-bold uppercase tracking-widest mt-1 line-clamp-1">{item.sequenceName}</p>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="flex-1 flex flex-col items-center justify-center text-slate-400 space-y-3 bg-slate-50 rounded-2xl border border-slate-100 border-dashed min-h-[150px]">
                <CheckCircle2 className="w-10 h-10 text-green-400/50" />
                <p className="text-sm font-medium">Ini adalah gerakan terakhir</p>
              </div>
            )}
          </div>
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
