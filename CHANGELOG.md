# Changelog

## v1.0.4 – 2026-02-13
- Windows CMD script now requires **installed 7-Zip (7z.exe)** for extraction.
- Removed/disabled the portable `7zr.exe` path because it can fail to open `.procreate` ZIP archives reliably on some systems.
- README updated to reflect the “installed 7-Zip only” requirement for the CMD script.

## v1.0.3 – 2026-02-13
- Windows CMD script now uses 7-Zip (7z/7zr) instead of PowerShell for thumbnail extraction.
- CMD script prints simple progress updates during processing.
- README updated with 7-Zip setup instructions for CMD.

## v1.0.2 – 2026-02-11
- Fix CMD script with progress

## v1.0.1 – 2026-02-11
- Fix README and normalize line endings

## v1.0.0 – 2026-02-11
- Initial release with Linux, PowerShell, and CMD scripts
- Extracts QuickLook/Thumbnail.png from Procreate files
- Adds progress display and logs failures

