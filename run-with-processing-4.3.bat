@echo off
rem Windows equivalent of run-with-processing-4.3.sh - see that file's comments for context.
rem run-with-processing-4.3.sh hardcodes ~/processing/4.3.4/processing-java with no override,
rem so this does the same with its Windows equivalent rather than adding
rem flexibility the original doesn't have either.

if "%~1"=="" (
    "%USERPROFILE%\processing\4.3.4\processing-java.exe" --sketch=app\src\solarchvision_bim --run
) else (
    "%USERPROFILE%\processing\4.3.4\processing-java.exe" --sketch=app\src\solarchvision_bim --run --args %*
)
