const fs = require('fs');

const path = 'src/components/layout/Sidebar.tsx';
let content = fs.readFileSync(path, 'utf8');

const target = \  const menus: MenuItem[] = hasDashboard 
    ? rawMenus 
    : [
        { id: "static-dashboard", parent_id: null, code: "dashboard", label: "Dashboard", icon: "LayoutDashboard", href: "/", sort_order: 0, is_active: true, created_at: "", updated_at: "", children: [] },
        ...rawMenus
      ];\;

const replacement = \  const baseMenus: MenuItem[] = hasDashboard 
    ? rawMenus 
    : [
        { id: "static-dashboard", parent_id: null, code: "dashboard", label: "Dashboard", icon: "LayoutDashboard", href: "/", sort_order: 0, is_active: true, created_at: "", updated_at: "", children: [] },
        ...rawMenus
      ];

  // Reorganize menus: Move Calendar & Availability into My Schedule, remove Scheduling
  const menus = React.useMemo(() => {
    // Deep clone to avoid mutating cached queries
    const clonedMenus = JSON.parse(JSON.stringify(baseMenus));
    
    // Find My Schedule
    const mySchedule = clonedMenus.find((m: any) => 
      m.label === "Jadwal Saya" || m.label === "My Schedule" || m.code === "my_schedule"
    );
    
    // Find Scheduling
    const schedulingIndex = clonedMenus.findIndex((m: any) => 
      m.label === "Penjadwalan" || m.label === "Scheduling" || m.label === "Jadwal" || m.code === "scheduling"
    );
    
    if (mySchedule && schedulingIndex !== -1) {
      const scheduling = clonedMenus[schedulingIndex];
      
      if (!mySchedule.children) mySchedule.children = [];
      
      // Move children
      if (scheduling.children && scheduling.children.length > 0) {
        mySchedule.children.push(...scheduling.children);
      }
      
      // Remove Scheduling parent
      clonedMenus.splice(schedulingIndex, 1);
    }
    
    return clonedMenus;
  }, [baseMenus]);\;

content = content.replace(target, replacement);
fs.writeFileSync(path, content);
console.log("Done");
