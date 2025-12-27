# Development Guidelines

Repository setup, CI/CD, Git workflow, project structure, testing, and development tools.

---

## How to Use This Handbook

**ALWAYS follow this workflow:**

1. **Read this file first** (AGENTS.md) - determine what you're doing
2. **Pick ONE specific document** based on your task
3. **Read ONLY that document** - don't load entire handbook

**Why?** Token efficiency. Handbook is large, you only need relevant parts.

---

## Quick Decision Tree

```
What am I doing?
│
├─ Using GitHub CLI (issues, PRs, sub-issues, API)
│  └─ Read: github-operations.md
│
├─ Searching internet / researching solutions
│  └─ Read: research-guide.md
│
├─ Running terminal commands (OpenCode - bash disabled)
│  └─ Read: ht-mcp-terminal.md
│
├─ Setting up NEW GitHub repository
│  └─ Read: repository-setup.md
│
├─ Setting up CI/CD for .NET project
│  ├─ What type?
│  │  ├─ NuGet package (library) → ci-cd-nuget.md
│  │  ├─ Web service (API/webapp) → ci-cd-web.md
│  │  ├─ Local app → ci-cd-local-apps.md
│  │  └─ Desktop app (GUI) → ci-cd-desktop.md
│  └─ Not sure? → ci-cd-overview.md (then pick specific doc)
│
├─ Structuring .NET project (folders/naming)
│  └─ Read: project-structure.md
│
├─ Implementing NEW complex features
│  └─ Read: feature-workflow.md
│
├─ Git workflow (branches/commits/issues)
│  └─ Read: workflow.md
│
├─ Code review / refactoring
│  ├─ General guide → code-review/code-review.md
│  ├─ Manual review → code-review/manual-review.md
│  ├─ Claude Code (automated /code-review) → code-review/CLAUDE.md
│  └─ OpenCode (manual) → code-review/AGENTS.md
│
├─ Learning SOLID principles
│  └─ Read: ../solid-principles/solid-principles.md
│
└─ Learning design patterns
   └─ Read: ../design-patterns/gof-design-patterns.md
```

---

## Document Index

### 1. Repository Setup
**File:** `repository-setup.md`

**Read when:**
- Creating new GitHub repository
- Configuring branch protection
- Setting up webhooks
- Managing GitHub Secrets

**Key info:**
- Repository naming conventions
- Required files (`.gitignore`, `LICENSE`, `AGENTS.md`)
- Secret management locations
- Webhook configuration

---

### 2. CI/CD: Which Type?
**File:** `ci-cd-overview.md` (English) / `ci-cd-overview-cz.md` (Czech)

**Read when:**
- Not sure which CI/CD strategy to use
- Project has mixed types (library + demo app)
- Need quick decision tree

**Outcome:** Determines which specific CI/CD doc to read next.

---

### 3. CI/CD: NuGet Packages
**File:** `ci-cd-nuget.md`

**Read when:**
- Publishing class library to NuGet.org
- Multi-package repository (e.g., TextToSpeech)
- Setting up NuGet API key
- Configuring package metadata

**Examples:** TextToSpeech, Mediation, SystemTray

**Key workflows:**
- `build.yml` - Build & test on push/PR
- `publish-nuget.yml` - Publish to NuGet.org

**Critical info:**
- NuGet API key location: `~/Dokumenty/Keys/nuget-key.txt`
- Multi-package detection: `find . -name "*.nupkg"`
- Exclude demo apps: `<IsPackable>false</IsPackable>`

---

### 4. CI/CD: Web Services
**File:** `ci-cd-web.md`

**Read when:**
- Deploying ASP.NET Core application to Linux server
- Setting up systemd service
- Managing production secrets
- Configuring self-hosted GitHub Actions runner

**Examples:** VirtualAssistant, GitHub.Issues

**Key info:**
- Deploy path: `/opt/olbrasoft/<app>/`
- Secrets: systemd `EnvironmentFile` (NOT in Git!)
- Deploy script pattern
- 100% functional rule (ALL features must work)

---

### 5. CI/CD: Desktop Apps
**File:** `ci-cd-desktop.md`

**Read when:**
- Building GUI application (WinForms/WPF/Avalonia/MAUI)
- Creating GitHub Releases
- Generating installers (AppImage, .deb, MSI)

**Key workflows:**
- Build on push/PR
- Release on git tag `v*`
- Multi-platform publish (Linux/Windows/macOS)

**Note:** This doc is incomplete (TODO: AppImage, .deb creation).

---

### 6. .NET Project Structure
**File:** `project-structure.md`

**Read when:**
- Creating new .NET solution
- Organizing project folders
- Naming conventions for projects/namespaces

**Key rules:**
- Folder naming: NO `Olbrasoft.` prefix (e.g., `SystemTray.Linux/`)
- Namespace naming: WITH `Olbrasoft.` prefix (e.g., `Olbrasoft.SystemTray.Linux`)
- Test project per source project (NOT shared test project)

---

### 7. Git Workflow
**File:** `workflow.md` (English)

**Read when:**
- Creating GitHub issues
- Branching strategy
- Commit messages
- Sub-issues (NOT checkboxes!)

### 8. Feature Development
**File:** `feature-workflow.md`

**Read when:**
- Starting a complex new feature
- Designing architecture
- Exploring unknown codebase
- Using 7-phase systematic process

### 9. Code Review & Refactoring (General)
**File:** `code-review-refactoring-guide.md` (English) / `code-review-refactoring-guide-cz.md` (Czech)

**Read when:**
- Reviewing code manually
- Refactoring existing code
- Identifying code smells
- Using OpenCode or Gemini (no automated review)

---

### 9. Code Review with Claude Code (Automated)
**File:** `code-review-claude.md` (English) / `code-review-claude-cz.md` (Czech)

**Read when:**
- Using Claude Code `/code-review` command
- Setting up CLAUDE.md for automated PR reviews
- Configuring review agents
- Integrating with GitHub PR workflow

**Key info:**
- 4 parallel agents (2x Sonnet, 2x Opus)
- Confidence scoring (threshold 80)
- .NET-specific CLAUDE.md template
- Integration with engineering-handbook standards

**Prerequisites:**
- Claude Code installed
- GitHub CLI (`gh`) authenticated
- CLAUDE.md in project root

---

### 10. SOLID Principles
**File:** `../solid-principles/solid-principles.md` (English)

**Read when:**
- Designing new classes/interfaces
- Refactoring to improve testability
- Learning modern SOLID interpretation (2025 update)

---

### 11. Design Patterns
**File:** `../design-patterns/gof-design-patterns.md` (English)

**Read when:**
- Implementing common patterns
- Learning Gang of Four patterns
- Modern pattern usage (2025 update)

---

### 12. GitHub Operations (OpenCode)
**File:** `github-operations/AGENTS.md`

**Read when:**
- Using GitHub CLI (`gh`)
- Managing issues, PRs
- Creating sub-issues
- GitHub API operations

**Key info:**
- `gh` CLI commands
- Sub-issue naming: "Issue #57 - part of #56"
- Why sub-issues > checkboxes
- API access via `gh api`

---

### 13. Web Search & Research (OpenCode)
**File:** `research-guide.md`

**Read when:**
- Searching internet for solutions
- Using SearXNG
- Reading documentation/articles
- Research methodology

**Key info:**
- SearXNG usage (`searxng_web_search`)
- URL reading tools (web_url_read, webfetch, curl)
- Research sequence: handbook → internet → Stack Overflow

---

### 14. ht-mcp Terminal (OpenCode)
**File:** `ht-mcp-terminal.md`

**Read when:**
- Running commands in OpenCode
- Bash is hanging/disabled
- Long-running commands
- Need live progress output

**Key info:**
- Why ht-mcp instead of bash
- Basic workflow (list → create → execute)
- When to use ht-mcp vs bash exceptions

---

## Common Scenarios

### "I need to create a new NuGet package repository"
1. Read: `repository-setup.md` (create repo)
2. Read: `project-structure.md` (organize code)
3. Read: `ci-cd-nuget.md` (setup CI/CD)
4. Read: `workflow-guide.md` (issues/branches)

### "I need to deploy a web service"
1. Read: `ci-cd-web.md` (deployment process)
2. Check: `/opt/olbrasoft/<app>/` structure
3. Verify: systemd EnvironmentFile has ALL secrets
4. Test: ALL features work (100% functional rule)

### "I'm starting a new .NET project"
1. Read: `ci-cd-overview.md` (determine type)
2. Read: `project-structure.md` (structure)
3. Read: specific CI/CD doc based on type
4. Read: `workflow-guide.md` (Git workflow)

---

## File Naming Convention

| Pattern | Language | Audience |
|---------|----------|----------|
| `filename.md` | English | AI agents (terse, token-efficient) |
| `filename-cz.md` | Czech | Human developers (detailed, formatted) |

**AI agents:** Use English `.md` files (shorter, less tokens).

---

## Secret Locations (Critical!)

**NEVER load secrets from handbook - reference only!**

| Secret Type | Location |
|-------------|----------|
| NuGet API key | `~/Dokumenty/Keys/nuget-key.txt` |
| GitHub tokens | `~/Dokumenty/přístupy/api-keys.md` |
| AI provider keys | `~/Dokumenty/přístupy/llmchain-*.txt` |
| Azure keys | `~/Dokumenty/přístupy/api-keys.md` |
| Production secrets | systemd EnvironmentFile (`~/.config/systemd/user/<service>.env`) |
| Development secrets | User Secrets (`dotnet user-secrets list`) |

---

## Token Optimization Tips

1. **Don't load multiple docs** - pick ONE based on task
2. **Use decision tree** - narrow down quickly
3. **English versions** - shorter than Czech
4. **Search specific sections** - don't read entire file
5. **Check index first** - this file (AGENTS.md)

---

## Document Status

| Document | Status | Notes |
|----------|--------|-------|
| ci-cd-overview | ✅ Complete | Decision tree |
| ci-cd-nuget | ✅ Complete | Multi-package examples |
| ci-cd-web | ✅ Complete | systemd, secrets |
| ci-cd-desktop | ⚠️ Incomplete | TODO: AppImage, .deb |
| repository-setup | ✅ Complete | - |
| project-structure | ✅ Complete | - |
| workflow-guide | ✅ Complete | - |
| code-review-refactoring-guide | ✅ Complete | Manual review |
| code-review-claude | ✅ Complete | Claude Code /code-review |

---

## Anti-Patterns to Avoid

❌ **DON'T:** Load entire handbook at once  
✅ **DO:** Read AGENTS.md → pick ONE doc

❌ **DON'T:** Read Czech versions as agent  
✅ **DO:** Use English versions (less tokens)

❌ **DON'T:** Guess which doc to read  
✅ **DO:** Use decision tree in this file

❌ **DON'T:** Load secrets from handbook  
✅ **DO:** Read secret location, then load from filesystem

---

## Contributing

When adding new documents:
1. Update this index (AGENTS.md)
2. Add to decision tree
3. Create both English (`.md`) and Czech (`-cz.md`) versions
4. Add to "Document Status" table

---

## Quick Reference Commands

```bash
# List all handbook files
ls ~/GitHub/Olbrasoft/engineering-handbook/development-guidelines/

# Read specific doc (example)
cat ~/GitHub/Olbrasoft/engineering-handbook/development-guidelines/ci-cd-nuget.md

# Find specific topic
grep -r "NuGet API key" ~/GitHub/Olbrasoft/engineering-handbook/

# Check document length (tokens)
wc -l ~/GitHub/Olbrasoft/engineering-handbook/development-guidelines/*.md
```

---

**Remember:** Read THIS file first. Pick ONE document. Stay token-efficient.
