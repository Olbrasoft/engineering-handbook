# Code Review with Claude Code - .NET Projects

**AI Assistant:** Claude Code  
**Configuration file:** `CLAUDE.md` in project root  
**Plugin:** `/code-review` command (built-in)

---

## What is `/code-review`?

Automated PR review using multiple specialized agents with confidence-based scoring to filter false positives.

### How It Works (Technical Workflow)

**Step 1: Pre-flight Checks**
- Launch haiku agent to check if review is needed
- Skip if: PR is closed, draft, trivial, or already reviewed by Claude
- Check `gh pr view <PR> --comments` for existing Claude comments

**Step 2: Gather CLAUDE.md Files**
- Launch haiku agent to find all relevant CLAUDE.md files
- Root CLAUDE.md (if exists)
- CLAUDE.md files in directories containing modified files

**Step 3: Summarize Changes**
- Launch sonnet agent to view PR and summarize changes
- Provides context for review agents

**Step 4: Parallel Review (4 Agents)**

**Agents #1 & #2: CLAUDE.md Compliance (Sonnet)**
- Audit changes for CLAUDE.md compliance in parallel
- Only consider CLAUDE.md files in same path or parent directories
- Must quote exact rule being violated
- **HIGH SIGNAL ONLY:** Clear, unambiguous violations

**Agent #3: Bug Detection (Opus)**
- Scan for obvious bugs in diff only (no extra context)
- Focus on changed code only
- Flag significant bugs, ignore nitpicks
- Only flag issues validatable from git diff

**Agent #4: Logic Analysis (Opus)**
- Look for security issues, incorrect logic in changed code
- Only issues within changed code
- **HIGH SIGNAL ONLY:** Objective bugs causing runtime errors

**CRITICAL: High Signal Issues Only**
- ✅ Objective bugs with incorrect behavior
- ✅ Clear CLAUDE.md violations (exact rule quotable)
- ❌ Subjective suggestions
- ❌ Style preferences not in CLAUDE.md
- ❌ "Might be" issues
- ❌ Anything requiring interpretation

**Step 5: Validation (Parallel Subagents)**
- For each issue from agents #3 & #4, launch validation subagent
- Opus for bugs, Sonnet for CLAUDE.md violations
- Validate issue is truly a problem with high confidence
- Example: If "variable not defined" → verify actually undefined
- For CLAUDE.md: verify rule is scoped for this file and truly violated

**Step 6: Filter Low-Confidence Issues**
- Remove issues not validated in step 5
- Threshold: 80+ confidence only
- Result: High signal issues for review

**Step 7: Post Review**
- If issues found → post inline comments (step 8)
- If NO issues → post summary comment using `gh pr comment`:
  ```markdown
  ## Code review
  
  No issues found. Checked for bugs and CLAUDE.md compliance.
  ```

**Step 8: Post Inline Comments**
- Use `mcp__github_inline_comment__create_inline_comment`
- **One comment per unique issue** (no duplicates)
- Format:
  - `path`: file path
  - `line` (and `startLine` for ranges): buggy lines
  - `body`: Brief description (no "Bug:" prefix)
  
**For small fixes (≤5 lines):**
```suggestion
corrected code here
```
- Must be COMPLETE (user clicks "Commit suggestion" and it works)
- If fix needs changes elsewhere (e.g., rename all usages) → NO suggestion

**For larger fixes (6+ lines, structural, multiple locations):**
1. Describe issue
2. Explain fix at high level
3. Copyable prompt for Claude Code:
```
Fix [file:line]: [brief description of issue and suggested fix]
```

### Confidence Scoring

- **0**: Not confident, false positive
- **25**: Somewhat confident, might be real
- **50**: Moderately confident, real but minor
- **75**: Highly confident, real and important
- **100**: Absolutely certain, definitely real

**Threshold:** 80 (default, configurable)

### False Positives Filtered (Do NOT Flag)

- Pre-existing issues (not introduced in PR)
- Code that looks like bug but is correct
- Pedantic nitpicks senior engineer wouldn't flag
- Issues linters will catch
- General quality issues (unless in CLAUDE.md)
- Issues with lint ignore comments
- Subjective concerns or suggestions
- Potential issues that "might" be problems

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

**Requirements:**
- Must use **full SHA** (not abbreviated, e.g., `c21d3c10bc8e898b7ac1a2d745bdc9bc4e423afe`)
- Must use `#L` notation (NOT `#`)
- Must include line range: `L[start]-L[end]` format
- Must provide at least 1 line of context before and after the issue
  - Example: Commenting on lines 5-6 → link to `#L4-L7`
- Repository name must match the repository being reviewed
- **NO shell commands in URLs** - Markdown preview won't render:
  - ❌ `blob/$(git rev-parse HEAD)/file.ext` (won't work)
  - ✅ `blob/c21d3c10bc8e898b7ac1a2d745bdc9bc4e423afe/file.ext`

**Example:**
```
https://github.com/anthropics/claude-code/blob/c21d3c10bc8e898b7ac1a2d745bdc9bc4e423afe/package.json#L10-L15
```

### GitHub CLI not working

**Issue**: `gh` commands fail

**Solution:**
- Install GitHub CLI: `brew install gh` (macOS/Linux) or see [GitHub CLI installation](https://cli.github.com/)
- Authenticate: `gh auth login`
- Verify repository has GitHub remote: `git remote -v`

**CRITICAL:** Agents MUST use `gh` CLI for ALL GitHub operations:
- ✅ `gh pr view <PR>`, `gh pr diff <PR>`, `gh pr list`
- ✅ `gh issue view <N>`, `gh issue list`
- ✅ `gh pr comment <PR> --body "..."`
- ❌ NEVER use web fetch/API directly (no authentication context)

**Citation Requirement:**
- Every inline comment MUST cite and link to the source
- CLAUDE.md violations → link to specific CLAUDE.md file
- Bug reports → link to relevant code context
- Format: `See [CLAUDE.md](path/to/CLAUDE.md#L10-L15) for rule`

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
