const fs = require('fs');
let content = fs.readFileSync('src/app/(dashboard)/clients/[id]/systemic-assessment/page.tsx', 'utf8');

// The main wrapper is:
// <div className="space-y-8 max-w-[1600px] mx-auto pb-12">
// Inside it, there are exactly two large divs:
// <div className="bg-white rounded-2xl shadow-md border border-slate-200 overflow-hidden">
// One contains "QUARTERLY REVIEW"
// One contains "INPUT NEW ASSESSMENT"

const parts = content.split('<div className="bg-white rounded-2xl shadow-md border border-slate-200 overflow-hidden">');
if (parts.length === 3) {
  // parts[0] is the prefix up to the first div
  // parts[1] is the first div content up to the second div
  // parts[2] is the second div content till the end
  
  let block1 = '<div className="bg-white rounded-2xl shadow-md border border-slate-200 overflow-hidden">' + parts[1];
  let block2 = '<div className="bg-white rounded-2xl shadow-md border border-slate-200 overflow-hidden">' + parts[2];
  
  // Actually parts[1] might have extra text at the end that belongs between them.
  // We can split by a safer marker.
  const historyHeaderIndex = content.indexOf('QUARTERLY REVIEW');
  const inputHeaderIndex = content.indexOf('INPUT NEW ASSESSMENT');
  
  let historyBlock, inputBlock;
  
  const divSeparator = '<div className="bg-white rounded-2xl shadow-md border border-slate-200 overflow-hidden">';
  const firstDivIndex = content.indexOf(divSeparator);
  const secondDivIndex = content.indexOf(divSeparator, firstDivIndex + 1);
  const endDivIndex = content.lastIndexOf('</div>\n    </ClientOnly>');
  
  if (firstDivIndex > -1 && secondDivIndex > -1 && endDivIndex > -1) {
    const blockA = content.substring(firstDivIndex, secondDivIndex);
    const blockB = content.substring(secondDivIndex, endDivIndex);
    
    // We want INPUT (blockB) to be first, HISTORY (blockA) to be second.
    // Let's assume blockB contains "INPUT NEW ASSESSMENT".
    if (blockB.includes('INPUT NEW ASSESSMENT') && blockA.includes('QUARTERLY REVIEW')) {
      const before = content.substring(0, firstDivIndex);
      const after = content.substring(endDivIndex);
      const newContent = before + blockB + blockA + after;
      fs.writeFileSync('src/app/(dashboard)/clients/[id]/systemic-assessment/page.tsx', newContent, 'utf8');
      console.log('SWAPPED CORRECTLY!');
    } else if (blockA.includes('INPUT NEW ASSESSMENT') && blockB.includes('QUARTERLY REVIEW')) {
      console.log('ALREADY IN CORRECT ORDER (INPUT FIRST, HISTORY SECOND)');
    } else {
      console.log('UNEXPECTED BLOCKS');
    }
  } else {
    console.log('DIVS NOT FOUND');
  }
} else {
  console.log('SPLIT FAILED');
}
