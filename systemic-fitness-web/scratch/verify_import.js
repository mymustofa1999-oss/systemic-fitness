const xlsx = require('xlsx');
const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

const DB_URL = "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:5432/postgres";

async function main() {
    const client = new Client({ connectionString: DB_URL });
    await client.connect();

    const dir = 'c:/Users/ITBDG/Documents/SystemicFitness-Handover/CLEAN/systemic-fitness-api/new movment';
    const files = fs.readdirSync(dir).filter(f => f.endsWith('.xlsx'));

    let excelItems = [];
    
    // 1. Parse Excel Data (Source of Truth)
    files.forEach(file => {
        let gender = file.toLowerCase().includes('female') ? 'Female' : 'Male';
        let levelMatch = file.match(/LEVEL (\d)/i);
        if (!levelMatch) return;
        let level = parseInt(levelMatch[1], 10);

        const workbook = xlsx.readFile(path.join(dir, file));
        const sheetName = workbook.SheetNames[0];
        const data = xlsx.utils.sheet_to_json(workbook.Sheets[sheetName]);

        let currentSequence = 'FC';

        data.forEach(row => {
            const keys = Object.keys(row);
            let seqKey = keys.find(k => k.toLowerCase().includes('sequence'));
            let setKey = keys.find(k => k.toLowerCase().includes('set') || k.toLowerCase().includes('track'));
            let typeKey = keys.find(k => k.toLowerCase() === 'type');
            let moveUpperKey = keys.find(k => k.toLowerCase().includes('upper'));
            let moveLowerKey = keys.find(k => k.toLowerCase().includes('lower'));
            let videoKey = keys.find(k => k.toLowerCase().includes('video') || k.toLowerCase().includes('link'));

            let sequence = seqKey ? String(row[seqKey] || '').trim() : '';
            let setTrack = setKey ? String(row[setKey] || '').trim() : '';
            let type = typeKey ? String(row[typeKey] || '').trim() : '';
            let moveUpper = moveUpperKey ? String(row[moveUpperKey] || '').trim() : '';
            let moveLower = moveLowerKey ? String(row[moveLowerKey] || '').trim() : '';
            let url = videoKey ? String(row[videoKey] || '').trim() : '';
            
            if (sequence) {
                currentSequence = sequence;
            } else {
                if (setTrack.includes('Set')) {
                    if (type === 'Isolate') currentSequence = 'FC';
                    if (type === 'Dynamic') currentSequence = 'CC';
                }
                if (setTrack.includes('Basic')) {
                    if (type === 'Isolate') currentSequence = 'MC';
                    if (type === 'Stretching') currentSequence = 'CD';
                }
            }
            
            let movementName = moveUpper || moveLower;
            if (!movementName || movementName.toLowerCase() === 'rest') return;

            excelItems.push({
                level,
                gender,
                sequence: currentSequence.toLowerCase(),
                set: setTrack,
                movement: movementName.toLowerCase().trim(),
                url: url.includes('http') ? url : null
            });
        });
    });

    // 2. Query Database
    const { rows: dbItems } = await client.query(`
        SELECT l.level_number as level, c.code as sequence, mi.set_name as set, 
               LOWER(TRIM(m.name)) as movement, mi.video_url_male, mi.video_url_female,
               m.video_url_male as global_male, m.video_url_female as global_female
        FROM dl_menu_items mi
        JOIN dl_levels l ON l.id = mi.level_id
        JOIN dl_categories c ON c.id = mi.category_id
        JOIN dl_movements m ON m.id = mi.movement_id
    `);

    // 3. Reconcile
    const report = {};
    for (let l = 1; l <= 6; l++) {
        report[l] = { 
            Male: { rows: 0, dbItems: 0, matched: 0, missing: 0, conflicts: 0, waitlist: 0 },
            Female: { rows: 0, dbItems: 0, matched: 0, missing: 0, conflicts: 0, waitlist: 0 }
        };
    }

    let globalConflicts = 0;
    let globalMatched = 0;
    let globalMissing = 0;
    let globalWaitlist = 0;
    let unexpectedDbRecords = 0;

    // Helper: Normalize youtube URLs (super basic for comparison)
    const normalizeUrl = (u) => {
        if (!u) return null;
        let t = u.trim().replace('http://', 'https://');
        return t;
    };

    excelItems.forEach(ex => {
        let st = report[ex.level][ex.gender];
        st.rows++;
        if (!ex.url) {
            st.waitlist++;
            globalWaitlist++;
        }

        // Find matching DB item
        const match = dbItems.find(db => 
            db.level === ex.level && 
            db.sequence === ex.sequence &&
            db.set === ex.set &&
            db.movement === ex.movement
        );

        if (!match) {
            st.missing++;
            globalMissing++;
            return;
        }

        // We count the DB item for the gender if the excel row exists
        st.dbItems++;

        let dbUrl = ex.gender === 'Male' ? match.video_url_male : match.video_url_female;
        
        let exUrlNorm = normalizeUrl(ex.url);
        let dbUrlNorm = normalizeUrl(dbUrl);

        if (exUrlNorm === dbUrlNorm) {
            st.matched++;
            globalMatched++;
        } else {
            // Mismatch
            st.conflicts++;
            globalConflicts++;
        }
    });

    console.log(JSON.stringify({report, globalMatched, globalMissing, globalConflicts, globalWaitlist}, null, 2));
    await client.end();
}

main().catch(console.error);
