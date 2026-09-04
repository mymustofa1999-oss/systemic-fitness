const fs = require('fs');
const path = 'systemic-fitness-client-web/src/app/(app)/layout.tsx';
let content = fs.readFileSync(path, 'utf8');

content = content.replace(
  '<div>\n                <label className="block text-xs font-bold text-slate-600 dark:text-slate-400 uppercase tracking-wider mb-1.5">\n                  {t.dob}',
  '<div className="grid grid-cols-1 md:grid-cols-2 gap-4">\n              <div>\n                <label className="block text-xs font-bold text-slate-600 dark:text-slate-400 uppercase tracking-wider mb-1.5">\n                  {t.dob}'
);

content = content.replace(
  '                </select>\n              </div>\n\n              <div>\n                <label className="block text-xs font-bold text-slate-600 dark:text-slate-400 uppercase tracking-wider mb-1.5">\n                  {t.weight}',
  '                </select>\n              </div>\n              </div>\n\n              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">\n              <div>\n                <label className="block text-xs font-bold text-slate-600 dark:text-slate-400 uppercase tracking-wider mb-1.5">\n                  {t.weight}'
);

content = content.replace(
  '                />\n              </div>\n\n              <div>\n                <label className="block text-xs font-bold text-slate-600 dark:text-slate-400 uppercase tracking-wider mb-1.5">\n                  {t.regional}',
  '                />\n              </div>\n              </div>\n\n              <div>\n                <label className="block text-xs font-bold text-slate-600 dark:text-slate-400 uppercase tracking-wider mb-1.5">\n                  {t.regional}'
);

fs.writeFileSync(path, content);
