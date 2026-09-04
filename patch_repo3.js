const fs = require('fs');
const file = 'systemic-fitness-api/internal/repository/trainer_card_repo.go';
let content = fs.readFileSync(file, 'utf8');

content = content.replace(
    'item.BreathingCore, item.BreathingDiaphragm, nonNilTiers(item.AllowedTiers),',
    'item.BreathingCore, item.BreathingDiaphragm, nonNilTiers(item.AllowedTiers), nil,'
);

fs.writeFileSync(file, content);
console.log("Patched 13th arg successfully");
