"use client";

import { Dumbbell } from "lucide-react";

export default function ProgramsPage() {
  return (
    <div className="px-5 py-6 animate-fade-in-up">
      <div className="card p-8 flex flex-col items-center justify-center min-h-[300px]">
        <div className="w-16 h-16 rounded-2xl bg-sf-systemBlue/10 flex items-center justify-center mb-4">
          <Dumbbell size={32} className="text-sf-systemBlue" />
        </div>
        <h2 className="text-base font-bold text-sf-charcoal mb-1">Belum Ada Program</h2>
        <p className="text-sm text-gray-400 text-center max-w-xs">
          Program latihan yang ditugaskan trainer Anda akan muncul di sini. Hubungi trainer untuk memulai.
        </p>
      </div>
    </div>
  );
}
