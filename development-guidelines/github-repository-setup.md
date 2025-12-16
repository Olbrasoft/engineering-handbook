# GitHub Repository Setup Guide

Complete guide for setting up GitHub repositories with proper configuration, security, and automation.

## Quick Checklist

- [ ] Create repository with README
- [ ] Add `.gitignore` (use template)
- [ ] Add LICENSE file
- [ ] Configure branch protection
- [ ] Set up webhooks (optional)
- [ ] Add AGENTS.md for AI agents
- [ ] Configure secrets

## Creating a New Repository

### Via GitHub Web UI

1. Go to https://github.com/new
2. Fill in:
   - **Repository name:** Use lowercase, hyphens (e.g., `my-project`)
   - **Description:** One-line summary
   - **Visibility:** Public or Private
   - **Initialize:** Check "Add a README file"
   - **Add .gitignore:** Select template (e.g., "VisualStudio" for .NET)
   - **Choose a license:** MIT for open source

### Via GitHub CLI

```bash
gh repo create my-project --public --clone --gitignore VisualStudio --license MIT
```

## Essential Files

### .gitignore

Use GitHub's templates. For .NET projects:

```bash
# Download .NET gitignore
curl -o .gitignore https://raw.githubusercontent.com/github/gitignore/main/VisualStudio.gitignore
```

**Always add:**
```gitignore
# User secrets
appsettings.*.local.json
*.local.json

# IDE
.idea/
*.user
*.suo

# Build artifacts
/publish/
/artifacts/
```

### README.md

Minimal structure:

```markdown
# Project Name

Brief description of what this project does.

## Getting Started

### Prerequisites
- .NET 10 SDK
- PostgreSQL (optional)

### Installation
\`\`\`bash
git clone https://github.com/Olbrasoft/project-name.git
cd project-name
dotnet build
\`\`\`

### Running Tests
\`\`\`bash
dotnet test
\`\`\`

## License

MIT License - see [LICENSE](LICENSE) file.
```

### AGENTS.md

Instructions for AI agents (Claude Code, GitHub Copilot, etc.):

```markdown
# AGENTS.md

Instructions for AI agents working with this repository.

## Project Overview
[Brief description of project purpose and architecture]

## Build Commands
\`\`\`bash
dotnet build
dotnet test
dotnet publish -c Release -o ./publish
\`\`\`

## Code Style
- Follow Microsoft C# naming conventions
- Use xUnit + Moq for testing
- Target .NET 10

## Important Paths
- Source: `src/`
- Tests: `tests/`
- Configuration: `appsettings.json`

## Secrets
Never commit secrets. Use:
- `dotnet user-secrets` for local development
- GitHub Secrets for CI/CD
- Environment variables for production
```

## Branch Protection

### Configure via Web UI

1. Go to **Settings** → **Branches** → **Add branch protection rule**
2. Branch name pattern: `main`
3. Recommended settings:

| Setting | Value | Why |
|---------|-------|-----|
| Require pull request | Yes | Code review |
| Required approvals | 1+ | For teams |
| Require status checks | Yes | CI must pass |
| Require up-to-date | Yes | No merge conflicts |
| Include administrators | Optional | Enforce for everyone |

### Configure via GitHub CLI

```bash
gh api repos/Olbrasoft/my-project/branches/main/protection \
  --method PUT \
  -f required_status_checks='{"strict":true,"contexts":["build"]}' \
  -f enforce_admins=false \
  -f required_pull_request_reviews='{"required_approving_review_count":1}'
```

## Webhooks Configuration

Webhooks notify external services about repository events (issues, PRs, pushes).

### Setting Up a Webhook

1. Go to **Settings** → **Webhooks** → **Add webhook**
2. Configure:

| Field | Description |
|-------|-------------|
| Payload URL | Your endpoint (e.g., `https://example.com/api/webhooks/github`) |
| Content type | `application/json` |
| Secret | HMAC signature key for verification |
| Events | Select needed events |

### Recommended Events

| Event | Use Case |
|-------|----------|
| `push` | CI/CD triggers |
| `pull_request` | PR automation |
| `issues` | Issue tracking sync |
| `issue_comment` | Comment notifications |
| `release` | Release automation |

### Webhook Security

**Always use a secret** for webhook verification:

```csharp
// Verify webhook signature in ASP.NET Core
var signature = Request.Headers["X-Hub-Signature-256"].FirstOrDefault();
var payload = await new StreamReader(Request.Body).ReadToEndAsync();
var hash = ComputeHmacSha256(payload, webhookSecret);
var expected = $"sha256={hash}";

if (!CryptographicOperations.FixedTimeEquals(
    Encoding.UTF8.GetBytes(signature ?? ""),
    Encoding.UTF8.GetBytes(expected)))
{
    return Unauthorized();
}
```

### Credentials Location

Webhook secrets and configuration details are stored in:

```
~/Dokumenty/guidebooks/github-webhooks.md
```

**Never commit webhook secrets to Git.**

## Secrets Management

### Where Secrets Are Stored

| Type | Location | Access |
|------|----------|--------|
| API Keys | `~/Dokumenty/přístupy/api-keys.md` | Local only |
| Webhook Secrets | `~/Dokumenty/guidebooks/github-webhooks.md` | Local only |
| DB Passwords | `dotnet user-secrets` | Per-project |
| CI/CD Secrets | GitHub Settings → Secrets | Repository |

### GitHub Repository Secrets

For CI/CD pipelines:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add secrets like:
   - `NUGET_API_KEY` - For package publishing
   - `AZURE_CREDENTIALS` - For Azure deployments

### Using Secrets in GitHub Actions

```yaml
jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - name: Publish to NuGet
        run: dotnet nuget push *.nupkg --api-key ${{ secrets.NUGET_API_KEY }}
```

### Local Development Secrets

Use .NET User Secrets (never committed to Git):

```bash
# Initialize user secrets
dotnet user-secrets init

# Set secrets
dotnet user-secrets set "GitHub:Token" "your-token-here"
dotnet user-secrets set "ConnectionStrings:DefaultPassword" "your-password"
```

Access in code:
```csharp
var token = configuration["GitHub:Token"];
```

## GitHub Actions (CI/CD)

### Basic .NET Workflow

Create `.github/workflows/build.yml`:

```yaml
name: Build and Test

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: '10.0.x'
    
    - name: Restore dependencies
      run: dotnet restore
    
    - name: Build
      run: dotnet build --no-restore --configuration Release
    
    - name: Test
      run: dotnet test --no-build --configuration Release --verbosity normal
```

### NuGet Publishing Workflow

Create `.github/workflows/publish.yml`:

```yaml
name: Publish NuGet Package

on:
  release:
    types: [published]

jobs:
  publish:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: '10.0.x'
    
    - name: Build
      run: dotnet build --configuration Release
    
    - name: Pack
      run: dotnet pack --configuration Release --no-build --output ./nupkg
    
    - name: Publish to NuGet
      run: dotnet nuget push ./nupkg/*.nupkg --api-key ${{ secrets.NUGET_API_KEY }} --source https://api.nuget.org/v3/index.json
```

## Repository Templates

For consistent project setup, create a template repository:

1. Create a repository with all standard files
2. Go to **Settings** → Check "Template repository"
3. When creating new repos, select "Repository template"

### Recommended Template Contents

```
template-dotnet/
├── .github/
│   └── workflows/
│       └── build.yml
├── src/
│   └── .gitkeep
├── tests/
│   └── .gitkeep
├── .gitignore
├── AGENTS.md
├── LICENSE
└── README.md
```

## Checklist for New Repositories

### Minimum Setup
- [ ] Repository created with README
- [ ] `.gitignore` added
- [ ] LICENSE file added

### Recommended Setup
- [ ] AGENTS.md for AI agents
- [ ] Branch protection on `main`
- [ ] Basic CI workflow (build + test)

### Full Setup (Production Projects)
- [ ] All above items
- [ ] Webhooks configured
- [ ] GitHub Secrets set up
- [ ] NuGet publishing workflow
- [ ] Code owners file (`.github/CODEOWNERS`)
- [ ] Issue templates (`.github/ISSUE_TEMPLATE/`)
- [ ] PR template (`.github/pull_request_template.md`)

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Webhook not receiving | Check Payload URL, verify secret, check firewall |
| CI failing on secrets | Verify secret name matches workflow |
| Push rejected | Check branch protection rules |
| Permission denied | Verify PAT has required scopes |

## Related Documentation

- [Workflow Guide](workflow-guide.md) - Git workflow, commits, branches
- [CI/CD Pipeline Setup](ci-cd-pipeline-setup.md) - Detailed CI/CD configuration
- [Code Review Guide](code-review-refactoring-guide.md) - Code review practices
