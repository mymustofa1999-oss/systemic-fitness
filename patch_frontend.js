const fs = require('fs');

// 1. Add hook to useDigitalLibrary.ts
let hooks = fs.readFileSync('systemic-fitness-web/src/hooks/useDigitalLibrary.ts', 'utf8');
if (!hooks.includes('useUpdateDLMenuItem')) {
    const newHook = `export function useUpdateDLMenuItem() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string, data: any }) => apiPut(\`/api/digital-library/menu/\${id}\`, data),
    onSuccess: () => {
      toast.success("Menu item updated");
      queryClient.invalidateQueries({ queryKey: ["dl-menu-items"] });
    },
    onError: (err: any) => {
      toast.error(err.message || "Failed to update menu item");
    }
  });
}
`;
    hooks += '\n' + newHook;
    fs.writeFileSync('systemic-fitness-web/src/hooks/useDigitalLibrary.ts', hooks);
}

// 2. Modify page.tsx
let page = fs.readFileSync('systemic-fitness-web/src/app/(dashboard)/modul-card/page.tsx', 'utf8');

// import useUpdateDLMenuItem
page = page.replace('useDLMovements,', 'useDLMovements,\n  useUpdateDLMenuItem,');

// replace mutation usage
page = page.replace('const updateMovementMutation = useUpdateDLMovement();', 'const updateMovementMutation = useUpdateDLMovement();\n  const updateMenuItemMutation = useUpdateDLMenuItem();');

// replace Video URL logic
page = page.replace('{row.movement?.video_url_female && (', '{ (row.video_url_female || row.movement?.video_url_female) && (');
page = page.replace('setVideoModalUrl(row.movement.video_url_female)', 'setVideoModalUrl(row.video_url_female || row.movement.video_url_female)');
page = page.replace('{row.movement?.video_url_male && (', '{ (row.video_url_male || row.movement?.video_url_male) && (');
page = page.replace('setVideoModalUrl(row.movement.video_url_male)', 'setVideoModalUrl(row.video_url_male || row.movement.video_url_male)');

// replace EditVideoModal initial values
page = page.replace('useState(item?.movement?.video_url_female || "");', 'useState(item?.video_url_female || item?.movement?.video_url_female || "");');
page = page.replace('useState(item?.movement?.video_url_male || "");', 'useState(item?.video_url_male || item?.movement?.video_url_male || "");');

// replace EditVideoModal save logic
page = page.replace(`await updateMovementMutation.mutateAsync({
                id: itemToEdit.movement_id,
                data: {
                  video_url_female: femaleUrl,
                  video_url_male: maleUrl
                }
              });`, `await updateMenuItemMutation.mutateAsync({
                id: itemToEdit.id,
                data: {
                  video_url_female: femaleUrl || null,
                  video_url_male: maleUrl || null
                }
              });`);

page = page.replace('isLoading={updateMovementMutation.isPending}', 'isLoading={updateMenuItemMutation.isPending}');

fs.writeFileSync('systemic-fitness-web/src/app/(dashboard)/modul-card/page.tsx', page);
console.log('Frontend patched');
