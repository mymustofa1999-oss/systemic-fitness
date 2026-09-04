const fs = require('fs');
const file = 'systemic-fitness-web/src/app/(dashboard)/clients/[id]/training-card/page.tsx';
let content = fs.readFileSync(file, 'utf8');

// 1. In addCat, ensure cdData is included
content = content.replace(
    'addCat((mcData?.data as any) || [], "MC");\n      return map;\n    }, [fcData, ccData, mcData]);',
    'addCat((mcData?.data as any) || [], "MC");\n      addCat((cdData?.data as any) || [], "CD");\n      return map;\n    }, [fcData, ccData, mcData, cdData]);'
);

// 2. Strict filtering in movementOptions
const strictFilter = "const currentLevel = form?.level ? parseInt(form.level) : parsedMappedLevel;\n" +
"        if (!currentLevel) return true;\n" +
"\n" +
"        // Strict filtering: Only allow movements present in Training Module for this level/gender\n" +
"        if (!menuCategoryMap.has(m.id)) {\n" +
"            return false;\n" +
"        }\n" +
"        return true;";

const oldFilterRegex = /const currentLevel = form\?\.level \? parseInt\(form\.level\) : parsedMappedLevel;[\s\S]*?\/\/ Jika gerakan tidak ada tag level, anggap general dan bisa dipakai di level berapapun\s*return true;/;

content = content.replace(oldFilterRegex, strictFilter.trim());

// 3. Remove bodyPart filter in MovementSelect
const bodyPartFilterRegex = /\/\/ Filter by bodyPart[\s\S]*?\/\/ Pastikan item\.movement_id yang terpilih ada di allOpts meskipun terfilter!/;

content = content.replace(bodyPartFilterRegex, '// Pastikan item.movement_id yang terpilih ada di allOpts meskipun terfilter!');

// 4. Change buttons
const oldButtons = '<div className="flex flex-wrap gap-2">\n' +
'              <button\n' +
'                onClick={() => onAddItem("upper")}\n' +
'                className="px-4 py-2 text-xs rounded border border-blue-200 text-blue-700 bg-blue-50 hover:bg-blue-100 transition-colors flex items-center gap-1.5 font-medium shadow-sm"\n' +
'              >\n' +
'                <Plus className="h-3.5 w-3.5" /> Tambah Upper\n' +
'              </button>\n' +
'              <button\n' +
'                onClick={() => onAddItem("lower")}\n' +
'                className="px-4 py-2 text-xs rounded border border-green-200 text-green-700 bg-green-50 hover:bg-green-100 transition-colors flex items-center gap-1.5 font-medium shadow-sm"\n' +
'              >\n' +
'                <Plus className="h-3.5 w-3.5" /> Tambah Lower\n' +
'              </button>\n' +
'              <button\n' +
'                onClick={() => onAddItem("core")}\n' +
'                className="px-4 py-2 text-xs rounded border border-amber-200 text-amber-700 bg-amber-50 hover:bg-amber-100 transition-colors flex items-center gap-1.5 font-medium shadow-sm"\n' +
'              >\n' +
'                <Plus className="h-3.5 w-3.5" /> Tambah Core\n' +
'              </button>\n' +
'            </div>';

const newButton = '<div className="flex flex-wrap gap-2">\n' +
'              <button\n' +
'                onClick={() => onAddItem("")}\n' +
'                className="px-4 py-2 text-xs rounded border-2 border-slate-300 text-slate-700 bg-slate-50 hover:bg-slate-100 transition-colors flex items-center gap-1.5 font-medium shadow-sm"\n' +
'              >\n' +
'                <Plus className="h-3.5 w-3.5" /> Tambah Gerakan\n' +
'              </button>\n' +
'            </div>';

content = content.replace(oldButtons, newButton);

fs.writeFileSync(file, content);
console.log("Patched frontend successfully");
