const fs = require('fs');
const file = 'systemic-fitness-api/internal/repository/trainer_card_repo.go';
let content = fs.readFileSync(file, 'utf8');

const target = '\t\t\t\t\tINSERT INTO trainer_card_set_items\n' +
'\t\t\t\t\t    (id, set_id, movement_id, movement_name, body_part, equipment, reps, sets_count, sort_order,\n' +
'\t\t\t\t\t     breathing_core, breathing_diaphragm, allowed_tiers)\n' +
'\t\t\t\t\t VALUES (, , , , , , , , , , , , )\n' +
'\t\t\t\t\t ON CONFLICT (id) DO UPDATE SET\n' +
'\t\t\t\t\t     movement_id = EXCLUDED.movement_id, movement_name = EXCLUDED.movement_name, body_part = EXCLUDED.body_part, equipment = EXCLUDED.equipment,\n' +
'\t\t\t\t\t     reps = EXCLUDED.reps, sets_count = EXCLUDED.sets_count, sort_order = EXCLUDED.sort_order,\n' +
'\t\t\t\t\t     breathing_core = EXCLUDED.breathing_core, breathing_diaphragm = EXCLUDED.breathing_diaphragm, allowed_tiers = EXCLUDED.allowed_tiers = EXCLUDED.video_url_snapshot, updated_at = NOW()';

const replacement = '\t\t\t\t\tINSERT INTO trainer_card_set_items\n' +
'\t\t\t\t\t    (id, set_id, movement_id, movement_name, body_part, equipment, reps, sets_count, sort_order,\n' +
'\t\t\t\t\t     breathing_core, breathing_diaphragm, allowed_tiers, video_url_snapshot)\n' +
'\t\t\t\t\t VALUES (, , , , , , , , , , , , )\n' +
'\t\t\t\t\t ON CONFLICT (id) DO UPDATE SET\n' +
'\t\t\t\t\t     movement_id = EXCLUDED.movement_id, movement_name = EXCLUDED.movement_name, body_part = EXCLUDED.body_part, equipment = EXCLUDED.equipment,\n' +
'\t\t\t\t\t     reps = EXCLUDED.reps, sets_count = EXCLUDED.sets_count, sort_order = EXCLUDED.sort_order,\n' +
'\t\t\t\t\t     breathing_core = EXCLUDED.breathing_core, breathing_diaphragm = EXCLUDED.breathing_diaphragm, allowed_tiers = EXCLUDED.allowed_tiers, video_url_snapshot = EXCLUDED.video_url_snapshot, updated_at = NOW()';

if (content.includes(target)) {
    content = content.replace(target, replacement);
    fs.writeFileSync(file, content);
    console.log("Patched string successfully");
} else {
    console.log("Target not found!");
}
