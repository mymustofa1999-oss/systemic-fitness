const fs = require('fs');
let code = fs.readFileSync('src/app/(dashboard)/modul-card/page.tsx', 'utf8');

// 1. Swap hook
code = code.replace(/useUpdateDLMovement/g, 'useUpdateDLMenuItem');

// 2. Add Gender Toggle UI
const genderToggleHtml = `
      <div className="flex justify-between items-center mb-4">
        <div className="flex bg-slate-100 p-1 rounded-lg w-fit">
          {['Male', 'Female'].map((g) => (
            <button
              key={g}
              onClick={() => setSelectedGender(g as 'Male' | 'Female')}
              className={cn(
                "px-6 py-2 rounded-md text-sm font-medium transition-all",
                selectedGender === g
                  ? "bg-white text-slate-900 shadow-sm"
                  : "text-slate-500 hover:text-slate-700"
              )}
            >
              {g}
            </button>
          ))}
        </div>
      </div>
`;
code = code.replace(/(<\/div>\s*<div className="bg-white rounded-2xl)/, genderToggleHtml + '\n$1');

// 3. Fix the Table Headers
code = code.replace(/<th className="px-4 py-3 font-semibold border-r border-slate-200">FEMALE<\/th>\s*<th className="px-4 py-3 font-semibold border-r border-slate-200">MALE<\/th>/g, 
'<th className="px-4 py-3 font-semibold border-r border-slate-200 text-center">MOVEMENT & VIDEO ({selectedGender})</th>');

// 4. Fix the Table Body Cells
const oldCellsRegex = /<td className="px-4 py-3 border-r border-slate-200">[\s\S]*?<div className="flex items-center justify-between gap-2">[\s\S]*?<span className="font-medium text-slate-900">\{row\.movement\?\.name \? row\.movement\.name\.split\(" \| "\)\[0\]\.replace\(\/\\s\*\\\[L\\d\+\\\]\$\/, ""\) : ""\}<\/span>[\s\S]*?\{row\.movement\?\.video_url_female && \([\s\S]*?<button onClick=\{\(\) => setVideoModalUrl\(row\.movement\.video_url_female\)\} className="text-blue-500 hover:text-blue-700 focus:outline-none">[\s\S]*?<Video className="w-4 h-4" \/>[\s\S]*?<\/button>[\s\S]*?\)[\s\S]*?<\/div>[\s\S]*?<\/td>[\s\S]*?<td className="px-4 py-3 border-r border-slate-200">[\s\S]*?<div className="flex items-center justify-between gap-2">[\s\S]*?<span className="font-medium text-slate-900">\{row\.movement\?\.name \? \(row\.movement\.name\.split\(" \| "\)\.length > 1 \? row\.movement\.name\.split\(" \| "\)\[1\]\.replace\(\/\\s\*\\\[L\\d\+\\\]\$\/, ""\) : row\.movement\.name\.split\(" \| "\)\[0\]\.replace\(\/\\s\*\\\[L\\d\+\\\]\$\/, ""\)\) : ""\}<\/span>[\s\S]*?\{row\.movement\?\.video_url_male && \([\s\S]*?<button onClick=\{\(\) => setVideoModalUrl\(row\.movement\.video_url_male\)\} className="text-blue-500 hover:text-blue-700 focus:outline-none">[\s\S]*?<Video className="w-4 h-4" \/>[\s\S]*?<\/button>[\s\S]*?\)[\s\S]*?<\/div>[\s\S]*?<\/td>/m;

const newCellHtml = `
                    <td className="px-4 py-3 border-r border-slate-200">
                      <div className="flex items-center justify-between gap-2">
                        <span className="font-medium text-slate-900">{row.movement?.name ? row.movement.name.replace(/\\s*\\[L\\d+\\]$/, "") : ""}</span>
                        {(selectedGender === 'Male' ? row.video_url_male : row.video_url_female) ? (
                          <button onClick={() => setVideoModalUrl(selectedGender === 'Male' ? row.video_url_male : row.video_url_female)} className="text-blue-500 hover:text-blue-700 focus:outline-none" title="Tonton Video">
                            <Video className="w-4 h-4" />
                          </button>
                        ) : (
                          <span className="text-xs text-slate-400 italic">Waitlist</span>
                        )}
                      </div>
                    </td>
`;
code = code.replace(oldCellsRegex, newCellHtml);

// 5. Clear Video Button & Delete fix
const editDeleteButtonsRegex = /<td className="px-4 py-3 text-center align-top whitespace-nowrap">[\s\S]*?<button[\s\S]*?onClick=\{\(\) => setItemToEdit\(row\)\}[\s\S]*?className="p-1.5 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-md transition-colors mr-1"[\s\S]*?title="Edit URL Video"[\s\S]*?>[\s\S]*?<Pencil className="h-4 w-4" \/>[\s\S]*?<\/button>[\s\S]*?<button[\s\S]*?onClick=\{\(\) => setItemToDelete\(row\)\}[\s\S]*?className="p-1.5 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-md transition-colors"[\s\S]*?title="Hapus dari Modul"[\s\S]*?>[\s\S]*?<Trash2 className="h-4 w-4" \/>[\s\S]*?<\/button>[\s\S]*?<\/td>/m;

const newEditDeleteButtonsHtml = `
                    <td className="px-4 py-3 text-center align-top whitespace-nowrap flex justify-center items-center gap-1">
                      <button
                        onClick={() => setItemToEdit(row)}
                        className="p-1.5 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-md transition-colors"
                        title="Edit URL Video"
                      >
                        <Pencil className="h-4 w-4" />
                      </button>
                      <button
                        onClick={async () => {
                          if (confirm('Clear video override untuk ' + selectedGender + '?')) {
                            await updateMovementMutation.mutateAsync({
                              id: row.id,
                              data: {
                                video_url_male: selectedGender === 'Male' ? null : row.video_url_male,
                                video_url_female: selectedGender === 'Female' ? null : row.video_url_female
                              }
                            });
                          }
                        }}
                        className="p-1.5 text-slate-400 hover:text-amber-600 hover:bg-amber-50 rounded-md transition-colors"
                        title="Clear Video"
                      >
                        <X className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() => setItemToDelete(row)}
                        className="p-1.5 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-md transition-colors"
                        title="Hapus dari Modul"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </td>
`;
code = code.replace(editDeleteButtonsRegex, newEditDeleteButtonsHtml);

// 6. Delete Confirm Dialog
code = code.replace(/await deleteMutation\.mutateAsync\(\{[\s\S]*?level_id: itemToDelete\.level_id,[\s\S]*?movement_id: itemToDelete\.movement_id[\s\S]*?\}\);/m, 'await deleteMutation.mutateAsync(itemToDelete.id);');

// 7. Edit Video Modal 
code = code.replace(/<EditVideoModal[\s\S]*?onSave=\{async \(femaleUrl, maleUrl\) => \{[\s\S]*?await updateMovementMutation\.mutateAsync\(\{[\s\S]*?id: itemToEdit\.movement_id,[\s\S]*?data: \{[\s\S]*?video_url_female: femaleUrl,[\s\S]*?video_url_male: maleUrl[\s\S]*?\}[\s\S]*?\}\);/m, 
`<EditVideoModal
          item={itemToEdit}
          selectedGender={selectedGender}
          onClose={() => setItemToEdit(null)}
          onSave={async (url: string) => {
            await updateMovementMutation.mutateAsync({
              id: itemToEdit.id,
              data: {
                video_url_male: selectedGender === 'Male' ? url : itemToEdit.video_url_male,
                video_url_female: selectedGender === 'Female' ? url : itemToEdit.video_url_female
              }
            });`);

// 8. Replace EditVideoModal definition
const editModalDefRegex = /function EditVideoModal\(\{ item, onClose, onSave, isLoading \}: \{ item: any, onClose: \(\) => void, onSave: \(f: string, m: string\) => void, isLoading: boolean \}\) \{[\s\S]*?const \[fUrl, setFUrl\] = useState\(item\?\.movement\?\.video_url_female \|\| ""\);[\s\S]*?const \[mUrl, setMUrl\] = useState\(item\?\.movement\?\.video_url_male \|\| ""\);[\s\S]*?return \([\s\S]*?<div[\s\S]*?Edit Video URL[\s\S]*?<button[\s\S]*?<\/button>[\s\S]*?<\/div>[\s\S]*?<div[\s\S]*?Video URL \(Female\)[\s\S]*?<\/div>[\s\S]*?<div[\s\S]*?Video URL \(Male\)[\s\S]*?<\/div>[\s\S]*?<\/div>[\s\S]*?<div[\s\S]*?Batal<\/button>[\s\S]*?<button onClick=\{\(\) => onSave\(fUrl, mUrl\)\}/m;

const newEditModalDef = `function EditVideoModal({ item, selectedGender, onClose, onSave, isLoading }: { item: any, selectedGender: string, onClose: () => void, onSave: (url: string) => void, isLoading: boolean }) {
  const [url, setUrl] = useState(selectedGender === 'Male' ? (item?.video_url_male || "") : (item?.video_url_female || ""));

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm">
      <div className="bg-white rounded-2xl shadow-xl w-full max-w-md overflow-hidden flex flex-col">
        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50">
          <h3 className="font-semibold text-slate-800">Edit Video URL ({selectedGender})</h3>
          <button onClick={onClose} className="p-1 text-slate-400 hover:text-slate-600 rounded-lg hover:bg-slate-200/50">
            <X className="w-5 h-5" />
          </button>
        </div>
        <div className="p-6 space-y-4 flex-1 overflow-y-auto">
          <p className="text-sm font-medium text-slate-700 bg-slate-100 p-3 rounded-lg mb-4">{item?.movement?.name}</p>
          <div>
            <label className="block text-xs font-semibold text-slate-600 mb-1.5 uppercase tracking-wide">Video URL</label>
            <input type="url" value={url} onChange={e => setUrl(e.target.value)} placeholder="https://youtube.com/..." className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 text-sm" />
          </div>
        </div>
        <div className="p-4 border-t border-slate-100 bg-slate-50 flex justify-end gap-2">
          <button onClick={onClose} className="px-4 py-2 text-sm font-medium text-slate-600 hover:bg-slate-200 rounded-lg transition-colors">Batal</button>
          <button onClick={() => onSave(url)}`;

code = code.replace(editModalDefRegex, newEditModalDef);

fs.writeFileSync('src/app/(dashboard)/modul-card/page.tsx', code);
