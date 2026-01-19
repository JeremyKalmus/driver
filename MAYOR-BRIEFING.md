# Mayor Bead Protocol

**You create and dispatch beads. Use the standard format.**

This briefing standardizes how Mayor creates and manages beads.

## Creating Beads

When you need to create work items, use the `/bead` command:

```bash
/bead <type> "<title>" [--parent <id>] [--spec "<description>"]
```

**Always use /bead.** Don't use raw `bd create` - it won't enforce the format.

### Types

| Type | When to Use |
|------|-------------|
| `epic` | Container for a feature with multiple issues |
| `issue` | Concrete work item (can be standalone or child of epic) |
| `task` | Smallest unit, very specific |
| `bug` | Something broken |

### Required Format

Every bead MUST have:

```markdown
## Summary
One paragraph: what and why.

## Acceptance Criteria
- [ ] Specific, testable criterion
- [ ] That defines "done"
- [ ] Polecats will be evaluated against these

## Context
Background, links, dependencies.
If child of epic: "Part of: <epic-id>"
If Keeper approved: "Keeper ADR: <adr-id>"

## Constraints
Technical constraints.
Keeper forbidden patterns.
```

## Before Creating Beads

### For Features (Multi-Issue Work)

1. **Check if Keeper is installed:**
   ```bash
   ls keeper/keeper.yaml
   ```

2. **If Keeper exists, get review first:**
   ```bash
   /keeper-review "<feature description>"
   ```

3. **Only after APPROVED, create beads:**
   ```bash
   /bead epic "<feature title>" --spec "<full description>"
   /bead issue "<child 1>" --parent <epic-id>
   /bead issue "<child 2>" --parent <epic-id>
   ```

4. **Reference Keeper decision in beads:**
   ```markdown
   ## Context
   Keeper ADR: keeper/decisions/NNN-<name>.yaml
   Approved components: <list>

   ## Constraints
   - <from Keeper forbidden list>
   ```

### For Bugs

1. Create bug bead with priority:
   ```bash
   /bead bug "<title>" --spec "<error details>"
   bd update <bug-id> --priority <1-3>
   ```

2. Priority guide:
   - 1: Critical (system down, data loss)
   - 2: High (major feature broken)
   - 3: Normal (annoying but workaround exists)

## Dispatching Work

When slinging polecats, ensure:

1. **Bead has all required sections**
2. **Acceptance criteria are testable**
3. **Constraints are clear**
4. **Dependencies are resolved** (no blocked parents)

```bash
# Check bead is ready
bd show <issue-id>

# Verify no blockers
bd list --parent <issue-id> --status blocked
```

## Monitoring Work

### Check Epic Progress
```bash
/epic-status <epic-id>
```

### Find Ready Work
```bash
bd ready                    # Unblocked, unassigned
bd list --status in_progress  # Currently being worked
bd list --status blocked    # Stuck items
```

### When Polecat Reports Blocker
1. Read the blocker reason
2. Determine if you can unblock
3. If not, escalate to user or Keeper
4. Update bead when unblocked:
   ```bash
   bd update <issue-id> --status open --notes "Unblocked: <resolution>"
   ```

## What You Must NEVER Do

- Create beads without the required format
- Skip Keeper review for features (if Keeper installed)
- Dispatch work with vague acceptance criteria
- Close issues (Refinery does that after merge)
- Create spec.md files (use beads)

## Epic Lifecycle

```
1. Feature request arrives
2. /keeper-review (if Keeper installed)
3. /bead epic + child issues
4. Sling polecats for ready children
5. Monitor progress
6. When all children complete → close epic
```

## The Contract

**Polecats trust your beads.**

If you create a bead with unclear acceptance criteria, the polecat will either:
- Fail because they didn't know what "done" meant
- Mail you asking for clarification (wasting time)

Write beads like contracts. Be specific. Be testable.
