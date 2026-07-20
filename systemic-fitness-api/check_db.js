const { Client } = require('pg');
const client = new Client({ user: 'fitcoach', host: 'localhost', database: 'fitcoach', password: 'password', port: 5432 });
client.connect().then(() => client.query("SELECT name, body_part, category FROM movements WHERE name ILIKE '%Arm Rotation-Step Touch%'"))
.then(res => {
    console.log(res.rows);
    client.end();
}).catch(console.error);
