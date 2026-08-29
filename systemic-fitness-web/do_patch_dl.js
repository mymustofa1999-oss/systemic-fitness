const fs = require('fs');
const path = '../systemic-fitness-api/internal/service/digital_library_service.go';
let content = fs.readFileSync(path, 'utf8');

const targetFunctionStart = 'func (s *DigitalLibraryService) UpdateMovement(ctx context.Context, id string, input *UpdateMovementInput) (*repository.DLMovement, error) {';
const targetFunctionEnd = '	s.logger.Info("dl movement updated", "id", id)\n	return existing, nil\n}';

const startIndex = content.indexOf(targetFunctionStart);
if (startIndex === -1) throw new Error("Could not find start");
const endIndex = content.indexOf(targetFunctionEnd, startIndex) + targetFunctionEnd.length;
if (content.indexOf(targetFunctionEnd, startIndex) === -1) throw new Error("Could not find end");

const replacement = \unc (s *DigitalLibraryService) UpdateMovement(ctx context.Context, id string, input *UpdateMovementInput, explicitNulls []string) (*repository.DLMovement, error) {
	existing, err := s.dlRepo.GetMovementByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update dl movement: fetch", "id", id, "error", err)
		}
		return nil, err
	}

	// Helper to check if a JSON key was explicitly sent as null
	isNull := func(field string) bool {
		for _, v := range explicitNulls {
			if v == field {
				return true
			}
		}
		return false
	}

	// ALWAYS update required fields because they are explicitly validated
	existing.Name = input.Name
	existing.BodyPart = input.BodyPart
	existing.Categories = input.Categories
	existing.IsActive = input.IsActive

	// ONLY update optional fields if they are explicitly provided in the JSON payload
	if input.VideoURLMale != nil {
		existing.VideoURLMale = input.VideoURLMale
	} else if isNull("video_url_male") {
		existing.VideoURLMale = nil
	}
	
	if input.VideoURLFemale != nil {
		existing.VideoURLFemale = input.VideoURLFemale
	} else if isNull("video_url_female") {
		existing.VideoURLFemale = nil
	}
	
	if input.ImageURL != nil {
		existing.ImageURL = input.ImageURL
	} else if isNull("image_url") {
		existing.ImageURL = nil
	}
	
	if input.Instructions != nil {
		existing.Instructions = input.Instructions
	} else if isNull("instructions") {
		existing.Instructions = nil
	}
	
	if input.Type != nil {
		existing.Type = input.Type
	} else if isNull("type") {
		existing.Type = nil
	}
	
	if input.Pattern != nil {
		existing.Pattern = input.Pattern
	} else if isNull("pattern") {
		existing.Pattern = nil
	}
	
	if input.Level != nil {
		existing.Level = input.Level
	} else if isNull("level") {
		existing.Level = nil
	}
	
	if input.NameEN != nil {
		existing.NameEN = input.NameEN
	} else if isNull("name_en") {
		existing.NameEN = nil
	}
	
	if input.InstructionsEN != nil {
		existing.InstructionsEN = input.InstructionsEN
	} else if isNull("instructions_en") {
		existing.InstructionsEN = nil
	}
	
	if input.DescriptionEN != nil {
		existing.DescriptionEN = input.DescriptionEN
	} else if isNull("description_en") {
		existing.DescriptionEN = nil
	}
	
	if input.TargetGender != nil {
		existing.TargetGender = input.TargetGender
	} else if isNull("target_gender") {
		existing.TargetGender = nil
	}

	if err := s.dlRepo.UpdateMovement(ctx, existing); err != nil {
		s.logger.Error("update dl movement: save", "id", id, "error", err)
		return nil, err
	}
	s.logger.Info("dl movement updated", "id", id)
	return existing, nil
}\;

content = content.substring(0, startIndex) + replacement + content.substring(endIndex);
fs.writeFileSync(path, content, 'utf8');
console.log("Patched successfully");
