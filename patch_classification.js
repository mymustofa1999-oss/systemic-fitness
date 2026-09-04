const fs = require('fs');
const file = 'systemic-fitness-web/src/app/(dashboard)/clients/[id]/page.tsx';
let content = fs.readFileSync(file, 'utf-8');

// 1. Update StaffCard instantiation
content = content.replace(
  '<StaffCard customerId={params.id} staff={setup?.staff} />',
  '<StaffCard customerId={params.id} staff={setup?.staff} profile={profile} />'
);

// 2. Replace StaffCard completely
const oldStaffCardStart = 'function StaffCard({ customerId, staff }: { customerId: string; staff: any }) {';

const newStaffCard = unction StaffCard({ customerId, staff, profile }: { customerId: string; staff: any; profile: any }) {
  const { data: teamData } = useTeam({ limit: 100 });
  const teamMembers = (teamData?.data ?? []) as any[];
  const assignStaff = useAssignStaff();
  const updateUser = useUpdateUser();

  function handleAssign(staffId: string, roleType: string) {
    if (!staffId) return;
    assignStaff.mutate({ customerId, staff_id: staffId, role_type: roleType });
  }

  function handleClassChange(e: React.ChangeEvent<HTMLSelectElement>) {
    const val = e.target.value;
    updateUser.mutate({ id: customerId, data: { classification: val } });
  }

  const staffOptions = teamMembers.map((m: any) => ({
    value: m.id, label: m.full_name, sublabel: m.role,
  }));

  const lbl = "px-3 py-2.5 font-semibold text-slate-500 bg-slate-50 text-xs border-r border-slate-100";
  const val = "px-3 py-2.5";

  return (
    <div className="bg-white overflow-hidden border border-slate-200 shadow-sm rounded-xl">
      <table className="w-full text-sm">
        <tbody>
          {/* Consultant */}
          <tr className="border-b border-slate-100">
            <td className={cn(lbl, "w-24")}>Consultant</td>
            <td colSpan={3} className={val}>
              <SearchableSelect
                options={staffOptions}
                value={staff?.consultant_id || ""}
                onChange={(v) => v && handleAssign(v, "consultant")}
                placeholder="- Pilih Consultant -"
                searchPlaceholder="Cari nama..."
                disabled={assignStaff.isPending}
              />
            </td>
          </tr>
          {/* Certified Trainer */}
          <tr className="border-b border-slate-100">
            <td className={cn(lbl, "w-24")}>Certified Trainer</td>
            <td colSpan={3} className={val}>
              <SearchableSelect
                options={staffOptions}
                value={staff?.trainer_id || ""}
                onChange={(v) => v && handleAssign(v, "trainer")}
                placeholder="- Pilih Certified Trainer -"
                searchPlaceholder="Cari nama..."
                disabled={assignStaff.isPending}
              />
            </td>
          </tr>
          {/* Client Classification */}
          <tr>
            <td className={cn(lbl, "w-24 align-middle")}>Classification</td>
            <td colSpan={3} className={val}>
              <select
                value={profile?.classification || ""}
                onChange={handleClassChange}
                disabled={updateUser.isPending}
                className="w-full border border-slate-200 rounded px-2 py-1 text-sm focus:outline-none focus:ring-1 focus:ring-sf-warmGold/40 bg-white"
              >
                <option value="">- Pilih Classification -</option>
                <option value="personal">Personal</option>
                <option value="group">Group</option>
                <option value="online">Online</option>
              </select>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  );
};

const startIndex = content.indexOf(oldStaffCardStart);

if (startIndex !== -1) {
  let before = content.slice(0, startIndex);
  let after = content.slice(content.indexOf('// ---------------------------------------------------------------\r\n//  HR Zone Card'));
  if (after === '') {
     after = content.slice(content.indexOf('// ---------------------------------------------------------------\n//  HR Zone Card'));
  }
  
  fs.writeFileSync(file, before + newStaffCard + '\n\n' + after);
  console.log("Success");
} else {
  console.log("Failed to find boundaries");
}
