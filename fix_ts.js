const fs = require('fs');
const path = 'C:/Users/ITBDG/Documents/SystemicFitness-Handover/CLEAN/systemic-fitness-web/src/app/(dashboard)/clients/[id]/training-card/page.tsx';
let c = fs.readFileSync(path, 'utf8');

// 1. Fix setForm
const oldSetForm = 'const [form, _setForm] = useState<CardForm | null>(null);\n  const setForm = (val: CardForm | null) => {\n    if (val && val.sequences) {\n      val.sequences = ensureUids(val.sequences);\n    }\n    _setForm(val);\n  };';
const newSetForm = 'const [form, _setForm] = useState<CardForm | null>(null);\n  const setForm = (val: any) => {\n    if (typeof val === "function") {\n      _setForm((prev: any) => {\n        const nextVal = val(prev);\n        if (nextVal && nextVal.sequences) nextVal.sequences = ensureUids(nextVal.sequences);\n        return nextVal;\n      });\n    } else {\n      if (val && val.sequences) val.sequences = ensureUids(val.sequences);\n      _setForm(val);\n    }\n  };';
c = c.replace(oldSetForm, newSetForm);

// 2. Add reorderItem
const reorderFunc = `
  function reorderItem(si: number, seti: number, oldIndex: number, newIndex: number) {
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

if (!c.includes('function reorderItem')) {
  c = c.replace(/(function addItem\(si: number, seti: number, bodyPart: string = "upper"\) \{)/, reorderFunc + '\n  $1');
}

fs.writeFileSync(path, c, 'utf8');
console.log('Fixed');
