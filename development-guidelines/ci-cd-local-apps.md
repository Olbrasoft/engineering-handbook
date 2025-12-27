# CI/CD for Local Applications

Deploying .NET applications to local server via GitHub Actions and self-hosted runner.

## When to Use

- **Project type**: Desktop app, console app, or service running locally
- **Distribution**: Local deployment to `/opt/olbrasoft/<app>/`
- **Examples**: VirtualAssistant, PushToTalk
- **NOT for**: NuGet packages (use [ci-cd-nuget.md](ci-cd-nuget.md)) or public releases (use [ci-cd-desktop.md](ci-cd-desktop.md))

## Key Differences from NuGet Packages

| Aspect | NuGet Packages | Local Apps |
|--------|----------------|------------|
| **Target** | NuGet.org | Local server `/opt/olbrasoft/<app>/` |
| **Runner** | GitHub-hosted (ubuntu-latest) | Self-hosted (local machine) |
| **Versioning** | Auto-increment (1.0.${{ github.run_number }}) | Auto-increment (1.0.${{ github.run_number }}) |
| **Deploy** | `dotnet nuget push` | `dotnet publish` + systemd restart |
| **Trigger** | Push to main | After successful build (workflow_run) |

## Quick Setup

### 1. Build Workflow (`.github/workflows/build.yml`)

```yaml
name: Build and Test

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  VERSION_PREFIX: "1.0"

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: 10.0.x

    - name: Calculate version
      id: version
      run: |
        VERSION="${{ env.VERSION_PREFIX }}.${{ github.run_number }}"
        echo "version=$VERSION" >> $GITHUB_OUTPUT
        echo "Building version: $VERSION"

    - name: Restore dependencies
      run: dotnet restore

    - name: Build
      run: dotnet build --no-restore --configuration Release -p:Version=${{ steps.version.outputs.version }}

    - name: Test
      run: dotnet test --no-build --verbosity normal --configuration Release
```

### 2. Deploy Workflow (`.github/workflows/deploy.yml`)

```yaml
name: Deploy to Production

on:
  workflow_run:
    workflows: ["Build and Test"]
    types:
      - completed
    branches: [main]

env:
  VERSION_PREFIX: "1.0"

jobs:
  deploy:
    runs-on: self-hosted
    if: ${{ github.event.workflow_run.conclusion == 'success' }}

    steps:
    - name: Calculate version
      id: version
      run: |
        VERSION="${{ env.VERSION_PREFIX }}.${{ github.event.workflow_run.run_number }}"
        echo "version=$VERSION" >> $GITHUB_OUTPUT
        echo "Deploying version: $VERSION"

    - name: Deploy Application
      env:
        DOTNET_ROOT: /home/jirka/.dotnet
        PATH: /home/jirka/.dotnet:/home/jirka/.dotnet/tools:/usr/local/bin:/usr/bin:/bin
      run: |
        echo "🚀 Deploying version ${{ steps.version.outputs.version }} to /opt/olbrasoft/<app>..."
        cd /home/jirka/Olbrasoft/<YourRepo>
        git pull origin main
        sudo -E env "PATH=$PATH" "DOTNET_ROOT=$DOTNET_ROOT" dotnet publish src/<YourApp>/<YourApp>.csproj \
          -c Release \
          -o /opt/olbrasoft/<app>/app \
          -p:Version=${{ steps.version.outputs.version }} \
          --no-self-contained
        echo "✅ Deployment completed: version ${{ steps.version.outputs.version }}"

    - name: Restart Service (if systemd)
      run: |
        sudo systemctl restart <your-service>.service
        echo "✅ Service restarted"
```

**CRITICAL:** Replace `<app>`, `<YourRepo>`, `<YourApp>`, `<your-service>` with actual names.

### 3. .csproj Versioning

```xml
<PropertyGroup>
  <!-- Version is auto-calculated in CI/CD as 1.0.${{ github.run_number }} -->
  <!-- This is fallback for local builds only -->
  <Version>1.0.0-local</Version>
</PropertyGroup>
```

**DO NOT** hardcode versions like `<Version>1.0.44</Version>` - this causes:
- ❌ Manual version bumps required
- ❌ Forgotten updates
- ❌ Version conflicts

### 4. Self-Hosted Runner Installation

Create `scripts/install-runner.sh`:

```bash
#!/bin/bash
set -e

REPO_OWNER="Olbrasoft"
REPO_NAME="YourRepo"
RUNNER_DIR="$HOME/actions-runner-${REPO_NAME}"
RUNNER_VERSION="2.321.0"

echo "🚀 Installing GitHub Actions Runner for ${REPO_OWNER}/${REPO_NAME}..."

# Check if runner already exists
if [ -d "$RUNNER_DIR" ]; then
    echo "❌ Runner directory already exists: $RUNNER_DIR"
    echo "   Run ./scripts/uninstall-runner.sh first"
    exit 1
fi

# Download runner
mkdir -p "$RUNNER_DIR"
cd "$RUNNER_DIR"
curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L \
    https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Get registration token
echo "🔑 Getting registration token from GitHub..."
TOKEN=$(gh api -X POST repos/${REPO_OWNER}/${REPO_NAME}/actions/runners/registration-token --jq .token)

if [ -z "$TOKEN" ]; then
    echo "❌ Failed to get registration token. Make sure you have 'gh' CLI installed and authenticated."
    exit 1
fi

# Configure runner
echo "⚙️  Configuring runner..."
./config.sh --url https://github.com/${REPO_OWNER}/${REPO_NAME} --token $TOKEN --unattended

# Install as service
echo "🔧 Installing runner as systemd service..."
sudo ./svc.sh install
sudo ./svc.sh start

echo "✅ Runner installed and started!"
echo "   Directory: $RUNNER_DIR"
echo "   Status: sudo ./svc.sh status"
```

Create `scripts/uninstall-runner.sh`:

```bash
#!/bin/bash
set -e

REPO_NAME="YourRepo"
RUNNER_DIR="$HOME/actions-runner-${REPO_NAME}"

echo "🗑️  Uninstalling GitHub Actions Runner..."

if [ ! -d "$RUNNER_DIR" ]; then
    echo "❌ Runner directory not found: $RUNNER_DIR"
    exit 1
fi

cd "$RUNNER_DIR"

# Stop and uninstall service
echo "🛑 Stopping service..."
sudo ./svc.sh stop || true
sudo ./svc.sh uninstall || true

# Remove runner from GitHub
echo "🔑 Getting removal token from GitHub..."
TOKEN=$(gh api -X POST repos/Olbrasoft/${REPO_NAME}/actions/runners/remove-token --jq .token)

if [ -n "$TOKEN" ]; then
    ./config.sh remove --token $TOKEN
else
    echo "⚠️  Could not get removal token, skipping GitHub removal"
fi

# Remove directory
cd ..
rm -rf "$RUNNER_DIR"

echo "✅ Runner uninstalled!"
```

Make scripts executable:

```bash
chmod +x scripts/install-runner.sh scripts/uninstall-runner.sh
```

### 5. Runner Installation

```bash
# Install runner
cd ~/Olbrasoft/YourRepo
./scripts/install-runner.sh

# Verify runner is running
sudo ~/actions-runner-YourRepo/svc.sh status

# Check in GitHub
# Go to: Settings → Actions → Runners → Should see "debian-local-debian" (Active)
```

## Automatic Versioning

### Version Calculation

**In build.yml (GitHub-hosted):**
```yaml
VERSION="${{ env.VERSION_PREFIX }}.${{ github.run_number }}"
```
- Uses `github.run_number` (sequential: 125, 126, 127...)
- Result: `1.0.125`, `1.0.126`, `1.0.127`

**In deploy.yml (self-hosted):**
```yaml
VERSION="${{ env.VERSION_PREFIX }}.${{ github.event.workflow_run.run_number }}"
```
- Uses `github.event.workflow_run.run_number` (matches build number)
- Result: **Same version** as build (e.g., `1.0.125`)

**CRITICAL:** Deploy workflow MUST use `github.event.workflow_run.run_number`, NOT `github.run_number`:
- ✅ `github.event.workflow_run.run_number` - matches build version
- ❌ `github.run_number` - different number, causes version mismatch

### Version Bumping

When to bump `VERSION_PREFIX`:
1. ✅ Breaking changes (1.0 → 2.0)
2. ✅ Major new features (1.0 → 1.1)
3. ❌ Bug fixes (keep 1.0.X auto-incrementing)

**Example:**
```yaml
env:
  VERSION_PREFIX: "1.1"  # Changed from 1.0 - new major feature added
```

Next versions: `1.1.130`, `1.1.131`, ...

## Self-Hosted Runner Setup

### Why Self-Hosted?

GitHub-hosted runners (`ubuntu-latest`) **cannot** access local machine:
- ❌ Cannot deploy to `/opt/olbrasoft/<app>/`
- ❌ Cannot restart systemd services
- ❌ Cannot access local databases

Self-hosted runner runs on **your machine**:
- ✅ Full access to filesystem
- ✅ Can use `sudo` for deployment
- ✅ Can restart services
- ✅ Can access local resources

### Security Considerations

Self-hosted runners execute code from GitHub Actions workflows:
- ⚠️ Only use on private repositories
- ⚠️ Review all changes before merging to main
- ⚠️ Runner has sudo access - use responsibly

### Runner Management

```bash
# Check status
sudo ~/actions-runner-YourRepo/svc.sh status

# Stop runner
sudo ~/actions-runner-YourRepo/svc.sh stop

# Start runner
sudo ~/actions-runner-YourRepo/svc.sh start

# View logs
journalctl -u actions.runner.Olbrasoft-YourRepo.*.service -f
```

## Deploy Workflow Details

### workflow_run Trigger

```yaml
on:
  workflow_run:
    workflows: ["Build and Test"]
    types:
      - completed
    branches: [main]
```

**How it works:**
1. Push to main → triggers "Build and Test" workflow (GitHub-hosted)
2. Build completes → triggers "Deploy to Production" workflow (self-hosted)
3. Deploy runs **only if** build succeeded

**Why this pattern?**
- ✅ Tests run on clean GitHub-hosted runner
- ✅ Deploy runs only after successful tests
- ✅ Deployment happens on local machine with access to `/opt/`

### Environment Variables

```yaml
env:
  DOTNET_ROOT: /home/jirka/.dotnet
  PATH: /home/jirka/.dotnet:/home/jirka/.dotnet/tools:/usr/local/bin:/usr/bin:/bin
```

**Why needed?**
- Self-hosted runner uses minimal environment
- `DOTNET_ROOT` - tells .NET where SDK is installed
- `PATH` - includes both .NET tools and system binaries

### sudo with Environment

```yaml
sudo -E env "PATH=$PATH" "DOTNET_ROOT=$DOTNET_ROOT" dotnet publish ...
```

**Flags explained:**
- `-E` - preserve user environment
- `env "PATH=$PATH"` - pass PATH to sudo
- `env "DOTNET_ROOT=$DOTNET_ROOT"` - pass DOTNET_ROOT to sudo

**Without this:** sudo resets environment → `dotnet` not found

## Directory Structure

```
/opt/olbrasoft/<app>/
├── app/                          # Binaries (deployed here)
│   ├── <YourApp>                 # Executable
│   ├── appsettings.json
│   ├── *.dll
│   └── ...
├── config/                       # Optional: external config
│   └── appsettings.Production.json
└── logs/                         # Optional: application logs
```

**Project structure:**
```
YourRepo/
├── .github/
│   └── workflows/
│       ├── build.yml            # Build + test (GitHub-hosted)
│       └── deploy.yml           # Deploy (self-hosted)
├── scripts/
│   ├── install-runner.sh        # Runner installation
│   ├── uninstall-runner.sh      # Runner removal
│   └── README.md                # Runner documentation
├── src/
│   └── YourApp/
│       └── YourApp.csproj
└── README.md
```

## Checklist

- [ ] Build workflow (`.github/workflows/build.yml`) exists
- [ ] Deploy workflow (`.github/workflows/deploy.yml`) exists
- [ ] ⚠️ **REQUIRED:** Automatic versioning configured (VERSION_PREFIX)
- [ ] ⚠️ **REQUIRED:** .csproj has fallback version `1.0.0-local`
- [ ] ⚠️ **REQUIRED:** Deploy uses `github.event.workflow_run.run_number`
- [ ] Self-hosted runner installed (`./scripts/install-runner.sh`)
- [ ] Runner appears in GitHub: Settings → Actions → Runners
- [ ] Deploy path `/opt/olbrasoft/<app>/app/` exists (create with sudo)
- [ ] Systemd service configured (if applicable)
- [ ] Tests pass locally: `dotnet test`

## Common Issues

| Problem | Cause | Fix |
|---------|-------|-----|
| .NET SDK not found | DOTNET_ROOT not set | Add `DOTNET_ROOT` env var to deploy.yml |
| git command not found | PATH missing system dirs | Add `/usr/local/bin:/usr/bin:/bin` to PATH |
| Permission denied `/opt/` | No sudo | Add `sudo -E` before `dotnet publish` |
| Wrong version deployed | Used `github.run_number` | Use `github.event.workflow_run.run_number` |
| Runner not found | Not installed | Run `./scripts/install-runner.sh` |
| Deploy triggered on PR | Wrong workflow_run filter | Add `branches: [main]` to workflow_run |

## Version Verification

After deployment:

```bash
# 1. Check GitHub Actions logs
# Go to: Actions → Deploy to Production → Latest run
# Find: "Deploying version: X.Y.Z"

# 2. Check deployed binary version
/opt/olbrasoft/<app>/app/<YourApp> --version

# 3. Check systemd service status
sudo systemctl status <your-service>.service

# 4. Check application logs
journalctl -u <your-service>.service -n 50
```

## Examples

### PushToTalk

Complete example with:
- Automatic versioning (1.0.${{ github.run_number }})
- Self-hosted runner
- Deploy to `/opt/olbrasoft/push-to-talk/`

**Repository:** `~/Olbrasoft/PushToTalk`

**Files to reference:**
- `.github/workflows/build.yml` - Build workflow with versioning
- `.github/workflows/deploy.yml` - Deploy workflow with workflow_run
- `scripts/install-runner.sh` - Runner installation
- `src/PushToTalk.App/PushToTalk.App.csproj` - Versioning in .csproj

### VirtualAssistant

Example with systemd service restart:

**Repository:** `~/Olbrasoft/VirtualAssistant`

**Deploy includes:**
```yaml
- name: Restart Service
  run: |
    sudo systemctl restart virtual-assistant.service
    sudo systemctl status virtual-assistant.service
```

## CI Verification Before Reporting Completion

**CRITICAL RULE:** Before informing the user that implementation is complete and deployed, you **MUST** verify that GitHub Actions CI passed successfully.

### Required Steps

1. **After pushing changes to `main`:**
   ```bash
   # Wait for CI to start (20-30 seconds)
   sleep 30

   # Check latest run status
   gh run list --limit 1
   ```

2. **Verify status is `completed success`:**
   ```bash
   completed	success	Your commit message	Deploy GitHub.Issues (Local)	main	push	...
   ```

3. **If CI failed:**
   - ❌ DO NOT report "deployment completed" to user
   - ✅ View failed logs: `gh run view <run-id> --log-failed`
   - ✅ Fix the issue
   - ✅ Push fix and verify again

4. **Only after CI passes:**
   - ✅ Report to user: "Implementation complete, CI passed, deployed successfully"
   - ✅ Send notification with issue IDs

### Why This Matters

Local builds can succeed while CI fails due to:
- Missing NuGet packages
- Project references to local repos (not available on CI)
- Environment-specific dependencies
- File lock issues (local only)

**Example failure:**
```
error CS0234: Type or namespace Google does not exist in namespace Olbrasoft.Text.Translation
```

**Root cause:** Project referenced `../../../Text/src/Olbrasoft.Text.Translation.Google/` which exists locally but NOT on GitHub-hosted runner.

**Fix:** Replace ProjectReference with PackageReference.

### GitHub CLI Commands

```bash
# List recent runs
gh run list --limit 5

# View specific run
gh run view <run-id>

# View failed logs only
gh run view <run-id> --log-failed

# Watch run in progress
gh run watch <run-id>
```

### Integration with Notifications

**Before notification:**
```bash
# 1. Push changes
git push origin main

# 2. Wait for CI
sleep 30

# 3. Verify CI passed
gh run list --limit 1 | grep "completed.*success"
```

**After verification passed:**
```javascript
mcp__notify__notify({
  text: "Implementace dokončena, CI prošlo, aplikace nasazena.",
  issueIds: [278, 279, 280]
})
```

**If CI failed:**
```javascript
mcp__notify__notify({
  text: "Build selhal na CI, opravuji chyby.",
  issueIds: [278, 279, 280]
})
```

## Web Application Verification Before Reporting Completion

**CRITICAL RULE:** If the application is a web application running at a specific address (e.g., `http://localhost:5156`), you **MUST** verify that the application is actually running and responding before informing the user that deployment is complete.

### Why This Matters

CI can pass and deployment can succeed, but the application may NOT be running:
- Deployment copied files successfully
- All tests passed
- BUT: Application process not started
- User receives "deployment completed" but application is inaccessible

**Example scenario:**
```
✅ CI passed
✅ Files deployed to /opt/olbrasoft/app/
✅ You reported: "Deployment successful, application running"
❌ Reality: Application NOT started, port NOT listening
❌ User tries to access: Connection refused
```

### Required Steps for Web Applications

**1. After deployment completes:**

```bash
# Start the application (use project-specific startup command)
# Example for GitHub.Issues:
/home/jirka/.local/bin/github-start.sh

# Or for systemd services:
sudo systemctl restart your-service.service
```

**2. Verify port is listening:**

```bash
# Check if application port is listening
ss -tulpn | grep <PORT>

# Example for port 5156:
ss -tulpn | grep 5156

# Expected output:
# tcp   LISTEN 0  512  127.0.0.1:5156  0.0.0.0:*  users:(("dotnet",pid=123,fd=4))
```

**3. Verify HTTP 200 OK response:**

```bash
# Test HTTP response
curl -I http://localhost:<PORT>

# Example for port 5156:
curl -I http://localhost:5156

# Expected output:
# HTTP/1.1 200 OK
# Content-Type: text/html; charset=utf-8
# ...
```

**4. Test with Playwright (homepage loads):**

Use `mcp__playwright__browser_navigate` to verify homepage loads successfully:

```javascript
// Navigate to application
mcp__playwright__browser_navigate({
  url: "http://localhost:<PORT>"
})

// Verify page loaded successfully (check title or key elements)
// If Playwright can load the page → application is functional
```

**5. ONLY after all verifications pass:**

```javascript
mcp__notify__notify({
  text: "Implementace dokončena, CI prošlo, aplikace běží a je funkční.",
  issueIds: [278, 279, 280]
})
```

### Common Web Application Issues

| Problem | Detection | Fix |
|---------|-----------|-----|
| Process not started | `ss -tulpn` shows no listening port | Start application with startup script |
| Wrong port | Port listening but different from expected | Check ASPNETCORE_URLS or config |
| Application crashed | Port was listening, then stopped | Check logs: journalctl or application log file |
| Returns error page | HTTP 200 but error content | Check application logs for exceptions |

### Integration with CI Verification

**Complete verification workflow:**

```bash
# 1. Push changes
git push origin main

# 2. Wait for CI
sleep 30

# 3. Verify CI passed
gh run list --limit 1 | grep "completed.*success"

# 4. Start application (if not auto-started)
/path/to/startup-script.sh

# 5. Verify port listening
ss -tulpn | grep <PORT>

# 6. Verify HTTP response
curl -I http://localhost:<PORT>

# 7. Test with Playwright
mcp__playwright__browser_navigate({ url: "http://localhost:<PORT>" })

# 8. ONLY if ALL steps passed → report to user
mcp__notify__notify({
  text: "Implementace dokončena, CI prošlo, aplikace běží.",
  issueIds: [...]
})
```

### Project-Specific Examples

**GitHub.Issues (ASP.NET Razor Pages):**
```bash
# Start
/home/jirka/.local/bin/github-start.sh

# Verify
ss -tulpn | grep 5156
curl -I http://localhost:5156
mcp__playwright__browser_navigate({ url: "http://localhost:5156" })
```

**VirtualAssistant (systemd service):**
```bash
# Start
sudo systemctl restart virtual-assistant.service

# Verify
ss -tulpn | grep 5055
curl http://localhost:5055/health
```

## Reference

- [GitHub Actions - workflow_run trigger](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#workflow_run)
- [Self-hosted runners](https://docs.github.com/en/actions/hosting-your-own-runners)
- [dotnet publish](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-publish)
