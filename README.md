# opencode-close-session

**Automatic session memory for AI coding agents.**

Every time you exit [OpenCode](https://opencode.ai), this tool runs a closeout in the background that saves what happened, what was learned, and what to do next -- so the next session picks up exactly where you left off.

## The Problem

AI coding agents start every session with a blank slate. No memory of what was built, what broke, what decisions were made, or what's left to do. You waste the first 10 minutes of every session re-explaining context.

## The Solution

This tool automatically maintains four files in each repo:

| File | What It Captures |
|------|-----------------|
| `AGENT.md` | Project overview, architecture, decisions log, runbook |
| `LEARNINGS.md` | Accumulated knowledge -- API quirks, gotchas, what works |
| `TECH_DEBT.md` | Prioritized backlog of things to fix |
| `handover/handover-NNN.md` | Per-session log: what happened, current state, next steps |

These files live in the repo, get committed to git, and the next session reads them immediately.

## How It Works

```
You exit OpenCode TUI
        |
        v
Bash wrapper detects session end (EXIT trap)
        |
        v
Runs `opencode run --command close-session` in background
        |
        v
AI agent reads session context, updates memory files
        |
        v
Git commit + push (automatic, zero friction)
```

The closeout runs in the background -- you don't wait for it. Logs go to `~/.local/state/opencode/close-session.log`.

## Quick Start

```bash
git clone https://github.com/yaronbeen/opencode-close-session.git
cd opencode-close-session
./install.sh
```

Restart your shell (or `source ~/.bashrc`), then use `opencode` normally. That's it.

### What the installer does

1. Finds your OpenCode binary
2. Installs a wrapper script to `~/.local/bin/`
3. Installs the `/close-session` command and skill to `~/.config/opencode/`
4. Adds a shell function to `.bashrc` / `.zshrc`
5. Creates a log directory

### Uninstall

```bash
./uninstall.sh
```

Removes all installed files. Does NOT touch repo-level files (AGENT.md, handover/, etc.) -- those are yours.

## Usage

Just use OpenCode as you normally would:

```bash
opencode              # launches TUI -- close-session runs on exit
opencode ~/my-project # same, for a specific directory
```

### Disable for one session

```bash
OPENCODE_AUTO_CLOSE=0 opencode
```

### Run manually

Inside OpenCode, type:

```
/close-session
```

### View logs

```bash
cat ~/.local/state/opencode/close-session.log
```

## What Gets Created in Your Repos

After your first session in a repo, you'll see:

```
your-project/
├── AGENT.md              # Project memory -- architecture, decisions, runbook
├── LEARNINGS.md          # What the agent learned working on this project
├── TECH_DEBT.md          # Prioritized list of things to fix
└── handover/
    ├── handover-001.md   # First session summary
    ├── handover-002.md   # Second session summary
    └── ...
```

Each subsequent session adds a new handover file and updates the other three.

## For Claude Code Users

The repo memory system works with any AI coding agent, not just OpenCode. For Claude Code:

1. Copy the content from `extras/claude-md-snippet.md` into your `CLAUDE.md`
2. Optionally add `extras/claude-code-hook.sh` as a Claude Code stop hook

The difference: with Claude Code, the agent needs the CLAUDE.md instructions to know about the session memory system. With OpenCode + this tool, it's fully automatic.

## Customization

See [docs/customization.md](docs/customization.md) for:

- Modifying the closeout workflow
- Adding per-repo overrides
- Changing the log location
- Disabling auto-close permanently

See [docs/how-it-works.md](docs/how-it-works.md) for the full architecture and design decisions.

## File Overview

```
opencode-close-session/
├── install.sh                        # One-command installer
├── uninstall.sh                      # Clean removal
├── bin/
│   └── opencode-auto-close          # Bash wrapper with EXIT trap
├── commands/
│   └── close-session.md             # OpenCode /close-session command
├── skills/
│   └── close-session/
│       └── SKILL.md                 # OpenCode skill definition
├── extras/
│   ├── claude-code-hook.sh          # Stop hook for Claude Code users
│   └── claude-md-snippet.md         # CLAUDE.md instructions to copy
├── docs/
│   ├── how-it-works.md              # Architecture & design decisions
│   └── customization.md             # How to customize the workflow
└── examples/
    ├── AGENT.md.example             # Template
    ├── LEARNINGS.md.example         # Template
    ├── TECH_DEBT.md.example         # Template
    └── handover-001.md.example      # Template
```

## Requirements

- [OpenCode](https://opencode.ai) installed and working
- Bash 4+ (ships with most Linux distros and macOS)
- Git (for the commit/push step)

## License

MIT -- see [LICENSE](LICENSE).
