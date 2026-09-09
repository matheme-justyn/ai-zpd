#!/usr/bin/env bash
# sync-template.sh - Sync template updates to project
# Compares .template-version with .scaffolding/VERSION and syncs changes

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEMPLATE_DIR="$PROJECT_ROOT/.scaffolding"
VERSION_FILE="$TEMPLATE_DIR/VERSION"
TRACKING_FILE="$PROJECT_ROOT/.template-version"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default exclude patterns
DEFAULT_EXCLUDES=(
    ".git"
    ".opencode-data"
    "node_modules"
    ".DS_Store"
    "VERSION"
    "CHANGELOG.md"
    "README.md"
    "README.*.md"
)

# User-configurable excludes from command line
USER_EXCLUDES=()

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Sync template updates from .scaffolding/ to project root.

OPTIONS:
    -h, --help              Show this help message
    -e, --exclude PATTERN   Exclude pattern (can be used multiple times)
    -n, --dry-run           Show what would be synced without applying changes
    -f, --force             Force sync even if versions are the same
    -y, --yes               Auto-confirm all prompts

EXAMPLES:
    $0                                      # Interactive sync
    $0 -n                                   # Dry run (preview changes)
    $0 -e "docs/*" -e "scripts/custom.sh"   # Exclude specific files
    $0 -f                                   # Force sync regardless of version

NOTES:
    - Compares .template-version (current) with .scaffolding/VERSION (latest)
    - Shows git-style diff summary before applying changes
    - Detects conflicts with modified project files
    - Preserves user customizations by default

EOF
    exit 0
}

log_info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

log_success() {
    echo -e "${GREEN}✓${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $*"
}

log_error() {
    echo -e "${RED}✗${NC} $*"
}

# Parse command line arguments
DRY_RUN=false
FORCE=false
AUTO_YES=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -e|--exclude)
            USER_EXCLUDES+=("$2")
            shift 2
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -y|--yes)
            AUTO_YES=true
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            ;;
    esac
done

# Check if .scaffolding/ exists
if [[ ! -d "$TEMPLATE_DIR" ]]; then
    log_error ".scaffolding/ directory not found. Are you in the project root?"
    exit 1
fi

# Check if VERSION file exists
if [[ ! -f "$VERSION_FILE" ]]; then
    log_error ".scaffolding/VERSION file not found."
    exit 1
fi

LATEST_VERSION=$(cat "$VERSION_FILE")

# Check current tracked version
if [[ ! -f "$TRACKING_FILE" ]]; then
    log_warning ".template-version not found. This appears to be first-time setup."
    CURRENT_VERSION="none"
else
    CURRENT_VERSION=$(cat "$TRACKING_FILE")
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}         Template Synchronization${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
log_info "Current version: ${YELLOW}${CURRENT_VERSION}${NC}"
log_info "Latest version:  ${GREEN}${LATEST_VERSION}${NC}"
echo ""

# Check if sync is needed
if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]] && [[ "$FORCE" == false ]]; then
    log_success "Already up to date. No sync needed."
    log_info "Use --force to sync anyway."
    exit 0
fi

# Combine exclude patterns
ALL_EXCLUDES=("${DEFAULT_EXCLUDES[@]}" ${USER_EXCLUDES[@]+'"${USER_EXCLUDES[@]}"'})

# Build rsync exclude arguments
RSYNC_EXCLUDES=()
for pattern in "${ALL_EXCLUDES[@]}"; do
    RSYNC_EXCLUDES+=(--exclude="$pattern")
done

# Show what will be excluded
if [[ ${#USER_EXCLUDES[@]:-0} -gt 0 ]]; then
    log_info "User excludes: ${USER_EXCLUDES[*]}"
fi

# Generate file list to sync (dry run first)
log_info "Scanning for changes..."
SYNC_LIST=$(rsync -avin --delete "${RSYNC_EXCLUDES[@]}" "$TEMPLATE_DIR/" "$PROJECT_ROOT/" | grep -v "/$" | grep -v "^$" || true)

if [[ -z "$SYNC_LIST" ]]; then
    log_success "No files to sync."
    
    # Update version tracking
    if [[ "$DRY_RUN" == false ]]; then
        echo "$LATEST_VERSION" > "$TRACKING_FILE"
        log_success "Updated .template-version to $LATEST_VERSION"
    fi
    
    exit 0
fi

# Parse sync list to categorize changes
NEW_FILES=()
MODIFIED_FILES=()
DELETED_FILES=()

while IFS= read -r line; do
    # Skip summary lines
    [[ "$line" =~ ^(sending|total|sent|received) ]] && continue
    
    # Parse rsync output format
    if [[ "$line" =~ ^[*]deleting ]]; then
        file="${line#*deleting }"
        DELETED_FILES+=("$file")
    elif [[ "$line" =~ ^\> ]]; then
        file="${line#>* }"
        if [[ -f "$PROJECT_ROOT/$file" ]]; then
            MODIFIED_FILES+=("$file")
        else
            NEW_FILES+=("$file")
        fi
    fi
done <<< "$SYNC_LIST"

# Display change summary
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}         Change Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

if [[ ${#NEW_FILES[@]} -gt 0 ]]; then
    echo -e "${GREEN}New files (${#NEW_FILES[@]}):${NC}"
    for file in "${NEW_FILES[@]}"; do
        echo -e "  ${GREEN}+${NC} $file"
    done
    echo ""
fi

if [[ ${#MODIFIED_FILES[@]} -gt 0 ]]; then
    echo -e "${YELLOW}Modified files (${#MODIFIED_FILES[@]}):${NC}"
    for file in "${MODIFIED_FILES[@]}"; do
        echo -e "  ${YELLOW}~${NC} $file"
    done
    echo ""
fi

if [[ ${#DELETED_FILES[@]} -gt 0 ]]; then
    echo -e "${RED}Deleted files (${#DELETED_FILES[@]}):${NC}"
    for file in "${DELETED_FILES[@]}"; do
        echo -e "  ${RED}-${NC} $file"
    done
    echo ""
fi

TOTAL_CHANGES=$((${#NEW_FILES[@]} + ${#MODIFIED_FILES[@]} + ${#DELETED_FILES[@]}))
echo -e "${BLUE}Total changes: $TOTAL_CHANGES${NC}"
echo ""

# Conflict detection for modified files
CONFLICTS=()
if [[ ${#MODIFIED_FILES[@]} -gt 0 ]]; then
    log_info "Checking for conflicts..."
    
    for file in "${MODIFIED_FILES[@]}"; do
        project_file="$PROJECT_ROOT/$file"
        template_file="$TEMPLATE_DIR/$file"
        
        # Check if project file has been modified from original template
        if [[ -f "$project_file" ]] && [[ -f "$template_file" ]]; then
            # Simple check: if file size differs significantly, likely customized
            project_size=$(wc -c < "$project_file")
            template_size=$(wc -c < "$template_file")
            size_diff=$(( (project_size - template_size) * 100 / template_size ))
            
            if [[ $size_diff -gt 20 ]] || [[ $size_diff -lt -20 ]]; then
                CONFLICTS+=("$file")
            fi
        fi
    done
    
    if [[ ${#CONFLICTS[@]} -gt 0 ]]; then
        echo ""
        log_warning "Potential conflicts detected (${#CONFLICTS[@]} files):"
        for file in "${CONFLICTS[@]}"; do
            echo -e "  ${YELLOW}!${NC} $file (significantly different from template)"
        done
        echo ""
        log_warning "These files may contain user customizations."
        log_warning "Syncing will overwrite them. Consider backing up first."
        echo ""
    fi
fi

# Dry run exit
if [[ "$DRY_RUN" == true ]]; then
    log_info "Dry run complete. No changes applied."
    log_info "Run without -n/--dry-run to apply changes."
    exit 0
fi

# Confirm before syncing
if [[ "$AUTO_YES" == false ]]; then
    echo -e "${YELLOW}Proceed with sync?${NC} [y/N] "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log_info "Sync cancelled."
        exit 0
    fi
fi

# Perform actual sync
log_info "Syncing files..."
rsync -av --delete "${RSYNC_EXCLUDES[@]}" "$TEMPLATE_DIR/" "$PROJECT_ROOT/" | grep -v "/$" | grep -v "^$" || true

# Update version tracking
echo "$LATEST_VERSION" > "$TRACKING_FILE"

echo ""
log_success "Sync complete!"
log_success "Updated .template-version to $LATEST_VERSION"

# Post-sync recommendations
if [[ ${#CONFLICTS[@]} -gt 0 ]]; then
    echo ""
    log_warning "Post-sync actions recommended:"
    log_warning "1. Review conflicted files for correctness"
    log_warning "2. Re-apply any custom modifications if needed"
    log_warning "3. Run tests to ensure everything works"
fi

echo ""
log_info "Next steps:"
log_info "  1. Review changes: git status"
log_info "  2. Test your project"
log_info "  3. Commit updates: git add . && git commit -m 'chore: sync template to v$LATEST_VERSION'"
