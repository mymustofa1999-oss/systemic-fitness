const fs = require('fs');
const data = JSON.parse(fs.readFileSync('excel_stats.json', 'utf8'));

const sets = new Set();
const seqs = new Set();
const types = new Set();
const sections = new Set();

for (const row of data) {
    if (row.Sequence) seqs.add(row.Sequence.toString().trim());
    if (row.Set) sets.add(row.Set.toString().trim());
    if (row.Type) types.add(row.Type.toString().trim());
    if (row.Section) sections.add(row.Section.toString().trim());
}

console.log("Sequences:", [...seqs]);
console.log("Sets:", [...sets]);
console.log("Types:", [...types]);
console.log("Sections:", [...sections]);
