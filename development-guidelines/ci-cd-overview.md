# CI/CD Overview

Quick reference for determining project type and CI/CD strategy.

## Project Type Decision Tree

```
.NET Project
│
├─ Has GUI? (WinForms/WPF/Avalonia/MAUI)
│  ├─ Deploy to local server? → Local App → ci-cd-local-apps.md
│  └─ Public release? → Desktop App → ci-cd-desktop.md
│
├─ Has ASP.NET Core? (API/Web/SignalR)
│  ├─ Deploy to local server? → Local App → ci-cd-local-apps.md
│  └─ Deploy to cloud? → Web Service → ci-cd-web.md
│
└─ Is Class Library?
   └─ YES → NuGet Package → ci-cd-nuget.md
```

## Quick Reference

| Type | Deploy Target | Workflow Trigger | Doc |
|------|---------------|------------------|-----|
| NuGet packages | NuGet.org | Push to `main` or tag `v*` | [ci-cd-nuget.md](ci-cd-nuget.md) |
| Local apps | `/opt/olbrasoft/<app>/` | After successful build (self-hosted) | [ci-cd-local-apps.md](ci-cd-local-apps.md) |
| Web services | `/opt/olbrasoft/<app>/` | Self-hosted runner | [ci-cd-web.md](ci-cd-web.md) |
| Desktop apps | GitHub Releases | Tag `v*` | [ci-cd-desktop.md](ci-cd-desktop.md) |

## Project Type Indicators

### NuGet Package
```xml
<!-- .csproj indicators -->
<PackageId>Olbrasoft.Something</PackageId>
<TargetFrameworks>netstandard2.1;net6.0;net8.0;net10.0</TargetFrameworks>
```
- Multi-targeting common
- No `<OutputType>Exe</OutputType>`
- Has NuGet metadata

### Local App
```xml
<!-- .csproj indicators -->
<OutputType>Exe</OutputType>
<TargetFramework>net10.0</TargetFramework>
<Version>1.0.0-local</Version>  <!-- Fallback, auto-versioned in CI/CD -->
```
- Has `.github/workflows/deploy.yml` with `workflow_run` trigger
- Has `scripts/install-runner.sh`
- Deploys to `/opt/olbrasoft/<app>/`
- Uses self-hosted runner

### Web Service
```xml
<!-- .csproj indicators -->
<Project Sdk="Microsoft.NET.Sdk.Web">
<TargetFramework>net10.0</TargetFramework>
```
- Has `appsettings.json`
- Has systemd `.service` file
- Has `deploy/deploy.sh` script

### Desktop App
```xml
<!-- .csproj indicators -->
<OutputType>WinExe</OutputType>
<TargetFramework>net10.0</TargetFramework>
```
- Single target framework
- Has GUI framework reference
- No multi-targeting

## Multi-Package Repositories

**Example:** TextToSpeech
```
src/               → Publishes to NuGet.org
  ├─ Core/
  ├─ Providers/
  └─ Orchestration/
examples/          → Build only (IsPackable=false)
  └─ Demo/
```

**Workflow:** `find . -name "*.nupkg"` publishes ALL packages at once.

## Common Workflows

### Build (All Types)
```yaml
on: [push, pull_request]
steps:
  - dotnet restore
  - dotnet build -c Release
  - dotnet test -c Release
```

### Publish (Type-Specific)
- **NuGet:** `dotnet pack` → `dotnet nuget push`
- **Local:** `dotnet publish` → `/opt/olbrasoft/<app>/` → `systemctl restart` (self-hosted)
- **Web:** `./deploy/deploy.sh /opt/olbrasoft/<app>` → `systemctl restart`
- **Desktop:** `dotnet publish -r <rid>` → `gh release create`
