const fs = require('fs');

// Fix ClientFormModal.tsx
let modal = fs.readFileSync('src/components/shared/ClientFormModal.tsx', 'utf8');
modal = modal.replace('const { session } = useAuth();', 'const { user } = useAuth();');
modal = modal.replace(
  'const isAuthorized = session?.user?.role === "admin" || session?.user?.role === "owner" || session?.user?.role === "consultant";',
  'const isAuthorized = user?.role === "admin" || user?.role === "owner" || user?.role === "consultant";'
);
fs.writeFileSync('src/components/shared/ClientFormModal.tsx', modal);

// Fix user_service.go
let service = fs.readFileSync('internal/service/user_service.go', 'utf8');

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
fs.writeFileSync('internal/service/user_service.go', service);
console.log("Patched both!");
