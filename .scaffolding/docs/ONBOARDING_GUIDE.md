# ONBOARDING_GUIDE

**Status**: Active | Domain: Collaboration  
**Related Modules**: README_STRUCTURE, TROUBLESHOOTING, SCAFFOLDING_DEV_GUIDE

## Purpose

This module provides guidance for creating effective onboarding documentation for new team members. It covers technical setup, codebase orientation, development workflows, and cultural integration.

## When to Use This Module

Reference this module when:
- Onboarding new developers
- Creating team documentation
- Standardizing development environment setup
- Documenting team processes and conventions
- Improving new hire experience

## Onboarding Checklist

### Day 1: Setup

- [ ] Hardware and accounts provisioned
- [ ] Access to repositories granted
- [ ] Development environment set up
- [ ] First build successful
- [ ] Tests running locally
- [ ] IDE configured with team settings

### Week 1: Orientation

- [ ] Codebase walkthrough completed
- [ ] Architecture documentation reviewed
- [ ] Development workflow understood
- [ ] First small PR merged
- [ ] Team meetings attended

### Month 1: Productivity

- [ ] First feature completed
- [ ] Code review process familiar
- [ ] Deployment process understood
- [ ] Team conventions internalized

## Technical Setup Guide

### Prerequisites

```markdown
## Required Software

Install these before starting:

1. **Git** (v2.30+)
   ```bash
   # macOS
   brew install git
   
   # Ubuntu
   sudo apt install git
   ```

2. **Node.js** (v18+)
   ```bash
   # Using nvm (recommended)
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
   nvm install 18
   nvm use 18
   ```

3. **Docker** (v20+)
   - Download from [docker.com](https://www.docker.com/products/docker-desktop)

4. **VS Code** (recommended)
   - Download from [code.visualstudio.com](https://code.visualstudio.com/)
   - Install extensions: ESLint, Prettier, GitLens
```

### Environment Setup

```markdown
## Development Environment

1. Clone repository:
   ```bash
   git clone https://github.com/company/project.git
   cd project
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Copy environment template:
   ```bash
   cp .env.example .env
   ```

4. Configure environment variables:
   ```bash
   # Required variables
   DATABASE_URL=postgresql://localhost:5432/myapp_dev
   REDIS_URL=redis://localhost:6379
   API_KEY=ask-your-team-lead
   ```

5. Start services:
   ```bash
   docker-compose up -d
   ```

6. Run migrations:
   ```bash
   npm run migrate
   ```

7. Seed database (optional):
   ```bash
   npm run seed
   ```

8. Start development server:
   ```bash
   npm run dev
   ```

9. Verify setup:
   - Open http://localhost:3000
   - Run `npm test`
   - Check all tests pass
```

## Codebase Tour

```markdown
## Project Structure

```
my-project/
├── src/
│   ├── api/           # REST API endpoints
│   ├── models/        # Database models
│   ├── services/      # Business logic
│   ├── utils/         # Helper functions
│   └── types/         # TypeScript types
├── tests/
│   ├── unit/          # Unit tests
│   ├── integration/   # Integration tests
│   └── e2e/           # End-to-end tests
├── docs/              # Documentation
├── scripts/           # Build and utility scripts
└── .github/           # GitHub workflows
```

## Key Files

* **src/api/routes.ts** - API route definitions
* **src/models/user.ts** - User model (good example of model structure)
* **src/services/auth.ts** - Authentication logic (important to understand)
* **src/utils/logger.ts** - Logging utility (use this everywhere)

## Important Patterns

### Error Handling

We use custom error classes:

```typescript
import { AppError } from './utils/errors';

// Throw errors like this
if (!user) {
  throw new AppError('User not found', 404);
}
```

### Database Queries

Always use parameterized queries:

```typescript
// ✅ Good
const user = await db.query('SELECT * FROM users WHERE id = $1', [userId]);

// ❌ Bad
const user = await db.query(`SELECT * FROM users WHERE id = '${userId}'`);
```

### Async/Await

Prefer async/await over promises:

```typescript
// ✅ Good
async function getUser(id: string): Promise<User> {
  const user = await db.users.findById(id);
  return user;
}

// ❌ Bad
function getUser(id: string): Promise<User> {
  return db.users.findById(id).then(user => user);
}
```
```

## Development Workflow

```markdown
## Daily Workflow

1. **Start your day**:
   ```bash
   git pull origin main
   npm install  # If package.json changed
   docker-compose up -d
   npm run dev
   ```

2. **Create feature branch**:
   ```bash
   git checkout -b feature/my-feature
   ```

3. **Write code**:
   - Write tests first (TDD)
   - Run tests: `npm test`
   - Run linter: `npm run lint`

4. **Commit changes**:
   ```bash
   git add .
   git commit -m "feat: add user profile page"
   ```

5. **Push and create PR**:
   ```bash
   git push origin feature/my-feature
   # Create PR on GitHub
   ```

6. **Address review feedback**:
   - Make changes
   - Push again
   - Request re-review

7. **After merge**:
   ```bash
   git checkout main
   git pull origin main
   git branch -d feature/my-feature
   ```

## Commit Message Format

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): brief description

[optional body]

[optional footer]
```

Types:
* `feat`: New feature
* `fix`: Bug fix
* `docs`: Documentation
* `refactor`: Code refactoring
* `test`: Adding tests
* `chore`: Maintenance

Examples:
```
feat(auth): add password reset functionality
fix(api): resolve null pointer in user endpoint
docs(readme): update installation instructions
```
```

## Common Tasks

### Running Tests

```bash
# All tests
npm test

# Specific test file
npm test -- user.test.ts

# Watch mode
npm test -- --watch

# Coverage
npm test -- --coverage
```

### Database Operations

```bash
# Create migration
npm run migration:create add_email_column

# Run migrations
npm run migrate

# Rollback migration
npm run migrate:down

# Reset database
npm run db:reset
```

### Debugging

```bash
# Start with debugger
npm run debug

# VS Code launch configuration
# Already configured in .vscode/launch.json
# Press F5 to start debugging
```

## Team Conventions

```markdown
## Code Style

* Use TypeScript strict mode
* 2 spaces for indentation
* Single quotes for strings
* Semicolons required
* Max line length: 100 characters

Enforced by ESLint and Prettier (runs automatically on save).

## Pull Request Guidelines

1. **Size**: Keep PRs under 400 lines
2. **Description**: Use PR template
3. **Tests**: All code must have tests
4. **Reviews**: Require 2 approvals
5. **Checks**: All CI checks must pass

## Code Review Process

As a **reviewer**:
* Be kind and constructive
* Ask questions, don't demand
* Approve if minor issues (can fix later)
* Block if major issues or tests failing

As an **author**:
* Respond to all comments
* Ask for clarification if unsure
* Don't take feedback personally
* Thank reviewers

## Communication

* **Slack**: Daily communication
  * #engineering - Technical discussions
  * #random - Casual chat
  * @mention for urgent issues

* **Stand-ups**: Daily at 10am (15 minutes)
  * What you did yesterday
  * What you're doing today
  * Any blockers

* **Sprint Planning**: Every 2 weeks
  * Review previous sprint
  * Plan next sprint

* **Retrospectives**: Every 2 weeks
  * What went well
  * What could improve
  * Action items
```

## Resources

```markdown
## Internal Documentation

* `docs/ARCHITECTURE.md`
* `docs/API.md`
* `docs/DATABASE.md`
* `docs/DEPLOYMENT.md`

## External Resources

* [TypeScript Handbook](https://www.typescriptlang.org/docs/)
* [React Documentation](https://react.dev/)
* [PostgreSQL Documentation](https://www.postgresql.org/docs/)

## Getting Help

* Ask in #engineering Slack channel
* Pair programming: Book time with senior developers
* Weekly office hours: Fridays 2-4pm
* Documentation bugs: Open PR to fix them
```

## First Tasks

```markdown
## Starter Tasks

Good first issues for new team members:

1. **Fix a typo** - Get familiar with PR process
2. **Add tests** - Learn testing patterns
3. **Update documentation** - Understand codebase
4. **Implement small feature** - End-to-end workflow

See issues labeled `good-first-issue` on GitHub.
```

## Related Modules

- **README_STRUCTURE** - Project documentation
- **TROUBLESHOOTING** - Common issues and solutions
- **SCAFFOLDING_DEV_GUIDE** - Template development guide
