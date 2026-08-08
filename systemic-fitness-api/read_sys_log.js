const xlsx = require("xlsx");
const workbook = xlsx.readFile("SYSTEMIC SESSION LOG/SYSTEMIC SESSION LOG.xlsx");
console.log("Sheets: ", workbook.SheetNames);
const sheet = workbook.Sheets["Scoring Guide"];
if (sheet) {
  const data = xlsx.utils.sheet_to_json(sheet, { header: 1 });
  data.slice(0, 100).forEach(row => {
    console.log(row.map(c => (c !== undefined && c !== null) ? c.toString().substring(0, 100) : "").join(" | "));
  });
}
