const fs = require('fs');
let content = fs.readFileSync('../systemic-fitness-api/internal/service/user_service.go', 'utf8');

// Replace UpdateUserInput
content = content.replace(
  /Country\s+\*string\s+\`json:"country,omitempty"\`\n\}/,
  'Country          *string  `json:"country,omitempty"`\n\tClassification   *string  `json:"classification,omitempty" validate:"omitempty,oneof=personal group online"`\n}'
);

fs.writeFileSync('../systemic-fitness-api/internal/service/user_service.go', content);
console.log("Patched UpdateUserInput");
