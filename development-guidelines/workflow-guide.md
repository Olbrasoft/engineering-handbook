# .NET Workflow Guide

Issues, branches, commits, testing, deployment, secrets.

## GitHub Issues

"Create task" → create GitHub Issue immediately. Focus on WHAT/WHY, not HOW.

### Issue Template
```markdown
## Summary
[What + why in one sentence]

## User Story
As [role], I want [action], so that [benefit].

## Requirements
### Must Have
- [ ] Requirement 1
### Should Have
- [ ] Optional

## Acceptance Criteria
- [ ] Given [context], when [action], then [result]
```

### Labels
`feature` | `bug` | `enhancement` | `refactor` | `docs`

### API Pagination

**ALWAYS use `perPage` parameter** to prevent context overflow.

| Tool | perPage |
|------|---------|
| list_issues/PRs | 10-20 |
| list_commits | 10-30 |
| search_* | 10-20 |

Never call without `perPage`. Max 100, rarely needed.

## Sub-Issues

**NEVER use checkboxes** → use native sub-issues.

**WRONG:** "Part of #123" in body (just text, no relationship)

**CORRECT:** Use GitHub MCP Server:
```
1. github_issue_write (method: create) → returns issue ID
2. github_sub_issue_write:
   - method: "add"
   - issue_number: 4 (parent)
   - sub_issue_id: 3725925667 (child ID, NOT number)
```

| Tool | Method | Purpose |
|------|--------|---------|
| `github_issue_read` | `get_sub_issues` | List sub-issues |
| `github_sub_issue_write` | `add` | Link sub-issue |
| `github_sub_issue_write` | `remove` | Unlink |
| `github_sub_issue_write` | `reprioritize` | Reorder |

⚠️ `sub_issue_id` = numeric ID from API, NOT issue number from URL

## Branches

### When to Branch

| Situation | Branch? |
|-----------|---------|
| Large feature (multi-day) | ✅ |
| Risky experiment | ✅ |
| Quick fix | ❌ |
| Small improvement | ❌ |
| Save state checkpoint | ✅ |

### Naming
| Type | Pattern |
|------|---------|
| Feature | `feature/issue-N-desc` |
| Fix | `fix/issue-N-desc` |
| Experiment | `experiment/desc` |
| Backup | `backup/desc` |

Rules: `main` always works, branch when unsure, delete when done.

## Commits

### Size
| Type | Example |
|------|---------|
| Atomic ✅ | "Add customer validation" |
| Too big ❌ | "Various fixes" |
| Too small ❌ | "WIP" |

### Message Format
```
[Type]: Short description (50 chars)

🤖 Generated with [Claude Code](https://claude.com/claude-code)
Co-Authored-By: Claude <noreply@anthropic.com>
```

Types: `Add` | `Fix` | `Update` | `Refactor` | `Remove` | `Docs`

### Workflow
- Issue = branch (`feature/issue-N-desc`)
- **COMMIT + PUSH after every step**
- Close sub-issues immediately when done
- Close issue only after: sub-issues closed + tests pass + deployed + **USER APPROVAL**

## Self-Review

| Before Commit | Check |
|---------------|-------|
| Read diff | Every change makes sense? |
| Explain it | Could explain to someone? |
| Run it | Actually tested? |

**Checklist:**
- [ ] Compiles without warnings
- [ ] Tests pass
- [ ] Diff reviewed
- [ ] No secrets/connection strings
- [ ] No Console.WriteLine debug
- [ ] No commented code

## AI-Assisted Dev

| AI Good For | Less Reliable |
|-------------|---------------|
| Obvious bugs | Business logic |
| Naming | Architecture |
| Code smells | Your domain context |
| Refactoring | "Does it work?" |
| Boilerplate | Complex integrations |

**Rules:** Always verify, test everything, understand code before commit, provide context.

## Testing

**Framework:** xUnit + Moq

**Naming:** `[Method]_[Scenario]_[Expected]`

Examples: `GetCustomer_ValidId_Returns`, `CreateOrder_EmptyCart_Throws`

## Deployment

1. Check `CLAUDE.md`
2. `dotnet test` (all pass)
3. `dotnet publish -c Release -o ~/target`

## Secrets

**🚨 NEVER in Git:** passwords, API keys, tokens

**OK in Git:** URLs, ports, DB names, usernames

### Pattern
**appsettings.json** (Git):
```json
{"ConnectionStrings": {"Default": "Host=localhost;Database=mydb;Username=user"}}
```

**User Secrets** (not Git):
```bash
dotnet user-secrets set "DbPassword" "secret"
dotnet user-secrets set "GitHub:Token" "ghp_xxx"
```

**Program.cs:**
```csharp
var conn = config.GetConnectionString("Default");
var pwd = config["DbPassword"];
var full = $"{conn};Password={pwd}";
```

**Load order:** appsettings → appsettings.Dev → User Secrets → Env vars → CLI
