const { Client } = require('pg');
require('dotenv').config();

// Try to use DATABASE_URL from .env or fallback
const dbUrl = process.env.DATABASE_URL || 'postgres://fitcoach:password@localhost:5432/fitcoach';
const client = new Client({ connectionString: dbUrl });

async function run() {
  try {
    await client.connect();
    
    const version = await client.query('SELECT version();');
    console.log('--- 1. PostgreSQL version ---');
    console.log(version.rows[0].version);

    const indexes = await client.query(\
        SELECT indexname, indexdef 
        FROM pg_indexes 
        WHERE tablename = 'dl_menu_items'
    \);
    console.log('\n--- 2. Current indexes on dl_menu_items ---');
    console.table(indexes.rows);

    const constraints = await client.query(\
        SELECT conname, pg_get_constraintdef(c.oid) 
        FROM pg_constraint c 
        JOIN pg_class t ON c.conrelid = t.oid 
        WHERE t.relname = 'dl_menu_items'
    \);
    console.log('\n--- 3. Existing constraints on dl_menu_items ---');
    console.table(constraints.rows);

    const nulls = await client.query(\
        SELECT column_name, is_nullable 
        FROM information_schema.columns 
        WHERE table_name = 'dl_menu_items' AND column_name IN ('set_name', 'group_type')
    \);
    console.log('\n--- 5. Check whether set_name or group_type can be NULL ---');
    console.table(nulls.rows);

    const count = await client.query('SELECT count(*) FROM dl_menu_items;');
    console.log('\n--- 6. Confirm exact row count ---');
    console.log('Count:', count.rows[0].count);

    const dups = await client.query(\
        SELECT category_id, level_id, target_gender, set_name, group_type, movement_id, COUNT(*) 
        FROM dl_menu_items 
        GROUP BY category_id, level_id, target_gender, set_name, group_type, movement_id 
        HAVING COUNT(*) > 1
    \);
    console.log('\n--- 4 & 7. Duplicate logical identities ---');
    console.log('Duplicates found:', dups.rowCount);
    if (dups.rowCount > 0) {
        console.table(dups.rows);
    }

  } catch(e) {
    console.error(e);
  } finally {
    await client.end();
  }
}
run();

