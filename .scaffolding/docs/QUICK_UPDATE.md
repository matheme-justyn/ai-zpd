# Quick Update Guide for Existing Projects

> **For projects already using my-vibe-scaffolding**  
> **Date**: 2026-03-03  
> **Update**: OpenCode project-isolated database configuration

---

## 🎯 What's New

**OpenCode Multi-Project Support** - Solve database conflicts!

Previously, all VSCode OpenCode instances shared `~/.local/share/opencode/opencode.db`, causing:
- 🔥 Crashes when multiple projects open
- 💔 Session history loss
- 🐌 Database bloat (> 50MB)

**Now**: Each project uses isolated `.opencode-data/` directory!

---

## 🚀 Quick Update (3 Steps)

### Method 1: AI-Assisted (Recommended)

Paste this in OpenCode/Cursor/Claude:

```
my-vibe-scaffolding (scaffolding template)
Update my-vibe-scaffolding by following the instructions here:
https://raw.githubusercontent.com/matheme-justyn/my-vibe-scaffolding/main/.opencode/INSTALL.md

Execute: ./.scaffolding/scripts/smart-install.sh

This will detect existing project and run incremental update only.
```

### Method 2: Manual Update

```bash
# 1. Pull latest template changes
git remote add scaffolding https://github.com/matheme-justyn/my-vibe-scaffolding.git
git fetch scaffolding
git merge scaffolding/main  # Or cherry-pick specific commits

# 2. Run OpenCode configuration
./.scaffolding/scripts/init-opencode.sh

# 3. Restart VSCode
```

---

## ✅ What Gets Updated

**Safe (will not overwrite):**
- ✅ `.vscode/settings.json` - Only if not exists or missing opencode.dataDir
- ✅ `.gitignore` - Appends `.opencode-data/` (no overwrite)
- ✅ `.scaffolding/` directory - Template infrastructure updates

**Not touched:**
- ✅ Your `README.md`
- ✅ Your `LICENSE`
- ✅ Your project files
- ✅ Your custom configurations

---

## 🔍 Verify Update Success

```bash
# 1. Check configuration
cat .vscode/settings.json
# Should contain: "opencode.dataDir": "${workspaceFolder}/.opencode-data"

# 2. Restart VSCode and check directory creation
ls -la .opencode-data/
# Should see: opencode.db, opencode.db-shm, opencode.db-wal

# 3. Test multi-project
# Open multiple VSCode windows → All should work without crashes
```

---

## 📖 Detailed Documentation

- [ADR 0005 - Technical Investigation](./adr/0005-single-instance-opencode-workflow.md)
- [Setup Guide](./OPENCODE_SETUP_GUIDE.md)
- [Template Sync](./TEMPLATE_SYNC.md)

---

## 🆘 Troubleshooting

### Q: Update script not working?

**A**: Manually run OpenCode configuration:
```bash
./.scaffolding/scripts/init-opencode.sh
```

### Q: Still using old database?

**A**: Check VSCode settings:
1. Completely close all VSCode windows
2. Reopen project
3. Verify: `cat .vscode/settings.json`

### Q: Want to clean old shared database?

**A**: After ALL projects configured:
```bash
# Backup first!
cp -r ~/.local/share/opencode ~/opencode-backup

# Clean old database
rm -rf ~/.local/share/opencode/opencode.db*
```

---

## 💬 Questions?

- Issues: https://github.com/matheme-justyn/my-vibe-scaffolding/issues
- Changelog: `.scaffolding/CHANGELOG.md`
