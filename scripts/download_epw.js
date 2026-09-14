// Downloads the weather-data .zip files listed in a CSV (Country, State,
// City/Station, WMO, Source Data, Latitude, Longitude, Time Zone,
// Elevation, URL), extracts the .epw file from each archive, and copies
// it into OUT_FOLDER.
//
// Usage:
//   node scripts/download_epw.js <path-or-url-to-csv>
//
// <path-or-url-to-csv> may be a local file path or an http(s) URL. If
// omitted, it defaults to CSV_PATH below.
//
// Requires Node.js 18+ (uses the built-in global fetch).

const fs = require('fs/promises');
const path = require('path');
const readline = require('readline');
const zlib = require('zlib');

const OUT_FOLDER = path.join(__dirname, '..', 'input', 'climate', 'TMYEPW');
const CSV_PATH = path.join(__dirname, '..', 'input', 'coordinates', 'TMYEPW.csv'); // used when no argument is given

const BAR_WIDTH = 100; // one '█' per percent, matching the header below

// Ffile hosts may reject plain requests with no User-Agent header
// Node's fetch doesn't send one by default the way a browser would,
// so without this every request can come back 403 Forbidden.
const USER_AGENT = 'solarchvision_bim/1.0 (+https://github.com/archmoj/solarchvision_bim)';

const REQUEST_TIMEOUT_MS = 60_000;
const MAX_ATTEMPTS = 3;

function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function fetchWithRetry(url, attempt = 1) {
  try {
    const res = await fetch(url, {
      headers: { 'User-Agent': USER_AGENT },
      signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
    });

    if (!res.ok) {
      throw new Error(`Request failed (${res.status} ${res.statusText}): ${url}`);
    }

    return res;
  } catch (error) {
    if (attempt >= MAX_ATTEMPTS) {
      throw new Error(`${error.message} (gave up after ${attempt} attempts)`);
    }

    await delay(1000 * attempt); // simple linear backoff
    return fetchWithRetry(url, attempt + 1);
  }
}

async function fetchText(url) {
  const res = await fetchWithRetry(url);
  return res.text();
}

async function fetchBuffer(url) {
  const res = await fetchWithRetry(url);
  return Buffer.from(await res.arrayBuffer());
}

// --- CSV parsing -----------------------------------------------------

// A small, dependency-free CSV parser that handles quoted fields
// (including embedded commas, newlines, and "" escaped quotes).
function parseCsv(text) {
  const rows = [];
  let row = [];
  let field = '';
  let inQuotes = false;

  for (let i = 0; i < text.length; i++) {
    const c = text[i];

    if (inQuotes) {
      if (c === '"') {
        if (text[i + 1] === '"') {
          field += '"';
          i += 1;
        } else {
          inQuotes = false;
        }
      } else {
        field += c;
      }
      continue;
    }

    if (c === '"') {
      inQuotes = true;
    } else if (c === ',') {
      row.push(field);
      field = '';
    } else if (c === '\n' || c === '\r') {
      if (c === '\r' && text[i + 1] === '\n') i += 1;
      row.push(field);
      field = '';
      if (row.length > 1 || row[0] !== '') rows.push(row); // skip blank lines
      row = [];
    } else {
      field += c;
    }
  }

  if (field !== '' || row.length > 0) {
    row.push(field);
    rows.push(row);
  }

  return rows;
}

// Turns the parsed rows into objects keyed by the header row, and pulls
// out just the URL column that we actually need.
function parseStationList(csvText) {
  const rows = parseCsv(csvText);
  if (rows.length === 0) return [];

  const header = rows[0].map((h) => h.trim());
  const urlIndex = header.findIndex((h) => h.toLowerCase() === 'url');
  if (urlIndex === -1) {
    throw new Error(`Could not find a "URL" column in the CSV header: ${header.join(', ')}`);
  }

  return rows
    .slice(1)
    .filter((row) => row[0] === "CAN" && row[1] === "ON") // Only download Canada/Ontario
    .filter((row) => row[4] !== "NRC2022v1") // Skip Canada NRC Future climate files

    .map((row) => ({
      station: row[2] || '',
      url: (row[urlIndex] || '').trim(),
    }))
    .filter((entry) => entry.url.length > 0);
}

// --- Minimal zero-dependency zip reader -------------------------------
//
// Just enough of the ZIP format to list a central directory and inflate
// individual entries (STORE and DEFLATE only, which covers the ordinary
// zip files served by climate.onebuilding.org). No ZIP64 support.

const EOCD_SIGNATURE = 0x06054b50;
const CENTRAL_DIR_SIGNATURE = 0x02014b50;
const LOCAL_HEADER_SIGNATURE = 0x04034b50;

function findEndOfCentralDirectory(buf) {
  const minEOCDSize = 22;
  const maxCommentSize = 65535;
  const searchStart = Math.max(0, buf.length - minEOCDSize - maxCommentSize);

  for (let i = buf.length - minEOCDSize; i >= searchStart; i--) {
    if (buf.readUInt32LE(i) === EOCD_SIGNATURE) return i;
  }

  throw new Error('Not a valid zip file (End Of Central Directory record not found)');
}

function listZipEntries(buf) {
  const eocdOffset = findEndOfCentralDirectory(buf);
  const totalEntries = buf.readUInt16LE(eocdOffset + 10);

  let offset = buf.readUInt32LE(eocdOffset + 16);
  const entries = [];

  for (let i = 0; i < totalEntries; i++) {
    if (buf.readUInt32LE(offset) !== CENTRAL_DIR_SIGNATURE) {
      throw new Error('Not a valid zip file (bad central directory signature)');
    }

    const compressionMethod = buf.readUInt16LE(offset + 10);
    const compressedSize = buf.readUInt32LE(offset + 20);
    const filenameLength = buf.readUInt16LE(offset + 28);
    const extraLength = buf.readUInt16LE(offset + 30);
    const commentLength = buf.readUInt16LE(offset + 32);
    const localHeaderOffset = buf.readUInt32LE(offset + 42);
    const filename = buf.toString('utf8', offset + 46, offset + 46 + filenameLength);

    entries.push({ filename, compressionMethod, compressedSize, localHeaderOffset });

    offset += 46 + filenameLength + extraLength + commentLength;
  }

  return entries;
}

function extractZipEntry(buf, entry) {
  const offset = entry.localHeaderOffset;
  if (buf.readUInt32LE(offset) !== LOCAL_HEADER_SIGNATURE) {
    throw new Error(`Bad local file header for ${entry.filename}`);
  }

  const filenameLength = buf.readUInt16LE(offset + 26);
  const extraLength = buf.readUInt16LE(offset + 28);
  const dataStart = offset + 30 + filenameLength + extraLength;
  const compressedData = buf.subarray(dataStart, dataStart + entry.compressedSize);

  if (entry.compressionMethod === 0) return compressedData; // stored, no compression
  if (entry.compressionMethod === 8) return zlib.inflateRawSync(compressedData); // deflate

  throw new Error(`Unsupported zip compression method ${entry.compressionMethod} for ${entry.filename}`);
}

function extractEpwFromZip(buf) {
  const epwEntry = listZipEntries(buf).find((entry) => /\.epw$/i.test(entry.filename));
  if (!epwEntry) {
    throw new Error('No .epw file found inside the zip');
  }

  return {
    filename: path.basename(epwEntry.filename),
    contents: extractZipEntry(buf, epwEntry),
  };
}

// --- Progress bar ------------------------------------------------------

// Prints the percent-marker header once, then keeps a fill bar and a
// "currently processing" line redrawn in place underneath it, so the bar
// stays on one line instead of the terminal scrolling on every update.
class ProgressBar {
  constructor(total) {
    this.total = total;
    this.linesDrawn = false;

    console.log('       10%       20%       30%       40%       50%       60%       70%       80%       90%       100%');
    console.log('.........|.........|.........|.........|.........|.........|.........|.........|.........|.........|');
  }

  update(done, label) {
    const percent = this.total === 0 ? BAR_WIDTH : Math.floor((done / this.total) * BAR_WIDTH);
    const bar = '█'.repeat(Math.min(Math.max(percent, 0), BAR_WIDTH));

    if (this.linesDrawn) {
      readline.moveCursor(process.stdout, 0, -2);
      readline.cursorTo(process.stdout, 0);
      readline.clearScreenDown(process.stdout);
    }

    process.stdout.write(bar + '\n');
    process.stdout.write(label + '\n');

    this.linesDrawn = true;
  }

  finish(label) {
    this.update(this.total, label);
  }
}

// --- Main ----------------------------------------------------------

async function loadCsv(source) {
  if (/^https?:\/\//i.test(source)) {
    return fetchText(source);
  }
  return fs.readFile(source, 'utf8');
}

async function downloadEpwFiles(csvSource) {
  let currentFiles;
  try {
    currentFiles = await fs.readdir(OUT_FOLDER);
  } catch (error) {
    throw new Error(`Could not read the output folder ${OUT_FOLDER}: ${error.message}`);
  }

  let csvText;
  try {
    csvText = await loadCsv(csvSource);
  } catch (error) {
    throw new Error(`Could not load the station list from ${csvSource}: ${error.message}`);
  }

  const currentFileSet = new Set(currentFiles);
  const stations = parseStationList(csvText);

  const bar = new ProgressBar(stations.length);
  const errors = [];

  // Downloaded one at a time (not in parallel) to avoid hammering the server.
  for (let i = 0; i < stations.length; i++) {
    const { station, url } = stations[i];

    // The .epw inside a climate.onebuilding.org zip is conventionally
    // named the same as the zip itself, just with a .epw extension -
    // check for that up front so already-downloaded stations can be
    // skipped without downloading their zip again.
    const guessedFilename = path.basename(url).replace(/\.zip$/i, '.epw');

    if (currentFileSet.has(guessedFilename)) {
      bar.update(i, `up to date: ${guessedFilename}`);
      continue;
    }

    bar.update(i, `downloading: ${station || guessedFilename}`);

    try {
      const zipBuffer = await fetchBuffer(url);
      const epw = extractEpwFromZip(zipBuffer);

      const filepath = path.join(OUT_FOLDER, epw.filename);
      await fs.writeFile(filepath, epw.contents);
    } catch (error) {
      // Deferred rather than printed immediately, so it doesn't get
      // interleaved with (and corrupt) the in-place progress bar.
      errors.push(`${station || url}: ${error.message}`);
    }
  }

  bar.finish('done.');

  if (errors.length > 0) {
    console.error(`\n${errors.length} station(s) failed to download:`);
    errors.forEach((message) => console.error(' -', message));
  }
}

const csvSource = process.argv[2] || CSV_PATH;

downloadEpwFiles(csvSource).catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
