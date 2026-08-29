const fs = require('fs');
let code = fs.readFileSync('systemic-fitness-api/internal/repository/digital_library_repo.go', 'utf8');

const updateFunc = `func (r *DigitalLibraryRepository) UpdateMenuItem(ctx context.Context, id string, videoUrlMale *string, videoUrlFemale *string) error {
\t_, err := r.db.Exec(ctx, "UPDATE dl_menu_items SET video_url_male = $1, video_url_female = $2, updated_at = now() WHERE id = $3", videoUrlMale, videoUrlFemale, id)
\treturn err
}

`;

code = code.replace('func (r *DigitalLibraryRepository) DeleteMenuItem', updateFunc + 'func (r *DigitalLibraryRepository) DeleteMenuItem');
fs.writeFileSync('systemic-fitness-api/internal/repository/digital_library_repo.go', code);
