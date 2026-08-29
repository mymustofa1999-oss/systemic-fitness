const fs = require('fs');
const file = 'src/app/(dashboard)/clients/[id]/training-card/page.tsx';
let content = fs.readFileSync(file, 'utf8');

const oldCode = \  const filteredMovements = allMovements.filter(m => {
    if (pickerSearch && !(m.name || "").toLowerCase().includes(pickerSearch.toLowerCase())) return false;
    if (pickerBodyPart && (m.body_part || "").toLowerCase() !== pickerBodyPart.toLowerCase()) return false;
    return true;
  });\;

const newCode = \  const filteredMovements = allMovements.filter(m => {
    if (pickerSearch && !(m.name || "").toLowerCase().includes(pickerSearch.toLowerCase())) return false;
    if (pickerBodyPart && (m.body_part || "").toLowerCase() !== pickerBodyPart.toLowerCase()) return false;
    
    const currentLevel = parseInt(level);
    if (!isNaN(currentLevel) && currentLevel > 0) {
      let mLevel = typeof m.level === 'number' && m.level > 0 ? m.level : null;
      let mGender = (m.target_gender && m.target_gender !== 'universal') ? m.target_gender.toLowerCase() : null;
      
      const match = (m.name || "").match(/\\[L(\\d+)(?:\\s+(Male|Female|Men|Women|Pria|Wanita))?\\]/i);
      if (match) {
        if (!mLevel) mLevel = parseInt(match[1]);
        if (!mGender && match[2]) mGender = match[2].toLowerCase();
      }

      if (mLevel && mLevel !== currentLevel) {
        return false;
      }

      if (gender && mGender) {
        const effGender = gender.toLowerCase();
        const isMale = effGender === "male" || effGender === "men" || effGender === "pria" || effGender === "laki-laki";
        const isFemale = effGender === "female" || effGender === "women" || effGender === "wanita" || effGender === "perempuan";
        
        const mIsMale = mGender === "male" || mGender === "men" || mGender === "pria";
        const mIsFemale = mGender === "female" || mGender === "women" || mGender === "wanita";

        if (isMale && mIsFemale) return false;
        if (isFemale && mIsMale) return false;
      }
    }

    return true;
  });\;

if (content.includes(oldCode)) {
    content = content.replace(oldCode, newCode);
    fs.writeFileSync(file, content);
    console.log("Patched successfully");
} else {
    console.log("Could not find the target code to patch");
}
