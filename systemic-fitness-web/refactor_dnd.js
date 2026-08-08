const fs = require('fs');

const filePath = 'C:/Users/ITBDG/Documents/SystemicFitness-Handover/CLEAN/systemic-fitness-web/src/app/(dashboard)/clients/[id]/training-card/page.tsx';
let content = fs.readFileSync(filePath, 'utf-8');

// 1. Add imports
const importStr = `
import { DndContext, closestCenter, PointerSensor, useSensor, useSensors, DragEndEvent } from "@dnd-kit/core";
import { SortableContext, verticalListSortingStrategy, useSortable, arrayMove } from "@dnd-kit/sortable";
import { CSS } from "@dnd-kit/utilities";
import { GripVertical } from "lucide-react";
`;
content = content.replace(/(import \* as Popover from "@radix-ui\/react-popover";)/, `$1\n${importStr.trim()}\n`);

// 2. Add _uid to CardItem interface
content = content.replace(/(interface CardItem \{)/, `$1\n  _uid?: string;`);

// A helper function ensureUids(sequences)
const uidHelper = `
function ensureUids(sequences: any[]) {
  return sequences.map(seq => ({
    ...seq,
    sets: (seq.sets || []).map((set: any) => ({
      ...set,
      items: (set.items || []).map((item: any) => ({
        ...item,
        _uid: item._uid || crypto.randomUUID()
      }))
    }))
  }));
}
`;

content = content.replace(
  /(export default function TrainingCardPage\(\{ params \}: \{ params: \{ id: string \} \}\) \{)/,
  `${uidHelper}\n$1`
);

// Intercept setForm
content = content.replace(
  /const \[form, setForm\] = useState<CardForm \| null>\(null\);/,
  `const [form, _setForm] = useState<CardForm | null>(null);\n  const setForm = (val: CardForm | null) => {\n    if (val && val.sequences) {\n      val.sequences = ensureUids(val.sequences);\n    }\n    _setForm(val);\n  };`
);


// Fix addItem new item _uid
content = content.replace(
  /(items: \[\.\.\.seq\.sets\[seti\]\.items,\s*\{\n\s*movement_id: null,\n\s*movement_name: null,\n\s*body_part: bodyPart,\n\s*equipment: null,\n\s*reps: null,\n\s*sets_count: null,\n\s*sort_order: seq\.sets\[seti\]\.items\.length \+ 1)/g,
  `$1,\n            _uid: crypto.randomUUID()`
);

// Add onReorderItem in TrainingCardPage
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

content = content.replace(
  /(function addItem\(si: number, seti: number, bodyPart: string\) \{)/,
  `${reorderFunc}\n  $1`
);

// Pass onReorderItem down to SequenceTable
content = content.replace(
  'onUpdateItem={(seti, ii, p) => updateItem(si, seti, ii, p)}',
  'onUpdateItem={(seti, ii, p) => updateItem(si, seti, ii, p)}\n            onReorderItem={(seti, oldI, newI) => reorderItem(si, seti, oldI, newI)}'
);

content = content.replace(
  'onUpdateItem: (seti: number, ii: number, p: Partial<CardItem>) => void;',
  'onUpdateItem: (seti: number, ii: number, p: Partial<CardItem>) => void;\n  onReorderItem?: (seti: number, oldIndex: number, newIndex: number) => void;'
);

content = content.replace(
  'onUpdateItem, onPreviewVideo,',
  'onUpdateItem, onReorderItem, onPreviewVideo,'
);

// Pass down to SetBlock
content = content.replace(
  'onUpdateItem={(ii, p) => onUpdateItem(seti, ii, p)}',
  'onUpdateItem={(ii, p) => onUpdateItem(seti, ii, p)}\n              onReorderItem={(oldI, newI) => onReorderItem && onReorderItem(seti, oldI, newI)}'
);

content = content.replace(
  'onUpdateItem: (ii: number, p: Partial<CardItem>) => void;',
  'onUpdateItem: (ii: number, p: Partial<CardItem>) => void;\n  onReorderItem?: (oldIndex: number, newIndex: number) => void;'
);

content = content.replace(
  'onUpdateItem, onPreviewVideo,',
  'onUpdateItem, onReorderItem, onPreviewVideo,'
);

// SetBlock Drag implementation
const setblockDrag = `
  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 5,
      },
    })
  );

  function handleDragEnd(event: DragEndEvent) {
    const { active, over } = event;
    if (over && active.id !== over.id) {
      const oldIndex = set.items.findIndex((i: any) => i._uid === active.id);
      const newIndex = set.items.findIndex((i: any) => i._uid === over.id);
      if (oldIndex !== -1 && newIndex !== -1 && onReorderItem) {
        onReorderItem(oldIndex, newIndex);
      }
    }
  }
`;

content = content.replace(
  /(const isLevel1 = level === "1" \|\| level === "1-499" \|\| level === "1-799";)/,
  `$1\n${setblockDrag}`
);

// 3. Replace the entire space-y-3 mb-4 block
const itemsBlockRegex = /<div className="space-y-3 mb-4">[\s\S]*?\{\/\* Add Movement Buttons \*\//;

const itemsBlockReplacement = `
          <DndContext sensors={sensors} collisionDetection={closestCenter} onDragEnd={handleDragEnd}>
            <SortableContext items={set.items.map((i: any) => i._uid || i.movement_id || String(Math.random()))} strategy={verticalListSortingStrategy}>
              <div className="space-y-3 mb-4">
                {set.items.map((item, ii) => (
                  <SortableItemRow
                    key={item._uid || ii}
                    id={item._uid || ii}
                    item={item}
                    ii={ii}
                    editing={editing}
                    isLevel1={isLevel1}
                    selectedPatterns={selectedPatterns}
                    categoryCode={categoryCode}
                    hasErrorReps={formErrors[\`item_\${si}_\${seti}_\${ii}_reps\`]}
                    hasErrorSets={formErrors[\`item_\${si}_\${seti}_\${ii}_sets_count\`]}
                    hasErrorMovement={formErrors[\`item_\${si}_\${seti}_\${ii}_movement\`]}
                    movementOptions={movementOptions}
                    movementMap={movementMap}
                    onUpdateItem={onUpdateItem}
                    onRemoveItem={onRemoveItem}
                    onPreviewVideo={(m: any) => onPreviewVideo && onPreviewVideo(m, set.bpm || "")}
                    gender={gender}
                  />
                ))}
              </div>
            </SortableContext>
          </DndContext>
        )}

        {/* Add Movement Buttons */`;

content = content.replace(itemsBlockRegex, itemsBlockReplacement);


const sortableComp = `
function SortableItemRow({ 
  item, ii, editing, isLevel1, selectedPatterns, categoryCode, hasErrorReps, hasErrorSets, hasErrorMovement,
  movementOptions, movementMap, onUpdateItem, onRemoveItem, onPreviewVideo, gender, id
}: any) {
  const { attributes, listeners, setNodeRef, transform, transition, isDragging } = useSortable({ id });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    zIndex: isDragging ? 50 : "auto",
    opacity: isDragging ? 0.9 : 1,
    position: isDragging ? "relative" : "static",
  } as any;

  return (
    <div ref={setNodeRef} style={style} className={\`flex flex-col md:flex-row gap-4 bg-white p-3 border \${isDragging ? "border-violet-400 shadow-md" : "border-slate-200"} rounded-md shadow-sm relative\`}>
      {editing && (
        <div {...attributes} {...listeners} className="absolute -left-3 top-1/2 -translate-y-1/2 p-2 cursor-grab active:cursor-grabbing text-slate-300 hover:text-slate-500 bg-white border border-slate-200 rounded-full shadow-sm z-10 md:flex hidden">
          <GripVertical className="h-4 w-4" />
        </div>
      )}
      {/* Bagian Nama & Body Part */}
      <div className="flex-1">
        <div className="flex items-center justify-end mb-1.5">
          {editing && (
            <div className="flex gap-2 items-center md:hidden">
              <div {...attributes} {...listeners} className="text-slate-400 hover:text-slate-600 transition-colors p-1 cursor-grab">
                <GripVertical className="h-4 w-4" />
              </div>
              <button onClick={() => {
                const m = item.movement_id ? movementMap[item.movement_id] : null;
                if (m && onPreviewVideo) onPreviewVideo(m, item.bpm || "");
              }} className="text-violet-500 hover:text-violet-700 transition-colors" title="Preview Video">
                <Video className="h-4 w-4" />
              </button>
              <button onClick={() => onRemoveItem(ii)} className="text-red-400 hover:text-red-600 transition-colors">
                <Trash2 className="h-4 w-4" />
              </button>
            </div>
          )}
        </div>
        
        {editing ? (
          <MovementSelect
            options={movementOptions}
            movementMap={movementMap}
            item={item}
            bodyPart={item.body_part || ""}
            selectedPatterns={selectedPatterns}
            categoryCode={categoryCode}
            onUpdate={(p) => onUpdateItem(ii, p)}
            hasError={hasErrorMovement}
            gender={gender}
          />
        ) : (
          <div className="flex items-center gap-2 mt-1">
            <div className="font-semibold text-slate-800 text-sm">{formatMovementName(item.movement_name || "-", gender)}</div>
            <button onClick={() => {
              const m = item.movement_id ? movementMap[item.movement_id] : null;
              if (m && onPreviewVideo) onPreviewVideo(m, item.bpm || "");
            }} className="p-1 rounded bg-slate-100 text-violet-600 hover:bg-violet-100" title="Preview Video">
              <Video className="h-4 w-4" />
            </button>
          </div>
        )}
      </div>

      {/* Bagian Reps & Breathing Khusus */}
      <div className="flex items-end gap-3 md:w-auto w-full border-t border-slate-100 md:border-none pt-3 md:pt-0 pl-0 md:pl-2">
        {/* Reps */}
        <div className="w-20 shrink-0">
          <label className="block text-[10px] text-slate-400 mb-1">Reps</label>
          {editing ? (
            <input 
              type="number" 
              value={item.reps ?? ""} 
              onChange={(e) => onUpdateItem(ii, { reps: e.target.value ? +e.target.value : null })} 
              className={\`w-full text-sm border rounded px-2 py-1.5 focus:outline-none focus:ring-1 focus:ring-sf-deepNavy text-center \${hasErrorReps ? "border-red-500 bg-red-50 placeholder-red-300" : "border-slate-200"}\`} 
            />
          ) : (
            <div className="font-medium text-sm text-center">{item.reps ?? "-"}</div>
          )}
        </div>
        
        {/* Sets Count */}
        <div className="w-16 shrink-0">
          <label className="block text-[10px] text-slate-400 mb-1">Set</label>
          {editing ? (
            <input 
              type="number" 
              value={item.sets_count ?? ""} 
              onChange={(e) => onUpdateItem(ii, { sets_count: e.target.value ? +e.target.value : null })} 
              className={\`w-full text-sm border rounded px-2 py-1.5 focus:outline-none focus:ring-1 focus:ring-sf-deepNavy text-center \${hasErrorSets ? "border-red-500 bg-red-50 placeholder-red-300" : "border-slate-200"}\`} 
            />
          ) : (
            <div className="font-medium text-sm text-center">{item.sets_count ?? "-"}</div>
          )}
        </div>

        {/* Breathing khusus level 1 per item */}
        {isLevel1 && (
          <div className="w-24 shrink-0 space-y-1">
            <label className="block text-[10px] text-slate-400 mb-1">Breathing</label>
            {editing ? (
              <select
                value={item.breathing_core || ""}
                onChange={(e) => onUpdateItem(ii, { breathing_core: e.target.value })}
                className="text-[10px] w-full border border-slate-200 rounded px-1.5 py-1 focus:outline-none bg-white"
              >
                <option value="">Pilih...</option>
                <option value="Core">Core</option>
                <option value="Diafragma">Diafragma</option>
              </select>
            ) : (
              <div className="font-medium text-sm text-center">
                {item.breathing_core || "-"}
              </div>
            )}
          </div>
        )}

        {/* Desktop Actions */}
        {editing && (
          <div className="hidden md:flex flex-row gap-2 items-center justify-center p-2">
            <button onClick={() => {
              const m = item.movement_id ? movementMap[item.movement_id] : null;
              if (m && onPreviewVideo) onPreviewVideo(m, item.bpm || "");
            }} className="text-violet-500 hover:text-violet-700 transition-colors p-2 bg-slate-50 rounded" title="Preview Video">
              <Video className="h-4 w-4" />
            </button>
            <button onClick={() => onRemoveItem(ii)} className="text-red-400 hover:text-red-600 transition-colors" title="Hapus gerakan">
              <Trash2 className="h-4 w-4" />
            </button>
          </div>
        )}
      </div>

    </div>
  );
}
`;

content = content + "\n\n" + sortableComp;

content = content.replace(
  /items: set\.items\.map\(\(item, index\) => \(\{/g,
  'items: set.items.map((item, index) => { const { _uid, ...rest } = item as any; return { ...rest,'
);

content = content.replace(
  /\.\.\.item,\n\s*sort_order: index \+ 1\n\s*\}\)\)/g,
  'sort_order: index + 1 }; })'
);

fs.writeFileSync(filePath, content, 'utf-8');
console.log('Done');
