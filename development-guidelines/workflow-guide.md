# C# .NET Application Workflow Guide

## Creating Issues

When user says "create task/new task" → **ALWAYS create GitHub Issue**:
```bash
gh issue create --repo Owner/Repo --title "Title" --body "Description"
```
- Don't ask, just create it
- **NEVER use checkboxes** - use **sub-issues** instead

---

## C# Unit Testing

**Framework:** xUnit + Moq (ALWAYS, no alternatives)

```csharp
[Fact]
public void MethodName_Scenario_ExpectedResult()
{
    // Arrange, Act, Assert
}
```

**Naming:** `[Method]_[Scenario]_[Expected]`

**Rules:** Each test = ONE thing, isolated (no DB/network/filesystem)

---

## Deployment Workflow

### Before Deploy
1. Check project's `AGENTS.md` for specific rules
2. Run tests: `dotnet test` (ALL must pass)

### Deploy
```bash
dotnet publish src/Project/Project.csproj -c Release -o ~/deploy-target --no-self-contained
systemctl --user restart service.service
systemctl --user status service.service
```

---

## Secrets Management

**🚨 NEVER store secrets in Git!**

| File | In Git? | Secrets? |
|------|---------|----------|
| `appsettings.json` | ✅ Yes | ❌ NO (placeholders only) |
| `appsettings.Development.json` | ❌ No | Local only |
| User Secrets | ❌ No | ✅ Yes |

### User Secrets Setup
```bash
dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:Default" "Host=...;Password=SECRET"
```

**Location:** `~/.microsoft/usersecrets/<id>/secrets.json`

### Config Load Order (later overrides earlier)
1. appsettings.json → 2. appsettings.Development.json → 3. **User Secrets** → 4. Env vars → 5. CLI args

### Production
- Published folder config (not in Git) OR environment variables

---

## Git Workflow

### Rules
- Each issue = separate branch
- **COMMIT + PUSH after every step** (work can be lost!)
- Never commit to `main` directly

### Branch Naming
- `fix/issue-N-desc` | `feature/issue-N-desc` | `enhancement/issue-N-desc`

### Sub-Issues (MANDATORY)
Create sub-issue for each step, close **immediately** after completing:
```bash
gh issue create --repo Owner/Repo --title "Step for #43" --body "Sub-issue for #43"
gh issue close 44 --repo Owner/Repo  # Close immediately when done!
```

### Closing Issue - ALL conditions required:
1. All sub-issues closed
2. All tests pass
3. Code deployed
4. **USER APPROVAL** - ask user to test, wait for confirmation

**NEVER close automatically!** Ask: "Can you test that [feature] works?"
