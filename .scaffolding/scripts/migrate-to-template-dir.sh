#!/usr/bin/env bash
# Migration script: Old structure → New .scaffolding/ structure
# Purpose: Help users of pre-v1.9.0 template migrate to new directory structure
#
# This script safely moves template infrastructure to .scaffolding/ directory
# while preserving user customizations and project-specific files.
#
# Author: Template Maintenance Team
# Date: 2026-03-03
# Related: ADR 0006 - Template Directory Isolation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✅${NC} $1"; }
warning() { echo -e "${YELLOW}⚠️${NC} $1"; }
error() { echo -e "${RED}❌${NC} $1"; }

echo ""
echo "🔄 Template Directory Migration Script"
echo "======================================"
echo ""
info "This script migrates your project from pre-v1.9.0 structure to new .scaffolding/ structure"
echo ""

# ============================================================================
# Step 1: Pre-flight checks
# ============================================================================

echo "🔍 Running pre-flight checks..."
echo ""

# Check if we're in project root
if [ ! -d ".git" ]; then
    error "Not a git repository. Please run this script from project root."
    exit 1
fi
success "Git repository detected"

# Check if .scaffolding/ already exists
if [ -d ".template" ]; then
    warning ".scaffolding/ directory already exists"
    info "Checking if migration is needed..."
    
    # Check if old structure still exists
    OLD_STRUCTURE_EXISTS=false
    
    if [ -d "i18n" ] && [ ! -L "i18n" ]; then
        OLD_STRUCTURE_EXISTS=true
        info "Found: i18n/ in root (should be in .scaffolding/)"
    fi
    
    if [ -d "languages" ] && [ ! -L "languages" ]; then
        OLD_STRUCTURE_EXISTS=true
        info "Found: languages/ in root (should be in .scaffolding/)"
    fi
    
    if [ "$OLD_STRUCTURE_EXISTS" = false ]; then
        success "Your project is already using new structure!"
        echo ""
        info "No migration needed. Exiting."
        exit 0
    fi
else
    info "Creating .scaffolding/ directory..."
    mkdir -p .scaffolding/{docs,scripts,i18n,languages}
    success ".scaffolding/ structure created"
fi

echo ""

# Check git status
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    warning "You have uncommitted changes"
    echo ""
    info "It's recommended to commit or stash changes before migration."
    read -p "Continue anyway? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        info "Migration cancelled. Please commit your changes first."
        exit 0
    fi
fi

echo ""

# ============================================================================
# Step 2: Backup current state
# ============================================================================

echo "💾 Creating backup..."
echo ""

BACKUP_DIR=".migration-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup directories that will be moved
if [ -d "i18n" ]; then
    cp -r i18n "$BACKUP_DIR/"
    success "Backed up: i18n/ → $BACKUP_DIR/i18n/"
fi

if [ -d "languages" ]; then
    cp -r languages "$BACKUP_DIR/"
    success "Backed up: languages/ → $BACKUP_DIR/languages/"
fi

if [ -f "AGENTS.md" ]; then
    cp AGENTS.md "$BACKUP_DIR/"
    success "Backed up: AGENTS.md → $BACKUP_DIR/AGENTS.md"
fi

if [ -f "README.md" ]; then
    cp README.md "$BACKUP_DIR/"
    success "Backed up: README.md → $BACKUP_DIR/README.md"
fi

echo ""
info "Backup created at: $BACKUP_DIR"
info "You can restore from this backup if anything goes wrong."
echo ""

# ============================================================================
# Step 3: Detect project mode
# ============================================================================

echo "🔍 Detecting project mode..."
echo ""

PROJECT_MODE="unknown"

# Deliberately reads [project].mode, a key since removed from
# config.toml.example. This script migrates projects created before that
# removal, so the config files it inspects still carry the old key; reading it
# here is how the migration identifies what it is migrating, not a live
# dependency on a key this repo still defines.
if [ -f "config.toml" ]; then
    if grep -q 'mode = "scaffolding"' config.toml; then
        PROJECT_MODE="scaffolding"
        info "Detected: Scaffolding mode (template development)"
    elif grep -q 'mode = "project"' config.toml; then
        PROJECT_MODE="project"
        info "Detected: Project mode (using template)"
    fi
else
    warning "config.toml not found"
    info "Assuming: Project mode"
    PROJECT_MODE="project"
fi

echo ""

# ============================================================================
# Step 4: Move files to .scaffolding/
# ============================================================================

echo "📦 Migrating files to .scaffolding/..."
echo ""

# Move i18n/ if exists in root
if [ -d "i18n" ] && [ ! -L "i18n" ]; then
    info "Moving i18n/ to .scaffolding/i18n/..."
    
    if [ -d ".scaffolding/i18n" ]; then
        warning ".scaffolding/i18n/ already exists, merging..."
        rsync -a i18n/ .scaffolding/i18n/
        rm -rf i18n
    else
        mv i18n .scaffolding/
    fi
    
    success "Moved: i18n/ → .scaffolding/i18n/"
fi

# Move languages/ if exists in root
if [ -d "languages" ] && [ ! -L "languages" ]; then
    info "Moving languages/ to .scaffolding/languages/..."
    
    if [ -d ".scaffolding/languages" ]; then
        warning ".scaffolding/languages/ already exists, merging..."
        rsync -a languages/ .scaffolding/languages/
        rm -rf languages
    else
        mv languages .scaffolding/
    fi
    
    success "Moved: languages/ → .scaffolding/languages/"
fi

echo ""

# ============================================================================
# Step 5: Update file references
# ============================================================================

echo "🔧 Updating file references..."
echo ""

# Update AGENTS.md references
if [ -f "AGENTS.md" ]; then
    info "Updating AGENTS.md references..."
    
    # Backup before modification
    cp AGENTS.md AGENTS.md.bak
    
    # Update paths
    sed -i.tmp 's|docs/DOCUMENTATION_GUIDELINES.md|.scaffolding/docs/DOCUMENTATION_GUIDELINES.md|g' AGENTS.md
    sed -i.tmp 's|docs/README_GUIDE.md|.scaffolding/docs/README_GUIDE.md|g' AGENTS.md
    sed -i.tmp 's|docs/TEMPLATE_SYNC.md|.scaffolding/docs/TEMPLATE_SYNC.md|g' AGENTS.md
    sed -i.tmp 's|scripts/init-project.sh|.scaffolding/scripts/init-project.sh|g' AGENTS.md
    sed -i.tmp 's|i18n/locales/|.scaffolding/i18n/locales/|g' AGENTS.md
    
    # Remove backup files
    rm -f AGENTS.md.tmp AGENTS.md.bak
    
    success "Updated AGENTS.md references"
fi

# Update README.md references
if [ -f "README.md" ]; then
    info "Updating README.md references..."
    
    # Backup before modification
    cp README.md README.md.bak
    
    # Update paths
    sed -i.tmp 's|scripts/init-project.sh|.scaffolding/scripts/init-project.sh|g' README.md
    sed -i.tmp 's|\[CHANGELOG.md\](./CHANGELOG.md)|[CHANGELOG.md](./.scaffolding/CHANGELOG.md)|g' README.md
    sed -i.tmp 's|\[Template Changelog\](CHANGELOG.md)|[Template Changelog](.scaffolding/CHANGELOG.md)|g' README.md
    
    # Remove backup files
    rm -f README.md.tmp README.md.bak
    
    success "Updated README.md references"
fi

echo ""

# ============================================================================
# Step 6: Create .template-version marker
# ============================================================================

echo "📝 Creating version tracking..."
echo ""

if [ -f ".scaffolding/VERSION" ]; then
    TEMPLATE_VERSION=$(cat .scaffolding/VERSION)
    echo "$TEMPLATE_VERSION" > .template-version
    success "Created .template-version: $TEMPLATE_VERSION"
else
    warning ".scaffolding/VERSION not found, using 1.9.0 as default"
    echo "1.9.0" > .template-version
fi

echo ""

# ============================================================================
# Step 7: Update .gitignore
# ============================================================================

echo "📝 Updating .gitignore..."
echo ""

if [ -f ".gitignore" ]; then
    # Check if migration backup is already ignored
    if ! grep -q "^.migration-backup-" .gitignore; then
        echo "" >> .gitignore
        echo "# Migration backups" >> .gitignore
        echo ".migration-backup-*/" >> .gitignore
        success "Added migration backup to .gitignore"
    fi
    
    # Ensure .template-version is not ignored (it should be committed)
    if grep -q "^.template-version" .gitignore; then
        warning ".template-version should be committed (tracking template version)"
        info "Consider removing '.template-version' from .gitignore"
    fi
else
    warning ".gitignore not found"
fi

echo ""

# ============================================================================
# Step 8: Verification
# ============================================================================

echo "✅ Verification..."
echo ""

VERIFICATION_PASSED=true

# Check .scaffolding/ structure
if [ ! -d ".template" ]; then
    error "Migration failed: .scaffolding/ directory not found"
    VERIFICATION_PASSED=false
fi

# Check i18n moved
if [ -d "i18n" ] && [ ! -L "i18n" ]; then
    error "Migration incomplete: i18n/ still exists in root"
    VERIFICATION_PASSED=false
fi

# Check languages moved
if [ -d "languages" ] && [ ! -L "languages" ]; then
    error "Migration incomplete: languages/ still exists in root"
    VERIFICATION_PASSED=false
fi

# Check .scaffolding/i18n exists
if [ ! -d ".scaffolding/i18n" ]; then
    warning ".scaffolding/i18n/ not found (might not be needed for your project)"
fi

# Check .scaffolding/languages exists
if [ ! -d ".scaffolding/languages" ]; then
    warning ".scaffolding/languages/ not found (might not be needed for your project)"
fi

if [ "$VERIFICATION_PASSED" = true ]; then
    success "All verification checks passed!"
else
    error "Some verification checks failed. Please review the output above."
    echo ""
    info "You can restore from backup: $BACKUP_DIR"
    exit 1
fi

echo ""

# ============================================================================
# Step 9: Summary & Next Steps
# ============================================================================

echo "🎉 Migration complete!"
echo "===================="
echo ""
success "Your project has been migrated to the new .scaffolding/ structure"
echo ""

echo "📊 Summary of changes:"
echo "  • i18n/ → .scaffolding/i18n/"
echo "  • languages/ → .scaffolding/languages/"
echo "  • Updated file references in AGENTS.md and README.md"
echo "  • Created .template-version marker"
echo "  • Backup saved to: $BACKUP_DIR"
echo ""

echo "🔍 Next steps:"
echo ""
echo "1. Review the changes:"
echo "   git status"
echo ""
echo "2. Test your project still works:"
echo "   • Check AGENTS.md loads correctly"
echo "   • Verify AI assistant can read configuration"
echo "   • Test any scripts that reference moved files"
echo ""
echo "3. Commit the migration:"
echo "   git add -A"
echo "   git commit -m \"chore: migrate to .scaffolding/ directory structure (ADR 0006)\""
echo ""
echo "4. (Optional) Remove backup after confirming everything works:"
echo "   rm -rf $BACKUP_DIR"
echo ""

info "If anything went wrong, restore from backup:"
echo "   cp -r $BACKUP_DIR/* ."
echo ""

warning "Important: Test thoroughly before pushing to remote!"
echo ""

success "Migration script completed successfully"
echo ""

exit 0
