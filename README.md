<div align="center">

<img src="./.scaffolding/assets/images/20260225_vibe-scaffolding-logo.png" alt="Vibe Scaffolding Logo" width="400"/>

# ai-zpd

[![Version](https://img.shields.io/badge/version-4.0.2-blue.svg)](./.scaffolding/VERSION)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)

English | [繁體中文](./README.zh-TW.md)

</div>

---

## 🔄 This Repo is Splitting Into Three

`my-vibe-scaffolding` is being split into three repos, each responsible for one layer of the "golden path" this template used to hold as a single bundle:

- **`ai-scheme`** — the repo/CI skeleton layer
- **`ai-zpd`** — the capability-delivery mechanism layer (**this repo**, being renamed)
- **`ai-skill-web`** — the hand-authored skill/agent-content layer

This repo keeps its git history and becomes `ai-zpd`. The other two are newly split out and being populated in stages.

### Why "ai-zpd"

Named after Lev Vygotsky's **Zone of Proximal Development** — Russian **зона ближайшего развития** (*zona blizhaishego razvitiya*). One translation note: "ближайший" more precisely means "nearest" or "next," not the spatially-flavored English "proximal" — the zone isn't some distant stretch goal, it's the very next layer of ability already within reach.

ZPD is the gap between what a learner can do alone and what they can do with the right support. That's this repo's job going forward: deciding what capability/support gets extended to an agent, right at the edge of what it can't yet do alone — not the skeleton it runs in (`ai-scheme`), not the skill content itself (`ai-skill-web`). Concretely, that means being the connector layer: configure it once, and it routes capability into whatever the agent is actually running in — IDE, CLI, or anything else — without the caller needing to know the wiring underneath.

### The Occupation: Telephonist

Every name in this project family pairs a psychologist's term with a vanished occupation that embodies it. This one is the **telephonist**.

Before automatic exchanges, you couldn't dial another line yourself — you told a telephonist the name or number you wanted, and she made the physical connection on a switchboard for you, without you ever needing to understand the exchange's wiring. Automated switching started in 1892; by the 1980s the manually-operated switchboard role had essentially vanished entirely.

That's this repo's job in one image: you say what you want connected, and the connection happens, however the underlying platform actually needs to be wired.

---

## 📌 What is This?

**AI-driven project scaffolding template** for quick project setup with best practices.

Named after the *scaffolding* metaphor from educational psychology — provides structure when you need it, remove it when you don't.

> The term "scaffolding" was coined by Wood, Bruner & Ross (1976) to describe how a more knowledgeable guide supports a learner across Vygotsky's Zone of Proximal Development (ZPD) — the gap between what a learner can do alone and what they can do with help. Vygotsky himself never used the word "scaffolding."

<div align="center">
<img src="./.scaffolding/assets/images/20260225_vibe-scaffolding-illustration-american.png" alt="American Style Illustration" width="300"/>
<img src="./.scaffolding/assets/images/20260225_vibe-scaffolding-illustration-japanese.png" alt="Japanese Style Illustration" width="300"/>
</div>

### Core Features

- 🤖 **AI Agent Integration** - `AGENTS.md` + Skills system for OpenCode/Cursor/Claude
- 📦 **Version Management** - Pre-push hooks enforce version updates
- 🌐 **Multi-language** - BCP 47 i18n for documentation
- 🛠️ **Smart Setup** - First-time setup handled automatically by AI agent

---

## 🚀 Installation

**Unified AI Prompt (Works for All Scenarios):**

```
Apply scaffolding from https://github.com/matheme-justyn/my-vibe-scaffolding to current project
```

**AI will automatically detect and handle:**

### Scenario A: Existing Project

If current directory has project files (`.git/`, `package.json`, etc.):
1. Download `.scaffolding/` directory from GitHub
2. Download `AGENTS.md`, `config.toml.example`
3. Run `./.scaffolding/scripts/init-project.sh`
4. Script detects no `.template-version` → **First-time mode**

### Scenario B: New Project from Template

If creating a brand new project:
1. Click **"Use this template"** on GitHub
2. Clone your new repository
3. Run `./.scaffolding/scripts/init-project.sh`
4. Script detects no `.template-version` → **First-time mode**

**Key benefit**: One prompt for all scenarios — AI handles the rest

---

## ⚙️ How the Script Works

The `init-project.sh` script intelligently detects your situation:

**First-time mode** (no `.template-version` file):
- Asks for project information
- Creates VERSION, README.md, LICENSE
- Sets up Git hooks
- Creates `.template-version` to track which template version you're using

**Update mode** (`.template-version` exists):
- Compares current version with template version
- Consolidates agent configs (`.claude`, `.roo` → `.agents`)
- Reinstalls Git hooks (may have new features)
- Updates `.template-version`

**When to run manually:**
- After cloning new project from template
- When you want to update template features
- When consolidating scattered agent configurations

---

## 📖 Documentation

- 📖 **[Full Features](./.scaffolding/docs/FEATURES.md)** - Complete v2.0.0 technical documentation
- 🤖 **[AGENTS.md](./AGENTS.md)** - AI agent instructions and coding conventions
- 📝 **[CHANGELOG.md](./.scaffolding/CHANGELOG.md)** - Version history and changes

---

## 🎯 Tech Stack

Why these technologies?

| Technology | Why | Problem Solved |
|------------|-----|----------------|
| **OpenCode** (Open-source AI) | 75+ models, CLI-first | Avoid vendor lock-in |
| **AGENTS.md Standard** | Cross-tool compatible | AI understands project conventions |
| **Skills System** | Reusable workflows | Encode best practices |
| **Bundles & Workflows** | Role-based collections | Quick context loading |

We use [superpowers](https://github.com/ohmyopencode/superpowers) - community-driven AI workflows.

---

## 📄 License

MIT License - See [LICENSE](./LICENSE)

---

<div align="center">

**Vygotsky's ZPD, Bruner's Scaffolding | Powered by AI | For Developers**

[Documentation](./.scaffolding/docs/) | [Changelog](./.scaffolding/CHANGELOG.md) | [GitHub](https://github.com/matheme-justyn/my-vibe-scaffolding)

</div>
