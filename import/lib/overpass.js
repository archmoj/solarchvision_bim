"use strict";
/**
 * lib/overpass.js
 *
 * Overpass fetch machinery: mirror fallback, User-Agent (overpass-api.de
 * rejects requests without a descriptive one - see the default below),
 * and 429/504 overload retry-with-pause (matching osmnx's own built-in
 * resilience on the Python side, which our Node client has to do
 * explicitly). This module is the piece a future Overture-sourced Node
 * script would most want to reuse as-is for an optional OSM tree layer,
 * mirroring how solarch_3d_common.py's fetch_features already serves
 * both Python scripts.
 */

const osmtogeojson = require("osmtogeojson");

// Public Overpass mirrors tried in order if --overpass-url isn't given and
// the primary instance is unreachable. Not guaranteed to be complete/current
// coverage -- if your organization runs its own instance, use --overpass-url.
const DEFAULT_OVERPASS_MIRRORS = [
  "https://overpass-api.de/api/interpreter",
  "https://overpass.kumi.systems/api/interpreter",
  "https://overpass.private.coffee/api/interpreter",
];

const DEFAULT_USER_AGENT = "SOLARCHVISION_OSM_3D_in_obj (https://github.com/archmoj/solarchvision_bim)";

class OverpassUnreachableError extends Error {}

function buildBuildingQuery(lat, lon, radius, includeParts) {
  const around = `around:${radius},${lat},${lon}`;
  const clauses = [`way["building"](${around});`, `relation["building"](${around});`];
  if (includeParts) {
    clauses.push(`way["building:part"](${around});`, `relation["building:part"](${around});`);
  }
  return `[out:json][timeout:60];\n(\n  ${clauses.join("\n  ")}\n);\nout body;\n>;\nout skel qt;`;
}

function buildTreeQuery(lat, lon, radius) {
  const around = `around:${radius},${lat},${lon}`;
  return `[out:json][timeout:60];\n(\n  node["natural"="tree"](${around});\n);\nout body;`;
}

// osmnx (used by the Python implementation) retries 429/504 responses
// automatically with a 55s pause before giving up - Overpass's public
// instances return these when they're transiently overloaded, and they
// usually recover. Our own client needs the same resilience explicitly.
const RETRYABLE_HTTP_STATUS = new Set([429, 504]);
const OVERLOAD_RETRY_PAUSE_MS = 55000;
const MAX_OVERLOAD_RETRIES = 5;

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/** Fetch from one Overpass URL, retrying in place (same URL) on a 429 or
 * 504 - a transient "server busy" response, not a real error - up to
 * MAX_OVERLOAD_RETRIES times with a pause between attempts. */
async function fetchWithOverloadRetry(url, query, userAgent) {
  for (let attempt = 0; ; attempt++) {
    try {
      return await fetchOverpassJson(url, query, userAgent);
    } catch (e) {
      const retryable = e && RETRYABLE_HTTP_STATUS.has(e.httpStatus);
      if (!retryable || attempt >= MAX_OVERLOAD_RETRIES) throw e;
      console.error(
        `  ${url} responded HTTP ${e.httpStatus} (server busy); ` +
          `retrying in ${OVERLOAD_RETRY_PAUSE_MS / 1000}s (attempt ${attempt + 1}/${MAX_OVERLOAD_RETRIES}) ...`
      );
      await sleep(OVERLOAD_RETRY_PAUSE_MS);
    }
  }
}

function isConnectionIssue(err) {
  if (err && err.name === "AbortError") return true; // treat a timeout like unreachable -> try next mirror
  const code = err && err.cause && err.cause.code;
  if (code && ["ECONNREFUSED", "ENOTFOUND", "ETIMEDOUT", "ECONNRESET", "EAI_AGAIN"].includes(code)) return true;
  const msg = String((err && err.message) || "");
  return /ECONNREFUSED|ENOTFOUND|ETIMEDOUT|fetch failed|network/i.test(msg);
}

async function fetchOverpassJson(url, query, userAgent, timeoutMs = 90000) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const res = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "User-Agent": userAgent,
        Referer: userAgent,
        Accept: "application/json, text/plain, */*",
      },
      body: "data=" + encodeURIComponent(query),
      signal: controller.signal,
    });
    if (!res.ok) {
      const text = await res.text().catch(() => "");
      const err = new Error(`Overpass returned HTTP ${res.status}: ${text.slice(0, 300)}`);
      err.httpStatus = res.status;
      throw err;
    }
    return await res.json();
  } finally {
    clearTimeout(timer);
  }
}

/** Fetch raw Overpass JSON for `query`, trying each URL in `overpassUrls`
 * in turn (default: DEFAULT_OVERPASS_MIRRORS) and throwing
 * OverpassUnreachableError with an actionable message if all fail to
 * connect. A non-connection error (e.g. a malformed query, or a 406 from
 * a server that still doesn't like our headers) is thrown immediately
 * without wasting retries on other mirrors. */
async function fetchOverpass(query, overpassUrls, userAgent = DEFAULT_USER_AGENT) {
  const urls = overpassUrls || DEFAULT_OVERPASS_MIRRORS;
  let lastErr = null;
  for (let i = 0; i < urls.length; i++) {
    const url = urls[i];
    try {
      return await fetchWithOverloadRetry(url, query, userAgent);
    } catch (e) {
      const retryableElsewhere = isConnectionIssue(e) || RETRYABLE_HTTP_STATUS.has(e && e.httpStatus);
      if (!retryableElsewhere) throw e;
      lastErr = e;
      if (i < urls.length - 1) {
        console.error(`  giving up on ${url} (${e.message.split("\n")[0]}); trying another mirror ...`);
      }
    }
  }
  throw new OverpassUnreachableError(
    "Could not get a successful response from any Overpass API endpoint " +
      `(${urls.join(", ")}) after retries.\n` +
      "This is usually one of two things, not a bug in the script:\n" +
      "  1. Network reachability from this machine (firewall, proxy, DNS, or no internet).\n" +
      "     Test with: `curl -v https://overpass-api.de/api/interpreter`\n" +
      "     If you're behind a proxy, set HTTPS_PROXY/HTTP_PROXY env vars.\n" +
      "  2. The public Overpass service(s) being temporarily overloaded (HTTP 429/504) -\n" +
      "     this was already retried automatically; if it still failed, the service is\n" +
      "     likely under heavy load right now. Waiting a bit and re-running the workflow\n" +
      "     usually resolves it.\n" +
      "  3. If your organization runs a private/self-hosted Overpass instance, or you\n" +
      "     know of a reachable/less-loaded mirror, pass it explicitly: --overpass-url <url>\n",
    { cause: lastErr }
  );
}

/** Fetch buildings (or trees) as a GeoJSON FeatureCollection, with
 * relations/multipolygons already assembled by osmtogeojson. */
async function fetchFeaturesGeoJSON(query, overpassUrls, userAgent) {
  const overpassJson = await fetchOverpass(query, overpassUrls, userAgent);
  return osmtogeojson(overpassJson);
}

module.exports = {
  DEFAULT_OVERPASS_MIRRORS,
  DEFAULT_USER_AGENT,
  OverpassUnreachableError,
  buildBuildingQuery,
  buildTreeQuery,
  RETRYABLE_HTTP_STATUS,
  OVERLOAD_RETRY_PAUSE_MS,
  MAX_OVERLOAD_RETRIES,
  fetchWithOverloadRetry,
  isConnectionIssue,
  fetchOverpassJson,
  fetchOverpass,
  fetchFeaturesGeoJSON,
};
