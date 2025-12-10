# C# .NET Application Workflow Guide

## Creating Issues
When user says "create task" → **create GitHub Issue** (don't ask, just do it)
- **NEVER use checkboxes** - use **sub-issues** instead

## C# Unit Testing
**Framework:** xUnit + Moq (ALWAYS) | **Naming:** `[Method]_[Scenario]_[Expected]`

## Deployment
1. Check project's `AGENTS.md` | 2. `dotnet test` (ALL must pass) | 3. `dotnet publish -c Release -o ~/target`

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

## Git Workflow
- Each issue = separate branch (`fix/issue-N-desc`, `feature/issue-N-desc`)
- **COMMIT + PUSH after every step**
- Sub-issues: create for each step, close **immediately** when done
- Close issue only after: all sub-issues closed + tests pass + deployed + **USER APPROVAL**
