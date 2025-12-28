# Self-Hosted Runner Setup for engineering-handbook

This document explains how to set up a self-hosted GitHub Actions runner for the `engineering-handbook` repository to enable automatic embedding updates when markdown files change.

## Why Self-Hosted Runner?

The update-embeddings workflow requires access to:
- Local PostgreSQL database with pgvector extension
- Local Ollama instance (localhost:11434)
- HandbookSearch CLI application

These services run locally and cannot be accessed by GitHub-hosted runners.

## Prerequisites

Before setting up the runner, ensure these services are installed and running:

| Service | Check Command | Expected Output |
|---------|---------------|-----------------|
| PostgreSQL with pgvector | `psql -d handbook_search -c "SELECT extname FROM pg_extension WHERE extname = 'vector';"` | `vector` |
| Ollama | `curl http://localhost:11434/api/tags` | JSON with model list |
| nomic-embed-text model | `ollama list \| grep nomic-embed-text` | Model listed |
| .NET 10 SDK | `dotnet --version` | `10.0.x` |
| HandbookSearch CLI | `ls ~/Olbrasoft/HandbookSearch/src/HandbookSearch.Cli/bin/Release/net10.0/HandbookSearch.Cli` | File exists |

## Runner Registration Steps

### 1. Navigate to Repository Settings

Go to: https://github.com/Olbrasoft/engineering-handbook/settings/actions/runners

### 2. Create New Runner

1. Click **"New self-hosted runner"**
2. Select **Linux** and **x64**
3. Follow the displayed instructions

### 3. Download and Configure Runner

```bash
# Create runner directory
mkdir -p ~/actions-runner-engineering-handbook
cd ~/actions-runner-engineering-handbook

# Download runner (check GitHub UI for latest version)
curl -o actions-runner-linux-x64-2.321.0.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.321.0/actions-runner-linux-x64-2.321.0.tar.gz

# Extract
tar xzf ./actions-runner-linux-x64-2.321.0.tar.gz

# Configure with token from GitHub UI
# IMPORTANT: Use the token shown in the GitHub UI
./config.sh \
  --url https://github.com/Olbrasoft/engineering-handbook \
  --token YOUR_REGISTRATION_TOKEN_FROM_GITHUB \
  --name debian \
  --labels handbook-search \
  --work _work

# Verify configuration
cat .runner
```

### 4. Install as systemd Service

```bash
cd ~/actions-runner-engineering-handbook

# Install service (runs as current user)
sudo ./svc.sh install

# Start service
sudo ./svc.sh start

# Check status
sudo ./svc.sh status
```

### 5. Verify Runner Status

1. Go to: https://github.com/Olbrasoft/engineering-handbook/settings/actions/runners
2. Look for runner named "debian" with label "handbook-search"
3. Status should be **"Idle"** (green dot)

## Runner Configuration

The runner is configured with:

| Setting | Value |
|---------|-------|
| **Repository** | `Olbrasoft/engineering-handbook` |
| **Name** | `debian` |
| **Labels** | `self-hosted`, `Linux`, `X64`, `handbook-search` |
| **Work Directory** | `_work` |

## Workflow Trigger

The workflow (`.github/workflows/update-embeddings.yml`) triggers on:
- Push to `main` branch
- Only when `**/*.md` files change

## Environment Variables

The workflow uses these environment variables (configured in workflow file):

```bash
ConnectionStrings__DefaultConnection="Host=localhost;Database=handbook_search;Username=postgres"
Ollama__BaseUrl="http://localhost:11434"
Ollama__Model="nomic-embed-text"
Ollama__Dimensions="768"
```

**Note:** No password is required for local PostgreSQL. If your setup requires a password, add it to repository secrets.

## Secrets Configuration (Optional)

If your PostgreSQL requires a password:

1. Go to: https://github.com/Olbrasoft/engineering-handbook/settings/secrets/actions
2. Click **"New repository secret"**
3. Name: `POSTGRES_PASSWORD`
4. Value: Your PostgreSQL password
5. Update workflow to use: `Password=${{ secrets.POSTGRES_PASSWORD }}`

## Testing the Workflow

After runner setup:

1. Make a change to any `.md` file in engineering-handbook
2. Commit and push to `main`:
   ```bash
   cd ~/GitHub/Olbrasoft/engineering-handbook
   git add README.md
   git commit -m "test: trigger embedding update workflow"
   git push
   ```
3. Check workflow run: https://github.com/Olbrasoft/engineering-handbook/actions
4. Verify embeddings updated in database:
   ```bash
   psql -d handbook_search -c "SELECT file_path, updated_at FROM documents ORDER BY updated_at DESC LIMIT 5;"
   ```

## Troubleshooting

### Runner Not Appearing

**Symptom:** Runner doesn't show up in GitHub UI

**Solutions:**
1. Check registration token hasn't expired (tokens expire after 1 hour)
2. Re-run `./config.sh` with a new token from GitHub UI
3. Verify network connectivity to GitHub

### Runner Shows Offline

**Symptom:** Runner shows "Offline" status

**Solutions:**
```bash
# Check service status
sudo systemctl status actions-runner-engineering-handbook.service

# View logs
journalctl -u actions-runner-engineering-handbook.service -f

# Restart service
sudo ./svc.sh stop
sudo ./svc.sh start
```

### Workflow Fails: CLI Not Found

**Symptom:** Error: "HandbookSearch.Cli: command not found"

**Solutions:**
1. Build CLI in Release mode:
   ```bash
   cd ~/Olbrasoft/HandbookSearch
   dotnet build -c Release src/HandbookSearch.Cli/HandbookSearch.Cli.csproj
   ```
2. Verify executable exists:
   ```bash
   ls -la ~/Olbrasoft/HandbookSearch/src/HandbookSearch.Cli/bin/Release/net10.0/HandbookSearch.Cli
   ```

### Workflow Fails: Database Connection

**Symptom:** Error: "connection to server failed"

**Solutions:**
1. Check PostgreSQL is running:
   ```bash
   systemctl status postgresql
   ```
2. Verify database exists:
   ```bash
   psql -l | grep handbook_search
   ```
3. Test connection:
   ```bash
   psql -d handbook_search -c "SELECT 1;"
   ```

### Workflow Fails: Ollama Connection

**Symptom:** Error: "Failed to generate embedding"

**Solutions:**
1. Check Ollama is running:
   ```bash
   curl http://localhost:11434/api/tags
   ```
2. Verify model is installed:
   ```bash
   ollama list | grep nomic-embed-text
   ```
3. Start Ollama if needed:
   ```bash
   ollama serve
   ```

## Maintenance

### Update Runner

```bash
cd ~/actions-runner-engineering-handbook

# Stop service
sudo ./svc.sh stop

# Download latest version (check GitHub for version)
curl -o actions-runner-linux-x64-X.XXX.X.tar.gz -L \
  https://github.com/actions/runner/releases/download/vX.XXX.X/actions-runner-linux-x64-X.XXX.X.tar.gz

# Extract (this updates binaries)
tar xzf ./actions-runner-linux-x64-X.XXX.X.tar.gz

# Start service
sudo ./svc.sh start
```

### Remove Runner

```bash
cd ~/actions-runner-engineering-handbook

# Stop and uninstall service
sudo ./svc.sh stop
sudo ./svc.sh uninstall

# Remove runner from GitHub
./config.sh remove --token YOUR_REMOVAL_TOKEN_FROM_GITHUB
```

## Security Considerations

- Runner runs as current user (`jirka`)
- Has access to local PostgreSQL and Ollama
- Can execute code from workflow files
- **Only grant repository write access to trusted users**
- Monitor workflow runs for suspicious activity

## Additional Resources

- [GitHub Self-Hosted Runners Documentation](https://docs.github.com/en/actions/hosting-your-own-runners)
- [tj-actions/changed-files Documentation](https://github.com/tj-actions/changed-files)
- [HandbookSearch README](https://github.com/Olbrasoft/HandbookSearch)
