const fs = require('fs');
let content = fs.readFileSync('src/app/(dashboard)/clients/page.tsx', 'utf8');

content = content.replace(
  'export default function ClientsPage() {',
  'export default function ClientClassificationPage({ params }: { params: { type: string } }) {'
);

content = content.replace(
  'Clients</h1>',
  'Client Classification</h1>'
);
content = content.replace(
  'Manage your clients, view their profiles, and track progress.</p>',
  'View {params.type.charAt(0).toUpperCase() + params.type.slice(1)} clients.</p>'
);

content = content.replace(
  'const { data, isLoading } = useClients({ page, limit: 10, search: debouncedSearch });',
  'const { data, isLoading } = useClients({ page, limit: 10, search: debouncedSearch, classification: params.type });'
);

const startIndex = content.indexOf('{/* Subscription Badge */}');
const endIndex = content.indexOf('{/* Status Badge */}');

if (startIndex !== -1 && endIndex !== -1) {
  const replacement = `{/* Classification Badge */}
                  <div className="hidden lg:flex items-center shrink-0 w-24">
                    <span className="px-3 py-1 rounded-full text-xs font-bold bg-indigo-100 text-indigo-700 uppercase tracking-wider">
                      {params.type}
                    </span>
                  </div>
                  `;
  content = content.substring(0, startIndex) + replacement + content.substring(endIndex);
}

fs.writeFileSync('src/app/(dashboard)/client-classification/[type]/page.tsx', content);
