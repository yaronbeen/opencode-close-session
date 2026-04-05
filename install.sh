#!/usr/bin/env bash
set -euo pipefail

# install.sh -- one-command installer for opencode-close-session
#
# Usage:
#   git clone https://github.com/yaronbeen/opencode-close-session.git
#   cd opencode-close-session
#   ./install.sh
#
# What it does:
#   1. Finds the real opencode binary on your system
#   2. Installs the wrapper script to ~/.local/bin/
#   3. Installs the OpenCode command + skill
#   4. Adds a shell function to your .bashrc / .zshrc
#   5. Creates the log directory

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()  { echo -e "${BLUE}[info]${NC}  $*"; }
ok()    { echo -e "${GREEN}[ok]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[warn]${NC}  $*"; }
err()   { echo -e "${RED}[error]${NC} $*" >&2; }

# ---------------------------------------------------------------------------
# 1. Find the real opencode binary
# ---------------------------------------------------------------------------
find_opencode() {
  # Check common locations
  local candidates=(
    "$(command -v opencode 2>/dev/null || true)"
    "$(npm bin -g 2>/dev/null)/opencode"
    "$HOME/.local/bin/opencode"
    "/usr/local/bin/opencode"
  )

  for candidate in "${candidates[@]}"; do
    if [[ -n "$candidate" && -x "$candidate" ]]; then
      # Resolve symlinks to get the real path
      local resolved
      resolved="$(readlink -f "$candidate" 2>/dev/null || realpath "$candidate" 2>/dev/null || echo "$candidate")"
      echo "$resolved"
      return 0
    fi
  done
  return 1
}

info "Looking for OpenCode binary..."
REAL_OPENCODE="$(find_opencode)" || {
  err "Could not find the opencode binary."
  err "Make sure OpenCode is installed: https://opencode.ai"
  exit 1
}
ok "Found OpenCode at: $REAL_OPENCODE"

# ---------------------------------------------------------------------------
# 2. Install the wrapper script
# ---------------------------------------------------------------------------
INSTALL_BIN="${XDG_BIN_HOME:-$HOME/.local/bin}"
mkdir -p "$INSTALL_BIN"

info "Installing wrapper script to $INSTALL_BIN/opencode-auto-close..."
cp "$SCRIPT_DIR/bin/opencode-auto-close" "$INSTALL_BIN/opencode-auto-close"
chmod +x "$INSTALL_BIN/opencode-auto-close"

# Save the real opencode path so the wrapper can find it reliably
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/opencode"
mkdir -p "$STATE_DIR"
echo "$REAL_OPENCODE" > "$STATE_DIR/real-opencode-path"
ok "Wrapper installed"

# ---------------------------------------------------------------------------
# 3. Install the OpenCode command + skill
# ---------------------------------------------------------------------------
OPENCODE_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
COMMANDS_DIR="$OPENCODE_CONFIG/commands"
SKILLS_DIR="$OPENCODE_CONFIG/skills/close-session"

mkdir -p "$COMMANDS_DIR" "$SKILLS_DIR"

info "Installing OpenCode command..."
cp "$SCRIPT_DIR/commands/close-session.md" "$COMMANDS_DIR/close-session.md"
ok "Command installed to $COMMANDS_DIR/"

info "Installing OpenCode skill..."
cp "$SCRIPT_DIR/skills/close-session/SKILL.md" "$SKILLS_DIR/SKILL.md"
ok "Skill installed to $SKILLS_DIR/"

# ---------------------------------------------------------------------------
# 4. Shell integration
# ---------------------------------------------------------------------------
SHELL_SNIPPET='
# === opencode auto-close-session wrapper ===
# Interactive `opencode` launches use a wrapper that triggers `/close-session`
# in the background when the TUI exits. To disable for one launch:
#   OPENCODE_AUTO_CLOSE=0 opencode
opencode() {
    '"$INSTALL_BIN"'/opencode-auto-close "$@"
}
# === end opencode auto-close-session wrapper ==='

MARKER="opencode auto-close-session wrapper"

add_to_shell_rc() {
  local rc_file="$1"
  if [[ ! -f "$rc_file" ]]; then
    return 1
  fi
  if grep -qF "$MARKER" "$rc_file" 2>/dev/null; then
    warn "Shell integration already present in $rc_file -- skipping"
    return 0
  fi
  echo "$SHELL_SNIPPET" >> "$rc_file"
  ok "Added shell function to $rc_file"
  return 0
}

info "Adding shell integration..."
ADDED=0

# Try the user's current shell first
case "${SHELL:-}" in
  */zsh)
    add_to_shell_rc "$HOME/.zshrc" && ADDED=1
    ;;
  */bash)
    add_to_shell_rc "$HOME/.bashrc" && ADDED=1
    ;;
esac

# If we haven't added to anything yet, try both
if [[ "$ADDED" -eq 0 ]]; then
  add_to_shell_rc "$HOME/.bashrc" && ADDED=1
  add_to_shell_rc "$HOME/.zshrc" && ADDED=1
fi

if [[ "$ADDED" -eq 0 ]]; then
  warn "Could not find .bashrc or .zshrc."
  warn "Add this to your shell config manually:"
  echo ""
  echo "$SHELL_SNIPPET"
  echo ""
fi

# ---------------------------------------------------------------------------
# 5. Create log directory
# ---------------------------------------------------------------------------
mkdir -p "$STATE_DIR"
ok "Log directory ready at $STATE_DIR/"

# ---------------------------------------------------------------------------
# 6. Activate pre-commit hook (TruffleHog secret scanning)
# ---------------------------------------------------------------------------
if git -C "$SCRIPT_DIR" rev-parse --git-dir &>/dev/null; then
  info "Activating TruffleHog pre-commit hook..."
  git -C "$SCRIPT_DIR" config --local core.hooksPath hooks
  ok "Pre-commit hook active (hooks/pre-commit)"
  if command -v trufflehog &>/dev/null; then
    ok "TruffleHog found -- commits will be scanned for secrets"
  else
    warn "TruffleHog not installed -- hook will warn but not block"
    warn "Install it: https://github.com/trufflesecurity/trufflehog#installation"
  fi
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  opencode-close-session installed!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "How it works:"
echo "  1. Use 'opencode' normally to launch the TUI"
echo "  2. When you exit, /close-session runs automatically in the background"
echo "  3. Your repo gets AGENT.md, LEARNINGS.md, TECH_DEBT.md, and handover/ files"
echo ""
echo "Disable for one session:  OPENCODE_AUTO_CLOSE=0 opencode"
echo "View logs:                cat $STATE_DIR/close-session.log"
echo "Uninstall:                $SCRIPT_DIR/uninstall.sh"
echo ""
echo -e "${YELLOW}Restart your shell or run 'source ~/.bashrc' to activate.${NC}"
