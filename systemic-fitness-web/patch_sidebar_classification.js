const fs = require('fs');

const path = 'src/components/layout/Sidebar.tsx';
let content = fs.readFileSync(path, 'utf8');

const search = `      // Remove Scheduling parent
      clonedMenus.splice(schedulingIndex, 1);
    }`;

const replacement = `      // Remove Scheduling parent
      clonedMenus.splice(schedulingIndex, 1);
    }
    
    // Add Client Classification after Clients
    const clientsIndex = clonedMenus.findIndex((m) => m.code === "clients");
    if (clientsIndex !== -1) {
      const clientClassificationMenu = {
        id: "client-classification-parent",
        parent_id: null,
        code: "client_classification",
        label: "Client Classification",
        icon: "UsersRound", // using an existing icon
        href: "/client-classification", // will act as parent
        sort_order: clonedMenus[clientsIndex].sort_order + 0.5, // keep it right after clients
        is_active: true,
        created_at: "",
        updated_at: "",
        children: [
          {
            id: "client-classification-personal",
            parent_id: "client-classification-parent",
            code: "cc_personal",
            label: "Personal",
            icon: "User",
            href: "/client-classification/personal",
            sort_order: 1,
            is_active: true,
            created_at: "",
            updated_at: "",
            children: []
          },
          {
            id: "client-classification-group",
            parent_id: "client-classification-parent",
            code: "cc_group",
            label: "Group",
            icon: "Users",
            href: "/client-classification/group",
            sort_order: 2,
            is_active: true,
            created_at: "",
            updated_at: "",
            children: []
          },
          {
            id: "client-classification-online",
            parent_id: "client-classification-parent",
            code: "cc_online",
            label: "Online",
            icon: "Monitor",
            href: "/client-classification/online",
            sort_order: 3,
            is_active: true,
            created_at: "",
            updated_at: "",
            children: []
          }
        ]
      };
      // Insert right after clients
      clonedMenus.splice(clientsIndex + 1, 0, clientClassificationMenu);
    }`;

content = content.replace(search, replacement);

if (!content.includes('Monitor')) {
  content = content.replace(
    'LayoutDashboard, Users, MessageSquare, Trophy, UserCheck, UsersRound,',
    'LayoutDashboard, Users, MessageSquare, Trophy, UserCheck, UsersRound, User, Monitor,'
  );
}

fs.writeFileSync(path, content);
console.log("Patched Sidebar.tsx");
