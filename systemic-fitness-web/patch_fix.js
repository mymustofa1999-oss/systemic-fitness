const fs = require('fs');
let code = fs.readFileSync('src/app/(dashboard)/clients/[id]/page.tsx', 'utf8');

code = code.replace(/<\/td>\r?\n\s*<\/tr>\r?\n<\/td>\r?\n\s*<\/tr>/g, '</td>\n          </tr>');

fs.writeFileSync('src/app/(dashboard)/clients/[id]/page.tsx', code, 'utf8');
console.log('Fixed syntax');

