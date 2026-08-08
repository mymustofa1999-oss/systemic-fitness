const xlsx = require('xlsx');

const filePath = "C:/Users/ITBDG/Documents/SystemicFitness-Handover/CLEAN/systemic-fitness-api/systemic assesment/Systemic Assesment .xlsx";

const workbook = xlsx.readFile(filePath);
const sheetNames = workbook.SheetNames;
console.log("Sheet names:", sheetNames);

for (const sheetName of sheetNames) {
  console.log(`\n\n--- Sheet: ${sheetName} ---`);
  const sheet = workbook.Sheets[sheetName];
  const data = xlsx.utils.sheet_to_json(sheet, { header: 1 }); // read as array of arrays
  
  for (let i = 0; i < Math.min(50, data.length); i++) {
    console.log(`Row ${i}:`, data[i]);
  }
}
