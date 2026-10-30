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

### World map tiles and scale-figure imagery — provenance not documented

`input/images/worldmap/` (1,244 tiles, ~131 MB) and `input/images/people/`
(43 files) have **no `credit.md` and no embedded metadata** (checked both
directly — EXIF/PNG text chunks are empty). The `worldmap/` tile filenames
follow a bounding-box naming pattern consistent with a WMS export (plausibly
the same family of government/NASA sources as the other imagery, given how
this project sources everything else), but that's an inference, not a
confirmed source — I'm not comfortable asserting a credit I can't verify.
**This is a real gap**: if these came from a source with its own license
(a stock-imagery pack, a specific tile provider), that should be recorded
the same way the other four image folders already are, before this gets
redistributed more widely. Worth the maintainer's own check.

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
- **X3D viewer (HTML export only)** — `export_objects_HTML.pde` loads
  `x3dom.js`/`x3dom.css` from `x3dom.org`'s own CDN into the exported HTML
  file, not into `dist/` itself. X3DOM is dual-licensed MIT/GPL-3 (confirmed
  from its own `LICENSE` file), so either applies.

---

This list covers `dist/lib/`, the bundled assets, and the live data sources
as they stood when this file was written — see a build's own `version.json`
for the exact commit. If a future dependency bump, new data source, or new
image folder changes any of this, the relevant section needs updating
alongside it; none of this is generated automatically.
