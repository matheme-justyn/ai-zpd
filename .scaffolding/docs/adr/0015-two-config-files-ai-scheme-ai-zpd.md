# ADR 0015: Two config files, one per layer, with no cross-reads

## Status

Accepted

## Date

2026-09-08

## Context

ADR 0014 split `my-vibe-scaffolding` into three repos and noted that the
`config.toml` / `config.toml.example` split was first-pass only, because the old
scaffolding-mode / project-mode switch does not cleanly apply after the split.
That left an open question: does a project adopting both layers end up with one
config file or two?

Both layers arrived at a config format independently:

- ai-zpd keeps `config.toml` at the repository root (TOML). Sections:
  `[project]` (`type`, `features`, `quality`), `[opencode]` with `.cleanup`,
  `.monitor`, `.workflow`, `.worklog`, `[services]` with `.capabilities` and
  `.fallback`, and `[modules]`.
- ai-scheme proposes `.scheme/config.yml` (YAML), which is what Copier writes
  natively as its answers file.

Three options were considered: unify the format and keep separate paths; merge
into a single file with per-layer sections; or keep two files in two formats and
define the boundary explicitly.

## Decision

Keep two config files in two formats. The repository owner decided this on
2026-09-08, with both layers' agents consulted.

- ai-zpd owns `config.toml` (TOML) at the repository root — the mechanism layer.
- ai-scheme owns `.scheme/config.yml` (YAML) — the skeleton layer.

The boundary is what actually carries the decision:

1. Neither layer reads or writes the other's config file. Keys that happen to
   share a name are independent; there is no fallback from one file to the other
   in either direction.
2. `ai-scheme status` and `ai-scheme adopt` report that a mechanism-layer config
   file was detected, but do not parse it and do not let it change their state
   determination. Changes to `config.toml` therefore cannot affect the skeleton
   layer's state machine.
3. Key ownership is enumerated, not inferred. The skeleton layer owns
   `languages`, `branch_strategy`, `release_phase`, `collaboration_mode`,
   `project_visibility`, `enable_*`, and the template version. The mechanism
   layer owns `[project].type`, `[project].features`, `[project].quality`, and
   the whole of `[opencode]`, `[services]`, and `[modules]`.
4. Names that would read as the same thing across layers are avoided rather
   than disambiguated in prose. ai-scheme does not use the literal
   `project_type`, expressing language and stack through `languages` instead,
   and its contract documents do not use the word `install` — the skeleton
   layer's is `docs/status-interface-contract.md` (how an agent calls the
   lifecycle interface), while ai-zpd keeps `.opencode/INSTALL.md` (how
   capability is installed into the adopting project).

## Consequences

- A project that adopts both layers will contain two config files in two
  formats. User-facing documentation must explain which file governs what, or
  this reads as an accident rather than a decision.
- Rejecting a merged file means neither layer needs to parse the other's format,
  and neither can silently break the other by editing shared state. The cost is
  that the layers must stay honest about ownership by hand; there is no
  mechanical enforcement.

### Follow-up items this decision creates for ai-zpd

- **`[project].type` should be renamed.** The skeleton layer's `project_*` keys
  and `languages` describe the repo skeleton and language profile; ai-zpd's
  `[project].type` describes which documentation modules load. The names are
  close enough that users will conflate them, and under the no-cross-read rule
  two similarly named keys that behave differently is the worst case. ai-scheme
  has already dropped the literal `project_type` on its side, so nothing forces
  this rename; it remains worth doing because `type` alone does not say that
  what it selects is documentation modules.
- **`[project].mode` will be removed rather than assigned an owner.** The
  scaffolding/project switch is the one ADR 0014 already flagged as not applying
  after the split. It currently has one live consumer,
  `.scaffolding/scripts/check-version-sync.sh`, which skips its entire check in
  project mode and therefore never runs in practice.
- **Template version has two implementations and needs one.** ai-scheme's
  `status --json` is to be the single source, exposing `current_version`,
  `target_version`, and `drift`. ai-zpd currently derives the same information
  from `.scaffolding/VERSION` (read by `init-project.sh`) and the
  `.template-version` sentinel it writes into the adopting project. The sentinel
  convention appears in 15 files — both root READMEs, `AGENTS.md`, `.gitignore`,
  `.opencode/INSTALL.md`, both `.scaffolding/` READMEs, the PRD,
  `.scaffolding/tests/test-init-project.sh`, and six scripts
  (`init-project.sh`, `smart-install.sh`, `sync-template.sh`,
  `analyze-conflicts.sh`, `generate-readme.sh`, `migrate-to-template-dir.sh`) —
  so this is a migration, not an edit. Until it is done,
  `.template-version` is a transitional compatibility path, read-only, and read
  only in the `migrate` state.

## Cross-repo reference convention

Cross-repo ADR references are written as `<repo> ADR <n>` — for example
`ai-zpd ADR 0014` — because ai-scheme is renumbering its own ADRs to a
contiguous 0001–0006 range and bare numbers would become ambiguous.

## Related

- ai-zpd ADR 0014 — the three-repo split that created this boundary.
