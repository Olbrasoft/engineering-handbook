# Engineering Handbook

C# / .NET development standards and reference guides for Olbrasoft projects.

## Quick Start

**New to the handbook?** Start here:
- [Workflow Guide](development-guidelines/workflow.md) - Git, branches, PRs, sub-issues
- [SOLID Principles](solid-principles/solid-principles.md) - Modern interpretation
- [Testing Guide](development-guidelines/testing.md) - Unit tests, mocking, xUnit

## Development Guidelines

### Workflow & Process
- **[Workflow Guide](development-guidelines/workflow.md)** - Git workflow, GitHub issues, branches, commits, sub-issues
- **[Feature Workflow](development-guidelines/feature-workflow.md)** - 7-phase systematic feature implementation
- **[Architecture Design](development-guidelines/architecture-design.md)** - Design trade-offs and decisions
- **[Code Exploration](development-guidelines/code-exploration.md)** - Codebase navigation techniques
- **[Code Review](development-guidelines/code-review/)** - Automated and manual review processes
  - [General Guidelines](development-guidelines/code-review/code-review.md)
  - [Manual Review Checklist](development-guidelines/code-review/manual-review.md)
  - [Claude Code: /code-review command](development-guidelines/code-review/CLAUDE.md)

### Testing
- **[Testing Guide](development-guidelines/testing.md)** - xUnit, Moq, test structure, CI integration

### Continuous Integration & Deployment

**Continuous Integration** (Build & Test):
- **[CI Overview](development-guidelines/continuous-integration/index-continuous-integration.md)** - Build and test automation
- **[Build](development-guidelines/continuous-integration/build-continuous-integration.md)** - .NET build process, multi-targeting
- **[Testing](development-guidelines/continuous-integration/test-continuous-integration.md)** - xUnit, Moq, CI integration

**Continuous Deployment** (Publish & Deploy):
- **[CD Overview](development-guidelines/continuous-deployment/index-continuous-deployment.md)** - Decision tree for deployment strategy
- **[NuGet Packages](development-guidelines/continuous-deployment/nuget-publish-continuous-deployment.md)** - Publishing to NuGet.org
- **[Web Services](development-guidelines/continuous-deployment/web-deploy-continuous-deployment.md)** - ASP.NET Core, systemd, secrets
- **[Local Applications](development-guidelines/continuous-deployment/local-apps-deploy-continuous-deployment.md)** - Self-hosted runner, systemd services
- **[Desktop Apps](development-guidelines/continuous-deployment/desktop-release-continuous-deployment.md)** - GitHub Releases, installers

**Development Workflow**:
- **[Local Package Testing](development-guidelines/local-package-testing.md)** - Test NuGet packages locally before publishing

### Project Setup
- **[Repository Setup](development-guidelines/repository-setup.md)** - GitHub repo creation, branch protection, webhooks
- **[Project Structure](development-guidelines/project-structure.md)** - Naming conventions, folders, test organization
- **[Package Management](development-guidelines/package-management.md)** - NuGet workflow, local testing, configuration

### Tools & Operations
- **[GitHub Operations](development-guidelines/github-operations.md)** - gh CLI, issues, PRs, sub-issues
- **[Research Guide](development-guidelines/research-guide.md)** - SearXNG, web search workflow
- **[ht-mcp Terminal](development-guidelines/ht-mcp-terminal.md)** - Terminal operations for restricted environments

## Design & Architecture

- **[SOLID Principles](solid-principles/solid-principles.md)** - Modern interpretation with Olbrasoft examples
- **[GoF Design Patterns](design-patterns/gof-design-patterns.md)** - All 23 patterns with current best practices

## Repository Structure

This handbook uses **self-descriptive filenames** instead of nested directories:

### General Rule
- **Default:** Single file with descriptive name (e.g., `workflow.md`, `testing.md`)
- Clear, self-documenting filenames
- Flat structure for easy navigation

### Exception: Tool-Specific Capabilities
When a specific tool has **unique capabilities** others don't support, create a directory:
- Main content in `<topic>.md` (applies to all tools)
- Tool-specific instructions in `<TOOL>.md`

**Example:** `code-review/`
- `code-review.md` - General guidelines (all tools)
- `CLAUDE.md` - Claude Code specific: background agents workflow for `/code-review` command
- `manual-review.md` - Manual review checklist

**Rationale:** Claude Code can run parallel background agents for code review, other tools cannot.

## Contributing

See [Workflow Guide](development-guidelines/workflow.md) for contribution process.

## License

MIT License - see [LICENSE](LICENSE)
