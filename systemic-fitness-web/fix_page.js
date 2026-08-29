const fs = require('fs');
let content = fs.readFileSync('src/app/(dashboard)/clients/page.tsx', 'utf8');

// Export default function changes
content = content.replace(
  'export default function ClientsPage() {',
  'export default function ClientClassificationPage({ params }: { params: { type: string } }) {'
);

// Page title changes
content = content.replace(
  'Clients</h1>',
  'Client Classification</h1>'
);
content = content.replace(
  'Manage your clients, view their profiles, and track progress.</p>',
  'View {params.type.charAt(0).toUpperCase() + params.type.slice(1)} clients.</p>'
);

// Add Classification parameter to useClients
content = content.replace(
  'const { data, isLoading } = useClients({ page, limit: 10, search: debouncedSearch });',
  'const { data, isLoading } = useClients({ page, limit: 10, search: debouncedSearch, classification: params.type });'
);

const rx = /\{\/\* Subscription Badge \*\/\}\s*\{sub \? \([\s\S]*?\) \: \([\s\S]*?\}\s*\)/m;
const match = content.match(rx);
if (match) {
  const replaceStr = `{/* Classification Badge */}
                  <div className="hidden lg:flex items-center shrink-0 w-24 justify-center">
                    <span className="px-3 py-1 rounded-full text-xs font-bold bg-indigo-100 text-indigo-700 uppercase tracking-wider">
                      {params.type}
                    </span>
                  </div>`;
  content = content.replace(rx, replaceStr);
} else {
  console.log("Could not find subscription badge regex match");
}

fs.writeFileSync('src/app/(dashboard)/client-classification/[type]/page.tsx', content);
console.log("Fixed page");
