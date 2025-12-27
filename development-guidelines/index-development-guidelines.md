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
│  └─ Read: project-setup/repository-setup-project-setup.md
│
├─ Setting up Continuous Integration (Build & Test)
│  ├─ Build process → continuous-integration/build-continuous-integration.md
│  ├─ Testing → continuous-integration/test-continuous-integration.md
│  └─ Overview → continuous-integration/index-continuous-integration.md
│
├─ Setting up Continuous Deployment (Publish & Deploy)
│  ├─ What type?
│  │  ├─ NuGet package (library) → continuous-deployment/nuget-publish-continuous-deployment.md
│  │  ├─ Web service (API/webapp) → continuous-deployment/web-deploy-continuous-deployment.md
│  │  ├─ Local app → continuous-deployment/local-apps-deploy-continuous-deployment.md
│  │  └─ Desktop app (GUI) → continuous-deployment/desktop-release-continuous-deployment.md
│  └─ Not sure? → continuous-deployment/index-continuous-deployment.md (decision tree)
│
├─ Structuring .NET project (folders/naming)
│  └─ Read: project-setup/project-structure-project-setup.md
│
├─ Implementing NEW complex features
│  └─ Read: workflow/feature-development-workflow.md
│
├─ Git workflow (branches/commits/issues)
│  └─ Read: workflow/git-workflow-workflow.md
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
   └─ Read: ../design-patterns/gof-patterns-design-patterns.md
```

---

## Document Index

### 1. Repository Setup
**File:** `project-setup/repository-setup-project-setup.md`

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

### 2. Continuous Integration: Build & Test
**Files:**
- `continuous-integration/index-continuous-integration.md` - Overview
- `continuous-integration/build-continuous-integration.md` - .NET build process
- `continuous-integration/test-continuous-integration.md` - Automated testing

**Read when:**
- Setting up automated builds
- Configuring test workflows
- Understanding CI pipeline

**Key workflows:**
- `build.yml` - Build & test on push/PR
- GitHub Actions with ubuntu-latest runner

---

### 3. Continuous Deployment: Which Type?
**File:** `continuous-deployment/index-continuous-deployment.md`

**Read when:**
- Not sure which deployment strategy to use
- Project has mixed types (library + demo app)
- Need quick decision tree

**Outcome:** Determines which specific deployment doc to read next.

---

### 4. Continuous Deployment: NuGet Packages
**File:** `continuous-deployment/nuget-publish-continuous-deployment.md`

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

### 5. Continuous Deployment: Web Services
**File:** `continuous-deployment/web-deploy-continuous-deployment.md`

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

### 6. Continuous Deployment: Desktop Apps
**File:** `continuous-deployment/desktop-release-continuous-deployment.md`

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

### 7. .NET Project Structure
**File:** `project-setup/project-structure-project-setup.md`

**Read when:**
- Creating new .NET solution
- Organizing project folders
- Naming conventions for projects/namespaces

**Key rules:**
- Folder naming: NO `Olbrasoft.` prefix (e.g., `SystemTray.Linux/`)
- Namespace naming: WITH `Olbrasoft.` prefix (e.g., `Olbrasoft.SystemTray.Linux`)
- Test project per source project (NOT shared test project)

---

### 8. Git Workflow
**File:** `workflow/git-workflow-workflow.md` (English)

**Read when:**
- Creating GitHub issues
- Branching strategy
- Commit messages
- Sub-issues (NOT checkboxes!)

### 9. Feature Development
**File:** `workflow/feature-development-workflow.md`

**Read when:**
- Starting a complex new feature
- Designing architecture
- Exploring unknown codebase
- Using 7-phase systematic process

### 10. Code Review & Refactoring (General)
**File:** `code-review/general-code-review.md` (English) / `code-review-refactoring-guide-cz.md` (Czech)

**Read when:**
- Reviewing code manually
- Refactoring existing code
- Identifying code smells
- Using OpenCode or Gemini (no automated review)

---

### 11. Code Review with Claude Code (Automated)
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

### 12. SOLID Principles
**File:** `../solid-principles/solid-principles.md` (English)

**Read when:**
- Designing new classes/interfaces
- Refactoring to improve testability
- Learning modern SOLID interpretation (2025 update)

---

### 13. Design Patterns
**File:** `../design-patterns/gof-patterns-design-patterns.md` (English)

**Read when:**
- Implementing common patterns
- Learning Gang of Four patterns
- Modern pattern usage (2025 update)

---

### 14. GitHub Operations (OpenCode)
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

### 15. Web Search & Research (OpenCode)
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

### 16. ht-mcp Terminal (OpenCode)
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
1. Read: `project-setup/repository-setup-project-setup.md` (create repo)
2. Read: `project-setup/project-structure-project-setup.md` (organize code)
3. Read: `continuous-integration/build-continuous-integration.md` (setup build)
4. Read: `continuous-integration/test-continuous-integration.md` (setup tests)
5. Read: `continuous-deployment/nuget-publish-continuous-deployment.md` (setup publishing)
6. Read: `workflow/git-workflow-workflow.md` (issues/branches)

### "I need to deploy a web service"
1. Read: `continuous-deployment/web-deploy-continuous-deployment.md` (deployment process)
2. Check: `/opt/olbrasoft/<app>/` structure
3. Verify: systemd EnvironmentFile has ALL secrets
4. Test: ALL features work (100% functional rule)

### "I'm starting a new .NET project"
1. Read: `continuous-deployment/index-continuous-deployment.md` (determine deployment type)
2. Read: `project-setup/project-structure-project-setup.md` (structure)
3. Read: `continuous-integration/build-continuous-integration.md` and `test.md` (CI setup)
4. Read: specific deployment doc based on type
5. Read: `workflow/git-workflow-workflow.md` (Git workflow)

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
| continuous-integration/build | ✅ Complete | .NET build process |
| continuous-integration/test | ✅ Complete | Automated testing |
| continuous-deployment/nuget-publish | ✅ Complete | Publishing to NuGet.org |
| continuous-deployment/web-deploy | ✅ Complete | systemd, secrets |
| continuous-deployment/local-apps-deploy | ✅ Complete | Self-hosted runner |
| continuous-deployment/desktop-release | ⚠️ Incomplete | TODO: AppImage, .deb |
| local-package-testing | ✅ Complete | Test before publish |
| repository-setup | ✅ Complete | - |
| project-structure | ✅ Complete | - |
| workflow | ✅ Complete | - |
| code-review/ | ✅ Complete | Multiple files |

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
