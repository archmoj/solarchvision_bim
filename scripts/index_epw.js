// you may require to increase the memory limit for node.js when calling this program e.g.
// node --max-old-space-size=5000 scripts/index_epw.js

'use strict';

var fs = require('fs');

var inFolder = '/home/solarch/org/solarchvision_bim/input/climate/TMYEPW/'; // input
var outIndex = '/home/solarch/org/solarchvision_bim/input/coordinates/TMYEPW.txt'; // output

var allFilenames = fs.readdirSync(inFolder).sort();
var allHeads = ['________,City,Province,Country,TMY-type,WMO,Latitude,Longitude,Time Zone,Elevation,Filename'];

for(var i = 0; i < allFilenames.length; i++) {
    var filename = allFilenames[i];
    var len = filename.length;
    if(filename.substring(len - 4) === '.epw') {
        var head = fs.readFileSync(inFolder + filename, {encoding:'utf8', flag:'r'}).split('\n')[0];
        allHeads.push(head.replace('\r', '') + ',' + filename.substring(0, len - 4));
    }
}

fs.writeFile(outIndex, allHeads.join('\n'), 'utf8', function () {
    console.log('Saved ' + outIndex);
});
