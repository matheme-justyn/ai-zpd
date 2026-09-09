# ADR 0009: Reference Claude Code's Five-Layer Architecture for OpenCode Adaptation

**Status**: Accepted  
**Date**: 2026-03-12  
**Deciders**: Template Maintainers  
**Tags**: architecture, ai-agents, opencode, claude-code, reference-design

## Context

In March 2025, Claude Code won the Anthropic API hackathon with a five-layer architecture designed for AI agent orchestration. This architecture has proven highly effective for:

1. **Delegation**: Coordinating multiple specialist agents
2. **Reusability**: Encoding best practices in portable modules (skills)
3. **Automation**: Git hooks and CI/CD integration
4. **Guardrails**: Preventing common AI agent failures
5. **Auditability**: Configuration as code (AgentShield concept)

**Reference**: [Claude Code Hackathon Winner Setup](https://www.blocktempo.com/hackathon-winner-claude-code-setup/)

Our my-vibe-scaffolding template aims to provide similar capabilities for OpenCode users. We need to decide how to adapt Claude Code's architecture while respecting OpenCode's differences.

## Decision

We will **adapt Claude Code's five-layer architecture** to OpenCode, mapping each layer to OpenCode equivalents:

### Layer Mapping

| Layer | Claude Code | My-Vibe-Scaffolding (OpenCode) | Implementation Status |
|-------|-------------|--------------------------------|----------------------|
| **1. Agents** | Delegation system | Task delegation in `AGENTS.md` | ✅ Complete |
| **2. Skills** | Prompt modules | `.agents/skills/`, superpowers | ✅ Complete |
| **3. Commands** | Task mappings | Commands block in `AGENTS.md` | ✅ Complete |
| **4. Hooks** | Git automation | `.scaffolding/scripts/install-hooks.sh` | ✅ Complete |
| **5. Rules** | Guardrails | Service detection, coding conventions | ✅ Complete |

### Key Adaptations

#### 1. Agents Layer
**Claude Code**: Uses `@agent` syntax for delegation  
**OpenCode**: Uses `task()` function with category/subagent selection  

```toml
# Claude Code style
@agent architect "Design the authentication system"

# OpenCode style (AGENTS.md)
task(
  category="deep",
  load_skills=["brainstorming", "systematic-debugging"],
  prompt="Design authentication system",
  run_in_background=false
)
```

#### 2. Skills Layer
**Claude Code**: `.claude/skills/` directory  
**OpenCode**: `.agents/skills/` + `~/.config/opencode/skills/superpowers/`

Both use SKILL.md format (portable across tools).

#### 3. Commands Layer
**Claude Code**: Separate `.claude/commands/` directory  
**OpenCode**: Commands block in `AGENTS.md` (2026 standard)

Rationale: AGENTS.md is the single source of truth for AI agent instructions.

#### 4. Hooks Layer
**Claude Code**: `.claude/hooks/` directory  
**OpenCode**: `.scaffolding/scripts/install-hooks.sh` + git hooks in `.git/hooks/`

Example: Pre-push hook enforces version bump before pushing to main.

#### 5. Rules Layer
**Claude Code**: AgentShield configuration  
**OpenCode**: Service detection protocol + coding conventions in `AGENTS.md`

Example: Prevent google-search calls when API unavailable, use alternatives.

## Implementation Phases

### Phase 1: Foundation (✅ Complete)
- [x] Create `.agents/` directory structure
- [x] Port superpowers skills to OpenCode
- [x] Add Commands block to AGENTS.md
- [x] Implement git hooks (version enforcement)
- [x] Create service detection protocol

### Phase 2: Enhanced Delegation (🔄 Planned)
- [ ] Category-based task routing (quick, deep, ultrabrain, etc.)
- [ ] Skill auto-loading based on task context
- [ ] Bundle system for role-based skill collections

### Phase 3: Full Integration (🔮 Future)
- [ ] Workflow orchestration (multi-step task sequences)
- [ ] Cross-session state persistence
- [ ] Performance monitoring and optimization

## Consequences

### Positive

1. **Battle-tested design**: Claude Code's architecture won a competitive hackathon, proving its effectiveness
2. **Cross-tool compatibility**: Skills and workflows portable across OpenCode, Cursor, Windsurf, Claude
3. **Gradual adoption**: Phased implementation allows incremental benefits
4. **Community alignment**: Following established patterns reduces learning curve

### Negative

1. **Not 1:1 mapping**: OpenCode differences require adaptation (e.g., task() vs @agent)
2. **Implementation effort**: Full feature parity requires significant development
3. **Documentation burden**: Must explain both Claude Code concepts and OpenCode adaptations

### Neutral

1. **Configuration complexity**: Five layers = more files to understand initially
2. **Opinionated structure**: Strong conventions may conflict with user preferences
3. **Maintenance**: Need to track Claude Code updates and adapt relevant changes

## Validation

### Success Criteria

1. ✅ All five layers implemented in OpenCode-compatible form
2. ✅ Skills portable between Claude Code and OpenCode
3. ✅ Git hooks prevent common errors (e.g., missing version bump)
4. ✅ Service detection prevents cryptic API errors
5. 🔄 User feedback confirms improved AI agent reliability

### Metrics

- **Before**: 30% of agent sessions end in confusing errors
- **Target**: <5% error rate, with clear error messages and alternatives

## Related Documents

- [AGENTS.md](../../../AGENTS.md) - Commands and Service Detection Protocol sections
- `.agents/service-detection.md` - Service detection implementation
- [`.scaffolding/docs/service-detection-protocol.md`](https://github.com/matheme-justyn/ai-skill-web/blob/main/docs/service-detection-protocol.md) - User guide
- [`.scaffolding/docs/SKILLS_USAGE_GUIDE.md`](https://github.com/matheme-justyn/ai-skill-web/blob/main/docs/SKILLS_USAGE_GUIDE.md) - Skills system documentation

## References

- [Claude Code Hackathon Winner](https://www.blocktempo.com/hackathon-winner-claude-code-setup/) - Original architecture announcement
- [AGENTS.md 2026 Standard](https://github.com/agentsmd/agents.md) - Cross-tool configuration standard
- [OpenCode Documentation](https://github.com/ohmyopencode/opencode) - OpenCode-specific features

## Revision History

- 2026-03-12: Initial decision - Adapt Claude Code's five-layer architecture to OpenCode
