const fs = require('fs');

let content = fs.readFileSync('../systemic-fitness-api/internal/repository/user_repo.go', 'utf8');

// Fix List
content = content.replace(
`		if err := rows.Scan(
			&u.ID, &u.Email, &u.PasswordHash, &u.FullName,
			&u.Phone, &u.AvatarURL, &u.Role, &u.Status,
			&u.Timezone, &u.CreatedAt, &u.UpdatedAt, &u.DeletedAt,
			&u.NeedsReassessment,
		); err != nil {`,
`		if err := rows.Scan(
			&u.ID, &u.Email, &u.PasswordHash, &u.FullName,
			&u.Phone, &u.AvatarURL, &u.Role, &u.Status,
			&u.Timezone, &u.CreatedAt, &u.UpdatedAt, &u.DeletedAt,
			&u.Classification,
			&u.NeedsReassessment,
		); err != nil {`);

// Fix ListTeamMembers
content = content.replace(
`		if err := rows.Scan(&u.ID, &u.Email, &u.PasswordHash, &u.FullName,
			&u.Phone, &u.AvatarURL, &u.Role, &u.Status,
			&u.Timezone, &u.CreatedAt, &u.UpdatedAt, &u.DeletedAt); err != nil {`,
`		if err := rows.Scan(&u.ID, &u.Email, &u.PasswordHash, &u.FullName,
			&u.Phone, &u.AvatarURL, &u.Role, &u.Status,
			&u.Timezone, &u.CreatedAt, &u.UpdatedAt, &u.DeletedAt,
			&u.Classification); err != nil {`);

fs.writeFileSync('../systemic-fitness-api/internal/repository/user_repo.go', content);
console.log("Patched user_repo.go Scan methods");
