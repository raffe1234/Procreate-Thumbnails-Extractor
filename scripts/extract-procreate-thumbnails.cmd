@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM extract-procreate-thumbnails.cmd
REM
REM Extract QuickLook\Thumbnail.png from each .procreate file and save it
REM as a .png with the same base filename.
REM
REM A .procreate file is a ZIP archive. The embedded preview is at:
REM   QuickLook\Thumbnail.png
REM
REM REQUIREMENTS (Windows 10/11):
REM   - Install 7-Zip (recommended): https://www.7-zip.org/download.html
REM     (Install the "7-Zip for Windows" package.)
REM
REM IMPORTANT:
REM   - This script uses the installed 7-Zip CLI: 7z.exe
REM   - The small "7zr.exe" (standalone) is NOT supported here because it
REM     cannot open ZIP archives reliably for this use-case (it is mainly
REM     for 7z archives), so .procreate extraction will fail.
REM
REM USAGE:
REM   1) Copy this .cmd file into the folder that contains your .procreate files
REM   2) Run it from Command Prompt (CMD):
REM        extract-procreate-thumbnails.cmd
REM
REM OUTPUT:
REM   file.procreate -> file.png
REM   failures are logged to problems.log
REM
REM NOTES / LIMITATIONS:
REM   - CMD can be fragile with special characters in filenames (e.g. &, ^, !).
REM     If you have such filenames, prefer the PowerShell script.
REM ============================================================

REM ---- Find installed 7z.exe ----
set "SEVENZIP="

REM Try PATH first
for /f "delims=" %%P in ('where 7z.exe 2^>nul') do (
    set "SEVENZIP=%%P"
    goto :found7z
)

REM Try common install paths
if exist "%ProgramFiles%\7-Zip\7z.exe" set "SEVENZIP=%ProgramFiles%\7-Zip\7z.exe"
if not defined SEVENZIP if exist "%ProgramFiles(x86)%\7-Zip\7z.exe" set "SEVENZIP=%ProgramFiles(x86)%\7-Zip\7z.exe"

:found7z
if not defined SEVENZIP (
    echo ERROR: Could not find 7z.exe.
    echo Install 7-Zip from https://www.7-zip.org/ and try again.
    exit /b 1
)

echo Using 7-Zip: "%SEVENZIP%"
echo.

REM ---- Count .procreate files ----
set "total=0"
for %%F in (*.procreate) do set /a total+=1

if %total% EQU 0 (
    echo No .procreate files found.
    exit /b 0
)

echo Starting extraction of Procreate thumbnails...
echo.

REM Progress: print about every 10% (no percent math inside loop)
set /a step=(total+9)/10
if %step% LSS 1 set "step=1"
set /a next_report=step

REM Optional: clear old log
del problems.log 2>nul

set "processed=0"
set "ok=0"
set "fail=0"

for %%F in (*.procreate) do (
    set /a processed+=1
    set "out=%%~nF.png"

    REM --- progress milestone (about 10%, 20%, ...) ---
    if !processed! GEQ !next_report! (
        echo Progress: !processed!/!total!   OK: !ok!   Failed: !fail!
        set /a next_report+=step
    )

    REM Extract QuickLook\Thumbnail.png to stdout and redirect to file
    "%SEVENZIP%" e -y -so "%%F" "QuickLook\Thumbnail.png" > "!out!" 2>nul

    if errorlevel 1 (
        set /a fail+=1
        del "!out!" >nul 2>&1
        echo %%F: Could not extract QuickLook\Thumbnail.png>>problems.log
    ) else (
        if not exist "!out!" (
            set /a fail+=1
            echo %%F: Output file not created>>problems.log
        ) else (
            for %%S in ("!out!") do (
                if %%~zS GTR 0 (
                    set /a ok+=1
                ) else (
                    set /a fail+=1
                    del "!out!" >nul 2>&1
                    echo %%F: Empty PNG file>>problems.log
                )
            )
        )
    )
)

echo.
echo Done!
echo Total files processed: %processed%
echo Succeeded:             %ok%
echo Failed:                %fail%

if exist problems.log (
    echo.
    echo Problems that occurred:
    type problems.log
)

exit /b 0
