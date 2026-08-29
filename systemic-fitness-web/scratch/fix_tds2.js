const fs = require('fs');
let file = fs.readFileSync('src/app/(dashboard)/modul-card/page.tsx', 'utf8');

const oldTds = `                      <td className="px-4 py-3 border-r border-slate-200">
                        <div className="flex items-center justify-between gap-2">
                          <span className="font-medium text-slate-900">{row.movement?.name ? row.movement.name.split(" | ")[0].replace(/\\s*\\[L\\d+\\]$/, "") : ""}</span>
                        { (row.video_url_female || row.movement?.video_url_female) && (
                          <button onClick={() => setVideoModalUrl(row.video_url_female || row.movement.video_url_female)} className="text-blue-500 hover:text-blue-700 focus:outline-none">
                              <Video className="w-4 h-4" />
                            </button>
                          )}
                        </div>
                      </td>
                      <td className="px-4 py-3 border-r border-slate-200">
                        <div className="flex items-center justify-between gap-2">
                          <span className="font-medium text-slate-900">{row.movement?.name ? row.movement.name.split(" | ")[0].replace(/\\s*\\[L\\d+\\]$/, "") : ""}</span>
                        { (row.video_url_male || row.movement?.video_url_male) && (
                          <button onClick={() => setVideoModalUrl(row.video_url_male || row.movement.video_url_male)} className="text-blue-500 hover:text-blue-700 focus:outline-none">
                              <Video className="w-4 h-4" />
                            </button>
                          )}
                        </div>
                      </td>`;

const newTds = `                      <td className="px-4 py-3 border-r border-slate-200">
                        <div className="flex items-center justify-between gap-2">
                          <span className="font-medium text-slate-900">{row.movement?.name ? row.movement.name.split(" | ")[0].replace(/\\s*\\[L\\d+\\]$/, "") : ""}</span>
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

// Because formatting might differ, a regex approach might be better.
// But let's try direct replace first.

if (file.includes('video_url_female')) {
    let parts = file.split('                      <td className="px-4 py-3 border-r border-slate-200">');
    // ... This is getting too complex to blind-replace.
}
