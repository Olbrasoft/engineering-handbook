# CLAUDE.md Best Practices for .NET Projects

How to configure CLAUDE.md files to maximize AI assistant effectiveness for .NET C# development.

## Why CLAUDE.md Matters

CLAUDE.md is your AI assistant's "constitution" - the file that transforms Claude from a generic chatbot into a specialized .NET developer who understands your project's patterns, constraints, and conventions.

**Key benefits:**
- **Compile-time validation** - C#'s strong typing means AI mistakes are caught immediately
- **Consistent code generation** - AI follows your established patterns
- **Reduced iteration** - Clear constraints prevent wrong implementations
- **Team alignment** - Shared context across all developers' AI assistants

## Core Principles

### 1. Be Lean and Token-Efficient

CLAUDE.md content is prepended to every prompt, consuming tokens.

**✅ GOOD: Concise bullet points**
```markdown
## Code Style
- PascalCase for classes, methods, properties
- camelCase for parameters, local variables
- `_camelCase` for private fields
- `Async` suffix for async methods
- `I` prefix for interfaces
```

**❌ WRONG: Verbose paragraphs**
```markdown
## Code Style
In this project, we follow the standard .NET naming conventions. This means that all classes, methods, and properties should use PascalCase naming. When you're writing parameters and local variables, please use camelCase...
```

### 2. Leverage C# Strong Typing in Instructions

C#'s type system is your validation layer. Reference it explicitly.

**✅ GOOD: Type-specific instructions**
```markdown
## Repository Pattern
- All data access via `IRepository<T> where T : IEntity`
- Methods: `GetByIdAsync(TId id)`, `AddAsync(T entity)`, `UpdateAsync(T entity)`
- Return `Task<T?>` for queries that may return null
- Use `AsNoTracking()` for read-only queries
```

**❌ WRONG: Vague instructions**
```markdown
## Data Access
- Use repository pattern
- Methods should be async
- Handle nulls properly
```

### 3. Front-Load Critical Context

Put most important information first - AI prioritizes earlier content.

**✅ GOOD: Priority structure**
```markdown
# Engineering Standards (CRITICAL)
- ALL code MUST follow: ~/GitHub/Olbrasoft/engineering-handbook/
- SOLID Principles: solid-principles/solid-principles.md
- Testing: xUnit + Moq ONLY (NOT NUnit/NSubstitute)

# Architecture
- Pattern: Clean Architecture with CQRS
- DI: Constructor injection only

# Project Structure
[Details...]
```

## File Structure

### Recommended Sections (Priority Order)

```markdown
# Project: [Name]

## Overview
[1-2 sentence description]

## Engineering Standards (CRITICAL - READ FIRST)
- Engineering Handbook: ~/GitHub/Olbrasoft/engineering-handbook/
- SOLID: solid-principles/solid-principles.md
- Git Workflow: development-guidelines/workflow/git-workflow-workflow.md

## .NET Standards
### Architecture
- Clean Architecture + CQRS
- Entity Framework Core
- MediatR for commands/queries

### Project Structure
[Directory layout]

### Naming Conventions
- Classes: PascalCase
- Methods: PascalCase with `Async` suffix
- Private fields: `_camelCase`

### Testing Requirements
- Framework: xUnit + Moq (NEVER NUnit)
- Pattern: `[Method]_[Scenario]_[Expected]`
- Coverage: ALL public methods

## Protected Areas - DO NOT MODIFY
- /Migrations - Database migrations
- /Tests - Test files require approval
- appsettings.json - Configuration needs review

## Dependencies
- PostgreSQL with pgvector
- Ollama (localhost:11434)
- Azure Speech Service (API key in env)

## Common Pitfalls
[Project-specific gotchas]
```

## Advanced Techniques

### Anchor Comments for Local Context

CLAUDE.md alone isn't enough for large codebases. Use anchor comments:

```csharp
// CLAUDE: This legacy method works by coincidence. Do NOT refactor without approval.
public decimal CalculateTax(decimal amount)
{
    // Order of operations matters for rounding
    return Math.Round(amount * 0.21m, 2);
}

// IMPORTANT: VAD threshold tuned for production. Do NOT change.
private const float VadThreshold = 0.5f;

// ANCHOR: Authentication flow - keep JWT logic intact
public async Task<AuthResult> AuthenticateAsync(LoginRequest request)
{
    // ...
}
```

**Why:** As codebase grows, local context prevents AI from making locally bad decisions.

### Import Files for Modularity

```markdown
# Engineering Standards
@~/GitHub/Olbrasoft/engineering-handbook/README.md

# Git Workflow
@development-guidelines/workflow/git-workflow-workflow.md

# Individual Preferences (gitignored)
@CLAUDE.local.md
```

**Benefits:**
- Centralize common rules
- Personal preferences without polluting team config
- Max import depth: 5 hops

### Protected Areas Section

Explicitly forbid AI from touching critical code:

```markdown
## Protected Areas - DO NOT MODIFY

- `/Migrations` - Database migrations are immutable
- `/Tests` - Never modify tests without explicit approval  
- `/Security` - Security code requires manual review
- `appsettings.json` - Configuration changes need approval
- `/legacy` - Legacy code frozen for compatibility

**PR Rejection Rule:** If AI touches protected areas, PR is rejected automatically.
```

### Type-Safe Instructions

```markdown
## Entity Framework
- DbContext: `AppDbContext : DbContext`
- Entities inherit from `BaseEntity` with `Id` property
- Migrations: Auto-applied on startup (DO NOT run manually)
- Queries: Use `.AsNoTracking()` for read-only
- Include pattern: `.Include(o => o.Customer).ThenInclude(c => c.Address)`

## Async/Await Rules
- ALL I/O operations MUST be async
- Method signature: `public async Task<Customer?> GetCustomerAsync(...)`
- Library code: ALWAYS use `ConfigureAwait(false)`
- NEVER `async void` (except event handlers)
```

## .NET-Specific Best Practices

### Dependency Injection Configuration

```markdown
## DI Lifetimes (CRITICAL)
- `Scoped`: DbContext, services with DbContext dependency
- `Transient`: Stateless operations, lightweight services
- `Singleton`: Caches, stateless services, configuration

**WRONG Lifetimes = Runtime Errors:**
- ❌ DbContext as Singleton (concurrency issues)
- ❌ Service with DbContext as Singleton (disposed context)
```

### Testing Standards

```markdown
## Testing (CRITICAL for Code Review)

**Framework:** xUnit + Moq (NEVER NUnit or NSubstitute)

**Project Structure:**
- One test project per source project
- ❌ WRONG: Single `MyApp.Tests` for entire solution
- ✅ CORRECT: `MyApp.Core.Tests`, `MyApp.Data.Tests`, etc.

**Naming:**
- Test class: `[ClassName]Tests` (e.g., `CustomerServiceTests`)
- Test method: `[Method]_[Scenario]_[Expected]`
  - Example: `GetCustomerAsync_InvalidId_ThrowsNotFoundException`

**Coverage:**
- ALL public methods must have tests
- Edge cases and error paths required
- No tests for private methods (test through public API)
```

### Error Handling Patterns

```markdown
## Error Handling

**Libraries:** Throw specific exceptions
```csharp
throw new CustomerNotFoundException($"Customer {id} not found");
```

**Services:** Return `Result<T>` or use OneOf pattern
```csharp
public Result<Order> CreateOrder(CreateOrderRequest request)
{
    if (!IsValid(request))
        return Result<Order>.Failure("Invalid request");
    
    return Result<Order>.Success(order);
}
```

**APIs:** Use Problem Details (RFC 7807)
```csharp
return Problem(
    statusCode: 404,
    title: "Customer not found",
    detail: $"Customer with ID {id} does not exist"
);
```
```

## Security and Secrets

```markdown
## Secrets Management (CRITICAL)

**NEVER commit secrets to repository!**

**Development:**
```bash
dotnet user-secrets set "AzureSpeech:ApiKey" "your-key"
```

**Production (systemd):**
```bash
# File: ~/.config/systemd/user/my-service.env
AZURE_SPEECH_API_KEY=your-key
GITHUB_PAT=ghp_xxxxx
```

**Environment File in .service:**
```ini
[Service]
EnvironmentFile=%h/.config/systemd/user/my-service.env
```

**Validation:**
- Check secrets on startup
- Fail fast if missing
```csharp
var apiKey = configuration["AzureSpeech:ApiKey"]
    ?? throw new InvalidOperationException("Missing AzureSpeech:ApiKey");
```
```

## Multi-Location Strategy

### 1. Global Config (`~/.claude/CLAUDE.md`)

Personal preferences across all projects:

```markdown
# Personal Coding Preferences

- Prefer `var` for local variables (unless type is unclear)
- Use expression-bodied members for simple properties
- File-scoped namespaces (C# 10+)
```

### 2. Project Root (`ProjectName/CLAUDE.md`)

Team-shared project configuration (commit to Git):

```markdown
# Project: VirtualAssistant

## Engineering Standards
@~/GitHub/Olbrasoft/engineering-handbook/README.md

## Architecture
- Clean Architecture + CQRS
- PostgreSQL + pgvector

## Protected Areas
- /Migrations
- /Tests
```

### 3. Local Override (`ProjectName/CLAUDE.local.md`)

Personal project preferences (add to `.gitignore`):

```markdown
# My Personal Preferences for This Project

@~/.claude/my-dotnet-preferences.md

## Custom Commands
- `dotnet watch run --project src/VirtualAssistant.Service`
```

## Code Review Configuration

### High Priority Issues (Always Flag)

```markdown
## Code Review Rules

### High Priority (Confidence 100, ALWAYS flag)

- Missing null check on public method parameters
- Async method without `Async` suffix
- `async void` (except event handlers)
- Hardcoded secrets/API keys
- Missing `using` statements (resource leaks)
- Test without `[Fact]` or `[Theory]` attribute
- Single test project for multi-project solution
- SOLID violations (god class >1000 lines)

### Medium Priority (Confidence 80-90)

- Missing XML docs on public APIs
- Missing `ConfigureAwait(false)` in library code
- DbContext as Transient/Singleton (should be Scoped)
- God interface (>10 methods)
- Method >50 lines (consider refactoring)

### Do NOT Flag (False Positives)

- Pre-existing issues not in current PR
- Test code being less strict
- Domain-specific patterns
```

## Project-Specific Examples

### ASP.NET Core Web Service

```markdown
## API Conventions

**Endpoints:**
- `GET /api/customers/{id}` - Return 200 or 404
- `POST /api/customers` - Return 201 with Location header
- `PUT /api/customers/{id}` - Return 204 (No Content)
- `DELETE /api/customers/{id}` - Return 204

**Validation:**
- Use FluentValidation for request validation
- Return 400 with Problem Details for validation errors

**Authentication:**
- JWT tokens in Authorization header: `Bearer {token}`
- Validate on every request via middleware
```

### Worker Service

```markdown
## Background Processing

**Hosted Service Pattern:**
```csharp
public class OrderProcessorService : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            await ProcessOrdersAsync(stoppingToken);
            await Task.Delay(TimeSpan.FromMinutes(5), stoppingToken);
        }
    }
}
```

**Cancellation:**
- ALWAYS respect `CancellationToken`
- Pass token through entire call chain
```

## Verification Checklist

After creating/updating CLAUDE.md:

- [ ] Token count reasonable (< 2000 tokens for main content)
- [ ] Critical rules at the top
- [ ] Type-specific instructions included
- [ ] Protected areas clearly marked
- [ ] Testing standards explicit (xUnit + Moq)
- [ ] Secrets management documented
- [ ] Project-specific patterns documented
- [ ] Example code uses actual project types
- [ ] File paths are absolute or relative to project root
- [ ] Committed to Git (if team-shared)

## Common Pitfalls

### ❌ WRONG: Too Verbose

```markdown
In this project, we use the Clean Architecture pattern, which was introduced by Robert C. Martin in 2012. Clean Architecture helps us maintain separation of concerns and testability by organizing our code into layers...

[500 more words...]
```

### ✅ CORRECT: Concise

```markdown
## Architecture
- Pattern: Clean Architecture + CQRS
- Layers: Core (domain), Data (EF), Providers (external), Service (API)
- Dependencies flow inward (Core has zero dependencies)
```

### ❌ WRONG: Vague Rules

```markdown
- Write good tests
- Use dependency injection
- Handle errors properly
```

### ✅ CORRECT: Specific Rules

```markdown
## Testing
- Framework: xUnit + Moq (NEVER NUnit)
- Pattern: `GetCustomerAsync_InvalidId_ThrowsNotFoundException`
- Coverage: ALL public methods

## DI
- Constructor injection ONLY
- Validate dependencies in constructor: `?? throw new ArgumentNullException`

## Errors
- Libraries: Throw `CustomerNotFoundException`, `InvalidOrderException`
- Services: Return `Result<T>` with Success/Failure
- APIs: Problem Details with status codes
```

## Advanced: Bespoke Scripts Pattern

Instruct Claude to create throwaway utility scripts:

```markdown
## Utility Scripts

When you need custom tooling, create scripts in `/scripts/temp/`:

**Pattern:**
```bash
#!/usr/bin/env bash
# Purpose: [One-line description]
# Usage: ./scripts/temp/my-script.sh [args]

# Script content...
```

**Examples:**
- Database seed script
- Migration rollback helper
- Log analysis tool

**Location:** `/scripts/temp/` (gitignored)
```

**Benefit:** AI creates tools it can then use, reducing reliance on static MCPs.

## Integration with Engineering Handbook

```markdown
## Engineering Handbook Integration

**CRITICAL:** All code MUST follow handbook standards:

**Handbook location:** `~/GitHub/Olbrasoft/engineering-handbook/`

**Key documents:**
- Workflow: `development-guidelines/workflow/git-workflow-workflow.md`
- SOLID: `development-guidelines/dotnet/solid-principles/solid-principles.md`
- Testing: `development-guidelines/dotnet/testing/index-testing.md`
- CI/CD: `development-guidelines/dotnet/continuous-integration/index-continuous-integration.md`

**Decision tree:** When unsure, check handbook FIRST before implementing.
```

## Continuous Improvement

```markdown
## CLAUDE.md Maintenance

**Monthly review:**
- Remove outdated rules
- Add common pitfalls discovered
- Update dependency versions
- Verify file paths still valid

**After incidents:**
- Document what went wrong
- Add preventive rule to CLAUDE.md
- Example: "After prod bug, added rule: NEVER modify VAD threshold"

**Prompt Improver:**
- Run CLAUDE.md through https://docs.anthropic.com/prompt-improver
- Improves adherence quality
```

## See Also

- [CLAUDE.md Template](../project-setup/project-config-project-setup.md) - Ready-to-use template
- [C# Coding Best Practices](csharp-coding-dotnet.md) - C# conventions
- [Testing Guide](testing/index-testing.md) - xUnit + Moq patterns
- [SOLID Principles](solid-principles/solid-principles.md) - Modern SOLID for .NET
