"use client";

import { useState, useEffect, useRef } from "react";
import { useInviteUser } from "@/hooks/useUsers";
import { Loader2, UserPlus, X } from "lucide-react";
import { SearchableSelect } from "@/components/shared/SearchableSelect";

interface InviteUserModalProps {
  open: boolean;
  onClose: () => void;
  defaultRole?: string;
}

export function InviteUserModal({ open, onClose, defaultRole }: InviteUserModalProps) {
  const overlayRef = useRef<HTMLDivElement>(null);
  const { mutate: invite, isPending } = useInviteUser();

  const [email, setEmail] = useState("");
  const [fullName, setFullName] = useState("");
  const [role, setRole] = useState("client");
  const [message, setMessage] = useState("");
  const [errors, setErrors] = useState<string[]>([]);

  // Reset on open
  useEffect(() => {
    if (open) {
      setEmail("");
      setFullName("");
      setRole(defaultRole || "client");
      setMessage("");
      setErrors([]);
    }
  }, [open, defaultRole]);

  // Close on Escape
  useEffect(() => {
    if (!open) return;
    const handler = (e: KeyboardEvent) => { if (e.key === "Escape") onClose(); };
    document.addEventListener("keydown", handler);
    return () => document.removeEventListener("keydown", handler);
  }, [open, onClose]);

  function validate(): boolean {
    const errs: string[] = [];
    if (!email.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) errs.push("Please enter a valid email address");
    if (fullName.trim().length < 2) errs.push("Name must be at least 2 characters");
    setErrors(errs);
    return errs.length === 0;
  }

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!validate()) return;

    invite(
      { email, full_name: fullName, role, message: message || undefined },
      { onSuccess: () => onClose() }
    );
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
              <UserPlus className="h-4 w-4 text-sf-deepNavy" />
            </div>
            <h2 className="text-lg font-semibold text-slate-900">Invite User</h2>
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
            <label className="label">Email Address *</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="user@example.com"
              required
              className="input"
              autoFocus
            />
          </div>

          <div>
            <label className="label">Full Name *</label>
            <input
              type="text"
              value={fullName}
              onChange={(e) => setFullName(e.target.value)}
              placeholder="John Doe"
              required
              className="input"
            />
          </div>

          <div>
            <label className="label">Role *</label>
            <SearchableSelect
              options={[{ value: "client", label: "Client" }, { value: "trainer", label: "Trainer" }, { value: "consultant", label: "Consultant" }, { value: "finance", label: "Finance" }, { value: "admin", label: "Admin" }]}
              value={role}
              onChange={setRole}
              placeholder="Select role..."
            />
            <p className="text-xs text-slate-400 mt-1">
              {role === "client" && "Can view workouts, log progress, chat with trainer"}
              {role === "trainer" && "Can manage workouts, programs, and assigned clients"}
              {role === "consultant" && "Can review assessment v2, lab consultations, and clinical notes"}
              {role === "finance" && "Can view payments, subscriptions, and financial reports"}
              {role === "admin" && "Full access to all features except owner settings"}
            </p>
          </div>

          <div>
            <label className="label">Personal Message <span className="text-slate-400 font-normal">(optional)</span></label>
            <textarea
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              placeholder="Welcome to Systemic Fitness! Looking forward to working with you."
              className="input"
              rows={3}
            />
          </div>

          {/* Footer */}
          <div className="flex justify-end gap-3 pt-2">
            <button type="button" onClick={onClose} disabled={isPending} className="btn-secondary">
              Cancel
            </button>
            <button type="submit" disabled={isPending} className="btn-primary">
              {isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <UserPlus className="h-4 w-4" />}
              {isPending ? "Sending..." : "Send Invitation"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
