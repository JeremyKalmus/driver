---
description: Create consistent beads (replaces spec.md files)
allowed-tools: Read,Bash(bd:*),Bash(bd --no-daemon:*),Bash(cat:*),Bash(ls:*)
argument-hint: <type> <title> [--parent <id>] [--spec <description>]
---

# /bead - Consistent Bead Creation

**All specs are beads. No more spec.md files.**

## Parse Arguments

Input: $ARGUMENTS

Expected format: `<type> <title> [--parent <id>] [--spec <description>]`

Where:
- `type`: epic | issue | task | bug
- `title`: Quoted string for the bead title
- `--parent`: Optional parent bead ID for hierarchy
- `--spec`: Optional inline spec or path to spec content

## Step 1: Validate Type

Valid types and their purposes:

| Type | Purpose | Has Children? |
|------|---------|---------------|
| `epic` | Container for related work (features, initiatives) | Yes - issues and tasks |
| `issue` | Concrete work item | Yes - tasks (optional) |
| `task` | Smallest unit, specific and actionable | No |
| `bug` | Something broken that needs fixing | No |

If type is not recognized, prompt for correction.

## Step 2: Check for Existing Similar Beads

Before creating, check if similar work exists:

```bash
bd list --title-contains "<keywords from title>" --status open
```

If similar beads exist, report them and ask:
- "Similar bead exists: <id>. Create anyway? Or link to existing?"

## Step 3: Build Bead Description

Every bead must follow this format:

```markdown
## Summary
<One paragraph explaining what and why>

## Acceptance Criteria
- [ ] <Specific, testable criterion 1>
- [ ] <Specific, testable criterion 2>
- [ ] <Defines what "done" means>

## Context
<Any relevant background, links, or dependencies>
<If --parent specified: "Part of: <parent-id>">

## Constraints
<Any technical constraints>
<Keeper decisions if applicable>
```

If `--spec` was provided:
- If it's a file path, read the file and incorporate
- If it's inline text, use as the Summary section
- Extract acceptance criteria if present

If `--spec` was NOT provided:
- Create a minimal template
- Mark as "Needs spec refinement" in description

## Step 4: Create the Bead

Build the bd command:

```bash
# For epic
bd create --type epic --title "<title>" --body "<description>"

# For issue with parent
bd create --type issue --title "<title>" --body "<description>" --parent <parent-id>

# For task
bd create --type task --title "<title>" --body "<description>"

# For bug
bd create --type bug --title "<title>" --body "<description>" --priority <1-3>
```

Execute and capture the bead ID.

## Step 5: If Epic, Prompt for Children

If type is `epic`:

```
Epic created: <epic-id>

An epic needs child issues. Would you like to:
1. Add child issues now (provide titles)
2. Add children later

Suggested children based on title:
- <inferred issue 1>
- <inferred issue 2>
```

## Step 6: Report Result

Output format:

```
BEAD CREATED: <bead-id>

Type: <type>
Title: <title>
Parent: <parent-id or "none">
Status: open

Next steps:
- [If epic] Add child issues: /bead issue "<title>" --parent <epic-id>
- [If feature] Route to Keeper: gt mail send <rig>/mayor -s "KEEPER REVIEW"
- [If bug] Route to Mayor: gt mail send <rig>/mayor -s "BUG TO SLING"
- [If task] Ready for polecat assignment
```

## Critical Rules

1. **No spec.md files** - Everything is a bead
2. **Acceptance criteria required** - Every bead must have testable done criteria
3. **Parent linking** - Features should be epics with child issues
4. **Consistent format** - Use the template, don't improvise
5. **Check for duplicates** - Always search before creating

## Examples

```bash
# Simple task
/bead task "Fix typo in README"

# Bug with priority
/bead bug "Login fails on Safari" --spec "Users report 500 error on Safari 17"

# Feature epic
/bead epic "User Metrics Dashboard" --spec "Add ability to view and export usage metrics"

# Issue under epic
/bead issue "Add metrics collection service" --parent gt-epic-123

# Task under issue
/bead task "Write unit tests for collector" --parent gt-issue-456
```
