const fs = require('fs');
const path = 'C:/Users/ITBDG/Documents/SystemicFitness-Handover/CLEAN/systemic-fitness-web/src/app/(dashboard)/clients/[id]/live-session/page.tsx';
let c = fs.readFileSync(path, 'utf8');

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

fs.writeFileSync(path, c, 'utf8');
console.log('Fixed formatMovementName in live-session');
