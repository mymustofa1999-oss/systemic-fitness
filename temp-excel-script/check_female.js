const ExcelJS = require('exceljs');

async function main() {
  const workbook = new ExcelJS.Workbook();
  await workbook.xlsx.readFile(`../systemic-fitness-api/movment/FEMALE SYSTEMIC MOVEMENT.xlsx`);
  const worksheet = workbook.worksheets[0];
  
  let count = 0;
  worksheet.eachRow((row, rowNumber) => {
    if (count > 20) return;
    count++;
    let rowData = [];
    row.eachCell((cell, colNumber) => {
        rowData.push({col: colNumber, val: cell.value?.richText ? cell.value.richText.map(rt => rt.text).join('') : cell.value});
    });
    console.log(`Row ${rowNumber}:`, JSON.stringify(rowData));
  });
}

main().catch(console.error);
