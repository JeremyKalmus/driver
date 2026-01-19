# Rig Driver - Gas Town Plugin

**Single point of contact for your rig.**

The Driver plugin reduces cognitive load by providing one dedicated crew member who handles all coordination. You talk to the Driver. The Driver talks to everyone else.

## Problem Solved

Before Driver:
- You manage multiple crew members per rig
- You remember who handles what (Mayor? Keeper? Polecat?)
- You create beads, spec.md files, mail manually
- You track epic progress yourself

After Driver:
- One conversation per rig
- Driver triages and routes automatically
- Consistent bead creation (no more spec.md)
- Epic progress monitoring built-in

## Installation

```bash
cd <your-rig>
gt plugin install driver
```

Or manually:
```bash
./plugins/driver/install/install-driver.sh
```

## Usage

### As a Crew Member

Add Driver as a dedicated crew member for your rig:

```bash
gt crew add driver --role driver
```

Then talk to your Driver:
```bash
gt crew chat driver
```

### Skills Available Everywhere

The plugin installs these slash commands for all agents:

| Command | Purpose |
|---------|---------|
| `/bead` | Create consistent beads (replaces spec.md) |
| `/triage` | Classify requests and recommend action |
| `/epic-status` | Check epic progress and blockers |

## The Workflow

```
┌─────────────────────────────────────────────────────────┐
│                     YOU (User)                           │
│                         │                                │
│                         ▼                                │
│                 ┌───────────────┐                        │
│                 │    DRIVER     │  ← Single contact      │
│                 │  (Crew Member) │                       │
│                 └───────┬───────┘                        │
│                         │                                │
│         ┌───────────────┼───────────────┐               │
│         │               │               │               │
│         ▼               ▼               ▼               │
│   ┌──────────┐   ┌──────────┐   ┌──────────┐          │
│   │  KEEPER  │   │  MAYOR   │   │ POLECAT  │          │
│   │(Arch Rev)│   │(Slinging)│   │ (Work)   │          │
│   └──────────┘   └──────────┘   └──────────┘          │
└─────────────────────────────────────────────────────────┘
```

## Request Types

| You Say | Driver Does |
|---------|-------------|
| "Fix the typo in README" | Creates task, routes to Mayor |
| "Login is broken on Safari" | Creates bug, routes to Mayor |
| "Add user metrics export" | Creates epic + issues, routes to Keeper then Mayor |
| "Should we use GraphQL?" | Routes to Keeper, no beads yet |
| "How does auth work?" | Answers directly, no beads |

## Bead Creation Standard

**All specs are beads. No more spec.md files.**

```bash
# Epic (container for features)
/bead epic "User Metrics Dashboard"

# Issues (concrete work, can have parent)
/bead issue "Add metrics collector" --parent gt-epic-123

# Tasks (smallest unit)
/bead task "Write unit tests"

# Bugs
/bead bug "Crash on empty data"
```

Every bead has:
- Summary
- Acceptance criteria
- Context
- Constraints

## Epic Monitoring

Driver tracks epic progress:

```
/epic-status gt-epic-123

EPIC STATUS: gt-epic-123
==========================================
Title: User Metrics Dashboard
[████████░░░░░░░░░░░░] 40% (4/10 complete)

BLOCKED
-------
- [!] gt-issue-456: Export endpoint
      Blocker: Waiting on API decision
      Action needed: Resolve architecture question

READY TO START
--------------
- [ ] gt-issue-789: Add CSV formatter
```

## Integration with Keeper

If Keeper is installed, Driver automatically:
1. Routes features through Keeper review first
2. Waits for approval before slinging work
3. Includes Keeper ADR references in beads

## Configuration

In `driver/driver.yaml`:

```yaml
driver:
  auto-route: true           # Automatically route after triage
  require-keeper: false      # Always require Keeper for features
```

## What Gets Installed

The plugin standardizes bead handling across ALL agent types:

| Agent | Gets | Purpose |
|-------|------|---------|
| **Driver** (crew) | Full context + all commands | Single point of contact |
| **Mayor** | `/bead`, `/epic-status`, MAYOR-BRIEFING.md | Create beads consistently |
| **Polecats** | `/bead` (limited), POLECAT-BRIEFING.md | Status updates, discovered bugs |
| **Refinery** | `/bead` | Reference during merge |

### Briefings Installed

- **MAYOR-BRIEFING.md**: How Mayor should create and dispatch beads
- **POLECAT-BRIEFING.md**: How Polecats should read, update, and report status

## The Bead Contract

Every bead MUST have:

```markdown
## Summary
What and why (one paragraph).

## Acceptance Criteria
- [ ] Specific, testable criterion
- [ ] That defines "done"

## Context
Background, dependencies, parent references.

## Constraints
Technical limits, Keeper decisions.
```

**Polecats are evaluated against acceptance criteria.** If criteria are vague, work will be vague.

## Philosophy

**Absorb complexity. Emit clarity.**

The Driver's success is measured by how little the user needs to think about Gas Town machinery. One conversation. One contact. Clear status.
