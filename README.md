# Procreate Thumbnails Extractor

Extract QuickLook thumbnails (`QuickLook/Thumbnail.png`) from `.procreate` files.

A `.procreate` file is a ZIP archive. This project extracts the embedded thumbnail image into a `*.png`
file with the same base filename, so you can preview your artwork quickly in file explorers (e.g. Windows Explorer).

## Manual method (Windows, 7-Zip)

**Requirements:** `7-zip`
- Install 7-Zip using the Windows installer from the 7-Zip download page.

1. Right-click a `.procreate` file → (Win 11 More options →) **7-Zip** → **Open archive**
2. Open the `QuickLook` folder
3. Extract `Thumbnail.png`
4. Rename it to match the Procreate filename, e.g. `Artwork.png`

## Quick start (recommended)

1. **Download/copy the script(s) to your computer**
   - Download this repo as a ZIP from GitHub and extract it, **or**
   - Copy a single script from the `scripts/` folder.
2. **Place the script in the same folder as your `.procreate` files**
   - This is the easiest way because the scripts work on the *current folder*.
3. **Run the script for your OS**
   - Windows: PowerShell (`.ps1`) or CMD (`.cmd`)
   - Linux/macOS: Shell (`.sh`)

> Tip: If you keep the scripts somewhere else, you can still run them — just **cd into** the folder that
> contains your `.procreate` files first, or run using the full path to the script.

## Scripts

All scripts look for `.procreate` files in the folder you run them from, and write `*.png` next to them.

### Linux / macOS (Shell)

**Requirements:** `unzip`

If you copied the script into the `.procreate` folder:

```sh
chmod +x extract-procreate-thumbnails.sh
./extract-procreate-thumbnails.sh
```

If you run it from this repo’s folder, run it like:

```sh
chmod +x scripts/extract-procreate-thumbnails.sh
./scripts/extract-procreate-thumbnails.sh
```

### Windows PowerShell

If you copied the script into the `.procreate` folder:

```powershell
# Optional (only for the current terminal session):
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

.\extract-procreate-thumbnails.ps1
```

If you run it from this repo’s folder:

```powershell
# Optional (only for the current terminal session):
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

.\scripts\extract-procreate-thumbnails.ps1
```

### Windows CMD (installed 7-Zip required)

The CMD script extracts thumbnails using the **installed 7-Zip CLI (`7z.exe`)**.

Why installed 7-Zip only?
- The small standalone `7zr.exe` can be blocked by security tools and/or fail to open `.procreate` ZIP archives reliably on some systems.
- `7z.exe` (installed version) works consistently for this extraction method.

#### Requirements

1. Install 7-Zip using the Windows installer from the 7-Zip download page.
2. The script will find `7z.exe` in one of these ways:
   - via `PATH` (if you’ve added it), or
   - in common install paths:
     - `%ProgramFiles%\7-Zip\7z.exe`
     - `%ProgramFiles(x86)%\7-Zip\7z.exe`

#### Run

If you copied the script into the `.procreate` folder:

```bat
extract-procreate-thumbnails.cmd
```

If you run it from this repo’s folder:

```bat
scripts\extract-procreate-thumbnails.cmd
```

The script prints simple progress updates (about every 10% of files processed).

## Output

For each `file.procreate`, the script writes `file.png` in the same folder.

If a file is missing a thumbnail, the scripts skip it and (for CMD) log failures to `problems.log`.

## Known limitations

### CMD special characters
Windows CMD can be fragile if filenames contain special characters such as `&`, `^`, `|`, `(`, `)`, or `!`.
If you have such filenames, prefer **PowerShell** or the **Shell** script.

### Line endings
This repository includes a `.gitattributes` file to normalize line endings across platforms:
- `.sh` and `.md` use LF
- `.cmd` / `.ps1` use CRLF

## Troubleshooting

- **PowerShell: “running scripts is disabled”**
  - Run: `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` (current terminal only)
- **Linux/macOS: `bad interpreter: /bin/sh^M`**
  - The script has Windows line endings. Ensure the `.sh` file uses LF (this repo enforces it via `.gitattributes`).
- **Linux/macOS: `unzip: command not found`**
  - Install `unzip` using your package manager (e.g. `apt`, `dnf`, `brew`).
- **CMD: “Could not find 7z.exe”**
  - Install 7-Zip and try again. If installed, confirm it’s in one of the common paths above or add it to `PATH`.
- **Nothing happens / no PNG output**
  - Confirm you are running the script in the folder that contains the `.procreate` files.

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
├─ .gitattributes
└─ .gitignore
```

## License

GPL-3.0-or-later
