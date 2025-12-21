# CI/CD - Claude Code Guide

**You are:** Claude Code  
**Topic:** GitHub Actions, NuGet, deployment

---

## What Type of Project?

### 📦 NuGet Package (Class Library)
**Read:** [ci-cd-nuget-packages.md](ci-cd-nuget-packages.md)

**Use when:** Publishing library to NuGet.org

**Key topics:**
- Package metadata (.csproj)
- Multi-package repositories
- GitHub workflow (build.yml, publish-nuget.yml)
- NuGet API key (from `~/Dokumenty/Keys/nuget-key.txt`)
- Version synchronization

### 🌐 Web Service (ASP.NET Core)
**Read:** [ci-cd-web-services.md](ci-cd-web-services.md)

**Use when:** Deploying API or web app to Linux server

**Key topics:**
- systemd service configuration
- Deployment path (`/opt/olbrasoft/<app>/`)
- Secrets management (EnvironmentFile)
- 100% functional rule (ALL features must work)
- Self-hosted GitHub Actions runner

### 🖥️ Desktop App (GUI)
**Read:** [ci-cd-desktop-apps.md](ci-cd-desktop-apps.md)

**Use when:** Building WinForms/WPF/Avalonia/MAUI app

**Key topics:**
- GitHub Releases
- Multi-platform builds
- Installers (AppImage, .deb, MSI)

### 🤷 Not Sure?
**Read:** [ci-cd-overview.md](ci-cd-overview.md)

Decision tree to pick the right guide.

---

## Quick Reference

| Project Type | Read This |
|--------------|-----------|
| NuGet package | `ci-cd-nuget-packages.md` |
| Web API/service | `ci-cd-web-services.md` |
| Desktop app | `ci-cd-desktop-apps.md` |
| Mixed/unsure | `ci-cd-overview.md` |

---

**Next step:** Choose project type above and read the corresponding file.
