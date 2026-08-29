const { execSync } = require('child_process');
const fs = require('fs');
const xlsx = require('xlsx');
const path = require('path');

const connStr = "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:5432/postgres";
const basePath = path.join(__dirname, '..', 'systemic-fitness-api', 'new movment');

// 1. Fetch current DB state
const output = execSync(`psql "${connStr}" -t -c "SELECT id, name, video_url_male, video_url_female FROM dl_movements;"`).toString();
const dbRecords = output.split('\n').filter(line => line.trim().length > 0).map(line => {
    const parts = line.split('|').map(s => s.trim());
    return { id: parts[0], name: parts[1], male: parts[2], female: parts[3] };
});

function parseExcel(filename) {
    const filePath = path.join(basePath, filename);
    const workbook = xlsx.readFile(filePath);
    const sheetName = workbook.SheetNames[0];
    const data = xlsx.utils.sheet_to_json(workbook.Sheets[sheetName]);
    
    return data.map(row => {
        const keys = Object.keys(row);
        const movementKey = keys.find(k => k.toLowerCase().includes('movement') || k.toLowerCase().includes('exercise') || k.toLowerCase().includes('gerakan'));
        const videoKey = keys.find(k => k.toLowerCase().includes('video') || k.toLowerCase().includes('url'));
        return {
            movement: row[movementKey],
            videoUrl: videoKey ? row[videoKey] : null
        };
    }).filter(x => x.movement);
}

const maleExcel = parseExcel('MALE-VIDEO LEVEL 1.xlsx');
const femaleExcel = parseExcel('FEMALE-VIDEO LEVEL 1.xlsx');

let maleUpdates = 0;
let maleMissing = 0;
let femaleUpdates = 0;
let femaleMissing = 0;

console.log('EXCEL SOURCE\n------------');
console.log('File: MALE-VIDEO LEVEL 1.xlsx & FEMALE-VIDEO LEVEL 1.xlsx');
console.log('Sheet: Sheet1\n');

console.log('LEVEL 1 MALE\n------------');
console.log(`Excel records: ${maleExcel.length}`);
console.log(`Existing DB records: ${dbRecords.length}`);
let maleReport = [];
maleExcel.forEach(e => {
    if (!e.videoUrl || e.videoUrl.toLowerCase() === 'waitlist') maleMissing++;
    const dbMatch = dbRecords.find(db => db.name && e.movement && db.name.toLowerCase() === String(e.movement).toLowerCase());
    if (dbMatch) {
        if (dbMatch.male !== e.videoUrl) {
            maleUpdates++;
            maleReport.push(`UPDATE: '${e.movement}' -> ${e.videoUrl}`);
        }
    } else {
        maleReport.push(`NOT FOUND IN DB: '${e.movement}'`);
    }
});
console.log(`New records: 0 (Strict update only)`);
console.log(`Records to update: ${maleUpdates}`);
console.log(`Missing video URL: ${maleMissing}\n`);

console.log('LEVEL 1 FEMALE\n--------------');
console.log(`Excel records: ${femaleExcel.length}`);
console.log(`Existing DB records: ${dbRecords.length}`);
let femaleReport = [];
femaleExcel.forEach(e => {
    if (!e.videoUrl || e.videoUrl.toLowerCase() === 'waitlist') femaleMissing++;
    const dbMatch = dbRecords.find(db => db.name && e.movement && db.name.toLowerCase() === String(e.movement).toLowerCase());
    if (dbMatch) {
        if (dbMatch.female !== e.videoUrl) {
            femaleUpdates++;
            femaleReport.push(`UPDATE: '${e.movement}' -> ${e.videoUrl}`);
        }
    } else {
        femaleReport.push(`NOT FOUND IN DB: '${e.movement}'`);
    }
});
console.log(`New records: 0 (Strict update only)`);
console.log(`Records to update: ${femaleUpdates}`);
console.log(`Missing video URL: ${femaleMissing}\n`);

console.log('DATABASE CHANGES\n----------------');
console.log('INSERT: 0');
console.log(`UPDATE: ${maleUpdates + femaleUpdates}`);
console.log('DELETE: 0');
console.log('Migration: NO');
console.log('Schema change: NO');

fs.writeFileSync('dry_run_details.txt', maleReport.join('\n') + '\n\n' + femaleReport.join('\n'));
