const fs = require('fs');

let content = fs.readFileSync('../systemic-fitness-api/internal/repository/user_repo.go', 'utf8');

content = content.replace(
`			district, province, postal_code, country, classification
		) VALUES ($1, $2::date, $3::gender_type, $4, $5, $6::fitness_goal, $7::experience_level, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
		ON CONFLICT (user_id) DO UPDATE SET`,
`			district, province, postal_code, country, classification
		) VALUES ($1, $2::date, $3::gender_type, $4, $5, $6::fitness_goal, $7::experience_level, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19)
		ON CONFLICT (user_id) DO UPDATE SET`);

fs.writeFileSync('../systemic-fitness-api/internal/repository/user_repo.go', content);
console.log("Patched user_repo UpsertProfile");
