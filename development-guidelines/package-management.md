# NuGet Package Management Workflow

Managing NuGet packages, dependencies, and their configuration in .NET projects.

## Adding or Upgrading Packages

When adding new packages or upgrading existing ones, follow this checklist to ensure proper integration.

### 1. Install Package

```bash
dotnet add package PackageName --version X.Y.Z
```

**During development/testing:**
- Use local packages first (see [Local Package Testing](#local-package-testing))
- Use exact versions during testing: `Version="10.0.2"` (not floating `10.*`)

**After testing:**
- Publish to NuGet.org
- Update project references to use published packages

### 2. Configuration Review Checklist

⚠️ **CRITICAL:** After adding/upgrading packages, **ALWAYS review ALL configuration files**

| File | Check | Example |
|------|-------|---------|
| `appsettings.json` | New settings for package features | Translation provider config |
| `appsettings.Production.json` | Production-specific overrides | Different API endpoints |
| Startup scripts | Environment variables for API keys | `~/.local/bin/app-start.sh` |
| User Secrets | Development API keys | `dotnet user-secrets list` |
| `Program.cs` / `Startup.cs` | Service registration | `services.AddTranslator(...)` |
| `.csproj` files | Version alignment across projects | All projects use same version |

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

- [CI/CD - NuGet Publishing](ci-cd/nuget/CLAUDE.md)
- [Secrets Management](workflow/workflow.md#secrets-management)
- [Local Package Testing](ci-cd/nuget/local-testing.md)

---

Last Updated: 2025-12-25
