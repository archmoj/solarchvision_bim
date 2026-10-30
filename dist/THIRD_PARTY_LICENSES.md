# Third-party licenses

SOLARCHVISION-BIM's own source code is licensed under the GNU General Public
License v2 — see [`LICENSE.md`](LICENSE.md). The libraries it bundles in
`dist/lib/` (and, for macOS, `Contents/Java/`) are each under their own,
separate license, listed below.

Where a jar ships its own license text inside itself, that's noted as
**"bundled in the jar"** — the most exact source there is, since it travels
with the exact bytes actually shipped. Where it doesn't, the link below is
pinned to an **exact commit or version tag**, not a `master`/`main` branch
head, so it won't drift out from under this list later. A couple of links
(marked below) follow each project's own documented tag-naming convention
rather than one independently loaded here — worth a quick check against the
jar's own `META-INF/MANIFEST.MF` if anything looks off.

## Processing core and bundled libraries — LGPL-2.1

`core-4.5.2.jar`, `pdf.jar`, `svg.jar`

Processing's core library (and its `pdf`/`svg` output libraries, which ship
in the same jar family) is licensed under the GNU Lesser General Public
License v2.1. The rest of Processing — the PDE itself, not used here — is
GPL-2.0.

- Full text, pinned to the exact Processing release this build uses
  (`processing-1313-4.5.2`, the same tag `build-dist.sh`/`dist.yml` build
  against):
  [`LICENSE.md` @ processing-1313-4.5.2](https://github.com/processing/processing4/blob/processing-1313-4.5.2/LICENSE.md)

## JOGL / GlueGen (JogAmp) — New BSD (2- and 3-clause)

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

## iText 2.1.7 — MPL-1.1 / LGPL-2.1 (dual-licensed)

`itext-2.1.7.jar`

This is the last iText release before the project moved to AGPL (5.x+) — it
carries its own dual MPL-1.1/LGPL-2.1 license, bundled directly in the jar:
`com/lowagie/text/apache_license.txt` and `com/lowagie/text/misc_licenses.txt`.

## Bouncy Castle 1.38 — Bouncy Castle License (MIT-style)

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

## Apache Commons — Apache License 2.0

`commons-compress-1.28.0.jar`, `commons-io-2.22.0.jar`, `commons-logging-1.3.0.jar`

Each bundles its own `META-INF/LICENSE.txt` and `META-INF/NOTICE.txt`.
Pinned links, following the Apache Commons project's own
`rel/<module>-<version>` release-tag convention (not independently loaded
here — check the bundled copy above first if these 404):

- [commons-compress `LICENSE.txt` @ rel/commons-compress-1.28.0](https://github.com/apache/commons-compress/blob/rel/commons-compress-1.28.0/LICENSE.txt)
- [commons-io `LICENSE.txt` @ rel/commons-io-2.22.0](https://github.com/apache/commons-io/blob/rel/commons-io-2.22.0/LICENSE.txt)
- [commons-logging `LICENSE.txt` @ rel/commons-logging-1.3.0](https://github.com/apache/commons-logging/blob/rel/commons-logging-1.3.0/LICENSE.txt)

## Apache xml-commons / XML Graphics Commons — Apache License 2.0

`xml-apis-1.4.01.jar`, `xml-apis-ext-1.3.04.jar`, `xmlgraphics-commons-2.11.jar`

All three bundle the full Apache License 2.0 text directly
(`license/LICENSE` in the `xml-apis*` jars, `META-INF/LICENSE` in
`xmlgraphics-commons`) — confirmed by extracting and reading each.

## ANTLR 2.7.7 — ANTLR Software Rights Notice (public-domain-style)

`antlr-2.7.7.jar`

ANTLR used a public-domain-style notice through version 2.x, before moving
to a BSD license for 3.0+. SPDX catalogs this exact notice as `ANTLR-PD`:
[SPDX: ANTLR-PD](https://spdx.org/licenses/ANTLR-PD.html).

## JetBrains Annotations 13.0 — Apache License 2.0

`annotations-13.0.jar`

Declared directly in the jar's own bundled Maven `pom.xml`
(`META-INF/maven/org.jetbrains/annotations/pom.xml`) as "The Apache Software
License, Version 2.0". Full text:
[Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt).

## Kotlin Standard Library 2.2.20 — Apache License 2.0

`kotlin-stdlib-2.2.20.jar`

Pinned link, following Kotlin's own `vX.Y.Z` release-tag convention (not
independently loaded here):
[`license/LICENSE.txt` @ v2.2.20](https://github.com/JetBrains/kotlin/blob/v2.2.20/license/LICENSE.txt).

---

This list covers `dist/lib/` as it stood for the build this file shipped
with — see that build's own `version.json` for the exact commit. If a
future dependency bump adds, removes, or re-versions a jar, this file needs
updating alongside it; it isn't generated automatically.
