#!/usr/bin/env node
/**
 * sort-csv.js
 *
 * Reads a (potentially large) CSV file line by line, keeps the header
 * (row 1) untouched at the top, sorts all remaining lines as plain
 * strings (whole-line comparison), and writes the result to an output
 * file.
 *
 * Usage:
 *   node sort-csv.js <input.csv> <output.csv> [--desc]
 *
 * Notes on "large" files:
 *   - This script streams the file in with readline so it never loads
 *     the raw file as one giant string, but it DOES hold all lines in
 *     memory as an array to sort them (Array.prototype.sort is the
 *     simplest correct approach and works fine up into the
 *     multi-GB-of-RAM-available / millions-of-rows range).
 *   - If your file is too large to fit in memory at all (e.g. tens of
 *     GB), you need an external merge sort instead (split into sorted
 *     chunks on disk, then k-way merge). Ask and I can write that
 *     version too.
 */

const fs = require('fs');
const readline = require('readline');
const path = require('path');

async function sortCsv(inputPath, outputPath, descending = false) {
  if (!fs.existsSync(inputPath)) {
    throw new Error(`Input file not found: ${inputPath}`);
  }

  const rl = readline.createInterface({
    input: fs.createReadStream(inputPath, { encoding: 'utf8' }),
    crlfDelay: Infinity, // handle \r\n line endings correctly
  });

  let header = null;
  const lines = [];

  console.log(`Reading ${inputPath} ...`);
  let lineCount = 0;

  for await (const line of rl) {
    lineCount++;
    if (lineCount === 1) {
      header = line; // stash the header, don't sort it
      continue;
    }
    // Skip truly empty trailing lines (common at end of CSV files)
    if (line.length === 0 && lineCount > 1) {
      // still keep non-final blank lines if they contain data-less rows;
      // simplest safe behavior: only skip if it's genuinely empty text
      continue;
    }
    lines.push(line);
  }

  console.log(`Read ${lineCount} lines (${lines.length} data rows). Sorting ...`);

  lines.sort((a, b) => {
    if (a < b) return descending ? 1 : -1;
    if (a > b) return descending ? -1 : 1;
    return 0;
  });

  console.log(`Writing sorted output to ${outputPath} ...`);

  const out = fs.createWriteStream(outputPath, { encoding: 'utf8' });

  await new Promise((resolve, reject) => {
    out.on('error', reject);
    out.on('finish', resolve);

    if (header !== null) {
      out.write(header + '\n');
    }
    for (const line of lines) {
      out.write(line + '\n');
    }
    out.end();
  });

  console.log('Done.');
}

function parseArgs(argv) {
  const args = argv.slice(2).filter((a) => a !== '--desc');
  const descending = argv.includes('--desc');
  const [input, output] = args;
  return { input, output, descending };
}

if (require.main === module) {
  const { input, output, descending } = parseArgs(process.argv);

  if (!input || !output) {
    console.error('Usage: node sort-csv.js <input.csv> <output.csv> [--desc]');
    process.exit(1);
  }

  sortCsv(path.resolve(input), path.resolve(output), descending).catch((err) => {
    console.error('Error:', err.message);
    process.exit(1);
  });
}

module.exports = { sortCsv };
