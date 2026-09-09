# ADR 0008: OpenCode Configuration Strategy - Claude Code Reference Adaptation

## Status

Accepted (2026-03-12)

## Context

### The Challenge

As AI-assisted development tools mature, the gap between "making Claude/OpenCode work" and "making it work well in production" has widened. The 2026 Anthropic Hackathon winner, Affaan Mustafa, demonstrated this by releasing [everything-claude-code](https://github.com/affaan-m/everything-claude-code) - a comprehensive configuration accumulated over 10 months of real product development. With 49K+ stars and 6,200 forks, it represents the community's recognition that AI coding assistant configuration is far more complex than initially assumed.

### Claude Code's Five-Layer Architecture

The winning configuration organizes AI agent behavior into five distinct layers:

**1. Agents (13 specialized sub-agents)**
- Delegation-based architecture: planner, architect, tdd-guide, code-reviewer, security-reviewer, build-fixer, e2e-tester, refactor-cleaner, doc-updater
- Language-specific reviewers: Go, Python, Database specialists
- Design rationale: Avoid "wide but shallow" LLM performance boundaries by delegating tasks to specialized nodes

**2. Skills (40+ workflow modules)**
- Language-specific patterns: TypeScript, Python, Go, Java, C++, Django, Spring Boot
- Context-specific workflows: testing, security, deployment, API design, database migration, Docker
- Advanced modules: cost-aware LLM pipeline, content hash cache patterns
- Purpose: Codify reusable patterns, not one-off solutions

**3. Commands (31 slash commands)**
- Basic: `/plan`, `/tdd`, `/code-review`, `/build-fix`, `/e2e`
- Multi-agent coordination: `/multi-plan`, `/multi-execute`
- Learning: `/instinct-status`, `/evolve`
- Purpose: Single-step trigger for common workflows

**4. Hooks (trigger-based automation)**
- Memory persistence: cross-conversation context retention
- Context compression: manage long-running context efficiently
- Pattern extraction: auto-learn from interaction history
- Purpose: Maintain coherence across sessions without manual intervention

**5. Rules (always-enforced coding standards)**
- Universal rules + language-specific rules (TypeScript/Python/Go)
- Coverage: code style, Git workflow, testing standards, security requirements
- Purpose: Consistent behavior regardless of conversation context

### Key Design Principles

1. **AgentShield (Security-First)**: 102 vulnerability scan rules, 912 test cases, 98% coverage - treats configuration files as attack surfaces
2. **Continuous Learning v2**: "Instinct" extraction with confidence scoring - AI accumulates codebase-specific memory
3. **Skill Creator**: Auto-generate skills from Git commit history - reduce manual configuration cost

### Current OpenCode Architecture Status

**Existing Strengths:**
- ✅ `.agents/` directory structure established
- ✅ `bundles.yaml` and `workflows.yaml` in place (role-based skill collections)
- ✅ AGENTS.md comprehensive: System Environment, Project Overview, Tech Stack, Coding Conventions, Git Conventions, Skill System, i18n, Documentation Standards
- ✅ 25 scripts in `.scaffolding/scripts/` (init, bump-version, generate-readme, install-hooks, etc.)
- ✅ MCP integration: filesystem, git, memory, github tools available

**Critical Gaps:**
- ❌ **Commands block missing** in AGENTS.md (one of 6 standard blocks in 2026 AGENTS.md format)
- ❌ **No service capability detection** - OpenCode attempts unavailable services (e.g., google-search) leading to cryptic errors
- ❌ **No explicit agent delegation architecture** - only skill bundles exist, no orchestration layer
- ❌ **Hooks/Rules not systematically organized** - scattered across AGENTS.md without clear activation mechanism

**Specific Pain Point: Service Detection**
User reported: OpenCode repeatedly tries `google_search` tool which fails with 403 Forbidden (service disabled in GCP project). No mechanism to declare "this service is unsupported, use alternative X instead."

## Decision

We adopt a **phased hybrid approach**: selectively integrate Claude's five-layer model while respecting OpenCode's existing MCP-based ecosystem and scaffolding template structure.

### Phase 1: Foundation (Immediate - Week 1)

#### 1.1 Add Commands Block to AGENTS.md (Layer 3 equivalent)

**Rationale**: Commands are the most user-facing gap and easiest to implement. Provides immediate value.

**Implementation**:
```markdown
## Commands

### Development
- Install: [project-specific, to be filled based on tech stack]
- Dev: [project-specific]
- Build: [project-specific]
- Test: [project-specific]

### Template Management
- Init project: `./.scaffolding/scripts/init-project.sh`
- Bump version: `./.scaffolding/scripts/bump-version.sh [patch|minor|major]`
- Generate README: `./.scaffolding/scripts/generate-readme.sh`
- Sync README: `./.scaffolding/scripts/sync-readme.sh`
- Sync template: `./.scaffolding/scripts/sync-template.sh` (to be implemented)

### Git Hooks
- Install hooks: `./.scaffolding/scripts/install-hooks.sh`

### OpenCode Specific
- Health check: `./.scaffolding/scripts/health-check.sh`
- Clean sessions: `./.scaffolding/scripts/smart-cleanup.sh`
- Monitor stability: `./.scaffolding/scripts/monitor-stability.sh`
```

#### 1.2 Service Capability Detection System

**Problem**: OpenCode has no way to know which services are unavailable until they fail.

**Solution**: Multi-layer service registry with graceful fallback

**A. Config Declaration** (`config.toml`):
```toml
[services]
# Explicitly declare unsupported services
unsupported = [
  "google-search",  # Requires GCP API enablement
  "google_search",  # Alternative name
]

# Service capability matrix
[services.capabilities]
web_search = ["websearch_web_search_exa", "webfetch"]  # Available alternatives
code_search = ["grep_app_searchGitHub"]
documentation = ["context7_query-docs", "context7_resolve-library-id"]

# Fallback behavior
[services.fallback]
mode = "suggest"  # Options: "suggest" (show alternatives), "auto" (use first available), "fail" (stop with error)
log_attempts = true  # Log failed service calls for debugging
```

**B. AGENTS.md Service Detection Protocol**:
```markdown
## Service Detection Protocol

**CRITICAL: AI agents MUST follow this protocol BEFORE calling ANY external service.**

### Pre-Call Checklist

1. **Read service capabilities** from `config.toml` [services] section
2. **Check if service is in `unsupported` list**
   - If YES → Skip to step 4 (use alternative)
   - If NO → Proceed to step 3
3. **Attempt service call** (if not in unsupported list)
4. **On failure OR if service unsupported**:
   - Check `[services.capabilities]` for alternatives
   - Present alternatives to user: "Service X unavailable. Available alternatives: Y, Z. Recommend: Y because [reason]"
   - If no alternatives exist: Clearly state limitation and suggest manual workaround

### Example Flow

```
User: "Search the web for X"
Agent checks config.toml:
  - "google-search" in unsupported? → YES
  - Check alternatives: web_search = ["websearch_web_search_exa", "webfetch"]
  - Use websearch_web_search_exa (prioritize full-featured tool)
  - Inform user: "Using websearch_web_search_exa as alternative to google-search"
```

### Error Message Template

When service unavailable:
```
❌ Service '{service_name}' is not available in this configuration.

Reason: {reason from config or API response}

✅ Available alternatives:
  1. {alternative_1} - {description}
  2. {alternative_2} - {description}

Recommended: Use {recommended_alternative}
Command: [具體使用方式]
```
```

**C. Service Detection Helper** (`.agents/service-detection.md`):
Creates a dedicated reference file for service capability queries, enabling AI to quickly check without re-parsing entire AGENTS.md.

### Phase 2: Skills & Delegation (Medium-term - Month 1)

#### 2.1 Enhance Skill Bundles with Role Definitions (Layer 1 & 2)

**Current state**: `bundles.yaml` defines skill collections but no clear orchestration

**Enhancement**: Add "agent role" metadata to bundles

```yaml
bundles:
  - id: "backend-dev"
    name: "Backend Development"
    agent_role: "backend-specialist"  # NEW: role identifier
    delegation_priority: "high"        # NEW: when to delegate vs handle inline
    skills: [...]
    
  - id: "security-audit"
    name: "Security Review"
    agent_role: "security-reviewer"
    delegation_priority: "always"      # Always delegate, never inline
    requires_approval: true            # Must ask before running
    skills: [...]
```

**Rationale**: Bridges gap between "skill collection" and "specialized agent" without full Claude-style sub-agent architecture (which may not fit OpenCode's execution model).

#### 2.2 Skill Creator from Git History (Layer 2 enhancement)

**Inspired by**: Claude's auto-generation from Git commits

**Implementation**: Add `.scaffolding/scripts/generate-skills-from-git.sh`
- Analyzes commit patterns (e.g., frequent test additions → TDD focus)
- Suggests skill modules based on file change patterns
- Generates skill template in `.agents/skills/generated/`

**Rationale**: Reduces manual skill configuration burden, especially for domain-specific codebases.

### Phase 3: Hooks & Memory (Long-term - Month 2-3)

#### 3.1 Context Compression Strategy (Layer 4)

**Challenge**: OpenCode sessions grow large, slowing down response time

**Solution**: Implement smart summarization hooks
- After N messages: Trigger context compression
- Preserve: Recent decisions, open todos, critical errors
- Archive: Detailed implementation logs, redundant Q&A

**Integration point**: Leverage OpenCode's session management (`.opencode-data/`)

#### 3.2 Pattern Extraction ("Instinct" Learning)

**Inspired by**: Claude's Continuous Learning v2

**Adaptation for OpenCode**:
- After each session: Extract key decisions → store in `.agents/learned-patterns.yaml`
- Format:
  ```yaml
  patterns:
    - id: "prefer-functional-components"
      context: "React development"
      confidence: 0.95
      learned_from: ["session_001", "session_005"]
      rule: "User prefers functional components over class components"
  ```

**Rationale**: Gradual learning without complex "instinct" scoring system (simpler MVP).

### Service Detection Design Details

**Why critical**: Without this, OpenCode wastes time, confuses users, and creates false urgency ("Why won't google-search work?!")

**Design considerations**:

1. **Declarative over procedural**: Use config file, not code
2. **Fail-fast with helpful errors**: Don't retry unsupported services
3. **Extensible**: Adding new service = update config, no code change
4. **Transparent**: User always knows why alternative was chosen

**Edge cases handled**:
- Service temporarily unavailable (network issue) vs permanently disabled (config)
- Multiple alternatives available → rank by capability (full-featured first)
- No alternatives available → clear "not possible" message with manual workaround

**Integration with MCP**: Service detection works ALONGSIDE MCP tools, not replacing them. MCP provides tools, service detection decides WHICH tools to use.

## Consequences

### Positive Impacts

1. **Immediate UX improvement**: No more cryptic "403 Forbidden" errors, users get actionable alternatives
2. **Standards compliance**: AGENTS.md matches 2026 format, improving cross-tool compatibility
3. **Graceful degradation**: System works even when services unavailable
4. **Reduced configuration burden**: Git-based skill generation automates common patterns
5. **Progressive enhancement**: Each phase delivers value independently

### Negative Impacts / Risks

1. **Configuration complexity increases**: More files to maintain (config.toml, service-detection.md, skills/)
2. **Learning curve for contributors**: Must understand five-layer model to contribute effectively
3. **Maintenance burden**: Service capabilities must be kept up-to-date as ecosystem evolves
4. **Potential over-engineering**: Risk of adding features that don't match OpenCode's execution model

**Mitigation strategies**:
- Start with Phase 1 only, validate user value before Phase 2/3
- Documentation-first approach: Explain WHY each layer exists
- Regular pruning: Remove unused skills/hooks every quarter
- Community feedback loop: Track which features actually get used

### Migration Cost

**Time investment**:
- Phase 1: 1-2 days (Commands block + service detection)
- Phase 2: 1 week (enhanced bundles + skill generator)
- Phase 3: 2-3 weeks (hooks + pattern learning)

**Backward compatibility**:
- ✅ Fully backward compatible: All changes are additive
- ✅ Existing skills/bundles continue working
- ✅ No breaking changes to AGENTS.md structure (only additions)

**Learning curve**:
- Template maintainers: Medium (understand five layers)
- Template users: Low (mostly invisible, just better UX)
- AI agents: None (reads from config, no code changes)

## Alternatives Considered

### Alternative 1: Maintain Status Quo

**Pros**:
- Zero implementation cost
- No new complexity

**Cons**:
- Service detection problem unsolved (major UX pain)
- AGENTS.md remains non-standard (compatibility issues)
- Miss opportunity to learn from proven production patterns

**Verdict**: ❌ Rejected - Pain points are real and growing

### Alternative 2: Full Clone of Claude Config

**Pros**:
- Battle-tested architecture
- Comprehensive feature set

**Cons**:
- 🚫 Over-engineered for OpenCode's simpler execution model
- 🚫 Ignores existing MCP integration strengths
- 🚫 Massive migration cost (weeks of work)
- 🚫 May not fit OpenCode's workflow at all

**Verdict**: ❌ Rejected - Too risky, not validated for OpenCode

### Alternative 3: Phased Hybrid (Adopted)

**Pros**:
- ✅ Incremental value delivery
- ✅ Can stop after Phase 1 if not working
- ✅ Respects existing OpenCode architecture
- ✅ Cherry-picks best ideas from Claude

**Cons**:
- Requires discipline to not over-engineer
- Needs clear phase exit criteria

**Verdict**: ✅ **Adopted** - Best risk/reward ratio

## Implementation Phases Summary

| Phase | Timeline | Deliverables | Success Criteria |
|-------|----------|--------------|-----------------|
| **Phase 1** | Week 1 | Commands block, Service detection, ADR | Users get helpful errors instead of cryptic failures |
| **Phase 2** | Month 1 | Enhanced bundles, Skill generator | Auto-generated skills match manual quality |
| **Phase 3** | Month 2-3 | Context compression, Pattern learning | Session performance improves, learned patterns reduce repeat questions |

**Go/No-Go decision points**:
- After Phase 1: Did service detection reduce support questions?
- After Phase 2: Are auto-generated skills being used?
- After Phase 3: Does pattern learning improve session quality?

## References

- [everything-claude-code GitHub Repository](https://github.com/affaan-m/everything-claude-code)
- [Anthropic Hackathon Winner Analysis](https://www.blocktempo.com/hackathon-winner-claude-code-setup-revealed/) (動區動趨)
- [AGENTS.md Standard (2026)](https://github.com/agentsmd/agents.md)
- Existing ADR 0005: [Single Instance OpenCode Workflow](./0005-single-instance-opencode-workflow.md)
- Existing ADR 0007: `0007-agent-skills-ecosystem-integration.md`（已隨 skills 內容遷往 ai-skill-web）

## Change Log

- 2026-03-12: Initial version (Status: Accepted)
