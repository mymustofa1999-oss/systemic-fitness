const fs = require('fs');
const path = 'C:/Users/ITBDG/Documents/SystemicFitness-Handover/CLEAN/systemic-fitness-web/src/app/(dashboard)/clients/[id]/training-card/page.tsx';
let c = fs.readFileSync(path, 'utf8');

// 1. Fix formatMovementName
const formatMovementOld = `function formatMovementName(rawName: string, gender: string | undefined): string {
  if (!rawName) return "-";
  if (!rawName.includes(" | ")) return rawName;

  const normalizedGender = (gender || "").toLowerCase();
  
  // Extract level suffix if present
  let levelSuffix = "";
  let baseName = rawName;
  const levelMatch = rawName.match(/(\\s*\\[L\\d+\\])$/i);
  if (levelMatch) {
    levelSuffix = levelMatch[1];
    baseName = rawName.replace(/(\\s*\\[L\\d+\\])$/i, "");
  }

  const parts = baseName.split(" | ");
  if (parts.length === 2) {
    const femaleName = parts[0].trim();
    const maleName = parts[1].trim();

    if (normalizedGender === "female" || normalizedGender === "wanita" || normalizedGender === "women") {
      return femaleName + levelSuffix;
    } else if (normalizedGender === "male" || normalizedGender === "pria" || normalizedGender === "men") {
      return maleName + levelSuffix;
    }
  }

  return rawName;
}`;

const formatMovementNew = `function formatMovementName(rawName: string, gender: string | undefined): string {
  if (!rawName) return "-";
  if (!rawName.includes(" | ")) return rawName;

  const normalizedGender = (gender || "").toLowerCase();
  
  // Extract level suffix if present
  let levelSuffix = "";
  let baseName = rawName;
  const levelMatch = rawName.match(/(\\s*\\[L\\d+\\])$/i);
  if (levelMatch) {
    levelSuffix = levelMatch[1];
    baseName = rawName.replace(/(\\s*\\[L\\d+\\])$/i, "");
  }

  const parts = baseName.split(" | ");
  if (parts.length >= 2) {
    const femaleName = parts[0].trim();
    const maleName = parts[1].trim();
    
    // Fix: if maleName is a youtube link (which happens if data was entered incorrectly)
    // just return the female name (the actual movement name) for both genders.
    if (maleName.startsWith("http")) {
        return femaleName + levelSuffix;
    }

    if (normalizedGender === "female" || normalizedGender === "wanita" || normalizedGender === "women") {
      return femaleName + levelSuffix;
    } else if (normalizedGender === "male" || normalizedGender === "pria" || normalizedGender === "men") {
      return maleName + levelSuffix;
    }
  }

  return rawName;
}`;

// Use regex to replace to avoid whitespace issues
const formatMovementRegex = /function formatMovementName\(rawName: string, gender: string \| undefined\): string \{[\s\S]*?return rawName;\s*\}/;
c = c.replace(formatMovementRegex, formatMovementNew);

// 2. Fix SortableItemRow Layout
const rowRegex = /<div ref=\{setNodeRef\} style=\{style\} className=\{`flex flex-col md:flex-row gap-4 bg-white p-3 border \$\{isDragging \? "border-violet-400 shadow-md" : "border-slate-200"\} rounded-md shadow-sm relative`\}>\s*\{editing && \(\s*<div \{\.\.\.attributes\} \{\.\.\.listeners\} className="absolute -left-3 top-1\/2 -translate-y-1\/2 p-2 cursor-grab active:cursor-grabbing text-slate-300 hover:text-slate-500 bg-white border border-slate-200 rounded-full shadow-sm z-10 md:flex hidden">\s*<GripVertical className="h-4 w-4" \/>\s*<\/div>\s*\)/;

const newRow = `<div ref={setNodeRef} style={style} className={\`flex flex-col md:flex-row gap-4 bg-white p-3 border \${isDragging ? "border-violet-400 shadow-md" : "border-slate-200"} rounded-md shadow-sm relative md:items-center items-start\`}>
        {editing && (
          <div {...attributes} {...listeners} className="cursor-grab active:cursor-grabbing text-slate-400 hover:text-slate-600 p-1 md:block hidden shrink-0" title="Geser untuk mengatur urutan">
            <GripVertical className="h-5 w-5" />
          </div>
        )}`;

c = c.replace(rowRegex, newRow);

fs.writeFileSync(path, c, 'utf8');
console.log('Fixed formatMovementName and SortableItemRow layout');
