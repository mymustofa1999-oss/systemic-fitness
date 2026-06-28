"use client";

import { Apple } from "lucide-react";

export default function NutritionPage() {
  return (
    <div className="px-5 py-6 animate-fade-in-up">
      <div className="card p-8 flex flex-col items-center justify-center min-h-[300px]">
        <div className="w-16 h-16 rounded-2xl bg-sf-deepTeal/10 flex items-center justify-center mb-4">
          <Apple size={32} className="text-sf-deepTeal" />
        </div>
        <h2 className="text-base font-bold text-sf-charcoal mb-1">Belum Ada Data Nutrisi</h2>
        <p className="text-sm text-gray-400 text-center max-w-xs">
          Log makanan dan meal plan Anda akan muncul di sini. Mulai tracking nutrisi harian Anda.
        </p>
      </div>
    </div>
  );
}
