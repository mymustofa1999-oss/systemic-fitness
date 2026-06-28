"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import { apiGet } from "@/lib/api";
import { PieChart, Pie, Cell, ResponsiveContainer } from "recharts";
import { EmptyState } from "@/components/shared/EmptyState";
import { Apple, Plus, Flame } from "lucide-react";
import { formatDate } from "@/lib/utils";

const MACRO_COLORS = ["#4F46E5", "#10B981", "#F59E0B"]; // protein, carbs, fat

export default function NutritionPage() {
  const router = useRouter();
  const [page, setPage] = useState(1);

  const { data, isLoading } = useQuery({
    queryKey: ["meal-plans", page],
    queryFn: () => apiGet("/api/nutrition/meal-plans", { page, limit: 20 }),
  });
  const plans = (data?.data ?? []) as any[];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Nutrition</h1>
          <p className="text-sm text-slate-500 mt-1">Meal plans and macro tracking</p>
        </div>
        <button onClick={() => router.push("/nutrition/create")} className="btn-primary">
          <Plus className="h-4 w-4" /> Create Meal Plan
        </button>
      </div>

      {isLoading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {Array.from({ length: 3 }).map((_, i) => <div key={i} className="skeleton h-48 rounded-xl" />)}
        </div>
      ) : plans.length === 0 ? (
        <EmptyState
          icon={Apple}
          title="No meal plans"
          description="Create your first meal plan to help clients track nutrition."
          action={<button onClick={() => router.push("/nutrition/create")} className="btn-primary"><Plus className="h-4 w-4" /> Create Meal Plan</button>}
        />
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {plans.map((plan: any) => {
            const macros = [
              { name: "Protein", value: plan.protein_g ?? 0 },
              { name: "Carbs", value: plan.carbs_g ?? 0 },
              { name: "Fat", value: plan.fat_g ?? 0 },
            ];
            const hasData = macros.some((m) => m.value > 0);

            return (
              <div key={plan.id} className="card p-5 flex flex-col">
                <div className="flex items-start justify-between mb-3">
                  <div>
                    <h3 className="font-semibold text-slate-900">{plan.name}</h3>
                    {plan.description && <p className="text-xs text-slate-400 mt-0.5 line-clamp-2">{plan.description}</p>}
                  </div>
                  {plan.daily_calories && (
                    <div className="flex items-center gap-1 px-2 py-1 rounded-lg bg-amber-50 shrink-0">
                      <Flame className="h-3 w-3 text-amber-600" />
                      <span className="text-xs font-bold text-amber-700">{plan.daily_calories}</span>
                      <span className="text-[10px] text-amber-500">kcal</span>
                    </div>
                  )}
                </div>

                {/* Macro donut */}
                <div className="flex items-center gap-4 flex-1">
                  {hasData ? (
                    <div className="w-20 h-20 shrink-0">
                      <ResponsiveContainer width="100%" height="100%">
                        <PieChart>
                          <Pie data={macros} dataKey="value" cx="50%" cy="50%" innerRadius={22} outerRadius={36} strokeWidth={0}>
                            {macros.map((_, i) => <Cell key={i} fill={MACRO_COLORS[i]} />)}
                          </Pie>
                        </PieChart>
                      </ResponsiveContainer>
                    </div>
                  ) : (
                    <div className="w-20 h-20 rounded-full bg-slate-50 flex items-center justify-center shrink-0">
                      <Apple className="h-6 w-6 text-slate-200" />
                    </div>
                  )}
                  <div className="space-y-1.5 flex-1">
                    {macros.map((m, i) => (
                      <div key={m.name} className="flex items-center justify-between">
                        <span className="flex items-center gap-1.5 text-xs text-slate-500">
                          <span className="w-2 h-2 rounded-full" style={{ backgroundColor: MACRO_COLORS[i] }} />
                          {m.name}
                        </span>
                        <span className="text-xs font-mono font-medium text-slate-700">{m.value}g</span>
                      </div>
                    ))}
                  </div>
                </div>

                <p className="text-[10px] text-slate-400 mt-3 pt-3 border-t border-slate-50">
                  Created {formatDate(plan.created_at)}
                </p>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
