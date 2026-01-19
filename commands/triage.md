---
description: Classify request and recommend action
allowed-tools: Read,Bash(bd:*),Bash(ls:*),Bash(cat:*),Bash(gt mail:*)
argument-hint: <request description>
---

# /triage - Request Classification

Classify incoming requests and recommend the appropriate Gas Town action.

## Input

Request: $ARGUMENTS

## Step 1: Signal Detection

Scan the request for classification signals:

### Quick Fix Signals
- "typo", "spelling", "small change", "one-liner"
- "just", "simply", "quick"
- References single file or line
- Estimated < 30 minutes work

### Bug Signals
- "broken", "error", "doesn't work", "crash"
- "regression", "used to work"
- "500", "exception", "fails"
- Describes unexpected behavior

### Feature Signals
- "add", "new", "implement", "create"
- "feature", "capability", "ability to"
- "users should be able to"
- Describes desired behavior that doesn't exist

### Architecture Signals
- "design", "approach", "architecture"
- "should we", "how should", "what's the best way"
- "pattern", "structure", "organize"
- Questions about HOW rather than WHAT

### Question Signals
- "how does", "where is", "explain", "what is"
- "?", inquiry without action request
- Seeking understanding, not change

## Step 2: Confidence Assessment

Rate confidence in classification:

| Confidence | Criteria |
|------------|----------|
| High | Multiple clear signals, unambiguous |
| Medium | Some signals present, mostly clear |
| Low | Mixed signals, could be multiple types |

If Low confidence, list the ambiguity and ask for clarification.

## Step 3: Scope Assessment

For non-questions, assess scope:

| Scope | Indicators | Bead Type |
|-------|------------|-----------|
| Tiny | Single file, < 30 min | task |
| Small | Few files, < 2 hours | issue |
| Medium | Multiple files, 2-8 hours | issue |
| Large | Multiple components, > 1 day | epic + issues |
| Huge | Cross-cutting, > 1 week | epic + architecture review |

## Step 4: Check Context

Gather relevant context:

```bash
# Check if related work exists
bd list --status open | head -20

# Check if Keeper is installed (for feature routing)
ls keeper/keeper.yaml 2>/dev/null && echo "Keeper: installed" || echo "Keeper: not installed"
```

## Step 5: Generate Recommendation

Output format:

```
TRIAGE RESULT
=============

Classification: <QUICK_FIX | BUG | FEATURE | ARCHITECTURE | QUESTION>
Confidence: <HIGH | MEDIUM | LOW>
Scope: <TINY | SMALL | MEDIUM | LARGE | HUGE>

Summary: <one sentence summary of request>

RECOMMENDED ACTION:
------------------

[If QUICK_FIX]
1. Create task bead: /bead task "<suggested title>"
2. Route to Mayor for next polecat, OR
3. Handle directly if trivial

[If BUG]
1. Create bug bead: /bead bug "<suggested title>" --spec "<error details>"
2. Set priority: 1 (critical) / 2 (high) / 3 (normal)
3. Route to Mayor: gt mail send <rig>/mayor -s "BUG: <title>"

[If FEATURE]
1. Create epic: /bead epic "<suggested title>" --spec "<feature description>"
2. Identify child issues (suggest 2-5)
3. [If Keeper installed] Route for review first
4. [After approval] Route to Mayor for slinging

Suggested epic structure:
- Epic: <title>
  - Issue: <child 1>
  - Issue: <child 2>
  - Issue: <child 3>

[If ARCHITECTURE]
Do NOT create beads yet.
1. Gather more context about the question
2. Route to Keeper: gt mail send <rig>/mayor -s "ARCHITECTURE: <question>"
3. Wait for Keeper guidance before creating work

[If QUESTION]
Do NOT create beads.
1. Research/answer the question directly
2. If answer reveals work needed, re-triage as appropriate type

RELATED WORK:
------------
<List any existing open beads that might be related>

NEXT STEP: <single clear action to take>
```

## Step 6: Offer to Execute

After presenting the recommendation:

```
Ready to proceed? Options:
1. Execute recommended action
2. Adjust classification
3. Get more details first
4. Cancel
```

## Classification Decision Tree

```
Is it a question seeking understanding?
├─ YES → QUESTION (no beads)
└─ NO ↓

Is something currently broken?
├─ YES → BUG
└─ NO ↓

Does it add new capability?
├─ YES ↓
│   Is it about HOW to build it?
│   ├─ YES → ARCHITECTURE
│   └─ NO → FEATURE
└─ NO ↓

Is it a small change to existing code?
├─ YES → QUICK_FIX
└─ NO → Ask for clarification
```

## Examples

**Input**: "The login button doesn't work on mobile"
**Output**: BUG, HIGH confidence, SMALL scope

**Input**: "Add ability for users to export their data as CSV"
**Output**: FEATURE, HIGH confidence, MEDIUM scope (epic with 2-3 issues)

**Input**: "Should we use GraphQL or REST for the new API?"
**Output**: ARCHITECTURE, HIGH confidence, route to Keeper

**Input**: "Fix typo in the footer"
**Output**: QUICK_FIX, HIGH confidence, TINY scope

**Input**: "How does the auth system work?"
**Output**: QUESTION, HIGH confidence, answer directly
