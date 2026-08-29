const fs = require('fs');

let page = fs.readFileSync('src/app/(dashboard)/modul-card/page.tsx', 'utf8');

// The table row part needs to render only one video column based on selectedGender.
const oldTDs = `{/* FEMALE */}
                          <td className="px-4 py-3 border-t border-slate-100">
                            { (row.video_url_female || row.movement?.video_url_female) && (
                              <div className="flex items-center gap-2">
                                <a
                                  href={row.video_url_female || row.movement.video_url_female}
                                  target="_blank"
                                  rel="noopener noreferrer"
                                  className="text-blue-500 hover:text-blue-600 transition-colors flex items-center gap-1 group"
                                >
                                  <Video className="h-4 w-4" />
                                  <span className="text-xs group-hover:underline">Play Video</span>
                                </a>
                                <button
                                  onClick={() => {
                                    setItemToEdit(row);
                                    setVideoModalUrl(row.video_url_female || row.movement.video_url_female);
                                  }}
                                  className="p-1.5 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                                  title="Edit Video URL"
                                >
                                  <Edit3 className="h-3.5 w-3.5" />
                                </button>
                              </div>
                            )}
                          </td>
                          {/* MALE */}
                          <td className="px-4 py-3 border-t border-slate-100">
                            { (row.video_url_male || row.movement?.video_url_male) && (
                              <div className="flex items-center gap-2">
                                <a
                                  href={row.video_url_male || row.movement.video_url_male}
                                  target="_blank"
                                  rel="noopener noreferrer"
                                  className="text-blue-500 hover:text-blue-600 transition-colors flex items-center gap-1 group"
                                >
                                  <Video className="h-4 w-4" />
                                  <span className="text-xs group-hover:underline">Play Video</span>
                                </a>
                                <button
                                  onClick={() => {
                                    setItemToEdit(row);
                                    setVideoModalUrl(row.video_url_male || row.movement.video_url_male);
                                  }}
                                  className="p-1.5 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                                  title="Edit Video URL"
                                >
                                  <Edit3 className="h-3.5 w-3.5" />
                                </button>
                              </div>
                            )}
                          </td>`;

const newTDs = `{/* SELECTED GENDER */}
                          <td className="px-4 py-3 border-t border-slate-100">
                            {selectedGender === 'Female' ? (
                                (row.video_url_female || row.movement?.video_url_female) && (
                                  <div className="flex items-center gap-2">
                                    <a
                                      href={row.video_url_female || row.movement.video_url_female}
                                      target="_blank"
                                      rel="noopener noreferrer"
                                      className="text-blue-500 hover:text-blue-600 transition-colors flex items-center gap-1 group"
                                    >
                                      <Video className="h-4 w-4" />
                                      <span className="text-xs group-hover:underline">Play Video</span>
                                    </a>
                                    <button
                                      onClick={() => {
                                        setItemToEdit(row);
                                        setVideoModalUrl(row.video_url_female || row.movement.video_url_female);
                                      }}
                                      className="p-1.5 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                                      title="Edit Video URL"
                                    >
                                      <Edit3 className="h-3.5 w-3.5" />
                                    </button>
                                  </div>
                                )
                            ) : (
                                (row.video_url_male || row.movement?.video_url_male) && (
                                  <div className="flex items-center gap-2">
                                    <a
                                      href={row.video_url_male || row.movement.video_url_male}
                                      target="_blank"
                                      rel="noopener noreferrer"
                                      className="text-blue-500 hover:text-blue-600 transition-colors flex items-center gap-1 group"
                                    >
                                      <Video className="h-4 w-4" />
                                      <span className="text-xs group-hover:underline">Play Video</span>
                                    </a>
                                    <button
                                      onClick={() => {
                                        setItemToEdit(row);
                                        setVideoModalUrl(row.video_url_male || row.movement.video_url_male);
                                      }}
                                      className="p-1.5 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                                      title="Edit Video URL"
                                    >
                                      <Edit3 className="h-3.5 w-3.5" />
                                    </button>
                                  </div>
                                )
                            )}
                          </td>`;

if (page.includes('{/* FEMALE */}')) {
    page = page.replace(oldTDs, newTDs);
    fs.writeFileSync('src/app/(dashboard)/modul-card/page.tsx', page);
    console.log('Fixed TDs');
}
