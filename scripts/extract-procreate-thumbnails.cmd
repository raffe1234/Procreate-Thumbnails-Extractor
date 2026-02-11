@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM extract-procreate-thumbnails.cmd
REM
REM Copyright (C) 2026 raffe
REM
REM This program is free software: you can redistribute it and/or modify
REM it under the terms of the GNU General Public License as published by
REM the Free Software Foundation, either version 3 of the License, or
REM (at your option) any later version.
REM
REM This program is distributed in the hope that it will be useful,
REM but WITHOUT ANY WARRANTY; without even the implied warranty of
REM MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
REM See the GNU General Public License for more details.
REM
REM You should have received a copy of the GNU General Public License
REM along with this program. If not, see <https://www.gnu.org/licenses/>.
REM Copyright (C) 2026 raffe
REM Licensed under GNU GPL v3 or later
REM
REM Requires: Windows 10/11 with PowerShell 5+ (default installed)
REM
REM Usage:
REM   Place this script in the directory containing your .procreate files
REM   and execute it.
REM
REM   Make sure your folder doesn’t have filenames with special 
REM   characters like & or ^ — CMD can be tricky there.
REM 
REM Windows CMD:
REM   extract-procreate-thumbnails.cmd
REM 
REM If you get an execution policy error, first run:
REM   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
REM
REM ============================================================

set total=0
set ok=0
set fail=0

echo Counting .procreate files...

for %%F in (*.procreate) do (
    set /a total+=1
)

if %total%==0 (
    echo No .procreate files found.
    goto :end
)

REM --- Progress setup: report about every 10% (no percent math) ---
set /a step=total/10
if %step% LSS 1 set step=1
set next_report=%step%

echo.
echo Starting extraction of Procreate thumbnails...
echo.

REM --- Create a temporary PowerShell script (extractor) ---
set "PS1=%TEMP%\extract-procreate-thumb-%RANDOM%%RANDOM%.ps1"

> "%PS1%"  echo param([string]$Procreate,[string]$Out)
>>"%PS1%"  echo Add-Type -AssemblyName System.IO.Compression.FileSystem
>>"%PS1%"  echo try {
>>"%PS1%"  echo   $zip = [IO.Compression.ZipFile]::OpenRead($Procreate)
>>"%PS1%"  echo   $entry = $zip.GetEntry('QuickLook/Thumbnail.png')
>>"%PS1%"  echo   if ($entry) {
>>"%PS1%"  echo     $outStream = [IO.File]::Create($Out)
>>"%PS1%"  echo     $entry.Open().CopyTo($outStream)
>>"%PS1%"  echo     $outStream.Close()
>>"%PS1%"  echo     $zip.Dispose()
>>"%PS1%"  echo     exit 0
>>"%PS1%"  echo   } else {
>>"%PS1%"  echo     $zip.Dispose()
>>"%PS1%"  echo     exit 2
>>"%PS1%"  echo   }
>>"%PS1%"  echo } catch { exit 1 }

set processed=0

for %%F in (*.procreate) do (
    set /a processed+=1
    set "filename=%%F"
    set "basename=%%~nF"
    set "output=!basename!.png"

    REM --- SIMPLE PROGRESS (before extraction) ---
    if !processed! GEQ !next_report! (
        echo Progress: !processed!/!total!   OK: !ok!   Failed: !fail!
        set /a next_report+=step
    )

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Procreate "%%F" -Out "!output!"
    set "psErr=!errorlevel!"

    if !psErr! == 0 (
        if exist "!output!" (
            for %%S in ("!output!") do (
                if %%~zS gtr 0 (
                    set /a ok+=1
                ) else (
                    del "!output!" >nul 2>&1
                    set /a fail+=1
                    echo !filename!: Empty PNG file>>problems.log
                )
            )
        ) else (
            set /a fail+=1
            echo !filename!: Output file not created>>problems.log
        )
    ) else (
        set /a fail+=1
        if !psErr! == 2 (
            echo !filename!: Thumbnail.png not found>>problems.log
        ) else (
            echo !filename!: Could not extract Thumbnail.png (code !psErr!)>>problems.log
        )
    )
)

del "%PS1%" >nul 2>&1

echo Progress: %total%/%total%   OK: %ok%   Failed: %fail%

echo.
echo Done!
echo Total files processed: %processed%
echo Succeeded:             %ok%
echo Failed:                %fail%

if %fail% gtr 0 (
    echo.
    echo Problems that occurred:
    type problems.log
)

:end
endlocal
exit /b 0

