const fs = require('fs');

let content = fs.readFileSync('src/app/(dashboard)/clients/[id]/page.tsx', 'utf8');

// 1. Pass profile to StaffCard
content = content.replace(
    `<StaffCard customerId={params.id} staff={setup?.staff} />`,
    `<StaffCard customerId={params.id} staff={setup?.staff} profile={userResponse?.profile} />`
);

// 2. Add profile prop and useUpdateUser to StaffCard
content = content.replace(
    `function StaffCard({ customerId, staff }: { customerId: string; staff: any }) {`,
    `function StaffCard({ customerId, staff, profile }: { customerId: string; staff: any; profile: any }) {
  const { mutate: updateUser, isPending: updatingUser } = useUpdateUser();`
);

// 3. Replace priority states with classification states
const oldPriorityStates = `  const updatePriority = useUpdateCustomerPriority();

  // Parse priority as array from comma-separated string
  const parsePriorities = (val: string | undefined | null): string[] =>
    (val || "").split(",").map((s: string) => s.trim()).filter(Boolean);

  const [priorities, setPriorities] = useState<string[]>(() => parsePriorities(staff?.priority));
  const [inputVal, setInputVal] = useState("");
  const [editingPriority, setEditingPriority] = useState(false);

  // Re-sync when props change
  useEffect(() => {
    if (!editingPriority) setPriorities(parsePriorities(staff?.priority));
  }, [staff?.priority, editingPriority]);

  function handleAssign(staffId: string, roleType: string) {
    if (!staffId) return;
    assignStaff.mutate({ customerId, staff_id: staffId, role_type: roleType });
  }

  function addPriority() {
    const trimmed = inputVal.trim();
    if (!trimmed || priorities.includes(trimmed)) return;
    setPriorities([...priorities, trimmed]);
    setInputVal("");
  }

  function removePriority(idx: number) {
    setPriorities(priorities.filter((_, i) => i !== idx));
  }

  function handleSavePriority() {
    // Include any pending input that hasn't been added yet
    const final = [...priorities];
    const pending = inputVal.trim();
    if (pending && !final.includes(pending)) final.push(pending);
    if (final.length === 0) return; // backend requires non-empty
    updatePriority.mutate({ customerId, priority: final.join(", ") }, {
      onSuccess: () => { setEditingPriority(false); setInputVal(""); },
    });
  }

  function cancelEditPriority() {
    setEditingPriority(false);
    setPriorities(parsePriorities(staff?.priority));
    setInputVal("");
  }`;

const newClassificationStates = `  const [editingClassification, setEditingClassification] = useState(false);
  const [classificationVal, setClassificationVal] = useState<string>(profile?.classification || "");
  const { user } = useAuth();
  const isAuthorized = user?.role === "admin" || user?.role === "owner" || user?.role === "consultant";

  useEffect(() => {
    if (!editingClassification) setClassificationVal(profile?.classification || "");
  }, [profile?.classification, editingClassification]);

  function handleAssign(staffId: string, roleType: string) {
    if (!staffId) return;
    assignStaff.mutate({ customerId, staff_id: staffId, role_type: roleType });
  }

  function handleSaveClassification() {
    updateUser({
      id: customerId,
      data: { classification: classificationVal || undefined }
    }, {
      onSuccess: () => setEditingClassification(false)
    });
  }

  function cancelEditClassification() {
    setEditingClassification(false);
    setClassificationVal(profile?.classification || "");
  }`;

content = content.replace(oldPriorityStates, newClassificationStates);

// 4. Replace priority HTML with classification HTML
const oldPriorityHtml = `        {/* Prioritas ?" multi-tag editable */}
        <tr>
          <td className={cn(lbl, "w-24 align-top")}>Priority</td>
          <td colSpan={3} className={val}>
            {editingPriority ? (
              <div className="space-y-2">
                {/* Tags */}
                {priorities.length > 0 && (
                  <div className="flex flex-wrap gap-1.5">
                    {priorities.map((p, i) => (
                      <span key={i} className="inline-flex items-center gap-1 bg-sf-iceBlue text-sf-deepNavy border border-sf-iceBlue rounded-full px-2.5 py-0.5 text-xs font-medium">
                        {p}
                        <button type="button" onClick={() => removePriority(i)} className="hover:text-red-500 transition-colors">
                          <X className="h-3 w-3" />
                        </button>
                      </span>
                    ))}
                  </div>
                )}
                {/* Input */}
                <div className="flex items-center gap-2">
                  <input
                    value={inputVal}
                    onChange={(e) => setInputVal(e.target.value)}
                    className="flex-1 border border-slate-200 rounded px-2 py-1 text-sm focus:outline-none focus:ring-1 focus:ring-sf-warmGold/40"
                    placeholder="Type priority then Enter..."
                    autoFocus
                    onKeyDown={(e) => {
                      if (e.key === "Enter") { e.preventDefault(); addPriority(); }
                      if (e.key === "Escape") cancelEditPriority();
                    }}
                  />
                  <button type="button" onClick={handleSavePriority} disabled={updatePriority.isPending}
                    className="inline-flex items-center gap-1.5 px-3 py-1 rounded bg-sf-deepNavy text-white text-xs font-medium hover:bg-sf-deepNavy disabled:opacity-50">
                    {updatePriority.isPending ? <Loader2 className="h-3.5 w-3.5 animate-spin" /> : <Save className="h-3.5 w-3.5" />}
                    Save
                  </button>
                  <button type="button" onClick={cancelEditPriority}
                    className="p-1 rounded hover:bg-slate-100 text-slate-400" title="Cancel">
                    <X className="h-3.5 w-3.5" />
                  </button>
                </div>
              </div>
            ) : (
              <button type="button" onClick={() => setEditingPriority(true)}
                className="text-sm font-medium hover:bg-slate-50 rounded px-1 py-0.5 -mx-1 transition-colors w-full text-left">
                {priorities.length > 0 ? (
                  <div className="flex flex-wrap gap-1.5">
                    {priorities.map((p, i) => (
                      <span key={i} className="inline-flex items-center bg-sf-iceBlue text-sf-deepNavy border border-sf-iceBlue rounded-full px-2.5 py-0.5 text-xs font-medium">
                        {p}
                      </span>
                    ))}
                  </div>
                ) : (
                  <span className="text-slate-400 italic">- Click to edit -</span>
                )}
              </button>
            )}
          </td>
        </tr>`;

const newClassificationHtml = `        {/* Client Classification */}
        <tr>
          <td className={cn(lbl, "w-24 align-middle")}>Client Classification</td>
          <td colSpan={3} className={val}>
            {editingClassification ? (
              <div className="flex items-center gap-2">
                <SearchableSelect
                  options={[
                    { value: "", label: "None (Unclassified)" },
                    { value: "personal", label: "Personal" },
                    { value: "group", label: "Group" },
                    { value: "online", label: "Online" },
                  ]}
                  value={classificationVal}
                  onChange={setClassificationVal}
                  placeholder="Select classification..."
                />
                <button type="button" onClick={handleSaveClassification} disabled={updatingUser}
                  className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded bg-sf-deepNavy text-white text-xs font-medium hover:bg-sf-deepNavy disabled:opacity-50">
                  {updatingUser ? <Loader2 className="h-3.5 w-3.5 animate-spin" /> : <Save className="h-3.5 w-3.5" />}
                  Save
                </button>
                <button type="button" onClick={cancelEditClassification}
                  className="p-1 rounded hover:bg-slate-100 text-slate-400" title="Cancel">
                  <X className="h-4 w-4" />
                </button>
              </div>
            ) : (
              <button 
                type="button" 
                onClick={() => { if (isAuthorized) setEditingClassification(true); }}
                disabled={!isAuthorized}
                className={cn(
                  "text-sm font-medium rounded px-1 py-0.5 -mx-1 transition-colors w-full text-left",
                  isAuthorized ? "hover:bg-slate-50 cursor-pointer" : "cursor-default"
                )}
              >
                {profile?.classification ? (
                  <span className="inline-flex items-center bg-sf-iceBlue text-sf-deepNavy border border-sf-iceBlue rounded-full px-2.5 py-0.5 text-xs font-medium capitalize">
                    {profile.classification}
                  </span>
                ) : (
                  <span className="text-slate-400 italic">
                    {isAuthorized ? "- Click to edit classification -" : "Unclassified"}
                  </span>
                )}
              </button>
            )}
          </td>
        </tr>`;

content = content.replace(oldPriorityHtml, newClassificationHtml);

fs.writeFileSync('src/app/(dashboard)/clients/[id]/page.tsx', content);
console.log("Patched StaffCard inside page.tsx");
