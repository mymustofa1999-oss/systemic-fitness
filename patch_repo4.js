const fs = require('fs');
const file = 'systemic-fitness-api/internal/repository/trainer_card_repo.go';
let content = fs.readFileSync(file, 'utf8');

content = content.replace(
    /breathing_core, breathing_diaphragm, allowed_tiers\)/g,
    'breathing_core, breathing_diaphragm, allowed_tiers, video_url_snapshot)'
);

fs.writeFileSync(file, content);
console.log("Patched 13th column successfully");
