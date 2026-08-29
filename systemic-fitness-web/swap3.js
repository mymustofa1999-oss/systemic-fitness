const fs = require('fs');
let content = fs.readFileSync('src/app/(dashboard)/clients/[id]/systemic-assessment/page.tsx', 'utf8');

const historyStart = content.lastIndexOf('<div', content.indexOf('QUARTERLY REVIEW (HISTORY)'));
// Actually, let's use the explicit markers:
// {/* Historical Data Table */}
// {/* Input Form Section (Vertical Layout) */}

const p1 = content.indexOf('{/* Historical Data Table */}');
const p2 = content.indexOf('{/* Input Form Section (Vertical Layout) */}');
const p3 = content.lastIndexOf('</div>\n    </ClientOnly>');

if (p1 > -1 && p2 > -1 && p3 > -1 && p2 > p1) {
  const before = content.substring(0, p1);
  const historyBlock = content.substring(p1, p2);
  const inputBlock = content.substring(p2, p3);
  const after = content.substring(p3);
  
  // We need to remove the `mt-8` from the History table if it's placed second, and add it to the History table.
  // Actually, we can just leave the styling as is, just swap them.
  // Wait, if we just swap them:
  const newContent = before + inputBlock + '\n\n' + historyBlock + after;
  fs.writeFileSync('src/app/(dashboard)/clients/[id]/systemic-assessment/page.tsx', newContent, 'utf8');
  console.log('SWAPPED CORRECTLY!');
} else {
  console.log('INDICES NOT FOUND');
}
