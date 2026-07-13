const { Client } = require('pg');

const client = new Client({
  connectionString: 'postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=simple_protocol&statement_cache_capacity=0',
});

async function main() {
  await client.connect();
  
  // Find user "ani"
  const userRes = await client.query(`SELECT id, full_name, email FROM users WHERE LOWER(full_name) LIKE '%ani%' OR LOWER(email) LIKE '%ani%'`);
  console.log("Users found:", userRes.rows);
  
  for (const user of userRes.rows) {
      console.log(`\nChecking data for user: ${user.full_name} (${user.id})`);
      
      const cardRes = await client.query(`SELECT id, level, status FROM trainer_cards WHERE customer_id = $1`, [user.id]);
      console.log("Trainer Cards:", cardRes.rows);
      
      const asmtRes = await client.query(`SELECT id, version, physical_status_level FROM assessments WHERE user_id = $1`, [user.id]);
      console.log("Assessments:", asmtRes.rows);
  }

  await client.end();
}

main().catch(console.error);
