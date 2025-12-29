## Deployment

### Production Environment

```
/opt/olbrasoft/github-issues/
├── app/          # Compiled binaries (from dotnet publish)
├── config/       # Configuration files (appsettings.json with API keys)
├── data/         # Runtime data
└── logs/         # Application logs
```

### Deployment Script

**Location**: `deploy/deploy.sh`

**Usage**:
```bash
cd ~/Olbrasoft/GitHub.Issues
sudo ./deploy/deploy.sh /opt/olbrasoft/github-issues
```

**Steps**:
1. Run tests (`dotnet test --verbosity minimal --filter "FullyQualifiedName!~IntegrationTests"`)
2. Build and publish (`dotnet publish -c Release -o /opt/olbrasoft/github-issues/app`)
3. Create directory structure (`app/`, `config/`, `data/`, `logs/`)
4. Copy default config if not exists

### GitHub Actions CI/CD

**Location**: `.github/workflows/deploy-local.yml`

**Trigger**: Push to `main` branch or manual dispatch

**Steps**:
1. Checkout code
2. Verify .NET version (requires .NET 10 SDK in PATH!)
3. Restore dependencies
4. Build (Release configuration)
5. Run tests (integration tests skip automatically via `[SkipOnCIFact]`)
6. Deploy using `deploy/deploy.sh`
7. Restart application (`pkill` + `github-start.sh`)
8. Verify application responds on port 5156

### Self-Hosted Runner Configuration

**Runner Name**: `debian-github-issues`
**Location**: `~/actions-runner-github-issues/`
**Service**: `actions.runner.Olbrasoft-GitHub.Issues.debian-github-issues.service`

**CRITICAL**: Runner systemd service MUST have .NET 10 SDK in PATH:

```ini
Environment="PATH=/home/jirka/.dotnet:/home/jirka/.local/bin:/usr/local/bin:/usr/bin:/bin"
```

**Why**: System-wide `dotnet` is .NET SDK 8.0, but this project requires .NET 10.

### Startup Script

**Location**: `/home/jirka/.local/bin/github-start.sh`

**Responsibilities**:
1. Start GitHub Actions runners
2. Start ngrok tunnel (https://plumbaginous-zoe-unexcusedly.ngrok-free.dev)
3. Start ASP.NET application with environment variables:
   - `ASPNETCORE_ENVIRONMENT=Production`
   - `ASPNETCORE_URLS=http://localhost:5156` (MUST be 5156 for ngrok)
   - `ConnectionStrings__DefaultConnection` (with password)

**Aliases**:
- `gi start` → Start application
- `gi stop` → Stop application

### Security Enhancement (Planned)

**Issue**: [#304 - Prevent Manual Production Edits](https://github.com/Olbrasoft/GitHub.Issues/issues/304)

**Problem**: Regular user can manually edit production config files, bypassing CI/CD.

**Proposed Solution**:
- Create dedicated `gh-deploy` user with restricted permissions
- Deploy script at `/home/gh-deploy/scripts/deploy.sh` (chmod 700)
- Production directory `/opt/olbrasoft/github-issues/` owned by `gh-deploy` (755)
- Regular user `jirka` has read-only access
- GitHub Actions runner migrated to `gh-deploy` user

---

