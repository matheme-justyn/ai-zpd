# Migration Guide: 1.x → 2.0.0

**Date**: 2026-03-16  
**Breaking Changes**: Module system introduction requires `config.toml` creation

---

## What's New in 2.0.0

### Core Feature: Smart Module Loading

v2.0.0 introduces a **configuration-driven module system** that reduces AI agent token usage by 70%+ through conditional documentation loading.

**Key Changes**:
- 31 documentation modules (7 implemented, 24 planned)
- Project-type aware loading (frontend/backend/fullstack/academic/cli/library/documentation)
- Feature-based loading (api, database, auth, i18n, realtime, files)
- Quality-based loading (performance, accessibility)

**Benefit**: AI agents load ONLY relevant documentation, improving response quality and speed.

---

## Migration Steps

### Step 1: Check Current Version

```bash
cat VERSION  # Should show 1.x.x
```

### Step 2: Backup Your Project (Optional)

```bash
git commit -am "chore: pre-2.0.0 backup"
git tag v1.x.x-backup
```

### Step 3: Pull Latest Template

```bash
git pull origin main  # Or fetch latest from template repo
```

### Step 4: Run Configuration Wizard

```bash
./.scaffolding/scripts/configure-project-type.sh
```

**The wizard will ask**:
1. **Project type**: frontend, backend, fullstack, cli, library, academic, documentation
2. **Features**: API, database, auth, i18n, realtime, files
3. **Quality needs**: Performance, accessibility
4. **Language**: zh-TW, en-US, ja-JP, zh-CN
5. **Academic settings** (if type=academic): Citation style, research field

**Output**: `config.toml` with optimal settings for your project.

### Step 5: Verify Configuration

```bash
cat config.toml
```

**Expected sections**:
```toml
[project]
type = "fullstack"  # Your chosen type
features = ["api", "database", "auth"]
quality = ["performance"]

[locale]
primary = "zh-TW"

[modules]
always_enabled = ["STYLE_GUIDE", "TERMINOLOGY", "GIT_WORKFLOW"]
```

### Step 6: Test AI Agent Loading

**Before 2.0.0** (all modules):
- AI agent loads ~15,500 lines of documentation
- 70% irrelevant to your project type

**After 2.0.0** (conditional):
- Fullstack project: ~4,000 lines (relevant only)
- Academic project: ~2,500 lines
- **70%+ token savings**

**Verification**: Start AI agent session and ask:
```
"What documentation modules are loaded for this project?"
```

Expected response should mention only relevant modules (e.g., FRONTEND_PATTERNS for frontend projects, not ACADEMIC_WRITING).

---

## Breaking Changes

### 1. `config.toml` Now Required

**Before 1.x**: Optional configuration  
**After 2.0.0**: `config.toml` required for module loading

**Action**: Run `configure-project-type.sh` to generate.

### 2. Terminology Files Moved

**Before 1.x**: `.scaffolding/terminology/`  
**After 2.0.0**: `.scaffolding/docs/terminology/`

**Action**: None (template handles this automatically).

### 3. PR Templates Now Language-Specific

**Before 1.x**: Single bilingual PR template  
**After 2.0.0**: 4 language-specific templates (auto-selected based on `config.toml`)

**Action**: None (configuration wizard handles this).

---

## New Features

### Terminology System

**7 multilingual terminology files** (English, 繁體中文, 簡體中文, 日本語):
- Universal: Git, naming conventions, SDLC
- Software: Frontend (React, CSS), Backend (Node.js, API), Database (SQL, ORM)
- Academic: Research writing, computer science

**Usage**: AI agents automatically load relevant terminology based on project type.

### High-Priority Modules

**4 new documentation modules**:
1. **STYLE_GUIDE.md** (838 lines): Code style, naming, structure
2. **GIT_WORKFLOW.md** (855 lines): Git workflows, commit format, PR guidelines
3. **ACADEMIC_WRITING.md** (777 lines): Research paper structure (for `type = "academic"`)
4. **CITATION_MANAGEMENT.md** (741 lines): APA/MLA/Chicago/IEEE citation styles

**Loading**: Conditional based on `config.toml` settings.

### Project Configuration Wizard

Interactive script to generate optimal `config.toml`:

```bash
./.scaffolding/scripts/configure-project-type.sh
```

**Features**:
- 7 project types
- Feature and quality selection
- Academic settings (citation style, research field)
- PR template generation

---

## Backward Compatibility

### Existing Projects (Without config.toml)

**Behavior**: AI agents fall back to loading core modules only:
- STYLE_GUIDE
- TERMINOLOGY (universal only)
- GIT_WORKFLOW

**Impact**: Reduced functionality but no breakage.

**Recommendation**: Run configuration wizard to unlock full features.

### Custom Terminology

**Before 1.x**: No custom terminology support  
**After 2.0.0**: Create `.agents/terminology/custom.md` to override terms

**Priority**: custom.md > domain-specific > common > universal

---

## Rollback Plan

If 2.0.0 causes issues:

### Option 1: Stay on 1.x

```bash
git checkout v1.15.0
```

### Option 2: Use Minimal Config

Create minimal `config.toml`:

```toml
[project]
type = "fullstack"
mode = "project"
features = []
quality = []

[locale]
primary = "en-US"
fallback = "en-US"

[modules]
always_enabled = ["STYLE_GUIDE", "TERMINOLOGY", "GIT_WORKFLOW"]
manual_enabled = []
manual_disabled = []
```

This provides backward compatibility while using 2.0.0.

---

## FAQ

### Q: Do I need to run the wizard for every project?

**A**: Yes, each project needs its own `config.toml` with project-specific settings.

### Q: Can I manually edit `config.toml`?

**A**: Yes, after wizard generates it, you can edit directly. See `config.toml.example` for reference.

### Q: What if I don't want module loading?

**A**: Set `manual_disabled = ["FRONTEND_PATTERNS", "BACKEND_PATTERNS", ...]` to disable specific modules.

### Q: How do I add more modules later?

**A**: Use `manual_enabled = ["PERFORMANCE_OPTIMIZATION"]` to force-load additional modules.

### Q: Can I revert to loading all modules?

**A**: No built-in option in 2.0.0. Use `manual_enabled` to load all 31 modules explicitly (not recommended).

### Q: What about academic projects?

**A**: Select `type = "academic"` in wizard, then choose citation style (APA/MLA/Chicago/IEEE) and research field.

---

## Support

**Issues**: Open GitHub issue with tag `v2.0.0-migration`  
**Documentation**: See `docs/adr/0012-module-system-and-conditional-loading.md`  
**Configuration Reference**: See `config.toml.example`

---

## Next Steps

1. ✅ Run configuration wizard
2. ✅ Verify `config.toml` generated
3. ✅ Test AI agent session (check loaded modules)
4. ✅ Update team on new workflow
5. ✅ Review [AGENTS.md § Module Loading Protocol](./AGENTS.md#module-loading-protocol)

---

**Version**: 2.0.0  
**Last Updated**: 2026-03-16  
**Template**: my-vibe-scaffolding
