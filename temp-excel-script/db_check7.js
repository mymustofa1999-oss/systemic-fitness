const { Client } = require('pg');

async function main() {
  const client = new Client({
    connectionString: "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=simple_protocol&statement_cache_capacity=0",
  });
  await client.connect();

  const res = await client.query(`
    SELECT level, count(*) FROM dl_movements GROUP BY level;
  `);
  console.table(res.rows);
  
  await client.end();
}

main().catch(console.error);
