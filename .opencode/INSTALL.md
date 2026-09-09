# Installing My Vibe Scaffolding

This scaffolding provides AI agent support, i18n, version management, and best practices for project development.

---

## 🚀 Quick Install (Recommended)

**One command handles both installation and updates:**

```bash
./.scaffolding/scripts/init-project.sh
```

**The script automatically detects:**

- **New project** (no `.template-version` file):
  - Creates project-specific files (VERSION, README, etc.)
  - Sets up Git hooks
  - Initializes OpenCode configuration
  - Creates `.template-version` for tracking

- **Existing project** (`.template-version` exists):
  - Consolidates agent configs (`.claude`, `.roo` → `.agents`)
  - Updates template version tracking
  - Reinstalls Git hooks
  - Preserves all your customizations

**Benefits:**
- ✅ Single command for install and update
- ✅ Auto-detects project state
- ✅ Safe: Won't overwrite your README/LICENSE/custom files
- ✅ Smart: Only updates what's needed

---

## Prerequisites

### Required

- **Git** - Version control
- **Node.js** (v18+) or **Bun** - For running scripts

### MCP Servers (Optional but Recommended)

MCP (Model Context Protocol) enhances AI capabilities with filesystem, git, and GitHub access.

**Required tools for MCP:**

1. **Bun** (https://bun.sh)
   ```bash
   # macOS/Linux
   curl -fsSL https://bun.sh/install | bash
   
   # Windows
   powershell -c "irm bun.sh/install.ps1 | iex"
   ```

2. **uv** (https://docs.astral.sh/uv/)
   ```bash
   # macOS/Linux
   curl -LsSf https://astral.sh/uv/install.sh | sh
   
   # Windows
   powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
   ```

**MCP Servers included:**
- **filesystem** - Direct file read/write access for AI
- **git** - Git operations (status, diff, commit, etc.)
- **memory** - AI memory persistence across sessions
- **github** (optional) - GitHub API integration (requires Personal Access Token)

**Test MCP Setup:**
```bash
./.scaffolding/scripts/test-mcp-setup.sh
```

---

## Installation Scenarios

### Scenario 1: New Project from Template

1. **Use GitHub Template**:
   - Visit https://github.com/matheme-justyn/my-vibe-scaffolding
   - Click "Use this template" → "Create a new repository"
   - Clone your new repository

2. **Initialize**:
   ```bash
   cd your-project-name
   ./.scaffolding/scripts/init-project.sh
   ```

3. **Done!** Start building your project.

---

### Scenario 2: Update Existing Project

If you previously used this scaffolding and want to update:

```bash
./.scaffolding/scripts/init-project.sh
```

The script detects you have `.template-version` and runs update mode automatically.

**What gets updated:**
- `.scaffolding/` directory (framework files)
- OpenCode configuration
- Git hooks
- Agent configs consolidated to `.agents/`

**What stays unchanged:**
- Your README.md
- Your LICENSE
- Your custom files
- Your project code

---

### Scenario 3: Integrate into Existing Project

⚠️ **Warning**: This adds scaffolding to an existing project. Commit your work first!

#### Option A: AI-Assisted Integration (Recommended)

Paste this in OpenCode/Cursor/Claude:

```
I'm integrating my-vibe-scaffolding into an existing project.
Please follow these steps:

1. Run: ./.scaffolding/scripts/analyze-conflicts.sh
2. Read the generated conflict report (.scaffolding-analysis/conflict-report.md)
3. Help me resolve conflicts based on the report categories:
   - Category 1 (🔄 Must Rewrite): Rewrite following scaffolding guides
   - Category 2 (⬇️ Direct Import): Use scaffolding version
   - Category 3 (🔧 Convert): Merge/convert to scaffolding format
   - Category 4 (✅ Keep Yours): Keep project's version
   - Category 5 (➕ New Files): Import scaffolding's new files
```

#### Option B: Manual Integration

1. **Add as Remote**:
   ```bash
   git remote add scaffolding https://github.com/matheme-justyn/my-vibe-scaffolding.git
   git fetch scaffolding
   ```

2. **Run Conflict Analysis**:
   ```bash
   ./.scaffolding/scripts/analyze-conflicts.sh
   ```

3. **Merge**:
   ```bash
   git checkout -b integrate-scaffolding
   git merge scaffolding/main --allow-unrelated-histories
   ```

4. **Resolve conflicts** based on the analysis report, then commit.

---

### Scenario 4: Cherry-Pick Features

Only want specific features? Pick what you need:

#### AI Agent Configuration
```bash
curl -o AGENTS.md https://raw.githubusercontent.com/matheme-justyn/my-vibe-scaffolding/main/AGENTS.md
# Edit AGENTS.md for your project
```

#### i18n System
```bash
mkdir -p .scaffolding/i18n/locales/en-US .scaffolding/i18n/locales/zh-TW
curl -o config.toml.example https://raw.githubusercontent.com/matheme-justyn/my-vibe-scaffolding/main/config.toml.example
```

---

## Configuration

After installation, configure for your needs:

### 1. Set Working Mode

Edit `config.toml`:
```toml
[project]
mode = "project"  # "scaffolding" if you're developing the template itself
```

### 2. Set Language

Edit `config.toml`:
```toml
[i18n]
primary_locale = "zh-TW"  # or "en-US", "ja-JP", etc.
fallback_locale = "en-US"
```

### 3. Update Project Info

Edit `README.md`, `AGENTS.md` with your project details.

### 4. Choose License

See `.scaffolding/docs/PROJECT_LICENSE_GUIDE.md` for guidance.

---

## What You Get

- **AI Agent Configuration**: `AGENTS.md` with coding conventions, commit format
- **Version Management**: Automatic version checking on git push
- **i18n Support**: Multi-language documentation (BCP 47)
- **Project Guides**: LICENSE, CONTRIBUTING, SECURITY setup guides
- **Documentation Structure**: ADR templates, organization guidelines
- **Skills System**: Reusable AI workflows (bundles, workflows)
- **Working Modes**: Scaffolding vs Project mode separation

---

## Troubleshooting

### Language not switching

1. Check `config.toml` exists (copy from `.example`)
2. Verify locale directory: `.scaffolding/i18n/locales/{your-lang}/`
3. Ensure OpenCode reads `AGENTS.md` (it should by default)

### MCP not working

Run the test script:
```bash
./.scaffolding/scripts/test-mcp-setup.sh
```

This will diagnose Bun, uv, and MCP configuration issues.

---

## Support

- Issues: https://github.com/matheme-justyn/my-vibe-scaffolding/issues
- Documentation: See `.scaffolding/docs/` directory
- Changelog: `.scaffolding/CHANGELOG.md`

---

## Learn More

- [README Guide](./.scaffolding/docs/README_GUIDE.md) - How to write project README
- [Documentation Guidelines](./.scaffolding/docs/DOCUMENTATION_GUIDELINES.md) - File organization
- [Skills Usage Guide](./.scaffolding/docs/SKILLS_USAGE_GUIDE.md) - Using AI skills system
- [License Guide](./.scaffolding/docs/PROJECT_LICENSE_GUIDE.md) - Choosing a license
- [Contributing Guide](./.scaffolding/docs/PROJECT_CONTRIBUTING_GUIDE.md) - Setting contribution policy
