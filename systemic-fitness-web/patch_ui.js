const fs = require('fs');

const path = 'src/components/shared/ClientFormModal.tsx';
let content = fs.readFileSync(path, 'utf8');

const uiSearch = `            <div>
              <label className="label">Phone</label>
              <input
                type="tel"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                placeholder="+62 812..."
                className="input"
              />
            </div>`;

const uiReplace = `            <div>
              <label className="label">Phone</label>
              <input
                type="tel"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                placeholder="+62 812..."
                className="input"
              />
            </div>

            <div>
              <label className="label">Client Classification *</label>
              <SearchableSelect
                options={[
                  { value: "personal", label: "Personal" },
                  { value: "group", label: "Group" },
                  { value: "online", label: "Online" },
                ]}
                value={classification}
                onChange={setClassification}
                placeholder="Select classification..."
              />
            </div>`;

content = content.replace(uiSearch, uiReplace);

fs.writeFileSync(path, content);
console.log("Patched UI");
