#!/bin/bash
# claude-code-hook.sh -- Claude Code stop-hook that reminds the agent to
# extract learnings before the session ends.
#
# Installation (Claude Code):
#   Copy this file to ~/.claude/scripts/
#   Add it as a stop hook in your Claude Code configuration.
#
# This is a complementary tool for Claude Code users. The main
# close-session system is built for OpenCode, but the session-memory
# concept (AGENT.md, LEARNINGS.md, TECH_DEBT.md, handover/) works
# with any AI coding agent.

LEARNED_DIR="$HOME/.claude/learned"
mkdir -p "$LEARNED_DIR"

cat << 'EOF'

---SESSION END: LEARNING EXTRACTION---

Before closing, consider if this session had:

1. **Error resolutions** worth remembering?
   - Tricky bugs and their fixes
   - Configuration gotchas
   - API quirks discovered

2. **Workflow patterns** that worked well?
   - Effective approaches to reuse
   - Tool combinations that helped

3. **Repo memory updates** needed?
   - LEARNINGS.md -- new discoveries
   - TECH_DEBT.md -- new items or resolved items
   - AGENT.md -- architecture or status changes
   - handover/ -- create next handover file

If yes, update the repo memory files and commit.

------------------------------------------
EOF

exit 0
