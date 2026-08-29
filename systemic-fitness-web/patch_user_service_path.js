const fs = require('fs');

let service = fs.readFileSync('../systemic-fitness-api/internal/service/user_service.go', 'utf8');

const profileUpdateSearch = `	// 4. Update profile if any profile fields were provided
	hasProfileUpdate := input.DateOfBirth != nil || input.Gender != nil ||`;

const profileUpdateReplace = `	// 4. Update profile if any profile fields were provided
	if input.Classification != nil {
		if callerRole != model.RoleAdmin && callerRole != model.RoleConsultant && callerRole != model.RoleOwner {
			return nil, fmt.Errorf("unauthorized: only admin and consultant can change classification")
		}
	}

	hasProfileUpdate := input.DateOfBirth != nil || input.Gender != nil || input.Classification != nil ||`;

service = service.replace(profileUpdateSearch, profileUpdateReplace);

const profileStructSearch = `			Province:          input.Province,
			PostalCode:        input.PostalCode,
			Country:           input.Country,
		}`;
const profileStructReplace = `			Province:          input.Province,
			PostalCode:        input.PostalCode,
			Country:           input.Country,
			Classification:    input.Classification,
		}`;

service = service.replace(profileStructSearch, profileStructReplace);
fs.writeFileSync('../systemic-fitness-api/internal/service/user_service.go', service);
console.log("Patched user_service.go with auth");
