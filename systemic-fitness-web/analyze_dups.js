const xlsx = require('xlsx');
const path = require('path');
const fs = require('fs');

const basePath = path.join(__dirname, '..', 'systemic-fitness-api', 'new movment');

function analyzeGenderExcel(filename, genderPrefix) {
    const filePath = path.join(basePath, filename);
    const workbook = xlsx.readFile(filePath);
    const sheetName = workbook.SheetNames[0];
    const data = xlsx.utils.sheet_to_json(workbook.Sheets[sheetName]);
    
    let processed = data.map((row, index) => {
        let movement = null;
        let url = null;
        
        const upperKey = `${genderPrefix}_MOVEMENT_UPPER`;
        const lowerKey = `${genderPrefix}_MOVEMENT_LOWER`;
        const videoKey = `${genderPrefix}_VIDEO_LINK`;
        
        if (row[upperKey] !== undefined) movement = String(row[upperKey]).trim();
        else if (row[lowerKey] !== undefined) movement = String(row[lowerKey]).trim();
        else {
            const keys = Object.keys(row);
            const moveKey = keys.find(k => k.toLowerCase().includes('movement') || k.toLowerCase().includes('exercise'));
            if (moveKey) movement = String(row[moveKey]).trim();
        }
        
        if (row[videoKey] !== undefined) url = String(row[videoKey]).trim();
        
        return {
            rowIdx: index + 2, // 1 for header, 1 for 0-index
            movement,
            url,
            raw: row
        };
    }).filter(x => x.movement);
    
    // Group by movement
    let groups = {};
    processed.forEach(p => {
        if (!groups[p.movement]) groups[p.movement] = [];
        groups[p.movement].push(p);
    });
    
    // Filter duplicates
    let duplicates = {};
    for (let key in groups) {
        if (groups[key].length > 1) {
            duplicates[key] = groups[key];
        }
    }
    
    return duplicates;
}

const maleDups = analyzeGenderExcel('MALE-VIDEO LEVEL 1.xlsx', 'MALE');
const femaleDups = analyzeGenderExcel('FEMALE-VIDEO LEVEL 1.xlsx', 'FEMALE');

fs.writeFileSync('dups_male.json', JSON.stringify(maleDups, null, 2));
fs.writeFileSync('dups_female.json', JSON.stringify(femaleDups, null, 2));

console.log("Analysis complete");
