#!/usr/bin/env bash
# test-template.sh - Validate template integrity and functionality
# Tests: template generation, i18n completeness, script execution, service detection

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_DIR="/tmp/vibe-scaffolding-test-$$"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

log_info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

log_success() {
    echo -e "${GREEN}✓${NC} $*"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

log_error() {
    echo -e "${RED}✗${NC} $*"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_TESTS+=("$*")
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $*"
}

test_section() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $*${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo ""
}

# Cleanup on exit
cleanup() {
    if [[ -d "$TEST_DIR" ]]; then
        log_info "Cleaning up test directory..."
        rm -rf "$TEST_DIR"
    fi
}

trap cleanup EXIT

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}         Template Validation Tests${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# ============================================================================
# Test 1: Template Structure
# ============================================================================
test_section "Test 1: Template Structure"

log_info "Checking required files..."

REQUIRED_FILES=(
    ".scaffolding/VERSION"
    ".scaffolding/CHANGELOG.md"
    ".scaffolding/scripts/init-project.sh"
    ".scaffolding/scripts/sync-template.sh"
    "config.toml.example"
    "AGENTS.md"
    "LICENSE"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$PROJECT_ROOT/$file" ]]; then
        log_success "Found: $file"
    else
        log_error "Missing: $file"
    fi
done

REQUIRED_DIRS=(
    ".scaffolding/docs"
    ".scaffolding/docs/adr"
    ".scaffolding/scripts"
    ".scaffolding/assets"
    ".agents"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [[ -d "$PROJECT_ROOT/$dir" ]]; then
        log_success "Found: $dir/"
    else
        log_error "Missing: $dir/"
    fi
done

# ============================================================================
# Test 2: Script Executability
# ============================================================================
test_section "Test 2: Script Executability"

log_info "Checking script permissions..."

SCRIPTS=(
    ".scaffolding/scripts/init-project.sh"
    ".scaffolding/scripts/sync-template.sh"
    ".scaffolding/scripts/health-check.sh"
    ".scaffolding/scripts/smart-cleanup.sh"
)

for script in "${SCRIPTS[@]}"; do
    script_path="$PROJECT_ROOT/$script"
    if [[ -x "$script_path" ]]; then
        log_success "Executable: $script"
    else
        log_error "Not executable: $script"
    fi
done

# ============================================================================
# Test 3: Script Help Output
# ============================================================================
test_section "Test 3: Script Help Output"

log_info "Testing script help functions..."

SCRIPTS_WITH_HELP=(
    ".scaffolding/scripts/sync-template.sh"
)

for script in "${SCRIPTS_WITH_HELP[@]}"; do
    script_path="$PROJECT_ROOT/$script"
    if "$script_path" --help > /dev/null 2>&1; then
        log_success "Help works: $script"
    else
        log_error "Help failed: $script"
    fi
done

# ============================================================================
# Test 4: Config File Validation
# ============================================================================
test_section "Test 4: Config File Validation"

log_info "Validating config.toml.example..."

if [[ -f "$PROJECT_ROOT/config.toml.example" ]]; then
    # Check for required sections
    REQUIRED_SECTIONS=(
        "[project]"
        "[services]"
        "[services.alternatives]"
    )
    
    for section in "${REQUIRED_SECTIONS[@]}"; do
        if grep -q "^$section" "$PROJECT_ROOT/config.toml.example"; then
            log_success "Found section: $section"
        else
            log_error "Missing section: $section"
        fi
    done
    
    # Check for service detection configuration
    if grep -q "unsupported = " "$PROJECT_ROOT/config.toml.example"; then
        log_success "Service detection: unsupported list configured"
    else
        log_error "Service detection: unsupported list missing"
    fi
else
    log_error "config.toml.example not found"
fi

# ============================================================================
# Test 5: AGENTS.md Completeness
# ============================================================================
test_section "Test 5: AGENTS.md Completeness (2026 Standard)"

log_info "Checking AGENTS.md required sections..."

REQUIRED_SECTIONS=(
    "## Commands"
    "## Service Detection Protocol"
    "## Tech Stack"
    "## Commit Message"
    "## File Structure"
    "## Coding Conventions"
)

if [[ -f "$PROJECT_ROOT/AGENTS.md" ]]; then
    for section in "${REQUIRED_SECTIONS[@]}"; do
        if grep -q "^$section" "$PROJECT_ROOT/AGENTS.md"; then
            log_success "Found section: $section"
        else
            log_error "Missing section: $section"
        fi
    done
    
    # Check for specific content
    if grep -q "sync-template.sh" "$PROJECT_ROOT/AGENTS.md"; then
        log_success "sync-template.sh documented in Commands"
    else
        log_error "sync-template.sh not documented"
    fi
    
    if grep -q "service-detection" "$PROJECT_ROOT/AGENTS.md"; then
        log_success "Service detection protocol documented"
    else
        log_error "Service detection protocol missing"
    fi
else
    log_error "AGENTS.md not found"
fi

# ============================================================================
# Test 6: Service Detection Files
# ============================================================================
test_section "Test 6: Service Detection Implementation"

log_info "Checking service detection files..."

SERVICE_DETECTION_FILES=(
    ".agents/service-detection.md"
    ".scaffolding/docs/service-detection-protocol.md"
)

for file in "${SERVICE_DETECTION_FILES[@]}"; do
    if [[ -f "$PROJECT_ROOT/$file" ]]; then
        log_success "Found: $file"
        
        # Check content
        if grep -q "google-search" "$PROJECT_ROOT/$file"; then
            log_success "  → Contains example service (google-search)"
        else
            log_warning "  → Missing example service reference"
        fi
    else
        log_error "Missing: $file"
    fi
done

# ============================================================================
# Test 7: ADR Documentation
# ============================================================================
test_section "Test 7: ADR Documentation"

log_info "Checking Architecture Decision Records..."

ADR_DIR="$PROJECT_ROOT/docs/adr"
if [[ -d "$ADR_DIR" ]]; then
    ADR_COUNT=$(find "$ADR_DIR" -name "*.md" | wc -l)
    log_success "Found ADR directory with $ADR_COUNT records"
    
    # Check for ADR 0009 (Claude Code reference)
    if [[ -f "$ADR_DIR/0009-reference-claude-code-architecture.md" ]]; then
        log_success "Found ADR 0009: Claude Code architecture reference"
    else
        log_warning "ADR 0009 not found (expected from recent updates)"
    fi
else
    log_error "ADR directory not found"
fi

# ============================================================================
# Test 8: README badges match the template version
# ============================================================================
test_section "Test 8: README Version Badges"

log_info "Checking README version badges..."

# The README generator was removed (ADR 0018): the READMEs are maintained by
# hand, so what has to be tested is no longer "does generation work" but
# "did the person remember". ci.yml enforces the same rule.
TEMPLATE_VERSION=$(cat "$PROJECT_ROOT/.scaffolding/VERSION")
for readme in README.md README.zh-TW.md; do
    if [[ ! -f "$PROJECT_ROOT/$readme" ]]; then
        log_error "$readme missing"
        continue
    fi
    badge=$(grep -o 'badge/version-[^-]*-blue' "$PROJECT_ROOT/$readme" | head -1 | sed 's|badge/version-||; s|-blue||')
    if [[ -z "$badge" ]]; then
        log_error "$readme has no version badge"
    elif [[ "$badge" == "$TEMPLATE_VERSION" ]]; then
        log_success "$readme badge matches: $badge"
    else
        log_error "$readme badge is $badge, expected $TEMPLATE_VERSION"
    fi
done

# ============================================================================
# Test 9: Template Generation (Simulated)
# ============================================================================
test_section "Test 9: Template Generation Simulation"

log_info "Creating test project from template..."

mkdir -p "$TEST_DIR"

# Copy template structure
if rsync -a --exclude=".git" --exclude=".opencode-data" --exclude="node_modules" \
    "$PROJECT_ROOT/.scaffolding/" "$TEST_DIR/" > /dev/null 2>&1; then
    log_success "Template copied to test directory"
    
    # Check if essential files are present
    if [[ -f "$TEST_DIR/scripts/init-project.sh" ]]; then
        log_success "  → Essential scripts present"
    else
        log_error "  → Scripts missing in generated project"
    fi
    
    if [[ -f "$TEST_DIR/VERSION" ]]; then
        log_success "  → VERSION file present"
    else
        log_error "  → VERSION file missing"
    fi
else
    log_error "Failed to copy template"
fi

# ============================================================================
# Test Results Summary
# ============================================================================
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}         Test Results${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))
echo -e "${BLUE}Total tests:${NC} $TOTAL_TESTS"
echo -e "${GREEN}Passed:${NC} $TESTS_PASSED"
echo -e "${RED}Failed:${NC} $TESTS_FAILED"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo -e "${GREEN}✓ Template is valid and ready for use.${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed.${NC}"
    echo ""
    echo -e "${YELLOW}Failed tests:${NC}"
    for test in "${FAILED_TESTS[@]}"; do
        echo -e "  ${RED}•${NC} $test"
    done
    echo ""
    echo -e "${YELLOW}Fix these issues before using the template.${NC}"
    exit 1
fi
