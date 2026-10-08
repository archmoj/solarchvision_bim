@echo off
setlocal enabledelayedexpansion
rem Downloads this build's input/ assets (left out by default to keep
rem the download small - see build-dist.sh's own INCLUDE_INPUT) from
rem this exact build's own commit, read from version.json shipped
rem alongside this script, rather than whatever the repository's main
rem branch currently is - so what gets installed always matches what
rem this particular build was actually tested against. Same logic as
rem install-assets.sh - see its own comment for more.
rem
rem Needs git (for a shallow, blob-filtered, sparse-checkout clone) and
rem PowerShell (bundled with Windows since Vista/Server 2008, used only
rem to read version.json's JSON - nothing else).

cd /d "%~dp0"

if exist input (
  echo input\ is already here - nothing to do ^(delete it first to re-download^).
  exit /b 0
)

where git >nul 2>nul
if errorlevel 1 (
  echo error: git is required to download these assets.
  echo        install it from https://git-scm.com/downloads, then re-run this script.
  exit /b 1
)

if not exist version.json (
  echo error: version.json is missing - can't tell which commit's assets to fetch.
  exit /b 1
)

for /f "usebackq delims=" %%c in (`powershell -NoProfile -Command "(Get-Content version.json | ConvertFrom-Json).commit"`) do set COMMIT=%%c
for /f "usebackq delims=" %%r in (`powershell -NoProfile -Command "(Get-Content version.json | ConvertFrom-Json).repository"`) do set REPO_URL=%%r

if "%COMMIT%"=="" (
  echo error: couldn't read "commit" out of version.json.
  exit /b 1
)
if "%REPO_URL%"=="" (
  echo error: couldn't read "repository" out of version.json.
  exit /b 1
)

echo ==^> Fetching input\ from %REPO_URL% at %COMMIT%

set "TMP_DIR=%TEMP%\solarchvision_bim_assets_%RANDOM%"

git clone --no-checkout --filter=blob:none --quiet "%REPO_URL%.git" "%TMP_DIR%"
if errorlevel 1 goto :fail

pushd "%TMP_DIR%"
git fetch --quiet --depth 1 origin %COMMIT%
if errorlevel 1 goto :fail_popped
git sparse-checkout init --cone
git sparse-checkout set input/coordinates input/images/worldmap input/images/earth input/images/moon input/images/sun input/images/people input/images/trees
if errorlevel 1 goto :fail_popped
git checkout --quiet FETCH_HEAD
if errorlevel 1 goto :fail_popped
popd

rem Same selection, same empty-climate-folders convention, as
rem build-dist.sh's own INCLUDE_INPUT=1 path - see its comment on why
rem those four specifically are left empty rather than fetched too,
rem rather than guessing at something different here.
mkdir input\climate\CWEEDS
mkdir input\climate\CLMREC
mkdir input\climate\TMYEPW
mkdir input\climate\NAEFS
xcopy /e /i /q "%TMP_DIR%\input\coordinates" input\coordinates >nul
mkdir input\images
for %%F in (worldmap earth moon sun people trees) do (
  xcopy /e /i /q "%TMP_DIR%\input\images\%%F" "input\images\%%F" >nul
)

rmdir /s /q "%TMP_DIR%"
echo ==^> Done - input\ is ready.
exit /b 0

:fail_popped
popd
:fail
echo error: failed to fetch assets from %REPO_URL% at %COMMIT%.
if exist "%TMP_DIR%" rmdir /s /q "%TMP_DIR%"
exit /b 1
