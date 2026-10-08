@echo off
rem Windows equivalent of run-with-latest-processing.sh - see that file's comments for
rem context on the symlink step and the Processing 4.5.x CLI generally.
rem
rem Run this from the repo root, same as run-with-latest-processing.sh.
setlocal

if "%PROCESSING_HOME%"=="" set "PROCESSING_HOME=%USERPROFILE%\processing\4.5.7"

rem The Windows portable build lays out one directory level shallower than
rem the Linux one (Processing.exe + app\ + runtime\ directly under
rem PROCESSING_HOME, no lib\ wrapper), so the resources\core folder
rem run-with-latest-processing.sh symlinks into is at app\resources\core
rem here, not lib\app\resources\core.
set "CORE=%PROCESSING_HOME%\app\resources\core"

if not exist "projects" mkdir "projects"

rem mklink /J (a directory junction) is used instead of /D (a true
rem symlink) specifically because junctions don't require Administrator
rem privileges or Developer Mode on Windows - /D would otherwise fail for
rem most users straight out of the box. rmdir first since mklink refuses
rem to (re)create a link where something already exists - same effect as
rem ln -sfn's overwrite-if-exists behavior in run-with-latest-processing.sh.
if exist "%CORE%\input" rmdir "%CORE%\input"
mklink /J "%CORE%\input" "%CD%\input" >nul

if exist "%CORE%\import" rmdir "%CORE%\import"
mklink /J "%CORE%\import" "%CD%\import" >nul

if exist "%CORE%\command" rmdir "%CORE%\command"
mklink /J "%CORE%\command" "%CD%\command" >nul

if exist "%CORE%\projects" rmdir "%CORE%\projects"
mklink /J "%CORE%\projects" "%CD%\projects" >nul

if "%~1"=="" (
    "%PROCESSING_HOME%\Processing.exe" cli --sketch=app\src\solarchvision_bim --run
) else (
    "%PROCESSING_HOME%\Processing.exe" cli --sketch=app\src\solarchvision_bim --run %*
)
