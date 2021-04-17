'use strict';

var outFolder = '/home/solarch/org/solarchvision_bim/input/climate/TMYEPW/';
var fs = require('fs');
var https = require('https');

var currentFiles = fs.readdirSync(outFolder);

function getFilename(str) {
    var parts = str.split('/');
    return parts[parts.length - 1];
}

function getURL(url, cb) {
    https.get(url, function (res) {
        var str = '';

        res.on('data', function (chunk) {
            str += chunk;
        });

        res.on('end', function () {
            return cb(str);
        });
    }).on('error', function (error) {
        console.error(error.message);
    });
}

getURL(
    'https://gist.githubusercontent.com/Myoldmopar/8c58eba49c0a40fdbbfd8cce36a0a96e/raw/830a33ec7e57aec610446d02c53e664c711c48d6/master.geojson',
    function (geoStr) {
        var list = JSON.parse(geoStr).features.map(function (a) {
            return a.properties.epw;
        });

        list = list.map(function (a) {
            var hrefStart = a.indexOf('=') + 1;
            var hrefEnd = a.indexOf('>');
            return a.substring(hrefStart, hrefEnd);
        });

        var download = function (n) {
            var url = list[n];
            if (!url) return;

            // skip when already exist
            if (currentFiles.indexOf(getFilename(url)) !== -1) {
                // download next
                return download(n + 1);
            }

            getURL(url, function (str) {
                var filepath = outFolder + getFilename(url);
                console.log('downloading:', url);

                fs.writeFile(filepath, str, 'utf8', function () {
                    console.log('downloaded:', filepath);

                    // download next
                    return download(n + 1);
                });
            });
        };

        // download first
        download(0);
    }
);
