const fs = require('fs');
const file = 'systemic-fitness-api/internal/repository/trainer_card_repo.go';
let content = fs.readFileSync(file, 'utf8');

content = content.replace(
    'allowed_tiers = EXCLUDED.allowed_tiers = EXCLUDED.video_url_snapshot',
    'allowed_tiers = EXCLUDED.allowed_tiers, video_url_snapshot = EXCLUDED.video_url_snapshot'
);

content = content.replace(
    'breathing_core, breathing_diaphragm, allowed_tiers)\n\t\t\t\t\t VALUES (, , , , , , , , , , , , )',
    'breathing_core, breathing_diaphragm, allowed_tiers, video_url_snapshot)\n\t\t\t\t\t VALUES (, , , , , , , , , , , , )'
);

// We also need to actually supply the 13th argument to batch.Queue for trainer_card_set_items!
// Wait, is VideoURLSnapshot in the Go struct?
// In UpsertCard, the item.VideoURLMale / VideoURLFemale are not in the query.
// But we need to add the 13th argument. Where does video_url_snapshot come from?
// The Training Card Snapshot architecture:
// When a movement is saved, we don't save the video snapshot in the Upsert. The service or handler might be doing it. Or we just save NULL for now.
// Let's check where batch.Queue is called.

fs.writeFileSync(file, content);
console.log("Patched successfully");
