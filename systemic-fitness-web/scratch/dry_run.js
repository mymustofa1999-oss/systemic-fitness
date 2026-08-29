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
        Male: { rows: 0, movements: new Set(), missingUrls: 0 },
        Female: { rows: 0, movements: new Set(), missingUrls: 0 }
    };
}

const parsedData = [];

files.forEach(file => {
    let gender = file.toLowerCase().includes('female') ? 'Female' : 'Male';
    let levelMatch = file.match(/LEVEL (\d)/i);
    if (!levelMatch) return;
    let level = parseInt(levelMatch[1], 10);

    const workbook = xlsx.readFile(path.join(dir, file));
    const sheetName = workbook.SheetNames[0];
    const data = xlsx.utils.sheet_to_json(workbook.Sheets[sheetName], { header: 1 });

    data.slice(1).forEach(row => {
        if (!row || row.length === 0) return;
        
        let sequence = String(row[0] || '').trim();
        let setTrack = String(row[1] || '').trim();
        let type = String(row[2] || '').trim();
        let section = String(row[3] || '').trim();
        let moveUpper = String(row[4] || '').trim();
        let moveLower = String(row[5] || '').trim();
        let url = String(row[6] || '').trim();
        
        if (!sequence) return;
        
        let movementName = moveUpper || moveLower;
        if (!movementName) return;

        inventory.totalExcelRows++;
        inventory.levels[level][gender].rows++;
        inventory.levels[level][gender].movements.add(movementName);
        
        if (!url.includes('http')) {
            inventory.levels[level][gender].missingUrls++;
            url = null;
        }

        parsedData.push({
            level,
            gender,
            sequence,
            set: setTrack,
            type,
            section,
            movement: movementName,
            url
        });
    });
});

console.log(JSON.stringify(inventory, (k,v) => v instanceof Set ? [...v].length : v, 2));

fs.writeFileSync('parsed_all.json', JSON.stringify(parsedData, null, 2));
console.log('Saved to parsed_all.json');
