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

set "BARW=30"

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

    set /a percent=(processed*100)/total
    call :showProgress !percent! !total! !ok! !fail! %BARW%
)

REM Finish the progress line with a newline
echo.

del "%PS1%" >nul 2>&1

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

:showProgress
REM args: percent total ok fail barw
setlocal EnableExtensions
set "P=%~1"
set "T=%~2"
set "O=%~3"
set "F=%~4"
set "W=%~5"

powershell.exe -NoProfile -Command ^
  "$p=%P%; $w=%W%; $filled=[int]($p*$w/100);" ^
  "$bar=('#'*$filled)+('-'*($w-$filled));" ^
  "$msg=('[{0}] {1,3}%  Total: {2}  OK: {3}  Failed: {4}' -f $bar,$p,%T%,%O%,%F%);" ^
  "Write-Host -NoNewline (\"`r\" + $msg.PadRight(120))"

endlocal & exit /b 0


