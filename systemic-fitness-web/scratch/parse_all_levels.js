const xlsx = require('xlsx');
const fs = require('fs');
const path = require('path');

const dir = 'c:/Users/ITBDG/Documents/SystemicFitness-Handover/CLEAN/systemic-fitness-api/new movment';
const files = fs.readdirSync(dir).filter(f => f.endsWith('.xlsx'));

let inventory = {
    totalExcelRows: 0,
    levels: {}
};

for (let i = 1; i <= 6; i++) {
    inventory.levels[i] = {
        Male: { rows: 0, movements: new Set() },
        Female: { rows: 0, movements: new Set() }
    };
}

const parsedData = [];

files.forEach(file => {
    // Parse level and gender from filename
    // e.g. "FEMALE- VIDEO LEVEL 2.xlsx"
    let gender = file.toLowerCase().includes('female') ? 'Female' : 'Male';
    let levelMatch = file.match(/LEVEL (\d)/i);
    if (!levelMatch) return;
    let level = parseInt(levelMatch[1], 10);

    const workbook = xlsx.readFile(path.join(dir, file));
    const sheetName = workbook.SheetNames[0];
    const data = xlsx.utils.sheet_to_json(workbook.Sheets[sheetName], { header: 1 });

    // Based on previous analysis, rows usually contain:
    // sequence in some column, or it's separated by headers
    // Let's print out the first few rows of each to see structure, or just use a generic parser.
    // In Batch 3E, we found sequence is inferred from headers like "FC", "CC", "MC".
    
    let currentSequence = null;
    let currentSet = null;

    data.forEach(row => {
        if (!row || row.length === 0) return;
        
        let firstCol = String(row[0] || '').trim();
        let secondCol = String(row[1] || '').trim();
        
        if (firstCol === 'FC' || firstCol === 'CC' || firstCol === 'MC') {
            currentSequence = firstCol;
        }
        if (firstCol.toLowerCase().startsWith('set ')) {
            currentSet = firstCol;
        }

        // if second col looks like a youtube url and first col is a movement name
        if (secondCol.includes('youtu')) {
            let movementName = firstCol;
            let url = secondCol;
            
            // fallbacks if sequence or set is missing
            let seq = currentSequence || 'FC';
            let set = currentSet || 'SET 1';

            inventory.totalExcelRows++;
            inventory.levels[level][gender].rows++;
            inventory.levels[level][gender].movements.add(movementName);

            parsedData.push({
                level,
                gender,
                sequence: seq,
                set: set,
                movement: movementName,
                url: url
            });
        }
    });
});

console.log(JSON.stringify(inventory, (k,v) => v instanceof Set ? [...v].length : v, 2));

// Save parsed data
fs.writeFileSync('parsed_all.json', JSON.stringify(parsedData, null, 2));
console.log('Saved to parsed_all.json');
