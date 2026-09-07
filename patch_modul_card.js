const fs = require('fs');
const file = 'systemic-fitness-web/src/app/(dashboard)/modul-card/page.tsx';
let content = fs.readFileSync(file, 'utf8');

const target = '          const res = await createMutation.mutateAsync({\n' +
'            name: newName,\n' +
'            body_part: newBodyPart,\n' +
'            video_url_male: gender.toLowerCase() === \\'male\\' ? newVideoUrl : undefined,\n' +
'            video_url_female: gender.toLowerCase() === \\'female\\' ? newVideoUrl : undefined,\n' +
'            target_gender: "universal"\n' +
'          });';

const replacement = '          const res = await createMutation.mutateAsync({\n' +
'            name: newName,\n' +
'            body_part: newBodyPart.toLowerCase(),\n' +
'            categories: [sequence],\n' +
'            video_url_male: (gender.toLowerCase() === \\'male\\' && newVideoUrl.trim()) ? newVideoUrl.trim() : undefined,\n' +
'            video_url_female: (gender.toLowerCase() === \\'female\\' && newVideoUrl.trim()) ? newVideoUrl.trim() : undefined,\n' +
'            target_gender: "universal"\n' +
'          });';

if (content.includes(target)) {
    content = content.replace(target, replacement);
    fs.writeFileSync(file, content);
    console.log("Patched modul card successfully");
} else {
    console.log("Target not found!");
}
