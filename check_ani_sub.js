const { Client } = require('pg');

const client = new Client({
  connectionString: 'postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=simple_protocol&statement_cache_capacity=0',
});

async function main() {
  await client.connect();
  const userRes = await client.query(`SELECT id, full_name, email FROM users WHERE LOWER(full_name) = 'ani'`);
  const user = userRes.rows[0];
  
  if (user) {
      console.log(`Checking subscriptions for ${user.full_name} (${user.id})`);
      const subRes = await client.query(`SELECT s.id, s.plan_id, s.status, pp.tier FROM subscriptions s JOIN payment_plans pp ON pp.id = s.plan_id WHERE s.user_id = $1`, [user.id]);
      console.log("Subscriptions:", subRes.rows);
  }
  await client.end();
}

main().catch(console.error);
