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
    const data = xlsx.utils.sheet_to_json(workbook.Sheets[sheetName]);

    // Use sheet_to_json without {header: 1} to get object with header keys
    data.forEach(row => {
        // Find keys that match our columns, they might vary slightly
        const keys = Object.keys(row);
        let seqKey = keys.find(k => k.toLowerCase().includes('sequence'));
        let setKey = keys.find(k => k.toLowerCase().includes('set') || k.toLowerCase().includes('track'));
        let typeKey = keys.find(k => k.toLowerCase() === 'type');
        let secKey = keys.find(k => k.toLowerCase() === 'section');
        let moveUpperKey = keys.find(k => k.toLowerCase().includes('upper'));
        let moveLowerKey = keys.find(k => k.toLowerCase().includes('lower'));
        let videoKey = keys.find(k => k.toLowerCase().includes('video') || k.toLowerCase().includes('link'));

        let sequence = seqKey ? String(row[seqKey] || '').trim() : '';
        let setTrack = setKey ? String(row[setKey] || '').trim() : '';
        let type = typeKey ? String(row[typeKey] || '').trim() : '';
        let section = secKey ? String(row[secKey] || '').trim() : '';
        let moveUpper = moveUpperKey ? String(row[moveUpperKey] || '').trim() : '';
        let moveLower = moveLowerKey ? String(row[moveLowerKey] || '').trim() : '';
        let url = videoKey ? String(row[videoKey] || '').trim() : '';
        
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
