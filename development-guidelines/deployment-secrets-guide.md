# .NET Deployment & Secrets Guide (Linux)

Best practices for deploying .NET apps on Linux with proper secrets management.

## Core Principles

| Rule | Why |
|------|-----|
| Deploy script receives base dir as argument | Deterministic, automatable |
| Base dir = runtime property, not config | Deploy defines reality, runtime reads it |
| User Secrets (dev) + Env Vars (prod) | Never commit secrets |
| All features 100% functional | "Not configured" = broken app |

## Directory Structure

### ⚠️ IMPORTANT: We Use Production-Only Deployment

**We do NOT have separate dev/staging environments.** All applications run in production mode at `/opt/olbrasoft/<app>/`.

User Secrets are for local development in IDE only. When deploying, ALWAYS deploy to `/opt/olbrasoft/`.

### Production Directory (ONLY deployment target)

```
/opt/olbrasoft/<app>/
├── app/                      # Binaries (AppContext.BaseDirectory)
├── config/                   # appsettings.json (no secrets!)
├── data/                     # Runtime data
├── certs/                    # TLS certificates
└── logs/                     # Application logs
```

**Examples:**
- `/opt/olbrasoft/virtual-assistant/`
- `/opt/olbrasoft/push-to-talk/`
- `/opt/olbrasoft/github-issues/`

### AI Models (Read-Only Data)

| Type | Path | Use Case |
|------|------|----------|
| System-wide | `/usr/share/whisper-models/` | Multi-user, needs sudo |
| User-level | `~/.local/share/whisper-models/` | Single user, no sudo |

## Deploy Script Pattern

### Minimal

```bash
#!/usr/bin/env bash
set -e

BASE_DIR="$1"
[ -z "$BASE_DIR" ] && { echo "Usage: deploy.sh <base-dir>"; exit 1; }

dotnet test --verbosity minimal || exit 1
dotnet publish src/MyApp/MyApp.csproj -c Release -o "$BASE_DIR/app" --no-self-contained

echo "✅ Deployed to $BASE_DIR"
```

**Usage:**
```bash
./deploy/deploy.sh /opt/olbrasoft/myapp
```

### With systemd restart

```bash
dotnet publish src/MyApp/MyApp.csproj -c Release -o "$BASE_DIR/app" --no-self-contained

SERVICE_NAME="myapp.service"
if systemctl --user is-active --quiet "$SERVICE_NAME"; then
    systemctl --user restart "$SERVICE_NAME"
fi
```

## Runtime: AppContext.BaseDirectory

```csharp
// ✅ ONLY correct source of base directory
var baseDir = AppContext.BaseDirectory;  // e.g., /opt/olbrasoft/myapp/app/

// Paths relative to base
var configPath = Path.Combine(baseDir, "../config/appsettings.json");
var dataPath = Path.Combine(baseDir, "../data/mydata.db");
```

❌ **DON'T USE:**
- `Directory.GetCurrentDirectory()` - working dir ≠ base dir
- `Environment.GetEnvironmentVariable("MYAPP_BASE")` - can be missing
- Hardcoded paths

## Secrets Management

### Finding Secrets in Our Projects

| Environment | Location | Command |
|-------------|----------|---------|
| **Development** | User Secrets | `dotnet user-secrets list --project src/<ProjectName>/` |
| **Production** | Startup scripts | `cat ~/.local/bin/<app>-start.sh` |

**Common Secrets:**
- `GitHub:Token` - GitHub PAT (GraphQL API)
- `GitHub:ClientSecret` - OAuth client secret
- `ConnectionStrings:*:Password` - Database passwords
- `AiProviders:*:Keys:*` - AI service API keys

### Development: User Secrets

```bash
# Initialize
cd ~/projects/MyApp/src/MyApp.Web
dotnet user-secrets init

# Set secrets
dotnet user-secrets set "ConnectionStrings:DefaultConnection" \
  "Server=localhost;Database=mydb;User=sa;Password=DevPass123"
dotnet user-secrets set "GitHub:ClientSecret" "ghp_abc123..."
dotnet user-secrets set "OpenAI:ApiKey" "sk-proj-..."

# List all
dotnet user-secrets list

# Location: ~/.microsoft/usersecrets/<UserSecretsId>/secrets.json
```

### Production: Environment Variables

**.NET Core format** (double underscore):
```bash
ConnectionStrings__DefaultConnection="Server=localhost;Database=mydb;User=sa;Password=ProdPass123"
GitHub__ClientSecret="ghp_xyz789..."
OpenAI__ApiKey="sk-proj-..."
```

`__` maps to `:` in JSON config hierarchy.

### Startup Script Pattern

```bash
#!/bin/bash
# app-start.sh

APP_PORT=5156
APP_DIR="/opt/olbrasoft/myapp/app"

# Secrets (NEVER commit this file!)
CONNECTION_STRING="Server=localhost,1433;Database=MyDB;User=sa;Password=Secret123"
GITHUB_TOKEN="ghp_xxx..."
GITHUB_CLIENT_SECRET="abc123..."

cd "$APP_DIR"
pkill -f "MyApp.dll" || true
sleep 1

nohup env ConnectionStrings__DefaultConnection="$CONNECTION_STRING" \
    GitHub__Token="$GITHUB_TOKEN" \
    GitHub__ClientSecret="$GITHUB_CLIENT_SECRET" \
    ASPNETCORE_ENVIRONMENT=Production \
    ASPNETCORE_URLS="http://localhost:$APP_PORT" \
    dotnet MyApp.dll > "$HOME/.local/state/myapp/app.log" 2>&1 &

echo "Started on http://localhost:$APP_PORT"
```

### systemd Service with Env File

**1. Create `/etc/systemd/system/myapp.env`:**
```bash
ConnectionStrings__DefaultConnection=Server=localhost;Database=proddb;User=sa;Password=ProdPass123
OpenAI__ApiKey=sk-proj-xyz789...
```

**2. Set permissions:**
```bash
sudo chmod 600 /etc/systemd/system/myapp.env
sudo chown root:root /etc/systemd/system/myapp.env
```

**3. Reference in service:**
```ini
[Unit]
Description=MyApp Service

[Service]
Type=simple
WorkingDirectory=/opt/olbrasoft/myapp/app
ExecStart=/usr/bin/dotnet /opt/olbrasoft/myapp/app/MyApp.dll
EnvironmentFile=/etc/systemd/system/myapp.env
Environment="ASPNETCORE_ENVIRONMENT=Production"

[Install]
WantedBy=multi-user.target
```

### Config Priority (.NET Core)

```
1. appsettings.json                 (base)
2. appsettings.{Environment}.json   (environment override)
3. User Secrets                     (dev only, ignored in prod)
4. Environment Variables            ← HIGHEST PRIORITY (production)
5. Command-line arguments           (manual override)
```

Environment variables override everything else!

### What Goes Where

**appsettings.json** (can commit):
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=mydb;User=sa;"
  },
  "GitHub": {
    "ClientId": "Ov23liabcdef",
    "Token": "",
    "ClientSecret": ""
  }
}
```

**User Secrets / Env Vars** (NEVER commit):
```bash
# Passwords, tokens, API keys
ConnectionStrings__DefaultConnection="...;Password=Secret123"
GitHub__Token="ghp_xxx..."
GitHub__ClientSecret="abc123..."
```

## GitHub Actions Self-Hosted Runners

### Check Runner Before Creating Workflow

```bash
# 1. List runners
ls -d ~/actions-runner* 2>/dev/null

# 2. Check configuration
cat ~/actions-runner/.runner | grep -E "agentName|gitHubUrl"
cat ~/actions-runner-va/.runner | grep -E "agentName|gitHubUrl"

# 3. Verify active runners
systemctl --user list-units | grep actions.runner
```

**Problem:** Workflow for `Olbrasoft/GitHub.Issues` without registered runner → forever "Queued" (brown dot).

### ⚠️ CRITICAL: PATH and .NET SDK Version

**Symptom:** `error NETSDK1045: Aktuální sada .NET SDK nepodporuje cílení .NET 10.0`

**Cause:** systemd service doesn't have `~/.dotnet` in PATH → uses old system-wide SDK.

**Fix:**
```ini
[Service]
Environment="PATH=/home/user/.dotnet:/home/user/.local/bin:/usr/local/bin:/usr/bin:/bin"
```

`~/.dotnet` MUST be FIRST in PATH!

### Workflow Pattern

```yaml
name: Deploy App

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: self-hosted

    steps:
      - uses: actions/checkout@v4
      - run: dotnet test --configuration Release
      - run: sudo ./deploy/deploy.sh /opt/olbrasoft/myapp
      - run: systemctl --user restart myapp.service
```

## ⚠️ CRITICAL: 100% Functional Application

**🚨 DEPLOYMENT IS NOT COMPLETE UNTIL ALL FEATURES WORK!**

| ❌ UNACCEPTABLE | ✅ CORRECT |
|-----------------|-----------|
| "OAuth doesn't work, but that's expected - ClientSecret not configured" | OAuth MUST work - add ClientSecret to production |
| "AI summary not showing, but it's fine - missing GitHub token" | AI summary MUST work - add GitHub token to production |
| "HTTP 200, so deployment is OK" | HTTP 200 + ALL features tested = OK |

### Rules

1. **NO feature can be non-functional** - if it exists in code, it MUST work in production
2. **All secrets MUST be in production** - if dev uses a secret, prod MUST have it too
3. **"Not configured" = broken app** - NEVER "expected behavior"
4. **Test ALL features** - not just "basic", but COMPLETELY ALL

### Before Claiming "Deployment Complete"

```bash
- [ ] App running (process + HTTP 200)
- [ ] EVERY feature tested and WORKS
- [ ] Login works (if exists)
- [ ] All API endpoints work
- [ ] Database operations work
- [ ] AI/ML features work (if exist)
- [ ] Real-time updates work (SignalR/WebSockets)
```

**If ANYTHING doesn't work → deployment NOT complete!**

## Post-Deployment Verification

### 1. Process Running

```bash
ps aux | grep <dll-name> | grep -v grep
systemctl --user status <service-name>
```

### 2. HTTP Response

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:<port>
# ✅ 200 = OK
# ❌ 500 = running but config error
# ❌ 000 = not running
```

### 3. Visual Check (Playwright)

```bash
mcp__playwright__browser_navigate(url: "http://localhost:<port>")
mcp__playwright__browser_take_screenshot(filename: "verify.png")
```

### 4. Logs

```bash
journalctl --user -u <service> -n 50
# ✅ Look for: "Application started", "Now listening on"
# ❌ Look for: "Failed", "Error", "Exception"
```

### Common Issues

| Problem | Cause | Fix |
|---------|-------|-----|
| Process not running | Restart failed | Check systemd logs |
| HTTP 000 | App not running or wrong port | `ss -tulpn \| grep <port>` |
| HTTP 500 | Config error | Check logs, fix secrets |
| Wrong port | ASPNETCORE_URLS not set | Set env var in startup script |

## Functional Testing (Web Apps)

**⚠️ CRITICAL:** For web apps, it's NOT enough to verify process runs and returns HTTP 200!

### Mandatory Workflow

1. **Create Test Plan** (in CLAUDE.md)
   - List all critical features
   - Specify what each test validates

2. **Run Functional Tests** (Playwright)
   - Navigate to app
   - Test EVERY feature systematically
   - Take screenshots of successful tests

3. **Record Results**
   - ✅ Test passed → continue
   - ❌ Test failed → fix, redeploy, test AGAIN from start

### Example Test Plan

```markdown
1. Authentication
   - Click login button → Verify OAuth flow
   - Tests: Authentication handler

2. Main Functionality
   - Submit form → Verify results displayed
   - Tests: Business logic, database, API

3. Detail View
   - Click item → Verify detail page loads
   - Tests: Routing, data fetching

4. Filtering/Search
   - Use filters → Verify filtering works
   - Tests: Query logic, database

5. AI/External Services
   - Verify AI-generated results displayed
   - Tests: External API integration
```

**Deployment complete = workflow ✅ + process runs ✅ + HTTP 200 ✅ + ALL functional tests pass ✅**

## Deployment Checklist

- [ ] **ALL app features MUST be fully functional in production**
- [ ] **ALL secrets from User Secrets MUST be in production startup script**
- [ ] All tests pass (`dotnet test`)
- [ ] Deploy script receives base dir as argument
- [ ] systemd service has correct `WorkingDirectory`
- [ ] C# code uses `AppContext.BaseDirectory` (not hardcoded path)
- [ ] Data not stored in binaries folder
- [ ] **If using GitHub Actions: Self-hosted runner registered for this repo**
- [ ] **After push to main: Check workflow result** (`gh run watch`)
- [ ] **Post-deployment verification completed** (process, HTTP, logs, Playwright)
- [ ] **Functional testing completed** (all features tested and working)

## References

- [Microsoft: Safe storage of app secrets](https://learn.microsoft.com/en-us/aspnet/core/security/app-secrets)
- [Microsoft: Configuration in ASP.NET Core](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/configuration/)
- [Linux FHS](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html)
- [GitHub Actions Self-Hosted Runners](https://docs.github.com/en/actions/hosting-your-own-runners)
