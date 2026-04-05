---
name: close-session
description: Close the current repo session properly: ensure AGENT/LEARNINGS/TECH_DEBT/handover exist, update them, create the next handover, then commit and push.
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
---

# Close Session

Run this when the user wants to wrap up work in the current repo.

## Goal

Leave the repo in a state where the next session can resume immediately with minimal context loss.

## Required workflow

### 1. Confirm repo context

- If not inside a git repo, say so and stop.
- Identify the repo root.

### 2. Ensure the repo support files exist

If missing, create them:

- `AGENT.md`
- `LEARNINGS.md`
- `TECH_DEBT.md`
- `handover/`

`AGENT.md` must include:
- Start Here
- Purpose & Context
- Architecture / Design
- Decisions Log
- Runbook / Operations
- Project File Structure
- References to `LEARNINGS.md`, `TECH_DEBT.md`, and `handover/`

### 3. Read current repo memory files

If they exist, read:
- latest `handover/handover-NNN.md`
- `LEARNINGS.md`
- `TECH_DEBT.md`
- `AGENT.md`

### 4. Update project memory

Based on the current session:

- Update `LEARNINGS.md` with any non-trivial discoveries
- Update `TECH_DEBT.md`
  - add newly discovered issues
  - move resolved items to the resolved section with date
- Update `AGENT.md` if the current status, architecture, or file structure changed

### 5. Create the next handover file

Create the next sequential file in `handover/`:

- `handover-001.md`
- `handover-002.md`
- etc.

The handover must include:

1. What was accomplished this session
2. Current state
3. Open issues / risks
4. Recommended next steps
5. Decisions made and why

### 6. Verify before closing

Check that:
- the updated files exist
- the new handover file exists
- git status reflects the intended changes

### 7. Commit and push

If there are changes:
- stage the changed documentation / repo-memory files
- create a concise commit message about the session closeout
- push to the current branch

If there are no changes, say so explicitly.

## Output format

When done, report:

- which files were created/updated
- the new handover filename
- the commit message
- whether push succeeded

## Notes

- This command is the preferred global way to end a session.
- If the repo already has a handover system, follow its numbering convention.
- If the repo has project-specific closeout rules in `AGENT.md`, follow those too.
