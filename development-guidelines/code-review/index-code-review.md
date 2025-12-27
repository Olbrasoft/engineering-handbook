# Code Review

Standards and processes for reviewing .NET code quality.

## What is Code Review?

**Code review** = Systematic examination of code to find bugs, improve quality, and ensure standards compliance.

**Goal:** Catch issues before merge, maintain code quality, share knowledge.

## Quick Navigation

| Topic | File | What You'll Learn |
|-------|------|-------------------|
| **General Standards** | [general-code-review.md](general-code-review.md) | What to check in any code review |
| **Manual Review** | [manual-review-code-review.md](manual-review-code-review.md) | Step-by-step manual review checklist |
| **Claude Code** | [claude-code-review.md](claude-code-review.md) | `/code-review` command workflow |

## Decision Tree

```
What do I need?
│
├─ "What should I check during code review?"
│  └─ Read: general-code-review.md
│
├─ "How do I manually review code?"
│  └─ Read: manual-review-code-review.md
│
├─ "How to use Claude Code /code-review command?"
│  └─ Read: claude-code-review.md
│
└─ "Overview of code review process"
   └─ Read this file (index)
```

## Code Review Types

### 1. Automated Review (Claude Code)

**Tool:** Claude Code `/code-review` command

**How it works:**
- Runs 4 parallel agents (2x Sonnet, 2x Opus)
- Reviews PR changes automatically
- Posts comments on GitHub PR
- Confidence scoring (threshold 80)

**When to use:**
- Pull requests ready for review
- Before requesting human review
- Automated quality gate

**Read:** [claude-code-review.md](claude-code-review.md)

### 2. Manual Review

**Tool:** Human developer + checklist

**How it works:**
- Follow step-by-step checklist
- Review SOLID principles
- Check design patterns
- Verify test coverage

**When to use:**
- Complex architectural changes
- Security-critical code
- After automated review
- Learning/mentoring

**Read:** [manual-review-code-review.md](manual-review-code-review.md)

## What to Review

### ✅ Always Review

From [general-code-review.md](general-code-review.md):

- **Bugs and logic errors** - Does the code work correctly?
- **Security vulnerabilities** - SQL injection, XSS, secrets in code
- **SOLID principle violations** - SRP, OCP, LSP, ISP, DIP
- **Design pattern misuse** - Singleton abuse, God objects
- **Test coverage** - Are new features tested?
- **Performance issues** - N+1 queries, memory leaks
- **Code duplication** - DRY violations

### ❌ Don't Review (Nitpicks)

- Naming preferences (if already clear)
- Formatting (use linter instead)
- Personal style choices
- Minor optimizations

## Review Process

### Standard Workflow

```
1. Code pushed to branch
   ↓
2. Pull request created
   ↓
3. Automated review (Claude Code /code-review)
   ↓
4. Developer fixes issues
   ↓
5. Manual review (if needed)
   ↓
6. Approval and merge
```

### Claude Code Workflow

```
User runs: /code-review

→ Pre-flight checks (haiku agent)
  - Is PR closed?
  - Is PR draft?
  - Already reviewed?

→ If OK, launch 4 review agents
  - 2x Sonnet (general review)
  - 2x Opus (deep analysis)

→ Agents review in parallel
  - Check SOLID principles
  - Find bugs
  - Security issues
  - Design patterns

→ Post comments to GitHub PR
  - Only high-confidence issues (>80)
  - Specific, actionable feedback
```

## Files in This Directory

| File | Lines | Description |
|------|-------|-------------|
| index-code-review.md | ~200 | This file - overview |
| general-code-review.md | ~250 | Standards for all reviews |
| manual-review-code-review.md | ~200 | Manual review checklist |
| claude-code-review.md | ~300 | Claude Code automation |

## Configuration

Code review standards are defined in project-specific `CLAUDE.md` files.

**Example:** VirtualAssistant project
```
/home/jirka/Olbrasoft/VirtualAssistant/CLAUDE.md
```

Contains:
- Project-specific standards
- Test requirements
- Architecture patterns
- Review checklist

## Integration with Handbook

Code review references:

- **[SOLID Principles](../../solid-principles/solid-principles.md)** - What to check
- **[Design Patterns](../../design-patterns/gof-design-patterns.md)** - Pattern usage
- **[Testing Guide](../testing/index-testing.md)** - Test coverage requirements
- **[Workflow Guide](../workflow.md)** - Git workflow with reviews

## Best Practices

### For Reviewers

1. **Focus on high-signal issues** - Bugs, security, SOLID violations
2. **Be specific** - "This violates SRP" not "This is messy"
3. **Provide examples** - Show how to fix, not just what's wrong
4. **Use confidence scoring** - Only block on >80 confidence issues
5. **Review thoroughly** - Don't rubber-stamp

### For Authors

1. **Self-review first** - Check your own code before PR
2. **Write tests** - Don't make reviewer verify manually
3. **Small PRs** - Easier to review thoroughly
4. **Describe changes** - Clear PR description
5. **Respond to feedback** - Don't argue, discuss and learn

## Common Issues Found

From actual reviews:

| Issue | Example | Fix |
|-------|---------|-----|
| **SRP violation** | Class does DB + business logic | Separate concerns |
| **Missing tests** | New feature has no tests | Add unit tests |
| **SQL injection** | String concatenation in query | Use parameterized queries |
| **Secrets in code** | API key hardcoded | Use environment variables |
| **God object** | 1000-line service class | Split by responsibility |
| **N+1 queries** | Loop with DB calls | Use eager loading |

## When to Skip Review

Skip code review for:

- **Automated PRs** - Dependabot, renovate
- **Documentation only** - README updates, typos
- **Trivial changes** - Version bumps, config
- **Reverts** - Reverting broken commits

**Always review:**
- New features
- Bug fixes
- Refactoring
- Security changes
- Architecture changes

## See Also

- [General Standards](general-code-review.md) - What to check
- [Manual Review](manual-review-code-review.md) - How to review manually
- [Claude Code](claude-code-review.md) - Automated review setup
- [Workflow Guide](../workflow.md) - Git workflow with PR reviews
- [Testing Guide](../testing/index-testing.md) - Test requirements
