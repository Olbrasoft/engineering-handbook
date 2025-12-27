# Workflow

Development workflow for .NET projects: Git, GitHub, feature development, and operations.

## Overview

This section covers the complete development workflow from issue creation to deployment:

- **Git Workflow** - Issues, branches, commits, pull requests
- **Feature Development** - Systematic 7-phase process for building features
- **GitHub Operations** - GitHub API operations, pagination, MCP server tools

## Quick Start

### For New Tasks

1. **Create Issue** → Define WHAT and WHY (not HOW)
2. **Create Branch** → `feature/issue-N-description` or `fix/issue-N-description`
3. **Follow Feature Workflow** → 7 phases for complex features
4. **Commit Frequently** → After each significant change
5. **Create PR** → When feature is complete and tests pass
6. **Code Review** → Get approval
7. **Merge & Deploy** → Close issue after deployment

See: [Git Workflow](git-workflow-workflow.md) for complete guide.

### For Feature Development

Follow systematic 7-phase process:

1. **Requirements Analysis** - Understand WHAT to build
2. **Architecture Design** - Design HOW to build it
3. **Implementation** - Build the code
4. **Testing** - Verify it works
5. **Integration** - Connect with existing systems
6. **Documentation** - Document usage
7. **Review & Deploy** - Final checks and deployment

See: [Feature Development Workflow](feature-development-workflow.md) for detailed process.

## File Index

### Core Workflow
- **[git-workflow-workflow.md](git-workflow-workflow.md)** - Complete Git workflow: issues, branches, commits, testing, deployment, secrets

### Specialized Workflows
- **[feature-development-workflow.md](feature-development-workflow.md)** - Systematic 7-phase process for building new features

### GitHub Operations
- **[github-operations-workflow.md](github-operations-workflow.md)** - GitHub API operations, pagination, MCP server tools

## Common Scenarios

### Starting New Feature

```bash
# 1. Create issue on GitHub
gh issue create --title "Add user authentication" --body "..."

# 2. Create branch
git checkout -b feature/issue-123-user-auth

# 3. Follow feature development workflow (7 phases)
# See: feature-development-workflow.md

# 4. Commit and push frequently
git add .
git commit -m "Add authentication service"
git push -u origin feature/issue-123-user-auth

# 5. Create PR when ready
gh pr create --title "Add user authentication" --body "Closes #123"
```

See: [Git Workflow](git-workflow-workflow.md#github-issues) for issue templates.

### Fixing Bug

```bash
# 1. Create issue for bug
gh issue create --title "Fix login validation" --label bug

# 2. Create fix branch
git checkout -b fix/issue-124-login-validation

# 3. Fix the bug
# (Make changes)

# 4. Test the fix
dotnet test

# 5. Commit and push
git commit -am "Fix login validation bug"
git push -u origin fix/issue-124-login-validation

# 6. Create PR
gh pr create --title "Fix login validation" --body "Closes #124"
```

See: [Git Workflow](git-workflow-workflow.md#branch-naming) for branch naming conventions.

### Using GitHub API

When working with GitHub API (via MCP server or gh CLI):

```bash
# List issues with pagination
gh issue list --limit 10

# Search issues
gh issue list --search "label:bug state:open" --limit 20

# View PR details
gh pr view 123

# Add sub-issue
# See: github-operations-workflow.md for MCP server examples
```

**CRITICAL:** Always use pagination (`--limit`, `perPage`) to prevent context overflow.

See: [GitHub Operations](github-operations-workflow.md) for complete API guide.

## Best Practices

### Issue Management

✅ **DO:**
- Create issue immediately for every task
- Use clear title (WHAT + WHY in one sentence)
- Use sub-issues for task breakdown (NOT checkboxes)
- Label issues properly (`feature`, `bug`, `enhancement`)

❌ **DON'T:**
- Start coding without issue
- Use vague titles like "Fix stuff"
- Use checkboxes for task tracking (use sub-issues)

### Branch Management

✅ **DO:**
- One branch per issue
- Descriptive names: `feature/issue-N-description`
- Commit and push frequently
- Keep branches short-lived

❌ **DON'T:**
- Reuse branches for multiple issues
- Use generic names like `dev`, `test`
- Wait days before pushing

### Commit Management

✅ **DO:**
- Commit after each significant change
- Write descriptive messages
- Push frequently (daily minimum)
- Include `Closes #N` in PR description

❌ **DON'T:**
- Massive commits with many changes
- Vague messages like "Update"
- Keep changes local for days

## Integration with CI/CD

Workflow integrates with CI/CD pipeline:

1. **Push to branch** → CI runs tests
2. **Create PR** → CI runs full build + test
3. **Merge to main** → CD deploys to production

See: [Continuous Integration](../dotnet/continuous-integration/index-continuous-integration.md) for CI setup.

## Secrets Management

**CRITICAL:** Never commit secrets!

- **Development:** User secrets (`dotnet user-secrets`)
- **Production:** Environment variables (systemd, Docker)
- **Catalog:** `~/Dokumenty/přístupy/api-keys.md`

See: [Git Workflow - Secrets](git-workflow-workflow.md#secrets-management) for complete guide.

## Next Steps

Choose your workflow guide:

- **[Git Workflow →](git-workflow-workflow.md)** - Complete workflow from issue to deployment
- **[Feature Development →](feature-development-workflow.md)** - Systematic feature development process
- **[GitHub Operations →](github-operations-workflow.md)** - GitHub API operations and tools

## See Also

- [Testing Guide](../dotnet/testing/index-testing.md) - Test before committing
- [Code Review](../code-review/index-code-review.md) - Review before merging
- [Continuous Integration](../dotnet/continuous-integration/index-continuous-integration.md) - CI/CD setup
- [Continuous Deployment](../dotnet/continuous-deployment/index-continuous-deployment.md) - Deployment workflows
