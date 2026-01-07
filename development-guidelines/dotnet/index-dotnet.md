# .NET Development Guidelines

Standards and conventions for .NET development in Olbrasoft projects.

## Overview

All Olbrasoft .NET projects follow these standards:

| Standard | Value |
|----------|-------|
| **Target Framework** | .NET 10 (`net10.0`) |
| **Root Namespace** | `Olbrasoft.{Domain}.{Layer}` |
| **Testing** | xUnit + Moq |
| **Nullable** | Enabled |
| **Implicit Usings** | Enabled |

## Quick Navigation

### Core Development
| Topic | File | Description |
|-------|------|-------------|
| **C# Coding** | [csharp-coding-dotnet.md](csharp-coding-dotnet.md) | Best practices for C# code quality |
| **CLAUDE.md Setup** | [claude-md-best-practices-dotnet.md](claude-md-best-practices-dotnet.md) | AI assistant configuration for .NET |

### Project Structure & Naming
| Topic | File | Description |
|-------|------|-------------|
| **Project Structure** | [project-structure-dotnet.md](project-structure-dotnet.md) | Naming conventions, folders, test organization |
| **Layered Naming** | [layered-naming-dotnet.md](layered-naming-dotnet.md) | Multi-layered applications (Blog example) |

### Testing
| Topic | File | Description |
|-------|------|-------------|
| **Testing Index** | [testing/index-testing.md](testing/index-testing.md) | Overview, decision tree |
| **Unit Tests** | [testing/unit-tests-testing.md](testing/unit-tests-testing.md) | xUnit, Moq, in-memory DB |
| **Integration Tests** | [testing/integration-tests-testing.md](testing/integration-tests-testing.md) | [SkipOnCIFact], real services |

### Continuous Integration
| Topic | File | Description |
|-------|------|-------------|
| **CI Index** | [continuous-integration/index-continuous-integration.md](continuous-integration/index-continuous-integration.md) | Overview |
| **Build** | [continuous-integration/build-continuous-integration.md](continuous-integration/build-continuous-integration.md) | .NET build, multi-targeting |
| **Test** | [continuous-integration/test-continuous-integration.md](continuous-integration/test-continuous-integration.md) | CI testing |

### Continuous Deployment
| Topic | File | Description |
|-------|------|-------------|
| **CD Index** | [continuous-deployment/index-continuous-deployment.md](continuous-deployment/index-continuous-deployment.md) | Decision tree |
| **NuGet** | [continuous-deployment/nuget-publish-continuous-deployment.md](continuous-deployment/nuget-publish-continuous-deployment.md) | NuGet.org publishing |
| **Web Services** | [continuous-deployment/web-deploy-continuous-deployment.md](continuous-deployment/web-deploy-continuous-deployment.md) | ASP.NET Core, systemd |
| **Local Apps** | [continuous-deployment/local-apps-deploy-continuous-deployment.md](continuous-deployment/local-apps-deploy-continuous-deployment.md) | Self-hosted runner |
| **Desktop Apps** | [continuous-deployment/desktop-release-continuous-deployment.md](continuous-deployment/desktop-release-continuous-deployment.md) | GitHub Releases |

### Package Management
| Topic | File | Description |
|-------|------|-------------|
| **Package Index** | [package-management/index-package-management.md](package-management/index-package-management.md) | Overview |
| **Local Testing** | [package-management/local-testing-package-management.md](package-management/local-testing-package-management.md) | Test before publish |
| **Overview** | [package-management/overview-package-management.md](package-management/overview-package-management.md) | Complete guide |

### Design Principles & Patterns
| Topic | File | Description |
|-------|------|-------------|
| **SOLID** | [solid-principles/solid-principles.md](solid-principles/solid-principles.md) | Modern SOLID interpretation |
| **Patterns Index** | [design-patterns/index-design-patterns.md](design-patterns/index-design-patterns.md) | Pattern catalog |
| **GoF** | [design-patterns/gof-patterns-design-patterns.md](design-patterns/gof-patterns-design-patterns.md) | Gang of Four |
| **Enterprise** | [design-patterns/enterprise-patterns-design-patterns.md](design-patterns/enterprise-patterns-design-patterns.md) | Martin Fowler |
| **Microservices** | [design-patterns/microservices-patterns-design-patterns.md](design-patterns/microservices-patterns-design-patterns.md) | Saga, CQRS |
| **Cloud** | [design-patterns/cloud-patterns-design-patterns.md](design-patterns/cloud-patterns-design-patterns.md) | Resilience |
| **Architectural** | [design-patterns/architectural-patterns-design-patterns.md](design-patterns/architectural-patterns-design-patterns.md) | Clean, Hexagonal |

## Project Types

### Multi-Layered Applications

Applications with Data, Business, and UI layers:

- **Blog** - ASP.NET Core MVC blog platform
- **VirtualAssistant** - Voice-controlled assistant service
- **GitHub.Issues** - GitHub issue synchronization

See: [Layered Naming Conventions](layered-naming-dotnet.md)

### Libraries

Standalone reusable packages published to NuGet:

- **Olbrasoft.Data** - CQRS, EF abstractions
- **Olbrasoft.Linq** - LINQ extensions
- **Olbrasoft.Extensions** - Common extensions
- **Olbrasoft.Mapping** - Object mapping

See: [Project Structure](project-structure-dotnet.md)

## .csproj Template

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <RootNamespace>Olbrasoft.{Domain}.{Layer}</RootNamespace>
  </PropertyGroup>
</Project>
```

## Namespace Convention

**Folders:** NO `Olbrasoft.` prefix
**Namespaces:** YES `Olbrasoft.` prefix

| Folder | Namespace |
|--------|-----------|
| `Blog.Data/` | `Olbrasoft.Blog.Data` |
| `VirtualAssistant.Voice/` | `Olbrasoft.VirtualAssistant.Voice` |

Set via `.csproj`:
```xml
<RootNamespace>Olbrasoft.Blog.Data</RootNamespace>
```

## See Also

- [Main Handbook](../../README.md) - Engineering handbook home
- [Workflow Guide](../workflow/index-workflow.md) - Git, branches, PRs
- [Architecture](../architecture/index-architecture.md) - Design decisions
