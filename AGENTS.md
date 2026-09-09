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
- **Template**: See `.scaffolding/docs/templates/PRD_TEMPLATE.md`
- **Guide**: See `.scaffolding/docs/PRD_GUIDE.md`

**Example PRD reference**:
## Project Overview

YourProject is a [brief project description].

**📋 Product Requirements**: See `docs/PRD.md` for complete specification.

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

A project keeps up with **two** things, and one command answers for each. Run them in this order:

```bash
ai-scheme status --json                    # 1. skeleton layer: ask, do not guess
./.scaffolding/scripts/init-project.sh     # 2. mechanism layer: this repo
```

| Axis | Covers | Version lives in | Who answers |
| --- | --- | --- | --- |
| Skeleton | CI, policies, conventions, release flow | `.scheme/config.yml` | `ai-scheme status` |
| Mechanism | agent tooling and its delivery directory | `.template-version` | `init-project.sh` |

**Step 1 — never infer the skeleton layer's state.** Not from `.template-version`, not from a `VERSION` file, not from what is on disk. Run `ai-scheme status --json`, read `state` and `next_command`, and run `next_command` — every lifecycle command produces a plan first, and the plan is for a person to see before anything is applied.

Three results that are not "no work to do":

- **Exit `2`** — it could not answer. Read `reason` and fix the cause. This is not an invitation to guess.
- **`drift` or `policy_drift` is `"unknown"`** — the check could not run. Reading it as `[]` claims something nobody verified.
- **`ai-scheme` not installed** — the skeleton state is simply unknown here. Say so; do not substitute a guess from the filesystem.

`ai-scheme status` exits `0` for **any** state it could determine, including one needing work. "An update is available" is `0` with `state: update`, not a non-zero exit.

`init-project.sh` prints this report itself before doing its own work, via `.scaffolding/scripts/scheme-status.sh`. It never runs `next_command` for you.

**Step 2 — the mechanism layer reads its own version file.** That is not a contradiction of step 1: the rule against inferring state binds the skeleton layer only, and `ai-scheme` has no idea what this layer's target version is, so it does not answer for it. See ADR 0020 and `ai-scheme`'s `docs/status-interface-contract.md`.

`init-project.sh` detects its own context:
- **First-time mode** (no `.template-version`) → initialize
- **Update mode** (`.template-version` exists) → update

**When AI agents should run this:**
- User says: "setup project", "initialize", "configure"
- User says: "update template", "upgrade", "sync template"
- Missing required files detected
- User wants latest template features
- Need to consolidate scattered agent configurations

`current` with `next_command: null` from step 1 means the *skeleton* layer has nothing to do. It says nothing about step 2.

The same two-layer split applies to configuration: `config.toml` is this layer's, `.scheme/config.yml` is the skeleton layer's, neither reads the other, and same-named keys are independent with no fallback. See [CONFIG_LAYERS.md](./.scaffolding/docs/CONFIG_LAYERS.md) for which file to edit, and ADR 0015.

---

### Writing to a pull request

**Never call `gh pr ready`, `gh pr edit`, or `gh pr merge` directly. Never `PATCH` `/pulls/` or send a GraphQL mutation.**

Worktrees isolate files; they do not isolate ready/draft, labels, milestone or merge. Those live on GitHub and every session on the same pull request shares them. Two sessions writing at once race, and **the loser's change disappears with no error** — which is why this is a rule rather than a preference.

```bash
./.scaffolding/scripts/pr-lifecycle.sh ready     --pr <n>
./.scaffolding/scripts/pr-lifecycle.sh draft     --pr <n>
./.scaffolding/scripts/pr-lifecycle.sh label     --pr <n> --add <label> [--remove <label>]
./.scaffolding/scripts/pr-lifecycle.sh milestone --pr <n> --set <milestone>
./.scaffolding/scripts/pr-lifecycle.sh merge     --pr <n> [--method squash|merge|rebase]
```

Reads need no lease: `gh pr view`, `list`, `checks`, `diff`, and `gh pr comment` (comments accumulate, they do not overwrite).

Three results are **not** "done":

- **exit `1`** — a definite no: leased elsewhere, the head moved, or merge conditions are not met. Nothing was written.
- **exit `2`** — could not determine: `gh` failed, or the lease carrier is missing. Not retried; a question that failed does not become a "no" by asking again.
- **`--on-conflict` has no silent-skip value.** `report`, `wait` and `abort` all end non-zero without writing.

`merge` re-reads review, checks and merge state *inside* the lease and stops for a human whenever any of them cannot be shown to hold — including the empty cases: no review decision, no checks reported at all, or a `mergeStateStatus` of `UNKNOWN`. **An unknown is not a yes.**

Full protocol in [PR_LEASE_PROTOCOL.md](./.scaffolding/docs/PR_LEASE_PROTOCOL.md), rationale in ADR 0021.

---

### Installation & Update

**One command handles both first-time setup and updates for this layer:**

```bash
./.scaffolding/scripts/init-project.sh
```

It reports the skeleton layer's state first (see above), then does its own work.

**The script auto-detects mode:**

- **First-time mode** (no `.template-version` file exists):
  - Creates project-specific files (VERSION, README, etc.)
  - Initializes OpenCode configuration
  - Creates `.template-version` for tracking

- **Update mode** (`.template-version` file exists):
  - Consolidates agent configs (`.claude`, `.roo` → `.agents`)
  - Updates template version tracking
  - Preserves all user customizations

**When to run this command:**

- User mentions "setup", "initialize", "configure" the project
- User mentions "update template", "upgrade", "sync template"
- Missing required files detected
- User wants latest template features
- Need to consolidate scattered agent configurations

### Template Development

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
- **Generate bilingual README** following `.scaffolding/docs/README_BILINGUAL_FORMAT.md`
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
**Documentation**: [`.scaffolding/agents/commands/README.md`](https://github.com/matheme-justyn/ai-skill-web/tree/main/agents/commands)

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
  - Reports the skeleton layer state, then creates project files and initializes OpenCode config

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

### Usage Tips

**For template maintainers:**
- The template version lives in `.scaffolding/VERSION` and nowhere else (ADR 0016). Edit it directly; there is no bump script and no pre-push version gate.
- Edit `README.md` and `README.zh-TW.md` directly; keep their version badges equal to `.scaffolding/VERSION`

**For template users:**
- Run `init-project.sh` once after creating project from template
- Use development commands specific to your tech stack
- Run `health-check.sh` if OpenCode becomes unstable

**For all users**:
- `verify-setup.sh` - Run to check configuration integrity


## Service Detection Protocol

**CRITICAL: AI agents MUST check service availability BEFORE calling external services.**

**Reference**: [`.scaffolding/agents/service-detection.md`](https://github.com/matheme-justyn/ai-skill-web/blob/main/agents/service-detection.md) | **ADR**: [0008](./
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

**Full details**: See [`.scaffolding/agents/service-detection.md`](https://github.com/matheme-justyn/ai-skill-web/blob/main/agents/service-detection.md)


## Module Loading Protocol

**Version**: 2.0.0  
**Purpose**: Conditional loading of documentation modules based on the configured domain and task context

### Overview

This scaffolding uses a **config-driven module system**. Instead of loading all documentation at once:

1. AI agent reads `config.toml` to understand which documentation domain is configured
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
[academic]
citation_style = "APA"  # APA | MLA | Chicago | IEEE
field = "computer_science"

[modules]
domain = "fullstack"  # frontend | backend | fullstack | cli | library | academic | documentation
features = ["api", "database", "auth", "i18n"]
quality = ["performance", "accessibility"]
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

**Full module list**: See `docs/adr/0012-module-system-and-conditional-loading.md`

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
# These modules ALWAYS load regardless of domain
always_enabled = ["STYLE_GUIDE", "TERMINOLOGY", "GIT_WORKFLOW", "SECURITY_CHECKLIST"]

# Force-load additional modules
manual_enabled = ["PERFORMANCE_OPTIMIZATION", "ACCESSIBILITY"]

# Disable modules even if the domain suggests them
manual_disabled = ["FRONTEND_PATTERNS"]
```

**Priority**: `manual_disabled` > `manual_enabled` > auto-detection > `always_enabled`

### AI Agent Protocol

**On session start**:

1. Read `config.toml` → identify `[modules].domain`, features, quality requirements
2. Check for manual module overrides (`manual_enabled`, `manual_disabled`)
3. Load `always_enabled` modules
4. Load domain-based modules (e.g., FRONTEND_PATTERNS if `domain = "frontend"`)
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

- **`docs/adr/0012-module-system-and-conditional-loading.md`** - Complete design decisions
- **[config.toml.example](./config.toml.example)** - Configuration reference
- **[Terminology README](https://github.com/matheme-justyn/ai-skill-web/tree/main/docs)** - Terminology system guide


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

### 6. README Maintenance

`README.md` and `README.zh-TW.md` are maintained directly. Edit them.

There used to be a generator, `generate-readme.sh`, and this section used to say
in capitals that editing the READMEs by hand would be overwritten. Both claims
had stopped being true, in a way that made following them destructive: the
script declared `.scaffolding/i18n/locales/{lang}/readme.toml` as its source,
that directory does not exist in this repo, and the content it wrote was
hardcoded inline in the script itself — content from before the rename, titling
the project "My Vibe Scaffolding" and linking to the old repository. Running it
as instructed would have replaced the current READMEs with pre-split text. The
script is removed (ADR 0018).

Two consequences worth knowing:

- The version badge in each README is now maintained by hand. `ci.yml` checks it
  against `.scaffolding/VERSION` and fails on a mismatch, so a stale badge is
  caught rather than merely noticed later.
- `.scaffolding/README.md` and `.scaffolding/README.zh-TW.md` are gone. They were
  copies the generator made, last refreshed at 3.2.0, and nothing read them.

If i18n-driven README generation is wanted again, it needs the translation
source to exist first. That is a design task, not a restoration.
