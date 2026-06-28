"use client";

import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend,
} from "recharts";

interface EngagementChartProps {
  data: { label: string; dau: number; wau: number; mau: number }[];
}

export function EngagementChart({ data }: EngagementChartProps) {
  if (data.length === 0) {
    return (
      <div className="h-72 flex items-center justify-center text-sm text-slate-400">
        No engagement data available
      </div>
    );
  }

  return (
    <ResponsiveContainer width="100%" height={288}>
      <BarChart data={data} margin={{ top: 8, right: 8, left: -16, bottom: 0 }} barCategoryGap="20%">
        <CartesianGrid strokeDasharray="3 3" stroke="#F1F5F9" vertical={false} />
        <XAxis dataKey="label" axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: "#94A3B8" }} />
        <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: "#94A3B8" }} />
        <Tooltip
          contentStyle={{
            backgroundColor: "white",
            border: "1px solid #E2E8F0",
            borderRadius: "12px",
            boxShadow: "0 4px 6px -1px rgb(0 0 0 / 0.07)",
            fontSize: "13px",
          }}
        />
        <Legend
          iconType="circle"
          iconSize={8}
          wrapperStyle={{ fontSize: "12px", paddingTop: "8px" }}
        />
        <Bar dataKey="dau" name="Daily Active" fill="#4F46E5" radius={[4, 4, 0, 0]} />
        <Bar dataKey="wau" name="Weekly Active" fill="#3B82F6" radius={[4, 4, 0, 0]} />
        <Bar dataKey="mau" name="Monthly Active" fill="#10B981" radius={[4, 4, 0, 0]} />
      </BarChart>
    </ResponsiveContainer>
  );
}

export function EngagementChartSkeleton() {
  return <div className="skeleton h-72 w-full rounded-xl" />;
}
