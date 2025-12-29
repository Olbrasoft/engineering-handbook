## Quick Reference

### Build & Test

```bash
cd ~/Olbrasoft/GitHub.Issues
dotnet build
dotnet test --verbosity minimal
```

### Deploy

```bash
cd ~/Olbrasoft/GitHub.Issues
sudo ./deploy/deploy.sh /opt/olbrasoft/github-issues
```

### Start/Stop Application

```bash
gi start  # Start application + ngrok + runners
gi stop   # Stop application
```

### Check Application Status

```bash
curl -s http://localhost:5156  # Should return HTML
```

### Database Connection String

```bash
Server=localhost,1433;Database=GitHubIssues;User Id=sa;Password=<PASSWORD>;TrustServerCertificate=True;Encrypt=True;
```

**CRITICAL**: Password is in environment variable `ConnectionStrings__DefaultConnection`, **NOT in JSON**.

### Port Configuration

- **Application Port**: `5156` (HTTP only)
- **MUST be set via**: `ASPNETCORE_URLS=http://localhost:5156`
- **Why**: ngrok tunnel is configured for port 5156
- **Location**: `/home/jirka/.local/bin/github-start.sh`
- ⚠️ **NEVER change this port** - it breaks ngrok integration

---

