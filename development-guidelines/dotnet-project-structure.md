# .NET Project Structure Guide

Complete guide for structuring .NET projects in Olbrasoft repositories.

> **Note:** These conventions apply to all .NET languages (C#, F#, VB.NET, C++/CLI), not just C#. The namespace naming follows [Microsoft Framework Design Guidelines](https://learn.microsoft.com/en-us/dotnet/standard/design-guidelines/names-of-namespaces).

---

## Directory Structure

### Repository Layout

```
RepositoryName/
├── src/                              # Source projects
│   ├── {Domain}.{Layer}/             # Project folders
│   └── ...
├── test/                             # Test projects (some repos use "tests/")
│   ├── {Domain}.{Layer}.Tests/
│   └── ...
├── .github/
│   └── workflows/                    # CI/CD pipelines
├── deploy/                           # Deployment scripts (optional)
├── docs/                             # Documentation (optional)
├── .gitignore
├── LICENSE
├── README.md
├── AGENTS.md                         # AI agent instructions (optional)
└── {RepositoryName}.sln              # Solution file
```

---

## Naming Conventions

### Key Principle: Folder vs Namespace

**Project folder names do NOT include `Olbrasoft.` prefix, but namespaces DO.**

| Aspect | Example (VirtualAssistant) | Example (GitHub.Issues) |
|--------|---------------------------|------------------------|
| **Folder** | `VirtualAssistant.Voice/` | `GitHub.Issues.Sync/` |
| **Namespace** | `Olbrasoft.VirtualAssistant.Voice` | `Olbrasoft.GitHub.Issues.Sync` |

### Project Folder Names

```
{Domain}.{Layer}[.{Sublayer}]
```

- **Domain:** Business domain (`GitHub.Issues`, `VirtualAssistant`, `Text`)
- **Layer:** Architectural layer (`Data`, `Business`, `Sync`, `AspNetCore`, `Voice`)
- **Sublayer:** Optional specificity (`EntityFrameworkCore`, `RazorPages`, `PostgreSQL`)

**Examples:**

| Layer Type | Folder Name |
|------------|-------------|
| Data/Domain | `VirtualAssistant.Data` |
| Business Logic | `GitHub.Issues.Business` |
| EF Core Implementation | `VirtualAssistant.Data.EntityFrameworkCore` |
| DB Migrations | `GitHub.Issues.Migrations.PostgreSQL` |
| API/Web | `GitHub.Issues.AspNetCore.RazorPages` |
| Voice/Audio | `VirtualAssistant.Voice` |

### Namespace Conventions

**Namespace = `Olbrasoft.` + Folder Name**

This is achieved via `<RootNamespace>` in .csproj:

```xml
<PropertyGroup>
  <RootNamespace>Olbrasoft.VirtualAssistant.Voice</RootNamespace>
</PropertyGroup>
```

| Folder | Namespace |
|--------|-----------|
| `VirtualAssistant.Voice` | `Olbrasoft.VirtualAssistant.Voice` |
| `GitHub.Issues.Sync` | `Olbrasoft.GitHub.Issues.Sync` |
| `VirtualAssistant.Data.EntityFrameworkCore` | `Olbrasoft.VirtualAssistant.Data.EntityFrameworkCore` |

**Subfolders append to namespace:**

| File Location | Namespace |
|---------------|-----------|
| `src/GitHub.Issues.Sync/Services/GitHubSyncService.cs` | `Olbrasoft.GitHub.Issues.Sync.Services` |
| `src/VirtualAssistant.Voice/Services/TtsService.cs` | `Olbrasoft.VirtualAssistant.Voice.Services` |

### Test Directory (`test/` or `tests/`)

**CRITICAL: Each source project MUST have its own separate test project.**

| Source Project | Test Project |
|----------------|--------------|
| `VirtualAssistant.Voice` | `VirtualAssistant.Voice.Tests` |
| `GitHub.Issues.Business` | `GitHub.Issues.Business.Tests` |
| `GitHub.Issues.Sync` | `GitHub.Issues.Sync.Tests` |

**NEVER create a single shared test project for all tests.**

### Test Class Naming

| Source Class | Test Class |
|--------------|------------|
| `GitHubSyncService` | `GitHubSyncServiceTests` |
| `TtsService` | `TtsServiceTests` |

Test files mirror source folder structure:

```
src/GitHub.Issues.Sync/
  Services/
    GitHubSyncService.cs
    
test/GitHub.Issues.Sync.Tests/
  Services/
    GitHubSyncServiceTests.cs
```

---

## Project Configuration

### Standard .csproj Template

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <LangVersion>13</LangVersion>
    <RootNamespace>Olbrasoft.{Domain}.{Layer}</RootNamespace>
    <GenerateDocumentationFile>true</GenerateDocumentationFile>
    <NoWarn>$(NoWarn);1591</NoWarn>
  </PropertyGroup>

</Project>
```

### Test Project Template

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <IsPackable>false</IsPackable>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="coverlet.collector" Version="6.0.4" />
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.14.1" />
    <PackageReference Include="Moq" Version="4.20.72" />
    <PackageReference Include="xunit" Version="2.9.3" />
    <PackageReference Include="xunit.runner.visualstudio" Version="3.1.4" />
  </ItemGroup>

  <ItemGroup>
    <Using Include="Xunit" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\..\src\{SourceProject}\{SourceProject}.csproj" />
  </ItemGroup>

</Project>
```

---

## GitHub Webhooks Setup

For applications that need real-time GitHub notifications (like GitHub.Issues), configure webhooks via ngrok.

### Local Development with ngrok

1. **Start ngrok tunnel** pointing to your local app:
   ```bash
   ngrok http 5156
   ```

2. **Note the public URL** (e.g., `https://plumbaginous-zoe-unexcusedly.ngrok-free.dev`)

### GitHub Webhook Configuration

| Parameter | Value |
|-----------|-------|
| **Payload URL** | `https://{ngrok-url}/api/webhooks/github` |
| **Content Type** | `application/json` |
| **Webhook Secret** | Store in `~/Dokumenty/guidebooks/github-webhooks.md` |

### Recommended Events

Select based on your needs:
- `issues` - Issue created, edited, closed
- `issue_comment` - Comments on issues
- `label` - Label changes
- `repository` - Repository changes
- `sub_issues` - Sub-issues (if used)

### Setting Up Webhook for New Repository

1. Go to repository **Settings → Webhooks → Add webhook**
2. Enter Payload URL with ngrok domain
3. Set Content type to `application/json`
4. Enter the shared webhook secret
5. Select events (or "Let me select individual events")
6. Click **Add webhook**

### Application Port

| Application | Port | Webhook Endpoint |
|-------------|------|------------------|
| GitHub.Issues | 5156 | `/api/webhooks/github` |

---

## Credentials and Secrets

### GitHub Personal Access Token

**Location:** `~/Dokumenty/přístupy/api-keys.md`

The token is used for:
- Authenticating GitHub API requests during sync
- Avoiding rate limits (60 req/hour → 5000 req/hour with token)

### API Keys Directory Structure

```
~/Dokumenty/přístupy/
├── api-keys.md              # Main API keys file (GitHub, NuGet)
├── github-issues/           # Project-specific keys
│   ├── cerebras.txt
│   ├── cohere.txt
│   └── groq.txt
├── databases.md             # Database connection strings
└── hosting.md               # Hosting credentials
```

### User Secrets Configuration

Use .NET User Secrets for local development:

```bash
cd src/GitHub.Issues.AspNetCore.RazorPages
dotnet user-secrets init
dotnet user-secrets set "GitHub:Token" "ghp_xxx"
dotnet user-secrets set "GitHubApp:WebhookSecret" "xxx"
```

---

## Layer Architecture

### Typical Layer Structure

```
{Domain}.Data              → Entities, DTOs, Queries, Commands (interfaces)
{Domain}.Data.EFCore       → DbContext, Query/Command handlers, Migrations
{Domain}.Business          → Business services, strategies, models
{Domain}.Sync              → External API clients, sync services, webhooks
{Domain}.AspNetCore.X      → Web layer (RazorPages, API controllers)
```

### Layer Dependencies

```
AspNetCore.RazorPages
    ↓
Business ←→ Sync
    ↓
Data.EntityFrameworkCore
    ↓
Data (entities, interfaces)
```

---

## Examples

### GitHub.Issues Repository Structure

```
GitHub.Issues/
├── src/
│   ├── GitHub.Issues.AspNetCore.RazorPages/  # Web UI
│   ├── GitHub.Issues.Business/               # Business logic
│   ├── GitHub.Issues.Data/                   # Entities, DTOs
│   ├── GitHub.Issues.Data.EntityFrameworkCore/ # EF Core
│   ├── GitHub.Issues.Migrations.PostgreSQL/  # PG migrations
│   ├── GitHub.Issues.Migrations.SqlServer/   # MSSQL migrations
│   └── GitHub.Issues.Sync/                   # GitHub API sync
├── test/
│   ├── GitHub.Issues.AspNetCore.RazorPages.Tests/
│   ├── GitHub.Issues.Business.Tests/
│   ├── GitHub.Issues.Data.EntityFrameworkCore.Tests/
│   ├── GitHub.Issues.Data.Tests/
│   └── GitHub.Issues.Sync.Tests/
└── GitHub.Issues.sln
```

**Namespaces:** All use `Olbrasoft.GitHub.Issues.{Layer}` via RootNamespace.

### VirtualAssistant Repository Structure

```
VirtualAssistant/
├── src/
│   ├── VirtualAssistant.Agent/
│   ├── VirtualAssistant.Core/
│   ├── VirtualAssistant.Data/
│   ├── VirtualAssistant.Data.EntityFrameworkCore/
│   ├── VirtualAssistant.Desktop/
│   ├── VirtualAssistant.GitHub/
│   ├── VirtualAssistant.LlmChain/
│   ├── VirtualAssistant.Service/           # Main web service
│   ├── VirtualAssistant.Tray/
│   └── VirtualAssistant.Voice/
├── tests/
│   ├── VirtualAssistant.Agent.Tests/
│   ├── VirtualAssistant.Data.EntityFrameworkCore.Tests/
│   ├── VirtualAssistant.GitHub.Tests/
│   └── VirtualAssistant.Voice.Tests/
├── deploy/
├── plugins/
└── VirtualAssistant.sln
```

**Namespaces:** All use `Olbrasoft.VirtualAssistant.{Layer}` via RootNamespace.

---

## Checklist for New Repository

- [ ] Create `src/` directory with project folders (without `Olbrasoft.` prefix)
- [ ] Create `test/` (or `tests/`) directory
- [ ] Create separate test project for each source project
- [ ] Set `<RootNamespace>Olbrasoft.{Domain}.{Layer}</RootNamespace>` in each .csproj
- [ ] Use .NET 10 (`net10.0`)
- [ ] Use xUnit + Moq for testing
- [ ] Configure user secrets if needed
- [ ] Add `.gitignore`, `LICENSE`, `README.md`
- [ ] Create solution file `{RepoName}.sln`
- [ ] If using GitHub webhooks, document in `~/Dokumenty/guidebooks/`

---

## References

- [Workflow Guide](./workflow-guide.md) - Git workflow, GitHub issues
- [SOLID Principles](../solid-principles/solid-principles-2025.md)
- [Design Patterns](../design-patterns/gof-design-patterns-2025.md)
