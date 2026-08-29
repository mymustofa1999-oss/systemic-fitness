const fs = require('fs');

let page = fs.readFileSync('src/app/(dashboard)/modul-card/page.tsx', 'utf8');

const regex = /<div className="flex gap-2 overflow-x-auto pb-2 scrollbar-hide">([\s\S]*?)<\/div>/;
const match = page.match(regex);

if (match) {
    const originalBlock = match[0];
    const newBlock = originalBlock + `\n
        {/* GENDER TOGGLE */}
        <div className="flex gap-2 overflow-x-auto pb-2">
            <button
                onClick={() => setSelectedGender('Male')}
                className={cn("px-6 py-2.5 rounded-xl text-sm font-semibold transition-all border", selectedGender === 'Male' ? "bg-sf-systemBlue text-white border-transparent shadow" : "bg-white text-slate-600 border-slate-200 hover:bg-slate-50")}
            >
                Male
            </button>
            <button
                onClick={() => setSelectedGender('Female')}
                className={cn("px-6 py-2.5 rounded-xl text-sm font-semibold transition-all border", selectedGender === 'Female' ? "bg-sf-systemBlue text-white border-transparent shadow" : "bg-white text-slate-600 border-slate-200 hover:bg-slate-50")}
            >
                Female
            </button>
        </div>\n`;
    page = page.replace(originalBlock, newBlock);
}

// ALSO FIX THE TABLE HEADERS (TH)
const thRegex = /<th className="px-4 py-3 font-semibold border-r border-slate-200">FEMALE<\/th>\s*<th className="px-4 py-3 font-semibold border-r border-slate-200">MALE<\/th>/;
page = page.replace(thRegex, '<th className="px-4 py-3 font-semibold border-r border-slate-200 text-center">VIDEO LATIHAN</th>');

fs.writeFileSync('src/app/(dashboard)/modul-card/page.tsx', page);
console.log('Fixed UI');
