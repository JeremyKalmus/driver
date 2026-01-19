# Polecat Bead Protocol

**You execute beads. You don't create them (except discovered bugs).**

This briefing standardizes how polecats interact with beads.

## Reading Your Assignment

When you receive work via your hook:

```bash
bd show {{issue}}
```

**Required sections you should find:**
- **Summary**: What needs to be done
- **Acceptance Criteria**: How to know you're done
- **Context**: Background and dependencies
- **Constraints**: Technical limits, Keeper decisions

If ANY of these are missing, mail Witness:
```bash
gt mail send <rig>/witness -s "INCOMPLETE BEAD" -m "Issue: {{issue}}
Missing: <what's missing>
Cannot proceed without clarification."
```

## Status Updates

**You MUST keep your bead status current.**

### When You Start Work
```bash
bd update {{issue}} --status in_progress
```

### When You Hit a Blocker
```bash
bd update {{issue}} --status blocked --notes "Blocked: <reason>"
gt mail send <rig>/witness -s "BLOCKED" -m "Issue: {{issue}}
Blocker: <description>
Need: <what would unblock>"
```

### When You Complete Work
```bash
bd update {{issue}} --notes "Completed: <summary of what was done>"
# Do NOT set --status done yourself
# That happens via gt done / merge process
```

### Progress Notes
For long-running work, add progress notes:
```bash
bd update {{issue}} --notes "Progress: <what's done so far>"
```

## Discovered Work

If you find bugs or issues while working:

```bash
bd create --type bug --title "Found: <description>" --priority 2 \
  --body "## Summary
Discovered while working on {{issue}}.

<description of the bug>

## Acceptance Criteria
- [ ] <how to verify it's fixed>

## Context
Found in: <file/location>
Related to: {{issue}}"
```

**Then continue with your assigned work.** Do NOT fix discovered bugs unless they block your current task.

## What You Must NEVER Do

- Create epic or feature beads (that's Driver/Mayor)
- Change another bead's status
- Close your own issue (Refinery does that)
- Mark your issue as done (merge process does that)
- Work on unassigned beads
- Skip status updates

## Acceptance Criteria Checklist

Before running `gt done`, verify ALL acceptance criteria:

```bash
bd show {{issue}}
# Read the Acceptance Criteria section
# Verify each item is satisfied
```

If ANY criteria cannot be met:
1. Note which criteria failed and why
2. Mail Witness before completing
3. Do NOT submit incomplete work

## The Contract

Your work is evaluated against the bead's acceptance criteria.
If you complete the criteria, you succeeded.
If you don't, you failed - regardless of how much code you wrote.

**Beads are contracts. Honor them.**
