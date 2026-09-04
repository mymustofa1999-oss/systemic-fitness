const fs = require('fs');
const data = JSON.parse(fs.readFileSync('excel_stats.json', 'utf8'));

const summary = {};

for (const row of data) {
    const key = `${row.Level}|${row.Gender}|${row.Sequence}|${row.Set}|${row.Type}|${row.Section}`;
    if (!summary[key]) summary[key] = 0;
    summary[key]++;
}

const lines = ['Level | Gender | Sequence | Set | Type | Section | Count', '---|---|---|---|---|---|---'];
for (const [key, count] of Object.entries(summary)) {
    lines.push(`${key.replace(/\|/g, ' | ')} | ${count}`);
}

fs.writeFileSync('excel_summary.md', lines.join('\n'));
console.log('Summary created.');
