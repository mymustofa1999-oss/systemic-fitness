const fs = require('fs');

function fixFormatMovementName(filePath) {
    let c = fs.readFileSync(filePath, 'utf8');

    const formatMovementRegex = /function formatMovementName\(rawName: string, gender: string \| undefined\): string \{[\s\S]*?return rawName;\s*\}/;
    
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

    if (normalizedGender === "male" || normalizedGender === "pria" || normalizedGender === "men" || normalizedGender === "laki-laki") {
      return maleName + levelSuffix;
    }
    
    // Default to female name for female, wanita, women, or if gender is unknown/empty.
    // This prevents the raw string with "|" from ever being shown to the user.
    return femaleName + levelSuffix;
  }

  return rawName;
}`;

    if (c.match(formatMovementRegex)) {
        c = c.replace(formatMovementRegex, formatMovementNew);
        fs.writeFileSync(filePath, c, 'utf8');
        console.log('Fixed formatMovementName in', filePath);
    } else {
        console.log('Could not find formatMovementName in', filePath);
    }
}

fixFormatMovementName('C:/Users/ITBDG/Documents/SystemicFitness-Handover/CLEAN/systemic-fitness-web/src/app/(dashboard)/clients/[id]/live-session/page.tsx');
fixFormatMovementName('C:/Users/ITBDG/Documents/SystemicFitness-Handover/CLEAN/systemic-fitness-web/src/app/(dashboard)/clients/[id]/training-card/page.tsx');
