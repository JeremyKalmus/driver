#!/bin/bash
#
# Rig Driver - Installation Script
# Installs Driver plugin for hierarchical bead creation
#
# Usage: ./install-driver.sh [options] <town-path>
#
# Options:
#   --skip-mayor       Don't install to Mayor
#   --skip-crew        Don't install to Crew
#   --force            Overwrite existing files
#   -h, --help         Show this help message
#
# Installs to: crew, mayor (NOT witness, refinery, deacon)
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
FORCE=false
SKIP_MAYOR=false
SKIP_CREW=false

# Get the directory where this script lives (driver plugin root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

print_header() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              Driver Plugin - Installation                     ║"
    echo "║     Hierarchical bead creation (Epic -> Task -> Subtask)      ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}→${NC} $1"
}

usage() {
    echo "Usage: $0 [options] <town-path>"
    echo ""
    echo "Install Driver plugin for hierarchical bead creation."
    echo ""
    echo "This plugin provides:"
    echo "  - /bead command with enforced hierarchy"
    echo "  - PreToolUse hook that blocks direct 'bd create'"
    echo "  - Consistent Epic -> Task -> Subtask relationships"
    echo ""
    echo "Installs to: crew, mayor"
    echo "Does NOT install to: witness, refinery, deacon"
    echo ""
    echo "Options:"
    echo "  --skip-mayor       Don't install to Mayor"
    echo "  --skip-crew        Don't install to Crew"
    echo "  --force            Overwrite existing files"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 ~/gt                     # Install to town"
    echo "  $0 --skip-mayor ~/gt        # Crew only"
    echo "  $0 --force ~/gt             # Reinstall everything"
}

# Function to merge PreToolUse hook into existing settings.json
merge_hook_into_settings() {
    local settings_file="$1"
    local hook_script_path="$2"

    # Check if jq is available
    if ! command -v jq &> /dev/null; then
        print_error "jq is required but not installed. Please install jq."
        return 1
    fi

    # Create settings if doesn't exist
    if [[ ! -f "$settings_file" ]]; then
        cat > "$settings_file" << EOF
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "$hook_script_path"
          }
        ]
      }
    ]
  }
}
EOF
        return 0
    fi

    # Check if our hook is already installed
    if grep -q "block-bd-create.sh" "$settings_file" 2>/dev/null; then
        print_warning "Hook already installed in $settings_file"
        return 0
    fi

    # Create the new hook entry as single-line JSON
    # Use single quotes to prevent bash expansion of $CLAUDE_PROJECT_DIR
    local new_hook='{"matcher":"Bash","hooks":[{"type":"command","command":"\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-bd-create.sh"}]}'

    # Merge into existing settings
    local temp_file=$(mktemp)

    # Check if PreToolUse array exists
    if jq -e '.hooks.PreToolUse' "$settings_file" > /dev/null 2>&1; then
        # Append to existing PreToolUse array
        jq --argjson newhook "$new_hook" '.hooks.PreToolUse += [$newhook]' "$settings_file" > "$temp_file"
    else
        # Create PreToolUse array
        jq --argjson newhook "$new_hook" '.hooks.PreToolUse = [$newhook]' "$settings_file" > "$temp_file"
    fi

    mv "$temp_file" "$settings_file"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE=true
            shift
            ;;
        --skip-mayor)
            SKIP_MAYOR=true
            shift
            ;;
        --skip-crew)
            SKIP_CREW=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
        *)
            TOWN_PATH="$1"
            shift
            ;;
    esac
done

# Validate town path
if [[ -z "$TOWN_PATH" ]]; then
    print_error "No town path specified"
    usage
    exit 1
fi

if [[ ! -d "$TOWN_PATH" ]]; then
    print_error "Town path does not exist: $TOWN_PATH"
    exit 1
fi

# Resolve to absolute path
TOWN_PATH="$(cd "$TOWN_PATH" && pwd)"

# Check if this looks like a Gas Town
if [[ ! -d "$TOWN_PATH/mayor" ]]; then
    print_warning "This doesn't look like a Gas Town (no mayor/ directory)"
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

print_header

echo "Installing Driver plugin to: $TOWN_PATH"
echo ""

# ============================================================================
# Step 1: Install hook script to a shared location
# ============================================================================
print_info "Installing hook script..."

HOOKS_DIR="$TOWN_PATH/.driver-hooks"
mkdir -p "$HOOKS_DIR"

cp "$SCRIPT_DIR/.claude/hooks/block-bd-create.sh" "$HOOKS_DIR/"
chmod +x "$HOOKS_DIR/block-bd-create.sh"

print_success "Installed hook script to $HOOKS_DIR/"

# ============================================================================
# Step 2: Install to Crew (all rigs)
# ============================================================================
if [[ "$SKIP_CREW" != true ]]; then
    print_info "Installing to Crew agents..."

    # Find all rig directories that have a crew/ subdirectory
    for rig_dir in "$TOWN_PATH"/*/; do
        rig_name=$(basename "$rig_dir")

        # Skip non-rig directories
        [[ "$rig_name" == "mayor" ]] && continue
        [[ "$rig_name" == ".driver-hooks" ]] && continue
        [[ ! -d "$rig_dir/crew" ]] && continue

        CREW_CLAUDE="$rig_dir/crew/.claude"

        if [[ -d "$CREW_CLAUDE" ]] || [[ -d "$rig_dir/crew" ]]; then
            mkdir -p "$CREW_CLAUDE/commands"
            mkdir -p "$CREW_CLAUDE/hooks"

            # Copy /bead command
            if [[ -f "$SCRIPT_DIR/commands/bead.md" ]]; then
                cp "$SCRIPT_DIR/commands/bead.md" "$CREW_CLAUDE/commands/"
                print_success "Installed /bead to $rig_name/crew"
            fi

            # Copy hook script locally (for portability)
            cp "$SCRIPT_DIR/.claude/hooks/block-bd-create.sh" "$CREW_CLAUDE/hooks/"
            chmod +x "$CREW_CLAUDE/hooks/block-bd-create.sh"

            # Merge hook into settings.json
            HOOK_PATH="\"\$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-bd-create.sh"
            merge_hook_into_settings "$CREW_CLAUDE/settings.json" "$HOOK_PATH"
            print_success "Installed hook to $rig_name/crew"
        fi
    done
fi

# ============================================================================
# Step 3: Install to Mayor
# ============================================================================
if [[ "$SKIP_MAYOR" != true ]]; then
    print_info "Installing to Mayor..."

    MAYOR_PATH="$TOWN_PATH/mayor"

    if [[ -d "$MAYOR_PATH" ]]; then
        MAYOR_CLAUDE="$MAYOR_PATH/.claude"
        mkdir -p "$MAYOR_CLAUDE/commands"
        mkdir -p "$MAYOR_CLAUDE/hooks"

        # Copy /bead command
        if [[ -f "$SCRIPT_DIR/commands/bead.md" ]]; then
            cp "$SCRIPT_DIR/commands/bead.md" "$MAYOR_CLAUDE/commands/"
            print_success "Installed /bead to Mayor"
        fi

        # Copy hook script locally
        cp "$SCRIPT_DIR/.claude/hooks/block-bd-create.sh" "$MAYOR_CLAUDE/hooks/"
        chmod +x "$MAYOR_CLAUDE/hooks/block-bd-create.sh"

        # Merge hook into settings.json
        HOOK_PATH="\"\$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-bd-create.sh"
        merge_hook_into_settings "$MAYOR_CLAUDE/settings.json" "$HOOK_PATH"
        print_success "Installed hook to Mayor"
    else
        print_warning "Mayor directory not found at $MAYOR_PATH"
    fi
fi

# ============================================================================
# Step 4: Create installation record
# ============================================================================
print_info "Creating installation record..."

INSTALL_RECORD="$TOWN_PATH/.driver-hooks/INSTALL-INFO.md"
cat > "$INSTALL_RECORD" << EOF
# Driver Plugin Installation

Installed: $(date)
Version: 0.2.0

## What Was Installed

### Hook Script
- \`.driver-hooks/block-bd-create.sh\` - Blocks direct \`bd create\` commands

### Locations Updated
EOF

if [[ "$SKIP_CREW" != true ]]; then
    echo "- Crew agents in all rigs" >> "$INSTALL_RECORD"
fi
if [[ "$SKIP_MAYOR" != true ]]; then
    echo "- Mayor" >> "$INSTALL_RECORD"
fi

cat >> "$INSTALL_RECORD" << 'EOF'

## Not Updated (by design)
- Witness
- Refinery
- Deacon

These agents may create beads but typically not work-related items that need hierarchy.

## How It Works

1. When an agent tries `bd create`, the PreToolUse hook blocks it
2. The hook tells the agent to use `/bead` instead
3. `/bead` enforces:
   - Epic: no parent (top-level container)
   - Task: parent required (under epic or task)
   - Bug: parent required (under epic or task)

## To Uninstall

Remove the following from each location's `.claude/settings.json`:
- The PreToolUse hook entry referencing `block-bd-create.sh`

Then delete:
- `.driver-hooks/` directory
- `.claude/hooks/block-bd-create.sh` from each location
- `.claude/commands/bead.md` from each location
EOF

print_success "Created installation record"

# ============================================================================
# Summary
# ============================================================================
echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Driver plugin installation complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
echo ""
echo "Installed to: $TOWN_PATH"
echo ""
echo "Agents updated:"
[[ "$SKIP_CREW" != true ]] && echo "  ✓ Crew (all rigs)"
[[ "$SKIP_MAYOR" != true ]] && echo "  ✓ Mayor"
echo ""
echo "Agents NOT updated (by design):"
echo "  - Witness"
echo "  - Refinery"
echo "  - Deacon"
echo ""
echo "Usage:"
echo "  /bead epic \"Feature title\"              # Create top-level epic"
echo "  /bead task \"Task title\" <parent-id>    # Create task under parent"
echo "  /bead bug \"Bug title\" <parent-id>      # Create bug under parent"
echo ""
echo "Direct 'bd create' commands are now blocked for crew and mayor."
echo "They will be prompted to use /bead instead."
echo ""
