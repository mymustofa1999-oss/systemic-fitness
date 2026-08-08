const fs = require('fs');
const path = 'C:/Users/ITBDG/Documents/SystemicFitness-Handover/CLEAN/systemic-fitness-web/src/app/(dashboard)/clients/[id]/live-session/page.tsx';
let c = fs.readFileSync(path, 'utf8');

const regex = /breathing_diaphragm: set\.breathing_diaphragm \|\| "-",\s*seqIndex: sIdx,/;
const replaceStr = `breathing_diaphragm: set.breathing_diaphragm || "-",
              equip_upper: set.equipment_upper || "-",
              equip_lower: set.equipment_lower || "-",
              seqIndex: sIdx,`;

if (c.match(regex)) {
    c = c.replace(regex, replaceStr);
    fs.writeFileSync(path, c, 'utf8');
    console.log('Fixed equip_upper and equip_lower');
} else {
    console.log('Could not find regex match!');
}
