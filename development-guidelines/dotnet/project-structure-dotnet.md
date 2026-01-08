# .NET Project Structure

## Directory Layout

```
RepoName/
├── src/                    # Source projects
│   └── {Domain}.{Layer}/
├── test/ or tests/         # Test projects
│   └── {Domain}.{Layer}.Tests/
├── .github/workflows/      # CI/CD
├── deploy/                 # Deployment (optional)
├── .gitignore, LICENSE, README.md, AGENTS.md
└── {RepoName}.sln
```

## Naming

### Folder vs Namespace

**Folders: NO `Olbrasoft.` prefix. Namespaces: YES `Olbrasoft.` prefix.**

| Folder | Namespace |
|--------|-----------|
| `VirtualAssistant.Voice/` | `Olbrasoft.VirtualAssistant.Voice` |
| `GitHub.Issues.Sync/` | `Olbrasoft.GitHub.Issues.Sync` |

Set via .csproj:
```xml
<RootNamespace>Olbrasoft.{Domain}.{Layer}</RootNamespace>
```

### Pattern: `{Domain}.{Layer}[.{Sublayer}]`

| Type | Example |
|------|---------|
| Data | `VirtualAssistant.Data` |
| EF Core | `VirtualAssistant.Data.EntityFrameworkCore` |
| Business | `GitHub.Issues.Business` |
| Migrations | `GitHub.Issues.Migrations.PostgreSQL` |
| API | `GitHub.Issues.AspNetCore.RazorPages` |

## Tests

**CRITICAL: Each source project = separate test project**

| Source | Test |
|--------|------|
| `VirtualAssistant.Voice` | `VirtualAssistant.Voice.Tests` |
| `GitHubSyncService.cs` | `GitHubSyncServiceTests.cs` |

**NEVER single shared test project.**

Mirror folder structure:
```
src/GitHub.Issues.Sync/Services/GitHubSyncService.cs
test/GitHub.Issues.Sync.Tests/Services/GitHubSyncServiceTests.cs
```

## .csproj Templates

**Source:**
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

**Test:**
```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <IsPackable>false</IsPackable>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.14.1" />
    <PackageReference Include="Moq" Version="4.20.72" />
    <PackageReference Include="xunit" Version="2.9.3" />
    <PackageReference Include="xunit.runner.visualstudio" Version="3.1.4" />
  </ItemGroup>
  <ItemGroup>
    <Using Include="Xunit" />
    <ProjectReference Include="..\..\src\{Source}\{Source}.csproj" />
  </ItemGroup>
</Project>
```

## GitHub Webhooks

### ngrok Setup
```bash
ngrok http 5156
# URL: https://xxx.ngrok-free.dev
```

### Webhook Config
| Parameter | Value |
|-----------|-------|
| Payload URL | `https://{ngrok}/api/webhooks/github` |
| Content Type | `application/json` |
| Secret | Store in `~/Dokumenty/guidebooks/github-webhooks.md` |

Events: `issues`, `issue_comment`, `label`, `repository`, `sub_issues`

## Secrets

### SecureStore (Recommended)

All Olbrasoft projects use SecureStore for encrypted secrets:
```
~/.config/{app-name}/
├── secrets/secrets.json    # Encrypted vault
└── keys/secrets.key        # Encryption key (chmod 600!)
```

See [Secrets Management](../secrets-management.md#securestore---standard-for-olbrasoft-projects) for setup.

### User Secrets (Development)
```bash
dotnet user-secrets init
dotnet user-secrets set "GitHub:Token" "ghp_xxx"
dotnet user-secrets set "GitHubApp:WebhookSecret" "xxx"
```

## Layer Architecture

```
AspNetCore.RazorPages → Business ↔ Sync → Data.EFCore → Data
```

| Layer | Content |
|-------|---------|
| Data | Entities, DTOs, interfaces |
| Data.EFCore | DbContext, handlers, migrations |
| Business | Services, strategies |
| Sync | API clients, webhooks |
| AspNetCore.X | Web layer |

## New Repo Checklist

- [ ] `src/` + `test/` directories
- [ ] Separate test project per source
- [ ] `<RootNamespace>Olbrasoft.{Domain}.{Layer}</RootNamespace>`
- [ ] .NET 10, xUnit + Moq
- [ ] User secrets if needed
- [ ] `.gitignore`, `LICENSE`, `README.md`
- [ ] `{RepoName}.sln`
