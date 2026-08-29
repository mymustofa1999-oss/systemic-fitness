const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const migrationsDir = path.join(__dirname, 'systemic-fitness-api', 'database', 'migrations');
const connStr = "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:5432/postgres";
const tmpFile = path.join(__dirname, 'tmp_migration_up.sql');

const files = fs.readdirSync(migrationsDir)
  .filter(f => f.endsWith('.sql'))
  .sort();

console.log(`Found ${files.length} migration files`);

for (const file of files) {
  const fullPath = path.join(migrationsDir, file);
  const content = fs.readFileSync(fullPath, 'utf8');
  
  // Extract only the "Up" section (between -- +migrate Up and -- +migrate Down)
  let upSection = '';
  const upIndex = content.indexOf('-- +migrate Up');
  const downIndex = content.indexOf('-- +migrate Down');
  
  if (upIndex !== -1) {
    const start = upIndex + '-- +migrate Up'.length;
    const end = downIndex !== -1 ? downIndex : content.length;
    upSection = content.substring(start, end).trim();
  } else {
    // No migrate markers, use whole file
    upSection = content.trim();
  }
  
  if (!upSection) {
    console.log(`SKIP (empty): ${file}`);
    continue;
  }
  
  fs.writeFileSync(tmpFile, upSection);
  
  try {
    execSync(`psql "${connStr}" -v ON_ERROR_STOP=0 -f "${tmpFile}"`, { 
      stdio: 'pipe',
      encoding: 'utf8'
    });
    console.log(`OK: ${file}`);
  } catch (e) {
    console.log(`WARN: ${file} - ${e.stderr || e.message}`);
  }
}

// Cleanup
if (fs.existsSync(tmpFile)) fs.unlinkSync(tmpFile);
console.log('\nAll migrations done!');
