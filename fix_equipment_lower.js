const fs = require('fs');
const path = 'C:/Users/ITBDG/Documents/SystemicFitness-Handover/CLEAN/systemic-fitness-web/src/app/(dashboard)/clients/[id]/training-card/page.tsx';
let c = fs.readFileSync(path, 'utf8');

const s = `              ) : (
                <div className="text-sm space-y-1 mt-1">
                  <div><span className="font-semibold text-slate-600">{set.equipment_lower || "-"}</span></div>
                  <div className="text-[10px] text-slate-400">
                    Acuan: {recommendedLower || "-"}
                  </div>
                </div>
              )}`;

const r = `              ) : (
                <div className="text-sm space-y-1 mt-1">
                  {set.equipment_lower ? (
                    <ul className="list-disc ml-4 text-slate-600 font-semibold space-y-0.5">
                      {set.equipment_lower.split(",").map((eq, idx) => (
                        <li key={idx}>{eq.trim()}</li>
                      ))}
                    </ul>
                  ) : (
                    <div><span className="font-semibold text-slate-600">-</span></div>
                  )}
                  <div className="text-[10px] text-slate-400">
                    Acuan: {recommendedLower || "-"}
                  </div>
                </div>
              )}`;

if (c.includes(s)) {
    fs.writeFileSync(path, c.replace(s, r), 'utf8');
    console.log('Replaced');
} else {
    // try to find it by ignoring whitespace differences
    const sRegex = /<div className="text-sm space-y-1 mt-1">\s*<div><span className="font-semibold text-slate-600">\{set\.equipment_lower \|\| "-"\}<\/span><\/div>\s*<div className="text-\[10px\] text-slate-400">\s*Acuan: \{recommendedLower \|\| "-"\}\s*<\/div>\s*<\/div>/;
    
    if (sRegex.test(c)) {
        const replacement = `<div className="text-sm space-y-1 mt-1">
                  {set.equipment_lower ? (
                    <ul className="list-disc ml-4 text-slate-600 font-semibold space-y-0.5">
                      {set.equipment_lower.split(",").map((eq, idx) => (
                        <li key={idx}>{eq.trim()}</li>
                      ))}
                    </ul>
                  ) : (
                    <div><span className="font-semibold text-slate-600">-</span></div>
                  )}
                  <div className="text-[10px] text-slate-400">
                    Acuan: {recommendedLower || "-"}
                  </div>
                </div>`;
        fs.writeFileSync(path, c.replace(sRegex, replacement), 'utf8');
        console.log('Replaced with Regex');
    } else {
        console.log('Not found');
    }
}
