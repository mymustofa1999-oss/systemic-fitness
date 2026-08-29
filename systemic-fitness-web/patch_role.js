const fs = require('fs');

const path = 'src/components/shared/ClientFormModal.tsx';
let content = fs.readFileSync(path, 'utf8');

if (!content.includes('useAuth')) {
  content = content.replace(
    'import { SearchableSelect } from "@/components/shared/SearchableSelect";',
    'import { SearchableSelect } from "@/components/shared/SearchableSelect";\nimport { useAuth } from "@/hooks/useAuth";'
  );
}

if (!content.includes('const { session } = useAuth()')) {
  content = content.replace(
    'const overlayRef = useRef<HTMLDivElement>(null);',
    'const overlayRef = useRef<HTMLDivElement>(null);\n  const { session } = useAuth();\n  const isAuthorized = session?.user?.role === "admin" || session?.user?.role === "owner" || session?.user?.role === "consultant";'
  );
}

const dropdownSearch = `              <SearchableSelect
                options={[
                  { value: "personal", label: "Personal" },
                  { value: "group", label: "Group" },
                  { value: "online", label: "Online" },
                ]}
                value={classification}
                onChange={setClassification}
                placeholder="Select classification..."
              />`;

const dropdownReplace = `              <SearchableSelect
                options={[
                  { value: "personal", label: "Personal" },
                  { value: "group", label: "Group" },
                  { value: "online", label: "Online" },
                ]}
                value={classification}
                onChange={setClassification}
                placeholder="Select classification..."
                disabled={!isAuthorized}
              />`;

content = content.replace(dropdownSearch, dropdownReplace);

fs.writeFileSync(path, content);
console.log("Patched roles");
