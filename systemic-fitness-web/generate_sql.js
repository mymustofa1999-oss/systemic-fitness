const fs = require('fs');
const xlsx = require('xlsx');
const path = require('path');
const { execSync } = require('child_process');

const connStr = "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:5432/postgres";
const basePath = path.join(__dirname, '..', 'systemic-fitness-api', 'new movment');

// Fetch current DB state
const output = execSync(`psql "${connStr}" -t -c "SELECT id, name FROM dl_movements;"`).toString();
const dbRecords = output.split('\n').filter(line => line.trim().length > 0).map(line => {
    const parts = line.split('|').map(s => s.trim());
    return { id: parts[0], name: parts[1] };
});

function parseExcel(filename, genderFieldPrefix) {
    const filePath = path.join(basePath, filename);
    const workbook = xlsx.readFile(filePath);
    const sheetName = workbook.SheetNames[0];
    const data = xlsx.utils.sheet_to_json(workbook.Sheets[sheetName]);
    
    return data.map(row => {
        let movement = null;
        let bodyPart = 'whole body';
        
        const upperKey = `${genderFieldPrefix}_MOVEMENT_UPPER`;
        const lowerKey = `${genderFieldPrefix}_MOVEMENT_LOWER`;
        const videoKey = `${genderFieldPrefix}_VIDEO_LINK`;
        
        if (row[upperKey] !== undefined) {
            movement = String(row[upperKey]);
            bodyPart = 'upper';
        } else if (row[lowerKey] !== undefined) {
            movement = String(row[lowerKey]);
            bodyPart = 'lower';
        } else {
            // fallback generic search
            const keys = Object.keys(row);
            const moveKey = keys.find(k => k.toLowerCase().includes('movement') || k.toLowerCase().includes('exercise'));
            if (moveKey) movement = String(row[moveKey]);
        }
        
        return {
            movement: movement ? movement.trim() : null,
            bodyPart: bodyPart,
            videoUrl: row[videoKey] ? String(row[videoKey]).trim() : null
        };
    }).filter(x => x.movement);
}

const maleExcel = parseExcel('MALE-VIDEO LEVEL 1.xlsx', 'MALE');
const femaleExcel = parseExcel('FEMALE-VIDEO LEVEL 1.xlsx', 'FEMALE');

const allMovements = new Map(); // name -> { bodyPart, maleUrl, femaleUrl, existsInDb }

// Build unified map
maleExcel.forEach(e => {
    if (!allMovements.has(e.movement)) {
        allMovements.set(e.movement, { bodyPart: e.bodyPart, maleUrl: e.videoUrl, femaleUrl: null, existsInDb: false });
    } else {
        const item = allMovements.get(e.movement);
        if (e.videoUrl) item.maleUrl = e.videoUrl;
    }
});

femaleExcel.forEach(e => {
    if (!allMovements.has(e.movement)) {
        allMovements.set(e.movement, { bodyPart: e.bodyPart, maleUrl: null, femaleUrl: e.videoUrl, existsInDb: false });
    } else {
        const item = allMovements.get(e.movement);
        if (e.videoUrl) item.femaleUrl = e.videoUrl;
    }
});

// Mark exists in DB
dbRecords.forEach(db => {
    // case-insensitive match
    for (let [name, data] of allMovements.entries()) {
        if (name.toLowerCase() === db.name.toLowerCase()) {
            data.existsInDb = true;
            data.actualDbName = db.name; // Use the exact case from DB
            break;
        }
    }
});

let sql = "BEGIN;\n\n";

for (let [name, data] of allMovements.entries()) {
    const maleSafe = data.maleUrl ? `'${data.maleUrl.replace(/'/g, "''")}'` : 'NULL';
    const femaleSafe = data.femaleUrl ? `'${data.femaleUrl.replace(/'/g, "''")}'` : 'NULL';
    
    if (data.existsInDb) {
        sql += `-- UPDATE EXISTING: ${data.actualDbName}\n`;
        sql += `UPDATE dl_movements SET `;
        
        let updates = [];
        if (data.maleUrl !== null) updates.push(`video_url_male = ${maleSafe}`);
        if (data.femaleUrl !== null) updates.push(`video_url_female = ${femaleSafe}`);
        
        if (updates.length > 0) {
            sql += updates.join(', ') + ` WHERE name = '${data.actualDbName.replace(/'/g, "''")}';\n\n`;
        }
    } else {
        sql += `-- INSERT NEW: ${name}\n`;
        sql += `INSERT INTO dl_movements (name, body_part, video_url_male, video_url_female, categories, is_active, target_gender) `;
        sql += `VALUES ('${name.replace(/'/g, "''")}', '${data.bodyPart}', ${maleSafe}, ${femaleSafe}, '{}', true, 'universal');\n\n`;
    }
}

sql += "COMMIT;\n";
fs.writeFileSync('apply_movements.sql', sql);
console.log('SQL generated to apply_movements.sql');
