const fs = require('fs');

const male = JSON.parse(fs.readFileSync('dups_male.json'));
const female = JSON.parse(fs.readFileSync('dups_female.json'));

function analyzeDups(dupsObj) {
    let duplicateNames = 0;
    let identicalUrls = 0;
    let differentUrls = 0;
    
    for (const [name, rows] of Object.entries(dupsObj)) {
        duplicateNames++;
        // check if all URLs are the same (normalize waitlist and youtube links if possible, but strict check first)
        const uniqueUrls = new Set(rows.map(r => {
            if (!r.url) return 'waitlist';
            let u = r.url.replace('https://www.youtube.com/watch?v=', 'https://youtu.be/');
            // strip query params for comparison? 
            if (u.includes('?')) u = u.split('?')[0];
            return u;
        }));
        
        if (uniqueUrls.size === 1) {
            identicalUrls++;
        } else {
            differentUrls++;
        }
    }
    
    return { duplicateNames, identicalUrls, differentUrls };
}

const maleStats = analyzeDups(male);
const femaleStats = analyzeDups(female);

console.log('MALE:', maleStats);
console.log('FEMALE:', femaleStats);

// Let's count unique names total
console.log('Total male unique names:', Object.keys(male).length);
