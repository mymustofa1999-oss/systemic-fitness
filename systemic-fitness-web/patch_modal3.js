const fs = require('fs');

let content = fs.readFileSync('src/components/shared/ClientFormModal.tsx', 'utf8');

content = content.replace(
`      } else {
        createClient(
          { full_name: fullName, email, password, phone: phone || undefined },`,
`      } else {
        createClient(
          { full_name: fullName, email, password, phone: phone || undefined, classification: classification || undefined },`);

fs.writeFileSync('src/components/shared/ClientFormModal.tsx', content);
console.log("Patched createClient in ClientFormModal");
