const fs = require('fs');
const path = '../systemic-fitness-api/internal/handler/trainer_card.go';
let content = fs.readFileSync(path, 'utf8');

content = content.replace(/TargetGender\s*:\s*input\.TargetGender,\s*/g, '');

fs.writeFileSync(path, content, 'utf8');
