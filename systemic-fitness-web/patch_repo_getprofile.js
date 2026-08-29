const fs = require('fs');

let content = fs.readFileSync('../systemic-fitness-api/internal/repository/user_repo.go', 'utf8');

const s1 = "district, province, postal_code, country";
const s2 = "FROM user_profiles WHERE user_id = $1";
const s3 = "&p.District, &p.Province, &p.PostalCode, &p.Country,";
const s4 = ")";

// Make sure we only replace in GetProfile, not UpsertProfile!
// Find index of GetProfile
const idx = content.indexOf("func (r *UserRepository) GetProfile(");
if (idx !== -1) {
    let before = content.substring(0, idx);
    let after = content.substring(idx);
    
    after = after.replace(s1, "district, province, postal_code, country, classification");
    after = after.replace(s3, "&p.District, &p.Province, &p.PostalCode, &p.Country, &p.Classification,");
    
    content = before + after;
    fs.writeFileSync('../systemic-fitness-api/internal/repository/user_repo.go', content);
    console.log("Patched GetProfile successfully");
} else {
    console.log("GetProfile not found");
}
