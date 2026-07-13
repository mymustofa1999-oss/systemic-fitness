const { Client } = require('pg');

async function main() {
  const client = new Client({
    connectionString: "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=simple_protocol&statement_cache_capacity=0",
  });
  await client.connect();

  const res = await client.query(`
    SELECT m.name, m.video_url_male, m.video_url_female, mi.level_id
    FROM dl_movements m
    JOIN dl_menu_items mi ON mi.movement_id = m.id
    WHERE m.name ILIKE '%pull down-front lift%'
       OR m.name ILIKE '%arm swing-side lift%'
    LIMIT 10;
  `);
  console.log("Movements:");
  console.table(res.rows);
  
  await client.end();
}

main().catch(console.error);
