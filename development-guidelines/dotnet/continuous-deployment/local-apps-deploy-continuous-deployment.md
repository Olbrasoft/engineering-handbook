# Local Applications Deployment

How to deploy .NET desktop/console apps to local server using GitHub Actions self-hosted runner.

## When to Use

- **Project type:** Desktop app, console app, or local service
- **Target:** Local server `/opt/olbrasoft/<app>/`
- **Examples:** VirtualAssistant, PushToTalk
- **NOT for:** NuGet packages or public releases

## Prerequisites

- ✅ Build succeeds (see [../continuous-integration/build-continuous-integration.md](../continuous-integration/build-continuous-integration.md))
- ✅ Tests pass (see [../continuous-integration/test-continuous-integration.md](../continuous-integration/test-continuous-integration.md))
- ✅ Self-hosted GitHub Actions runner installed and running

## GitHub Actions Deploy Workflow

**File:** `.github/workflows/deploy.yml`

```yaml
name: Deploy to Production

on:
  workflow_run:
    workflows: ["Build and Test"]  # Runs AFTER build workflow succeeds
    types: [completed]
    branches: [main]

env:
  VERSION_PREFIX: "1.0"

jobs:
  deploy:
    runs-on: self-hosted  # MUST use self-hosted runner!
    if: ${{ github.event.workflow_run.conclusion == 'success' }}

    steps:
    - uses: actions/checkout@v4

    - name: Calculate version
      id: version
      run: |
        VERSION="${{ env.VERSION_PREFIX }}.${{ github.event.workflow_run.run_number }}"
        echo "version=$VERSION" >> $GITHUB_OUTPUT

    - name: Deploy Application
      env:
        DOTNET_ROOT: /home/user/.dotnet
        PATH: /home/user/.dotnet:/usr/local/bin:/usr/bin:/bin
      run: |
        ./deploy/deploy.sh /opt/olbrasoft/myapp ${{ steps.version.outputs.version }}
```

## Deploy Script

**File:** `deploy/deploy.sh`

```bash
#!/usr/bin/env bash
set -e

DEPLOY_DIR="$1"
VERSION="$2"

[ -z "$DEPLOY_DIR" ] && { echo "Usage: deploy.sh <deploy-dir> <version>"; exit 1; }
[ -z "$VERSION" ] && { echo "Version required!"; exit 1; }

echo "🚀 Deploying version $VERSION to $DEPLOY_DIR..."

# Publish application
dotnet publish src/MyApp/MyApp.csproj \
  -c Release \
  -o "$DEPLOY_DIR" \
  --no-self-contained \
  -p:Version="$VERSION"

# Restart service if exists
SERVICE_NAME="myapp.service"
if systemctl --user is-active --quiet "$SERVICE_NAME"; then
    systemctl --user restart "$SERVICE_NAME"
    echo "✅ Service restarted"
fi

echo "✅ Deployed version $VERSION"
```

**Make executable:**
```bash
chmod +x deploy/deploy.sh
```

## Self-Hosted Runner Setup

**Install runner:** (one-time setup)

```bash
cd ~
mkdir actions-runner-myapp && cd actions-runner-myapp

# Download latest runner (check GitHub for current version)
curl -o actions-runner-linux-x64-2.321.0.tar.gz \
  -L https://github.com/actions/runner/releases/download/v2.321.0/actions-runner-linux-x64-2.321.0.tar.gz

tar xzf ./actions-runner-linux-x64-2.321.0.tar.gz

# Configure (follow prompts)
./config.sh --url https://github.com/YourOrg/YourRepo --token YOUR_TOKEN
```

**Install as systemd service:**
```bash
sudo ./svc.sh install
sudo ./svc.sh start
```

**Verify runner:**
```bash
# Check if running
systemctl status actions.runner.*

# Or check GitHub:
# Settings → Actions → Runners → Should show "Idle" (green)
```

## Deployment Verification

**After deployment completes:**

### 1. Check Version

```bash
/opt/olbrasoft/myapp/MyApp --version
# Should output: 1.0.123 (your deployed version)
```

### 2. Check Service Status (if systemd service)

```bash
systemctl --user status myapp.service
# Active: active (running)
```

### 3. Check Logs

```bash
journalctl --user -u myapp.service -n 50
```

### 4. Verify Running Process Uses New Code

**🚨 CRITICAL:** After deployment, running application may still use OLD code if not restarted!

**Check process start time:**
```bash
# Find running process PID
PID=$(pgrep -f "myapp" | head -1)

# Check when process started
ps -p $PID -o pid,lstart,cmd

# Compare with deploy time - if process started BEFORE deploy, it's using OLD code!
```

**Check binary modification time:**
```bash
# When was binary last updated?
stat -c '%y' /opt/olbrasoft/myapp/MyApp

# Should be AFTER latest deploy (check GitHub Actions timestamp)
```

**Restart if needed:**
```bash
# Kill old process
kill $PID

# Or restart systemd service (preferred)
systemctl --user restart myapp.service

# Verify new process started AFTER deploy
ps -p $(pgrep -f "myapp" | head -1) -o pid,lstart,cmd
```

**Why this matters:**
- GitHub Actions may deploy new binaries successfully
- But running application continues using old code in memory
- New code only loads when process restarts
- Tests pass, deploy succeeds, but users see old behavior!

**Example issue:**
```
Deploy: 2025-12-27 04:23:00  ← New code deployed
Process: Started 2025-12-27 01:38:00  ← Still running old code (3 hours old!)
Result: Users report "it doesn't work" even though tests pass
```

### 5. Test Functionality

**Test ALL features before completing deployment:**
- Run the application
- Test core functionality
- Verify integrations work
- Check no errors in logs

**🚨 Deployment NOT complete until everything works!**

## Automatic Versioning

**Version format:** `{PREFIX}.{RUN_NUMBER}`

| Run | Version |
|-----|---------|
| 1st run | 1.0.1 |
| 2nd run | 1.0.2 |
| 100th run | 1.0.100 |

**.csproj configuration:**
```xml
<!-- Version set by deploy script via -p:Version -->
<PropertyGroup>
  <Version>1.0.0</Version>  <!-- Fallback if not set -->
</PropertyGroup>
```

## Common Issues

| Problem | Cause | Fix |
|---------|-------|-----|
| Runner offline | Service stopped | `sudo systemctl start actions.runner.*` |
| Permission denied | Missing sudo/permissions | Add user to sudoers or fix file permissions |
| NETSDK1045 | PATH missing .dotnet | Set `DOTNET_ROOT` and `PATH` in workflow |
| Deploy fails | Tests failed in build workflow | Fix tests, push again |

## Workflow Trigger Explanation

```yaml
on:
  workflow_run:
    workflows: ["Build and Test"]
    types: [completed]
```

**Means:**
- Deploy workflow triggers AFTER "Build and Test" workflow completes
- Only runs if build workflow succeeded (`if: conclusion == 'success'`)
- Prevents deploying broken builds

## See Also

- [Build](../continuous-integration/build-continuous-integration.md) - Build before deploying
- [Test](../continuous-integration/test-continuous-integration.md) - Test before deploying
- [Web Deploy](web-deploy-continuous-deployment.md) - Similar but for web services
- [GitHub Self-Hosted Runners](https://docs.github.com/en/actions/hosting-your-own-runners)
