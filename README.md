# Engineering Handbook

C# / .NET development standards and reference guides for Olbrasoft projects.

## Quick Start

**New to the handbook?** Start here:
- [Workflow Guide](development-guidelines/workflow/index-workflow.md) - Git, branches, PRs, sub-issues
- [SOLID Principles](solid-principles/solid-principles.md) - Modern interpretation
- [Testing Guide](development-guidelines/testing/index-testing.md) - Unit tests, integration tests, xUnit

## Development Guidelines

### Workflow & Process
- **[Workflow Index](development-guidelines/workflow/index-workflow.md)** - Overview and quick start
- **[Git Workflow](development-guidelines/workflow/git-workflow-workflow.md)** - Git workflow, GitHub issues, branches, commits, sub-issues
- **[Feature Development](development-guidelines/workflow/feature-development-workflow.md)** - 7-phase systematic feature implementation
- **[GitHub Operations](development-guidelines/workflow/github-operations-workflow.md)** - GitHub API operations, pagination
### Architecture
- **[Architecture Index](development-guidelines/architecture/index-architecture.md)** - Overview
- **[Architecture Design](development-guidelines/architecture/architecture-design-architecture.md)** - Design trade-offs and decisions
- **[Code Exploration](development-guidelines/architecture/code-exploration-architecture.md)** - Codebase navigation techniques
- **[Code Review](development-guidelines/code-review/)** - Automated and manual review processes
  - [General Guidelines](development-guidelines/code-review/code-review.md)
  - [Manual Review Checklist](development-guidelines/code-review/manual-review.md)
  - [Claude Code: /code-review command](development-guidelines/code-review/CLAUDE.md)

### Testing
- **[Testing Index](development-guidelines/testing/index-testing.md)** - Overview, decision tree
- **[Unit Tests](development-guidelines/testing/unit-tests-testing.md)** - xUnit, Moq, in-memory DB
- **[Integration Tests](development-guidelines/testing/integration-tests-testing.md)** - [SkipOnCIFact], real services

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
- **[Local Package Testing](development-guidelines/package-management/local-testing-package-management.md)** - Test NuGet packages locally before publishing

### Project Setup
- **[Project Setup Index](development-guidelines/project-setup/index-project-setup.md)** - Overview and quick start
- **[Repository Setup](development-guidelines/project-setup/repository-setup-project-setup.md)** - GitHub repo creation, branch protection, webhooks
- **[Project Structure](development-guidelines/project-setup/project-structure-project-setup.md)** - Naming conventions, folders, test organization

### Package Management
- **[Package Management Index](development-guidelines/package-management/index-package-management.md)** - Overview and quick start
- **[Local Testing](development-guidelines/package-management/local-testing-package-management.md)** - Test NuGet packages locally before publishing
- **[Package Overview](development-guidelines/package-management/overview-package-management.md)** - Complete guide: configuration, versioning, deployment

### Tools
- **[Tools Index](development-guidelines/tools/index-tools.md)** - Overview
- **[Research Guide](development-guidelines/tools/research-guide-tools.md)** - SearXNG, web search workflow
- **[HT Terminal](development-guidelines/tools/ht-terminal-tools.md)** - Terminal operations for restricted environments
- **[CLAUDE.md Template](development-guidelines/tools/claude-template-tools.md)** - Project configuration template

## Design & Architecture

### Design Principles
- **[SOLID Principles](solid-principles/solid-principles.md)** - Modern interpretation with Olbrasoft examples

### Design Patterns
- **[Design Patterns Index](design-patterns/index-design-patterns.md)** - Overview and pattern catalog navigation
- **[GoF Patterns](design-patterns/gof-patterns-design-patterns.md)** - 23 classic Gang of Four patterns
- **[Enterprise Patterns](design-patterns/enterprise-patterns-design-patterns.md)** - Martin Fowler's enterprise application patterns
- **[Microservices Patterns](design-patterns/microservices-patterns-design-patterns.md)** - Saga, CQRS, Event Sourcing, API Gateway
- **[Cloud Patterns](design-patterns/cloud-patterns-design-patterns.md)** - Retry, Circuit Breaker, Bulkhead, resilience patterns
- **[Architectural Patterns](design-patterns/architectural-patterns-design-patterns.md)** - Clean Architecture, Hexagonal, Layered, Event-Driven

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

See [Workflow Guide](development-guidelines/workflow/index-workflow.md) for contribution process.

## License

MIT License - see [LICENSE](LICENSE)
