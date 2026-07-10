"use client";

import { useState, useMemo } from "react";
import { useQuery } from "@tanstack/react-query";
import { apiGet } from "@/lib/api";
import axios from "axios";
import { CreditCard, Clock, Crown, Plus, X, File, Upload, Loader2, Check } from "lucide-react";
import { useAuth } from "@/hooks/useAuth";
import { useSubscriptionPlans, useCreateManualSubscription, useUpdateSubscriptionAttachment } from "@/hooks/useSubscription";
import { cn, formatCurrency, formatDate } from "@/lib/utils";

const tierStyle: Record<string, { gradient: string; icon: any }> = {
  basic: { gradient: "from-slate-600 to-slate-700", icon: CreditCard },
  pro: { gradient: "from-blue-600 to-blue-800", icon: Crown },
  elite: { gradient: "from-sf-deepNavy to-black", icon: Crown },
};
// Use Crown for default Zap alternative in case Zap is undefined in lucide-react if imported wrongly

export function ClientSubscriptionSection({ clientId, clientName }: { clientId: string; clientName: string }) {
  const [tab, setTab] = useState<"subscriptions" | "payments">("subscriptions");
  const [manualSubOpen, setManualSubOpen] = useState(false);
  const [selectedPlanId, setSelectedPlanId] = useState("");
  const [uploadingId, setUploadingId] = useState<string | null>(null);

  const { isFinance } = useAuth();
  const createManualSub = useCreateManualSubscription();
  const updateAttachment = useUpdateSubscriptionAttachment();

  const { data: subsData, isLoading: subsLoading } = useQuery({
    queryKey: ["client-subscriptions", clientId],
    queryFn: () => apiGet("/api/payments/subscriptions", { user_id: clientId, limit: 50 }),
  });
  const subs = (subsData?.data ?? []) as any[];

  const { data: payData, isLoading: payLoading } = useQuery({
    queryKey: ["client-payments", clientId],
    queryFn: () => apiGet("/api/payments", { user_id: clientId, limit: 50 }),
  });
  const payments = (payData?.data ?? []) as any[];

  const { data: plansData, isLoading: plansLoading } = useSubscriptionPlans();
  const plans = (plansData?.data ?? []) as any[];

  const planOptions = useMemo(() => {
    const opts: { value: string; label: string }[] = [];
    plans.forEach((group: any) => {
      if (group.monthly) {
        opts.push({
          value: group.monthly.id,
          label: `${group.monthly.name} - ${formatCurrency(group.monthly.price)} / bulan`,
        });
      }
      if (group.annual) {
        opts.push({
          value: group.annual.id,
          label: `${group.annual.name} - ${formatCurrency(group.annual.price)} / tahun`,
        });
      }
    });
    return opts;
  }, [plans]);

  const activeSub = subs.find((s: any) => s.status === "active");
  const tier = activeSub?.plan_name?.toLowerCase()?.includes("elite") ? "elite"
    : activeSub?.plan_name?.toLowerCase()?.includes("pro") ? "pro"
    : activeSub ? "basic" : null;
  const ts = tier ? tierStyle[tier] : null;
  const TierIcon = ts?.icon || CreditCard;

  let daysLeft: number | null = null;
  if (activeSub?.expires_at) {
    daysLeft = Math.ceil((new Date(activeSub.expires_at).getTime() - Date.now()) / (1000 * 60 * 60 * 24));
  }

  const totalSpent = payments
    .filter((p: any) => p.status === "completed")
    .reduce((sum: number, p: any) => sum + (p.amount || 0), 0);

  const handleCreateManualSub = async () => {
    if (!selectedPlanId) return;
    try {
      await createManualSub.mutateAsync({
        user_id: clientId,
        plan_id: selectedPlanId,
      });
      setManualSubOpen(false);
      setSelectedPlanId("");
    } catch (e) {
      // Error handled by toast
    }
  };

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>, subId: string) => {
    const file = e.target.files?.[0];
    if (!file) return;
    if (file.size > 10 * 1024 * 1024) {
      alert("File too large. Maximum size is 10MB");
      return;
    }

    setUploadingId(subId);
    try {
      const formData = new FormData();
      formData.append("file", file);
      const res = await axios.post("/api/uploads", formData, {
        baseURL: process.env.NEXT_PUBLIC_API_URL || "http://localhost:8080",
      });
      const url = res.data?.data?.url;
      if (url) {
        await updateAttachment.mutateAsync({ id: subId, attachment_url: url });
      }
    } catch (err: any) {
      alert("Upload failed: " + err.message);
    } finally {
      setUploadingId(null);
      e.target.value = "";
    }
  };

  return (
    <div className="space-y-3">
      {activeSub ? (
        <div className={cn("rounded-xl p-5 text-white bg-gradient-to-r", ts?.gradient || "from-slate-500 to-slate-600")}>
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-white/20 rounded-lg">
                <TierIcon className="h-5 w-5" />
              </div>
              <div>
                <p className="text-sm text-white/70">Langganan Aktif</p>
                <p className="text-xl font-bold">{activeSub.plan_name}</p>
              </div>
            </div>
            <div className="text-right flex flex-col items-end gap-1.5">
              <div className="flex items-center gap-1.5 text-white/80 text-sm font-semibold">
                <Clock className="h-4 w-4" />
                {daysLeft != null && daysLeft > 0 ? `${daysLeft} hari tersisa` : "Expired"}
              </div>
              <p className="text-xs text-white/50">s/d {formatDate(activeSub.expires_at)}</p>
              {isFinance && (
                <button
                  onClick={() => setManualSubOpen(true)}
                  className="mt-2 px-2.5 py-1 text-xs bg-white text-sf-deepNavy font-bold rounded hover:bg-slate-100 transition-colors shadow-sm"
                >
                  Ubah / Set Paket
                </button>
              )}
            </div>
          </div>
          <div className="flex items-center gap-4 mt-3 pt-3 border-t border-white/20 text-sm text-white/70">
            <span>Mulai: {formatDate(activeSub.started_at)}</span>
            <span>Metode: {activeSub.payment_method || "-"}</span>
            <span>Total Langganan: {subs.length}x</span>
            <span>Total Bayar: {formatCurrency(totalSpent)}</span>
          </div>
        </div>
      ) : (
        <div className="card p-5 flex items-center justify-between border-dashed border-2 bg-slate-50/50">
          <div className="flex items-center gap-4">
            <div className="p-2 bg-slate-100 rounded-lg">
              <CreditCard className="h-5 w-5 text-slate-400" />
            </div>
            <div>
              <p className="text-sm font-semibold text-slate-700">Belum Berlangganan</p>
              <p className="text-xs text-slate-400">{clientName} belum memiliki langganan aktif</p>
            </div>
          </div>
          {isFinance && (
            <button
              onClick={() => setManualSubOpen(true)}
              className="btn-primary text-xs px-3 py-1.5 flex items-center gap-1"
            >
              <Plus className="h-3.5 w-3.5" /> Set Paket Langganan
            </button>
          )}
        </div>
      )}

      {manualSubOpen && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center" onClick={() => setManualSubOpen(false)}>
          <div className="absolute inset-0 bg-black/40 backdrop-blur-sm animate-fade-in" />
          <div className="relative bg-white rounded-2xl shadow-xl max-w-md w-full mx-4 p-6 animate-slide-in" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between border-b border-slate-100 pb-3 mb-4">
              <h3 className="font-bold text-slate-900 flex items-center gap-2">
                <Crown className="h-5 w-5 text-sf-warmGold" />
                Set Paket Langganan Manual
              </h3>
              <button onClick={() => setManualSubOpen(false)} className="p-1 rounded-lg hover:bg-slate-100 text-slate-400">
                <X className="h-5 w-5" />
              </button>
            </div>

            <div className="space-y-4">
              <p className="text-sm text-slate-500">
                Pilih paket berlangganan untuk client <strong>{clientName}</strong>.
              </p>
              <div>
                <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Paket</label>
                <select
                  value={selectedPlanId}
                  onChange={(e) => setSelectedPlanId(e.target.value)}
                  className="w-full border border-slate-300 rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-sf-warmGold/50 outline-none"
                >
                  <option value="">-- Pilih Paket --</option>
                  {planOptions.map((o) => (
                    <option key={o.value} value={o.value}>{o.label}</option>
                  ))}
                </select>
              </div>
            </div>

            <div className="mt-8 flex justify-end gap-3">
              <button onClick={() => setManualSubOpen(false)} className="btn-secondary text-sm px-4">Batal</button>
              <button onClick={handleCreateManualSub} disabled={!selectedPlanId || createManualSub.isPending} className="btn-primary text-sm px-4">
                {createManualSub.isPending ? <Loader2 className="h-4 w-4 animate-spin mr-1.5" /> : null}
                Aktifkan Paket
              </button>
            </div>
          </div>
        </div>
      )}

      <div className="card overflow-hidden">
        <div className="flex items-center gap-6 px-5 pt-4 border-b border-slate-100">
          <button
            onClick={() => setTab("subscriptions")}
            className={cn("pb-3 text-sm font-semibold transition-colors border-b-2 relative top-[1px]",
              tab === "subscriptions" ? "border-sf-deepNavy text-sf-deepNavy" : "border-transparent text-slate-500 hover:text-slate-800"
            )}
          >
            Riwayat Langganan
          </button>
          <button
            onClick={() => setTab("payments")}
            className={cn("pb-3 text-sm font-semibold transition-colors border-b-2 relative top-[1px]",
              tab === "payments" ? "border-sf-deepNavy text-sf-deepNavy" : "border-transparent text-slate-500 hover:text-slate-800"
            )}
          >
            Riwayat Pembayaran
          </button>
        </div>

        <div className="p-0">
          {tab === "subscriptions" && (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="bg-slate-50 border-b border-slate-100">
                    <th className="px-5 py-3 text-left text-xs font-bold text-slate-500 uppercase tracking-wider">Tanggal</th>
                    <th className="px-5 py-3 text-left text-xs font-bold text-slate-500 uppercase tracking-wider">Paket</th>
                    <th className="px-5 py-3 text-left text-xs font-bold text-slate-500 uppercase tracking-wider">Status</th>
                    <th className="px-5 py-3 text-left text-xs font-bold text-slate-500 uppercase tracking-wider">Masa Aktif</th>
                    <th className="px-5 py-3 text-left text-xs font-bold text-slate-500 uppercase tracking-wider">Hasil Lab</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {subsLoading ? (
                    <tr><td colSpan={5} className="p-8 text-center"><Loader2 className="h-5 w-5 animate-spin mx-auto text-slate-400" /></td></tr>
                  ) : subs.length === 0 ? (
                    <tr><td colSpan={5} className="p-8 text-center text-slate-500 text-sm">Belum ada riwayat langganan</td></tr>
                  ) : (
                    subs.map((s: any) => (
                      <tr key={s.id} className="hover:bg-slate-50/50 transition-colors">
                        <td className="px-5 py-3 font-mono text-xs text-slate-600">{formatDate(s.created_at)}</td>
                        <td className="px-5 py-3 font-semibold text-slate-900">{s.plan_name}</td>
                        <td className="px-5 py-3">
                          <span className={cn(
                            "px-2 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider",
                            s.status === "active" ? "bg-green-100 text-green-700"
                              : s.status === "expired" ? "bg-slate-100 text-slate-600"
                              : "bg-orange-100 text-orange-700"
                          )}>
                            {s.status}
                          </span>
                        </td>
                        <td className="px-5 py-3 text-xs text-slate-600 font-mono">
                          {formatDate(s.started_at)} - {formatDate(s.expires_at)}
                        </td>
                        <td className="px-5 py-3 text-xs">
                          {s.attachment_url ? (
                            <a href={s.attachment_url} target="_blank" rel="noreferrer" className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-blue-50 text-blue-700 hover:bg-blue-100 font-medium rounded-lg transition-colors shadow-sm">
                              <File className="h-3.5 w-3.5" /> Lihat Hasil
                            </a>
                          ) : (
                            <div className="relative inline-block">
                              <input 
                                type="file" 
                                className="absolute inset-0 w-full h-full opacity-0 cursor-pointer disabled:cursor-not-allowed" 
                                accept="application/pdf,image/*"
                                onChange={(e) => handleFileUpload(e, s.id)}
                                disabled={uploadingId === s.id}
                              />
                              <button disabled={uploadingId === s.id} className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-slate-100 text-slate-600 hover:bg-slate-200 font-medium rounded-lg transition-colors shadow-sm disabled:opacity-50">
                                {uploadingId === s.id ? <Loader2 className="h-3.5 w-3.5 animate-spin" /> : <Upload className="h-3.5 w-3.5" />} Upload
                              </button>
                            </div>
                          )}
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          )}

          {tab === "payments" && (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="bg-slate-50 border-b border-slate-100">
                    <th className="px-5 py-3 text-left text-xs font-bold text-slate-500 uppercase tracking-wider">Tanggal</th>
                    <th className="px-5 py-3 text-left text-xs font-bold text-slate-500 uppercase tracking-wider">Invoice</th>
                    <th className="px-5 py-3 text-left text-xs font-bold text-slate-500 uppercase tracking-wider">Metode</th>
                    <th className="px-5 py-3 text-left text-xs font-bold text-slate-500 uppercase tracking-wider">Total</th>
                    <th className="px-5 py-3 text-left text-xs font-bold text-slate-500 uppercase tracking-wider">Status</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {payLoading ? (
                    <tr><td colSpan={5} className="p-8 text-center"><Loader2 className="h-5 w-5 animate-spin mx-auto text-slate-400" /></td></tr>
                  ) : payments.length === 0 ? (
                    <tr><td colSpan={5} className="p-8 text-center text-slate-500 text-sm">Belum ada riwayat pembayaran</td></tr>
                  ) : (
                    payments.map((p: any) => (
                      <tr key={p.id} className="hover:bg-slate-50/50 transition-colors">
                        <td className="px-5 py-3 font-mono text-xs text-slate-600">{formatDate(p.created_at)}</td>
                        <td className="px-5 py-3 font-mono text-xs">{p.invoice_number || "-"}</td>
                        <td className="px-5 py-3 text-slate-700">{p.payment_method || "-"}</td>
                        <td className="px-5 py-3 font-semibold text-sf-deepNavy">{formatCurrency(p.amount)}</td>
                        <td className="px-5 py-3">
                          <span className={cn(
                            "px-2 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider",
                            p.status === "completed" || p.status === "paid" ? "bg-green-100 text-green-700"
                              : p.status === "failed" ? "bg-red-100 text-red-700"
                              : "bg-orange-100 text-orange-700"
                          )}>
                            {p.status}
                          </span>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
