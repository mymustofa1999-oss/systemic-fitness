const fs = require('fs');
const { Client } = require('pg');

const DB_URL = "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:5432/postgres";

async function main() {
    const data = JSON.parse(fs.readFileSync('import_report.json', 'utf8'));

    const client = new Client({ connectionString: DB_URL });
    await client.connect();

    try {
        await client.query('BEGIN');
        
        let inserted = 0;
        let updated = 0;

        // Ensure dl_menu_items has the correct UNIQUE constraint to upsert properly
        // Or we can manually UPSERT by checking.
        // Wait, there is no unique constraint on (level_id, category_id, set_name, movement_id)!
        // If we don't have a unique constraint, we can just delete old data and insert new data for these levels?
        // NO! "Jangan DROP/TRUNCATE database... Jangan menghapus existing data."
        
        // We will manually query if it exists.
        for (let item of data) {
            const { level_id, category_id, set_name, movement_id, group_type, body_part, sort_order, video_url_male, video_url_female } = item;
            
            const check = await client.query(
                `SELECT id, video_url_male, video_url_female FROM dl_menu_items 
                 WHERE level_id = $1 AND category_id = $2 AND set_name = $3 AND movement_id = $4`,
                [level_id, category_id, set_name, movement_id]
            );

            let bp = body_part || 'whole body';
            if (check.rows.length > 0) {
                // Update
                const existing = check.rows[0];
                let newMale = video_url_male || existing.video_url_male;
                let newFemale = video_url_female || existing.video_url_female;
                
                await client.query(
                    `UPDATE dl_menu_items 
                     SET video_url_male = $1, video_url_female = $2, group_type = $3, body_part = $4, sort_order = $5, updated_at = now()
                     WHERE id = $6`,
                    [newMale, newFemale, group_type, bp, sort_order, existing.id]
                );
                updated++;
            } else {
                // Insert
                await client.query(
                    `INSERT INTO dl_menu_items 
                     (level_id, category_id, set_name, movement_id, group_type, body_part, sort_order, video_url_male, video_url_female, created_at, updated_at) 
                     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, now(), now())`,
                    [level_id, category_id, set_name, movement_id, group_type, bp, sort_order, video_url_male, video_url_female]
                );
                inserted++;
            }
        }

        await client.query('COMMIT');
        console.log(`EXECUTION SUCCESS: ${inserted} inserted, ${updated} updated.`);

    } catch (e) {
        await client.query('ROLLBACK');
        console.error('ROLLBACK', e);
    } finally {
        await client.end();
    }
}

main().catch(console.error);
