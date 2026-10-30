# SOLARCHVISION-BIM — pre-built binaries

This folder contains ready-to-run builds of SOLARCHVISION-BIM for Linux, Windows,
and macOS. See the [project README](../README.md) for what the application does
and how to use it once it's running.

## Contents

| File / folder                              | Platform              |
|---------------------------------------------|------------------------|
| `solarchvision_bim_linux-amd64`              | Linux (x86-64)         |
| `solarchvision_bim_windows-amd64.exe`        | Windows (x86-64)       |
| `solarchvision_bim_macos-x86_64.app`         | macOS, Intel           |
| `solarchvision_bim_macos-aarch64.app`        | macOS, Apple Silicon (M1/M2/M3/M4) |
| `lib/`, `data/`                              | Shared libraries and assets — must stay alongside the executable/app above |
| `source/`                                    | Preprocessed Java source this build was compiled from |
| `version.json`                               | Exact commit, branch, and Processing version this build came from |

Don't move an executable or `.app` out of this folder on its own — it depends on
`lib/` and `data/` sitting right next to it.

## Requirements: Java 17+ (all platforms)

These builds do **not** bundle a Java runtime (embedding one breaks the macOS
export, so it's left out everywhere for consistency). You need Java 17 or newer
installed yourself:

- **Windows/macOS:** most machines have no Java at all by default — install one,
  e.g. [Eclipse Temurin 17](https://adoptium.net/) or `brew install openjdk@17` on macOS.
- **Linux:** install a *full* JRE/JDK, not a headless one. Headless packages
  (e.g. Debian/Ubuntu's `openjdk-*-jre-headless`) are missing `libawt_xawt.so` /
  `libjawt.so`, so the app can't open a window at all — you'll just get
  "Cannot run sketch without a display" regardless of `DISPLAY` or Xvfb.
  Install the regular package instead, e.g. `sudo apt install openjdk-17-jre`.

Check your version with `java -version`.

## Running it

### Windows

Double-click `solarchvision_bim_windows-amd64.exe`.

### Linux

```sh
chmod +x solarchvision_bim_linux-amd64   # if it isn't already executable
./solarchvision_bim_linux-amd64
```

### macOS

1. Pick the build matching your Mac's chip — Apple menu → **About This Mac** tells
   you whether you have Apple Silicon or Intel.
2. **The app is unsigned**, so macOS Gatekeeper will block a normal double-click
   the first time. To get past that:
   - **Right-click (Control-click) the `.app` → Open** — not a double-click.
   - Click **Open** again in the confirmation dialog.
   - After this first right-click-open, it launches normally from then on.
   - If macOS still refuses (e.g. "app is damaged" from the quarantine flag on
     a downloaded ZIP), clear it from Terminal instead:
     ```sh
     xattr -cr solarchvision_bim_macos-aarch64.app   # or the x86_64 build
     ```
   - Alternatively: **System Settings → Privacy & Security** usually shows an
     "Open Anyway" button right after a blocked first launch attempt.

## Troubleshooting

- **"Cannot run sketch without a display" (Linux):** your JRE is headless — see
  Requirements above.
- **"A null PFont was passed to textFont()" on startup:** `data/font/` isn't
  next to the executable — make sure you kept the whole `dist/` folder together
  rather than copying out just the one executable or `.app`.
- **App won't open at all (macOS):** see the Gatekeeper steps above; a plain
  double-click on an unsigned app is expected to fail the first time.
- **Still stuck?** Check `version.json` for the exact commit this build came
  from, and open an issue on the [GitHub repo](https://github.com/archmoj/solarchvision_bim)
  with that commit hash plus your OS/Java version.
