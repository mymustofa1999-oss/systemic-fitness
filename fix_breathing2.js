const fs = require('fs');
const path = 'C:/Users/ITBDG/Documents/SystemicFitness-Handover/CLEAN/systemic-fitness-web/src/app/(dashboard)/clients/[id]/training-card/page.tsx';
let c = fs.readFileSync(path, 'utf8');

// Replace SetBlock Breathing
const setBlockRegex = /<select\s*value=\{set\.breathing_core \|\| ""\}\s*onChange=\{\(e\) => onUpdateSet\(\{ breathing_core: e\.target\.value \}\)\}\s*className="[^"]*"\s*>\s*<option value="">Pilih\.\.\.<\/option>\s*<option value="Core">Core<\/option>\s*<option value="Diafragma">Diafragma<\/option>\s*<\/select>\s*\) : \(\s*<div className="text-sm font-medium text-slate-800">\s*\{set\.breathing_core \|\| "-"\}\s*<\/div>/g;

const setBlockReplace = `<MultiSearchableSelect
                  options={[
                    { value: "Core", label: "Core" },
                    { value: "Diafragma", label: "Diafragma" }
                  ]}
                  value={set.breathing_core || ""}
                  onChange={(val) => onUpdateSet({ breathing_core: val })}
                  placeholder="Pilih..."
                />
              ) : (
                <div className="text-sm font-medium text-slate-800">
                  {set.breathing_core ? set.breathing_core.split(',').map((s: string) => s.trim()).join(', ') : "-"}
                </div>`;

c = c.replace(setBlockRegex, setBlockReplace);

// Replace SortableItemRow Breathing
const itemRowRegex = /<select\s*value=\{item\.breathing_core \|\| ""\}\s*onChange=\{\(e\) => onUpdateItem\(ii, \{ breathing_core: e\.target\.value \}\)\}\s*className="[^"]*"\s*>\s*<option value="">Pilih\.\.\.<\/option>\s*<option value="Core">Core<\/option>\s*<option value="Diafragma">Diafragma<\/option>\s*<\/select>\s*\) : \(\s*<div className="font-medium text-sm text-center">\s*\{item\.breathing_core \|\| "-"\}\s*<\/div>/g;

const itemRowReplace = `<MultiSearchableSelect
                  options={[
                    { value: "Core", label: "Core" },
                    { value: "Diafragma", label: "Diafragma" }
                  ]}
                  value={item.breathing_core || ""}
                  onChange={(val) => onUpdateItem(ii, { breathing_core: val })}
                  placeholder="Pilih..."
                />
              ) : (
                <div className="font-medium text-sm text-center">
                  {item.breathing_core ? item.breathing_core.split(',').map((s: string) => s.trim()).join(', ') : "-"}
                </div>`;

c = c.replace(itemRowRegex, itemRowReplace);

fs.writeFileSync(path, c, 'utf8');
console.log('Fixed Breathing selects with regex');
