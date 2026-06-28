"use client";

import { cn } from "@/lib/utils";
import type { LucideIcon } from "lucide-react";

interface StatsCardProps {
  label: string;
  value: string | number;
  change?: number; // percentage
  icon: LucideIcon;
  iconColor?: string;
}

export function StatsCard({ label, value, change, icon: Icon, iconColor = "text-sf-deepNavy" }: StatsCardProps) {
  return (
    <div className="card p-6">
      <div className="flex items-start justify-between">
        <div>
          <p className="text-sm font-medium text-slate-500">{label}</p>
          <p className="mt-1 text-2xl font-bold font-heading text-slate-900">{value}</p>
          {change !== undefined && (
            <p className={cn("mt-1 text-xs font-medium", change >= 0 ? "text-emerald-600" : "text-rose-500")}>
              {change >= 0 ? "+" : ""}{change}% from last month
            </p>
          )}
        </div>
        <div className={cn("p-3 rounded-xl bg-slate-50", iconColor)}>
          <Icon className="h-5 w-5" />
        </div>
      </div>
    </div>
  );
}

export function StatsCardSkeleton() {
  return (
    <div className="card p-6">
      <div className="flex items-start justify-between">
        <div className="space-y-2">
          <div className="skeleton h-4 w-24" />
          <div className="skeleton h-8 w-16" />
          <div className="skeleton h-3 w-32" />
        </div>
        <div className="skeleton h-11 w-11 rounded-xl" />
      </div>
    </div>
  );
}
