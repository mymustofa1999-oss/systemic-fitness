const xlsx = require('xlsx');
const path = require('path');

const basePath = path.join(__dirname, '..', 'systemic-fitness-api', 'new movment');

function readExcel(filename) {
    const filePath = path.join(basePath, filename);
    console.log(`\n\nEXCEL SOURCE\n------------\nFile: ${filename}`);
    
    try {
        const workbook = xlsx.readFile(filePath);
        const sheetName = workbook.SheetNames[0];
        console.log(`Sheet: ${sheetName}\n`);
        
        const data = xlsx.utils.sheet_to_json(workbook.Sheets[sheetName]);
        
        console.log(`${filename.includes('FEMALE') ? 'LEVEL 1 FEMALE' : 'LEVEL 1 MALE'}\n------------`);
        data.forEach(row => {
            // Find columns dynamically since headers might vary
            const keys = Object.keys(row);
            const movementKey = keys.find(k => k.toLowerCase().includes('movement') || k.toLowerCase().includes('exercise') || k.toLowerCase().includes('gerakan'));
            const videoKey = keys.find(k => k.toLowerCase().includes('video') || k.toLowerCase().includes('url'));
            
            if (movementKey) {
                const movement = row[movementKey];
                const videoUrl = videoKey ? row[videoKey] : 'MISSING';
                console.log(`- ${movement} — ${videoUrl || 'MISSING'}`);
            } else {
                console.log(`- Unknown Movement — ${JSON.stringify(row)}`);
            }
        });
        
    } catch (e) {
        console.error(`Error reading ${filename}: ${e.message}`);
    }
}

readExcel('MALE-VIDEO LEVEL 1.xlsx');
readExcel('FEMALE-VIDEO LEVEL 1.xlsx');
