#!/usr/bin/env bash
set -euo pipefail

# md
# ## install-appimage
#
# Integrate an AppImage into the Applications menu and command line
#
# ### Usage:
#
# ```bash
# ./install-appimage.sh /path/to/App.AppImage \
#    [--name "Nice Name"] \
#    [--categories "Utility;"] \
#    [--cmd "commandname"]
# ```
#
# Notes:
#
# - User-scope only (no sudo needed). Creates a launcher in ~/.local/share/applications
# - Tries to extract an icon from the AppImage; you can swap it later by editing the .desktop.
# /md


print_usage() {
  cat <<EOF
Usage:
  $0 /path/to/App.AppImage [--name "Nice Name"] [--categories "Utility;"] [--cmd "commandname"]

Notes:
  - Installs for the current user only (no sudo).
  - Places AppImage in ~/Applications
  - Creates ~/.local/share/applications/<app-id>.desktop
  - Installs icon into ~/.local/share/icons/hicolor/*/apps/<app-id>.png and uses Icon=<app-id>
  - Creates ~/.local/bin/<command> symlink (ensure ~/.local/bin is in your PATH)
EOF
}

# sanitize helper: lowercase, replace non-alnum with '-', trim duplicate '-'
sanitize_id() {
  local s="$1"
  s="$(echo "$s" | tr '[:upper:]' '[:lower:]' \
        | sed -E 's/[^a-z0-9]+/-/g' \
        | sed -E 's/^-+|-+$//g')"
  echo "$s"
}

if [[ "${1:-}" =~ ^(-h|--help)$ ]]; then
  print_usage
  exit 0
fi

APPIMAGE_PATH="${1:-}"
shift || true

if [[ -z "${APPIMAGE_PATH}" || ! -f "${APPIMAGE_PATH}" ]]; then
  echo "Error: please pass a valid AppImage path."
  print_usage
  exit 1
fi

# Defaults; can override via flags
CUSTOM_NAME=""
CATEGORIES="Utility;"
CMD_NAME_FLAG=""

# Parse optional flags
while (( "$#" )); do
  case "$1" in
    --name) CUSTOM_NAME="${2:-}"; shift 2 ;;
    --categories) CATEGORIES="${2:-}"; shift 2 ;;
    --cmd) CMD_NAME_FLAG="${2:-}"; shift 2 ;;
    *) echo "Unknown option: $1"; print_usage; exit 1 ;;
  esac
done

# Resolve absolute path
APPIMAGE_PATH="$(readlink -f "$APPIMAGE_PATH")"

# Derive sensible app id/name from filename
FILENAME="$(basename "$APPIMAGE_PATH")"
BASENAME="${FILENAME%.AppImage}"
APP_ID="$(sanitize_id "$BASENAME")"
APP_NAME="${CUSTOM_NAME:-$BASENAME}"

# Locations
INSTALL_DIR="$HOME/Applications"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_BASE_DIR="$HOME/.local/share/icons/hicolor"
ICON_PATH_512="$ICON_BASE_DIR/512x512/apps/${APP_ID}.png"
DESKTOP_FILE="${DESKTOP_DIR}/${APP_ID}.desktop"
TARGET_APPIMAGE="${INSTALL_DIR}/${FILENAME}"
BIN_DIR="$HOME/.local/bin"

# Command name: flag wins, otherwise app id
if [[ -n "${CMD_NAME_FLAG:-}" ]]; then
  CMD_NAME="$(sanitize_id "$CMD_NAME_FLAG")"
else
  CMD_NAME="$APP_ID"
fi

# Ensure directories exist
mkdir -p "$INSTALL_DIR" "$DESKTOP_DIR" \
         "$ICON_BASE_DIR/512x512/apps" \
         "$ICON_BASE_DIR/256x256/apps" \
         "$ICON_BASE_DIR/128x128/apps" \
         "$BIN_DIR"

echo "Preparing AppImage:"
echo "  Source: $APPIMAGE_PATH"
echo "  Will install as: $APP_NAME (id: $APP_ID)"
echo "  Command name: $CMD_NAME"
echo "  Target path: $TARGET_APPIMAGE"
echo

# Copy/move the AppImage into a stable location
if [[ "$APPIMAGE_PATH" != "$TARGET_APPIMAGE" ]]; then
  cp -f "$APPIMAGE_PATH" "$TARGET_APPIMAGE"
fi
chmod +x "$TARGET_APPIMAGE"

# Try to extract an icon from the AppImage (best-effort) in a subshell
TMPDIR="$(mktemp -d)"
cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

echo "Attempting to extract icon from AppImage (best-effort)..."
EXTRACT_DIR=""
if ( cd "$TMPDIR" && "$TARGET_APPIMAGE" --appimage-extract >/dev/null 2>&1 ); then
  EXTRACT_DIR="$TMPDIR/squashfs-root"
  echo "  -> extracted to $EXTRACT_DIR"
else
  echo "  -> AppImage didn't extract (or extraction failed). Skipping extraction."
fi

ICON_CANDIDATE=""
if [[ -n "$EXTRACT_DIR" && -d "$EXTRACT_DIR" ]]; then
  if command -v identify >/dev/null 2>&1; then
    best_area=0
    while IFS= read -r -d $'\0' p; do
      dims="$(identify -format "%w %h" "$p" 2>/dev/null || echo "0 0")"
      w="${dims%% *}"; h="${dims##* }"
      w="${w:-0}"; h="${h:-0}"
      area=$(( (w+0) * (h+0) ))
      if (( area > best_area )); then
        best_area=$area
        ICON_CANDIDATE="$p"
      fi
    done < <(find "$EXTRACT_DIR" -type f -iname '*.png' -print0 2>/dev/null)
  else
    ICON_CANDIDATE="$(find "$EXTRACT_DIR" -type f -iname '*.png' -print0 2>/dev/null \
      | xargs -0 ls -1S 2>/dev/null | head -n1 || true)"
  fi

  if [[ -n "$ICON_CANDIDATE" && -f "$ICON_CANDIDATE" ]]; then
    echo "  -> Found PNG icon: $ICON_CANDIDATE"
    mkdir -p "$(dirname "$ICON_PATH_512")"
    cp -f "$ICON_CANDIDATE" "$ICON_PATH_512" || true
  else
    SVG_ICON="$(find "$EXTRACT_DIR" -type f -iname '*.svg' 2>/dev/null | head -n1 || true)"
    if [[ -n "$SVG_ICON" && -x "$(command -v rsvg-convert)" ]]; then
      echo "  -> Converting SVG to PNG: $SVG_ICON"
      mkdir -p "$(dirname "$ICON_PATH_512")"
      rsvg-convert -w 512 -h 512 "$SVG_ICON" -o "$ICON_PATH_512" || true
    else
      echo "  -> No suitable icon found inside AppImage."
    fi
  fi
else
  echo "  -> No extracted contents to search for icons."
fi

# Install icon into hicolor and use theme-style icon name (better DE compatibility)
ICON_KEY=""
if [[ -f "$ICON_PATH_512" ]]; then
  echo "Installing icon as: $ICON_PATH_512"
  chmod 644 "$ICON_PATH_512" || true
  ICON_KEY="Icon=${APP_ID}"
  if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f "$ICON_BASE_DIR" >/dev/null 2>&1 || true
  fi
else
  echo "No icon installed (continuing without a theme icon)."
fi

echo "Writing desktop entry: $DESKTOP_FILE"
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=$APP_NAME
TryExec=$CMD_NAME
Exec=$CMD_NAME %U
$ICON_KEY
Terminal=false
Type=Application
StartupNotify=true
Categories=$CATEGORIES
X-AppImage-Integrate=true
EOF

chmod 644 "$DESKTOP_FILE"
chmod +x "$DESKTOP_FILE" || true

# Refresh desktop database (best-effort)
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$DESKTOP_DIR" >/dev/null 2>&1 || true
fi

# Ensure bin dir exists and create symlink command
mkdir -p "$BIN_DIR"
ln -sf "$TARGET_APPIMAGE" "$BIN_DIR/$CMD_NAME"
chmod +x "$TARGET_APPIMAGE"

echo
echo "✅ Installed \"$APP_NAME\""
echo "   Launcher: $DESKTOP_FILE"
echo "   Binary:   $TARGET_APPIMAGE"
echo "   Command:  $BIN_DIR/$CMD_NAME"
[[ -n "$ICON_KEY" ]] && echo "   Icon:     $ICON_PATH_512" || echo "   Icon:     (none found)"
echo
echo "Tip: to uninstall, delete:"
echo "  rm -f \"$DESKTOP_FILE\" \"$TARGET_APPIMAGE\" \"$ICON_PATH_512\" \"$BIN_DIR/$CMD_NAME\" && update-desktop-database \"$DESKTOP_DIR\" || true"
