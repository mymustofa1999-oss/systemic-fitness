const fs = require('fs');
const xlsx = require('xlsx');
const path = require('path');
const { execSync } = require('child_process');

const connStr = "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:5432/postgres";
const basePath = path.join(__dirname, '..', 'systemic-fitness-api', 'new movment');

// Fetch current DB state
const output = execSync(`psql "${connStr}" -t -c "SELECT id, name, video_url_male, video_url_female FROM dl_movements;"`).toString();
const dbRecords = output.split('\n').filter(line => line.trim().length > 0).map(line => {
    const parts = line.split('|').map(s => s.trim());
    return { id: parts[0], name: parts[1], maleUrl: parts[2], femaleUrl: parts[3] };
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

const results = {
    male: { excelRecords: maleExcel.length, matched: 0, missing: 0, urlMatched: 0, urlMismatch: 0, waitlist: 0, duplicate: 0 },
    female: { excelRecords: femaleExcel.length, matched: 0, missing: 0, urlMatched: 0, urlMismatch: 0, waitlist: 0, duplicate: 0 }
};

let details = "";
details += "| Level | Gender | Movement | Excel Video URL | Database Video URL | Match | Status |\n";
details += "|---|---|---|---|---|---|---|\n";

function verifyGender(excelData, genderLabel, urlField) {
    excelData.forEach(row => {
        let status = "";
        const isWaitlist = row.videoUrl === 'waitlist' || row.videoUrl === null;
        if (isWaitlist) results[genderLabel].waitlist++;
        
        const matches = dbRecords.filter(db => db.name.toLowerCase() === row.movement.toLowerCase());
        if (matches.length === 0) {
            results[genderLabel].missing++;
            status = "MISSING";
            details += `| 1 | ${genderLabel.toUpperCase()} | ${row.movement} | ${row.videoUrl || 'null'} | null | NO | ${status} |\n`;
        } else if (matches.length > 1) {
            results[genderLabel].duplicate++;
            status = "DUPLICATE";
            details += `| 1 | ${genderLabel.toUpperCase()} | ${row.movement} | ${row.videoUrl || 'null'} | Multiple | NO | ${status} |\n`;
        } else {
            results[genderLabel].matched++;
            const dbUrl = matches[0][urlField];
            
            // Waitlist values are saved verbatim, check if they match
            if (row.videoUrl === dbUrl || (!row.videoUrl && !dbUrl)) {
                results[genderLabel].urlMatched++;
                status = isWaitlist ? "WAITLIST" : "MATCH";
                details += `| 1 | ${genderLabel.toUpperCase()} | ${row.movement} | ${row.videoUrl || 'null'} | ${dbUrl || 'null'} | YES | ${status} |\n`;
            } else {
                results[genderLabel].urlMismatch++;
                status = "MISMATCH";
                details += `| 1 | ${genderLabel.toUpperCase()} | ${row.movement} | ${row.videoUrl || 'null'} | ${dbUrl || 'null'} | NO | ${status} |\n`;
            }
        }
    });
}

verifyGender(maleExcel, 'male', 'maleUrl');
verifyGender(femaleExcel, 'female', 'femaleUrl');

fs.writeFileSync('verification_results.json', JSON.stringify(results, null, 2));
fs.writeFileSync('verification_details.md', details);
