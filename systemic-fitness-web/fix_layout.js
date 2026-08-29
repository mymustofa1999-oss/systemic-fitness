const fs = require('fs');
let content = fs.readFileSync('temp.tsx', 'utf8');

const regex = /\{\/\* SECTION 2: EXIT CHECKLIST \*\/\}[\s\S]*?\{\/\* SECTION 3: BODY COMPOSITION \*\/\}/;

const newSection2 = `{/* SECTION 2: EXIT CHECKLIST */}
          <div>
            <h3 className="text-sm font-bold text-slate-800 uppercase tracking-wider mb-4 border-b border-slate-100 pb-2 flex items-center justify-between">
              Exit Checklist
              <span className="text-xs font-normal text-slate-500 bg-slate-100 px-2 py-1 rounded">Target Score: &gt; {scoreThreshold}</span>
            </h3>
            
            <div className="bg-slate-50 p-5 rounded-xl border border-slate-100 space-y-6">
              
              {/* TOP ROW: Current Level */}
              <div className="flex items-center gap-4 bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
                <label className="text-sm font-bold text-slate-700 uppercase tracking-wider whitespace-nowrap">Current Level</label>
                <select value={currentLevel} onChange={e => setCurrentLevel(Number(e.target.value))} className="w-48 p-2.5 font-bold text-lg text-center bg-white border-2 border-slate-900 rounded-xl focus:ring-2 focus:ring-amber-400 cursor-pointer shadow-sm">
                  {[1,2,3,4,5,6].map(l => <option key={l} value={l}>Level {l}</option>)}
                </select>
              </div>

              {/* BOTTOM ROW: The 3 Columns */}
              <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
                
                {/* Column 1: Functional Met */}
                <div className="lg:col-span-5 flex flex-col p-5 bg-white border border-slate-200 rounded-xl shadow-sm hover:border-green-400 transition-colors h-full">
                  <label className="flex items-center gap-3 cursor-pointer mb-4">
                    <input type="checkbox" checked={functionalMet} onChange={e => setFunctionalMet(e.target.checked)} className="w-5 h-5 rounded border-slate-300 text-green-600 focus:ring-green-600 cursor-pointer" />
                    <span className="text-sm font-bold text-slate-800 tracking-wide uppercase">Functional Met</span>
                  </label>
                  <ul className="space-y-3 text-xs text-slate-600 ml-1">
                    {(EXIT_CRITERIA[currentLevel as keyof typeof EXIT_CRITERIA]?.functional || "").split('\\n').map((point, idx) => (
                      <li key={idx} className="flex items-start gap-2.5">
                        <span className="text-slate-400 mt-0.5 text-[10px]">●</span>
                        <span className="leading-relaxed">{point.replace(/^•\\s*/, '')}</span>
                      </li>
                    ))}
                  </ul>
                </div>

                {/* Column 2: Movement Quality Met */}
                <div className="lg:col-span-5 flex flex-col p-5 bg-white border border-slate-200 rounded-xl shadow-sm hover:border-green-400 transition-colors h-full">
                  <label className="flex items-center gap-3 cursor-pointer mb-4">
                    <input type="checkbox" checked={movementMet} onChange={e => setMovementMet(e.target.checked)} className="w-5 h-5 rounded border-slate-300 text-green-600 focus:ring-green-600 cursor-pointer" />
                    <span className="text-sm font-bold text-slate-800 tracking-wide uppercase">Movement Quality Met</span>
                  </label>
                  <ul className="space-y-3 text-xs text-slate-600 ml-1">
                    {(EXIT_CRITERIA[currentLevel as keyof typeof EXIT_CRITERIA]?.movement || "").split('\\n').map((point, idx) => (
                      <li key={idx} className="flex items-start gap-2.5">
                        <span className="text-slate-400 mt-0.5 text-[10px]">●</span>
                        <span className="leading-relaxed">{point.replace(/^•\\s*/, '')}</span>
                      </li>
                    ))}
                  </ul>
                </div>

                {/* Column 3: Scores */}
                <div className="lg:col-span-2 flex flex-col space-y-6">
                  
                  <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm h-full flex flex-col justify-center">
                    <label className="block text-xs font-bold text-slate-700 mb-2 text-center">Avg Systemic Score</label>
                    <input type="number" step="0.01" value={avgScore} onChange={e => setAvgScore(e.target.value ? parseFloat(e.target.value) : "")} placeholder="2.50" className="w-full p-3 text-center text-lg font-bold bg-slate-50 border border-slate-200 rounded-lg focus:ring-2 focus:ring-amber-400" required />
                    <div className="mt-3 text-center">
                      {avgScore !== "" ? (
                        scoreMet ? <span className="text-xs font-bold text-green-700 bg-green-100 px-3 py-1.5 rounded-full inline-block w-full">✔ Passed</span> : <span className="text-xs font-bold text-red-600 bg-red-50 px-3 py-1.5 rounded-full inline-block w-full">✖ Needs {scoreThreshold}</span>
                      ) : null}
                    </div>
                  </div>

                  <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm h-full flex flex-col items-center justify-center text-center">
                    <span className="text-xs text-slate-500 font-bold mb-2 uppercase tracking-wider">Calculated Outcome</span>
                    <span className={cn("px-4 py-2 rounded-lg font-black text-sm mb-3 w-full", decision === "PROGRESS" ? "text-green-800 bg-[#d9ead3]" : "text-amber-800 bg-[#fce5cd]")}>{decision}</span>
                    <div className="text-xs text-slate-500 bg-slate-50 px-3 py-2 rounded-lg w-full border border-slate-100">
                      New Level: <strong className="text-sf-deepNavy text-sm ml-1">{newLevel}</strong>
                    </div>
                  </div>

                </div>

              </div>
            </div>
          </div>

          {/* SECTION 3: BODY COMPOSITION */}`;

content = content.replace(regex, newSection2);
fs.writeFileSync('temp.tsx', content, 'utf8');
console.log('Fix complete.');
