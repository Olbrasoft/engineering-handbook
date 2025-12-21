# CI/CD Overview

Quick reference for determining project type and CI/CD strategy.

## Project Type Decision Tree

```
.NET Project
│
├─ Has GUI? (WinForms/WPF/Avalonia/MAUI)
│  └─ YES → Desktop App → ci-cd-desktop-apps.md
│
├─ Has ASP.NET Core? (API/Web/SignalR)
│  └─ YES → Web Service → ci-cd-web-services.md
│
└─ Is Class Library?
   └─ YES → NuGet Package → ci-cd-nuget-packages.md
```

## Quick Reference

| Type | Deploy Target | Workflow Trigger | Doc |
|------|---------------|------------------|-----|
| NuGet packages | NuGet.org | Push to `main` or tag `v*` | [nuget](ci-cd-nuget-packages.md) |
| Web services | `/opt/olbrasoft/<app>/` | Self-hosted runner | [web](ci-cd-web-services.md) |
| Desktop apps | GitHub Releases | Tag `v*` | [desktop](ci-cd-desktop-apps.md) |

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
- **Web:** `./deploy/deploy.sh /opt/olbrasoft/<app>` → `systemctl restart`
- **Desktop:** `dotnet publish -r <rid>` → `gh release create`
