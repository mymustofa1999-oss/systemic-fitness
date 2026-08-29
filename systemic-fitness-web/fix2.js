const fs = require('fs');
let code = fs.readFileSync('src/app/(dashboard)/clients/[id]/page.tsx', 'utf8');

code = code.replace(/function StaffCard\(\{\, profile\}: \{\, profile: any\}\)/g, 'function StaffCard({ customerId, staff, profile }: { customerId: string; staff: any; profile: any })');

fs.writeFileSync('src/app/(dashboard)/clients/[id]/page.tsx', code, 'utf8');
console.log('Fixed StaffCard signature');

