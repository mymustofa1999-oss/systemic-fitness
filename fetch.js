const url = 'https://systemic-fitness-production.up.railway.app';
const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNjQ2ZTRkZWItODk3Zi00NTgzLTlmOWEtMTJlMGY1M2EzNGI1IiwiZW1haWwiOiJhZG1pbkBzeXN0ZW1pYy5hcHAiLCJyb2xlIjoib3duZXIiLCJpc3MiOiJmaXRjb2FjaC1hcGkiLCJzdWIiOiI2NDZlNGRlYi04OTdmLTQ1ODMtOWY5YS0xMmUwZjUzYTM0YjUiLCJleHAiOjE3ODU2MzM5MjEsImlhdCI6MTc4MzA0MTkyMX0.x00aqorYnxPLGZBAKYe-H0QnAbm72gQ5XZEOIEuLQIc';

fetch(url + '/api/digital-library/categories/fc/menu?level=1', {
  headers: { 'Authorization': 'Bearer ' + token }
}).then(r => r.json()).then(d => console.log(JSON.stringify(d.data.slice(0, 2), null, 2))).catch(console.error);
