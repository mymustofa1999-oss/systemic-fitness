const fs = require('fs');

let content = fs.readFileSync('../systemic-fitness-api/internal/service/user_service.go', 'utf8');

content = content.replace(
  'type ListUsersInput struct {\n\tPagination model.PaginationParams\n\tRole       *model.Role\n\tStatus     *model.UserStatus\n\t// Populated by handler from JWT context',
  'type ListUsersInput struct {\n\tPagination model.PaginationParams\n\tRole       *model.Role\n\tStatus     *model.UserStatus\n\tClassification *string\n\t// Populated by handler from JWT context'
);

content = content.replace(
  '	filter := repository.UserListFilter{\n		Role:   input.Role,\n		Status: input.Status,\n		Search: input.Pagination.Search,\n	}',
  '	filter := repository.UserListFilter{\n		Role:   input.Role,\n		Status: input.Status,\n		Search: input.Pagination.Search,\n		Classification: input.Classification,\n	}'
);

fs.writeFileSync('../systemic-fitness-api/internal/service/user_service.go', content);
console.log("Patched ListUsersInput");
