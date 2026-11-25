#!/bin/sh
# Install the Dark Studio look for Mixbus 12.1 into the current user's Mixbus config.
# Existing files are backed up first. Close Mixbus before running.
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
CFG="${XDG_CONFIG_HOME:-$HOME/.config}/mixbus12"
STAMP=$(date +%Y%m%d-%H%M%S)
BACKUP="$CFG/appearance-backups/$STAMP"

mkdir -p "$CFG" "$BACKUP"
for f in my-dark-mixbus-12.1.colors dark-studio.rc ui_config; do
	[ -f "$CFG/$f" ] && cp "$CFG/$f" "$BACKUP/"
done

cp "$HERE/my-dark-mixbus-12.1.colors" "$CFG/"
cp "$HERE/dark-studio.rc" "$CFG/"

# UI options: style file, font, font scale, flat regions
python3 - "$CFG/ui_config" <<'PY'
import os, re, sys
p = sys.argv[1]
opts = {"ui-rc-file": "dark-studio.rc", "ui-font-family": "Adwaita Sans",
        "font-scale": "114447", "timeline-item-gradient-depth": "0"}
s = open(p).read() if os.path.exists(p) else '<?xml version="1.0" encoding="UTF-8"?>\n<Ardour>\n  <UI>\n  </UI>\n</Ardour>\n'
if "<UI>" not in s:
    s = s.replace("<Ardour>", "<Ardour>\n  <UI>\n  </UI>", 1)
for k, v in opts.items():
    tag = f'<Option name="{k}" value="{v}"/>'
    if f'name="{k}"' in s:
        s = re.sub(rf'<Option name="{k}" value="[^"]*"/>', tag, s)
    else:
        s = s.replace("<UI>", f"<UI>\n    {tag}", 1)
open(p, "w").write(s)
PY

echo "Dark Studio installed in $CFG (previous files saved in $BACKUP)."
echo "Start Mixbus; the dark-mixbus colour theme must be selected in Preferences > Appearance."
