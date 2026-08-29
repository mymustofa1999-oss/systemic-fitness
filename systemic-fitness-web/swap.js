const fs = require('fs');
let content = fs.readFileSync('src/app/(dashboard)/clients/[id]/systemic-assessment/page.tsx', 'utf8');

const historyStart = content.indexOf('{/* QUARTERLY REVIEW HISTORY (TABLE) */}');
// find the parent div
const historyParentStart = content.lastIndexOf('<div className="bg-white rounded-2xl shadow-md border border-slate-200 overflow-hidden">', historyStart);
const inputStart = content.indexOf('{/* Input Form Section (Vertical Layout) */}');
const inputParentStart = content.lastIndexOf('<div className="bg-white rounded-2xl shadow-md border border-slate-200 overflow-hidden">', inputStart);
// end of input is the second to last closing div
const endDiv = content.lastIndexOf('</div>\n    </ClientOnly>');

if (historyParentStart > -1 && inputStart > historyStart && endDiv > inputStart) {
  const historyBlock = content.substring(historyStart - 50, inputStart - 50).trim();
  const inputBlock = content.substring(inputStart - 50, endDiv).trim();
  
  const before = content.substring(0, historyStart - 50);
  const after = content.substring(endDiv);
  
  const newContent = before + inputBlock + '\n\n      ' + historyBlock + '\n    ' + after;
  fs.writeFileSync('src/app/(dashboard)/clients/[id]/systemic-assessment/page.tsx', newContent, 'utf8');
  console.log('SWAPPED SUCCESSFULLY!');
} else {
  console.log('INDICES NOT FOUND');
}
