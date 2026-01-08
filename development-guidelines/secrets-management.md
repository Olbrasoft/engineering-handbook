# Secrets Management

How to securely manage passwords, API keys, tokens, and sensitive configuration in .NET projects.

## What Are Secrets?

**Secrets** = Sensitive data that must NOT be committed to Git:
- Database passwords
- API keys (Azure, OpenAI, GitHub tokens, etc.)
- Encryption keys
- Connection strings with passwords
- OAuth client secrets
- Private certificates

**Public data** (OK in Git):
- URLs, ports
- Database names
- Usernames (without passwords)
- Feature flags

---

## 🚨 CRITICAL: Never Commit Secrets to Git

**NEVER commit:**
- ❌ Passwords
- ❌ API keys
- ❌ Tokens
- ❌ Connection strings with passwords
- ❌ Private keys
- ❌ `.env` files with production secrets

**Why?**
- Git history is permanent - even if you delete the file later, it stays in history
- Public repositories expose secrets to the world
- Private repositories can be compromised
- Secrets in Git = security vulnerability

---

## Development Environment - User Secrets

**Use .NET User Secrets** for local development.

### Setup

```bash
# Initialize User Secrets for project
cd src/MyProject
dotnet user-secrets init

# Set secrets
dotnet user-secrets set "ConnectionStrings:Default" "Server=localhost;Database=dev;User=sa;Password=DevPass123"
dotnet user-secrets set "GitHub:Token" "ghp_xxxxxxxxxxxxx"
dotnet user-secrets set "AzureTTS:SubscriptionKey" "abc123def456"
dotnet user-secrets set "OpenAI:ApiKey" "sk-xxxxxxxxxxxxx"

# List all secrets
dotnet user-secrets list

# Remove secret
dotnet user-secrets remove "GitHub:Token"

# Clear all secrets
dotnet user-secrets clear
```

### Where Are Secrets Stored?

**Windows:**
```
%APPDATA%\Microsoft\UserSecrets\<user_secrets_id>\secrets.json
```

**Linux/macOS:**
```
~/.microsoft/usersecrets/<user_secrets_id>/secrets.json
```

**File format** (`secrets.json`):
```json
{
  "ConnectionStrings:Default": "Server=localhost;Database=dev;Password=DevPass123",
  "GitHub:Token": "ghp_xxxxxxxxxxxxx",
  "AzureTTS": {
    "SubscriptionKey": "abc123def456"
  }
}
```

### Access in Code

```csharp
// ASP.NET Core automatically loads User Secrets in Development
public class MyService
{
    private readonly IConfiguration _config;

    public MyService(IConfiguration config)
    {
        _config = config;
    }

    public void DoWork()
    {
        var dbPassword = _config["ConnectionStrings:Default"];
        var githubToken = _config["GitHub:Token"];
        var azureKey = _config["AzureTTS:SubscriptionKey"];
    }
}
```

**Configuration load order:**
1. `appsettings.json`
2. `appsettings.Development.json` (if Development)
3. **User Secrets** (if Development)
4. Environment variables
5. Command-line arguments

---

## Production Environment - Environment Variables

**Use Environment Variables** for production deployments.

### Option 1: systemd EnvironmentFile (Recommended for Linux Services)

**1. Create secrets file:**

**File:** `~/.config/systemd/user/myapp.env`

```bash
# Database
ConnectionStrings__DefaultConnection=Server=localhost;Database=prod;User=produser;Password=ProdPass123

# GitHub API
GitHub__Token=ghp_prodtoken123

# Azure TTS
AzureTTS__SubscriptionKey=prodkey456
AZURE_SPEECH_REGION=westeurope

# OpenAI
OpenAI__ApiKey=sk-prodkey789
```

**Important:**
- Use **double underscore `__`** to replace `:` in config hierarchy
- `ConnectionStrings__Default` maps to `ConnectionStrings:Default` in config

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

**3. Reload and restart:**

```bash
systemctl --user daemon-reload
systemctl --user restart myapp.service

# Verify environment variables loaded
systemctl --user show myapp.service | grep Environment
```

### Option 2: Direct Environment Variables

**Set in shell:**

```bash
export ConnectionStrings__Default="Server=localhost;Database=prod;Password=ProdPass123"
export GitHub__Token="ghp_prodtoken123"

# Run application
dotnet run
```

**Set in Docker:**

```dockerfile
ENV ConnectionStrings__Default="Server=db;Database=prod;User=app;Password=ProdPass123"
ENV GitHub__Token="ghp_prodtoken123"
```

---

## GitHub Actions Secrets

**Use GitHub Secrets** for CI/CD workflows.

### Setup

1. **Go to repository → Settings → Secrets and variables → Actions**
2. **Click "New repository secret"**
3. **Add secrets:**
   - Name: `NUGET_API_KEY`, Value: `oy2abc...`
   - Name: `AZURE_TTS_KEY`, Value: `abc123...`
   - Name: `DB_PASSWORD`, Value: `ProdPass123`

### Use in Workflow

**File:** `.github/workflows/deploy.yml`

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '10.0.x'

      - name: Publish to NuGet
        run: |
          dotnet pack -c Release
          dotnet nuget push *.nupkg --api-key ${{ secrets.NUGET_API_KEY }} --source https://api.nuget.org/v3/index.json

      - name: Deploy with secrets
        env:
          DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
          AZURE_TTS_KEY: ${{ secrets.AZURE_TTS_KEY }}
        run: |
          ./deploy.sh
```

**Access in script:**

```bash
#!/bin/bash
# deploy.sh

echo "Deploying with DB password: ${DB_PASSWORD}"
echo "Azure TTS key configured: ${AZURE_TTS_KEY}"

# Use in connection string
export ConnectionStrings__Default="Server=db;Database=prod;Password=${DB_PASSWORD}"
dotnet MyApp.dll
```

---

## appsettings.json - What to Commit

**DO commit** to Git:

**File:** `appsettings.json`

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information"
    }
  },
  "ConnectionStrings": {
    "Default": "Server=localhost;Database=myapp"
  },
  "GitHub": {
    "ApiUrl": "https://api.github.com"
  },
  "AzureTTS": {
    "Region": "westeurope"
  }
}
```

**DO NOT commit:**

```json
{
  "ConnectionStrings": {
    "Default": "Server=localhost;Database=myapp;Password=secret123"  // ❌ NO!
  },
  "GitHub": {
    "Token": "ghp_xxxxxxxxxxxxx"  // ❌ NO!
  },
  "AzureTTS": {
    "SubscriptionKey": "abc123def456"  // ❌ NO!
  }
}
```

**Best practice:** Separate public config from secrets

```json
{
  "ConnectionStrings": {
    "DefaultTemplate": "Server=localhost;Database=myapp"
  },
  "GitHub": {
    "ApiUrl": "https://api.github.com"
  }
}
```

Then in code, combine with secrets:

```csharp
var connTemplate = _config["ConnectionStrings:DefaultTemplate"];
var password = _config["DbPassword"]; // From User Secrets or env vars
var fullConn = $"{connTemplate};Password={password}";
```

---

## Best Practices

### ✅ DO

1. **Use User Secrets for development**
   ```bash
   dotnet user-secrets set "GitHub:Token" "ghp_dev123"
   ```

2. **Use Environment Variables for production**
   ```bash
   export GitHub__Token="ghp_prod456"
   ```

3. **Use GitHub Secrets for CI/CD**
   ```yaml
   env:
     NUGET_API_KEY: ${{ secrets.NUGET_API_KEY }}
   ```

4. **Add `.env` to `.gitignore`**
   ```gitignore
   .env
   .env.local
   .env.production
   *.env
   secrets.json
   ```

5. **Rotate secrets regularly**
   - Change passwords every 90 days
   - Regenerate API keys periodically

6. **Use strong passwords**
   - Min 16 characters
   - Mix of letters, numbers, symbols
   - Use password manager

7. **Principle of least privilege**
   - Give minimum permissions needed
   - Separate dev/prod credentials

### ❌ DON'T

1. **Commit secrets to Git**
   ```bash
   # ❌ NEVER DO THIS:
   git add appsettings.Production.json  # Contains passwords
   git commit -m "Add prod config"
   ```

2. **Share secrets via chat/email**
   - Use secure password managers instead

3. **Hardcode secrets**
   ```csharp
   // ❌ NEVER DO THIS:
   var apiKey = "abc123def456";
   var password = "MyPassword123";
   ```

4. **Log secrets**
   ```csharp
   // ❌ NEVER DO THIS:
   _logger.LogInformation("API Key: {Key}", apiKey);
   _logger.LogInformation("Password: {Pwd}", password);
   ```

5. **Include secrets in error messages**
   ```csharp
   // ❌ NEVER DO THIS:
   throw new Exception($"Failed to connect with password: {password}");
   ```

---

## Checking for Leaked Secrets

### Before Commit

**Pre-commit checklist:**
```bash
# Search for potential secrets
git diff --cached | grep -i "password\|secret\|token\|api.*key"

# Check staged files
git diff --cached --name-only | xargs grep -i "password\|secret\|token"
```

### Leaked Secret? Fix Immediately!

**If you accidentally committed a secret:**

```bash
# 1. IMMEDIATELY rotate the secret
# - Change password
# - Regenerate API key
# - Revoke token

# 2. Remove from Git history (if just committed)
git reset HEAD~1  # Undo last commit
git commit -m "..."  # Commit without secret

# 3. If pushed to remote - contact admin to rotate secret
# - Cannot reliably remove from public Git history
# - Anyone could have copied it
```

---

## Platform-Specific Guides

### Azure

**Use Azure Key Vault** for production secrets:

```csharp
// Add NuGet: Azure.Extensions.AspNetCore.Configuration.Secrets

public static IHostBuilder CreateHostBuilder(string[] args) =>
    Host.CreateDefaultBuilder(args)
        .ConfigureAppConfiguration((context, config) =>
        {
            if (context.HostingEnvironment.IsProduction())
            {
                var keyVaultUrl = new Uri("https://mykeyvault.vault.azure.net/");
                config.AddAzureKeyVault(keyVaultUrl, new DefaultAzureCredential());
            }
        });
```

### AWS

**Use AWS Secrets Manager:**

```bash
# Install AWS CLI
aws secretsmanager get-secret-value --secret-id prod/myapp/db-password
```

### Google Cloud

**Use Secret Manager:**

```bash
# Install gcloud CLI
gcloud secrets versions access latest --secret="db-password"
```

---

## Common Scenarios

### Database Connection String

**Development** (User Secrets):
```bash
dotnet user-secrets set "ConnectionStrings:Default" "Server=localhost;Database=dev;User=dev;Password=DevPass123"
```

**Production** (Environment Variable):
```bash
export ConnectionStrings__Default="Server=prod-db;Database=prod;User=produser;Password=ProdPass456"
```

### API Keys

**Development:**
```bash
dotnet user-secrets set "OpenAI:ApiKey" "sk-dev123"
dotnet user-secrets set "GitHub:Token" "ghp_dev456"
```

**Production:**
```bash
export OpenAI__ApiKey="sk-prod789"
export GitHub__Token="ghp_prod012"
```

### Multiple Environments

**Use environment-specific config files (without secrets):**

- `appsettings.json` - Shared config
- `appsettings.Development.json` - Dev overrides (no secrets)
- `appsettings.Production.json` - Prod overrides (no secrets)

**Secrets always via User Secrets (dev) or Environment Variables (prod).**

---

## Verification Checklist

Before deploying:

- [ ] No secrets in `appsettings.json`
- [ ] No secrets in `appsettings.Production.json`
- [ ] `.env` files in `.gitignore`
- [ ] User Secrets configured for development
- [ ] Environment variables configured for production
- [ ] systemd `EnvironmentFile` set (if Linux service)
- [ ] GitHub Secrets configured (if CI/CD)
- [ ] No hardcoded secrets in code
- [ ] No secrets in logs or error messages

---

## SecureStore - Standard for Olbrasoft Projects

All Olbrasoft production applications use **NeoSmart.SecureStore** - an encrypted JSON vault with keyfile-based decryption.

### Why SecureStore?

| Approach | Pros | Cons |
|----------|------|------|
| User Secrets | Simple, built-in | Per-user, not portable |
| Environment Variables | Standard | Visible in process list, systemd files |
| Plaintext files | Simple | **Security risk - NOT RECOMMENDED** |
| **SecureStore** | Encrypted, portable, single keyfile | Requires initial setup |

SecureStore provides:
- **Encrypted vault** - AES + HMAC encryption, secrets encrypted at rest
- **Single keyfile** - One file to protect (chmod 600)
- **IConfiguration integration** - Works seamlessly with .NET configuration
- **Portable** - Copy vault + keyfile to any machine

### Directory Structure

All Olbrasoft projects use the same pattern:

```
~/.config/{app-name}/
├── secrets/
│   └── secrets.json      # Encrypted vault (AES + HMAC)
└── keys/
    └── secrets.key       # Encryption key (chmod 600!)
```

**Examples:**
- `~/.config/github-issues/secrets/secrets.json`
- `~/.config/handbook-search/secrets/secrets.json`
- `~/.config/virtual-assistant/secrets/secrets.json`

### Setup

```bash
# 1. Install NeoSmart.SecureStore CLI tool
dotnet tool install --global SecureStore.Client

# 2. Create vault and keyfile (replace {app-name})
APP_NAME=github-issues  # or handbook-search, virtual-assistant, etc.
mkdir -p ~/.config/$APP_NAME/secrets
mkdir -p ~/.config/$APP_NAME/keys

SecureStore create \
  -s ~/.config/$APP_NAME/secrets/secrets.json \
  -k ~/.config/$APP_NAME/keys/secrets.key

# 3. Secure the keyfile (CRITICAL!)
chmod 600 ~/.config/$APP_NAME/keys/secrets.key
```

### Managing Secrets

```bash
# Define paths (add to ~/.bashrc for convenience)
APP_NAME=github-issues
SECRETS_PATH=~/.config/$APP_NAME/secrets/secrets.json
KEY_PATH=~/.config/$APP_NAME/keys/secrets.key

# Add a secret
SecureStore set -s $SECRETS_PATH -k $KEY_PATH "Database:Password=MySecretPassword"

# Get a secret
SecureStore get -s $SECRETS_PATH -k $KEY_PATH "Database:Password"

# List all secrets
SecureStore get -s $SECRETS_PATH -k $KEY_PATH --all

# Delete a secret
SecureStore delete -s $SECRETS_PATH -k $KEY_PATH "Database:Password"
```

### Common Secret Names by Project

**GitHub.Issues:**
```bash
TranslatorPool:AzureApiKey1
TranslatorPool:AzureApiKey2
TranslatorPool:DeepLApiKey1
TranslatorPool:DeepLApiKey2
GitHub:Token
GitHubApp:WebhookSecret
Database:Password
AiProviders:Cohere:Key1
```

**HandbookSearch:**
```bash
Database:Password
AzureTranslator:SubscriptionKey
GitHub:Token
```

**VirtualAssistant:**
```bash
Database:Password
TTS:AzureTTS:SubscriptionKey
LlmChain:Mistral:ApiKey
LlmChain:Cerebras:ApiKeys
GitHub:Token
```

### Integration with ASP.NET Core

**Add NuGet package:**
```bash
dotnet add package NeoSmart.SecureStore
```

**Program.cs:**

```csharp
using NeoSmart.SecureStore;

var builder = WebApplication.CreateBuilder(args);

// Add SecureStore as configuration source
var appName = "github-issues";
var secretsPath = Path.Combine(
    Environment.GetFolderPath(Environment.SpecialFolder.UserProfile),
    $".config/{appName}/secrets/secrets.json");
var keyPath = Path.Combine(
    Environment.GetFolderPath(Environment.SpecialFolder.UserProfile),
    $".config/{appName}/keys/secrets.key");

builder.Configuration.AddSecureStore(secretsPath, keyPath);

// Secrets now available via IConfiguration
var dbPassword = builder.Configuration["Database:Password"];
var azureKey = builder.Configuration["TranslatorPool:AzureApiKey1"];
```

### Security Best Practices

1. **Keyfile permissions:** Always `chmod 600` - readable only by owner
2. **Never commit keyfile:** Add `*.key` to `.gitignore`
3. **Vault is safe to commit:** Encrypted JSON, useless without keyfile
4. **Backup keyfile securely:** Losing keyfile = losing access to secrets
5. **One keyfile per environment:** Dev/staging/prod should have separate keyfiles

### Deployment Checklist

- [ ] Keyfile exists at expected path (`~/.config/{app}/keys/secrets.key`)
- [ ] Keyfile has chmod 600 permissions
- [ ] Encrypted vault exists (`~/.config/{app}/secrets/secrets.json`)
- [ ] All required secrets present in vault
- [ ] Service has read access to keyfile
- [ ] No keyfiles in Git repository

### Troubleshooting

```bash
# Verify keyfile permissions
ls -la ~/.config/github-issues/keys/secrets.key
# Should show: -rw------- (600)

# Test vault access
SecureStore get -s $SECRETS_PATH -k $KEY_PATH --all

# Check service can read keyfile
sudo -u $(whoami) cat ~/.config/github-issues/keys/secrets.key > /dev/null && echo "OK"

# If permission denied - check ownership
ls -la ~/.config/github-issues/keys/
```

### Migration from Old Approaches

If migrating from plaintext files or environment variables:

1. **Identify all secrets** in old location
2. **Create SecureStore vault** (see Setup above)
3. **Add each secret** to vault
4. **Update application** to use SecureStore configuration provider
5. **Test locally** before deploying
6. **Remove old secrets** (delete plaintext files, unset env vars)

---

## See Also

- [Git Workflow](workflow/git-workflow-workflow.md) - Git best practices, commit checklist
- [Web Deployment](dotnet/continuous-deployment/web-deploy-continuous-deployment.md) - Deploying with secrets
- [NuGet Publishing](dotnet/continuous-deployment/nuget-publish-continuous-deployment.md) - Publishing with API keys
- [GitHub Operations](workflow/github-operations-workflow.md) - GitHub API authentication
