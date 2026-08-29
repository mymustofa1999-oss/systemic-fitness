const fs = require('fs');

const path = 'src/components/shared/ClientFormModal.tsx';
let content = fs.readFileSync(path, 'utf8');

// 1. Add classification state
content = content.replace(
  'const [status, setStatus] = useState("active");',
  'const [status, setStatus] = useState("active");\n  const [classification, setClassification] = useState("");'
);

// 2. Add prop to interface if it's there, but actually we use any or Record<string, unknown> anyway.
// Let's modify the reset block.
content = content.replace(
  'setStatus(client.status || "active");',
  'setStatus(client.status || "active");\n      // @ts-ignore\n      setClassification(client.profile?.classification || "");'
);
content = content.replace(
  'setStatus("active");',
  'setStatus("active");\n      setClassification("");'
);

// 3. Update the onSubmit to send classification
const submitSearch = `      const payload = {
        full_name: fullName,
        email,
        phone,
        status,
      };`;
const submitReplace = `      const payload = {
        full_name: fullName,
        email,
        phone,
        status,
        ...(classification ? { classification } : {}),
      };`;
content = content.replace(submitSearch, submitReplace);

// 4. Add the Classification dropdown in the UI (between Phone and Status)
const uiSearch = `            {isEdit && (
              <div className="space-y-1.5">`;
const uiReplace = `            <div className="space-y-1.5">
              <label className="text-sm font-medium text-slate-700">Client Classification</label>
              <select
                value={classification}
                onChange={(e) => setClassification(e.target.value)}
                className="w-full px-3 py-2 bg-white border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-sf-deepNavy/20"
              >
                <option value="">Unclassified</option>
                <option value="personal">Personal</option>
                <option value="group">Group</option>
                <option value="online">Online</option>
              </select>
            </div>

            {isEdit && (
              <div className="space-y-1.5">`;
content = content.replace(uiSearch, uiReplace);

fs.writeFileSync(path, content);
console.log("Patched ClientFormModal");
