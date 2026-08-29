const fs = require('fs');

let content = fs.readFileSync('../systemic-fitness-api/internal/repository/user_repo.go', 'utf8');

const search = `	// Trainer scoping: only show assigned clients
	joinClause := ""
	
	// Classification filtering
	if filter.Classification != nil {
		joinClause += " LEFT JOIN user_profiles up ON u.id = up.user_id "
		where = append(where, fmt.Sprintf("up.classification = $%d", argIdx))
		args = append(args, *filter.Classification)
		argIdx++
	}

	if filter.TrainerID != nil {
		joinClause = fmt.Sprintf("JOIN trainer_clients tc ON u.id = tc.client_id AND tc.trainer_id = $%d AND tc.status = 'active'", argIdx)
		args = append(args, *filter.TrainerID)
		argIdx++
	}`;

const replace = `	// ALWAYS include user_profiles since userPrefixedColumns references 'up'
	joinClause := " LEFT JOIN user_profiles up ON u.id = up.user_id "
	
	// Classification filtering
	if filter.Classification != nil {
		where = append(where, fmt.Sprintf("up.classification = $%d", argIdx))
		args = append(args, *filter.Classification)
		argIdx++
	}

	// Trainer scoping: only show assigned clients
	if filter.TrainerID != nil {
		joinClause += fmt.Sprintf(" JOIN trainer_clients tc ON u.id = tc.client_id AND tc.trainer_id = $%d AND tc.status = 'active' ", argIdx)
		args = append(args, *filter.TrainerID)
		argIdx++
	}`;

content = content.replace(search, replace);
fs.writeFileSync('../systemic-fitness-api/internal/repository/user_repo.go', content);
console.log("Patched user_repo.go");
