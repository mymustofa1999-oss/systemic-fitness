const fs = require('fs');
let file = fs.readFileSync('src/app/(dashboard)/modul-card/page.tsx', 'utf8');

const regex = /<td className="px-4 py-3 border-r border-slate-200">\s*<div className="flex items-center justify-between gap-2">\s*<span className="font-medium text-slate-900">\{row\.movement\?\.name \? row\.movement\.name\.split\(" \| "\)\[0\]\.replace\(\/\\s\*\\\[L\\d\+\\\]\$\/, ""\) : ""\}<\/span>\s*\{ \(row\.video_url_female \|\| row\.movement\?\.video_url_female\) && \(\s*<button onClick=\{\(\) => setVideoModalUrl\(row\.video_url_female \|\| row\.movement\.video_url_female\)\} className="text-blue-500 hover:text-blue-700 focus:outline-none">\s*<Video className="w-4 h-4" \/>\s*<\/button>\s*\)\}\s*<\/div>\s*<\/td>\s*<td className="px-4 py-3 border-r border-slate-200">\s*<div className="flex items-center justify-between gap-2">\s*<span className="font-medium text-slate-900">\{row\.movement\?\.name \? \(row\.movement\.name\.split\(" \| "\)\.length > 1 \? row\.movement\.name\.split\(" \| "\)\[1\]\.replace\(\/\\s\*\\\[L\\d\+\\\]\$\/, ""\) : row\.movement\.name\.split\(" \| "\)\[0\]\.replace\(\/\\s\*\\\[L\\d\+\\\]\$\/, ""\)\) : ""\}<\/span>\s*\{ \(row\.video_url_male \|\| row\.movement\?\.video_url_male\) && \(\s*<button onClick=\{\(\) => setVideoModalUrl\(row\.video_url_male \|\| row\.movement\.video_url_male\)\} className="text-blue-500 hover:text-blue-700 focus:outline-none">\s*<Video className="w-4 h-4" \/>\s*<\/button>\s*\)\}\s*<\/div>\s*<\/td>/g;

const replacement = `<td className="px-4 py-3 border-r border-slate-200">
                        <div className="flex items-center justify-between gap-2">
                          <span className="font-medium text-slate-900">{row.movement?.name || ""}</span>
                        { selectedGender === 'Female' ? (
                          (row.video_url_female || row.movement?.video_url_female) && (
                            <button onClick={() => setVideoModalUrl(row.video_url_female || row.movement.video_url_female)} className="text-blue-500 hover:text-blue-700 focus:outline-none">
                              <Video className="w-4 h-4" />
                            </button>
                          )
                        ) : (
                          (row.video_url_male || row.movement?.video_url_male) && (
                            <button onClick={() => setVideoModalUrl(row.video_url_male || row.movement.video_url_male)} className="text-blue-500 hover:text-blue-700 focus:outline-none">
                              <Video className="w-4 h-4" />
                            </button>
                          )
                        )}
                        </div>
                      </td>`;

file = file.replace(regex, replacement);
fs.writeFileSync('src/app/(dashboard)/modul-card/page.tsx', file);
console.log('Fixed TDs!');
