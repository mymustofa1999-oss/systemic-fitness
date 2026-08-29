const fs = require('fs');

let content = fs.readFileSync('src/components/shared/ClientFormModal.tsx', 'utf8');

// Inject the dropdown for Classification
content = content.replace(
`          {!isEdit ? (
            <div>
              <label className="label">Password *</label>`,
`          {isAuthorized && (
            <div>
              <label className="label">Client Classification</label>
              <SearchableSelect
                options={[
                  { value: "", label: "None (Unclassified)" },
                  { value: "personal", label: "Personal" },
                  { value: "group", label: "Group" },
                  { value: "online", label: "Online" },
                ]}
                value={classification || ""}
                onChange={(val) => setClassification(val)}
                placeholder="Select classification..."
              />
              <p className="text-xs text-slate-400 mt-1">Assigning this classification will organize the client in the sidebar.</p>
            </div>
          )}

          {!isEdit ? (
            <div>
              <label className="label">Password *</label>`);

// Also update the payload to include classification
content = content.replace(
`      if (isEdit) {
        updateClient(
          {
            id: client.id,
            payload: {
              full_name: fullName.trim(),
              phone: phone.trim(),
              status,
            },
          },`,
`      if (isEdit) {
        updateClient(
          {
            id: client.id,
            payload: {
              full_name: fullName.trim(),
              phone: phone.trim(),
              status,
              classification: classification || undefined,
            },
          },`);

fs.writeFileSync('src/components/shared/ClientFormModal.tsx', content);
console.log("Patched ClientFormModal.tsx");
