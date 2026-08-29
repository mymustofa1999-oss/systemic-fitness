const fs = require('fs');
let content = fs.readFileSync('src/app/(dashboard)/clients/page.tsx', 'utf8');

// Export default function changes
content = content.replace(
  'export default function ClientsPage() {',
  'export default function ClientClassificationPage({ params: pageParams }: { params: { type: string } }) {'
);

// Page title changes
content = content.replace(
  'Clients</h1>',
  'Client Classification</h1>'
);
content = content.replace(
  'Manage your clients, view their profiles, and track progress.</p>',
  'View {pageParams.type.charAt(0).toUpperCase() + pageParams.type.slice(1)} clients.</p>'
);

// Add Classification parameter to useClients
content = content.replace(
  'const params: Record<string, unknown> = { page, limit: 20, search };',
  'const params: Record<string, unknown> = { page, limit: 20, search, classification: pageParams.type };'
);

const startIndex = content.indexOf('{/* Subscription Badge */}');
const endIndex = content.indexOf('{/* Status Badge */}');

if (startIndex !== -1 && endIndex !== -1) {
  const replacement = `{/* Classification Badge */}
                  <div className="hidden lg:flex items-center shrink-0 w-24">
                    <span className="px-3 py-1 rounded-full text-xs font-bold bg-indigo-100 text-indigo-700 uppercase tracking-wider">
                      {pageParams.type}
                    </span>
                  </div>
                  `;
  content = content.substring(0, startIndex) + replacement + content.substring(endIndex);
}

fs.writeFileSync('src/app/(dashboard)/client-classification/[type]/page.tsx', content);
