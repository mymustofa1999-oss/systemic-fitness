const fs = require('fs');
let content = fs.readFileSync('src/app/(dashboard)/clients/[id]/systemic-assessment/page.tsx', 'utf8');

const p1 = content.indexOf('{/* Historical Data Table */}');
const p2 = content.indexOf('{/* Input Form Section (Vertical Layout) */}');
const p3 = content.indexOf('      <style dangerouslySetInnerHTML');

if (p1 > -1 && p2 > -1 && p3 > -1 && p2 > p1) {
  const before = content.substring(0, p1);
  const historyBlock = content.substring(p1, p2);
  const inputBlock = content.substring(p2, p3);
  const after = content.substring(p3);
  
  const newContent = before + inputBlock + '\n\n' + historyBlock + after;
  fs.writeFileSync('src/app/(dashboard)/clients/[id]/systemic-assessment/page.tsx', newContent, 'utf8');
  console.log('SWAPPED CORRECTLY!');
} else {
  console.log('INDICES NOT FOUND');
}
