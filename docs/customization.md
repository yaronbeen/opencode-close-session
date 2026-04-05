# Customization

## Modifying the Closeout Workflow

The AI agent's behavior is controlled by two files:

- **Command**: `~/.config/opencode/commands/close-session.md` -- What runs when `/close-session` is invoked
- **Skill**: `~/.config/opencode/skills/close-session/SKILL.md` -- Reusable skill that can be referenced by other commands

Edit either file to change what the agent does during closeout.

### Examples

**Add a changelog update step** -- Add a section to the command:

```markdown
### 8. Update CHANGELOG

If user-facing features were added or bugs fixed, append an entry to CHANGELOG.md.
```

**Skip the push** -- Remove or comment out the push instruction in step 7.

**Add custom files** -- Add instructions to maintain any file you want. For example, a `TODO.md`, `ARCHITECTURE.md`, or `SECURITY.md`.

## Per-Repo Overrides

If a repo's `AGENT.md` has its own closeout rules, those take priority. Add a section like:

```markdown
## Session Close Rules

When closing a session in this repo, also:
- Update the API docs in docs/api/
- Run `npm run build` to verify no build errors
- Update the version number if features were added
```

The agent will follow both the global close-session command and the repo-specific rules.

## Disabling Auto-Close

### For a single session

```bash
OPENCODE_AUTO_CLOSE=0 opencode
```

### Permanently

Remove the shell function from your `.bashrc` / `.zshrc`:

```bash
# Delete the block between these markers:
# === opencode auto-close-session wrapper ===
# ... (the function)
# === end opencode auto-close-session wrapper ===
```

Or run `./uninstall.sh`.

### For non-git directories

The wrapper automatically skips closeout if the working directory is not inside a git repo. No configuration needed.

## Changing the Log Location

The wrapper logs to `$XDG_STATE_HOME/opencode/close-session.log` (defaults to `~/.local/state/opencode/close-session.log`).

Set `XDG_STATE_HOME` to change the location:

```bash
export XDG_STATE_HOME="$HOME/.state"
```

## Using with Claude Code

The close-session system is built for OpenCode, but the **repo memory concept** works with any AI coding agent.

For Claude Code users:

1. Copy `extras/claude-md-snippet.md` content into your `CLAUDE.md`
2. Optionally install `extras/claude-code-hook.sh` as a Claude Code stop hook
3. The agent will follow the session start/end instructions from your `CLAUDE.md`

The difference: with Claude Code, the agent needs to be reminded to run the closeout. With OpenCode + this tool, it happens automatically.

## Adjusting the Subcommand Allowlist

The wrapper maintains a list of known OpenCode subcommands that should NOT trigger auto-close (because they're not interactive TUI sessions):

```bash
KNOWN_SUBCOMMANDS=(
  completion acp mcp run debug providers auth agent upgrade uninstall
  serve web models stats export import github pr session plugin db
)
```

If OpenCode adds new subcommands, add them to this list in `~/.local/bin/opencode-auto-close`.
