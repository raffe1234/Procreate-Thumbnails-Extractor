@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM extract-procreate-thumbnails-7zip.cmd
REM
REM Extracts QuickLook\Thumbnail.png from each .procreate file and
REM saves it as a .png with the same base filename.
REM
REM A .procreate file is a ZIP archive. The embedded preview is at:
REM   QuickLook\Thumbnail.png
REM
REM REQUIREMENTS (choose one):
REM
REM Option A (portable, no install):
REM   1) Download 7zr.exe from 7-zip.org (console executable)
REM      Put 7zr.exe in the SAME folder as:
REM        - your .procreate files
REM        - this .cmd script
REM
REM Option B (install 7-Zip):
REM   1) Install 7-Zip (Windows installer)
REM   2) This script will try common locations:
REM        %ProgramFiles%\7-Zip\7z.exe
REM        %ProgramFiles(x86)%\7-Zip\7z.exe
REM      (or you can add 7-Zip to PATH)
REM
REM USAGE:
REM   Place this script in the folder containing your .procreate files
REM   then run:
REM     extract-procreate-thumbnails-7zip.cmd
REM
REM OUTPUT:
REM   file.procreate -> file.png
REM   failures are logged to problems.log
REM ============================================================

REM ---- Find 7-Zip console executable ----
set "SEVENZIP="

REM Prefer portable exe in the same folder as this script:
if exist "%~dp07zr.exe" set "SEVENZIP=%~dp07zr.exe"
if not defined SEVENZIP if exist "%~dp07z.exe"  set "SEVENZIP=%~dp07z.exe"

REM Common install paths:
if not defined SEVENZIP if exist "%ProgramFiles%\7-Zip\7z.exe" set "SEVENZIP=%ProgramFiles%\7-Zip\7z.exe"
if not defined SEVENZIP if exist "%ProgramFiles(x86)%\7-Zip\7z.exe" set "SEVENZIP=%ProgramFiles(x86)%\7-Zip\7z.exe"

if not defined SEVENZIP (
    echo ERROR: Could not find 7zr.exe or 7z.exe.
    echo Put 7zr.exe next to this script, or install 7-Zip.
    exit /b 1
)

echo Using 7-Zip: "%SEVENZIP%"
echo.

REM ---- Count .procreate files ----
set "total=0"
for %%F in (*.procreate) do set /a total+=1

if %total%==0 (
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
