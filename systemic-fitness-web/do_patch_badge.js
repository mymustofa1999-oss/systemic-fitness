const fs = require('fs');
let code = fs.readFileSync('src/app/(dashboard)/clients/page.tsx', 'utf8');

const repl = fs.readFileSync('patch_badge.txt', 'utf8');
const regex = /\{\/\* Status Badge \*\/\}/m;
code = code.replace(regex, repl);

fs.writeFileSync('src/app/(dashboard)/clients/page.tsx', code, 'utf8');
console.log('Patched clients badge');

