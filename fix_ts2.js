const fs = require('fs');
const path = 'C:/Users/ITBDG/Documents/SystemicFitness-Handover/CLEAN/systemic-fitness-web/src/app/(dashboard)/clients/[id]/training-card/page.tsx';
let c = fs.readFileSync(path, 'utf8');

const s1 = '  const [form, _setForm] = useState<CardForm | null>(null);\r\n  const setForm = (val: CardForm | null) => {\r\n    if (val && val.sequences) {\r\n      val.sequences = ensureUids(val.sequences);\r\n    }\r\n    _setForm(val);\r\n  };';
const r1 = '  const [form, _setForm] = useState<CardForm | null>(null);\r\n  const setForm = (val: React.SetStateAction<CardForm | null>) => {\r\n    if (typeof val === "function") {\r\n      _setForm((prev: any) => {\r\n        const nextVal = (val as any)(prev);\r\n        if (nextVal && nextVal.sequences) nextVal.sequences = ensureUids(nextVal.sequences);\r\n        return nextVal;\r\n      });\r\n    } else {\r\n      if (val && val.sequences) val.sequences = ensureUids(val.sequences);\r\n      _setForm(val);\r\n    }\r\n  };';
c = c.replace(s1, r1);

// Because of Windows CRLF, sometimes it's easier to just match without whitespace:
const setFormRegex = /const \[form, _setForm\] = useState<CardForm \| null>\(null\);[\s\S]*?_setForm\(val\);\s*\};/;
c = c.replace(setFormRegex, r1);

const reorderFunc = `  function reorderItem(si: number, seti: number, oldIndex: number, newIndex: number) {
    if (!form) return;
    const newSequences = [...form.sequences];
    const newSets = [...newSequences[si].sets];
    const newItems = [...newSets[seti].items];
    
    const reordered = arrayMove(newItems, oldIndex, newIndex);
    
    newSets[seti] = { ...newSets[seti], items: reordered };
    newSequences[si] = { ...newSequences[si], sets: newSets };
    
    setForm({ ...form, sequences: newSequences });
  }
`;

// Remove ALL existing function reorderItem(...) { ... }
const duplicateReorderRegex = /\s*function reorderItem\(si: number, seti: number, oldIndex: number, newIndex: number\) \{[\s\S]*?setForm\(\{ \.\.\.form, sequences: newSequences \}\);\s*\}/g;
c = c.replace(duplicateReorderRegex, '');

// Re-inject it ONCE before addItem
c = c.replace(/(function addItem\(si: number, seti: number, bodyPart: string( = "upper")?\) \{)/, '\n' + reorderFunc + '\n  $1');

fs.writeFileSync(path, c, 'utf8');
console.log('Fixed exactly once.');
