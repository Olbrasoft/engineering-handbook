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

**Option 1: Via GitHub UI**
1. Open the **child issue** (the one that will become a sub-issue)
2. In the right sidebar, find **"Relationships"** section
3. Click **"Edit Relationships"** button
4. Click **"Add parent"** in the dropdown menu
5. Search for and select the parent issue

Alternative (from parent issue):
1. Open the **parent issue**
2. In the right sidebar, find **"Sub-issues"** section
3. Click **"Create sub-issue"** or use the dropdown to add existing issue

**Option 2: Via GitHub REST API**

⚠️ **Important:** The API requires the issue's numeric `id` (from API response), NOT the issue `number` (from URL).

```bash
# Step 1: Get the sub-issue's numeric ID
curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://api.github.com/repos/OWNER/REPO/issues/ISSUE_NUMBER" | jq '.id'

# Step 2: Add sub-issue to parent
curl -L -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/OWNER/REPO/issues/PARENT_NUMBER/sub_issues" \
  -d '{"sub_issue_id": NUMERIC_ID_FROM_STEP_1}'
```

**Available Sub-Issue API Endpoints:**
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/repos/{owner}/{repo}/issues/{issue_number}/parent` | Get parent issue |
| GET | `/repos/{owner}/{repo}/issues/{issue_number}/sub_issues` | List sub-issues |
| POST | `/repos/{owner}/{repo}/issues/{issue_number}/sub_issues` | Add sub-issue |
| DELETE | `/repos/{owner}/{repo}/issues/{issue_number}/sub_issue` | Remove sub-issue |
| PATCH | `/repos/{owner}/{repo}/issues/{issue_number}/sub_issues/priority` | Reprioritize |

See: https://docs.github.com/en/rest/issues/sub-issues

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
