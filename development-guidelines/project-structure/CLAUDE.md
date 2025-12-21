# Project Structure - Claude Code Guide

**You are:** Claude Code  
**Topic:** .NET solution structure, naming conventions

---

## What You Need

**Read:** [dotnet-project-structure.md](dotnet-project-structure.md)

**Contents:**
- Folder structure (`src/`, `tests/`, `docs/`)
- Naming conventions:
  - Folders: NO `Olbrasoft.` prefix (e.g., `SystemTray.Linux/`)
  - Namespaces: WITH `Olbrasoft.` prefix (e.g., `Olbrasoft.SystemTray.Linux`)
- Test project structure:
  - Separate test project per source project
  - NOT single shared test project
- Multi-package repositories
- Clean Architecture organization

**Example:**
```
src/
  NotificationAudio.Abstractions/
  NotificationAudio.Core/
  NotificationAudio.Providers.Linux/
tests/
  NotificationAudio.Core.Tests/
  NotificationAudio.Providers.Linux.Tests/
```

---

**Next step:** Read [dotnet-project-structure.md](dotnet-project-structure.md)
