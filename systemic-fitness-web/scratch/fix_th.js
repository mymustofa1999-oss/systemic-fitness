const fs = require('fs');
let file = fs.readFileSync('src/app/(dashboard)/modul-card/page.tsx', 'utf8');

// Replace FEMALE and MALE TH headers
const oldHeaders = `<th className="px-4 py-3 font-semibold border-r border-slate-200">FEMALE</th>
                  <th className="px-4 py-3 font-semibold border-r border-slate-200">MALE</th>`;
const newHeaders = `<th className="px-4 py-3 font-semibold border-r border-slate-200">VIDEO LATIHAN</th>`;
if (file.includes('FEMALE</th>')) {
    file = file.replace(oldHeaders, newHeaders);
}

fs.writeFileSync('src/app/(dashboard)/modul-card/page.tsx', file);
console.log('Fixed TH');
