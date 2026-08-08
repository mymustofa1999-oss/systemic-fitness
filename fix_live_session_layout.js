const fs = require('fs');
const path = 'C:/Users/ITBDG/Documents/SystemicFitness-Handover/CLEAN/systemic-fitness-web/src/app/(dashboard)/clients/[id]/live-session/page.tsx';
let c = fs.readFileSync(path, 'utf8');

// 1. Add sequenceNames to the component, near the playlist definition
if (!c.includes('const sequenceNames = useMemo')) {
    const sequenceNamesStr = `
  const sequenceNames = useMemo(() => {
    const data = cardData?.data as any;
    if (!data?.sequences) return [];
    return data.sequences.map((seq: any) => seq.program_category_name || seq.name || "Bagian");
  }, [cardData]);
  
  const playlist = useMemo`;
    c = c.replace('const playlist = useMemo', sequenceNamesStr);
}

// 2. Add equip_upper and equip_lower to playlist items
const itemsPushSearch = `              breathing_diaphragm: set.breathing_diaphragm || "-",
              seqIndex: sIdx,`;
const itemsPushReplace = `              breathing_diaphragm: set.breathing_diaphragm || "-",
              equip_upper: set.equipment_upper || "-",
              equip_lower: set.equipment_lower || "-",
              seqIndex: sIdx,`;
c = c.replace(itemsPushSearch, itemsPushReplace);

// 3. Move Navigation Controls (Compacted) to immediately after Video Player
const videoPlayerEndSearch = `                  <p className="font-medium text-lg">Video tidak tersedia</p>
                </div>
              )}
            </div>`;

// Check if we can extract Navigation Controls block
const navControlsStartIdx = c.indexOf('{/* Navigation Controls (Compacted) */}');
if (navControlsStartIdx !== -1) {
    const navControlsRegex = /\{\/\* Navigation Controls \(Compacted\) \*\/\}\s*<div className="bg-white rounded-2xl p-4 md:p-5 shadow-xl border border-slate-100 flex items-center justify-between mt-auto">[\s\S]*?<\/div>\s*<\/div>/;
    
    const match = c.match(navControlsRegex);
    if (match) {
        // Extract it
        let navStr = match[0];
        // Note: the regex captures an extra </div> at the end, let's be careful
        // The nav controls ends with:
        //               </button>
        //             </div>
        
        const navRegexBetter = /\{\/\* Navigation Controls \(Compacted\) \*\/\}\s*<div className="bg-white rounded-2xl p-4 md:p-5 shadow-xl border border-slate-100 flex items-center justify-between mt-auto">[\s\S]*?<\/button>\s*<\/div>/;
        
        const betterMatch = c.match(navRegexBetter);
        if (betterMatch) {
            navStr = betterMatch[0];
            // Remove it from its original place
            c = c.replace(navStr, '');
            
            // Insert it after video player
            c = c.replace(videoPlayerEndSearch, videoPlayerEndSearch + '\n\n            ' + navStr);
        }
    }
}

// 4. Replace Parameter Latihan
const paramLatihanRegex = /\{\/\* Parameter Latihan \(Wide Layout\) \*\/\}\s*<div className="bg-sf-deepNavy rounded-2xl p-5 md:p-6 shadow-xl ring-1 ring-slate-900\/10 shrink-0">[\s\S]*?BPM Zone<\/p>\s*<p className="text-lg font-bold text-white leading-tight">\{currentItem\.bpm\}<\/p>\s*<\/div>\s*<\/div>\s*<\/div>/;

const newParamLatihan = `{/* Parameter Latihan (Wireframe Layout) */}
            <div className="bg-sf-deepNavy rounded-2xl p-5 md:p-6 shadow-xl ring-1 ring-slate-900/10 shrink-0">
              <h3 className="text-white font-extrabold text-lg mb-4 flex items-center gap-2">
                <Activity className="h-5 w-5 text-sf-warmGold" /> Parameter Latihan
              </h3>
              
              <div className="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-4">
                
                {/* SEQUENCE */}
                <div className="bg-slate-800/60 rounded-xl border border-slate-700/50 backdrop-blur-sm transition-colors hover:bg-slate-800 flex flex-col p-3 row-span-2">
                  <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest mb-3 text-center">Sequence</p>
                  <div className="flex flex-col gap-1.5 flex-1 justify-center">
                    {sequenceNames.map((name: string, i: number) => {
                      const isActive = i === currentItem.seqIndex;
                      return (
                        <div key={i} className={\`text-xs font-semibold py-2 px-2.5 rounded text-center transition-all \${isActive ? "bg-sf-warmGold/20 text-sf-warmGold animate-pulse border border-sf-warmGold/50 shadow-sm" : "text-slate-400 bg-slate-900/40"}\`}>
                          {name}
                        </div>
                      )
                    })}
                  </div>
                </div>

                {/* DURATION */}
                <div className="bg-slate-800/60 rounded-xl border border-slate-700/50 backdrop-blur-sm transition-colors hover:bg-slate-800 flex flex-col p-3 row-span-2">
                  <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest mb-1 text-center">Duration</p>
                  <div className="flex-1 flex items-center justify-center">
                    <p className="text-xl md:text-2xl font-bold text-sf-warmGold">{currentItem.duration}</p>
                  </div>
                </div>

                {/* EQUIPMENT */}
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
                </div>

                {/* SET / REPS */}
                <div className="bg-slate-800/60 p-4 rounded-xl border border-slate-700/50 backdrop-blur-sm transition-colors hover:bg-slate-800 flex flex-col items-center justify-center text-center">
                  <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest mb-1">Set/Reps</p>
                  <p className="text-xl md:text-2xl font-extrabold text-white">
                    {currentItem.sets} <span className="text-slate-500 font-normal mx-1 text-lg">x</span> {currentItem.reps}
                  </p>
                </div>

                {/* MAX HR (BPM Zone) */}
                <div className="bg-slate-800/60 p-3 rounded-xl border border-slate-700/50 backdrop-blur-sm transition-colors hover:bg-slate-800 flex flex-col items-center justify-center text-center">
                  <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest mb-1">Max HR / BPM</p>
                  <p className="text-lg md:text-xl font-bold text-white leading-tight">{currentItem.bpm}</p>
                </div>

                {/* BREATHING */}
                <div className="bg-slate-800/60 p-3 rounded-xl border border-slate-700/50 backdrop-blur-sm transition-colors hover:bg-slate-800 flex flex-col items-center justify-center text-center">
                  <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest mb-1">Breathing</p>
                  <div className="text-xs md:text-sm font-bold text-slate-200 capitalize leading-relaxed">
                    {currentItem.breathing_core && currentItem.breathing_core !== "-" && (
                      <div className="mb-1"><span className="text-slate-500 block text-[9px] uppercase">Core</span> {currentItem.breathing_core.split(',').join(', ')}</div>
                    )}
                    {currentItem.breathing_diaphragm && currentItem.breathing_diaphragm !== "-" && (
                      <div><span className="text-slate-500 block text-[9px] uppercase">Diaphragm</span> {currentItem.breathing_diaphragm.split(',').join(', ')}</div>
                    )}
                    {(!currentItem.breathing_core || currentItem.breathing_core === "-") && (!currentItem.breathing_diaphragm || currentItem.breathing_diaphragm === "-") && "-"}
                  </div>
                </div>

              </div>
            </div>`;

const paramMatch = c.match(paramLatihanRegex);
if (paramMatch) {
    c = c.replace(paramLatihanRegex, newParamLatihan);
} else {
    console.log("Param Latihan block not found by regex!");
}

fs.writeFileSync(path, c, 'utf8');
console.log('Fixed live session layout');
