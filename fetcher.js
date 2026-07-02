const https = require('https');
const url = 'https://systemic-fitness-admin001.vercel.app/modul-card';

https.get(url, (res) => {
  let html = '';
  res.on('data', d => html += d);
  res.on('end', () => {
    const regex = /_next\/static\/chunks\/[^"']+/g;
    const matches = [...new Set(html.match(regex) || [])];
    if (matches.length > 0) {
      let completed = 0;
      let allText = '';
      matches.forEach(m => {
        https.get('https://systemic-fitness-admin001.vercel.app/' + m, (r) => {
          let text = '';
          r.on('data', d => text += d);
          r.on('end', () => {
            allText += text;
            completed++;
            if (completed === matches.length) {
              console.log('railway:', allText.includes('railway.app'));
              console.log('mandalika:', allText.includes('mandalikasolusi.co.id'));
            }
          });
        });
      });
    }
  });
});
