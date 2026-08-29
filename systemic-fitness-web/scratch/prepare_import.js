const xlsx = require('xlsx');
const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

const DB_URL = "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:5432/postgres";

async function main() {
    const client = new Client({ connectionString: DB_URL });
    await client.connect();

    // 1. Ensure 'cd' category exists
    await client.query(`INSERT INTO dl_categories (code, name, created_at, updated_at) VALUES ('cd', 'Cool Down', now(), now()) ON CONFLICT (code) DO NOTHING`);

    // 2. Fetch lookups
    const { rows: levels } = await client.query('SELECT id, level_number FROM dl_levels');
    const { rows: categories } = await client.query('SELECT id, code FROM dl_categories');
    
    // We will build a map of existing movements. 
    // We need to keep this updated if we insert new ones.
    const { rows: dbMovements } = await client.query('SELECT id, name FROM dl_movements');
    const movementMap = new Map();
    dbMovements.forEach(m => movementMap.set(m.name.toLowerCase().trim(), m.id));

    const getMovementId = async (name) => {
        let cleanName = name.trim();
        let key = cleanName.toLowerCase();
        if (movementMap.has(key)) return movementMap.get(key);
        
        // Insert
        let res = await client.query(`INSERT INTO dl_movements (name, body_part, created_at, updated_at) VALUES ($1, 'whole body', now(), now()) RETURNING id`, [cleanName]);
        let newId = res.rows[0].id;
        movementMap.set(key, newId);
        return newId;
    };

    const dir = 'c:/Users/ITBDG/Documents/SystemicFitness-Handover/CLEAN/systemic-fitness-api/new movment';
    const files = fs.readdirSync(dir).filter(f => f.endsWith('.xlsx'));

    let allItems = [];

    files.forEach(file => {
        let gender = file.toLowerCase().includes('female') ? 'Female' : 'Male';
        let levelMatch = file.match(/LEVEL (\d)/i);
        if (!levelMatch) return;
        let level = parseInt(levelMatch[1], 10);

        const workbook = xlsx.readFile(path.join(dir, file));
        const sheetName = workbook.SheetNames[0];
        const data = xlsx.utils.sheet_to_json(workbook.Sheets[sheetName]);

        let currentSequence = 'FC'; // Default fallback
        let sortOrder = 0;

        data.forEach(row => {
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
            
            // Infer Sequence if missing (e.g. Level 3 Female)
            if (sequence) {
                currentSequence = sequence;
            } else {
                // Infer from Set/Track or Type if possible
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

            if (!url.includes('http')) {
                url = null; // waitlist or missing
            }

            allItems.push({
                level,
                gender,
                sequence: currentSequence,
                set: setTrack,
                type,
                section,
                movement: movementName,
                url,
                sortOrder: sortOrder++
            });
        });
    });

    console.log(`Parsed ${allItems.length} valid rows from Excel.`);

    // 3. Upsert into dl_menu_items
    // We group by: level_id, category_id, set_name, movement_id
    // Wait, the user wants ONE dl_menu_items record to hold both video_url_male and video_url_female?
    // "Gunakan video override pada dl_menu_items. Gunakan: video_url_male, video_url_female ... Jangan duplicate menu item jika record yang sama sudah ada."

    // So we group by Level, Sequence(Category), Set, Movement
    let menuMap = new Map(); // key -> { ..., maleUrl, femaleUrl }
    
    for (let item of allItems) {
        let levelObj = levels.find(l => l.level_number === item.level);
        let catCode = item.sequence.toLowerCase();
        let catObj = categories.find(c => c.code === catCode);
        
        if (!levelObj || !catObj) {
            console.log(`Skipping unknown level/cat: Level ${item.level}, Cat ${item.sequence}`);
            continue;
        }

        let movId = await getMovementId(item.movement);
        let key = `${levelObj.id}_${catObj.id}_${item.set}_${movId}`;

        if (!menuMap.has(key)) {
            menuMap.set(key, {
                level_id: levelObj.id,
                category_id: catObj.id,
                set_name: item.set,
                movement_id: movId,
                group_type: item.type,
                section: item.section,
                sort_order: item.sortOrder,
                video_url_male: null,
                video_url_female: null
            });
        }
        
        let existing = menuMap.get(key);
        if (item.gender === 'Male' && item.url) existing.video_url_male = item.url;
        if (item.gender === 'Female' && item.url) existing.video_url_female = item.url;
    }

    console.log(`Compacted to ${menuMap.size} unique menu items.`);

    // Before inserting, let's just clear dl_menu_items?
    // User said: "Jangan menghapus existing data... Jangan DROP/TRUNCATE".
    // "JANGAN EXECUTE jika ada ambiguity."
    // Let's do an UPSERT.
    // constraint on dl_menu_items? Does it have a unique constraint?
    
    const { rows: constraints } = await client.query(`
        SELECT conname, pg_get_constraintdef(c.oid) 
        FROM pg_constraint c 
        JOIN pg_class t ON c.conrelid = t.oid 
        WHERE t.relname = 'dl_menu_items' AND contype = 'u'
    `);
    console.log('Unique constraints on dl_menu_items:', constraints);
    
    fs.writeFileSync('import_report.json', JSON.stringify([...menuMap.values()], null, 2));

    await client.end();
}

main().catch(console.error);
