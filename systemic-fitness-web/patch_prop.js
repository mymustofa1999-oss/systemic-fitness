const fs = require('fs');

let content = fs.readFileSync('src/app/(dashboard)/clients/[id]/page.tsx', 'utf8');

content = content.replace(
    `<StaffCard customerId={params.id} staff={setup?.staff} profile={userResponse?.profile} />`,
    `<StaffCard customerId={params.id} staff={setup?.staff} profile={profile} />`
);

fs.writeFileSync('src/app/(dashboard)/clients/[id]/page.tsx', content);
console.log("Patched profile prop");
