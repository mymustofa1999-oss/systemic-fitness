const fs = require('fs');
const path = '../systemic-fitness-api/internal/handler/trainer_card.go';
let content = fs.readFileSync(path, 'utf8');

content = content.replace(/GetTrainingCard/g, 'GetByCustomerID');

fs.writeFileSync(path, content, 'utf8');
