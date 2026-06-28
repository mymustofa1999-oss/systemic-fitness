"use client";

import { useState, useEffect, useRef } from "react";
import { useCreateClient, useUpdateClient } from "@/hooks/useUsers";
import { Loader2, UserPlus, Pencil, X } from "lucide-react";
import { SearchableSelect } from "@/components/shared/SearchableSelect";

interface ClientFormModalProps {
  open: boolean;
  onClose: () => void;
  /** null/undefined = create mode, an object = edit mode */
  client?: { id: string; full_name?: string; email?: string; phone?: string; status?: string } | null;
}

export function ClientFormModal({ open, onClose, client }: ClientFormModalProps) {
  const overlayRef = useRef<HTMLDivElement>(null);
  const isEdit = !!client;
  const { mutate: createClient, isPending: creating } = useCreateClient();
  const { mutate: updateClient, isPending: updating } = useUpdateClient();
  const isPending = creating || updating;

  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [password, setPassword] = useState("");
  const [status, setStatus] = useState("active");
  const [errors, setErrors] = useState<string[]>([]);

  // Reset/populate on open
  useEffect(() => {
    if (open) {
      setFullName(client?.full_name || "");
      setEmail(client?.email || "");
      setPhone(client?.phone || "");
      setPassword("");
      setStatus(client?.status || "active");
      setErrors([]);
    }
  }, [open, client]);

  // Close on Escape
  useEffect(() => {
    if (!open) return;
    const handler = (e: KeyboardEvent) => { if (e.key === "Escape") onClose(); };
    document.addEventListener("keydown", handler);
    return () => document.removeEventListener("keydown", handler);
  }, [open, onClose]);

  function validate(): boolean {
    const errs: string[] = [];
    if (fullName.trim().length < 2) errs.push("Nama minimal 2 karakter");
    if (!isEdit) {
      if (!email.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) errs.push("Email tidak valid");
      if (password.length < 8) errs.push("Password minimal 8 karakter");
    }
    setErrors(errs);
    return errs.length === 0;
  }

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!validate()) return;

    if (isEdit && client) {
      updateClient(
        { id: client.id, data: { full_name: fullName, phone: phone || undefined, status } },
        { onSuccess: () => onClose() }
      );
    } else {
      createClient(
        { full_name: fullName, email, password, phone: phone || undefined },
        { onSuccess: () => onClose() }
      );
    }
  }

  if (!open) return null;

  return (
    <div
      ref={overlayRef}
      className="fixed inset-0 z-50 flex items-center justify-center"
      onClick={(e) => { if (e.target === overlayRef.current) onClose(); }}
    >
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm animate-fade-in" />

      <div className="relative bg-white rounded-2xl shadow-xl max-w-lg w-full mx-4 animate-slide-in">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
          <div className="flex items-center gap-2.5">
            <div className="p-2 rounded-xl bg-sf-iceBlue">
              {isEdit ? <Pencil className="h-4 w-4 text-sf-deepNavy" /> : <UserPlus className="h-4 w-4 text-sf-deepNavy" />}
            </div>
            <h2 className="text-lg font-semibold text-slate-900">{isEdit ? "Edit Client" : "Tambah Client"}</h2>
          </div>
          <button onClick={onClose} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400 hover:text-slate-600">
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          {errors.length > 0 && (
            <div className="p-3 rounded-lg bg-rose-50 border border-rose-200">
              {errors.map((err, i) => (
                <p key={i} className="text-sm text-rose-700">{err}</p>
              ))}
            </div>
          )}

          <div>
            <label className="label">Nama Lengkap *</label>
            <input
              type="text"
              value={fullName}
              onChange={(e) => setFullName(e.target.value)}
              placeholder="John Doe"
              required
              className="input"
              autoFocus
            />
          </div>

          <div>
            <label className="label">Email *</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="user@example.com"
              required
              disabled={isEdit}
              className="input disabled:bg-slate-50 disabled:text-slate-400"
            />
            {isEdit && <p className="text-xs text-slate-400 mt-1">Email tidak dapat diubah.</p>}
          </div>

          <div>
            <label className="label">Nomor HP <span className="text-slate-400 font-normal">(opsional)</span></label>
            <input
              type="tel"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              placeholder="08xxxxxxxxxx"
              className="input"
            />
          </div>

          {!isEdit ? (
            <div>
              <label className="label">Password *</label>
              <input
                type="text"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Min. 8 karakter"
                required
                className="input"
              />
              <p className="text-xs text-slate-400 mt-1">Bagikan password ini ke client untuk login.</p>
            </div>
          ) : (
            <div>
              <label className="label">Status</label>
              <SearchableSelect
                options={[
                  { value: "active", label: "Active" },
                  { value: "inactive", label: "Inactive" },
                  { value: "suspended", label: "Suspended" },
                  { value: "pending", label: "Pending" },
                ]}
                value={status}
                onChange={setStatus}
                placeholder="Pilih status..."
              />
            </div>
          )}

          {/* Footer */}
          <div className="flex justify-end gap-3 pt-2">
            <button type="button" onClick={onClose} disabled={isPending} className="btn-secondary">
              Batal
            </button>
            <button type="submit" disabled={isPending} className="btn-primary">
              {isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : (isEdit ? <Pencil className="h-4 w-4" /> : <UserPlus className="h-4 w-4" />)}
              {isPending ? "Menyimpan..." : (isEdit ? "Simpan" : "Tambah Client")}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
