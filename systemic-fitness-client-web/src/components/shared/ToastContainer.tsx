"use client";

import { useToastStore } from "@/stores/toastStore";
import { CheckCircle, XCircle, Info, X } from "lucide-react";

export function ToastContainer() {
  const { toasts, removeToast } = useToastStore();

  if (toasts.length === 0) return null;

  return (
    <div className="fixed top-4 right-4 z-[100] flex flex-col gap-2 max-w-sm w-full pointer-events-none">
      {toasts.map((t) => (
        <div
          key={t.id}
          className={`
            pointer-events-auto flex items-start gap-3 px-4 py-3 rounded-xl shadow-soft
            animate-slide-in backdrop-blur-xl border
            ${t.type === "success" ? "bg-emerald-50/90 border-emerald-200 text-emerald-800" : ""}
            ${t.type === "error" ? "bg-rose-50/90 border-rose-200 text-rose-800" : ""}
            ${t.type === "info" ? "bg-blue-50/90 border-blue-200 text-blue-800" : ""}
          `}
        >
          <span className="mt-0.5 shrink-0">
            {t.type === "success" && <CheckCircle size={18} />}
            {t.type === "error" && <XCircle size={18} />}
            {t.type === "info" && <Info size={18} />}
          </span>
          <p className="text-sm font-medium flex-1">{t.message}</p>
          <button
            onClick={() => removeToast(t.id)}
            className="shrink-0 hover:opacity-70 transition-opacity"
          >
            <X size={16} />
          </button>
        </div>
      ))}
    </div>
  );
}
