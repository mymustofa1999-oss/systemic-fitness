const fs = require('fs');

let content = fs.readFileSync('../systemic-fitness-api/internal/handler/user.go', 'utf8');

const listClientsSearch = `	input := &service.ListUsersInput{
		Pagination: params,
		Role:       &clientRole,
		CallerRole: callerRole,
		CallerID:   callerID,
	}`;

const listClientsReplace = `	input := &service.ListUsersInput{
		Pagination: params,
		Role:       &clientRole,
		CallerRole: callerRole,
		CallerID:   callerID,
	}

	classQuery := r.URL.Query().Get("classification")
	if classQuery != "" {
		input.Classification = &classQuery
	}`;

content = content.replace(listClientsSearch, listClientsReplace);
fs.writeFileSync('../systemic-fitness-api/internal/handler/user.go', content);
console.log("Patched ListClients in user.go");
