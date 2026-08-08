const fs = require('fs');
const path = 'C:/Users/ITBDG/Documents/SystemicFitness-Handover/CLEAN/systemic-fitness-web/src/app/(dashboard)/clients/[id]/training-card/page.tsx';
let c = fs.readFileSync(path, 'utf8');

// Replace SetBlock Breathing
const setBlockRegex = /<div className="text-sm font-medium text-slate-800">\s*\{set\.breathing_core \? set\.breathing_core\.split\(\',\’\)\.map\(\(s: string\) => s\.trim\(\)\)\.join\(\', \'\) : "-"\}\s*<\/div>/g;

const setBlockReplace = `<div className="text-sm font-medium text-slate-800">
                  {set.breathing_core ? (
                    <ul className="list-disc ml-4 space-y-0.5">
                      {set.breathing_core.split(',').map((s: string, idx: number) => <li key={idx}>{s.trim()}</li>)}
                    </ul>
                  ) : "-"}
                </div>`;

c = c.replace(/<div className="text-sm font-medium text-slate-800">\s*\{set\.breathing_core \? set\.breathing_core\.split\(\',\s*\'\)\.map\(\(s: string\) => s\.trim\(\)\)\.join\(\',\s*\'\)\s*:\s*\"-\"\}\s*<\/div>/g, setBlockReplace);
// Because regex might fail due to quotes, let's just do a normal string replace or precise regex
c = c.replace(/\{set\.breathing_core \? set\.breathing_core\.split\(\',\s*\'\)\.map\(\(s:\s*string\)\s*=>\s*s\.trim\(\)\)\.join\(\',\s*\'\)\s*:\s*"-"\}/g, `{set.breathing_core ? (
                    <ul className="list-disc ml-4 space-y-0.5 text-slate-600">
                      {set.breathing_core.split(',').map((s: string, idx: number) => <li key={idx}>{s.trim()}</li>)}
                    </ul>
                  ) : "-"}`);


c = c.replace(/\{item\.breathing_core \? item\.breathing_core\.split\(\',\s*\'\)\.map\(\(s:\s*string\)\s*=>\s*s\.trim\(\)\)\.join\(\',\s*\'\)\s*:\s*"-"\}/g, `{item.breathing_core ? (
                    <ul className="list-disc ml-4 space-y-0.5 text-slate-600 text-left">
                      {item.breathing_core.split(',').map((s: string, idx: number) => <li key={idx}>{s.trim()}</li>)}
                    </ul>
                  ) : "-"}`);

fs.writeFileSync(path, c, 'utf8');
console.log('Fixed Breathing view mode to bullet points');
