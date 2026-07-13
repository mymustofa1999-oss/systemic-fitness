const { Client } = require('pg');

async function main() {
  const client = new Client({
    connectionString: "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=simple_protocol&statement_cache_capacity=0",
  });
  await client.connect();

  const res = await client.query(`
    SELECT mi.id, mi.body_part, m.name, m.body_part as m_body_part 
    FROM dl_menu_items mi
    JOIN dl_levels l ON mi.level_id = l.id
    JOIN dl_categories c ON mi.category_id = c.id
    LEFT JOIN dl_movements m ON mi.movement_id = m.id
    WHERE l.level_number = 3 AND c.code = 'fc'
    ORDER BY mi.sort_order;
  `);
  console.table(res.rows);
  
  await client.end();
}

main().catch(console.error);
