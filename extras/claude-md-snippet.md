# CLAUDE.md Session Memory Snippet

Add these sections to your `~/.claude/CLAUDE.md` (or project-level `CLAUDE.md`)
to teach Claude Code about the session memory system.

---

Copy everything below this line into your CLAUDE.md:

---

## Session Memory System

This project uses a structured memory system to preserve context across sessions.

### On Repo Init / First Session in a Repo

When working in a repo for the first time (no `AGENT.md` exists):

1. **Create `AGENT.md`** at the repo root with these sections:
   - **Start Here**: instructions to read latest handover, review tech debt P0, skim learnings
   - **Purpose & Context**: what the project does, who it's for, current status
   - **Architecture / Design**: high-level system design, data flow, key components
   - **Decisions Log**: append-only table of key decisions with date, decision, and rationale
   - **Runbook / Operations**: how to operate the system day-to-day
   - **Project File Structure**: what each file/directory does
   - **References**: links to LEARNINGS.md, TECH_DEBT.md, and handover system

2. **Create `LEARNINGS.md`** at the repo root:
   - Accumulated knowledge from working on the project
   - API quirks, gotchas, what works and what doesn't

3. **Create `TECH_DEBT.md`** at the repo root:
   - Prioritized backlog: P0 (next session), P1 (this week), P2 (when convenient), P3 (nice to have)
   - "Resolved Items" section at the bottom with dates

4. **Create `handover/`** directory:
   - Numbered files: `handover-001.md`, `handover-002.md`, etc.

### On Session Start (Existing Repo)

1. Read the latest handover: `ls -1 handover/ | tail -1` then read it
2. Review `TECH_DEBT.md` P0 items -- address them first
3. Skim `LEARNINGS.md` for relevant context

### On Session End

Before the session ends:

1. Create new handover file (`handover/handover-NNN.md`) with next sequential number
   - What was accomplished this session
   - Current state
   - Open issues / risks
   - Recommended next steps
   - Decisions made and why
2. Update `LEARNINGS.md` if you discovered anything new
3. Update `TECH_DEBT.md` -- add new items, move resolved items
4. Update `AGENT.md` if architecture or status changed
5. Commit and push
