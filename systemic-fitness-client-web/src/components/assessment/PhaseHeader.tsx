"use client";

import { ArrowLeft } from "lucide-react";
import { useRouter } from "next/navigation";

interface PhaseHeaderProps {
  currentPhase: number; // 0 for A, 1 for B, 2 for C
  title: string;
  subProgress?: string;
  onBack?: () => void;
}

export function PhaseHeader({
  currentPhase,
  title,
  subProgress,
  onBack,
}: PhaseHeaderProps) {
  const router = useRouter();
  const totalPhases = 3;
  
  // Example widths: 33%, 66%, 100%
  const progressWidth = `${((currentPhase + 1) / totalPhases) * 100}%`;

  return (
    <header className="sticky top-0 z-40 bg-bg-primary pt-3 pb-2 px-5 max-w-lg mx-auto">
      <div className="flex items-center mb-3">
        <button
          onClick={onBack || (() => router.back())}
          className="w-10 h-10 flex items-center justify-center rounded-xl bg-bg-card border border-border-color hover:bg-black/5 dark:hover:bg-white/5 transition-colors"
        >
          <ArrowLeft size={20} className="text-text-primary" />
        </button>
        <div className="flex-1 ml-4">
          <h1 className="text-[17px] font-bold text-text-primary leading-tight">
            {title}
          </h1>
          {subProgress && (
            <p className="text-xs text-text-secondary mt-0.5">{subProgress}</p>
          )}
        </div>
      </div>
      
      {/* Progress Bar */}
      <div className="w-full h-1.5 bg-border-color rounded-full overflow-hidden">
        <div
          className="h-full bg-sf-warmGold rounded-full transition-all duration-500 ease-out"
          style={{ width: progressWidth }}
        />
      </div>
    </header>
  );
}
