"use client";

import { MessageCircle } from "lucide-react";

export default function MessagesPage() {
  return (
    <div className="px-5 py-6 animate-fade-in-up">
      <div className="card p-8 flex flex-col items-center justify-center min-h-[300px]">
        <div className="w-16 h-16 rounded-2xl bg-sf-warmGold/10 flex items-center justify-center mb-4">
          <MessageCircle size={32} className="text-sf-warmGold" />
        </div>
        <h2 className="text-base font-bold text-sf-charcoal mb-1">Belum Ada Percakapan</h2>
        <p className="text-sm text-gray-400 text-center max-w-xs">
          Pesan dari trainer dan grup Anda akan muncul di sini. Mulai percakapan untuk berkomunikasi.
        </p>
      </div>
    </div>
  );
}
