# NuGet Package Management Workflow

Managing NuGet packages, dependencies, and their configuration in .NET projects.

## Olbrasoft Package Versioning

### Floating Versions for Olbrasoft Packages

**CRITICAL:** Olbrasoft packages (packages created and maintained by Olbrasoft) are ALWAYS referenced with **wildcard/floating versions** to automatically get the latest version.

```xml
<!-- ✅ CORRECT: Olbrasoft packages use wildcard -->
<PackageReference Include="Olbrasoft.Data" Version="10.*" />
<PackageReference Include="Olbrasoft.Extensions" Version="1.*" />
<PackageReference Include="Olbrasoft.Text.Translation" Version="10.*" />
<PackageReference Include="Olbrasoft.Testing.Xunit.Attributes" Version="1.*" />

<!-- ❌ WRONG: Never use exact versions for Olbrasoft packages in production -->
<PackageReference Include="Olbrasoft.Data" Version="10.0.2" />
```

**Why floating versions for Olbrasoft packages?**
- Automatic updates when new versions are published
- Consistent versioning across all projects
- No manual version bumping required
- All projects automatically get bug fixes and improvements

**Exception: Local Testing**
During local testing of **unpublished** packages, use exact versions temporarily:
```xml
<!-- Temporary during local testing ONLY -->
<PackageReference Include="Olbrasoft.NewPackage" Version="1.0.5" />

<!-- After testing, switch back to floating version -->
<PackageReference Include="Olbrasoft.NewPackage" Version="1.*" />
```

### Third-Party Packages: Exact Versions

Third-party packages (Microsoft, Moq, xUnit, etc.) use exact versions for stability:

```xml
<!-- Third-party packages: exact versions -->
<PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.14.1" />
<PackageReference Include="Moq" Version="4.20.72" />
<PackageReference Include="xunit" Version="2.9.3" />
<PackageReference Include="Microsoft.EntityFrameworkCore" Version="10.0.1" />
```

### Version Summary Table

| Package Type | Version Format | Example |
|--------------|----------------|---------|
| **Olbrasoft packages** | Wildcard (`Major.*`) | `Version="10.*"` |
| **Third-party packages** | Exact | `Version="17.14.1"` |
| **Local testing (temp)** | Exact | `Version="10.0.5"` |

---

## Two-Phase Deployment Process

Package deployment follows a **two-phase approach** to ensure stability:

1. **Phase 1: Local Package Testing** - Test with locally packed packages before publishing
2. **Phase 2: Production Deployment** - Deploy published NuGet packages to production

⚠️ **CRITICAL:** Configuration must be verified in **BOTH phases** - local settings may differ from production!

---

## Phase 1: Local Package Testing

Test new/updated packages locally BEFORE publishing to NuGet.org to catch bugs early and avoid indexing delays.

### Step 1: Pack Packages Locally

```bash
cd ~/Olbrasoft/PackageProject
dotnet pack -c Release -o ./artifacts
```

**Output:** `./artifacts/PackageName.10.0.2.nupkg`

### Step 2: Add Local NuGet Source

```bash
cd ~/Olbrasoft/TargetProject
dotnet nuget add source ~/Olbrasoft/PackageProject/artifacts --name "LocalSource"
```

### Step 3: Install Local Package

```bash
dotnet add package PackageName --version 10.0.2
```

⚠️ **Use exact versions** during testing: `Version="10.0.2"` (NOT floating `10.*`)

### Step 4: Clear Cache and Restore

```bash
dotnet nuget locals all --clear
dotnet restore --verbosity detailed | grep "LocalSource"
```

**Verify:** Should show `Installed PackageName 10.0.2 from LocalSource`

### Step 5: Configuration Review - Phase 1 (Local Testing)

⚠️ **CRITICAL:** Review ALL configuration files for local testing:

| File | Action | Example |
|------|--------|---------|
| `appsettings.json` | Add/update package settings | `"GoogleEnabled": true` |
| `appsettings.Development.json` | Local-specific overrides | Development API endpoints |
| User Secrets | Add development API keys | `dotnet user-secrets set "Google:ApiKey" "test123"` |
| `Program.cs` / `Startup.cs` | Register services | `services.AddGoogleTranslator()` |
| `.csproj` files | Align versions across projects | All use same version |

**Checklist - Phase 1:**
- [ ] Package added to .csproj with exact version
- [ ] appsettings.json updated with new settings
- [ ] appsettings.Development.json checked
- [ ] User secrets configured (if needed)
- [ ] Service registration added to Program.cs
- [ ] All dependent projects use same version
- [ ] NuGet cache cleared
- [ ] Build succeeds
- [ ] Tests pass
- [ ] **Application runs with local package**
- [ ] **Functionality verified in running app**

### Step 6: Test Application

```bash
dotnet build
dotnet test
dotnet run
```

**Verify:**
1. Application starts without errors
2. New package functionality works as expected
3. Check logs for initialization messages
4. Test the specific feature added by package

---

## Phase 2: Production Deployment

After successful local testing, deploy published packages to production.

### Step 1: Publish to NuGet.org

```bash
cd ~/Olbrasoft/PackageProject
dotnet pack -c Release
dotnet nuget push artifacts/*.nupkg --source https://api.nuget.org/v3/index.json --api-key YOUR_API_KEY
```

**Wait:** NuGet indexing takes 5-15 minutes

### Step 2: Remove Local Source

```bash
cd ~/Olbrasoft/TargetProject
dotnet nuget remove source LocalSource
```

### Step 3: Update to Published Package

```bash
dotnet nuget locals all --clear
dotnet restore
```

**Verify:** Should now restore from `nuget.org`

```bash
dotnet restore --verbosity detailed | grep "nuget.org"
# Should show: Installed PackageName 10.0.2 from nuget.org
```

### Step 4: Configuration Review - Phase 2 (Production)

⚠️ **CRITICAL:** Production configuration may DIFFER from local testing!

**Re-check ALL configuration files:**

| File | Action | Difference from Local |
|------|--------|----------------------|
| `appsettings.json` | Verify settings | ✅ Usually same |
| `appsettings.Production.json` | Update production overrides | ⚠️ **May differ!** |
| Startup scripts (`app-start.sh`) | Update environment variables | ⚠️ **May differ!** |
| User Secrets | N/A (production doesn't use) | Production uses env vars |
| Service registration | Verify same as Phase 1 | ✅ Should be same |

**Common Differences Between Local and Production:**

| Configuration | Local (Phase 1) | Production (Phase 2) |
|---------------|-----------------|---------------------|
| API Keys | User Secrets | Environment variables in startup script |
| Endpoints | Development URLs | Production URLs |
| Provider Order | All providers enabled | Subset enabled (e.g., only Google) |
| Timeouts | Short (5s) | Longer (30s) |
| Logging | Verbose | Warning/Error only |

### Step 5: Update Startup Scripts

**Example:** Production startup script may need updates

**Before (local testing used Azure + Google):**
```bash
# ~/.local/bin/app-start.sh
nohup env \
    AzureTranslator__ApiKey="xxx" \
    GoogleTranslator__ApiKey="yyy" \
    dotnet App.dll &
```

**After (production uses only Google):**
```bash
# ~/.local/bin/app-start.sh
nohup env \
    GoogleTranslator__ApiKey="yyy" \
    dotnet App.dll &
```

⚠️ **Why this matters:** Environment variables override appsettings.json!

### Step 6: Deploy and Verify Production

```bash
# Rebuild with published packages
dotnet build -c Release

# Deploy (example)
dotnet publish -c Release -o /opt/app
sudo systemctl restart myapp.service
```

**Checklist - Phase 2:**
- [ ] Published package available on NuGet.org
- [ ] Local NuGet source removed
- [ ] Restored from nuget.org (verified in logs)
- [ ] appsettings.Production.json updated
- [ ] Startup scripts updated (environment variables)
- [ ] Build succeeds with published package
- [ ] Tests pass with published package
- [ ] Application deployed to production
- [ ] **Production application started successfully**
- [ ] **Logs verified - no configuration errors**
- [ ] **Functionality tested in production environment**

### Step 7: Verify Production Configuration

```bash
# Check application logs
tail -100 /var/log/myapp.log | grep -i "package\|config\|error"

# Look for initialization messages
grep "TranslatorPool\|Google\|initialized" /var/log/myapp.log
```

**Expected:**
- ✅ No "configuration missing" errors
- ✅ Package initialized correctly
- ✅ Using published package version (check logs)
- ✅ Production settings applied (e.g., "Google only")

---

## Configuration Differences: Local vs Production

### Example: Google Translator

**Phase 1 (Local Testing):**

```json
// appsettings.Development.json
{
  "TranslatorPool": {
    "ProviderOrder": ["Google", "Azure", "DeepL"],  // Test all providers
    "GoogleTimeoutSeconds": 5  // Short timeout for dev
  }
}
```

```bash
# User Secrets (local)
dotnet user-secrets set "GoogleTranslator:ApiKey" "dev-key-123"
```

**Phase 2 (Production):**

```json
// appsettings.Production.json
{
  "TranslatorPool": {
    "ProviderOrder": ["Google"],  // Only Google in production
    "GoogleTimeoutSeconds": 30  // Longer timeout for stability
  }
}
```

```bash
# Startup script (production)
nohup env \
    GoogleTranslator__ApiKey="prod-key-xyz" \
    ASPNETCORE_ENVIRONMENT=Production \
    dotnet App.dll &
```

### Why Configuration Differs

| Reason | Local | Production |
|--------|-------|------------|
| **Testing** | Test all providers to verify fallback | Use only validated provider |
| **Performance** | Shorter timeouts (fail fast) | Longer timeouts (reliability) |
| **Secrets** | User Secrets (convenient) | Environment variables (secure) |
| **Endpoints** | Development APIs | Production APIs |
| **Logging** | Verbose (debug) | Minimal (performance) |

### 3. Version Alignment

**Rule:** All projects in solution MUST use the same version of shared packages.

**Example Problem:**
```xml
<!-- Project A -->
<PackageReference Include="Olbrasoft.Translation.Abstractions" Version="10.0.2" />

<!-- Project B -->
<PackageReference Include="Olbrasoft.Translation.Abstractions" Version="10.0.1" />
<!-- ❌ ERROR: Downgrade detected! -->
```

**Fix:** Upgrade all references to the highest version:
```bash
# Find all references
grep -r "Translation.Abstractions" --include="*.csproj"

# Update each project to same version
dotnet add ProjectB.csproj package Olbrasoft.Translation.Abstractions --version 10.0.2
```

### 4. Configuration Integration

#### Example: Adding Google Translator

**Package added:**
```bash
dotnet add package Olbrasoft.Text.Translation.Google --version 10.0.2
```

**Configuration files to update:**

**1. appsettings.json:**
```json
{
  "TranslatorPool": {
    "ProviderOrder": ["Google", "Azure", "DeepL"],
    "GoogleEnabled": true,
    "GoogleTimeoutSeconds": 10
  }
}
```

**2. appsettings.Production.json:**
```json
{
  "TranslatorPool": {
    "ProviderOrder": ["Google"]  // Production override
  }
}
```

**3. Startup script (~/.local/bin/app-start.sh):**
```bash
# Environment variables for API keys
nohup env \
    GoogleTranslator__ApiKey="xxx" \
    AzureTranslator__ApiKey="yyy" \
    ASPNETCORE_ENVIRONMENT=Production \
    dotnet App.dll > app.log 2>&1 &
```

**❌ Common Mistake:**
- Adding package ✅
- Updating appsettings.json ✅
- **Forgetting to update startup script** ❌
- Result: Old configuration still active!

**✅ Correct Approach:**
1. Add package
2. Update ALL config files (json + scripts + user secrets)
3. Test configuration is loaded correctly
4. Verify new functionality works

## Local Package Testing

**Workflow:** Test locally BEFORE publishing to NuGet.org to avoid indexing delays and catch bugs early.

### 1. Pack Packages Locally

```bash
cd ~/Olbrasoft/Text
dotnet pack -c Release -o ./artifacts
```

**Output:** `./artifacts/PackageName.10.0.2.nupkg`

### 2. Add Local NuGet Source

```bash
cd ~/Olbrasoft/GitHub.Issues
dotnet nuget add source ~/Olbrasoft/Text/artifacts --name "TextLocal"
```

### 3. Use Exact Versions

```xml
<PackageReference Include="Olbrasoft.Text.Translation.Google" Version="10.0.2" />
<!-- NOT: Version="10.*" -->
```

### 4. Clear Cache Before Restore

```bash
dotnet nuget locals all --clear
dotnet restore
```

### 5. Verify Local Package is Used

```bash
dotnet restore --verbosity detailed | grep "TextLocal"
# Should show: Installed Olbrasoft.Text.Translation.Google 10.0.2 from TextLocal
```

### 6. After Testing: Publish to NuGet

```bash
cd ~/Olbrasoft/Text
dotnet pack -c Release
dotnet nuget push artifacts/*.nupkg --source https://api.nuget.org/v3/index.json
```

### 7. Update Project to Use Published Package

```bash
# Remove local source
dotnet nuget remove source TextLocal

# Clear cache
dotnet nuget locals all --clear

# Restore from NuGet.org
dotnet restore
```

## Multi-Project Version Management

### Problem: Version Conflicts

```
error NU1605: Package downgrade detected
ProjectA -> PackageB 2.0 -> SharedDep (>= 3.0)
ProjectA -> SharedDep (>= 2.0)
```

### Solution: Centralized Package Management

**Option 1: Directory.Packages.props** (Recommended for .NET 7+)

```xml
<!-- Directory.Packages.props -->
<Project>
  <PropertyGroup>
    <ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>
  </PropertyGroup>

  <ItemGroup>
    <PackageVersion Include="Olbrasoft.Text.Translation.Abstractions" Version="10.0.2" />
    <PackageVersion Include="Olbrasoft.Text.Translation.Google" Version="10.0.2" />
  </ItemGroup>
</Project>
```

```xml
<!-- Project.csproj -->
<ItemGroup>
  <PackageReference Include="Olbrasoft.Text.Translation.Google" />
  <!-- No Version attribute - managed centrally -->
</ItemGroup>
```

**Option 2: Manual Sync**

```bash
# Find all references
grep -r "PackageName" --include="*.csproj"

# Update each to same version
# Use highest version required by any project
```

## Environment Variables vs Configuration Files

### When to Use Each

| Type | Use For | Example |
|------|---------|---------|
| **appsettings.json** | Public config, defaults | Endpoints, timeouts, feature flags |
| **Environment Variables** | Secrets, production overrides | API keys, passwords, connection strings |
| **User Secrets** | Development secrets | Local API keys for testing |

### Configuration Priority (Lowest → Highest)

1. appsettings.json
2. appsettings.{Environment}.json
3. User Secrets (Development only)
4. Environment Variables
5. Command-line arguments

**Example:**
```json
// appsettings.json
{"TranslatorPool": {"ProviderOrder": ["Google", "Azure"]}}

// Environment variable (WINS)
TranslatorPool__ProviderOrder__0="Azure"
TranslatorPool__ProviderOrder__1="Google"
```

### Double Underscore Mapping

Environment variable `Section__SubSection__Key` maps to:
```json
{
  "Section": {
    "SubSection": {
      "Key": "value"
    }
  }
}
```

**Array indexing:**
```bash
TranslatorPool__ProviderOrder__0="Google"
TranslatorPool__ProviderOrder__1="Azure"
```

Maps to:
```json
{"TranslatorPool": {"ProviderOrder": ["Google", "Azure"]}}
```

## Case Study: Google Translator Integration

**Problem:** Added Google Translator package, updated appsettings.json, but application still used Azure.

**Root Cause:** Startup script set environment variables for Azure/DeepL API keys, overriding appsettings.json configuration.

**Lesson:** When adding packages, check ALL configuration sources.

### What Happened

1. ✅ Added package: `Olbrasoft.Text.Translation.Google 10.0.2`
2. ✅ Updated `appsettings.json`: `"ProviderOrder": ["Google"]`
3. ❌ **Missed:** Startup script still set `AzureTranslator__ApiKey` environment variable
4. ❌ **Result:** TranslatorPool initialized with Azure (from env var) instead of Google

### Configuration Sources Found

1. `/opt/app/config/appsettings.json` - File config ✅
2. `/opt/app/app/appsettings.Production.json` - Deployed config ✅
3. `~/.local/bin/app-start.sh` - Environment variables ❌ **MISSED THIS!**

### Fix

```bash
# Before (startup script)
nohup env \
    AzureTranslator__ApiKey="xxx" \
    DeepL__ApiKey="yyy" \
    dotnet App.dll &

# After (removed Azure/DeepL env vars)
nohup env \
    ASPNETCORE_ENVIRONMENT=Production \
    dotnet App.dll &
```

### Verification Checklist

After adding Google Translator:

- [x] Package added to .csproj
- [x] appsettings.json updated
- [x] appsettings.Production.json checked
- [x] **Startup script environment variables removed** ⚠️ This was the missing step!
- [x] User secrets checked (development)
- [x] Application restarted
- [x] Logs verified: "TranslatorPool initialized with Google"

## Troubleshooting

### Package Not Found After Adding

**Symptoms:**
```
error NU1101: Unable to find package PackageName
```

**Solutions:**
1. Check package name spelling
2. Verify version exists on NuGet.org
3. Clear NuGet cache: `dotnet nuget locals all --clear`
4. Check NuGet sources: `dotnet nuget list source`

### Configuration Not Loading

**Symptoms:**
- Package installed
- Configuration file updated
- Feature not working as expected

**Debug Steps:**

1. **Check configuration loading:**
```csharp
// In Startup.cs or Program.cs
var config = builder.Configuration.Get<YourConfig>();
Console.WriteLine(JsonSerializer.Serialize(config)); // Debug output
```

2. **Check environment variables:**
```bash
# List all env vars for running process
cat /proc/PID/environ | tr '\0' '\n' | grep -i "packagename"
```

3. **Check configuration priority:**
```csharp
// See which config source is winning
var debugView = (Configuration as IConfigurationRoot).GetDebugView();
Console.WriteLine(debugView);
```

4. **Verify startup scripts:**
```bash
# Search all startup scripts
grep -r "PACKAGE\|CONFIG" ~/.local/bin/*.sh
```

### Version Conflicts

**Symptoms:**
```
error NU1605: Package downgrade detected
```

**Solution:**
1. Identify all projects using the package
2. Find highest version required
3. Upgrade all projects to that version
4. Clear cache and restore

## Best Practices

### ✅ DO

- Test packages locally before publishing
- Use exact versions during testing
- Check ALL configuration files after adding packages
- Align versions across all projects in solution
- Document configuration requirements in README
- Clear NuGet cache after switching sources
- Verify configuration loading in logs

### ❌ DON'T

- Skip testing local packages
- Use floating versions (`*`, `10.*`) during development
- Forget to update environment variables in startup scripts
- Mix different versions of shared packages
- Commit API keys to Git (use User Secrets or env vars)
- Assume appsettings.json is the only config source

## Related Topics

- [CI/CD - NuGet Publishing](../continuous-deployment/nuget-publish-continuous-deployment.md)
- [Secrets Management](../../secrets-management.md)

---

Last Updated: 2025-12-25
