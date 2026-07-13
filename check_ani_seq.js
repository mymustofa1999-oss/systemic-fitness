const { Client } = require('pg');

const client = new Client({
  connectionString: 'postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=simple_protocol&statement_cache_capacity=0',
});

async function main() {
  await client.connect();
  const cardId = 'f21be4bc-7873-4e51-8462-2eca43a4dd60';
  const seqRes = await client.query(`SELECT id, duration, program_category_id FROM trainer_card_sequences WHERE trainer_card_id = $1`, [cardId]);
  console.log("Sequences:", seqRes.rows);
  await client.end();
}

main().catch(console.error);
