const xlsx = require('xlsx');
const wb = xlsx.readFile('../systemic-fitness-api/new movment/FEMALE- VIDEO LEVEL 3.xlsx');
const data = xlsx.utils.sheet_to_json(wb.Sheets[wb.SheetNames[0]]);
console.log("Keys in row 0:", Object.keys(data[0]));
console.log("First row:", data[0]);
