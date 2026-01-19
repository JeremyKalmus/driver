#!/bin/bash
#
# Rig Driver - Uninstallation Script
# Removes Driver coordination system from a Gas Town rig
#
# Usage: ./uninstall-driver.sh [options] <rig-path>
#
# Options:
#   --keep-config      Preserve driver.yaml configuration
#   -h, --help         Show this help message
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
KEEP_CONFIG=false

print_header() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              Rig Driver - Uninstallation                      ║"
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
    echo "Usage: $0 [options] <rig-path>"
    echo ""
    echo "Remove Driver coordination system from a Gas Town rig."
    echo ""
    echo "Options:"
    echo "  --keep-config    Preserve driver.yaml configuration"
    echo "  -h, --help       Show this help message"
    echo ""
    echo "Note: Beads created by the plugin are preserved."
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --keep-config)
            KEEP_CONFIG=true
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
            RIG_PATH="$1"
            shift
            ;;
    esac
done

# Validate rig path
if [[ -z "$RIG_PATH" ]]; then
    print_error "No rig path specified"
    usage
    exit 1
fi

if [[ ! -d "$RIG_PATH" ]]; then
    print_error "Rig path does not exist: $RIG_PATH"
    exit 1
fi

# Resolve to absolute path
RIG_PATH="$(cd "$RIG_PATH" && pwd)"
RIG_NAME="$(basename "$RIG_PATH")"

print_header

echo "Uninstalling Driver from rig: $RIG_NAME"
echo "Path: $RIG_PATH"
echo ""

# Remove rig-level commands
print_info "Removing rig-level commands..."

for cmd in bead.md triage.md epic-status.md; do
    if [[ -f "$RIG_PATH/.claude/commands/$cmd" ]]; then
        rm -f "$RIG_PATH/.claude/commands/$cmd"
        print_success "Removed $cmd from rig .claude/commands/"
    fi
done

# Remove Mayor commands and briefing
print_info "Removing Mayor commands and briefing..."

MAYOR_RIG="$RIG_PATH/mayor/rig"
if [[ -d "$MAYOR_RIG" ]]; then
    rm -f "$MAYOR_RIG/.claude/commands/bead.md"
    rm -f "$MAYOR_RIG/.claude/commands/epic-status.md"
    rm -rf "$MAYOR_RIG/driver"
    print_success "Removed Driver files from Mayor"
fi

# Remove Polecat commands and briefing
print_info "Removing Polecat commands and briefing..."

if [[ -d "$RIG_PATH/polecats" ]]; then
    rm -f "$RIG_PATH/polecats/.claude/commands/bead.md"
    rm -rf "$RIG_PATH/polecats/driver"
    print_success "Removed Driver files from Polecats"
fi

# Remove Refinery commands
print_info "Removing Refinery commands..."

if [[ -d "$RIG_PATH/refinery/rig" ]]; then
    rm -f "$RIG_PATH/refinery/rig/.claude/commands/bead.md"
    print_success "Removed Driver files from Refinery"
fi

# Remove driver directory
print_info "Removing driver directory..."

if [[ -d "$RIG_PATH/driver" ]]; then
    if [[ "$KEEP_CONFIG" == true ]] && [[ -f "$RIG_PATH/driver/driver.yaml" ]]; then
        # Keep only the config
        find "$RIG_PATH/driver" -type f ! -name "driver.yaml" -delete
        find "$RIG_PATH/driver" -type d -empty -delete 2>/dev/null || true
        print_success "Removed driver/ (kept driver.yaml)"
    else
        rm -rf "$RIG_PATH/driver"
        print_success "Removed driver/ directory"
    fi
fi

# Summary
echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Driver uninstallation complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
echo ""
echo "Note: Any beads created by the plugin are preserved."
echo ""
