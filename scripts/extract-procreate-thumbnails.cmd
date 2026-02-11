@echo off
setlocal EnableDelayedExpansion

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

echo.
echo Starting extraction of Procreate thumbnails...
echo.

set processed=0

for %%F in (*.procreate) do (
    set /a processed+=1
    set filename=%%F
    set basename=%%~nF
    set output=!basename!.png

    REM Use PowerShell to extract Thumbnail.png
    powershell -NoProfile -Command ^
        "try { ^
            Add-Type -AssemblyName System.IO.Compression.FileSystem; ^
            $zip=[IO.Compression.ZipFile]::OpenRead('%%F'); ^
            $entry=$zip.GetEntry('QuickLook/Thumbnail.png'); ^
            if($entry){ ^
                $out=[IO.File]::Create('!output!'); ^
                $entry.Open().CopyTo($out); ^
                $out.Close(); ^
                $zip.Dispose(); ^
                exit 0 ^
            } else { ^
                $zip.Dispose(); ^
                exit 2 ^
            } ^
        } catch { exit 1 }"

    if !errorlevel! == 0 (
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
        )
    ) else (
        set /a fail+=1
        echo !filename!: Could not extract Thumbnail.png>>problems.log
    )

    set /a percent=(processed*100)/total

    <nul set /p ="Processed: !processed!/!total!  (!percent!%%)  OK: !ok!  Failed: !fail!     `r"
)

echo.
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
