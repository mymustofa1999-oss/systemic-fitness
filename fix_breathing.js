const fs = require('fs');
const path = 'C:/Users/ITBDG/Documents/SystemicFitness-Handover/CLEAN/systemic-fitness-web/src/app/(dashboard)/clients/[id]/training-card/page.tsx';
let c = fs.readFileSync(path, 'utf8');

// Replace SetBlock Breathing
const setBlockSearch = `{editing ? (
                <select
                  value={set.breathing_core || ""}
                  onChange={(e) => onUpdateSet({ breathing_core: e.target.value })}
                  className="w-full text-sm border border-slate-200 rounded-md px-2 py-1.5 focus:outline-none focus:border-sf-deepNavy bg-white"
                >
                  <option value="">Pilih...</option>
                  <option value="Core">Core</option>
                  <option value="Diafragma">Diafragma</option>
                </select>
              ) : (
                <div className="text-sm font-medium text-slate-800">
                  {set.breathing_core || "-"}
                </div>
              )}`;

const setBlockReplace = `{editing ? (
                <MultiSearchableSelect
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
                </div>
              )}`;

// Replace SortableItemRow Breathing
const itemRowSearch = `{editing ? (
                <select
                  value={item.breathing_core || ""}
                  onChange={(e) => onUpdateItem(ii, { breathing_core: e.target.value })}
                  className="text-[10px] w-full border border-slate-200 rounded px-1.5 py-1 focus:outline-none bg-white"
                >
                  <option value="">Pilih...</option>
                  <option value="Core">Core</option>
                  <option value="Diafragma">Diafragma</option>
                </select>
              ) : (
                <div className="font-medium text-sm text-center">
                  {item.breathing_core || "-"}
                </div>
              )}`;

const itemRowReplace = `{editing ? (
                <MultiSearchableSelect
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
                </div>
              )}`;

if (c.includes(setBlockSearch)) {
    c = c.replace(setBlockSearch, setBlockReplace);
} else {
    console.log("Could not find SetBlock Breathing");
}

if (c.includes(itemRowSearch)) {
    c = c.replace(itemRowSearch, itemRowReplace);
} else {
    console.log("Could not find SortableItemRow Breathing");
}

fs.writeFileSync(path, c, 'utf8');
console.log('Fixed Breathing selects');
