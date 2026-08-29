const fs = require('fs');
let code = fs.readFileSync('src/app/(dashboard)/clients/[id]/page.tsx', 'utf8');

// 1. Pass profile to StaffCard
code = code.replace(/<StaffCard customerId=\{params.id\} staff=\{setup\?\.staff\} \/>/g, '<StaffCard customerId={params.id} staff={setup?.staff} profile={profile} />');

// 2. Add profile and updateUser to StaffCard signature
code = code.replace(/function StaffCard\(\{(.*?)\}: \{(.*?)\}\) \{/, 'function StaffCard({, profile}: {, profile: any}) {\n  const { mutate: updateUser, isPending: updatingUser } = useUpdateUser();');

// 3. Fix isAdmin
code = code.replace(/isSuperAdmin/g, 'isAdmin');

fs.writeFileSync('src/app/(dashboard)/clients/[id]/page.tsx', code, 'utf8');
console.log('Fixed StaffCard props');

