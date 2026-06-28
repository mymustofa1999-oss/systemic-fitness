"use client";

import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { apiGet } from "@/lib/api";
import {
  BarChart, Bar, PieChart, Pie, Cell, XAxis, YAxis,
  CartesianGrid, Tooltip, ResponsiveContainer, Legend,
} from "recharts";
import { ArrowLeft, Download, Calendar } from "lucide-react";
import Link from "next/link";
import { formatCurrency } from "@/lib/utils";

const PIE_COLORS = ["#4F46E5", "#3B82F6", "#10B981", "#F59E0B", "#F43F5E", "#8B5CF6"];

export default function ReportsPage() {
  const today = new Date();
  const thirtyDaysAgo = new Date(today); thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
  const [dateFrom, setDateFrom] = useState(thirtyDaysAgo.toISOString().split("T")[0]);
  const [dateTo, setDateTo] = useState(today.toISOString().split("T")[0]);

  const { data: report, isLoading } = useQuery({
    queryKey: ["financial-report", dateFrom, dateTo],
    queryFn: () => apiGet("/api/payments/reports", { period_start: dateFrom, period_end: dateTo }),
    enabled: !!dateFrom && !!dateTo,
  });
  const rpt = report?.data as any;

  const { data: monthlyData } = useQuery({
    queryKey: ["dashboard", "revenue", 12],
    queryFn: () => apiGet("/api/dashboard/revenue", { months: 12 }),
  });
  const monthlyChart = ((monthlyData?.data as any)?.data ?? []) as any[];

  function exportCSV() {
    if (!rpt) return;
    const rows = [
      ["Metric", "Value"],
      ["Period", `${dateFrom} to ${dateTo}`],
      ["Total Revenue", rpt.total_revenue],
      ["Net Revenue", rpt.net_revenue],
      ["Transactions", rpt.total_transactions],
      ["Successful", rpt.successful_payments],
      ["Failed", rpt.failed_payments],
      ["Refunded", rpt.refunded_payments],
      ["Refund Amount", rpt.refund_amount],
      ["Active Subs", rpt.active_subscriptions],
    ];
    const csv = rows.map((r) => r.join(",")).join("\n");
    const blob = new Blob([csv], { type: "text/csv" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a"); a.href = url; a.download = `financial_report_${dateFrom}_${dateTo}.csv`; a.click();
    URL.revokeObjectURL(url);
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Link href="/payments" className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400"><ArrowLeft className="h-4 w-4" /></Link>
          <h1 className="text-2xl font-bold text-slate-900">Financial Reports</h1>
        </div>
        <button onClick={exportCSV} disabled={!rpt} className="btn-secondary"><Download className="h-4 w-4" /> Export CSV</button>
      </div>

      {/* Date Range */}
      <div className="card p-4 flex items-center gap-4 flex-wrap">
        <Calendar className="h-4 w-4 text-slate-400" />
        <div className="flex items-center gap-2">
          <input type="date" value={dateFrom} onChange={(e) => setDateFrom(e.target.value)} className="input w-40" />
          <span className="text-slate-400">to</span>
          <input type="date" value={dateTo} onChange={(e) => setDateTo(e.target.value)} className="input w-40" />
        </div>
      </div>

      {isLoading ? (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">{Array.from({ length: 4 }).map((_, i) => <div key={i} className="skeleton h-20 rounded-xl" />)}</div>
      ) : rpt ? (
        <>
          {/* Summary Cards */}
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
            {[
              { label: "Total Revenue", value: formatCurrency(rpt.total_revenue ?? 0), color: "text-emerald-600" },
              { label: "Net Revenue", value: formatCurrency(rpt.net_revenue ?? 0), color: "text-blue-600" },
              { label: "Transactions", value: rpt.total_transactions ?? 0, color: "text-sf-deepNavy" },
              { label: "Active Subs", value: rpt.active_subscriptions ?? 0, color: "text-purple-600" },
            ].map((s) => (
              <div key={s.label} className="card p-4">
                <p className="text-xs text-slate-500">{s.label}</p>
                <p className={`text-xl font-bold font-heading mt-1 ${s.color}`}>{s.value}</p>
              </div>
            ))}
          </div>

          {/* Transaction breakdown */}
          <div className="grid grid-cols-3 gap-4">
            <div className="card p-4 text-center"><p className="text-2xl font-bold text-emerald-600">{rpt.successful_payments ?? 0}</p><p className="text-xs text-slate-500">Successful</p></div>
            <div className="card p-4 text-center"><p className="text-2xl font-bold text-rose-600">{rpt.failed_payments ?? 0}</p><p className="text-xs text-slate-500">Failed</p></div>
            <div className="card p-4 text-center"><p className="text-2xl font-bold text-amber-600">{rpt.refunded_payments ?? 0}</p><p className="text-xs text-slate-500">Refunded ({formatCurrency(rpt.refund_amount ?? 0)})</p></div>
          </div>

          {/* Charts Row */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {/* Revenue by Plan (Pie) */}
            <div className="card p-5">
              <h3 className="text-sm font-semibold text-slate-700 mb-4">Revenue by Plan</h3>
              {(rpt.revenue_by_plan ?? []).length > 0 ? (
                <ResponsiveContainer width="100%" height={240}>
                  <PieChart>
                    <Pie data={rpt.revenue_by_plan} dataKey="revenue" nameKey="plan_name" cx="50%" cy="50%" outerRadius={80} innerRadius={40} strokeWidth={0}>
                      {rpt.revenue_by_plan.map((_: any, i: number) => <Cell key={i} fill={PIE_COLORS[i % PIE_COLORS.length]} />)}
                    </Pie>
                    <Tooltip contentStyle={{ borderRadius: "12px", border: "1px solid #E2E8F0", fontSize: "12px" }} formatter={(v: any) => formatCurrency(Number(v))} />
                    <Legend iconType="circle" iconSize={8} wrapperStyle={{ fontSize: "12px" }} />
                  </PieChart>
                </ResponsiveContainer>
              ) : <div className="h-60 flex items-center justify-center text-sm text-slate-400">No data</div>}
            </div>

            {/* Monthly Revenue (Bar) */}
            <div className="card p-5">
              <h3 className="text-sm font-semibold text-slate-700 mb-4">Monthly Revenue</h3>
              {monthlyChart.length > 0 ? (
                <ResponsiveContainer width="100%" height={240}>
                  <BarChart data={monthlyChart} margin={{ top: 5, right: 5, left: -20, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#F1F5F9" vertical={false} />
                    <XAxis dataKey="month" tick={{ fontSize: 10, fill: "#94A3B8" }} axisLine={false} tickLine={false}
                      tickFormatter={(v) => { const m = v.split("-")[1]; const ms = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]; return ms[parseInt(m,10)-1] ?? v; }} />
                    <YAxis tick={{ fontSize: 10, fill: "#94A3B8" }} axisLine={false} tickLine={false}
                      tickFormatter={(v) => v >= 1e6 ? `${(v/1e6).toFixed(1)}M` : v >= 1e3 ? `${(v/1e3).toFixed(0)}K` : v} />
                    <Tooltip contentStyle={{ borderRadius: "12px", border: "1px solid #E2E8F0", fontSize: "12px" }} formatter={(v: any) => formatCurrency(Number(v))} />
                    <Bar dataKey="revenue" fill="#4F46E5" radius={[4, 4, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              ) : <div className="h-60 flex items-center justify-center text-sm text-slate-400">No data</div>}
            </div>
          </div>

          {/* Payment Method Breakdown */}
          {(rpt.revenue_by_method ?? []).length > 0 && (
            <div className="card p-5">
              <h3 className="text-sm font-semibold text-slate-700 mb-3">Payment Method Breakdown</h3>
              <div className="space-y-2">
                {rpt.revenue_by_method.map((m: any, i: number) => {
                  const pct = rpt.total_revenue > 0 ? (m.revenue / rpt.total_revenue * 100) : 0;
                  return (
                    <div key={i} className="flex items-center gap-3">
                      <span className="text-sm font-medium text-slate-700 w-24 capitalize">{m.method}</span>
                      <div className="flex-1 h-2 bg-slate-100 rounded-full overflow-hidden">
                        <div className="h-full rounded-full" style={{ width: `${pct}%`, backgroundColor: PIE_COLORS[i % PIE_COLORS.length] }} />
                      </div>
                      <span className="text-xs font-mono text-slate-600 w-20 text-right">{formatCurrency(m.revenue)}</span>
                      <span className="text-xs text-slate-400 w-12 text-right">{pct.toFixed(1)}%</span>
                    </div>
                  );
                })}
              </div>
            </div>
          )}
        </>
      ) : (
        <div className="card p-12 text-center text-sm text-slate-400">Select a date range to generate report</div>
      )}
    </div>
  );
}
