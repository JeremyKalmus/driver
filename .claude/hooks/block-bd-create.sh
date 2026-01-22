#!/bin/bash
#
# block-bd-create.sh - Claude Code PreToolUse hook
#
# Intercepts 'bd create' and 'bd new' commands and blocks them,
# directing agents to use the /bead skill instead for consistent
# hierarchy enforcement.
#

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // ""')

# Check if this is a bd create or bd new command
if [[ "$command" == bd\ create* ]] || [[ "$command" == bd\ new* ]]; then
  cat >&2 << 'EOF'
BLOCKED: Direct 'bd create' is not allowed.

Use the /bead skill instead to ensure proper hierarchy:

  /bead epic "Title"              # Create top-level epic
  /bead task "Title" <parent-id>  # Create task under epic/task
  /bead bug "Title" <parent-id>   # Create bug under epic/task

The /bead skill enforces:
- Parent-child relationships (Epic -> Task -> Subtask)
- Consistent description format
- Proper linking for visualization

Run: /bead --help for usage
EOF
  exit 2
fi

exit 0
