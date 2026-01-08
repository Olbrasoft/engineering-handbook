# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Engineering Handbook - C#/.NET development standards and reference guides for Olbrasoft projects. This is a **documentation-only repository** with no code to build or test.

## Repository Purpose

This handbook provides standards for:
- Git workflow, branching, commits, sub-issues
- .NET project structure and naming conventions
- Testing with xUnit + Moq
- CI/CD pipelines and deployment
- SOLID principles and design patterns
- Code review guidelines

## Navigation

**Entry points by task:**

| Task | Start Here |
|------|------------|
| Git workflow, branches, commits | [git-workflow-workflow.md](development-guidelines/workflow/git-workflow-workflow.md) |
| Feature development (7-phase) | [feature-development-workflow.md](development-guidelines/workflow/feature-development-workflow.md) |
| .NET project structure | [project-structure-dotnet.md](development-guidelines/dotnet/project-structure-dotnet.md) |
| Testing (xUnit, Moq) | [index-testing.md](development-guidelines/dotnet/testing/index-testing.md) |
| CI/CD for NuGet packages | [nuget-publish-continuous-deployment.md](development-guidelines/dotnet/continuous-deployment/nuget-publish-continuous-deployment.md) |
| CI/CD for web services | [web-deploy-continuous-deployment.md](development-guidelines/dotnet/continuous-deployment/web-deploy-continuous-deployment.md) |
| SOLID principles | [solid-principles.md](development-guidelines/dotnet/solid-principles/solid-principles.md) |
| Design patterns (GoF) | [gof-patterns-design-patterns.md](development-guidelines/dotnet/design-patterns/gof-patterns-design-patterns.md) |
| Code review | [index-code-review.md](development-guidelines/code-review/index-code-review.md) |
| Secrets management | [secrets-management.md](development-guidelines/secrets-management.md) |

## File Naming Convention

All files follow strict naming patterns - see [file-naming-contributing.md](contributing/file-naming-contributing.md):

- **Index files:** `index-{directory-name}.md` (e.g., `index-testing.md`)
- **Topic files in directories:** `{topic}-{directory-name}.md` (e.g., `unit-tests-testing.md`)
- **Full words only** - never abbreviations (`continuous-integration` not `ci`)
- **Action verbs** for procedures (`nuget-publish` not `nuget`)

## Key Standards for Olbrasoft Projects

**From [AGENTS.md](AGENTS.md):**

```bash
# Build
dotnet build -c Release

# Run all tests
dotnet test

# Run single test
dotnet test --filter "FullyQualifiedName~MyTestMethod"
```

| Standard | Value |
|----------|-------|
| Target Framework | .NET 10 (`net10.0`) |
| Root Namespace | `Olbrasoft.{Domain}.{Layer}` |
| Testing | xUnit + Moq |
| Nullable | Enabled |

**Folder vs Namespace:** Folders have NO `Olbrasoft.` prefix, namespaces YES.

**NuGet versioning:** Olbrasoft packages use floating versions (`10.*`), third-party use exact.

## Before Commit & Push - IMPORTANT

This repository has **automatic HandbookSearch integration**. When you push changes to `.md` files, GitHub Actions automatically imports them into the HandbookSearch database with embeddings.

### Pre-push Checklist

**1. Verify Ollama is running** (required for embeddings):
```bash
curl -s http://localhost:11434/api/tags | jq '.models[].name'
# Should show: qwen3-embedding:0.6b
```

**2. Verify GitHub Actions runners are running:**
```bash
ps aux | grep "Runner.Listener" | grep -v grep
# Should show: actions-runner-engineering-handbook and actions-runner-handbook-search
```

**3. After push - monitor GitHub Actions:**
- Go to: https://github.com/Olbrasoft/engineering-handbook/actions
- Check "Update Handbook Embeddings" workflow
- Verify all changed `.md` files are imported successfully

### What Happens on Push

1. GitHub Actions detects changed `.md` files
2. Self-hosted runner (`handbook-search`) processes files
3. Ollama generates embeddings (EN + CS translation)
4. Embeddings are stored in PostgreSQL (pgvector)
5. Files become searchable in HandbookSearch

### Troubleshooting

If workflow fails:
- Check Ollama: `curl http://localhost:11434/api/tags`
- Check runner logs: `journalctl --user -u actions.runner.* -f`
- Check HandbookSearch CLI: `/opt/olbrasoft/handbook-search/cli/HandbookSearch.Cli --help`

## Contributing to This Handbook

When adding/editing documentation:

1. Follow [file-naming-contributing.md](contributing/file-naming-contributing.md) for naming
2. Follow [structure-contributing.md](contributing/structure-contributing.md) for content structure
3. Follow [style-guide-contributing.md](contributing/style-guide-contributing.md) for writing style
4. Keep files 80-250 lines, focused on ONE topic
5. Examples first, explanations after
6. Update parent index files and README.md navigation
