import React from "react";

interface HRZoneTableProps {
  hrZones: { label: string; key: string; value: string | number }[];
  editingHR?: boolean;
  hrForm?: any;
  setHrForm?: any;
  handleSaveHR?: () => void;
  isPending?: boolean;
  setEditingHR?: (v: boolean) => void;
}

export function HRZoneTable({
  hrZones,
  editingHR = false,
  hrForm,
  setHrForm,
  handleSaveHR,
  isPending = false,
  setEditingHR
}: HRZoneTableProps) {
  return (
    <div className="overflow-x-auto w-full rounded-xl shadow-sm border border-slate-200 bg-white">
      <table className="w-full border-collapse text-xs text-slate-700">
        <tbody>
          {/* Max HR */}
          <tr className="border-b border-slate-200">
            <td rowSpan={6} className="border-r border-slate-200 font-bold p-2.5 px-2 text-center align-middle text-slate-600 bg-slate-50/50 w-1/4">
              <div className="flex flex-col items-center justify-center gap-2">
                <span>HR Zone</span>
                {setEditingHR && (
                  !editingHR ? (
                    <button onClick={() => setEditingHR(true)} className="text-[10px] text-sf-deepNavy font-medium hover:underline bg-white px-2 py-0.5 rounded shadow-sm border border-slate-200">Edit</button>
                  ) : (
                    <div className="flex flex-col gap-1 w-full mt-1">
                      <button onClick={handleSaveHR} disabled={isPending} className="text-[10px] bg-sf-deepNavy text-white px-1 py-1 rounded shadow-sm flex items-center justify-center">
                        {isPending ? "..." : "Simpan"}
                      </button>
                      <button onClick={() => setEditingHR(false)} className="text-[10px] bg-white text-slate-600 px-1 py-1 rounded shadow-sm border border-slate-200">Batal</button>
                    </div>
                  )
                )}
              </div>
            </td>
            <td className="border-r border-slate-200 p-2.5 px-4 font-bold bg-rose-100/50 text-rose-800 w-1/4">Max HR</td>
            <td className="border-r border-slate-200 p-2.5 px-4 text-center bg-rose-100/50 font-semibold text-rose-900 w-1/4">
              {editingHR && hrForm && setHrForm ? <input type="number" value={hrForm.max_hr_upper} onChange={e => setHrForm({...hrForm, max_hr_upper: e.target.value})} className="w-14 px-1 py-0.5 text-center rounded border border-slate-300" /> : (hrZones[0].value)}
            </td>
            <td className="p-2.5 px-4 text-center bg-rose-200/40 font-semibold text-rose-900 w-1/4">{hrZones[0].value !== "-" ? Math.round(Number(hrZones[0].value) / 4) : "-"}</td>
          </tr>

          {/* Zona 5 */}
          <tr className="border-b border-slate-200">
            <td className="border-r border-slate-200 p-2.5 px-4 font-bold bg-amber-100/50 text-amber-800">Zona 5</td>
            <td className="border-r border-slate-200 p-2.5 px-4 text-center bg-amber-100/50 font-semibold text-amber-900">
              {editingHR && hrForm && setHrForm ? <input type="number" value={hrForm.zone5_lower} onChange={e => setHrForm({...hrForm, zone5_lower: e.target.value})} className="w-14 px-1 py-0.5 text-center rounded border border-slate-300" /> : (hrZones[1].value)}
            </td>
            <td className="p-2.5 px-4 text-center bg-amber-200/40 font-semibold text-amber-900">{hrZones[1].value !== "-" ? Math.round(Number(hrZones[1].value) / 4) : "-"}</td>
          </tr>

          {/* Zona 4 */}
          <tr className="border-b border-slate-200">
            <td className="border-r border-slate-200 p-2.5 px-4 font-bold bg-fuchsia-100/50 text-fuchsia-800">Zona 4</td>
            <td className="border-r border-slate-200 p-2.5 px-4 text-center bg-fuchsia-100/50 font-semibold text-fuchsia-900">
              {editingHR && hrForm && setHrForm ? <input type="number" value={hrForm.zone4_lower} onChange={e => setHrForm({...hrForm, zone4_lower: e.target.value})} className="w-14 px-1 py-0.5 text-center rounded border border-slate-300" /> : (hrZones[2].value)}
            </td>
            <td className="p-2.5 px-4 text-center bg-fuchsia-200/40 font-semibold text-fuchsia-900">{hrZones[2].value !== "-" ? Math.round(Number(hrZones[2].value) / 4) : "-"}</td>
          </tr>

          {/* Zona 3 */}
          <tr className="border-b border-slate-200">
            <td className="border-r border-slate-200 p-2.5 px-4 font-bold bg-emerald-100/50 text-emerald-800">Zona 3</td>
            <td className="border-r border-slate-200 p-2.5 px-4 text-center bg-emerald-100/50 font-semibold text-emerald-900">
              {editingHR && hrForm && setHrForm ? <input type="number" value={hrForm.zone3_lower} onChange={e => setHrForm({...hrForm, zone3_lower: e.target.value})} className="w-14 px-1 py-0.5 text-center rounded border border-slate-300" /> : (hrZones[3].value)}
            </td>
            <td className="p-2.5 px-4 text-center bg-emerald-200/40 font-semibold text-emerald-900">{hrZones[3].value !== "-" ? Math.round(Number(hrZones[3].value) / 4) : "-"}</td>
          </tr>

          {/* Zona 2 */}
          <tr className="border-b border-slate-200">
            <td className="border-r border-slate-200 p-2.5 px-4 font-bold bg-sky-100/50 text-sky-800">Zona 2</td>
            <td className="border-r border-slate-200 p-2.5 px-4 text-center bg-sky-100/50 font-semibold text-sky-900">
              {editingHR && hrForm && setHrForm ? <input type="number" value={hrForm.zone2_lower} onChange={e => setHrForm({...hrForm, zone2_lower: e.target.value})} className="w-14 px-1 py-0.5 text-center rounded border border-slate-300" /> : (hrZones[4].value)}
            </td>
            <td className="p-2.5 px-4 text-center bg-sky-200/40 font-semibold text-sky-900">{hrZones[4].value !== "-" ? Math.round(Number(hrZones[4].value) / 4) : "-"}</td>
          </tr>

          {/* Zona 1 */}
          <tr>
            <td className="border-r border-slate-200 p-2.5 px-4 font-bold bg-indigo-50/70 text-indigo-800">Zona 1</td>
            <td className="border-r border-slate-200 p-2.5 px-4 text-center bg-indigo-50/70 font-semibold text-indigo-900">
              {editingHR && hrForm && setHrForm ? <input type="number" value={hrForm.zone1_lower} onChange={e => setHrForm({...hrForm, zone1_lower: e.target.value})} className="w-14 px-1 py-0.5 text-center rounded border border-slate-300" /> : (hrZones[5].value)}
            </td>
            <td className="p-2.5 px-4 text-center bg-indigo-100/40 font-semibold text-indigo-900">{hrZones[5].value !== "-" ? Math.round(Number(hrZones[5].value) / 4) : "-"}</td>
          </tr>
        </tbody>
      </table>
    </div>
  );
}
