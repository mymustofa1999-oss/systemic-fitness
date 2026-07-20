const { Client } = require('pg');
const client = new Client({ connectionString: 'postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=simple_protocol&statement_cache_capacity=0' });
client.connect().then(() => client.query("SELECT name, body_part, category FROM movements WHERE name ILIKE '%Arm Rotation-Step Touch%'"))
.then(res => {
    console.log(res.rows);
    client.end();
}).catch(console.error);
