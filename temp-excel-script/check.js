const ExcelJS = require('exceljs');
const fs = require('fs');

async function main() {
  const files = [
    'LEVEL_1.xlsx', 'LEVEL_2.xlsx', 'LEVEL_3.xlsx', 
    'LEVEL_4.xlsx', 'LEVEL_5.xlsx', 'LEVEL_6_LOCK.xlsx'
  ];

  for (const file of files) {
    const workbook = new ExcelJS.Workbook();
    await workbook.xlsx.readFile(`../systemic-fitness-api/movment/${file}`);
    const worksheet = workbook.worksheets[0];
    
    worksheet.eachRow((row, rowNumber) => {
      let isYellow = false;
      let fVideo = "";
      let mVideo = "";
      
      row.eachCell((cell, colNumber) => {
        const fgColor = cell.fill && cell.fill.fgColor ? cell.fill.fgColor.argb : null;
        if (fgColor && (fgColor.toLowerCase().includes('ffff00') || fgColor.toLowerCase() === 'ffffff00')) {
          isYellow = true;
        }
        if (colNumber === 7) {
            fVideo = cell.value?.richText ? cell.value.richText.map(rt => rt.text).join('') : (cell.value?.text || cell.value);
        }
        if (colNumber === 11) {
            mVideo = cell.value?.richText ? cell.value.richText.map(rt => rt.text).join('') : (cell.value?.text || cell.value);
        }
      });
      
      if (isYellow) {
          if (fVideo && typeof fVideo === 'string' && !fVideo.includes('youtu') && fVideo.toLowerCase() !== 'waitlist') {
              console.log(`WARNING: Row ${rowNumber} in ${file} fVideo is NOT youtube: "${fVideo}"`);
          }
          if (mVideo && typeof mVideo === 'string' && !mVideo.includes('youtu') && mVideo.toLowerCase() !== 'waitlist') {
              console.log(`WARNING: Row ${rowNumber} in ${file} mVideo is NOT youtube: "${mVideo}"`);
          }
      }
    });
  }
  console.log("Check complete.");
}

main().catch(console.error);
