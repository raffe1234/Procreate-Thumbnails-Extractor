#!/bin/sh
#
# extract-procreate-thumbnails.sh
# 
# Copyright (C) 2026 raffe
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#
# Requirements:
#   - unzip must be installed and available in PATH
#
# Usage:
#   Place this script in the directory containing your .procreate files
#   and execute it.
#
# Linux:
#  chmod +x extract-procreate-thumbnails.sh
#  ./extract-procreate-thumbnails.sh
#

# Check dependency
command -v unzip >/dev/null 2>&1 || {
    echo "Error: unzip is required but not installed."
    exit 1
}

total=0
ok=0
fail=0
problems=""
num_files=0
bar_width=30

# Count files
for f in *.procreate; do
    [ -e "$f" ] || continue
    num_files=$((num_files + 1))
done

[ "$num_files" -gt 0 ] || {
    echo "No .procreate files found."
    exit 0
}

echo "Starting extraction of Procreate thumbnails..."

# Loop through files
for file in *.procreate; do
    [ -e "$file" ] || continue

    total=$((total + 1))
    base="${file%.procreate}"
    output="${base}.png"

    if unzip -p "$file" "QuickLook/Thumbnail.png" > "$output" 2>/dev/null; then
        if [ -s "$output" ]; then
            ok=$((ok + 1))
        else
            fail=$((fail + 1))
            rm -f "$output"
            problems="$problems
$base.procreate: Empty PNG file"
        fi
    else
        fail=$((fail + 1))
        problems="$problems
$base.procreate: Could not extract Thumbnail.png"
    fi

    percent=$(( total * 100 / num_files ))
    filled=$(( total * bar_width / num_files ))
    empty=$(( bar_width - filled ))

    # Build progress bar using shell loop (for compatibility, no seq)
    bar=""
    i=0
    while [ "$i" -lt "$filled" ]; do
        bar="${bar}#"
        i=$((i + 1))
    done
    i=0
    while [ "$i" -lt "$empty" ]; do
        bar="${bar}-"
        i=$((i + 1))
    done

    printf "\r[%s] %3d%%  Total: %d  OK: %d  Failed: %d" \
        "$bar" "$percent" "$total" "$ok" "$fail"
done

echo
echo
echo "Done!"
echo "Total files processed: $total"
echo "Succeeded:             $ok"
echo "Failed:                $fail"

if [ "$fail" -ne 0 ]; then
    echo
    echo "Problems that occurred:"
    printf "%s\n" "$problems" | sed '1d'
fi