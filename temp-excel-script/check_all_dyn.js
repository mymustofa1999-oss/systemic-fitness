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
    
    let mismatchCount = 0;
    worksheet.eachRow((row, rowNumber) => {
      let typeCol = "";
      let isYellow = false;
      row.eachCell((cell, colNumber) => {
        if (colNumber === 3) {
            typeCol = cell.value?.richText ? cell.value.richText.map(rt => rt.text).join('') : cell.value;
        }
        const fgColor = cell.fill && cell.fill.fgColor ? cell.fill.fgColor.argb : null;
        if (fgColor && (fgColor.toLowerCase().includes('ffff00') || fgColor.toLowerCase() === 'ffffff00')) {
          isYellow = true;
        }
      });
      
      const isTypeDynamic = typeCol && typeCol.toLowerCase().includes('dynamic');
      
      if (isTypeDynamic && !isYellow) {
          console.log(`Mismatch in ${file} Row ${rowNumber}: TYPE is Dynamic but NOT yellow`);
          mismatchCount++;
      } else if (!isTypeDynamic && isYellow) {
          console.log(`Mismatch in ${file} Row ${rowNumber}: YELLOW but TYPE is ${typeCol}`);
          mismatchCount++;
      }
    });
    console.log(`${file} mismatches: ${mismatchCount}`);
  }
}

main().catch(console.error);
