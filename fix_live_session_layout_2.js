const fs = require('fs');
const path = 'C:/Users/ITBDG/Documents/SystemicFitness-Handover/CLEAN/systemic-fitness-web/src/app/(dashboard)/clients/[id]/live-session/page.tsx';
let c = fs.readFileSync(path, 'utf8');

// 1. Extract Navigation Controls
const navRegex = /\{\/\* Navigation Controls \(Compacted\) \*\/\}\s*<div className="bg-white rounded-2xl p-4 md:p-5 shadow-xl border border-slate-100 flex items-center\s*justify-between mt-auto">[\s\S]*?<\/button>\s*<\/div>/;

const navMatch = c.match(navRegex);
if (navMatch) {
    const navStr = navMatch[0];
    
    // Remove from old position
    c = c.replace(navRegex, '');
    
    // Insert it before BPM player
    const bpmPlayerSearch = '{/* 🎵 BPM Metronome Player Box 🎵 */}';
    if (c.includes(bpmPlayerSearch)) {
        c = c.replace(bpmPlayerSearch, navStr + '\n\n            ' + bpmPlayerSearch);
    }
} else {
    console.log("Could not find Navigation Controls block!");
}

// 2. Tidy up Equipment Box
// Let's change divide-x to divide-y so Upper and Lower stack vertically to give more horizontal room.
// And style the Upper / Lower / SET/REPS labels to look like little badges.
const equipmentSearch = `{/* EQUIPMENT */}
                <div className="bg-slate-800/60 rounded-xl border border-slate-700/50 backdrop-blur-sm transition-colors hover:bg-slate-800 flex flex-col overflow-hidden">
                  <div className="p-2 border-b border-slate-700/50 text-center bg-slate-900/30">
                    <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest">Equipment</p>
                  </div>
                  <div className="flex flex-1 divide-x divide-slate-700/50">
                    <div className="flex-1 p-2 flex flex-col items-center justify-center text-center">
                      <p className="text-[9px] text-slate-500 font-bold uppercase mb-1">Upper</p>
                      <p className="text-xs md:text-sm font-bold text-white leading-tight">
                        {currentItem.equip_upper !== "-" ? currentItem.equip_upper.split(",").map((s:string,idx:number)=><div key={idx}>{s.trim()}</div>) : "-"}
                      </p>
                    </div>
                    <div className="flex-1 p-2 flex flex-col items-center justify-center text-center">
                      <p className="text-[9px] text-slate-500 font-bold uppercase mb-1">Lower</p>
                      <p className="text-xs md:text-sm font-bold text-white leading-tight">
                        {currentItem.equip_lower !== "-" ? currentItem.equip_lower.split(",").map((s:string,idx:number)=><div key={idx}>{s.trim()}</div>) : "-"}
                      </p>
                    </div>
                  </div>
                </div>`;

const equipmentReplace = `{/* EQUIPMENT */}
                <div className="bg-slate-800/60 rounded-xl border border-slate-700/50 backdrop-blur-sm transition-colors hover:bg-slate-800 flex flex-col overflow-hidden">
                  <div className="p-2 border-b border-slate-700/50 text-center bg-slate-900/30">
                    <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest">Equipment</p>
                  </div>
                  <div className="flex flex-col flex-1 divide-y divide-slate-700/50">
                    <div className="flex-1 p-2 flex flex-col items-center justify-center text-center">
                      <span className="bg-sf-deepNavy/80 text-sf-warmGold text-[9px] font-bold uppercase px-2 py-0.5 rounded border border-sf-warmGold/20 mb-1.5">Upper</span>
                      <div className="text-[11px] font-bold text-white leading-tight break-words">
                        {currentItem.equip_upper !== "-" ? currentItem.equip_upper.split(",").map((s:string,idx:number)=><div key={idx} className="mb-0.5">{s.trim()}</div>) : "-"}
                      </div>
                    </div>
                    <div className="flex-1 p-2 flex flex-col items-center justify-center text-center">
                      <span className="bg-sf-deepNavy/80 text-sf-warmGold text-[9px] font-bold uppercase px-2 py-0.5 rounded border border-sf-warmGold/20 mb-1.5">Lower</span>
                      <div className="text-[11px] font-bold text-white leading-tight break-words">
                        {currentItem.equip_lower !== "-" ? currentItem.equip_lower.split(",").map((s:string,idx:number)=><div key={idx} className="mb-0.5">{s.trim()}</div>) : "-"}
                      </div>
                    </div>
                  </div>
                </div>`;

if (c.includes(equipmentSearch)) {
    c = c.replace(equipmentSearch, equipmentReplace);
}

// 3. Tidy up SET/REPS Box
const setRepsSearch = `{/* SET / REPS */}
                <div className="bg-slate-800/60 p-4 rounded-xl border border-slate-700/50 backdrop-blur-sm transition-colors hover:bg-slate-800 flex flex-col items-center justify-center text-center">
                  <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest mb-1">Set/Reps</p>
                  <p className="text-xl md:text-2xl font-extrabold text-white">
                    {currentItem.sets} <span className="text-slate-500 font-normal mx-1 text-lg">x</span> {currentItem.reps}
                  </p>
                </div>`;

const setRepsReplace = `{/* SET / REPS */}
                <div className="bg-slate-800/60 p-4 rounded-xl border border-slate-700/50 backdrop-blur-sm transition-colors hover:bg-slate-800 flex flex-col items-center justify-center text-center">
                  <span className="bg-sf-deepNavy/80 text-sf-warmGold text-[10px] font-bold uppercase px-3 py-1 rounded border border-sf-warmGold/20 mb-2 tracking-widest">Set/Reps</span>
                  <p className="text-2xl md:text-3xl font-extrabold text-white">
                    {currentItem.sets} <span className="text-slate-500 font-normal mx-1 text-xl">x</span> {currentItem.reps}
                  </p>
                </div>`;

if (c.includes(setRepsSearch)) {
    c = c.replace(setRepsSearch, setRepsReplace);
}

fs.writeFileSync(path, c, 'utf8');
console.log('Fixed Live Session layouts');
