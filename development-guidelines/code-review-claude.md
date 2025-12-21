# Code Review with Claude Code - .NET Projects

**AI Assistant:** Claude Code  
**Configuration file:** `CLAUDE.md` in project root  
**Plugin:** `/code-review` command (built-in)

---

## What is `/code-review`?

Automated PR review using 4 parallel agents:
- **2x Sonnet agents:** CLAUDE.md compliance checking
- **2x Opus agents:** Bug detection and logic analysis
- **Confidence scoring:** 0-100, threshold 80 (filters false positives)
- **Output:** Terminal or GitHub PR comment (`--comment` flag)

---

## Prerequisites

1. **Claude Code installed:** `npm install -g @anthropic-ai/claude-code`
2. **GitHub CLI:** `gh` authenticated (`gh auth login`)
3. **CLAUDE.md exists:** Project root with .NET standards
4. **PR branch checked out:** Local branch corresponding to GitHub PR

---

## .NET-Specific CLAUDE.md Template

Create `CLAUDE.md` in project root with these sections:

### Required Content

```markdown
# Project: [Name]

## .NET Standards (CRITICAL for Code Review)

### Architecture
- Clean Architecture with CQRS pattern
- Dependency Injection via built-in DI container
- Entity Framework Core for data access
- MediatR for commands/queries (if applicable)

### SOLID Principles
**Reference:** ~/GitHub/Olbrasoft/engineering-handbook/solid-principles/solid-principles-2025.md

- Single Responsibility: One class = one reason to change
- Open/Closed: Extend via inheritance/composition, not modification
- Liskov Substitution: Derived classes must be substitutable
- Interface Segregation: Small, focused interfaces (not god interfaces)
- Dependency Inversion: Depend on abstractions, not concretions

### Design Patterns
**Reference:** ~/GitHub/Olbrasoft/engineering-handbook/design-patterns/gof-design-patterns-2025.md

- **Strategy Pattern:** For interchangeable algorithms (e.g., PushToTalk monitors)
- **Factory Pattern:** For object creation with varying types
- **Repository Pattern:** For data access abstraction
- **Mediator Pattern:** For decoupling request/response handling
- **Observer Pattern:** For event-driven architecture

### Testing Requirements
**Reference:** ~/GitHub/Olbrasoft/engineering-handbook/development-guidelines/workflow-guide.md

- **Framework:** xUnit + Moq (NOT NUnit/NSubstitute)
- **Coverage:** All public methods must have tests
- **Naming:** `[Method]_[Scenario]_[Expected]`
- **Structure:** Separate test project per source project
  - Test project: `ProjectName.Tests` (e.g., `TextToSpeech.Core.Tests`)
  - Test class: `ClassNameTests` (e.g., `TtsResultTests`)
  - **NEVER** single shared test project like `ProjectName.Tests` for all

### Code Quality Standards

#### Naming Conventions
- **Classes/Interfaces:** PascalCase (e.g., `ITtsProvider`, `AzureTtsProvider`)
- **Methods:** PascalCase (e.g., `GetCustomerById`)
- **Variables/Parameters:** camelCase (e.g., `customerId`, `isValid`)
- **Constants:** PascalCase (e.g., `MaxRetryCount`)
- **Private fields:** `_camelCase` with underscore (e.g., `_httpClient`)

#### Async/Await
- All I/O operations MUST be async
- Use `ConfigureAwait(false)` in library code
- Methods: `MethodNameAsync` suffix
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

### .NET Version
- **Target:** .NET 10 (`net10.0`)
- **Language version:** Latest C# features
- **Framework:** ASP.NET Core (web), .NET Worker (services)

### File Organization
**Reference:** ~/GitHub/Olbrasoft/engineering-handbook/development-guidelines/dotnet-project-structure.md

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

### Security
- **Secrets:** NEVER in code, use User Secrets (dev) or EnvironmentFile (prod)
- **API keys:** Load from configuration, validate on startup
- **SQL Injection:** Use parameterized queries (EF Core does this)
- **XSS:** Razor automatically encodes (don't use `@Html.Raw` without sanitization)

### Documentation
- **Public APIs:** XML comments (`/// <summary>`)
- **Complex logic:** Inline comments explaining "why" (not "what")
- **README.md:** Project overview, setup instructions
- **CHANGELOG.md:** Keep updated with changes

## Flag These as Errors

### High Priority (Always flag, confidence 100)
- Missing null checks on public method parameters
- Async method without `Async` suffix
- `async void` (except event handlers)
- Hardcoded secrets/connection strings
- SQL concatenation (SQL injection risk)
- Missing using statements (resource leaks)
- Test method without `[Fact]` or `[Theory]` attribute
- Test project named `ProjectName.Tests` when multiple source projects exist

### Medium Priority (Flag if confident, 80-90)
- Missing XML documentation on public APIs
- Variable names not following camelCase
- Class names not following PascalCase
- Missing ConfigureAwait(false) in library code
- DbContext not registered as Scoped
- Exception not logged before throwing
- God interface (>10 methods)
- Method >50 lines (consider refactoring)

### Low Priority (Flag only if obvious, 60-70)
- Missing blank line between method groups
- Long parameter list (>5 parameters, consider object)
- Commented-out code (should be removed)
- Magic numbers (should be constants)

## Do NOT Flag (False Positives)

- Pre-existing issues not introduced in PR
- Code that looks odd but is correct for the domain
- Pedantic style issues not in CLAUDE.md
- Issues linters will catch (no need to run linter)
- Test code less strict than production code
- Demo/sample projects (may intentionally break rules)
```

---

## Usage

### 1. Local Review (Terminal Output)

```bash
# On PR branch
/code-review
```

**Output:** Lists issues in terminal, grouped by confidence score.

### 2. Post to GitHub PR

```bash
/code-review --comment
```

**Output:** Posts inline comments on GitHub PR with:
- File path and line numbers
- Issue description
- Link to code (full SHA + line range)
- Suggestion block (if fix is ≤5 lines)

### 3. Review Existing PR

```bash
# Switch to PR branch
gh pr checkout 123

# Run review
/code-review --comment
```

---

## Agent Behavior

### Agent #1 & #2: CLAUDE.md Compliance (Sonnet)
- **Task:** Check if code follows rules in CLAUDE.md
- **Scope:** Only CLAUDE.md files in same directory or parent directories
- **Validation:** Quotes exact CLAUDE.md rule being violated
- **Confidence:** 80-100 if rule explicitly mentioned, <80 if inferred

### Agent #3 & #4: Bug Detection (Opus)
- **Task:** Find objective bugs (null refs, resource leaks, logic errors)
- **Scope:** Only changed lines (not pre-existing code)
- **Validation:** Can explain why it's a bug without external context
- **Confidence:** 90-100 if definitely a bug, <80 if "might be"

### Validation Agents (Parallel per Issue)
- **Task:** Re-check each flagged issue
- **Criteria:** Does CLAUDE.md actually say this? Is the bug real?
- **Output:** Confidence score 0-100
- **Filter:** Issues <80 are discarded

---

## Example Review Comment

```markdown
## Code review

Found 3 issues:

1. Missing null check for parameter (violates CLAUDE.md: "Validate parameters")

https://github.com/Olbrasoft/VirtualAssistant/blob/abc123.../src/Core/Services/TtsService.cs#L67-L72

```suggestion
public async Task<TtsResult> SynthesizeAsync(string text)
{
    ArgumentNullException.ThrowIfNull(text);
    // existing code...
}
```

2. Async method missing `Async` suffix (violates CLAUDE.md: "Methods: MethodNameAsync suffix")

https://github.com/Olbrasoft/VirtualAssistant/blob/abc123.../src/Core/Services/TtsService.cs#L88-L95

Fix: Rename `Synthesize` to `SynthesizeAsync`

3. Test project incorrectly named (violates CLAUDE.md: "Test project: ProjectName.Tests per source project")

Found: `VirtualAssistant.Tests` (shared test project)  
Expected: `VirtualAssistant.Core.Tests`, `VirtualAssistant.Voice.Tests`, etc.

Fix: Split into separate test projects matching source project structure.
```

---

## Integration with Engineering Handbook

When flagging issues, `/code-review` should reference:

1. **SOLID violations:** Link to `~/GitHub/Olbrasoft/engineering-handbook/solid-principles/solid-principles-2025.md`
2. **Design pattern issues:** Link to `~/GitHub/Olbrasoft/engineering-handbook/design-patterns/gof-design-patterns-2025.md`
3. **Testing issues:** Link to `~/GitHub/Olbrasoft/engineering-handbook/development-guidelines/workflow-guide.md`
4. **Project structure:** Link to `~/GitHub/Olbrasoft/engineering-handbook/development-guidelines/dotnet-project-structure.md`

**Example comment:**
```
Missing Repository pattern for data access (see ~/GitHub/Olbrasoft/engineering-handbook/design-patterns/gof-design-patterns-2025.md#repository)
```

---

## Workflow Integration

### Standard PR Workflow

```bash
# 1. Create branch from issue
git checkout -b feature/issue-123-add-tts

# 2. Implement feature
# ... code changes ...

# 3. Commit and push
git add .
git commit -m "Add: Azure TTS provider"
git push origin feature/issue-123-add-tts

# 4. Create PR
gh pr create --title "Add Azure TTS provider" --body "Closes #123"

# 5. Run local review
/code-review

# 6. Fix issues
# ... code fixes ...

# 7. Post review to PR
/code-review --comment

# 8. Merge when approved
gh pr merge 123 --squash
```

### CI/CD Integration

Add to `.github/workflows/code-review.yml`:

```yaml
name: Automated Code Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Claude Code
        run: npm install -g @anthropic-ai/claude-code
      - name: Run Code Review
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          gh pr checkout ${{ github.event.pull_request.number }}
          claude /code-review --comment
```

---

## Troubleshooting

### Review takes too long
- **Normal for large PRs** (4 agents run in parallel, each analyzes full diff)
- **Solution:** Split large PRs into smaller ones (recommended max: 500 lines)

### Too many false positives
- **Check CLAUDE.md specificity** - vague rules = more false positives
- **Review threshold** - default 80 already filters most
- **Validate flagged issues** - are they actually wrong per CLAUDE.md?

### No review comment posted
**Causes:**
- PR is closed → automatically skipped
- PR is draft → automatically skipped
- PR is trivial (e.g., version bump) → automatically skipped
- Already reviewed → skipped
- No issues ≥80 confidence → nothing to post

### Links don't work in GitHub
**Fix:** Ensure format is exactly:
```
https://github.com/owner/repo/blob/[FULL-SHA]/path/file.ext#L[start]-L[end]
```
- Must use **full SHA** (not abbreviated)
- Must use `#L` notation
- Must include line range with context

---

## Best Practices

1. **Maintain detailed CLAUDE.md** - more specific = better reviews
2. **Run locally first** - fix obvious issues before posting to PR
3. **Trust the 80 threshold** - false positives are filtered
4. **Review agent findings** - use as starting point, not final verdict
5. **Update CLAUDE.md** - if agents miss recurring issues, add explicit rules
6. **Reference handbook** - link to engineering-handbook for detailed guidance
7. **Keep PRs small** - <500 lines = faster, more accurate reviews

---

## Configuration

### Adjust Confidence Threshold

Edit Claude Code plugin at `~/.claude/plugins/code-review/commands/code-review.md`:

```markdown
Filter out any issues with a score less than 80.
```

Change `80` to preferred threshold (recommended range: 70-90).

### Add Custom Agents

Extend review by adding agents in CLAUDE.md:

```markdown
## Custom Review Agents

### Security Agent (Opus)
- Scan for hardcoded secrets
- Check authentication/authorization
- Validate input sanitization
- Check for OWASP Top 10 vulnerabilities

### Performance Agent (Sonnet)
- Flag N+1 query issues
- Check for missing indexes (EF Core)
- Identify blocking I/O in async methods
- Validate caching opportunities
```

---

## See Also

- **Engineering Handbook:** `~/GitHub/Olbrasoft/engineering-handbook/AGENTS.md`
- **SOLID Principles:** `~/GitHub/Olbrasoft/engineering-handbook/solid-principles/solid-principles-2025.md`
- **Design Patterns:** `~/GitHub/Olbrasoft/engineering-handbook/design-patterns/gof-design-patterns-2025.md`
- **Git Workflow:** `~/GitHub/Olbrasoft/engineering-handbook/development-guidelines/workflow-guide.md`
- **Claude Code Docs:** https://docs.anthropic.com/en/docs/claude-code/overview
- **Code Review Plugin:** `~/Stažené/claude-code/plugins/code-review/README.md`

---

**Target framework:** .NET 10  
**Test framework:** xUnit + Moq  
**Architecture:** Clean Architecture + CQRS  
**Last updated:** 2025-12-21
