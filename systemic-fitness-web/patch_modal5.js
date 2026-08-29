const fs = require('fs');

let content = fs.readFileSync('src/components/shared/ClientFormModal.tsx', 'utf8');

content = content.replace(
`      setStatus(client?.status || "active");
      setErrors([]);
    }
  }, [open, client]);`,
`      setStatus(client?.status || "active");
      setClassification((client as any)?.classification || "");
      setErrors([]);
    }
  }, [open, client]);`);

fs.writeFileSync('src/components/shared/ClientFormModal.tsx', content);
console.log("Patched useEffect in ClientFormModal");
