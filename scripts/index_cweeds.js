// you may require to increase the memory limit for node.js when calling this program e.g.
// node --max-old-space-size=8000 scripts/index_cweeds.js

'use strict';

var fs = require('fs');

var inFolder = '/home/solarch/org/solarchvision_bim/input/climate/CWEEDS/'; // input
var outIndex = '/home/solarch/org/solarchvision_bim/input/coordinates/CWEEDS.txt'; // output

var allFilenames = fs.readdirSync(inFolder).sort();
var allHeads = ['________,City,Province,Country,StationId,Latitude,Longitude,Time Zone,Elevation,Filename'];

for(var i = 0; i < allFilenames.length; i++) {
    var filename = allFilenames[i];
    var len = filename.length;
    if(filename.substring(len - 4) === '.WY3') {
        var head = fs.readFileSync(inFolder + filename, {encoding:'utf8', flag:'r'}).split('\n')[0];
        allHeads.push(head.replace('\r', '') + ',' + filename.substring(0, len - 4));
    }
}

fs.writeFile(outIndex, allHeads.join('\n'), 'utf8', function () {
    console.log('Saved ' + outIndex);
});
