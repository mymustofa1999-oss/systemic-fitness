const fs = require('fs');

const path = 'src/app/(dashboard)/client-classification/[type]/page.tsx';
let content = fs.readFileSync(path, 'utf8');

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

// Replace Subscription Block
const subBlockRegex = /\{\/\* Subscription Badge \*\/\}.*?\) \: \(/s;
const subBlockReplace = `{/* Classification Badge */}
                <div className="hidden lg:flex items-center shrink-0 w-24">
                  <span className="px-2 py-0.5 rounded-md text-xs font-semibold bg-indigo-50 text-indigo-700 uppercase tracking-wider">
                    {params.type}
                  </span>
                </div>
                {/* Status Badge */}
                (`;

content = content.replace(subBlockRegex, subBlockReplace);

// We need to also replace the closing paren of `) : (` which comes after status
const statusBlockRegex = /<span className=\{cn\("px-2 py-0\.5 rounded-full text-xs font-medium capitalize", statusStyles\[client\.status\] \|\| "bg-slate-100 text-slate-500"\)\}>\s*\{client\.status\}\s*<\/span>\s*\)/s;
const statusBlockReplace = `<span className={cn("px-2 py-0.5 rounded-full text-xs font-medium capitalize", statusStyles[client.status] || "bg-slate-100 text-slate-500")}>
                      {client.status}
                    </span>`;
content = content.replace(statusBlockRegex, statusBlockReplace);

fs.writeFileSync(path, content);
console.log("Patched classification page");
