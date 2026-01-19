---
description: Check progress of an epic and its children
allowed-tools: Read,Bash(bd:*),Bash(bd --no-daemon:*)
argument-hint: <epic-id>
---

# /epic-status - Epic Progress Report

Check the status of an epic and all its children to understand progress and blockers.

## Input

Epic ID: $ARGUMENTS

## Step 1: Validate Epic Exists

```bash
bd show $ARGUMENTS
```

If not found or not an epic type, report error.

## Step 2: Get Children

```bash
bd list --parent $ARGUMENTS --json
```

Parse the JSON to get all child beads.

## Step 3: Categorize Children

Group children by status:

| Status | Meaning |
|--------|---------|
| `open` | Not started |
| `in_progress` | Currently being worked |
| `blocked` | Has blockers |
| `done` | Completed |
| `closed` | Completed and verified |

## Step 4: Identify Blockers

For any `blocked` children:

```bash
bd show <child-id>
```

Extract blocker information:
- What is blocking?
- Who/what can unblock?
- How long blocked?

## Step 5: Calculate Progress

```
Total children: X
Completed: Y (done + closed)
In progress: Z
Blocked: B
Open (not started): O

Progress: Y/X (XX%)
```

## Step 6: Identify Next Actions

Determine what can move forward:

```bash
bd ready --parent $ARGUMENTS
```

This shows children that:
- Have no blockers
- Have all dependencies met
- Are ready for work

## Step 7: Generate Report

Output format:

```
EPIC STATUS: <epic-id>
==========================================

Title: <epic title>
Created: <date>
Owner: <assignee if any>

PROGRESS
--------
[████████░░░░░░░░░░░░] 40% (4/10 complete)

BREAKDOWN
---------
Completed:    4
In Progress:  2
Blocked:      1
Open:         3

COMPLETED
---------
- [x] <child-1>: <title>
- [x] <child-2>: <title>
- [x] <child-3>: <title>
- [x] <child-4>: <title>

IN PROGRESS
-----------
- [ ] <child-5>: <title> (assigned to: polecat-abc)
- [ ] <child-6>: <title> (assigned to: polecat-def)

BLOCKED
-------
- [!] <child-7>: <title>
      Blocker: <description of blocker>
      Blocked since: <date>
      Action needed: <what needs to happen>

READY TO START
--------------
- [ ] <child-8>: <title>
- [ ] <child-9>: <title>

NOT READY (has dependencies)
---------------------------
- [ ] <child-10>: <title>
      Waiting on: <dependency-id>

RECOMMENDATIONS
---------------
1. <Most important next action>
2. <Second priority action>
3. <If blocked> Resolve blocker on <child-id>

ESTIMATED COMPLETION
--------------------
Based on current velocity: <estimate or "insufficient data">
```

## Step 8: Offer Actions

```
Actions available:
1. Nudge Mayor to sling ready work
2. Investigate blocker on <blocked-child>
3. Add more child issues to this epic
4. Mark epic as complete (if all children done)
5. View details of specific child
```

## Progress Bar Generation

Generate ASCII progress bar:

```
0%   [░░░░░░░░░░░░░░░░░░░░]
25%  [█████░░░░░░░░░░░░░░░]
50%  [██████████░░░░░░░░░░]
75%  [███████████████░░░░░]
100% [████████████████████]
```

Each █ represents 5% progress.

## Completion Detection

If all children are done/closed:

```
EPIC COMPLETE!
=============

All 10 children are complete.

Ready to close epic? This will:
- Mark <epic-id> as closed
- Update any parent references
- Log completion in events

Confirm: /bead close <epic-id>
```

## No Children Warning

If epic has no children:

```
WARNING: Epic has no children

An epic should have child issues that break down the work.
Use: /bead issue "<title>" --parent <epic-id>

Suggested breakdown based on epic description:
- <inferred issue 1>
- <inferred issue 2>
- <inferred issue 3>
```
