"use client";

import { EmptyState } from "@/components/shared/EmptyState";
import {
  ClipboardList, Plus, FileText, MoreHorizontal, Eye, Copy, ExternalLink,
} from "lucide-react";

const SAMPLE_FORMS = [
  { id: 1, name: "New Client Intake Form", responses: 48, status: "active", lastResponse: "2 hours ago", fields: 12 },
  { id: 2, name: "Weekly Check-in", responses: 156, status: "active", lastResponse: "30 min ago", fields: 8 },
  { id: 3, name: "Nutrition Assessment", responses: 34, status: "active", lastResponse: "1 day ago", fields: 15 },
  { id: 4, name: "Goal Setting Questionnaire", responses: 22, status: "draft", lastResponse: "3 days ago", fields: 10 },
  { id: 5, name: "Progress Evaluation", responses: 67, status: "active", lastResponse: "5 hours ago", fields: 6 },
  { id: 6, name: "Injury History Form", responses: 19, status: "archived", lastResponse: "2 weeks ago", fields: 14 },
];

const statusStyles: Record<string, string> = {
  active: "bg-emerald-50 text-emerald-700",
  draft: "bg-amber-50 text-amber-700",
  archived: "bg-slate-100 text-slate-500",
};

export default function FormsPage() {
  const showEmpty = false;

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Forms</h1>
          <p className="text-sm text-slate-500 mt-1">
            Create and manage intake forms, check-ins, and questionnaires
          </p>
        </div>
        <button className="btn-primary">
          <Plus className="h-4 w-4" /> Create Form
        </button>
      </div>

      {showEmpty ? (
        <EmptyState
          icon={ClipboardList}
          title="No forms yet"
          description="Create forms to collect information from your clients during onboarding or check-ins."
          action={
            <button className="btn-primary">
              <Plus className="h-4 w-4" /> Create Form
            </button>
          }
        />
      ) : (
        <div className="card divide-y divide-slate-50 overflow-hidden">
          {SAMPLE_FORMS.map((form) => (
            <div
              key={form.id}
              className="px-5 py-4 flex items-center gap-4 hover:bg-slate-50/60 cursor-pointer transition-colors"
            >
              <div className="h-10 w-10 rounded-xl bg-indigo-50 flex items-center justify-center shrink-0">
                <FileText className="h-5 w-5 text-indigo-500" />
              </div>

              <div className="flex-1 min-w-0">
                <p className="font-medium text-slate-900 text-sm">{form.name}</p>
                <p className="text-xs text-slate-400">
                  {form.fields} fields · {form.responses} responses · Last: {form.lastResponse}
                </p>
              </div>

              <span className={`px-2.5 py-1 rounded-full text-xs font-medium capitalize ${statusStyles[form.status]}`}>
                {form.status}
              </span>

              <div className="flex items-center gap-1">
                <button className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400 transition-colors" title="Preview">
                  <Eye className="h-4 w-4" />
                </button>
                <button className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400 transition-colors" title="Copy link">
                  <Copy className="h-4 w-4" />
                </button>
                <button className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400 transition-colors" title="Open">
                  <ExternalLink className="h-4 w-4" />
                </button>
                <button className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400 transition-colors">
                  <MoreHorizontal className="h-4 w-4" />
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
