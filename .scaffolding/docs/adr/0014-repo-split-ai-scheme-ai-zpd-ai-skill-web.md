# ADR 0014: Split into ai-scheme / ai-zpd / ai-skill-web

## Status

Accepted

## Date

2026-08-25

## Context

`my-vibe-scaffolding` bundled three concerns in one repo: repo/CI skeleton, install/runtime mechanism, hand-authored agent/skill content. Mirrors a three-layer split the author had already used elsewhere (repo template / AI setup / future agent kit), not a fork — terminology differs, and that link stays private-side only.

## Decision

Split into three repos, one-way content move (no git history rewrite, plain copy + delete):

- **ai-scheme** — repo/CI skeleton (languages/, hooks, PR templates, vscode, i18n mechanism, doc-convention guides, coding conventions slice of AGENTS.md)
- **ai-zpd** — install/runtime mechanism (this repo, renamed in place from my-vibe-scaffolding, kept git history, v3.2.0 → v4.0.0). Scripts, opencode config, MCP/service detection, module loading, release/migration docs.
- **ai-skill-web** — hand-authored content (agents/, skills/, commands/, rules/, SDD workflow, skill-pattern docs)

`AGENTS.md` and `config.toml.example` split by section into each repo; no single repo keeps the full original.

## Naming

Each repo: psychologist + their original-language term + a vetted vanished occupation. Formula and full rejected-candidate log: see this user's memory system, file `scaffold-vibe-repo-split-naming.md`.

| Repo | Psychologist / term | Occupation | Why |
|---|---|---|---|
| ai-scheme | Jean Piaget — French *schème* (not *schéma*) | Punchcutter (字模雕刻師) | Punch strikes matrix strikes unlimited type — template of templates, matches schème's "reusable skeleton of action" |
| ai-zpd | Lev Vygotsky — ЗПД (зона ближайшего развития, "nearest" not "proximal") | Telephonist (電話接線員) | Say what you want connected, connection happens, caller doesn't need the wiring — matches config-driven cross-platform capability routing |
| ai-skill-web | Kurt W. Fischer — Dynamic Skill Theory, "skill web" | Wheelwright (造輪匠) | Many interlocking sub-skills, none alone sufficient — literal skill-web shape |

Occupation candidates checked against user's own `tool-armarius`/`tool-spigurnel`/`tool-zographos`/`tool-anagnostes`/`kb-scriptorium` naming portfolio (no dupes) and against PyPI/npm/GitHub squatting, same diligence as `tool-spigurnel/docs/naming-history.md`.

## Incident: Dropbox mmap failures during migration

Mid-migration, `git status`/`add`/`commit`/`push` in this repo (hosted under `~/Library/CloudStorage/Dropbox/`) started failing with `fatal: mmap failed: Operation timed out`, persisting across 10+ min of retries. Root cause: Dropbox desktop app was not running at all — its File Provider extension (`DropboxFileProvider.appex`) still mounts `~/Library/CloudStorage/Dropbox`, but with no daemon behind it, on-demand file materialization hangs. Confirmed via: plain `cat`/`mmap` on `.git/FETCH_HEAD` and `.git/ORIG_HEAD` timed out identically to git itself; a scripted scan found 600+ `.git/objects/` loose objects unreadable the same way. Fix: user started Dropbox; `git status` succeeded 30s later, push succeeded shortly after. No data lost — working-tree files were unaffected throughout, only `.git` internals were unreadable.

Lesson: if `mmap failed: Operation timed out` recurs on a Dropbox-hosted repo, check `ps aux | grep -i dropbox` for the actual `Dropbox.app` process (not just the FileProvider extension, which can be running even when the app looks closed) before diagnosing further.

## Consequences

- Three separate git histories going forward; ai-scheme and ai-skill-web start fresh (no pre-split history).
- `.scaffolding/i18n/`, `.scaffolding/docs/terminology/` moved to ai-scheme (doc-convention concern), not left in ai-zpd.
- ~20 docs with no clean single-repo owner (FEATURES.md, migration/release notes, PRD variants, opencode/MCP setup guides) stayed in ai-zpd by default — revisit if they turn out to belong elsewhere.
- `config.toml`/`config.toml.example` split is first-pass only; each repo's actual config needs a real redesign pass since the old scaffolding-mode/project-mode switch doesn't cleanly apply post-split.
