# Web Services Deployment

How to deploy ASP.NET Core web services to local Linux server with systemd.

## When to Use

- **Project type:** ASP.NET Core (API, SignalR, Blazor Server)
- **Target:** Local Linux server (`/opt/olbrasoft/<app>/`)
- **Examples:** VirtualAssistant, GitHub.Issues

## Prerequisites

Before deployment:
- ✅ Build succeeds (see [../continuous-integration/build.md](../continuous-integration/build.md))
- ✅ Tests pass (see [../continuous-integration/test.md](../continuous-integration/test.md))
- ✅ All secrets configured in production EnvironmentFile

## Deployment Directory Structure

```
/opt/olbrasoft/<app>/
├── app/           # Binaries (dotnet publish output)
├── config/        # appsettings.json (NO secrets!)
├── data/          # Runtime data (database, uploaded files)
├── certs/         # TLS certificates
└── logs/          # Application logs
```

## Deploy Script

**File:** `deploy/deploy.sh`

```bash
#!/usr/bin/env bash
set -e  # Exit on error

BASE_DIR="$1"
[ -z "$BASE_DIR" ] && { echo "Usage: deploy.sh <base-dir>"; exit 1; }

# Publish to target directory
dotnet publish src/MyApp/MyApp.csproj \
  -c Release \
  -o "$BASE_DIR/app" \
  --no-self-contained

# Restart service if running
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

**🚨 CRITICAL: Secrets MUST be in production EnvironmentFile, NOT in appsettings.json!**

### Development - User Secrets

```bash
cd src/MyApp
dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Server=localhost;..."
dotnet user-secrets set "GitHub:Token" "ghp_xxx"
```

### Production - systemd EnvironmentFile

**1. Create secrets file:**

**File:** `~/.config/systemd/user/myapp.env`

```bash
# Database
ConnectionStrings__DefaultConnection=Server=localhost;Database=prod;Password=xxx

# GitHub API
GitHub__Token=ghp_xxxxx

# Azure TTS
AzureTTS__SubscriptionKey=abc123
AZURE_SPEECH_REGION=westeurope
```

**Note:** Double underscore `__` replaces `:` in config hierarchy.

**2. Reference in systemd service:**

**File:** `~/.config/systemd/user/myapp.service`

```ini
[Unit]
Description=MyApp Service

[Service]
WorkingDirectory=/opt/olbrasoft/myapp/app
ExecStart=/usr/bin/dotnet /opt/olbrasoft/myapp/app/MyApp.dll
EnvironmentFile=%h/.config/systemd/user/myapp.env
Environment="ASPNETCORE_ENVIRONMENT=Production"
Environment="PATH=/home/user/.dotnet:/usr/local/bin:/usr/bin:/bin"

[Install]
WantedBy=default.target
```

**Reload after changes:**
```bash
systemctl --user daemon-reload
systemctl --user restart myapp.service
```

## GitHub Actions Deployment

**File:** `.github/workflows/deploy.yml`

```yaml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: self-hosted  # MUST use self-hosted runner!
    steps:
      - uses: actions/checkout@v4

      # Build and test first
      - run: dotnet restore
      - run: dotnet build -c Release --no-restore
      - run: dotnet test -c Release --no-build

      # Deploy
      - run: ./deploy/deploy.sh /opt/olbrasoft/myapp
      - run: systemctl --user restart myapp.service
```

**Setup self-hosted runner:** See [GitHub self-hosted runner docs](https://docs.github.com/en/actions/hosting-your-own-runners)

## Deployment Verification

**After deployment, VERIFY:**

### 1. Process Running

```bash
systemctl --user status myapp.service
# Should show: Active: active (running)
```

### 2. HTTP Response

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:5055
# ✅ 200 = OK
# ❌ 500 = Configuration error (check logs)
# ❌ 000 = Not running
```

### 3. Application Logs

```bash
journalctl --user -u myapp.service -n 50
```

**Look for:**
- ✅ "Application started"
- ✅ "Now listening on http://localhost:5055"

**Avoid:**
- ❌ "Failed to start"
- ❌ "not configured"
- ❌ "Error"

## Critical Rule: 100% Functional

**🚨 Deployment is NOT complete until ALL features work!**

| ❌ WRONG | ✅ CORRECT |
|----------|-----------|
| "App returns HTTP 200 so it's deployed" | "ALL features tested and working" |
| "OAuth doesn't work - will fix later" | "OAuth MUST work before completing deployment" |

### Pre-Completion Checklist

- [ ] Process running (`systemctl status`)
- [ ] HTTP 200 response
- [ ] ALL features tested:
  - [ ] Login/authentication works
  - [ ] All API endpoints respond correctly
  - [ ] Database operations work
  - [ ] External integrations work (GitHub API, Azure TTS, etc.)
  - [ ] Real-time features work (SignalR/WebSockets)
- [ ] No errors in logs

**If ANY feature doesn't work → Deployment NOT complete!**

## Common Issues

| Problem | Cause | Fix |
|---------|-------|-----|
| Process not running | systemd service failed | `journalctl --user -u myapp.service` |
| HTTP 000 | App not listening | Check port with `ss -tulpn \| grep 5055` |
| HTTP 500 | Configuration error | Check logs, verify all secrets in EnvironmentFile |
| "Not configured" errors | Missing secrets | Add ALL secrets to EnvironmentFile |
| NETSDK1045 (wrong .NET version) | PATH missing `~/.dotnet` | Add to `Environment="PATH=..."` in service |

## See Also

- [Build](../continuous-integration/build.md) - Build before deploying
- [Test](../continuous-integration/test.md) - Test before deploying
- [Secrets Guide](../secrets-management.md) - Full secrets documentation
- [VirtualAssistant deploy.sh](https://github.com/Olbrasoft/VirtualAssistant/blob/main/deploy/deploy.sh) - Real example
