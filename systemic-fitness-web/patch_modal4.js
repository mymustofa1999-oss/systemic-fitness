const fs = require('fs');

let content = fs.readFileSync('src/components/shared/ClientFormModal.tsx', 'utf8');

content = content.replace(
`        updateClient(
          { id: client.id, data: { full_name: fullName, phone: phone || undefined, status } },
          { onSuccess: () => onClose() }
        );
      } else {
        createClient(
          { full_name: fullName, email, password, phone: phone || undefined },
          { onSuccess: () => onClose() }
        );`,
`        updateClient(
          { id: client.id, data: { full_name: fullName, phone: phone || undefined, status, classification: classification || undefined } },
          { onSuccess: () => onClose() }
        );
      } else {
        createClient(
          { full_name: fullName, email, password, phone: phone || undefined },
          { 
            onSuccess: (res: any) => {
              // If classification was selected, apply it immediately after creation
              if (classification && res?.data?.user?.id) {
                updateClient({ id: res.data.user.id, data: { classification } });
              }
              onClose();
            } 
          }
        );`);

fs.writeFileSync('src/components/shared/ClientFormModal.tsx', content);
console.log("Patched createClient and updateClient in ClientFormModal");
