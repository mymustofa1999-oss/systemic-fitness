"use client";

import { cn } from "@/lib/utils";
import { ChevronLeft, ChevronRight, ChevronsUpDown } from "lucide-react";

// ── Types ───────────────────────────────────────────────────────

export interface Column<T> {
  key: string;
  label: string;
  sortable?: boolean;
  className?: string;
  render?: (row: T) => React.ReactNode;
}

interface DataTableProps<T> {
  columns: Column<T>[];
  data: T[];
  loading?: boolean;
  page?: number;
  pageSize?: number;
  totalPages?: number;
  total?: number;
  onPageChange?: (page: number) => void;
  onSort?: (key: string) => void;
  sortBy?: string;
  sortOrder?: "asc" | "desc";
  onRowClick?: (row: T) => void;
  emptyMessage?: string;
}

// ── Helpers ─────────────────────────────────────────────────────

function getPageNumbers(current: number, total: number): (number | "...")[] {
  if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1);

  const pages: (number | "...")[] = [1];

  if (current > 3) pages.push("...");

  const start = Math.max(2, current - 1);
  const end = Math.min(total - 1, current + 1);
  for (let i = start; i <= end; i++) pages.push(i);

  if (current < total - 2) pages.push("...");

  pages.push(total);
  return pages;
}

// ── Component ───────────────────────────────────────────────────

export function DataTable<T extends Record<string, any>>({
  columns, data, loading, page = 1, pageSize = 20, totalPages = 1, total = 0,
  onPageChange, onSort, sortBy, onRowClick, emptyMessage = "No data found",
}: DataTableProps<T>) {
  if (loading) return <TableSkeleton columns={columns.length} />;

  return (
    <div className="card overflow-hidden">
      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-slate-100 bg-slate-50/50">
              {columns.map((col) => (
                <th
                  key={col.key}
                  className={cn(
                    "px-4 py-3 text-left font-medium text-slate-500 whitespace-nowrap",
                    col.sortable && "cursor-pointer select-none hover:text-slate-700",
                    col.className
                  )}
                  onClick={() => col.sortable && onSort?.(col.key)}
                >
                  <span className="inline-flex items-center gap-1">
                    {col.label}
                    {col.sortable && (
                      <ChevronsUpDown className={cn(
                        "h-3.5 w-3.5",
                        sortBy === col.key ? "text-sf-deepNavy" : "text-slate-300"
                      )} />
                    )}
                  </span>
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-50">
            {data.length === 0 ? (
              <tr>
                <td colSpan={columns.length} className="px-4 py-12 text-center text-slate-400">
                  {emptyMessage}
                </td>
              </tr>
            ) : (
              data.map((row, i) => (
                <tr
                  key={(row as any).id || i}
                  className={cn(
                    "hover:bg-slate-50/80 transition-colors",
                    onRowClick && "cursor-pointer"
                  )}
                  onClick={() => onRowClick?.(row)}
                >
                  {columns.map((col) => (
                    <td key={col.key} className={cn("px-4 py-3.5 whitespace-nowrap", col.className)}>
                      {col.render ? col.render(row) : String(row[col.key] ?? "—")}
                    </td>
                  ))}
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination — always visible */}
      <div className="flex items-center justify-between px-4 py-3 border-t border-slate-100">
        <p className="text-xs text-slate-500">
          {total === 0
            ? "No data"
            : `Showing ${(page - 1) * pageSize + 1}–${Math.min(page * pageSize, total)} of ${total}`}
        </p>

        {totalPages > 1 && (
          <div className="flex items-center gap-1">
            {/* Previous */}
            <button
              type="button"
              className="p-1.5 rounded-lg text-slate-500 hover:bg-slate-100 disabled:opacity-30 disabled:hover:bg-transparent transition-colors"
              disabled={page <= 1}
              onClick={() => onPageChange?.(page - 1)}
            >
              <ChevronLeft className="h-4 w-4" />
            </button>

            {/* Page numbers */}
            {getPageNumbers(page, totalPages).map((p, i) =>
              p === "..." ? (
                <span key={`dots-${i}`} className="px-1.5 text-xs text-slate-400 select-none">
                  ...
                </span>
              ) : (
                <button
                  key={p}
                  type="button"
                  onClick={() => onPageChange?.(p as number)}
                  className={cn(
                    "min-w-[32px] h-8 rounded-lg text-xs font-medium transition-colors",
                    p === page
                      ? "bg-sf-deepNavy text-white shadow-sm"
                      : "text-slate-600 hover:bg-slate-100"
                  )}
                >
                  {p}
                </button>
              )
            )}

            {/* Next */}
            <button
              type="button"
              className="p-1.5 rounded-lg text-slate-500 hover:bg-slate-100 disabled:opacity-30 disabled:hover:bg-transparent transition-colors"
              disabled={page >= totalPages}
              onClick={() => onPageChange?.(page + 1)}
            >
              <ChevronRight className="h-4 w-4" />
            </button>
          </div>
        )}
      </div>
    </div>
  );
}

function TableSkeleton({ columns }: { columns: number }) {
  return (
    <div className="card overflow-hidden">
      <div className="px-4 py-3 border-b border-slate-100 bg-slate-50/50">
        <div className="flex gap-4">
          {Array.from({ length: columns }).map((_, i) => (
            <div key={i} className="skeleton h-4 w-24" />
          ))}
        </div>
      </div>
      {Array.from({ length: 5 }).map((_, i) => (
        <div key={i} className="px-4 py-4 border-b border-slate-50 flex gap-4">
          {Array.from({ length: columns }).map((_, j) => (
            <div key={j} className="skeleton h-4 w-20" />
          ))}
        </div>
      ))}
    </div>
  );
}
