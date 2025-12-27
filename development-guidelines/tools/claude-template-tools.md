# CLAUDE.md Template for .NET Projects

**Purpose:** Configuration file for Claude Code AI assistant  
**Location:** Project root (e.g., `/home/jirka/Olbrasoft/VirtualAssistant/CLAUDE.md`)  
**Read by:** Claude Code (official Anthropic terminal/web tool)

---

## How to Use This Template

1. **Copy to project root:** `cp ~/GitHub/Olbrasoft/engineering-handbook/development-guidelines/claude-md-template.md ~/YourProject/CLAUDE.md`
2. **Customize sections:** Replace `[ProjectName]` and adjust project-specific details
3. **Commit to Git:** Share with team via version control
4. **Test:** Run `/code-review` in Claude Code to verify

---

## Template

```markdown
# Project: [ProjectName]

## Overview

[Brief 1-2 sentence description of what this project does]

**Architecture:** Clean Architecture with CQRS  
**.NET Version:** net10.0  
**Primary Technology:** ASP.NET Core / .NET Worker / Console App

---

## Engineering Standards

**ALL code in this project MUST follow:**
- Engineering Handbook: `~/GitHub/Olbrasoft/engineering-handbook/AGENTS.md`
- SOLID Principles: `~/GitHub/Olbrasoft/engineering-handbook/solid-principles/solid-principles.md`
- Design Patterns: `~/GitHub/Olbrasoft/engineering-handbook/design-patterns/gof-patterns-design-patterns.md`
- Git Workflow: `~/GitHub/Olbrasoft/engineering-handbook/development-guidelines/workflow-guide.md`

---

## .NET Standards (CRITICAL for /code-review)

### Architecture

- **Pattern:** Clean Architecture with CQRS
- **DI Container:** Built-in ASP.NET Core DI
- **Data Access:** Entity Framework Core with Repository pattern
- **Command/Query:** MediatR (if applicable)
- **Validation:** FluentValidation (if applicable)

### Project Structure

```
src/
  [ProjectName].Core/         # Domain logic, interfaces, CQRS handlers
  [ProjectName].Data/         # Entities, DTOs, DbContext
  [ProjectName].Providers/    # Third-party integrations
  [ProjectName].Service/      # ASP.NET Core application (if web service)
tests/
  [ProjectName].Core.Tests/
  [ProjectName].Data.Tests/
  [ProjectName].Providers.Tests/
```

**Naming rules:**
- Folders: NO `Olbrasoft.` prefix (e.g., `VirtualAssistant.Core/`)
- Namespaces: WITH `Olbrasoft.` prefix (e.g., `Olbrasoft.VirtualAssistant.Core`)

### SOLID Principles (Enforced)

Reference: `~/GitHub/Olbrasoft/engineering-handbook/solid-principles/solid-principles.md`

**Single Responsibility:**
- One class = one reason to change
- Services should do ONE thing (e.g., `ITtsProvider` only synthesizes speech)

**Open/Closed:**
- Extend via inheritance/composition, NOT modification
- Use Strategy pattern for varying behavior

**Liskov Substitution:**
- Derived classes must be substitutable for base
- Don't change expected behavior in overrides

**Interface Segregation:**
- Small, focused interfaces (NOT god interfaces)
- Example: `IRepository<T>` is fine, `IDataAccess` with 30 methods is NOT

**Dependency Inversion:**
- Depend on abstractions (interfaces), not concrete classes
- Constructor injection ONLY (no property/method injection)

### Design Patterns (Expected)

Reference: `~/GitHub/Olbrasoft/engineering-handbook/design-patterns/gof-patterns-design-patterns.md`

**Required patterns in this project:**
- **Repository Pattern:** For all data access (`IRepository<T>`)
- **Strategy Pattern:** For interchangeable algorithms (e.g., [specific example])
- **Factory Pattern:** For creating complex objects (e.g., [specific example])
- **Mediator Pattern:** For CQRS commands/queries (MediatR)
- **Observer Pattern:** For event-driven features (e.g., [specific example])

### Testing Requirements

Reference: `~/GitHub/Olbrasoft/engineering-handbook/development-guidelines/workflow-guide.md`

**Framework:** xUnit + Moq (NEVER NUnit or NSubstitute)

**Coverage:**
- ALL public methods must have tests
- Edge cases and error paths must be tested
- No tests for private methods (test through public API)

**Naming:**
- Test project: `[SourceProject].Tests` (e.g., `VirtualAssistant.Core.Tests`)
- Test class: `[ClassName]Tests` (e.g., `TtsServiceTests`)
- Test method: `[Method]_[Scenario]_[Expected]` (e.g., `SynthesizeAsync_NullText_ThrowsArgumentNullException`)

**Structure:** Separate test project per source project (NO shared test projects!)

### Code Quality Standards

#### Naming Conventions
- **Classes/Interfaces:** PascalCase
  - Interfaces: `I` prefix (e.g., `ITtsProvider`)
  - Implementations: Descriptive name (e.g., `AzureTtsProvider`)
- **Methods:** PascalCase (e.g., `GetCustomerById`)
- **Variables/Parameters:** camelCase (e.g., `customerId`, `isValid`)
- **Constants:** PascalCase (e.g., `MaxRetryCount`)
- **Private fields:** `_camelCase` with underscore (e.g., `_httpClient`)

#### Async/Await
- **ALL I/O operations MUST be async** (DB, HTTP, file system)
- Method suffix: `Async` (e.g., `GetCustomerAsync`)
- **NEVER `async void`** (except event handlers)
- Library code: Use `ConfigureAwait(false)`

#### Null Handling
- **Enable nullable reference types:** `#nullable enable` in all files
- **Validate parameters:** `ArgumentNullException.ThrowIfNull(param)`
- **Return nullable:** Use `Task<T?>` for async methods that may return null

#### Error Handling
- **Libraries:** Throw specific exceptions (`InvalidOperationException`, `ArgumentException`)
- **Services:** Return `Result<T>` or use OneOf pattern
- **APIs:** Use Problem Details (RFC 7807)
- **Always log before throwing/returning errors**

#### Dependency Injection
- **Constructor injection ONLY** (no property/method injection)
- **Register in Program.cs** or dedicated extension methods
- **Lifetimes:**
  - `Scoped`: DbContext, services with DbContext dependency
  - `Transient`: Lightweight services, stateless operations
  - `Singleton`: Stateless services, caches

### Security

- **Secrets:** NEVER hardcoded
  - Development: User Secrets (`dotnet user-secrets`)
  - Production: systemd EnvironmentFile (`~/.config/systemd/user/[service].env`)
- **API Keys:** Load from configuration, validate on startup
- **SQL Injection:** Use parameterized queries (EF Core does this automatically)
- **XSS:** Razor auto-encodes (never use `@Html.Raw` without sanitization)

### Documentation

- **Public APIs:** XML comments with `/// <summary>`, `<param>`, `<returns>`
- **Complex logic:** Inline comments explaining WHY (not WHAT)
- **README.md:** Project overview, setup instructions, dependencies
- **CHANGELOG.md:** Keep updated with significant changes

---

## /code-review Rules

### High Priority Issues (Confidence 100, ALWAYS flag)

- Missing null check on public method parameters
- Async method without `Async` suffix
- `async void` (except event handlers)
- Hardcoded secrets/connection strings/API keys
- SQL string concatenation (SQL injection risk)
- Missing `using` statements (resource leaks)
- Test method without `[Fact]` or `[Theory]` attribute
- Test project incorrectly named (e.g., single `ProjectName.Tests` for multiple source projects)
- SOLID violations with clear evidence (e.g., god class >1000 lines)

### Medium Priority Issues (Confidence 80-90, flag if clear)

- Missing XML documentation on public APIs
- Naming convention violations (PascalCase/camelCase)
- Missing `ConfigureAwait(false)` in library code
- DbContext registered as Transient or Singleton (should be Scoped)
- Exception not logged before throwing
- God interface (>10 methods)
- Method too long (>50 lines, consider refactoring)
- Missing Repository pattern for data access

### Low Priority Issues (Confidence 60-70, flag only if obvious)

- Missing blank lines between method groups
- Long parameter list (>5 params, suggest object)
- Commented-out code (should be removed)
- Magic numbers (suggest constants)
- Duplicate code (suggest extraction)

### Do NOT Flag (False Positives)

- Pre-existing issues not introduced in current PR
- Code that looks odd but is correct for this domain
- Style issues not explicitly mentioned above
- Issues linters will catch (don't run linters)
- Test code being less strict than production code
- Demo/sample projects intentionally breaking rules

---

## Project-Specific Rules

[Add project-specific rules here that differ from general standards]

Example:
```markdown
### Voice Processing
- All voice processing MUST use ONNX models (NOT cloud APIs)
- VAD threshold: 0.5 (do NOT change without approval)
- Audio format: 16kHz, 16-bit, mono PCM

### Database
- PostgreSQL with pgvector extension
- Embeddings: 768 dimensions (nomic-embed-text model)
- Migrations: Applied automatically on startup (no manual run)
```

---

## Dependencies

[List critical dependencies and why they're used]

Example:
```markdown
- **Ollama** (localhost:11434): Embeddings generation (nomic-embed-text)
- **PostgreSQL** (localhost:5432): Database with pgvector for semantic search
- **Azure Speech Service**: TTS/STT (API key in EnvironmentFile)
- **GitHub API**: Issue synchronization (PAT token in EnvironmentFile)
```

---

## Key API Endpoints

[If web service, list important endpoints]

Example:
```markdown
- `GET /api/github/search?q=...`: Semantic issue search
- `POST /api/tts/speak`: Text-to-speech synthesis
- `POST /api/hub/send`: Inter-agent messaging
- `POST /api/tasks/create`: Create task for agents
- `GET /health`: Health check
```

---

## Common Pitfalls

[Document common mistakes specific to this project]

Example:
```markdown
### TTS Provider Implementation
- ALWAYS implement `ITtsProvider` interface
- MUST support cancellation token
- MUST validate input text (not null, max length)
- MUST dispose audio streams

### Database Queries
- Use `.AsNoTracking()` for read-only queries
- Include related entities explicitly (`.Include()`)
- Never execute queries in loops (N+1 problem)
```

---

## Deployment

[Brief deployment notes specific to this project]

Example:
```markdown
- **Deploy path:** `/opt/olbrasoft/virtual-assistant/`
- **Service:** `systemd --user virtual-assistant.service`
- **Logs:** `journalctl --user -u virtual-assistant.service -f`
- **Secrets:** `~/.config/systemd/user/virtual-assistant.env`
- **Deploy script:** `./deploy/deploy.sh`
```

---

## Related Documentation

- Engineering Handbook: `~/GitHub/Olbrasoft/engineering-handbook/`
- SOLID Principles: `~/GitHub/Olbrasoft/engineering-handbook/solid-principles/solid-principles.md`
- Design Patterns: `~/GitHub/Olbrasoft/engineering-handbook/design-patterns/gof-patterns-design-patterns.md`
- Code Review Guide: `~/GitHub/Olbrasoft/engineering-handbook/development-guidelines/code-review-claude.md`
```

---

## Customization Checklist

After copying this template:

- [ ] Replace `[ProjectName]` with actual project name
- [ ] Update architecture details (ASP.NET Core / Worker / Console)
- [ ] Add project-specific patterns under "Design Patterns (Expected)"
- [ ] Document key dependencies with versions
- [ ] List important API endpoints (if applicable)
- [ ] Add deployment-specific details
- [ ] Document common pitfalls for this project
- [ ] Test with `/code-review` command in Claude Code
- [ ] Commit to Git and push

---

**Last updated:** 2025-12-21  
**Template version:** 1.0  
**Compatible with:** Claude Code, Engineering Handbook v2025
