const url = 'https://systemic-fitness-production.up.railway.app';
fetch(url + '/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ email: 'admin@systemic.app', password: 'password123' })
}).then(r => r.json()).then(console.log).catch(console.error);
