# How It Works

## The Problem

AI coding agents (OpenCode, Claude Code, Cursor, etc.) start every session with a blank slate. The agent has no memory of what happened last time -- what was built, what broke, what decisions were made, or what's left to do.

This means you waste the first 10-15 minutes of every session re-explaining context.

## The Solution

**opencode-close-session** automatically runs a closeout workflow every time you exit an OpenCode session. It creates and maintains four files in each repo:

| File | Purpose |
|------|---------|
| `AGENT.md` | Project overview, architecture, decisions log, runbook |
| `LEARNINGS.md` | Accumulated knowledge -- API quirks, gotchas, what works |
| `TECH_DEBT.md` | Prioritized backlog of things to fix |
| `handover/handover-NNN.md` | Per-session log of what happened and what's next |

These files live in the repo, get committed to git, and are available for the next session to read immediately.

## Architecture

```
User exits OpenCode TUI
        |
        v
~/.bashrc: opencode() function
        |
        v
~/.local/bin/opencode-auto-close
  - Detects if this was an interactive TUI session
  - Ignores subcommands (run, session, auth, etc.)
  - EXIT trap fires on TUI close
        |
        v
launch_closeout()
  - Finds the git repo root for the working directory
  - Launches close-session in the background (nohup)
        |
        v
opencode run --command close-session
  - OpenCode loads commands/close-session.md
  - The AI agent executes the closeout workflow
        |
        v
Agent workflow:
  1. Read existing memory files
  2. Update LEARNINGS.md with new discoveries
  3. Update TECH_DEBT.md (add new, resolve old)
  4. Update AGENT.md if architecture changed
  5. Create handover/handover-NNN.md
  6. git add, commit, push
        |
        v
Done. Logs written to:
  ~/.local/state/opencode/close-session.log
```

## Key Design Decisions

### Why a bash wrapper instead of an OpenCode plugin?

OpenCode plugins can listen to events (`session.idle`, `session.error`) but there's no reliable `session.end` event that fires when the TUI exits. The bash wrapper is the only way to guarantee the closeout runs on every exit -- including Ctrl+C, crashes, and normal quit.

### Why background execution (nohup)?

The closeout involves an AI agent reading files, making decisions, and writing updates. This takes 30-60 seconds. Running it in the foreground would block the user's terminal after they've already mentally moved on. Background execution means zero friction.

### Why a breadcrumb file for the real binary path?

The wrapper needs to call the real `opencode` binary without recursing into itself. Rather than relying on fragile PATH manipulation, the installer saves the real binary path to `~/.local/state/opencode/real-opencode-path`. This survives node version changes, reinstalls, and PATH reordering.

### Why per-repo files instead of a central database?

- Files live with the code they describe
- They get committed to git -- versioned and shared
- Any AI agent can read them (not just OpenCode)
- No external dependencies or databases
- They're human-readable and human-editable

## How the Agent Knows What to Write

The `/close-session` command (in `commands/close-session.md`) gives the AI agent explicit instructions on what to create and update. The agent has full access to the session context -- it knows what files were changed, what errors occurred, what decisions were made -- and uses that to write meaningful updates.

The quality of the handover files depends on the quality of the session. A productive session with clear work produces detailed handovers. A short config change produces a brief one.
