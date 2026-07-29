"use client";

import React from "react";
import { UsersRound, Settings2, MapPin, Dumbbell } from "lucide-react";

export default function OnSitePTPage() {
  return (
    <div className="p-6 max-w-[1600px] mx-auto space-y-6">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <div className="flex items-center gap-2 text-sm text-slate-500 mb-2">
            <UsersRound className="h-4 w-4" />
            <span>Consultant / My Clients / On-site / Personal Training</span>
          </div>
          <h1 className="text-2xl font-bold text-slate-900 flex items-center gap-2">
            <MapPin className="h-6 w-6 text-sf-deepNavy" />
            <Dumbbell className="h-5 w-5 text-sf-deepNavy" />
            On-site - Personal Training
          </h1>
          <p className="text-slate-500 text-sm mt-1">Manage your on-site personal training clients here.</p>
        </div>
        
        <div className="flex items-center gap-3">
          <button className="btn-secondary">
            <Settings2 className="w-4 h-4 mr-2" />
            Filter
          </button>
        </div>
      </div>
      
      <div className="card p-12 flex flex-col items-center justify-center text-center space-y-4 min-h-[400px]">
        <div className="h-16 w-16 bg-slate-100 text-slate-400 rounded-full flex items-center justify-center">
          <UsersRound className="h-8 w-8" />
        </div>
        <div>
          <h3 className="text-lg font-medium text-slate-900">No data available yet</h3>
          <p className="text-sm text-slate-500 mt-1 max-w-sm">This section is currently under construction. Client data will appear here once the integration is complete.</p>
        </div>
      </div>
    </div>
  );
}
