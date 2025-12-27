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

### CI/CD & Deployment
- **[CI/CD Overview](development-guidelines/ci-cd-overview.md)** - Decision tree for deployment strategy
- **[CI/CD Pipeline Setup](development-guidelines/ci-cd-pipeline-setup.md)** - General pipeline configuration
- **[NuGet Packages](development-guidelines/ci-cd-nuget.md)** - Multi-package repos, publishing workflow
- **[Web Services](development-guidelines/ci-cd-web.md)** - ASP.NET Core, systemd, secrets
- **[Local Applications](development-guidelines/ci-cd-local-apps.md)** - Self-hosted runner, systemd services
- **[Desktop Apps](development-guidelines/ci-cd-desktop.md)** - GitHub Releases, installers

### Project Setup
- **[Repository Setup](development-guidelines/repository-setup.md)** - GitHub repo creation, branch protection, webhooks
- **[Project Structure](development-guidelines/project-structure.md)** - Naming conventions, folders, test organization
- **[Package Management](development-guidelines/package-management.md)** - NuGet workflow, local testing, configuration

### Tools & Operations
- **[GitHub Operations](development-guidelines/github-operations.md)** - gh CLI, issues, PRs, sub-issues
- **[Research Guide](development-guidelines/research-guide.md)** - SearXNG, web search workflow
- **[ht-mcp Terminal](development-guidelines/ht-mcp-terminal.md)** - Terminal operations for restricted environments

## Design & Architecture

- **[SOLID Principles (2025)](solid-principles/solid-principles.md)** - Modern interpretation with Olbrasoft examples
- **[GoF Design Patterns (2025)](design-patterns/gof-design-patterns.md)** - All 23 patterns with current best practices

## For AI Agents

This handbook is optimized for AI agent consumption:
- **Claude Code:** Read [CLAUDE.md](CLAUDE.md) for navigation
- **OpenCode/Agents:** Read [AGENTS.md](AGENTS.md) for navigation
- **Gemini:** Read [GEMINI.md](GEMINI.md) for navigation

Each guide follows consistent structure and includes practical examples from real Olbrasoft projects.

## Contributing

See [Workflow Guide](development-guidelines/workflow.md) for contribution process.

## License

MIT License - see [LICENSE](LICENSE)
