# Repository instructions

> Split out of my-vibe-scaffolding's AGENTS.md. Covers install/update mechanism, MCP/OpenCode config, and runtime capability-delivery — see ai-scheme for repo/CI skeleton conventions, ai-skill-web for agent roles/skills/SDD.


## System Environment

**CRITICAL: Read system information from `config.toml` before executing commands.**

The `[system]` section contains auto-detected operating system information:

```toml
[system]
os_type = "macOS"  # or "Linux", "Windows"
os_version = "26.3"
shell = "/bin/zsh"

[system.commands]
timeout_command = "none"  # macOS doesn't have timeout by default
sed_inplace = "sed -i ''"  # macOS requires empty string argument
has_brew = true
has_apt = false
# ... other command availability flags
```

### Command Selection Examples

**Before using commands with OS-specific differences:**

1. **timeout command** (Linux has it, macOS doesn't):
   ```bash
   # ❌ WRONG: Assume timeout exists
   timeout 5 command
   
   # ✅ CORRECT: Check config.toml first
   # If timeout_command = "none" → use alternative (sleep + kill)
   # If timeout_command = "gtimeout" → use gtimeout
   # If timeout_command = "timeout" → use timeout
   ```

2. **sed in-place editing** (macOS vs Linux syntax difference):
   ```bash
   # ❌ WRONG: Use Linux syntax on macOS
   sed -i 's/foo/bar/' file.txt  # Fails on macOS
   
   # ✅ CORRECT: Use config.toml value
   # Read sed_inplace from config.toml:
   #   macOS: sed -i ''
   #   Linux: sed -i
   ```

3. **Package managers**:
   ```bash
   # Check has_brew, has_apt, has_yum, has_choco
   # Install based on available package manager
   ```

### Updating System Information

System information is automatically detected and updated by:

```bash
./.scaffolding/scripts/detect-os.sh
```

This script is run during project initialization. Re-run it if:
- Operating system changes (e.g., WSL → native Linux)
- New development tools are installed
- AI agent encounters "command not found" errors


# AGENTS.md

This document serves as the primary instruction set for AI agents (like OpenCode) working on this project.

## Project Overview

<!-- TODO: Fill in project description, goals, and context -->

### 📋 Product Requirements Document (PRD)

**For projects with detailed requirements, maintain a PRD file:**

- **Location**: `docs/PRD.md` (recommended) or `docs/specs/PRD.md`
- **Purpose**: Define features, technical requirements, user flows for AI-assisted development
- **Template**: See [.scaffolding/docs/templates/PRD_TEMPLATE.md](./.scaffolding/docs/templates/PRD_TEMPLATE.md)
- **Guide**: See [.scaffolding/docs/PRD_GUIDE.md](./.scaffolding/docs/PRD_GUIDE.md)

**Example PRD reference**:
## Project Overview

YourProject is a [brief project description].

**📋 Product Requirements**: See [docs/PRD.md](./docs/PRD.md) for complete specification.

**Key Features** (from PRD):
- [Feature 1]
- [Feature 2]
- [Feature 3]
- [Feature 4]

**Current Phase**: Phase 1 - MVP (see PRD Section 6)

**Benefits of PRD for AI coding**:
- ✅ AI has complete context at session start
- ✅ Consistent implementation across features
- ✅ No lost context between sessions
- ✅ Explicit edge cases and error handling


<!-- TODO: Fill in project description, goals, and context -->

## Project Setup for AI Agents

**IMPORTANT: This section is for AI agents (OpenCode, Cursor, Claude). Human users see simplified instructions in README.**

### Core Design Philosophy: Unified Command

**This scaffolding's most important design principle: One command for everything.**

```bash
# Whether first-time installation or update, AI agents always use:
./.scaffolding/scripts/init-project.sh
```

**The script automatically detects context:**
- **First-time mode** (no `.template-version` file) → Initialize new project
- **Update mode** (`.template-version` exists) → Update template configuration

**When AI agents should run this command:**
- User says: "setup project", "initialize", "configure"
- User says: "update template", "upgrade", "sync template"
- Missing required files detected (VERSION, git hooks, etc.)
- User wants latest template features
- Need to consolidate scattered agent configurations

**Key benefit**: Users and AI agents don't need to remember different commands for different scenarios.

**Design rationale**: This unified interface reduces cognitive load and prevents confusion between "install" vs "update" workflows. The script's auto-detection ensures the correct behavior based on project state.

---

### Installation & Update (Project Mode)

**Single command handles both first-time setup and updates:**

```bash
./.scaffolding/scripts/init-project.sh
```

**The script auto-detects mode:**

- **First-time mode** (no `.template-version` file exists):
  - Creates project-specific files (VERSION, README, etc.)
  - Sets up Git hooks
  - Initializes OpenCode configuration
  - Creates `.template-version` for tracking

- **Update mode** (`.template-version` file exists):
  - Consolidates agent configs (`.claude`, `.roo` → `.agents`)
  - Updates template version tracking
  - Reinstalls Git hooks (may have new features)
  - Preserves all user customizations

**When to run this command:**

- User mentions "setup", "initialize", "configure" the project
- User mentions "update template", "upgrade", "sync template"
- Missing required files detected (VERSION, git hooks, etc.)
- User wants latest template features
- Need to consolidate scattered agent configurations

### Template Development (Scaffolding Mode)

When developing the template itself, modifications go to `.scaffolding/` directory:

```bash
# Template mode doesn't need init script
# You're directly modifying template files
```

**Key differences:**
- Edit `.scaffolding/docs/`, `.scaffolding/scripts/`, etc.
- Changes apply to the template, not a specific project
- Commit to template repository

---

## Working Mode

**This scaffolding has two working modes configured in `config.toml`:**

### Scaffolding Mode (`mode = "scaffolding"`)

You're developing this scaffolding itself. File organization:

- **Scaffolding ADRs**: `.scaffolding/docs/adr/`
- **Scaffolding scripts**: `.scaffolding/scripts/`
- **Scaffolding assets**: `.scaffolding/assets/`
- **Root directories**: Keep `docs/`, `scripts/`, `assets/` empty or minimal

**AI Agent behavior:**
- Create new ADRs in `.scaffolding/docs/adr/`
- Reference scaffolding scripts from `.scaffolding/scripts/`
- Reference scaffolding assets from `.scaffolding/assets/`
- **Generate bilingual README** following [README_BILINGUAL_FORMAT.md](./.scaffolding/docs/README_BILINGUAL_FORMAT.md)
- **CHANGELOG**: Update `.scaffolding/CHANGELOG.md` (template changes)
- **README sync**: If `sync_readme = true`, **all** `README*.md` files (all locales) auto-sync: root → `.scaffolding/`

### Project Mode (`mode = "project"`)

You're using this scaffolding for your project. File organization:

- **Project ADRs**: `docs/adr/`
- **Project scripts**: `scripts/`
- **Project assets**: `assets/`
- **.scaffolding/ directory**: Contains reference examples only

**AI Agent behavior:**
- Create new ADRs in `docs/adr/`
- Place project-specific scripts in `scripts/`
- Place project-specific assets in `assets/`
- Reference `.scaffolding/` examples but don't modify them
- **CHANGELOG**: Update root `CHANGELOG.md` (your project changes)
- **README**: Edit root `README.md` for your project (independent from template)

**To change mode:** Edit `config.toml` and set `[project] mode = "scaffolding"` or `"project"`

## Tech Stack

<!-- TODO: List technologies, frameworks, and tools used in this project -->

## MCP (Model Context Protocol) Usage

**Priority: Always check for MCP tools first, then fallback to CLI.**

### GitHub Operations Priority

When performing GitHub operations (issues, PRs, releases):

1. **First**: Check if GitHub MCP server tools are available
   - Tool names: `github_*` (e.g., `github_create_issue`, `github_create_pull_request`)
   - Advantages: Faster, structured responses, cross-tool compatible

2. **Fallback**: Use `gh` CLI if MCP not available
   - Via `bash` tool: `gh issue create`, `gh pr create`, etc.
   - Reliable but slower (subprocess overhead)

### How to Check MCP Availability

```typescript
// At session start, list available tools
// If you see tools starting with 'github_', 'git_', 'filesystem_' → MCP is active
// If not → Use CLI fallbacks (gh, git commands via bash)
```

### MCP Servers Configuration

- **filesystem**: File operations (read/write/search)
- **git**: Git operations (status, diff, commit, push)
- **memory**: Persistent memory across sessions
- **github**: GitHub API (issues, PRs, releases, workflows)

Configuration: `opencode.json`  
Setup guide: [.scaffolding/docs/MCP_SETUP_GUIDE.md](./.scaffolding/docs/MCP_SETUP_GUIDE.md)

## Commands

**Reference**: AGENTS.md 2026 Standard - Commands are one of 6 core blocks required for AI agent coordination.

### AI Development Commands

**Source**: [everything-claude-code](https://github.com/affaan-m/everything-claude-code)  
**Documentation**: [`.scaffolding/agents/commands/README.md`](./.scaffolding/agents/commands/README.md)

These commands provide task-specific workflows combining agents and skills:

| Command | Description | Agent | Use When |
|---------|-------------|-------|----------|
| **plan** | Create implementation plan with risk assessment | planner | Starting complex features |
| **code-review** | Review code for quality, security, maintainability | code-reviewer | Before commits, PR review |
| **build-fix** | Diagnose and fix build errors | architect | Build failures |
| **e2e** | Create end-to-end tests | tdd-guide | Testing workflows |
| **checkpoint** | Save state before major changes | — | Before refactoring |
| **test-all** | Run all tests with coverage | tdd-guide | Pre-commit, CI/CD |
| **security-scan** | Security vulnerability audit | security-reviewer | Pre-deployment |
| **analyze** | Codebase quality analysis | architect | Code health check |
| **refactor** | Systematic code refactoring | architect | Improving maintainability |
| **document** | Generate/update documentation | architect | API docs, README |

**Usage**: Commands are invoked by referencing the command file (e.g., "run plan command for user auth").

**Command Chains** (Common Workflows):
- **Feature Development**: plan → checkpoint → [implement] → test-all → code-review → security-scan → document
- **Bug Fix**: checkpoint → analyze → [fix] → test-all → code-review
- **Refactoring**: analyze → checkpoint → test-all → refactor → test-all → code-review
- **Pre-Deployment**: test-all → code-review → security-scan → document


### Development

- **Install**: (Project-specific - depends on tech stack)
  - Node.js: `npm install` or `pnpm install`
  - Python: `pip install -r requirements.txt`
  - Go: `go mod download`
  - Note: This scaffolding template itself has no development commands (it's a template, not an application)

- **Dev**: (Project-specific - depends on tech stack)
  - Node.js: `npm run dev`
  - Python: `python manage.py runserver` (Django) or `flask run`
  - Go: `go run main.go`

- **Build**: (Project-specific - depends on tech stack)
  - Node.js: `npm run build`
  - Python: (typically no build step)
  - Go: `go build`

- **Test**: (Project-specific - depends on tech stack)
  - Node.js: `npm test`
  - Python: `pytest` or `python -m unittest`
  - Go: `go test ./...`

### Template Management

These commands manage the scaffolding template itself:

- **Init project**: `./.scaffolding/scripts/init-project.sh`
  - First-time project setup or template updates
  - Auto-detects: first-time mode (no `.template-version`) vs update mode (existing `.template-version`)
  - Creates project files, sets up git hooks, initializes OpenCode config

- **Bump version**: `./.scaffolding/scripts/bump-version.sh [patch|minor|major]`
  - Update `.scaffolding/VERSION` and `VERSION` files
  - Create git commit and tag
  - Update `CHANGELOG.md` and `README.md` badges
  - Usage:
    - `./template/scripts/bump-version.sh patch` - Bug fixes (1.0.0 → 1.0.1)
    - `./.scaffolding/scripts/bump-version.sh minor` - New features (1.0.0 → 1.1.0)
    - `./.scaffolding/scripts/bump-version.sh major` - Breaking changes (1.0.0 → 2.0.0)

- **Generate README**: `./.scaffolding/scripts/generate-readme.sh`
  - Generate `README.md` and `README.{lang}.md` from `i18n/locales/{lang}/readme.toml`
  - Sync to `.scaffolding/README.md` and `.scaffolding/README.{lang}.md`
  - Add language switcher links automatically
  - **CRITICAL**: Always use this script to update README, never edit README.md directly

- **Sync README**: `./.scaffolding/scripts/sync-readme.sh`
  - Sync root README files to `.scaffolding/` directory (if `sync_readme = true` in scaffolding mode)
  - Used in scaffolding mode when developing the template itself

- **Sync template**: `./.scaffolding/scripts/sync-template.sh`
  - Sync template changes from `.scaffolding/` to project root
  - Version comparison (.template-version vs .scaffolding/VERSION)
  - Change summary display (git-style diff)
  - Selective file sync with exclude patterns (--exclude)
  - Conflict detection and resolution guidance
  - Usage:
    - `sync-template.sh` - Interactive sync
    - `sync-template.sh -n` - Dry run (preview)
    - `sync-template.sh -e "docs/*"` - Exclude specific files
    - `sync-template.sh -f` - Force sync regardless of version

### Git Hooks

- **Install hooks**: `./.scaffolding/scripts/install-hooks.sh`
  - Install pre-commit and pre-push git hooks
  - Pre-push hook: Enforce version bump before pushing to main
  - Location: `.git/hooks/`

### OpenCode Specific

These commands help manage OpenCode stability and workflow:

- **Health check**: `./.scaffolding/scripts/health-check.sh`
  - Check OpenCode database size, session count, startup time
  - Recommend cleanup if thresholds exceeded
  - Run manually or via cron job

- **Clean sessions**: `./.scaffolding/scripts/smart-cleanup.sh`
  - Smart session cleanup (keeps recent/active sessions)
  - Triggered by health check or run manually
  - Archives old sessions to `.opencode-data/archive/`

- **Monitor stability**: `./.scaffolding/scripts/monitor-stability.sh`
  - Monitor OpenCode crashes and performance
  - Generate daily stability reports
  - Track memory usage and session duration

- **Init OpenCode**: `./.scaffolding/scripts/init-opencode.sh`
  - Set up project-specific OpenCode database
  - Configure `.vscode/settings.json` for isolated data directory
  - Prevents multi-project database conflicts

- **Detect OS**: `./.scaffolding/scripts/detect-os.sh`
  - Auto-detect operating system and available commands
  - Update `config.toml` [system] section
  - Run during project initialization or when environment changes

### Utility Scripts

- **Verify setup**: `./.scaffolding/scripts/verify-setup.sh`
  - Verify project configuration integrity
  - Check required files exist
  - Validate configuration format

- **Check version sync**: `./.scaffolding/scripts/check-version-sync.sh`
  - Ensure `.scaffolding/VERSION` and `VERSION` are in sync
  - Used by pre-push git hook

### Usage Tips

**For template maintainers** (scaffolding mode):
- Use `bump-version.sh` before every commit to main
- Run `generate-readme.sh` after updating i18n translation files
- Use `sync-readme.sh` to keep `.scaffolding/` README in sync

**For template users** (project mode):
- Run `init-project.sh` once after creating project from template
- Use development commands specific to your tech stack
- Run `health-check.sh` if OpenCode becomes unstable

**For all users**:
- `install-hooks.sh` - Run once to set up automatic version enforcement
- `verify-setup.sh` - Run to check configuration integrity


## Service Detection Protocol

**CRITICAL: AI agents MUST check service availability BEFORE calling external services.**

**Reference**: [`.scaffolding/agents/service-detection.md`](./.scaffolding/agents/service-detection.md) | **ADR**: [0008](./
.scaffolding/docs/adr/0008-opencode-config-claude-code-reference.md)

### Quick Protocol

**Before calling ANY external service:**

1. ✅ **Check `config.toml`** `[services.unsupported]` list
2. ✅ **If service is unsupported** → Look up alternatives in `[services.capabilities]`
3. ✅ **Use alternative tool** and inform user of substitution
4. ✅ **Provide clear reasoning** for why alternative was chosen

### Example: Handling Unsupported google-search

**Bad (DON'T DO THIS)**:
```
User: "Search the web for React best practices"
Agent: [Attempts google-search]
Result: 403 Forbidden - Gemini for Google Cloud API has not been used...
Agent: "Sorry, I encountered an error."
```

**Good (DO THIS)**:
```
User: "Search the web for React best practices"
Agent: [Checks config.toml → google-search in unsupported list]
Agent: [Looks up alternatives → websearch_web_search_exa available]
Agent: "Using websearch_web_search_exa as alternative to google-search (provides LLM-optimized results)"
Agent: [Executes search successfully]
```

### Service Configuration Location

**File**: `config.toml` (copy from `config.toml.example`)

**Structure**:
```toml
[services]
unsupported = ["google-search", "google_search"]

[services.capabilities]
web_search = ["websearch_web_search_exa", "webfetch"]
code_search = ["grep_app_searchGitHub"]
documentation = ["context7_query-docs", "context7_resolve-library-id"]

[services.fallback]
mode = "suggest"  # "suggest" | "auto" | "fail"
log_attempts = true
show_reason = true
```

### Error Message Template

When service is unavailable:

```markdown
❌ Service '{service_name}' is not available in this configuration.

Reason: {specific_reason}

✅ Available alternatives:
  1. {alternative_1} - {description}
  2. {alternative_2} - {description}

Recommended: {best_alternative}
Using: {chosen_alternative}

[Continues execution with alternative]
```

### Service Capability Matrix

| Functionality | Unsupported Services | Available Alternatives | Recommended |
|---------------|----------------------|------------------------|-------------|
| **Web Search** | `google-search`, `google_search` | `websearch_web_search_exa`, `webfetch` | `websearch_web_search_exa` (LLM-optimized) |
| **Code Search** | — | `grep_app_searchGitHub` | `grep_app_searchGitHub` |
| **Documentation** | — | `context7_query-docs`, `context7_resolve-library-id` | `context7_query-docs` |
| **Web Fetch** | — | `webfetch` | `webfetch` (direct URL) |

**Full details**: See [`.scaffolding/agents/service-detection.md`](./.scaffolding/agents/service-detection.md)


## Module Loading Protocol

**Version**: 2.0.0  
**Purpose**: Conditional loading of documentation modules based on project type and task context

### Overview

This scaffolding uses a **config-driven module system**. Instead of loading all documentation at once:

1. AI agent reads `config.toml` to understand project type
2. AI agent detects task keywords to determine needed modules
3. AI agent loads ONLY relevant modules for the current task
4. Token usage reduced by 70%+ compared to full-inline approach

### Module Categories

**31 total modules** organized in 7 categories:

| Category | Count | Modules |
|----------|-------|---------|
| **Core** | 5 | STYLE_GUIDE, TERMINOLOGY, GIT_WORKFLOW, TESTING_STRATEGY, SECURITY_CHECKLIST |
| **Software Dev** | 6 | FRONTEND_PATTERNS, BACKEND_PATTERNS, API_DESIGN, DATABASE_CONVENTIONS, CLI_DESIGN, LIBRARY_DESIGN |
| **Academic** | 6 | ACADEMIC_WRITING, CITATION_MANAGEMENT, TRANSLATION_GUIDE, LITERATURE_REVIEW, RESEARCH_ORGANIZATION, DOCUMENT_STRUCTURE |
| **Feature** | 4 | I18N_GUIDE, AUTH_IMPLEMENTATION, REALTIME_PATTERNS, FILE_HANDLING |
| **Quality** | 4 | PERFORMANCE_OPTIMIZATION, TROUBLESHOOTING, PRODUCTION_READINESS, ACCESSIBILITY |
| **Collaboration** | 4 | README_STRUCTURE, ADR_TEMPLATE, RELEASE_PROCESS, ONBOARDING_GUIDE |
| **Scaffolding** | 2 | SCAFFOLDING_DEV_GUIDE, MODE_GUIDE |

### Configuration-Driven Loading

**config.toml structure**:

```toml
[project]
type = "fullstack"  # frontend | backend | fullstack | cli | library | academic | documentation
features = ["api", "database", "auth", "i18n"]
quality = ["performance", "accessibility"]

[academic]
citation_style = "APA"  # APA | MLA | Chicago | IEEE
field = "computer_science"

[modules]
always_enabled = ["STYLE_GUIDE", "TERMINOLOGY", "GIT_WORKFLOW"]
manual_enabled = []
manual_disabled = []
```

### Module Loading Table

**When to load each module** (AI agents follow this table):

| Module | Load When | Trigger Keywords | Location |
|--------|-----------|------------------|----------|
| **STYLE_GUIDE** | Always | (all tasks) | `.scaffolding/docs/STYLE_GUIDE.md` |
| **TERMINOLOGY** | Always | (all tasks) | `.scaffolding/docs/terminology/` |
| **GIT_WORKFLOW** | Always | git, commit, branch | `.scaffolding/docs/GIT_WORKFLOW.md` |
| **FRONTEND_PATTERNS** | `type = "frontend"` or `"fullstack"` | React, component, UI, frontend | `.scaffolding/docs/FRONTEND_PATTERNS.md` |
| **BACKEND_PATTERNS** | `type = "backend"` or `"fullstack"` | API, server, backend, Node.js | `.scaffolding/docs/BACKEND_PATTERNS.md` |
| **API_DESIGN** | `features` contains `"api"` | API, endpoint, REST, GraphQL | `.scaffolding/docs/API_DESIGN.md` |
| **DATABASE_CONVENTIONS** | `features` contains `"database"` | database, SQL, query, schema | `.scaffolding/docs/DATABASE_CONVENTIONS.md` |
| **AUTH_IMPLEMENTATION** | `features` contains `"auth"` | authentication, login, JWT, OAuth | `.scaffolding/docs/AUTH_IMPLEMENTATION.md` |
| **I18N_GUIDE** | `features` contains `"i18n"` | i18n, translation, locale, multilingual | `.scaffolding/docs/I18N_GUIDE.md` |
| **ACADEMIC_WRITING** | `type = "academic"` | paper, thesis, research, citation | `.scaffolding/docs/ACADEMIC_WRITING.md` |
| **CITATION_MANAGEMENT** | `type = "academic"` | reference, bibliography, APA, MLA | `.scaffolding/docs/CITATION_MANAGEMENT.md` |
| **PERFORMANCE_OPTIMIZATION** | `quality` contains `"performance"` | slow, optimize, performance, speed | `.scaffolding/docs/PERFORMANCE_OPTIMIZATION.md` |
| **ACCESSIBILITY** | `quality` contains `"accessibility"` | a11y, WCAG, screen reader, keyboard | `.scaffolding/docs/ACCESSIBILITY.md` |

**Full module list**: See [ADR 0012](./docs/adr/0012-module-system-and-conditional-loading.md)

### TERMINOLOGY Loading Logic

Terminology files are loaded hierarchically based on project configuration:

**1. Always Load**:
- `.scaffolding/docs/terminology/terminology.md` (universal terms)

**2. Domain-Specific** (based on `[project].type`):

```
type = "frontend" or "fullstack":
  → software/common.md
  → software/frontend.md

type = "backend" or "fullstack":
  → software/common.md
  → software/backend.md

features contains "database":
  → software/database.md

type = "academic":
  → academic/common.md
  → academic/{field}.md  (e.g., computer-science.md)
```

**3. Custom Terminology** (highest priority):
- `.agents/terminology/custom.md` (user overrides)

**Priority Order**: Custom > Domain-Specific > Common > Universal

### Conditional Loading Examples

**Example 1: Fullstack Project with Auth**

```toml
[project]
type = "fullstack"
features = ["api", "database", "auth"]
```

**AI Agent loads**:
- Always: STYLE_GUIDE, TERMINOLOGY, GIT_WORKFLOW
- Type-based: FRONTEND_PATTERNS, BACKEND_PATTERNS
- Feature-based: API_DESIGN, DATABASE_CONVENTIONS, AUTH_IMPLEMENTATION
- Terminology: terminology.md, software/common.md, software/frontend.md, software/backend.md, software/database.md

**Example 2: Academic Research Project**

```toml
[project]
type = "academic"

[academic]
citation_style = "APA"
field = "computer_science"
```

**AI Agent loads**:
- Always: STYLE_GUIDE, TERMINOLOGY, GIT_WORKFLOW
- Type-based: ACADEMIC_WRITING, CITATION_MANAGEMENT
- Terminology: terminology.md, academic/common.md, academic/computer-science.md

### Manual Module Control

Override automatic loading in `config.toml`:

```toml
[modules]
# These modules ALWAYS load regardless of project type
always_enabled = ["STYLE_GUIDE", "TERMINOLOGY", "GIT_WORKFLOW", "SECURITY_CHECKLIST"]

# Force-load additional modules
manual_enabled = ["PERFORMANCE_OPTIMIZATION", "ACCESSIBILITY"]

# Disable modules even if project type suggests them
manual_disabled = ["FRONTEND_PATTERNS"]
```

**Priority**: `manual_disabled` > `manual_enabled` > auto-detection > `always_enabled`

### AI Agent Protocol

**On session start**:

1. Read `config.toml` → identify project type, features, quality requirements
2. Check for manual module overrides (`manual_enabled`, `manual_disabled`)
3. Load `always_enabled` modules
4. Load type-based modules (e.g., FRONTEND_PATTERNS if type=frontend)
5. Load feature-based modules (e.g., API_DESIGN if features contains "api")
6. Load quality-based modules (e.g., ACCESSIBILITY if quality contains "accessibility")
7. Load terminology files hierarchically

**During task execution**:

1. Detect task keywords (e.g., "API", "authentication", "performance")
2. If module not yet loaded → load on-demand
3. Reference loaded modules when providing guidance

**When in doubt**: Load the module. Token cost is minimal compared to incorrect guidance.

### Module File Locations

**Current Status** (v2.0.0):

| Status | Modules | Note |
|--------|---------|------|
| ✅ **Exists** | TERMINOLOGY (7 files) | Fully implemented terminology system |
| ⏸️ **Planned** | 30 other modules | Will be created in future versions |

**Terminology System** (Complete):
```
.scaffolding/docs/terminology/
├── README.md
├── terminology.md                    # Universal terms (Git, naming, etc.)
├── software/
│   ├── common.md                     # SDLC, patterns, testing
│   ├── frontend.md                   # React, CSS, performance
│   ├── backend.md                    # Node.js, API, security
│   └── database.md                   # SQL, ORM, optimization
├── academic/
│   ├── common.md                     # Research, writing, ethics
│   └── computer-science.md           # AI/ML, algorithms, HCI
└── project/
    └── custom.md.example             # User overrides
```

**Module files will be created at** (Future):
```
.scaffolding/docs/
├── STYLE_GUIDE.md
├── GIT_WORKFLOW.md
├── FRONTEND_PATTERNS.md
├── BACKEND_PATTERNS.md
├── API_DESIGN.md
├── DATABASE_CONVENTIONS.md
├── AUTH_IMPLEMENTATION.md
├── I18N_GUIDE.md
├── ACADEMIC_WRITING.md
├── CITATION_MANAGEMENT.md
├── PERFORMANCE_OPTIMIZATION.md
├── ACCESSIBILITY.md
└── ... (18 more modules)
```

### Version & Maintenance

- **Module system version**: 2.0.0
- **Terminology system version**: 2.0.0 (Complete)
- **Future module files**: Will align with scaffolding versions
- **Updates**: Documented in `.scaffolding/CHANGELOG.md`

### Related Documentation

- **[ADR 0012 - Module System & Conditional Loading](./docs/adr/0012-module-system-and-conditional-loading.md)** - Complete design decisions
- **[config.toml.example](./config.toml.example)** - Configuration reference
- **[Terminology README](./.scaffolding/docs/terminology/README.md)** - Terminology system guide


## AI Agent Communication Protocol

**CRITICAL: AI agents MUST follow this protocol at the start of EVERY session.**

### 1. Read User's Language Preference

On session start, ALWAYS read the user's language configuration:

```bash
# Read config.toml
[i18n]
primary_locale = "zh-TW"  # User's preferred language
fallback_locale = "en-US"
```

**If config.toml doesn't exist:** Use `en-US` as default.

### 2. Load Translation Files

Load translations from `.scaffolding/i18n/locales/{primary_locale}/`:

- `agents.toml` - Coding conventions, commit format, PR guidelines
- `readme.toml` - Project documentation phrases
- `templates.toml` - Issue/PR template text
- `adr.toml` - ADR template phrases

**Example (zh-TW):**
```bash
# Load coding conventions
.scaffolding/i18n/locales/zh-TW/agents.toml

[coding_conventions]
title = "編碼規範"
test_first = "**永遠先寫測試**：所有新功能和 bug 修復都必須先寫測試"
```

### 3. Communication Language Rules

**Use the user's configured language for ALL responses and communication:**

| Configuration | Communication Language | Example |
|---------------|------------------------|---------|
| `primary_locale = "zh-TW"` | 繁體中文（台灣） | "我已經完成了這個功能..." |
| `primary_locale = "en-US"` | English (US) | "I've completed this feature..." |
| `primary_locale = "ja-JP"` | 日本語 | "この機能を完了しました..." |

**Code and Technical Terms:**
- Variable names, function names → Always English
- Code comments → Use primary_locale language
- Commit messages → Follow locale-specific format in `agents.toml`
- Technical documentation → Use primary_locale language

**Documentation Language Guidelines:**

| File/Directory | Language | Reason |
|----------------|----------|--------|
| Root `README.md` | 🌐 Multi-language (i18n) | User-facing, needs language support |
| `.scaffolding/*` files | 🇬🇧 English only | AI-facing, English is most direct |
| `AGENTS.md` | 🌐 Multi-language | AI reads, but users also reference |
| `docs/adr/*.md` | 🇬🇧 English only | Technical decisions, for AI and developers |
| `scripts/*` | 🇬🇧 English only | Tool documentation |

**Why English for `.scaffolding/` files:**
1. AI models are primarily trained on English
2. International accessibility for technical content
3. Reduces translation maintenance cost

**Exceptions:**
- Project root `CHANGELOG.md` → Use project's primary language
- Project `docs/` files → Project decides

### 4. Fallback Strategy

If a translation key is missing:

1. Check `fallback_locale` in config.toml (usually `en-US`)
2. Load the key from fallback locale
3. Continue without error
4. Optionally note the missing translation

### 5. Session Start Checklist

**Before responding to ANY user message:**

- [ ] Read `config.toml` and identify `primary_locale`
- [ ] Load translation files from `.scaffolding/i18n/locales/{primary_locale}/`
- [ ] Set communication language to match `primary_locale`
- [ ] Verify fallback locale is available

### 6. README Generation Protocol

**CRITICAL: README files are auto-generated from i18n translations. DO NOT edit README.md directly.**

### Workflow

1. **Edit translation files:**
   ```bash
   .scaffolding/i18n/locales/en-US/readme.toml
   .scaffolding/i18n/locales/zh-TW/readme.toml
   ```

2. **Generate README files:**
   ```bash
   ./.scaffolding/scripts/generate-readme.sh
   ```

   This script:
   - Reads content from `i18n/locales/{lang}/readme.toml`
   - Generates `README.md` (English) and `README.zh-TW.md` (中文)
   - Syncs to `.scaffolding/README.md` and `.scaffolding/README.zh-TW.md`
   - Adds language switcher links automatically
   - **NO markdown code fences** around content (README is already markdown)

3. **MANDATORY Verification (ALWAYS do this before committing):**
   ```bash
   # Verify all 4 files exist and are in sync
   diff README.md .scaffolding/README.md
   diff README.zh-TW.md .scaffolding/README.zh-TW.md
   ```
   
   **Success criteria:**
   - ✅ Both diffs show no differences (files are identical)
   - ✅ Both language versions updated (en-US and zh-TW)
   - ✅ Language switcher links present in both files
   - ✅ No ```markdown code fences wrapping content
   
   **If verification fails:**
   - Re-run generate-readme.sh
   - Do NOT commit until all checks pass
   - Reads content from `i18n/locales/{lang}/readme.toml`
   - Generates `README.md` (English) and `README.zh-TW.md` (中文)
   - Syncs to `.scaffolding/README.md` and `.scaffolding/README.zh-TW.md`
   - Adds language switcher links automatically
   - **NO markdown code fences** around content (README is already markdown)

   ### Current Configuration

This template uses **`separate` strategy**:
- `README.md` - English (auto-generated from `en-US/readme.toml`)
- `README.zh-TW.md` - 繁體中文 (auto-generated from `zh-TW/readme.toml`)

### Important Rules

1. **NEVER edit README.md or README.zh-TW.md directly** - Changes will be overwritten
2. **Edit i18n TOML files** - All content comes from `i18n/locales/{lang}/readme.toml`
3. **Run generate-readme.sh** - After editing TOML files, regenerate READMEs
4. **NO ```markdown``` code fences** - README is markdown, content doesn't need wrapping

3. **Verify language switcher (for separate strategy):**
   - Top of README.md: Links to all language versions
   - Format: `English | [繁體中文](./README.zh-TW.md) | [日本語](./README.ja-JP.md)`
   - Current language shows as plain text (no link to itself)

4. **Validation:**
   - Separate: Each README file exists and is single-language
   - Bilingual: Single README.md follows bilingual formatting rules
   - Primary only: Only README.md exists

**Reference:** [`.scaffolding/docs/README_BILINGUAL_FORMAT.md`](./.scaffolding/docs/README_BILINGUAL_FORMAT.md)

**This is MANDATORY. No exceptions.**


