<#
extract-procreate-thumbnails.ps1

Copyright (C) 2026 raffe

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.

Requires: Windows 10/11 with PowerShell 5+ (default installed)

Usage:
  Place this script in the directory containing your .procreate files
  and execute it.

Windows PowerShell:
  .\extract-procreate-thumbnails.ps1

If you get an execution policy error, first run:
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
	   
#>

Add-Type -AssemblyName System.IO.Compression.FileSystem

$files = Get-ChildItem -Filter *.procreate -File

if (-not $files) {
    Write-Host "No .procreate files found."
    exit 0
}

$total = 0
$ok = 0
$fail = 0
$problems = @()

$numberOfFiles = $files.Count

Write-Host "Starting extraction of Procreate thumbnails..."

foreach ($file in $files) {

    $total++

    $percent = [int](($total / $numberOfFiles) * 100)

    Write-Progress `
        -Activity "Extracting thumbnails" `
        -Status "Processed $total of $numberOfFiles" `
        -PercentComplete $percent

    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $outputFile = Join-Path $file.DirectoryName "$baseName.png"

    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($file.FullName)
        $entry = $zip.GetEntry("QuickLook/Thumbnail.png")

        if ($entry -ne $null) {
            $entryStream = $entry.Open()
            $fileStream = [System.IO.File]::Create($outputFile)
            $entryStream.CopyTo($fileStream)

            $fileStream.Close()
            $entryStream.Close()

            if ((Get-Item $outputFile).Length -gt 0) {
                $ok++
            }
            else {
                Remove-Item $outputFile -ErrorAction SilentlyContinue
                $fail++
                $problems += "$($file.Name): Empty PNG file"
            }
        }
        else {
            $fail++
            $problems += "$($file.Name): Could not find QuickLook/Thumbnail.png"
        }

        $zip.Dispose()
    }
    catch {
        $fail++
        $problems += "$($file.Name): Could not open archive"
    }
}

Write-Progress -Activity "Extracting thumbnails" -Completed

Write-Host ""
Write-Host "Done!"
Write-Host "Total files processed: $total"
Write-Host "Succeeded:             $ok"
Write-Host "Failed:                $fail"

if ($fail -gt 0) {
    Write-Host ""
    Write-Host "Problems that occurred:"
    $problems | ForEach-Object { Write-Host $_ }
}
