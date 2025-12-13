# C# .NET Application Workflow Guide

Complete guide for .NET development: issues, Git workflow, testing, deployment, and secrets.

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

## Git Workflow

- Each issue = separate branch (`fix/issue-N-desc`, `feature/issue-N-desc`)
- **COMMIT + PUSH after every step**
- Sub-issues: create for each step, close **immediately** when done
- Close issue only after: all sub-issues closed + tests pass + deployed + **USER APPROVAL**

---

## Issue Writing Principles

### DO
- Write from user's perspective
- Write implementation-neutral requirements (WHAT, not HOW)
- Include acceptance criteria
- Prioritize requirements (must have / should have)
- Break large issues into smaller sub-issues
- **LINK sub-issues properly using GitHub's native feature**

### DON'T
- Specify database schema or table structure
- Choose frameworks or libraries
- Define API endpoint paths or HTTP methods
- Make architectural decisions
- Use ambiguous language ("should work", "might need")
- **Write "Part of #X" instead of actually linking sub-issues**

### Checklist Before Creating Issue

- [ ] Can be understood without additional context?
- [ ] No ambiguous terms?
- [ ] WHO benefits is clear?
- [ ] WHAT needs to be done is defined?
- [ ] WHY it's needed is explained?
- [ ] Acceptance criteria are measurable?
- [ ] Issue is small enough to complete in one session?
- [ ] If sub-issue, is it LINKED (not just referenced) to parent?

---

## C# Unit Testing

**Framework:** xUnit + Moq (ALWAYS)

**Naming:** `[Method]_[Scenario]_[Expected]`

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
