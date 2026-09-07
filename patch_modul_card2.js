const fs = require('fs');
const file = 'systemic-fitness-web/src/app/(dashboard)/modul-card/page.tsx';
let content = fs.readFileSync(file, 'utf8');

const regex = /const res = await createMutation\.mutateAsync\(\{[\s\S]*?name: newName,[\s\S]*?body_part: newBodyPart,[\s\S]*?video_url_male: [^\n]+,[\s\S]*?video_url_female: [^\n]+,[\s\S]*?target_gender: "universal"[\s\S]*?\}\);/;

const replacement = \const res = await createMutation.mutateAsync({
            name: newName,
            body_part: newBodyPart.toLowerCase(),
            categories: [sequence],
            video_url_male: (gender.toLowerCase() === 'male' && newVideoUrl.trim()) ? newVideoUrl.trim() : undefined,
            video_url_female: (gender.toLowerCase() === 'female' && newVideoUrl.trim()) ? newVideoUrl.trim() : undefined,
            target_gender: "universal"
          });\;

content = content.replace(regex, replacement);
fs.writeFileSync(file, content);
console.log("Patched correctly");
