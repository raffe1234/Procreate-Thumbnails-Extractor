# Procreate Thumbnails Extractor

Extract QuickLook thumbnails (`QuickLook/Thumbnail.png`) from `.procreate` files.

A `.procreate` file is a ZIP archive. This project extracts the embedded thumbnail image into a `*.png`
file with the same base filename.

## Manual method (Windows, 7-Zip)

1. Right-click a `.procreate` file → (Win 11 More options →) **7-Zip** → **Open archive**
2. Open the `QuickLook` folder
3. Extract `Thumbnail.png`
4. Rename it to match the Procreate filename, e.g. `Artwork.png`

## Scripts

All scripts look for `.procreate` files in the folder you run them from, and write `*.png` next to them.

### Linux / macOS (Shell)

**Requirements:** `unzip`

```sh
chmod +x scripts/extract-procreate-thumbnails.sh
./scripts/extract-procreate-thumbnails.sh
```

### Windows PowerShell

```powershell
# Optional (only for the current terminal session):
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

.\scripts\extract-procreate-thumbnails.ps1
```

### Windows CMD

```bat
scripts\extract-procreate-thumbnails.cmd
```

## Output

For each `file.procreate`, the script writes `file.png` in the same folder.

If a file is missing a thumbnail, the scripts skip it and (for CMD) log it to `problems.log`.

## Project structure

```
Procreate-Thumbnails-Extractor/
├─ scripts/
│  ├─ extract-procreate-thumbnails.sh
│  ├─ extract-procreate-thumbnails.ps1
│  └─ extract-procreate-thumbnails.cmd
├─ README.md
├─ LICENSE
├─ CHANGELOG.md
├─ VERSION
└─ .gitignore
```

## License

GPL-3.0-or-later
