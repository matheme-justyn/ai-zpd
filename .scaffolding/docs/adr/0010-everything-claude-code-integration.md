# ADR 0010: Everything-Claude-Code Architecture Integration

## Status

Accepted

## Context

### Background

We identified the need to enhance our AI-driven scaffolding system with proven architectural patterns from the Claude Code hackathon winner ([everything-claude-code](https://github.com/affaan-m/everything-claude-code) by Affaan Memon).

The everything-claude-code (ECC) project won Anthropic's Claude Code hackathon by implementing a sophisticated five-layer architecture:

1. **Agents** - Specialized AI agents for delegation
2. **Skills** - Reusable prompt modules for specific domains
3. **Commands** - Task-specific workflows combining agents and skills
4. **Rules** - Behavioral constraints and guardrails
5. **AgentShield** - Security layer preventing configuration vulnerabilities

### Problem Statement

Our existing scaffolding system (v1.13.0) lacked:
- Structured task delegation patterns
- Reusable skill modules
- Systematic security guardrails
- Command-based workflow orchestration

This resulted in:
- Inconsistent AI behavior across sessions
- Repeated context loading for common tasks
- No standardized security review process
- Limited scalability for complex projects

### Requirements

From PRD analysis, we needed to:
1. Integrate proven architectural patterns
2. Maintain OpenCode compatibility (not Claude Desktop)
3. Complement existing superpowers skills (not replace)
4. Implement within 2026-Q1 timeline
5. Achieve production-ready quality

## Decision

### What We Imported (Phase 1 - Immediate)

#### 1.1 Specialized Agents (5 agents)

**Rationale**: High value (4.3/5), medium complexity, immediate benefit

**Implementation**:
- `planner` - Task planning and breakdown
- `architect` - System architecture design
- `tdd-guide` - TDD workflow guidance
- `code-reviewer` - Code quality review
- `security-reviewer` - Security vulnerability scanning

**Adaptation**: Added OpenCode integration instructions to each agent definition.

**Files Created**: 
- `.agents/agents/*.md` (5 files)
- `.agents/agents/README.md`

#### 1.2 Core Skills (15 skills)

**Rationale**: Very high value (4.5/5), medium complexity

**Implementation**:
- **5 Universal**: api-design, security-review, tdd-workflow, coding-standards, verification-loop
- **3 Backend**: backend-patterns, database-optimization, error-handling
- **3 Frontend**: frontend-patterns, react-hooks, component-design
- **2 Testing**: e2e-testing, unit-testing
- **2 Other**: content-engine, market-research

**Adaptation**: 
- Organized by domain (universal/backend/frontend/testing/other)
- Added OpenCode Integration sections
- Complemented with existing superpowers skills

**Files Created**: 
- `.agents/skills/*/*.md` (15 files across 5 directories)
- `.agents/skills/README.md`

#### 1.3 Essential Commands (10 commands)

**Rationale**: High value (4.0/5), high impact

**Implementation**:
- **Downloaded (5)**: plan, code-review, build-fix, e2e, checkpoint
- **Created (5)**: test-all, security-scan, analyze, refactor, document

**Adaptation**: Commands work as reference files for OpenCode (no slash command syntax needed)

**Files Created**: 
- `.agents/commands/*.md` (10 files)
- `.agents/commands/README.md`

#### 1.4 Common Rules (4 categories, 60 rules)

**Rationale**: Very high value (4.75/5), low complexity

**Implementation**:
- `git-rules.md` - 11 rules (commit conventions, branching, merging)
- `testing-rules.md` - 16 rules (TDD, coverage, test quality)
- `security-rules.md` - 13 rules (prevent vulnerabilities, secure coding)
- `code-style-rules.md` - 20 rules (naming, formatting, consistency)

**Adaptation**: Added severity levels (🔴 CRITICAL, 🟠 HIGH, 🟡 MEDIUM, 🟢 LOW)

**Files Created**: 
- `.agents/rules/*.md` (4 files)
- `.agents/rules/README.md`

#### 1.5 AgentShield Integration (Simplified)

**Rationale**: High security value (3.75/5), medium complexity

**Implementation**: Simplified 5-category framework instead of full 102 rules
- File Operations (Critical)
- Command Execution (Critical)
- External Services (High)
- Code Modification (Medium)
- Data Access (Medium)

**Rationale for Simplification**: 
- Full 102 rules would exceed token budget
- Core security concerns covered by 5 categories
- Original repository available for reference

**Files Created**: 
- `.agents/agentshield/README.md`

### What We Deferred (Phase 2 - Q2 2026)

**Continuous Learning v2**:
- **Reason**: Requires OpenCode hooks maturity
- **Timeline**: After OpenCode 1.0 stable release

**Advanced Memory System**:
- **Reason**: Complex implementation, high risk
- **Timeline**: After Phase 1 validation in production

**PM2 Multi-Agent**:
- **Reason**: Limited use cases in our target audience
- **Timeline**: On-demand if user requests

### What We Rejected

**Skill Creator**:
- **Reason**: Quality uncontrollable, risks low-quality skill proliferation
- **Decision**: Manual skill curation only

**NanoClaw**:
- **Reason**: Redundant with existing OpenCode tools
- **Decision**: Use native OpenCode capabilities

**Codex CLI Support**:
- **Reason**: Not our target audience (we target VSCode users)
- **Decision**: Focus on OpenCode/VSCode integration

## Consequences

### Positive

1. **Structured AI Workflows**: Agents, skills, and commands provide clear task patterns
2. **Reusable Expertise**: 15 skills encode best practices across domains
3. **Security First**: Rules and AgentShield prevent common vulnerabilities
4. **Scalability**: Architecture supports complex multi-agent workflows
5. **Proven Patterns**: Based on hackathon-winning architecture

### Negative

1. **Increased Complexity**: 5 new architectural layers to maintain
2. **Learning Curve**: Users must understand agents/skills/commands distinction
3. **Token Overhead**: Large context windows needed for full system
4. **Maintenance Burden**: 35+ files to keep updated

### Mitigations

1. **Documentation**: Comprehensive READMEs for each layer
2. **Examples**: Usage examples in each file
3. **Gradual Adoption**: Users can adopt layers incrementally
4. **Simplification**: Simplified AgentShield vs. full 102 rules

## Implementation Details

### File Structure

```
.agents/
├── agents/          # 5 specialized agents
│   ├── planner.md
│   ├── architect.md
│   ├── tdd-guide.md
│   ├── code-reviewer.md
│   ├── security-reviewer.md
│   └── README.md
├── skills/          # 15 skill modules
│   ├── universal/   # 5 files
│   ├── backend/     # 3 files
│   ├── frontend/    # 3 files
│   ├── testing/     # 2 files
│   ├── other/       # 2 files
│   └── README.md
├── commands/        # 10 commands
│   ├── plan.md
│   ├── code-review.md
│   ├── build-fix.md
│   ├── e2e.md
│   ├── checkpoint.md
│   ├── test-all.md
│   ├── security-scan.md
│   ├── analyze.md
│   ├── refactor.md
│   ├── document.md
│   └── README.md
├── rules/           # 4 rule categories (60 rules)
│   ├── git-rules.md
│   ├── testing-rules.md
│   ├── security-rules.md
│   ├── code-style-rules.md
│   └── README.md
└── agentshield/     # Simplified security framework
    └── README.md
```

### AGENTS.md Integration

Added 2 new major sections:
1. **Specialized Agents** (line 254) - Agent system overview
2. **Core Skills System** (line 426) - Skills usage guide
3. **AI Development Commands** (line 612) - Commands reference

### Version Impact

- **From**: v1.14.0 (template sync + service detection)
- **To**: v1.15.0 (everything-claude-code integration)
- **Breaking Changes**: None (additive only)
- **Migration**: Existing projects continue working, new features opt-in

## Alternatives Considered

### Alternative 1: Full Everything-Claude-Code Fork

**Pros**: Get all 102 AgentShield rules, continuous learning, advanced memory

**Cons**: 
- Incompatible with OpenCode (designed for Claude Desktop)
- Would require massive refactoring
- Maintenance burden too high

**Decision**: Rejected - Adapt core patterns only

### Alternative 2: Build from Scratch

**Pros**: Complete control, tailored to our needs

**Cons**: 
- Reinventing the wheel
- No proven track record
- Higher risk of design flaws

**Decision**: Rejected - Leverage proven architecture

### Alternative 3: Minimal Integration (Agents Only)

**Pros**: Lowest complexity, easiest to maintain

**Cons**: 
- Miss out on skills, commands, rules synergy
- Limited value compared to full system

**Decision**: Rejected - Five-layer architecture is most valuable as a complete system

## Success Metrics

### Quantitative

- ✅ 5 agents created and documented
- ✅ 15 skills created and organized
- ✅ 10 commands created
- ✅ 60 rules defined across 4 categories
- ✅ AgentShield framework established
- ✅ All documentation complete (5 README files)
- ✅ AGENTS.md updated with 3 new sections

### Qualitative

- **Code Quality**: Rules enforce consistent standards
- **Security**: AgentShield + security rules prevent vulnerabilities
- **Maintainability**: Skills provide reusable patterns
- **Collaboration**: Agents enable task delegation
- **Scalability**: Architecture supports complex workflows

### Future Validation

- **Q2 2026**: User adoption metrics (which agents/skills used most)
- **Q3 2026**: Security incident rate (should decrease)
- **Q4 2026**: Code quality metrics (complexity, test coverage)

## References

- **Source**: https://github.com/affaan-m/everything-claude-code
- **Article**: https://www.blocktempo.com/hackathon-winner-claude-code-setup-revealed/
- **PRD**: `docs/PRD-claude-code-inspired-upgrades.md`
- **Previous ADR**: [ADR 0009: Reference Claude Code Architecture](./0009-reference-claude-code-architecture.md)

## Date

2025-03-12

## Author

AI Agent (Sisyphus) via OpenCode

---

**Implementation Status**: ✅ Complete  
**Next Steps**: Update README with Advanced AI Agent Features section
