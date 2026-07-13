const http = require('http');

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/digital-library/categories/fc/menu?level=3',
  method: 'GET'
};

const req = http.request(options, res => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    try {
      const parsed = JSON.parse(data);
      console.log(JSON.stringify(parsed.data.slice(0, 2), null, 2));
    } catch(e) {
      console.error(e);
      console.log(data);
    }
  });
});

req.on('error', error => {
  console.error(error);
});

req.end();
