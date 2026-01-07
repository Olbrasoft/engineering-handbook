# Engineering Handbook

C# / .NET development standards and reference guides for Olbrasoft projects.

## Quick Start

**New to the handbook?** Start here:
- [Workflow Guide](development-guidelines/workflow/index-workflow.md) - Git, branches, PRs, sub-issues
- [SOLID Principles](development-guidelines/dotnet/solid-principles/solid-principles.md) - Modern interpretation
- [Testing Guide](development-guidelines/dotnet/testing/index-testing.md) - Unit tests, integration tests, xUnit

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
- **[Code Review](development-guidelines/code-review/index-code-review.md)** - Automated and manual review processes
  - [General Guidelines](development-guidelines/code-review/general-code-review.md)
  - [Manual Review Checklist](development-guidelines/code-review/manual-review-code-review.md)
  - [Claude Code: /code-review command](development-guidelines/code-review/CLAUDE.md)

### Configuration & Secrets
- **[Configuration Management](development-guidelines/configuration-management.md)** - Managing prompts, templates, and config data
- **[Secrets Management](development-guidelines/secrets-management.md)** - API keys, passwords, environment variables

### Tools
- **[Tools Index](development-guidelines/tools/index-tools.md)** - Overview
- **[Research Guide](development-guidelines/tools/research-guide-tools.md)** - SearXNG, web search workflow
- **[HT Terminal](development-guidelines/tools/ht-terminal-tools.md)** - Terminal operations for restricted environments

### Project Setup
- **[Project Setup Index](development-guidelines/project-setup/index-project-setup.md)** - Overview and quick start
- **[Repository Setup](development-guidelines/project-setup/repository-setup-project-setup.md)** - GitHub repo creation, branch protection, webhooks
- **[Project Config](development-guidelines/project-setup/project-config-project-setup.md)** - CLAUDE.md template for AI assistant configuration

## .NET Development

All .NET-specific content is organized under **[.NET Guidelines](development-guidelines/dotnet/index-dotnet.md)**.

### Quick Links

| Topic | Description |
|-------|-------------|
| **[.NET Index](development-guidelines/dotnet/index-dotnet.md)** | Overview, standards, namespace conventions |
| **[Project Structure](development-guidelines/dotnet/project-structure-dotnet.md)** | Naming conventions, folders, test organization |
| **[Layered Naming](development-guidelines/dotnet/layered-naming-dotnet.md)** | Multi-layered app naming (Blog example) |

### Testing
- **[Testing Index](development-guidelines/dotnet/testing/index-testing.md)** - Overview, decision tree
- **[Unit Tests](development-guidelines/dotnet/testing/unit-tests-testing.md)** - xUnit, Moq, in-memory DB
- **[Integration Tests](development-guidelines/dotnet/testing/integration-tests-testing.md)** - [SkipOnCIFact], real services

### Continuous Integration & Deployment

**Continuous Integration** (Build & Test):
- **[CI Overview](development-guidelines/dotnet/continuous-integration/index-continuous-integration.md)** - Build and test automation
- **[Build](development-guidelines/dotnet/continuous-integration/build-continuous-integration.md)** - .NET build process, multi-targeting
- **[Testing](development-guidelines/dotnet/continuous-integration/test-continuous-integration.md)** - xUnit, Moq, CI integration

**Continuous Deployment** (Publish & Deploy):
- **[CD Overview](development-guidelines/dotnet/continuous-deployment/index-continuous-deployment.md)** - Decision tree for deployment strategy
- **[NuGet Packages](development-guidelines/dotnet/continuous-deployment/nuget-publish-continuous-deployment.md)** - Publishing to NuGet.org
- **[Web Services](development-guidelines/dotnet/continuous-deployment/web-deploy-continuous-deployment.md)** - ASP.NET Core, systemd, secrets
- **[Local Applications](development-guidelines/dotnet/continuous-deployment/local-apps-deploy-continuous-deployment.md)** - Self-hosted runner, systemd services
- **[Desktop Apps](development-guidelines/dotnet/continuous-deployment/desktop-release-continuous-deployment.md)** - GitHub Releases, installers

### Package Management
- **[Package Management Index](development-guidelines/dotnet/package-management/index-package-management.md)** - Overview and quick start
- **[Local Testing](development-guidelines/dotnet/package-management/local-testing-package-management.md)** - Test NuGet packages locally before publishing
- **[Package Overview](development-guidelines/dotnet/package-management/overview-package-management.md)** - Complete guide: configuration, versioning, deployment

### Design Principles & Patterns
- **[SOLID Principles](development-guidelines/dotnet/solid-principles/solid-principles.md)** - Modern interpretation with Olbrasoft examples
- **[Design Patterns Index](development-guidelines/dotnet/design-patterns/index-design-patterns.md)** - Overview and pattern catalog navigation
- **[GoF Patterns](development-guidelines/dotnet/design-patterns/gof-patterns-design-patterns.md)** - 23 classic Gang of Four patterns
- **[Enterprise Patterns](development-guidelines/dotnet/design-patterns/enterprise-patterns-design-patterns.md)** - Martin Fowler's enterprise application patterns
- **[Microservices Patterns](development-guidelines/dotnet/design-patterns/microservices-patterns-design-patterns.md)** - Saga, CQRS, Event Sourcing, API Gateway
- **[Cloud Patterns](development-guidelines/dotnet/design-patterns/cloud-patterns-design-patterns.md)** - Retry, Circuit Breaker, Bulkhead, resilience patterns
- **[Architectural Patterns](development-guidelines/dotnet/design-patterns/architectural-patterns-design-patterns.md)** - Clean Architecture, Hexagonal, Layered, Event-Driven

## Repository Structure

```
engineering-handbook/
├── README.md                          # This file
├── development-guidelines/
│   ├── workflow/                      # Git, branches, PRs (general)
│   ├── architecture/                  # Design decisions (general)
│   ├── code-review/                   # Code review (general)
│   ├── tools/                         # SearXNG, HT terminal (general)
│   ├── project-setup/                 # Repository setup (general)
│   ├── dotnet/                        # .NET SPECIFIC
│   │   ├── testing/                   # xUnit, Moq
│   │   ├── continuous-integration/    # Build, test
│   │   ├── continuous-deployment/     # Deploy, NuGet
│   │   ├── package-management/        # NuGet packages
│   │   ├── solid-principles/          # SOLID for .NET
│   │   └── design-patterns/           # GoF, Enterprise, Cloud
│   ├── configuration-management.md
│   └── secrets-management.md
└── contributing/
```

## Contributing

See [Contributing Guide](contributing/index-contributing.md) for file naming conventions and contribution process.

## License

MIT License - see [LICENSE](LICENSE)
