# Third-party licenses, assets, and data sources

SOLARCHVISION-BIM's own source code is licensed under the GNU General Public
License v2 — see [`LICENSE.md`](LICENSE.md). Three other kinds of
third-party material are involved beyond that, each covered in its own
section below:

1. **Bundled software libraries** — the jars in `dist/lib/` (and, for
   macOS, `Contents/Java/`).
2. **Bundled creative assets** — the font and imagery under `src/solarchvision_bim/data/`
   and `input/images/`, which ship inside `solarchvision_bim.jar`/the
   `data/` folder, not as separate files someone would notice.
3. **External data sources and live APIs** — not bundled at all; fetched
   over the network at runtime (weather/climate data, elevation, satellite
   imagery), each under the issuing service's own terms rather than a
   software license as such.

Where a jar ships its own license text inside itself, that's noted as
**"bundled in the jar"** — the most exact source there is, since it travels
with the exact bytes actually shipped. Where it doesn't, the link below is
pinned to an **exact commit or version tag**, not a `master`/`main` branch
head, so it won't drift out from under this list later. A couple of links
(marked below) follow each project's own documented tag-naming convention
rather than one independently loaded here — worth a quick check against the
jar's own `META-INF/MANIFEST.MF` if anything looks off.

## 1. Bundled software libraries

### Processing core and bundled libraries — LGPL-2.1

`core-4.5.2.jar`, `pdf.jar`, `svg.jar`

Processing's core library (and its `pdf`/`svg` output libraries, which ship
in the same jar family) is licensed under the GNU Lesser General Public
License v2.1. The rest of Processing — the PDE itself, not used here — is
GPL-2.0.

- Full text, pinned to the exact Processing release this build uses
  (`processing-1313-4.5.2`, the same tag `build-dist.sh`/`dist.yml` build
  against):
  [`LICENSE.md` @ processing-1313-4.5.2](https://github.com/processing/processing4/blob/processing-1313-4.5.2/LICENSE.md)

### JOGL / GlueGen (JogAmp) — New BSD (2- and 3-clause)

`jogl-all-2.6.0.jar`, `jogl-all-2.6.0-natives-*.jar`, `jogl-all-main-2.6.0.jar`,
`gluegen-rt-2.6.0.jar`, `gluegen-rt-2.6.0-natives-*.jar`, `gluegen-rt-main-2.6.0.jar`

Mostly the Simplified ("New") BSD 2-clause license (the GlueGen runtime jar
specifically under the New BSD 3-clause license), with a handful of other
BSD/Apache-licensed files mixed in — see each project's own `LICENSE.txt`
for the full breakdown.

- JOGL — pinned to the exact commit this jar's own
  `META-INF/MANIFEST.MF` (`Implementation-Commit`) says it was built from:
  [`LICENSE.txt` @ f596460](https://github.com/JogAmp/jogl/blob/f5964604d3e940c07c3e6af884f06b4eceb08dd4/LICENSE.txt)
- GlueGen — same, pinned to its own manifest's `Implementation-Commit`:
  [`LICENSE.txt` @ c06493e](https://github.com/JogAmp/gluegen/blob/c06493e448332ace78721f5dfc3718c863783a12/LICENSE.txt)

### iText 2.1.7 — MPL-1.1 / LGPL-2.1 (dual-licensed)

`itext-2.1.7.jar`

This is the last iText release before the project moved to AGPL (5.x+) — it
carries its own dual MPL-1.1/LGPL-2.1 license, bundled directly in the jar:
`com/lowagie/text/apache_license.txt` and `com/lowagie/text/misc_licenses.txt`.

### Bouncy Castle 1.38 — Bouncy Castle License (MIT-style)

`bcprov-jdk14-1.38.jar`, `bcmail-jdk14-1.38.jar`, `bcmail-jdk14-138.jar`,
`bctsp-jdk14-1.38.jar`

All four are the same `org.bouncycastle` release (`1.38.0` per each jar's own
`Implementation-Version`), under the Bouncy Castle License — permissive,
MIT-style. The license text itself is compiled directly into
`bcprov-jdk14-1.38.jar` as `org/bouncycastle/LICENSE.class` (confirmed by
extracting and reading it, not assumed) and applies to the whole suite, not
just that one jar. This release predates Bouncy Castle's move to Git/GitHub,
so there's no commit to pin an external link to — the bundled copy above is
the authoritative source for this exact version.

### Apache Commons — Apache License 2.0

`commons-compress-1.28.0.jar`, `commons-io-2.22.0.jar`, `commons-logging-1.3.0.jar`

Each bundles its own `META-INF/LICENSE.txt` and `META-INF/NOTICE.txt`.
Pinned links, following the Apache Commons project's own
`rel/<module>-<version>` release-tag convention (not independently loaded
here — check the bundled copy above first if these 404):

- [commons-compress `LICENSE.txt` @ rel/commons-compress-1.28.0](https://github.com/apache/commons-compress/blob/rel/commons-compress-1.28.0/LICENSE.txt)
- [commons-io `LICENSE.txt` @ rel/commons-io-2.22.0](https://github.com/apache/commons-io/blob/rel/commons-io-2.22.0/LICENSE.txt)
- [commons-logging `LICENSE.txt` @ rel/commons-logging-1.3.0](https://github.com/apache/commons-logging/blob/rel/commons-logging-1.3.0/LICENSE.txt)

### Apache xml-commons / XML Graphics Commons — Apache License 2.0

`xml-apis-1.4.01.jar`, `xml-apis-ext-1.3.04.jar`, `xmlgraphics-commons-2.11.jar`

All three bundle the full Apache License 2.0 text directly
(`license/LICENSE` in the `xml-apis*` jars, `META-INF/LICENSE` in
`xmlgraphics-commons`) — confirmed by extracting and reading each.

### ANTLR 2.7.7 — ANTLR Software Rights Notice (public-domain-style)

`antlr-2.7.7.jar`

ANTLR used a public-domain-style notice through version 2.x, before moving
to a BSD license for 3.0+. SPDX catalogs this exact notice as `ANTLR-PD`:
[SPDX: ANTLR-PD](https://spdx.org/licenses/ANTLR-PD.html).

### JetBrains Annotations 13.0 — Apache License 2.0

`annotations-13.0.jar`

Declared directly in the jar's own bundled Maven `pom.xml`
(`META-INF/maven/org.jetbrains/annotations/pom.xml`) as "The Apache Software
License, Version 2.0". Full text:
[Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt).

### Kotlin Standard Library 2.2.20 — Apache License 2.0

`kotlin-stdlib-2.2.20.jar`

Pinned link, following Kotlin's own `vX.Y.Z` release-tag convention (not
independently loaded here):
[`license/LICENSE.txt` @ v2.2.20](https://github.com/JetBrains/kotlin/blob/v2.2.20/license/LICENSE.txt).

## 2. Bundled creative assets

### Selawik font — SIL Open Font License 1.1

`data/font/selawk.ttf`

Microsoft's Selawik font, bundled for the application's own UI text. Its
full OFL 1.1 text ships right next to it at `data/font/LICENSE.txt` (in both
`src/solarchvision_bim/data/font/` and every `dist/` build's `data/font/`) —
confirmed by reading that file directly, not assumed.

### Earth, high-res Earth, Moon, and Sun imagery — NASA (public domain)

`input/images/earth/`, `input/images/earth_high_res/`, `input/images/moon/`,
`input/images/sun/`

Each of these four folders already carries its own `credit.md` naming NASA
(or NASA's Scientific Visualization Studio / STEREO mission) as the source,
with a link to the original. NASA media is generally not copyrighted (it's
U.S. government work), though NASA still asks for credit — which these
`credit.md` files already give. Nothing new needed here; worth knowing they
exist.

### Scale-figure silhouettes — Dezignus "People Silhouettes" (vector freebie)

`input/images/people/` (43 PNG files)

Source identified and confirmed directly (fetched the live page, still up
at the original URL): [dezignus.com/people-silhouettes](https://dezignus.com/people-silhouettes),
a free vector (EPS) silhouette pack posted November 12, 2007. These PNGs
are individually exported/rendered from that EPS set with transparency
added, not the original file itself — consistent with each one having its
own, slightly different pixel dimensions (checked earlier: not a uniform
grid, which a straight bulk-export would produce).

The site's own stated terms, in its own words rather than a formal license
name: free to use, including for commercial work (web design, print,
illustration, book/CD covers, logos), with one restriction — don't resell
the freebie file itself as-is. No attribution is required to use the
graphics in finished work (a backlink is only asked for if someone writes
a *tutorial about* the freebie itself, not for ordinary use) — but since
this repo doesn't currently credit it anywhere, adding a one-line
`input/images/people/credit.md` (source URL, like the other four image
folders already have) would bring this folder in line with the rest and
cost nothing, now that the source is known. Worth doing regardless of
whether the terms strictly require it.

### World map tiles — provenance still not documented

`input/images/worldmap/` (1,244 tiles, ~131 MB) has **no `credit.md` and
no embedded metadata** (checked directly — EXIF/PNG text chunks are
empty). The tile filenames follow a bounding-box naming pattern consistent
with a WMS export (plausibly the same family of government/NASA sources as
the other imagery, given how this project sources everything else), but
that's an inference, not a confirmed source — unlike `people/` above,
nothing here has actually been tracked down yet. **This is still a real
gap**: if these came from a source with its own license, that should be
recorded the same way the other folders now are, before this gets
redistributed more widely.

### Tree imagery — procedurally generated, not third-party content

`input/images/trees/`

These are rendered output, not photographs or stock art: `scripts/make-tree-pngs/`
generates them using the npm packages `@dgreenheck/ez-tree` and `three`
(see its `package.json`) — a build-time tool, not something bundled into
`dist/`. The generated PNGs themselves aren't a redistributed copy of either
library, so they don't need a license entry the way the jars above do; worth
a quick look at `@dgreenheck/ez-tree`'s own license if that chain ever
matters to you specifically (e.g. a restrictive license could still affect
how its *output* may be used, depending on the exact terms).

### Project logo — not under the code's GPL-2.0

`input/images/logo/SOLARCHVISION.jpg`

The project's own brand asset. Common open-source practice treats a
project's logo/trademark as separate from its code license (the code is
free to reuse under GPL-2.0; the name and logo typically aren't,
independent of that) — worth the maintainer confirming that's the intent
here too, rather than this file assuming it.

## 3. External data sources and live APIs (not bundled)

None of this is shipped in `dist/` — it's fetched over the network the
first time a project actually needs it, each under the issuing service's
own terms rather than a software license. `Land3D.pde` already handles
attribution for two of these itself: every successful elevation or texture
download gets logged to that project's own `elevations.md`/`textures.md`
(via `appendTerrainReference()`), one row per file with its source and URL
— so this section is about knowing the terms exist, not about adding
anything new to the app.

- **Elevation** — [Open-Meteo](https://open-meteo.com/) (`api.open-meteo.com`,
  primary) and [TerrainTap](https://terraintap.com/) (`api.terraintap.com`,
  fallback). Open-Meteo's data is CC BY 4.0 (attribution required); check
  TerrainTap's own terms for its API.
- **Satellite imagery** — [Esri World Imagery](https://www.arcgis.com/home/item.html?id=10df2279f9684e4a9f6a7f08febac2a9)
  (`services.arcgisonline.com`, free/key-less, default) and
  [Google Static Maps](https://developers.google.com/maps/documentation/maps-static)
  (`maps.googleapis.com`, fallback — only used if the person running the
  app supplies their own `GOOGLE_STATIC_MAPS_API_KEY`, since Google retired
  the free tier; see `Land3D.pde`'s own comment on this). Esri's and
  Google's terms both require attribution and place limits on reuse/caching
  — the app's own `textures.md` logging is part of meeting that, but the
  terms themselves go beyond what a log file covers (e.g. Google's
  prohibit some forms of bulk/offline reuse).
- **Weather and climate data** — Environment and Climate Change Canada
  (`climate.weather.gc.ca`, `dd.weather.gc.ca`, `geo.weather.gc.ca`) for
  CWEEDS/CLMREC/NAEFS/SWOB data, under the
  [Open Government Licence – Canada](https://open.canada.ca/en/open-government-licence-canada).
  `input/coordinates/TMYEPW.csv` instead points at
  [Climate.OneBuilding.Org](https://climate.onebuilding.org/) for TMY/EPW
  files (confirmed directly from that CSV's own `URL` column) — a long-running
  free public weather-file repository that asks for credit when used, without
  a single formal license text of its own. None of this data is committed to
  this repo (`input/climate/.gitignore` keeps downloaded files out of git) —
  each person/CI run fetches what it needs.
- **3D building import (`import/*.py`/`.js`, optional, run on demand)** —
  `SOLARCHVISION_OSM_3D_in_obj.py`/`.js` (OpenStreetMap, via Overpass) and
  `SOLARCHVISION_Overture_3D_in_obj.py` (Overture Maps' Buildings theme,
  confirmed ODbL directly against Overture's own release notes) both
  produce `buildings.obj`/`buildings.svs` under the
  **Open Database License (ODbL)** — see `import/README.md`'s own
  "Data sources" table for the full breakdown, including per-script trees
  support. Unlike everything else in this section, ODbL isn't just an
  attribution ask: redistributing a database built from this data (not the
  SOLARCHVISION-BIM project itself, but someone's *own* OBJ/SVS output,
  if they share it onward) carries a share-alike requirement, similar in
  spirit to GPL but for data. None of this output is committed to this
  repo or bundled in `dist/` — the matching GitHub Actions workflows
  (`osm-3d-import-js.yml`, `osm-3d-import-py.yml`,
  `overture-3d-import.yml`) just run the script on demand and hand back
  an ephemeral build artifact to whoever triggered it.
- **X3D viewer (HTML export only)** — `export_objects_HTML.pde` loads
  `x3dom.js`/`x3dom.css` from `x3dom.org`'s own CDN into the exported HTML
  file, not into `dist/` itself. X3DOM is dual-licensed MIT/GPL-3 (confirmed
  from its own `LICENSE` file), so either applies.

### A privacy note on these calls

Every call above is a direct HTTP request from the machine running
SOLARCHVISION-BIM (or `import/`'s scripts) to that service — there's no
proxy or intermediary server of this project's own in between. Two things
that necessarily travel with a direct request like that are worth knowing
if a project's study location is personally identifying (a home address,
say, rather than a public site):

- **The requesting IP address** — standard for any direct HTTP request, and
  enough on its own for the receiving service to derive a rough
  geolocation (ISP/region), independent of anything else in the request.
- **The exact query itself** — most of these calls include the project's
  latitude/longitude directly as a parameter (elevation, satellite
  texture, and Overpass/OSM queries all do this), since that's what makes
  the result useful. Google Static Maps specifically also requires a
  personal or organizational `GOOGLE_STATIC_MAPS_API_KEY`, which Google
  ties to whichever Google Cloud account that key belongs to — a more
  direct identity link than anything else in this list, and the only one
  of these calls where supplying credentials is involved at all.

None of this is particular to SOLARCHVISION-BIM — it's just what a direct
HTTPS request *is* — and whether it matters depends entirely on whether the
location being studied is one the person would rather not have associated
with their network/IP or account in a third party's logs. A few things
someone could **possibly** do about it, each a genuine trade-off rather
than a complete fix:

- **Query a nearby public point instead of the exact address** — offsetting
  the project's coordinates by some distance before fetching elevation,
  imagery, or OSM data decouples the request from the precise location,
  at the cost of the fetched data (terrain, imagery, nearby trees) no
  longer matching the real site exactly.
- **Route the traffic through a VPN or proxy** — addresses the IP-based
  exposure specifically, not the coordinates in the query itself; the
  `import/` scripts already read `HTTPS_PROXY`/`HTTP_PROXY` (documented in
  `import/README.md`, there for corporate-firewall reasons, but usable for
  this too), and `--overpass-url` already lets OSM queries go to a
  self-hosted or different Overpass instance instead of the public ones.
- **Skip `GOOGLE_STATIC_MAPS_API_KEY` entirely** — this is already the
  default: without it, satellite texture downloads stay on Esri's
  key-less endpoint rather than ever reaching Google, avoiding that
  particular account-level link altogether.

This project doesn't control any of the receiving services' own logging,
retention, or data-sharing practices — their own privacy policies (not
this file) are the actual authority on what each one does with a request
once received.

---

This list covers `dist/lib/`, the bundled assets, and the live data sources
as they stood when this file was written — see a build's own `version.json`
for the exact commit. If a future dependency bump, new data source, or new
image folder changes any of this, the relevant section needs updating
alongside it; none of this is generated automatically.
