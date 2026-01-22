---
description: Create beads with enforced hierarchy (Epic -> Task -> Subtask) and optional test verification
allowed-tools: Read,Bash(bd:*),Bash(bd --no-daemon:*),Bash(cat:*),Bash(ls:*)
argument-hint: <type> "<title>" [parent-id] [--keeper <ADR-id>] [--spec "<description>"]
---

# /bead - Hierarchical Bead Creation with Test Verification

Create beads with enforced parent-child relationships and optional test linkage for TDD.

## Usage

```
/bead epic "<title>" [--spec "<description>"]
/bead task "<title>" <parent-id> [--keeper <ADR-id>] [--spec "<description>"]
/bead bug "<title>" <parent-id> [--keeper <ADR-id>] [--spec "<description>"]
```

## Hierarchy Rules (STRICTLY ENFORCED)

| Type | Parent Required? | Valid Parents | Purpose |
|------|------------------|---------------|---------|
| `epic` | NO | None | Top-level container for a feature/initiative |
| `task` | YES | Epic or Task | Concrete work item |
| `bug` | YES | Epic or Task | Something broken to fix |

**A task under an epic = Task. A task under a task = Subtask.**

## Critical Rule: NO CODE IN DESCRIPTIONS

**Beads are specifications, not implementations. Polecats write the code.**

### FORBIDDEN in bead descriptions:
- Code blocks with implementation (functions, classes, methods)
- Inline code snippets that solve the problem
- Copy-paste ready solutions
- Pseudocode that's essentially the implementation

### ALLOWED in bead descriptions:
- File paths to reference: `src/auth/login.ts`
- Line references: `src/auth/login.ts:42-67`
- Function/class names to modify: "Update the `validateCredentials` function"
- Interface/type references: "Use the existing `UserCredentials` type"
- Test file references: `src/auth/__tests__/login.test.ts`
- API endpoint references: `POST /auth/login`

### Examples

**BAD** (contains implementation):
```
## Summary
Add login endpoint:
\`\`\`typescript
app.post('/login', async (req, res) => {
  const { email, password } = req.body;
  const user = await db.users.findByEmail(email);
  // ... implementation
});
\`\`\`
```

**GOOD** (references without implementation):
```
## Summary
Add POST /auth/login endpoint in src/routes/auth.ts.
Use existing validateCredentials() from src/auth/utils.ts.
Return JWT using createToken() from src/auth/jwt.ts.
```

## Parse Arguments

Input: $ARGUMENTS

Expected formats:
- `epic "<title>"` - Create top-level epic
- `epic "<title>" --spec "<description>"` - Epic with description
- `task "<title>" <parent-id>` - Task under parent
- `task "<title>" <parent-id> --keeper ADR-010` - Task with keeper decision
- `task "<title>" <parent-id> --spec "<description>"` - Task with description
- `bug "<title>" <parent-id>` - Bug under parent

## Step 1: Validate Type and Parent

```
IF type is "epic":
  - Parent must NOT be specified
  - Proceed to Step 2

IF type is "task" or "bug":
  - Parent MUST be specified
  - IF no parent provided:
      OUTPUT ERROR:
      "ERROR: <type> requires a parent ID.

       Usage: /bead <type> "<title>" <parent-id>

       To find valid parents:
         bd list --type epic --status open    # List open epics
         bd list --type task --status open    # List open tasks

       Example: /bead task "Implement login form" jeremy-abc123"
      STOP - do not create anything

  - Verify parent exists:
      bd show <parent-id> --json
  - IF parent doesn't exist:
      OUTPUT ERROR: "Parent <parent-id> not found"
      STOP
```

## Step 2: Check for Keeper Decision (if --keeper specified)

If `--keeper <ADR-id>` was provided:

```bash
# Find keeper decisions directory
ls keeper/decisions/<ADR-id>*.yaml 2>/dev/null || ls */keeper/decisions/<ADR-id>*.yaml 2>/dev/null
```

If found, read the decision and extract:
- `verification.test_files` - Which test files to work with
- `verification.criteria` - Acceptance criteria with IDs and test names
- `verification.fixtures` - Test fixtures to use
- `verification.run_command` - How to run the tests

If keeper decision has a `verification:` block, USE IT to populate the bead's verification.

## Step 3: Build Description with Verification Block

### For tasks/bugs WITH keeper decision verification:

```markdown
---
verification:
  keeper_decision: <ADR-id>
  test_files:
    - file: <from keeper decision>
      action: <extend|create|modify>
  criteria:
    - id: AC-1
      criterion: "<from keeper decision>"
      test: "<test name from keeper decision>"
    - id: AC-2
      criterion: "<from keeper decision>"
      test: "<test name from keeper decision>"
  run_command: "<from keeper decision>"
---

## Summary
<One paragraph: what needs to be done and why. NO CODE - reference files/functions only>

## Acceptance Criteria
- [ ] **AC-1**: <criterion text>
- [ ] **AC-2**: <criterion text>

## Context
Parent: <parent-id> (<parent-type>: <parent-title>)
Keeper ADR: <ADR-id>

## Constraints
<From keeper decision forbidden/constraints>
- NO CODE in this bead - polecats implement
```

### For tasks/bugs WITHOUT keeper decision:

Auto-generate AC IDs for each criterion:

```markdown
---
verification:
  criteria:
    - id: AC-1
      criterion: "<extracted from spec>"
    - id: AC-2
      criterion: "<extracted from spec>"
---

## Summary
<One paragraph: what needs to be done and why. NO CODE - reference files/functions only>

## Acceptance Criteria
- [ ] **AC-1**: <criterion 1>
- [ ] **AC-2**: <criterion 2>

## Context
Parent: <parent-id> (<parent-type>: <parent-title>)

## Constraints
- NO CODE in this bead - polecats implement
- <Any technical constraints>
```

### For epics (no verification block):

```markdown
## Summary
<One paragraph: what this epic encompasses>

## Acceptance Criteria
- [ ] All child tasks completed
- [ ] <High-level success criteria>

## Context
Top-level epic for <feature/initiative>
```

## Step 4: Create the Bead

Build and execute the bd command:

```bash
# For epic (no parent)
bd create --type epic --title "<title>" --description "<description>"

# For task/bug (with parent)
bd create --type <type> --title "<title>" --parent <parent-id> --description "<description>"
```

Capture the created bead ID from the output.

## Step 5: Show Hierarchy and Verification Confirmation

After successful creation, output:

```
BEAD CREATED
============

ID:     <new-bead-id>
Type:   <type>
Title:  <title>
Parent: <parent-id or "none (top-level epic)">
Status: open

Hierarchy:
<Run: bd graph <epic-id> --compact>

Verification:
  Keeper ADR: <ADR-id or "none">
  Test file:  <test file or "not specified">
  Criteria:
    AC-1: <criterion> → <test name or "needs test">
    AC-2: <criterion> → <test name or "needs test">
  Run: <run_command or "project default">

Description:
<The full description including YAML frontmatter>

---
Next steps:
  - To add children: /bead task "<child-title>" <new-bead-id>
  - To run tests: <run_command>
```

## Step 6: Verify Linkage

After creation, verify the parent-child link:

```bash
bd show <new-bead-id> --json | jq '.parent'
```

If parent doesn't match expected, report error.

## Examples

### Create an Epic (no verification)
```
/bead epic "User Authentication System" --spec "Implement complete auth flow"
```

Output:
```
BEAD CREATED
============

ID:     jeremy-a1b2c3
Type:   epic
Title:  User Authentication System
Parent: none (top-level epic)

Hierarchy:
  jeremy-a1b2c3 [epic] User Authentication System

Verification: N/A (epics don't have verification)

---
## Summary
Implement complete auth flow including login, logout, and session management.

## Acceptance Criteria
- [ ] All child tasks completed
- [ ] Users can authenticate and maintain sessions
```

### Create a Task with Keeper Decision
```
/bead task "Store player state on reconnect" jeremy-epic-123 --keeper ADR-010
```

Output:
```
BEAD CREATED
============

ID:     jeremy-d4e5f6
Type:   task
Title:  Store player state on reconnect
Parent: jeremy-epic-123 (epic: Game State Management)

Hierarchy:
  jeremy-epic-123 [epic] Game State Management
    jeremy-d4e5f6 [task] Store player state on reconnect  <-- NEW

Verification:
  Keeper ADR: ADR-010
  Test file:  packages/server/src/events/GameManager.test.ts
  Criteria:
    AC-1: Player state stored on reportState → "should store player state"
    AC-2: State restored on reconnect → "should include state in rejoinGameSuccess"
  Run: npm test --workspace=server

---
verification:
  keeper_decision: ADR-010
  test_files:
    - file: packages/server/src/events/GameManager.test.ts
      action: extend
  criteria:
    - id: AC-1
      criterion: "Player state stored on reportState"
      test: "should store player state when reportState received"
    - id: AC-2
      criterion: "State restored on reconnect"
      test: "should include player state in rejoinGameSuccess"
  run_command: "npm test --workspace=server"
---

## Summary
Extend GameManager to store player card state when reportState is received,
and restore it when player reconnects via rejoinGame.

## Acceptance Criteria
- [ ] **AC-1**: Player state stored on reportState
- [ ] **AC-2**: State restored on reconnect

## Context
Parent: jeremy-epic-123 (epic: Game State Management)
Keeper ADR: ADR-010

## Constraints
- MUST use existing PlayerGameState type
- MUST extend GameManager, not create new state store
- Server state is authoritative
```

### Create a Task without Keeper (auto-generate ACs)
```
/bead task "Write unit tests for login" jeremy-task-456 --spec "Add tests for the login endpoint covering valid and invalid credentials"
```

Output:
```
BEAD CREATED
============

ID:     jeremy-g7h8i9
Type:   task
Title:  Write unit tests for login
Parent: jeremy-task-456 (task: Implement login endpoint)

Verification:
  Keeper ADR: none
  Test file:  not specified
  Criteria:
    AC-1: Valid credentials return JWT → needs test
    AC-2: Invalid credentials return 401 → needs test
  Run: project default

---
verification:
  criteria:
    - id: AC-1
      criterion: "Valid credentials return JWT"
    - id: AC-2
      criterion: "Invalid credentials return 401"
---

## Summary
Add tests for the login endpoint covering valid and invalid credentials.

## Acceptance Criteria
- [ ] **AC-1**: Valid credentials return JWT
- [ ] **AC-2**: Invalid credentials return 401

## Context
Parent: jeremy-task-456 (task: Implement login endpoint)
```

## Error Cases

### Missing Parent for Task
```
/bead task "Some task"

ERROR: task requires a parent ID.

Usage: /bead task "<title>" <parent-id>
```

### Keeper Decision Not Found
```
/bead task "Some task" jeremy-123 --keeper ADR-999

WARNING: Keeper decision ADR-999 not found.
Creating bead without verification linkage.
Consider running /keeper-review first.
```

### Invalid Parent ID
```
/bead task "Some task" invalid-id

ERROR: Parent 'invalid-id' not found.
```

## AC ID Generation Rules

1. **With Keeper decision**: Use IDs from the decision's `verification.criteria`
2. **Without Keeper decision**: Auto-generate as AC-1, AC-2, AC-3, etc.
3. **Global reference format**: `<bead-id>-AC-1` (e.g., `jeremy-d4e5f6-AC-1`)
4. **Max criteria**: If more than 10 criteria, consider splitting into subtasks
