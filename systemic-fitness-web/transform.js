const fs = require('fs');
const path = require('path');
const file = path.resolve('src/app/(dashboard)/clients/[id]/systemic-assessment/page.tsx');
let content = fs.readFileSync(file, 'utf8');

// 1. Swap the sections
const historyRegex = /      \{\/\* Historical Data Table \*\/\}[\s\S]*?      <\/div>\n/;
const inputFormRegex = /      \{\/\* Input Form Section \(Vertical Layout\) \*\/\}[\s\S]*?      <\/div>\n/;

const historyMatch = content.match(historyRegex);
const inputFormMatch = content.match(inputFormRegex);

if (historyMatch && inputFormMatch) {
    content = content.replace(historyMatch[0], '');
    content = content.replace(inputFormMatch[0], inputFormMatch[0] + '\n' + historyMatch[0]);
}

// 2. Refactor Functional Met and Movement Met to render vertically and clearly
const functionalMetRegex = /<label className="flex items-start gap-3 p-3 bg-white border border-slate-200 rounded-lg cursor-pointer hover:border-green-400 transition-colors">[\s\S]*?<\/label>/;

const newFunctionalMet = `<div className="flex flex-col p-4 bg-white border border-slate-200 rounded-xl shadow-sm hover:border-green-400 transition-colors h-full">
                  <label className="flex items-center gap-3 cursor-pointer mb-3">
                    <input type="checkbox" checked={functionalMet} onChange={e => setFunctionalMet(e.target.checked)} className="w-5 h-5 rounded border-slate-300 text-green-600 focus:ring-green-600 cursor-pointer" />
                    <span className="text-sm font-bold text-slate-800 tracking-wide uppercase">Functional Met</span>
                  </label>
                  <ul className="space-y-2 text-xs text-slate-600 ml-1">
                    {(EXIT_CRITERIA[currentLevel as keyof typeof EXIT_CRITERIA]?.functional || "").split('\\n').map((point, idx) => (
                      <li key={idx} className="flex items-start gap-2">
                        <span className="text-slate-400 mt-0.5">•</span>
                        <span className="leading-relaxed">{point.replace(/^•\\s*/, '')}</span>
                      </li>
                    ))}
                  </ul>
                </div>`;

const movementMetRegex = /<label className="flex items-start gap-3 p-3 bg-white border border-slate-200 rounded-lg cursor-pointer hover:border-green-400 transition-colors">[\s\S]*?<\/label>/;

const newMovementMet = `<div className="flex flex-col p-4 bg-white border border-slate-200 rounded-xl shadow-sm hover:border-green-400 transition-colors h-full">
                  <label className="flex items-center gap-3 cursor-pointer mb-3">
                    <input type="checkbox" checked={movementMet} onChange={e => setMovementMet(e.target.checked)} className="w-5 h-5 rounded border-slate-300 text-green-600 focus:ring-green-600 cursor-pointer" />
                    <span className="text-sm font-bold text-slate-800 tracking-wide uppercase">Movement Quality Met</span>
                  </label>
                  <ul className="space-y-2 text-xs text-slate-600 ml-1">
                    {(EXIT_CRITERIA[currentLevel as keyof typeof EXIT_CRITERIA]?.movement || "").split('\\n').map((point, idx) => (
                      <li key={idx} className="flex items-start gap-2">
                        <span className="text-slate-400 mt-0.5">•</span>
                        <span className="leading-relaxed">{point.replace(/^•\\s*/, '')}</span>
                      </li>
                    ))}
                  </ul>
                </div>`;

content = content.replace(functionalMetRegex, newFunctionalMet);
content = content.replace(movementMetRegex, newMovementMet);

// 3. Fix the Historical Data Table rendering
const functionalTableRegex = /<td className="px-4 py-3 border-r border-slate-200 text-\[11px\] whitespace-pre-wrap text-slate-500 leading-tight">\s*\{EXIT_CRITERIA\[a.current_level as keyof typeof EXIT_CRITERIA\]\?.functional \|\| ""\}\s*<\/td>/;
const newFunctionalTable = `<td className="px-4 py-3 border-r border-slate-200 text-[11px] text-slate-500 align-top">
                      <ul className="space-y-1">
                        {(EXIT_CRITERIA[a.current_level as keyof typeof EXIT_CRITERIA]?.functional || "").split('\\n').map((pt, i) => (
                          <li key={i} className="flex items-start gap-1.5"><span className="text-slate-300">•</span> <span className="leading-tight">{pt.replace(/^•\\s*/, '')}</span></li>
                        ))}
                      </ul>
                    </td>`;

const movementTableRegex = /<td className="px-4 py-3 border-r border-slate-300 text-\[11px\] whitespace-pre-wrap text-slate-500 leading-tight">\s*\{EXIT_CRITERIA\[a.current_level as keyof typeof EXIT_CRITERIA\]\?.movement \|\| ""\}\s*<\/td>/;
const newMovementTable = `<td className="px-4 py-3 border-r border-slate-300 text-[11px] text-slate-500 align-top">
                      <ul className="space-y-1">
                        {(EXIT_CRITERIA[a.current_level as keyof typeof EXIT_CRITERIA]?.movement || "").split('\\n').map((pt, i) => (
                          <li key={i} className="flex items-start gap-1.5"><span className="text-slate-300">•</span> <span className="leading-tight">{pt.replace(/^•\\s*/, '')}</span></li>
                        ))}
                      </ul>
                    </td>`;

content = content.replace(functionalTableRegex, newFunctionalTable);
content = content.replace(movementTableRegex, newMovementTable);

// 4. Update Grid layout
content = content.replace(/<div className="lg:col-span-3 space-y-3">/g, '<div className="lg:col-span-4">');

const avgScoreRegex = /<div className="lg:col-span-2">\s*<label className="block text-xs font-bold text-slate-700 mb-1">Avg Systemic Score<\/label>[\s\S]*?<\/div>\s*<\/div>\s*<div className="lg:col-span-2 flex flex-col justify-center items-center p-3 bg-white border border-slate-200 rounded-lg">[\s\S]*?<\/div>/;

const newAvgScore = `<div className="lg:col-span-2 space-y-4">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Avg Systemic Score</label>
                  <input type="number" step="0.01" value={avgScore} onChange={e => setAvgScore(e.target.value ? parseFloat(e.target.value) : "")} placeholder="2.50" className="w-full p-2.5 text-center font-bold bg-white border border-slate-200 rounded-lg focus:ring-2 focus:ring-amber-400" required />
                  <div className="mt-2 text-center">
                    {avgScore !== "" ? (
                      scoreMet ? <span className="text-xs font-bold text-green-600 bg-green-50 px-2 py-1 rounded">✔ Score Passed</span> : <span className="text-xs font-bold text-red-500 bg-red-50 px-2 py-1 rounded">✖ Needs {scoreThreshold}</span>
                    ) : null}
                  </div>
                </div>

                <div className="flex flex-col justify-center items-center p-3 bg-white border border-slate-200 rounded-lg shadow-sm h-full max-h-[80px]">
                  <span className="text-xs text-slate-500 font-medium mb-1">Calculated Outcome</span>
                  <div className="flex items-center gap-2">
                    <span className={cn("px-3 py-1 rounded-md font-bold text-sm", decision === "PROGRESS" ? "text-green-700 bg-green-100" : "text-amber-700 bg-amber-100")}>{decision}</span>
                    <span className="text-xs text-slate-500">New Level: <strong className="text-sf-deepNavy">{newLevel}</strong></span>
                  </div>
                </div>
              </div>`;
content = content.replace(avgScoreRegex, newAvgScore);

content = content.replace(/<div className="bg-white rounded-2xl shadow-md border border-slate-200 overflow-hidden mt-8">/, '<div className="bg-white rounded-2xl shadow-md border border-slate-200 overflow-hidden">');
content = content.replace(/<div className="bg-white rounded-2xl shadow-md border border-slate-200 overflow-hidden">/, '<div className="bg-white rounded-2xl shadow-md border border-slate-200 overflow-hidden mt-8">'); 

fs.writeFileSync(file, content, 'utf8');
console.log('Transform complete.');
