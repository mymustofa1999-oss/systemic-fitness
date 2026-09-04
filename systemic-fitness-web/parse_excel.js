const fs = require('fs');
const xlsx = require('xlsx');
const path = require('path');

const dir = path.join(__dirname, '../systemic-fitness-api/new movment');
const files = fs.readdirSync(dir).filter(f => f.endsWith('.xlsx'));

const stats = [];

for (const file of files) {
    const filePath = path.join(dir, file);
    const workbook = xlsx.readFile(filePath);
    const sheetName = workbook.SheetNames[0];
    const sheet = workbook.Sheets[sheetName];
    const data = xlsx.utils.sheet_to_json(sheet);

    let gender = file.toLowerCase().includes('female') ? 'Female' : 'Male';
    let levelMatch = file.match(/LEVEL\s*(\d)/i);
    let level = levelMatch ? parseInt(levelMatch[1], 10) : 'Unknown';

    if (data.length === 0) continue;
    
    const keys = Object.keys(data[0]);
    const seqKey = keys.find(k => k.toLowerCase().includes('sequence')) || keys[0];
    const setKey = keys.find(k => k.toLowerCase().includes('set') || k.toLowerCase().includes('track')) || keys[1];
    const typeKey = keys.find(k => k.toLowerCase().includes('type') || k.toLowerCase().includes('group')) || keys[2];
    const sectionKey = keys.find(k => k.toLowerCase().includes('section') || k.toLowerCase().includes('pattern')) || keys[3];
    const exeKey = keys.find(k => k.toLowerCase().includes('exercise')) || keys[4];

    for (const row of data) {
        if (!row[seqKey] && !row[setKey]) continue; 
        stats.push({
            File: file,
            Level: level,
            Gender: gender,
            Sequence: row[seqKey] || 'N/A',
            Set: row[setKey] || 'N/A',
            Type: row[typeKey] || 'N/A',
            Section: row[sectionKey] || 'N/A',
            Exercise: row[exeKey] || 'Unknown'
        });
    }
}

fs.writeFileSync('excel_stats.json', JSON.stringify(stats, null, 2));
console.log(`Parsed ${stats.length} exercises from ${files.length} files.`);
