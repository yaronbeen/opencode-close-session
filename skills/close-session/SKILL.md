---
name: close-session
description: End-of-session repo closeout workflow. Ensures AGENT.md, LEARNINGS.md, TECH_DEBT.md, and handover files are created and updated, then commits and pushes.
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
---

# Close Session Skill

Use this at the end of a working session in a repo.

## Purpose

Prevent context loss between sessions by enforcing a standard closeout workflow.

## Required steps

### 1. Confirm the current repo

- Verify you are working inside a git repo.
- Determine the repo root.

### 2. Ensure the standard memory system exists

If missing, create:

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

### 3. Read the repo memory files

Read:
- the latest handover file
- `LEARNINGS.md`
- `TECH_DEBT.md`
- `AGENT.md`

### 4. Update memory from the current session

- Add new durable learnings to `LEARNINGS.md`
- Add / resolve items in `TECH_DEBT.md`
- Update `AGENT.md` if status, architecture, or file structure changed

### 5. Write the next handover file

Create the next sequential `handover/handover-NNN.md`.

It must include:
- what happened this session
- the current state
- open issues / risks
- next steps
- decisions made and rationale

### 6. Verify

Make sure the updated files exist and reflect the session accurately.

### 7. Commit and push

If there are changes:
- stage them
- commit with a concise message
- push

If there are no changes, report that clearly.

## Output

Return:
- files updated
- new handover filename
- commit message
- push result

## Important

This is the global end-of-session standard.
Prefer invoking it manually through `/close-session` so it happens deliberately.
If the repo has stronger project-specific session-close rules in `AGENT.md`, follow those too.
