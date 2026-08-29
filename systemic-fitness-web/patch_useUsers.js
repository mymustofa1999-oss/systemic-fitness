const fs = require('fs');

const path = 'src/hooks/useUsers.ts';
let content = fs.readFileSync(path, 'utf8');

const searchCreate = `    return useMutation({
    mutationFn: (data: { full_name: string; email: string; password: string; phone?: string }) =>
      apiPost("/api/auth/register", { ...data, role: "client" }),
    onSuccess: () => {`;

const replaceCreate = `    return useMutation({
    mutationFn: async (data: { full_name: string; email: string; password: string; phone?: string; classification?: string }) => {
      // 1. Create client
      const res = await apiPost<{ user: { id: string } }>("/api/auth/register", { 
        full_name: data.full_name,
        email: data.email,
        password: data.password,
        phone: data.phone,
        role: "client"
      });
      
      // 2. Update classification if provided
      if (data.classification && res.user?.id) {
        await apiPut(\`/api/users/\${res.user.id}\`, { classification: data.classification });
      }
      return res;
    },
    onSuccess: () => {`;

content = content.replace(searchCreate, replaceCreate);

// wait, I also need to make sure we import apiPut in useUsers.ts if not already!
// I see it's imported at the top.

fs.writeFileSync(path, content);
console.log("Patched useUsers.ts");
