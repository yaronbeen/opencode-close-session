#!/usr/bin/env bash
set -euo pipefail

# uninstall.sh -- cleanly removes opencode-close-session
#
# Does NOT remove any repo-level files (AGENT.md, handover/, etc.)
# Those belong to your projects and are yours to keep.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[info]${NC}  $*"; }
ok()    { echo -e "${GREEN}[ok]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[warn]${NC}  $*"; }

MARKER="opencode auto-close-session wrapper"

# ---------------------------------------------------------------------------
# 1. Remove wrapper script
# ---------------------------------------------------------------------------
INSTALL_BIN="${XDG_BIN_HOME:-$HOME/.local/bin}"
WRAPPER="$INSTALL_BIN/opencode-auto-close"

if [[ -f "$WRAPPER" ]]; then
  rm "$WRAPPER"
  ok "Removed $WRAPPER"
else
  info "Wrapper script not found at $WRAPPER -- already removed?"
fi

# ---------------------------------------------------------------------------
# 2. Remove breadcrumb file
# ---------------------------------------------------------------------------
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/opencode"
BREADCRUMB="$STATE_DIR/real-opencode-path"

if [[ -f "$BREADCRUMB" ]]; then
  rm "$BREADCRUMB"
  ok "Removed breadcrumb $BREADCRUMB"
fi

# ---------------------------------------------------------------------------
# 3. Remove OpenCode command + skill
# ---------------------------------------------------------------------------
OPENCODE_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
CMD_FILE="$OPENCODE_CONFIG/commands/close-session.md"
SKILL_FILE="$OPENCODE_CONFIG/skills/close-session/SKILL.md"
SKILL_DIR="$OPENCODE_CONFIG/skills/close-session"

if [[ -f "$CMD_FILE" ]]; then
  rm "$CMD_FILE"
  ok "Removed command: $CMD_FILE"
fi

if [[ -f "$SKILL_FILE" ]]; then
  rm "$SKILL_FILE"
  ok "Removed skill: $SKILL_FILE"
fi

if [[ -d "$SKILL_DIR" ]] && [[ -z "$(ls -A "$SKILL_DIR" 2>/dev/null)" ]]; then
  rmdir "$SKILL_DIR"
  ok "Removed empty directory: $SKILL_DIR"
fi

# ---------------------------------------------------------------------------
# 4. Remove shell integration
# ---------------------------------------------------------------------------
remove_from_rc() {
  local rc_file="$1"
  if [[ ! -f "$rc_file" ]]; then
    return
  fi
  if ! grep -qF "$MARKER" "$rc_file" 2>/dev/null; then
    return
  fi

  # Remove the block between the start and end markers (inclusive)
  local tmp
  tmp="$(mktemp)"
  awk -v marker="$MARKER" '
    /=== .* === *$/ && index($0, marker) {
      skip = !skip
      next
    }
    !skip { print }
  ' "$rc_file" > "$tmp"

  mv "$tmp" "$rc_file"
  ok "Removed shell integration from $rc_file"
}

info "Removing shell integration..."
remove_from_rc "$HOME/.bashrc"
remove_from_rc "$HOME/.zshrc"

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
echo ""
echo -e "${GREEN}opencode-close-session has been uninstalled.${NC}"
echo ""
echo "Notes:"
echo "  - Log file kept at: $STATE_DIR/close-session.log (delete manually if wanted)"
echo "  - Repo-level files (AGENT.md, handover/, etc.) were NOT removed"
echo "  - Restart your shell or run 'source ~/.bashrc' to complete removal"
