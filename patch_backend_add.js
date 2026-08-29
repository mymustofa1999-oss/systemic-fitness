const fs = require('fs');

// 1. Handler
let handlerPath = 'systemic-fitness-api/internal/handler/digital_library.go';
let handlerCode = fs.readFileSync(handlerPath, 'utf8');
handlerCode = handlerCode.replace(
\		Section      *string \\\json:"section,omitempty"\\\\,
\		Section      *string \\\json:"section,omitempty"\\\
		TargetGender *string \\\json:"target_gender,omitempty"\\\\
);
handlerCode = handlerCode.replace(
\	if err := h.dlService.AddModulCardItem(r.Context(), req.LevelID, req.MovementID, req.CategoryCode, req.SetName, req.GroupType, req.Section); err != nil {\,
\	if err := h.dlService.AddModulCardItem(r.Context(), req.LevelID, req.MovementID, req.CategoryCode, req.SetName, req.GroupType, req.Section, req.TargetGender); err != nil {\
);
fs.writeFileSync(handlerPath, handlerCode);

// 2. Service
let svcPath = 'systemic-fitness-api/internal/service/digital_library_service.go';
let svcCode = fs.readFileSync(svcPath, 'utf8');
svcCode = svcCode.replace(
\unc (s *DigitalLibraryService) AddModulCardItem(ctx context.Context, levelID string, movementID string, categoryCode *string, setName *string, groupType *string, section *string) error {
	err := s.dlRepo.AddModulCardItem(ctx, levelID, movementID, categoryCode, setName, groupType, section)\,
\unc (s *DigitalLibraryService) AddModulCardItem(ctx context.Context, levelID string, movementID string, categoryCode *string, setName *string, groupType *string, section *string, targetGender *string) error {
	err := s.dlRepo.AddModulCardItem(ctx, levelID, movementID, categoryCode, setName, groupType, section, targetGender)\
);
fs.writeFileSync(svcPath, svcCode);

// 3. Repo
let repoPath = 'systemic-fitness-api/internal/repository/digital_library_repo.go';
let repoCode = fs.readFileSync(repoPath, 'utf8');
repoCode = repoCode.replace(
\unc (r *DigitalLibraryRepository) AddModulCardItem(ctx context.Context, levelID string, movementID string, categoryCode *string, setName *string, groupType *string, section *string) error {\,
\unc (r *DigitalLibraryRepository) AddModulCardItem(ctx context.Context, levelID string, movementID string, categoryCode *string, setName *string, groupType *string, section *string, targetGender *string) error {\
);
// In the loop where it inserts:
repoCode = repoCode.replace(
\		_, err = tx.Exec(ctx, \\\\\
			INSERT INTO dl_menu_items (level_id, movement_id, sequence, set_track, group_type, section, sort_order)
			VALUES (, , , , , , )
		\\\\\, levelID, movementID, catCode, sName, gType, sect, nextSort)\,
\		_, err = tx.Exec(ctx, \\\\\
			INSERT INTO dl_menu_items (level_id, movement_id, sequence, set_track, group_type, section, target_gender, sort_order)
			VALUES (, , , , , , , )
		\\\\\, levelID, movementID, catCode, sName, gType, sect, targetGender, nextSort)\
);
fs.writeFileSync(repoPath, repoCode);
console.log("Backend patched!");
