# C# .NET Application Workflow Guide

Complete guide for .NET development: issues, Git workflow, branches, commits, testing, deployment, and secrets.

---

## GitHub Issues

### Creating Issues

When user says "create task" → **create GitHub Issue** (don't ask, just do it)

Focus on **WHAT** and **WHY**, leave **HOW** to the programmer.

### Issue Template

```markdown
## Summary
[One sentence: What needs to be done and why]

## User Story
As a [persona/role], I want to [action/feature], so that [benefit/value].

## Context
- Current state: [What exists now]
- Problem: [What's wrong or missing]

## Requirements
### Must Have
- [ ] Requirement 1
- [ ] Requirement 2

### Should Have (if time permits)
- [ ] Optional enhancement

## Acceptance Criteria
- [ ] Given [context], when [action], then [expected result]

## Out of Scope
- What this issue does NOT include
```

### Issue Labels

| Label | Use For |
|-------|---------|
| `feature` | New functionality |
| `bug` | Something broken |
| `enhancement` | Improvement to existing feature |
| `refactor` | Code cleanup, no behavior change |
| `docs` | Documentation only |

### GitHub API Pagination Limits

**CRITICAL:** Always use `perPage` parameter when listing issues, PRs, or commits to prevent context overflow.

| Tool | Recommended `perPage` | Use Case |
|------|----------------------|----------|
| `github_list_issues` | 10-20 | Quick overview |
| `github_list_pull_requests` | 10-20 | Recent PRs |
| `github_list_commits` | 10-30 | Commit history |
| `github_search_issues` | 10-20 | Search results |
| `github_search_code` | 10-20 | Code search |

**Rules:**
- **NEVER call without `perPage`** - default returns too many results
- For specific searches, use filters (labels, state, author) + low `perPage`
- For broad searches, start with `perPage: 10`, increase only if needed
- Maximum allowed: 100 (but rarely needed)

**Example - Searching issues:**
```
github_search_issues:
  query: "bug label:high-priority"
  owner: "Olbrasoft"
  repo: "VirtualAssistant"
  perPage: 15  # Always specify!
```

---

## Sub-Issues: Critical Rules

**NEVER use checkboxes** - use **sub-issues** instead.

**Sub-issues MUST be linked via GitHub's native sub-issue feature, NOT as text references.**

### The Wrong Way

Do NOT write these in issue body:
- "Part of #123"
- "Sub-issue of #123"
- "Parent Issue: #123"

This creates NO actual parent-child relationship. It's just text.

### The Correct Way

**Option 1: Via GitHub MCP Server (Recommended)**

GitHub MCP Server (`github/github-mcp-server` v0.24.1+) provides native sub-issues support.

**Creating a sub-issue:**
```
1. Create the child issue using `github_issue_write` (method: create)
   → Returns issue ID (numeric, e.g., 3725925667)

2. Link it to parent using `github_sub_issue_write`:
   - method: "add"
   - owner: "Olbrasoft"
   - repo: "engineering-handbook"
   - issue_number: 4  (parent issue number)
   - sub_issue_id: 3725925667  (child issue ID from step 1)
```

**Reading sub-issues:**
```
Use `github_issue_read` with method: "get_sub_issues"
- owner: "Olbrasoft"
- repo: "engineering-handbook"
- issue_number: 4  (parent issue number)
```

**Available MCP tools for sub-issues:**

| Tool | Method | Description |
|------|--------|-------------|
| `github_issue_read` | `get_sub_issues` | List all sub-issues of a parent |
| `github_sub_issue_write` | `add` | Link existing issue as sub-issue |
| `github_sub_issue_write` | `remove` | Unlink sub-issue from parent |
| `github_sub_issue_write` | `reprioritize` | Change sub-issue order |

⚠️ **Important:** The `sub_issue_id` parameter requires the issue's numeric `id` (from API response), NOT the issue `number` (from URL).

**Option 2: Via GitHub UI**

1. Open the **parent issue**
2. In the right sidebar, find **"Sub-issues"** section
3. Click **"Create sub-issue"** or use the dropdown to add existing issue

### Why Native Sub-Issues Matter

| Aspect | Text Reference | Native Sub-Issue |
|--------|---------------|------------------|
| Progress tracking | Manual counting | Automatic percentage |
| Navigation | Search required | Direct bidirectional links |
| Reporting | Not possible | Built-in summaries |
| Parent completion | Manual verification | Automatic blocking |
| Visibility | Hidden in body text | Prominent in UI |

---

## Branch Strategy

### When to Use Branches

For solo development with AI, branches are useful in specific situations:

| Situation | Use Branch? | Why |
|-----------|-------------|-----|
| Large feature (multi-day) | ✅ Yes | Keep main working while you experiment |
| Risky experiment | ✅ Yes | Easy to abandon if it doesn't work |
| Quick bug fix | ❌ No | Just commit to main |
| Small improvement | ❌ No | Not worth the overhead |
| "I want to save this state" | ✅ Yes | Create branch as a "checkpoint" |

### Practical Branch Naming

```
main (always working)
  │
  ├── feature/voice-recognition  ← big feature, might break things
  │
  ├── experiment/new-ai-model    ← trying something, might abandon
  │
  └── backup/before-refactor     ← checkpoint before risky change
```

**Simple rules:**
- `main` should always work
- Branch when you're not sure something will work
- Delete branches when merged or abandoned

### Branch Naming Convention

| Type | Pattern | Example |
|------|---------|---------|
| Feature | `feature/issue-N-short-desc` | `feature/issue-42-voice-input` |
| Bug fix | `fix/issue-N-short-desc` | `fix/issue-15-null-reference` |
| Experiment | `experiment/desc` | `experiment/new-tts-provider` |
| Backup | `backup/desc` | `backup/before-big-refactor` |

---

## Commit Guidelines

### Commit Size

| Commit Type | Size | Example |
|-------------|------|---------|
| **Atomic** ✅ | 1 logical change | "Add customer validation" |
| **Too big** ❌ | Multiple unrelated changes | "Various fixes and improvements" |
| **Too small** ❌ | Incomplete change | "WIP" |

**Why good commits matter (even solo):**
- Easier to find when bug was introduced (`git bisect`)
- Easier to revert specific changes
- Better history for future reference

### Commit Message Format

```
[Type]: Short description (max 50 chars)

Optional longer explanation if needed.
- What changed
- Why it changed

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Types:**
- `Add` - New feature or file
- `Fix` - Bug fix
- `Update` - Enhancement to existing feature
- `Refactor` - Code cleanup, no behavior change
- `Remove` - Deleting code or files
- `Docs` - Documentation only

### Git Workflow Summary

- Each issue = separate branch (`fix/issue-N-desc`, `feature/issue-N-desc`)
- **COMMIT + PUSH after every step**
- Sub-issues: create for each step, close **immediately** when done
- Close issue only after: all sub-issues closed + tests pass + deployed + **USER APPROVAL**

---

## Self-Review (Before Committing)

When working alone or with AI assistance, you are your own reviewer.

### Quick Self-Check

| Before Commit | Ask Yourself |
|---------------|--------------|
| **Read the diff** | Does every change make sense? |
| **Explain it** | Could I explain this to someone else? |
| **Run it** | Did I actually test this works? |
| **Sleep on it** | Does it still look good after a break? |

### The "Fresh Eyes" Technique

- Take a 15-minute break before reviewing your own code
- Read the code as if you didn't write it
- Ask: "What would confuse me if I saw this in 6 months?"

### Before Every Commit Checklist

- [ ] Code compiles without warnings
- [ ] All tests pass
- [ ] I've read the diff - every change makes sense
- [ ] No hardcoded secrets or connection strings
- [ ] No `Console.WriteLine` debugging left behind
- [ ] No commented-out code

---

## AI-Assisted Development

When using AI (Claude Code, Copilot) for development:

### What AI is Good For

| Good for | Less reliable for |
|----------|-------------------|
| Catching obvious bugs | Business logic correctness |
| Naming suggestions | Architecture decisions |
| Finding code smells | Performance in your specific context |
| Suggesting refactoring | Understanding your domain |
| Security pattern checks | "Does this actually work?" |
| Boilerplate code | Complex integrations |

### Best Practices

- **Always verify** - AI suggestions may look correct but miss context
- **Test everything** - Don't assume generated code works
- **Understand the code** - Don't commit code you don't understand
- **Provide context** - The more context AI has, the better suggestions

### When to Ask AI for Help

| Situation | AI Can Help With |
|-----------|------------------|
| "How do I...?" | Syntax, patterns, examples |
| "What's wrong?" | Error analysis, debugging suggestions |
| "Make this better" | Refactoring, naming, simplification |
| "Is this secure?" | Common vulnerability patterns |

---

## C# Unit Testing

**Framework:** xUnit + Moq (ALWAYS)

**Naming:** `[Method]_[Scenario]_[Expected]`

**Examples:**
- `GetCustomer_WithValidId_ReturnsCustomer`
- `CreateOrder_WithEmptyCart_ThrowsException`
- `CalculateDiscount_ForPremiumMember_Returns20Percent`

---

## Deployment

1. Check project's `AGENTS.md` or `CLAUDE.md`
2. `dotnet test` (ALL must pass)
3. `dotnet publish -c Release -o ~/target`

---

## Secrets Management

**🚨 NEVER store secrets in Git!** [Microsoft Docs](https://learn.microsoft.com/en-us/aspnet/core/security/app-secrets)

### Secrets = passwords, API keys, tokens
### NOT secrets = URLs, ports, DB names, usernames, model names

### Correct Pattern

**appsettings.json** (in Git - connection string WITHOUT password):
```json
{
  "ConnectionStrings": { "Default": "Host=localhost;Database=mydb;Username=user" },
  "GitHub": { "Owner": "Olbrasoft" },
  "OpenAI": { "Model": "gpt-4" }
}
```

**User Secrets** (outside Git - passwords and API keys only):
```bash
dotnet user-secrets init
dotnet user-secrets set "DbPassword" "secret"
dotnet user-secrets set "GitHub:Token" "ghp_xxx"
dotnet user-secrets set "OpenAI:ApiKey" "sk-xxx"
```

**Program.cs** - combine at runtime:
```csharp
var connString = builder.Configuration.GetConnectionString("Default");
var password = builder.Configuration["DbPassword"];
var full = $"{connString};Password={password}";
```

### Config Load Order
appsettings.json → appsettings.Development.json → **User Secrets** → Env vars → CLI args

### Production
Published folder config (not in Git) OR `export DbPassword="prod_secret"`

---

## References

- [GitHub Sub-Issues Documentation](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/adding-sub-issues)
- [Atlassian User Stories Guide](https://www.atlassian.com/agile/project-management/user-stories)
- [Microsoft App Secrets](https://learn.microsoft.com/en-us/aspnet/core/security/app-secrets)
- [Google Engineering Practices - Code Review](https://google.github.io/eng-practices/review/)
