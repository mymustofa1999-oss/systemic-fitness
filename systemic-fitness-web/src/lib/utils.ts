import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatCurrency(amount: number | null | undefined, currency = "IDR"): string {
  const value = typeof amount === "number" && isFinite(amount) ? amount : 0;
  // Intl throws a RangeError on an invalid/blank currency code — fall back to IDR.
  const code = typeof currency === "string" && /^[A-Za-z]{3}$/.test(currency) ? currency : "IDR";
  try {
    return new Intl.NumberFormat("id-ID", { style: "currency", currency: code }).format(value);
  } catch {
    return new Intl.NumberFormat("id-ID", { style: "currency", currency: "IDR" }).format(value);
  }
}

export function formatDate(date: string | Date | null | undefined): string {
  if (!date) return "-";
  const d = new Date(date);
  // Intl throws "Invalid time value" on an unparseable date — guard against it.
  if (isNaN(d.getTime())) return "-";
  return new Intl.DateTimeFormat("id-ID", {
    day: "numeric", month: "short", year: "numeric",
  }).format(d);
}

export function formatRelative(date: string | Date): string {
  const diff = Date.now() - new Date(date).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1) return "Just now";
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  const days = Math.floor(hrs / 24);
  if (days < 7) return `${days}d ago`;
  return formatDate(date);
}

export function getInitials(name: string): string {
  return name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);
}
