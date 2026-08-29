const fs = require('fs');

function fixRepo() {
	const path = '../systemic-fitness-api/internal/repository/trainer_card_repo.go';
	let content = fs.readFileSync(path, 'utf8');

	content = content.replace(/,\s*video_url_snapshot/g, '');
	content = content.replace(/video_url_snapshot\s*=\s*EXCLUDED\.video_url_snapshot,\s*/g, '');
	content = content.replace(/,\s*item\.VideoURLSnapshot/g, '');

	fs.writeFileSync(path, content, 'utf8');
}

function fixHandler() {
	const path = '../systemic-fitness-api/internal/handler/trainer_card.go';
	let content = fs.readFileSync(path, 'utf8');
	
	content = content.replace(/VideoURLSnapshot:\s*itemIn\.VideoURLSnapshot,/g, '');
	
	fs.writeFileSync(path, content, 'utf8');
}

fixRepo();
fixHandler();
console.log("fixed snapshot issue");
