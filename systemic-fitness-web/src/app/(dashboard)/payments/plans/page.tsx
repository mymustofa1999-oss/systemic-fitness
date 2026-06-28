"use client";

import { useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPost, apiPut, apiDelete } from "@/lib/api";
import { toast } from "@/stores/toastStore";
import { ArrowLeft, Plus, Check, X, Loader2, Pencil, Trash2 } from "lucide-react";
import { formatCurrency } from "@/lib/utils";
import Link from "next/link";
import { SearchableSelect } from "@/components/shared/SearchableSelect";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";

export default function PlansPage() {
  const qc = useQueryClient();
  const [createOpen, setCreateOpen] = useState(false);
  const [editPlan, setEditPlan] = useState<any>(null);
  const [deletePlan, setDeletePlan] = useState<any>(null);
  const [deleting, setDeleting] = useState(false);
  const { data, isLoading } = useQuery({ queryKey: ["payment-plans"], queryFn: () => apiGet("/api/payments/plans") });
  const plans = (data?.data ?? []) as any[];

  async function handleDelete() {
    if (!deletePlan) return;
    setDeleting(true);
    try {
      await apiDelete(`/api/payments/plans/${deletePlan.id}`);
      qc.invalidateQueries({ queryKey: ["payment-plans"] });
      toast.success("Plan deleted");
      setDeletePlan(null);
    } catch (err: any) {
      toast.error(err.message);
    } finally {
      setDeleting(false);
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Link href="/payments" className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400"><ArrowLeft className="h-4 w-4" /></Link>
          <h1 className="text-2xl font-bold text-slate-900">Pricing Plans</h1>
        </div>
        <button onClick={() => setCreateOpen(true)} className="btn-primary"><Plus className="h-4 w-4" /> Create Plan</button>
      </div>

      {isLoading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">{Array.from({ length: 3 }).map((_, i) => <div key={i} className="skeleton h-72 rounded-xl" />)}</div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {plans.map((plan: any) => {
            const features = typeof plan.features === "string" ? JSON.parse(plan.features) : plan.features ?? [];
            return (
              <div key={plan.id} className="card p-6 flex flex-col">
                <div className="flex items-center justify-between mb-4">
                  <h3 className="text-lg font-bold text-slate-900">{plan.name}</h3>
                  {!plan.is_active && <span className="text-xs text-slate-400 italic">Inactive</span>}
                </div>
                <p className="text-3xl font-bold font-heading text-sf-deepNavy mb-1">{formatCurrency(plan.price, plan.currency)}</p>
                <p className="text-sm text-slate-500 mb-2">/ {plan.duration_months} month{plan.duration_months > 1 ? "s" : ""}</p>
                <div className="flex flex-wrap gap-1.5 mb-4">
                  {plan.tier && (
                    <span className="px-2 py-0.5 text-[10px] font-semibold bg-indigo-50 text-indigo-600 rounded border border-indigo-100">
                      Tier: {plan.tier}
                    </span>
                  )}
                  {plan.billing_period && (
                    <span className="px-2 py-0.5 text-[10px] font-semibold bg-emerald-50 text-emerald-600 rounded border border-emerald-100 uppercase">
                      {plan.billing_period}
                    </span>
                  )}
                </div>
                {plan.description && <p className="text-sm text-slate-600 mb-4">{plan.description}</p>}
                <ul className="space-y-2 flex-1 mb-4">
                  {features.map((f: string, i: number) => (
                    <li key={i} className="flex items-start gap-2 text-sm text-slate-600"><Check className="h-4 w-4 text-emerald-500 shrink-0 mt-0.5" />{f}</li>
                  ))}
                </ul>
                <div className="flex gap-2">
                  <button className="btn-secondary flex-1" onClick={() => setEditPlan(plan)}>
                    <Pencil className="h-4 w-4" /> Edit
                  </button>
                  <button className="btn-secondary text-rose-600 hover:bg-rose-50" onClick={() => setDeletePlan(plan)}>
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Create Plan Modal */}
      {createOpen && <CreatePlanModal onClose={() => setCreateOpen(false)} />}

      {/* Edit Plan Modal */}
      {editPlan && <CreatePlanModal plan={editPlan} onClose={() => setEditPlan(null)} />}

      {/* Delete Confirm */}
      <ConfirmDialog
        open={!!deletePlan}
        onClose={() => setDeletePlan(null)}
        onConfirm={handleDelete}
        title="Delete Plan"
        description={`Are you sure you want to delete "${deletePlan?.name}"? This action cannot be undone.`}
        confirmLabel="Delete"
        variant="danger"
        loading={deleting}
      />
    </div>
  );
}

function CreatePlanModal({ onClose, plan }: { onClose: () => void; plan?: any }) {
  const isEdit = !!plan;
  const qc = useQueryClient();
  const [loading, setLoading] = useState(false);
  const [name, setName] = useState(plan?.name ?? "");
  const [description, setDescription] = useState(plan?.description ?? "");
  const [price, setPrice] = useState(plan?.price?.toString() ?? "");
  const [currency, setCurrency] = useState(plan?.currency ?? "IDR");
  const [duration, setDuration] = useState(plan?.duration_months?.toString() ?? "1");
  const [tier, setTier] = useState(plan?.tier ?? "");
  const [billingPeriod, setBillingPeriod] = useState(plan?.billing_period ?? "monthly");
  const parsedFeatures = plan?.features ? (typeof plan.features === "string" ? JSON.parse(plan.features) : plan.features) : [""];
  const [features, setFeatures] = useState<string[]>(parsedFeatures.length > 0 ? parsedFeatures : [""]);

  function addFeature() { setFeatures([...features, ""]); }
  function updateFeature(i: number, v: string) { setFeatures(features.map((f, idx) => idx === i ? v : f)); }
  function removeFeature(i: number) { setFeatures(features.filter((_, idx) => idx !== i)); }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim() || !price) return;
    setLoading(true);
    try {
      const payload = {
        name, description: description || undefined,
        price: parseFloat(price), currency,
        duration_months: parseInt(duration),
        features: JSON.stringify(features.filter((f) => f.trim())),
        tier: tier || null,
        billing_period: billingPeriod || null,
      };
      if (isEdit) {
        await apiPut(`/api/payments/plans/${plan.id}`, payload);
        toast.success("Plan updated");
      } else {
        await apiPost("/api/payments/plans", payload);
        toast.success("Plan created");
      }
      qc.invalidateQueries({ queryKey: ["payment-plans"] });
      onClose();
    } catch (err: any) { toast.error(err.message); }
    setLoading(false);
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center" onClick={onClose}>
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" />
      <div className="relative bg-white rounded-2xl shadow-xl max-w-lg w-full mx-4 animate-slide-in" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
          <h2 className="text-lg font-semibold text-slate-900">{isEdit ? "Edit Plan" : "Create Plan"}</h2>
          <button onClick={onClose} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400"><X className="h-5 w-5" /></button>
        </div>
        <form onSubmit={handleSubmit} className="p-6 space-y-4 max-h-[70vh] overflow-y-auto">
          <div><label className="label">Plan Name *</label><input value={name} onChange={(e) => setName(e.target.value)} className="input" required autoFocus /></div>
          <div><label className="label">Description</label><textarea value={description} onChange={(e) => setDescription(e.target.value)} className="input" rows={2} /></div>
          <div className="grid grid-cols-3 gap-3">
            <div><label className="label">Price *</label><input value={price} onChange={(e) => setPrice(e.target.value)} type="number" min="0" className="input" required /></div>
            <div><label className="label">Currency</label><SearchableSelect options={[{ value: "IDR", label: "IDR" }, { value: "USD", label: "USD" }]} value={currency} onChange={setCurrency} placeholder="Currency" /></div>
            <div><label className="label">Duration</label><SearchableSelect options={[{ value: "1", label: "1 month" }, { value: "3", label: "3 months" }, { value: "6", label: "6 months" }, { value: "12", label: "12 months" }]} value={duration} onChange={setDuration} placeholder="Duration" /></div>
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="label">Subscription Tier (slug)</label>
              <SearchableSelect
                options={[
                  { value: "", label: "No Tier (None)" },
                  { value: "sf_free", label: "SF Free — System Check" },
                  { value: "sf_tier_1", label: "Tier 1 — Preventive Auto" },
                  { value: "sf_tier_2", label: "Tier 2 — Performance Program" },
                  { value: "sf_tier_3", label: "Tier 3 — System Active" },
                  { value: "sf_tier_4_waitlist", label: "Tier 4 — System Elite (Waitlist)" },
                  { value: "sf_lab_consultation", label: "Lab Consultation" },
                ]}
                value={tier}
                onChange={setTier}
                placeholder="Select Tier"
              />
            </div>
            <div>
              <label className="label">Billing Period</label>
              <SearchableSelect
                options={[
                  { value: "monthly", label: "Monthly" },
                  { value: "quarterly", label: "Quarterly" },
                  { value: "annual", label: "Annual" },
                ]}
                value={billingPeriod}
                onChange={setBillingPeriod}
                placeholder="Select Period"
              />
            </div>
          </div>
          <div>
            <div className="flex items-center justify-between mb-1.5"><label className="text-sm font-medium text-slate-700">Features</label><button type="button" onClick={addFeature} className="text-xs text-sf-deepNavy hover:text-sf-deepNavy font-medium">+ Add</button></div>
            <div className="space-y-2">
              {features.map((f, i) => (
                <div key={i} className="flex items-center gap-2">
                  <input value={f} onChange={(e) => updateFeature(i, e.target.value)} className="input flex-1" placeholder={`Feature ${i + 1}`} />
                  {features.length > 1 && <button type="button" onClick={() => removeFeature(i)} className="p-1 text-slate-400 hover:text-rose-500"><X className="h-4 w-4" /></button>}
                </div>
              ))}
            </div>
          </div>
          <div className="flex justify-end gap-3 pt-2">
            <button type="button" onClick={onClose} className="btn-secondary">Cancel</button>
            <button type="submit" disabled={loading || !name.trim() || !price} className="btn-primary">
              {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <Plus className="h-4 w-4" />}
              {loading ? (isEdit ? "Saving..." : "Creating...") : (isEdit ? "Save Changes" : "Create Plan")}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
