const fs = require('fs');
let page = fs.readFileSync('src/app/(dashboard)/modul-card/page.tsx', 'utf8');

if (!page.includes('selectedGender')) {
    page = page.replace('const [selectedLevel, setSelectedLevel] = useState<number>(1);', 
        `const [selectedLevel, setSelectedLevel] = useState<number>(1);
  const [selectedGender, setSelectedGender] = useState<'Male'|'Female'>('Male');`);

    const levelSelectorUI = `<div className="flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
          {activeLevels.map((lvl) => {`;
    
    const genderToggleUI = `<div className="flex items-center gap-4 mb-4">
          <div className="flex bg-slate-100 p-1 rounded-xl border border-slate-200">
            <button
              onClick={() => setSelectedGender('Male')}
              className={cn("px-6 py-2 rounded-lg text-sm font-semibold transition-all", selectedGender === 'Male' ? "bg-white shadow-sm text-slate-800" : "text-slate-500 hover:text-slate-700")}
            >Male</button>
            <button
              onClick={() => setSelectedGender('Female')}
              className={cn("px-6 py-2 rounded-lg text-sm font-semibold transition-all", selectedGender === 'Female' ? "bg-white shadow-sm text-slate-800" : "text-slate-500 hover:text-slate-700")}
            >Female</button>
          </div>
        </div>

        <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
          {activeLevels.map((lvl) => {`;
          
    page = page.replace(levelSelectorUI, genderToggleUI);

    page = page.replace('<th className="px-4 py-3 text-left text-xs font-semibold text-slate-500 uppercase tracking-wider w-1/4">Latihan Female</th>', '');
    page = page.replace('<th className="px-4 py-3 text-left text-xs font-semibold text-slate-500 uppercase tracking-wider w-1/4">Latihan Male</th>', '<th className="px-4 py-3 text-left text-xs font-semibold text-slate-500 uppercase tracking-wider w-1/2">Video Latihan</th>');

    // This is getting tricky to replace via regex reliably. I will manually edit it with a replace regex block.
    
    fs.writeFileSync('src/app/(dashboard)/modul-card/page.tsx', page);
    console.log('Added Gender Toggle');
}
