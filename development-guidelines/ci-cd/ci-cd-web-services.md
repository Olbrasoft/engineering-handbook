# CI/CD for Web Services

Deploying ASP.NET Core web services to local Linux server with systemd.

## When to Use
- Project type: ASP.NET Core (API/SignalR/Blazor Server)
- Distribution: Local server deployment
- Examples: VirtualAssistant, GitHub.Issues

## Deployment Architecture

```
/opt/olbrasoft/<app>/
├── app/           # Binaries (dotnet publish output)
├── config/        # appsettings.json (no secrets!)
├── data/          # Runtime data (DB, files)
├── certs/         # TLS certificates
└── logs/          # Application logs
```

## Deploy Script Pattern

```bash
#!/usr/bin/env bash
set -e

BASE_DIR="$1"
[ -z "$BASE_DIR" ] && { echo "Usage: deploy.sh <base-dir>"; exit 1; }

dotnet test --verbosity minimal || exit 1
dotnet publish src/MyApp/MyApp.csproj -c Release -o "$BASE_DIR/app" --no-self-contained

SERVICE_NAME="myapp.service"
if systemctl --user is-active --quiet "$SERVICE_NAME"; then
    systemctl --user restart "$SERVICE_NAME"
fi

echo "✅ Deployed to $BASE_DIR"
```

**Usage:**
```bash
./deploy/deploy.sh /opt/olbrasoft/myapp
```

## Secrets Management

### Development (User Secrets)
```bash
cd ~/projects/MyApp/src/MyApp
dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Server=localhost;Database=mydb;Password=DevPass"
dotnet user-secrets set "GitHub:Token" "ghp_xxx..."
```

### Production (systemd EnvironmentFile)

**1. Create `~/.config/systemd/user/myapp.env`:**
```bash
ConnectionStrings__DefaultConnection=Server=localhost;Database=prod;Password=ProdPass
GitHub__Token=ghp_xxx...
AzureTTS__SubscriptionKey=abc123...
```

**2. systemd service:**
```ini
[Unit]
Description=MyApp Service

[Service]
WorkingDirectory=/opt/olbrasoft/myapp/app
ExecStart=/usr/bin/dotnet /opt/olbrasoft/myapp/app/MyApp.dll
EnvironmentFile=%h/.config/systemd/user/myapp.env
Environment="ASPNETCORE_ENVIRONMENT=Production"

[Install]
WantedBy=default.target
```

**Note:** Double underscore `__` maps to `:` in JSON config hierarchy.

## Config Priority (Lowest to Highest)

```
1. appsettings.json
2. appsettings.{Environment}.json
3. User Secrets (dev only)
4. Environment Variables ← PRODUCTION (overrides all)
5. Command-line args
```

## Runtime Path Resolution

```csharp
// ✅ CORRECT - Use AppContext.BaseDirectory
var baseDir = AppContext.BaseDirectory;  // /opt/olbrasoft/myapp/app/
var configPath = Path.Combine(baseDir, "../config/appsettings.json");
var dataPath = Path.Combine(baseDir, "../data/app.db");
```

❌ **DON'T USE:**
- `Directory.GetCurrentDirectory()` - working dir ≠ base dir
- `Environment.GetEnvironmentVariable("APP_BASE")` - can be missing
- Hardcoded paths like `/opt/olbrasoft/myapp`

## GitHub Actions (Self-Hosted Runner)

### Check Runner Before Creating Workflow

```bash
# List runners
ls -d ~/actions-runner* 2>/dev/null

# Check configuration
cat ~/actions-runner/.runner | grep -E "agentName|gitHubUrl"

# Verify active
systemctl --user list-units | grep actions.runner
```

### Workflow Example

```yaml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - run: dotnet test -c Release
      - run: sudo ./deploy/deploy.sh /opt/olbrasoft/myapp
      - run: systemctl --user restart myapp.service
```

### Critical: PATH Environment

**Problem:** `error NETSDK1045: Current .NET SDK doesn't support .NET 10.0`

**Cause:** systemd service doesn't have `~/.dotnet` in PATH.

**Fix:**
```ini
[Service]
Environment="PATH=/home/user/.dotnet:/home/user/.local/bin:/usr/local/bin:/usr/bin:/bin"
```

`~/.dotnet` MUST be FIRST!

## Deployment Verification

### 1. Process Running
```bash
systemctl --user status myapp.service
ps aux | grep MyApp.dll | grep -v grep
```

### 2. HTTP Response
```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:5055
# ✅ 200 = OK
# ❌ 500 = config error
# ❌ 000 = not running
```

### 3. Logs
```bash
journalctl --user -u myapp.service -n 50
# Look for: "Application started", "Now listening on"
# Avoid: "Failed", "Error", "not configured"
```

## Critical Rule: 100% Functional

**🚨 Deployment NOT complete until ALL features work!**

| ❌ UNACCEPTABLE | ✅ CORRECT |
|-----------------|-----------|
| "OAuth doesn't work - ClientSecret not configured" | OAuth MUST work |
| "HTTP 200 so deployment is OK" | HTTP 200 + ALL features tested |

### Checklist Before "Deployment Complete"

- [ ] App running (process + HTTP 200)
- [ ] EVERY feature tested and works
- [ ] Login works (if exists)
- [ ] All API endpoints work
- [ ] Database operations work
- [ ] AI/ML features work
- [ ] Real-time updates work (SignalR/WebSockets)

**If ANYTHING doesn't work → deployment NOT complete!**

## Common Issues

| Problem | Cause | Fix |
|---------|-------|-----|
| Process not running | Restart failed | Check systemd logs |
| HTTP 000 | App not listening | `ss -tulpn \| grep <port>` |
| HTTP 500 | Config error | Check logs, verify secrets |
| "Not configured" errors | Missing secrets | Add to EnvironmentFile |

## Checklist

- [ ] Deploy script receives base dir as argument
- [ ] systemd service has `WorkingDirectory` and `EnvironmentFile`
- [ ] C# code uses `AppContext.BaseDirectory`
- [ ] ALL secrets from User Secrets in production EnvironmentFile
- [ ] Self-hosted runner registered (if using GitHub Actions)
- [ ] Post-deployment: process + HTTP + logs + ALL features tested

## Reference

- [VirtualAssistant deploy script](https://github.com/Olbrasoft/VirtualAssistant/blob/main/deploy/deploy.sh)
- [Microsoft: ASP.NET Core Deployment](https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/)
- [systemd User Services](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
