# Code Review Standards - .NET Projects

**Purpose:** Define what to check during code review  
**Applies to:** All code reviews (automated and manual)  
**Configuration:** Project-specific `CLAUDE.md` files

---

## Overview

Code review ensures code quality, adherence to standards, and catches bugs before merge. Reviews should focus on **high-signal issues** - objective problems that impact functionality, security, or maintainability.

### What to Review

✅ **Always review:**
- Bugs and logic errors
- Security vulnerabilities
- SOLID principle violations
- Design pattern misuse
- Test coverage and quality
- Code style violations (per CLAUDE.md)

❌ **Do NOT flag:**
- Pre-existing issues (not introduced in PR)
- Subjective style preferences (unless in CLAUDE.md)
- Pedantic nitpicks
- Issues linters will catch
- Code that looks odd but is correct

---

## .NET Code Review Standards

### Architecture & Design

**Clean Architecture + CQRS**
- Domain logic in Core layer
- Data access via Repository pattern
- Commands/Queries via MediatR (if applicable)
- Dependency Injection for all services

**SOLID Principles**  
Reference: [solid-principles.md](../../solid-principles/solid-principles.md)

- **Single Responsibility:** One class = one reason to change
- **Open/Closed:** Extend via inheritance/composition, not modification
- **Liskov Substitution:** Derived classes must be substitutable
- **Interface Segregation:** Small, focused interfaces (not god interfaces)
- **Dependency Inversion:** Depend on abstractions, not concretions

**Design Patterns**  
Reference: [gof-design-patterns.md](../../design-patterns/gof-design-patterns.md)

- **Strategy:** Interchangeable algorithms
- **Factory:** Object creation with varying types
- **Repository:** Data access abstraction
- **Mediator:** Decoupling request/response handling
- **Observer:** Event-driven architecture

---

### Testing Standards

Reference: [Git Workflow](../workflow/git-workflow-workflow.md)

**Framework:** xUnit + Moq (NOT NUnit/NSubstitute)

**Structure:**
- Separate test project per source project
- Test project: `{SourceProject}.Tests` (e.g., `TextToSpeech.Core.Tests`)
- Test class: `{SourceClass}Tests` (e.g., `TtsResultTests`)
- **NEVER** single shared test project for multiple source projects

**Coverage:**
- All public methods must have tests
- Test naming: `[Method]_[Scenario]_[Expected]`

---

### Code Quality Standards

#### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Classes/Interfaces | PascalCase | `ITtsProvider`, `AzureTtsProvider` |
| Methods | PascalCase | `GetCustomerById` |
| Variables/Parameters | camelCase | `customerId`, `isValid` |
| Constants | PascalCase | `MaxRetryCount` |
| Private fields | `_camelCase` | `_httpClient` |

#### Async/Await

- All I/O operations MUST be async
- Methods: `MethodNameAsync` suffix
- Use `ConfigureAwait(false)` in library code
- Avoid `async void` (except event handlers)

#### Null Handling

- Use nullable reference types (`#nullable enable`)
- Validate parameters: `ArgumentNullException.ThrowIfNull(param)`
- Return `Task<T?>` for nullable async results

#### Error Handling

- **Libraries:** Throw specific exceptions (e.g., `InvalidOperationException`)
- **Services:** Return `Result<T>` or `OneOf<TSuccess, TError>`
- **APIs:** Use Problem Details (RFC 7807)
- Log exceptions before throwing/returning

#### Dependency Injection

- Constructor injection (NOT property/method injection)
- Register services in `Program.cs` or extension methods
- Scoped for DbContext, Transient for lightweight, Singleton for stateless

---

### .NET Version & Framework

- **Target:** .NET 10 (`net10.0`)
- **Language:** Latest C# features
- **Framework:** ASP.NET Core (web), .NET Worker (services)

---

### File Organization

Reference: [structure.md](../project-structure.md)

```
src/
  ProjectName.Core/         # Domain logic, interfaces
  ProjectName.Data/         # DTOs, entities
  ProjectName.Providers/    # Implementations
tests/
  ProjectName.Core.Tests/
  ProjectName.Providers.Tests/
```

**Naming:**
- **Folders:** NO `Olbrasoft.` prefix (e.g., `SystemTray.Linux/`)
- **Namespaces:** WITH `Olbrasoft.` prefix (e.g., `Olbrasoft.SystemTray.Linux`)

---

### Security Standards

- **Secrets:** NEVER in code
  - Development: User Secrets (`dotnet user-secrets`)
  - Production: EnvironmentFile (systemd) or Key Vault
- **API keys:** Load from configuration, validate on startup
- **SQL Injection:** Use parameterized queries (EF Core does this)
- **XSS:** Razor automatically encodes (don't use `@Html.Raw` without sanitization)

---

### Documentation Standards

- **Public APIs:** XML comments (`/// <summary>`)
- **Complex logic:** Inline comments explaining "why" (not "what")
- **README.md:** Project overview, setup instructions
- **CHANGELOG.md:** Keep updated with changes

---

## Review Priority Levels

### High Priority (Always Flag)

These issues MUST be caught in review:

- Missing null checks on public method parameters
- Async method without `Async` suffix
- `async void` (except event handlers)
- Hardcoded secrets/connection strings
- SQL concatenation (SQL injection risk)
- Missing `using` statements (resource leaks)
- Test method without `[Fact]` or `[Theory]` attribute
- Test project named `ProjectName.Tests` when multiple source projects exist

### Medium Priority (Flag if Confident)

Flag these if violation is clear:

- Missing XML documentation on public APIs
- Variable names not following camelCase
- Class names not following PascalCase
- Missing `ConfigureAwait(false)` in library code
- DbContext not registered as Scoped
- Exception not logged before throwing
- God interface (>10 methods)
- Method >50 lines (consider refactoring)

### Low Priority (Flag Only if Obvious)

Minor issues, flag only if clearly wrong:

- Missing blank line between method groups
- Long parameter list (>5 parameters, consider object)
- Commented-out code (should be removed)
- Magic numbers (should be constants)

---

## False Positives - Do NOT Flag

**NEVER flag these:**

- Pre-existing issues not introduced in PR
- Code that looks odd but is correct for the domain
- Pedantic style issues not in CLAUDE.md
- Issues linters will catch (no need to run linter)
- Test code less strict than production code
- Demo/sample projects (may intentionally break rules)
- Issues mentioned in CLAUDE.md but explicitly silenced in code (e.g., via lint ignore comment)

---

## Project-Specific CLAUDE.md Template

Create `CLAUDE.md` in project root to customize review standards:

### Minimal Template

```markdown
# Project: [Name]

**Target:** .NET 10  
**Architecture:** Clean Architecture + CQRS  
**Testing:** xUnit + Moq

## Standards

Follow standards from:
- ~/GitHub/Olbrasoft/engineering-handbook/development-guidelines/code-review/code-review.md
- ~/GitHub/Olbrasoft/engineering-handbook/solid-principles/solid-principles.md
- ~/GitHub/Olbrasoft/engineering-handbook/design-patterns/gof-design-patterns.md

## Project-Specific Rules

### High Priority (Always Flag)
- [Add project-specific critical rules]

### Medium Priority (Flag if Confident)
- [Add project-specific important rules]

### Low Priority (Flag Only if Obvious)
- [Add project-specific nice-to-have rules]

## Do NOT Flag
- [Add project-specific exceptions]
```

### Full Template

For complete template with all .NET standards, see lines 139-279 in previous version of this file, or create issue asking for full CLAUDE.md template.

---

## Integration with Engineering Handbook

When documenting issues, reference relevant handbook sections:

| Issue Type | Reference |
|------------|-----------|
| SOLID violations | [solid-principles.md](../../solid-principles/solid-principles.md) |
| Design patterns | [gof-design-patterns.md](../../design-patterns/gof-design-patterns.md) |
| Testing | [Testing Guide](../testing/index-testing.md) |
| Project structure | [structure.md](../project-structure.md) |
| CI/CD | [Continuous Integration](../continuous-integration/index-continuous-integration.md) |

**Example:**
```
Missing Repository pattern for data access (see design-patterns/gof-design-patterns.md#repository)
```

---

## Best Practices

1. **Focus on high-signal issues** - objective problems, not opinions
2. **Quote exact rules** - when flagging CLAUDE.md violations, cite the specific rule
3. **Provide context** - explain why something is wrong, link to handbook
4. **Be specific** - "Missing null check on line 67" not "Improve error handling"
5. **Suggest fixes** - when possible, show how to fix the issue
6. **Trust the domain** - code that looks odd might be correct for business logic

---

## See Also

- **Engineering Handbook:** [README.md](../../README.md)
- **SOLID Principles:** [solid-principles.md](../../solid-principles/solid-principles.md)
- **Design Patterns:** [gof-design-patterns.md](../../design-patterns/gof-design-patterns.md)
- **Git Workflow:** [Git Workflow](../workflow/git-workflow-workflow.md)
- **Project Structure:** [structure.md](../project-structure.md)

---

**Target framework:** .NET 10  
**Test framework:** xUnit + Moq  
**Architecture:** Clean Architecture + CQRS  
**Last updated:** 2025-12-21
