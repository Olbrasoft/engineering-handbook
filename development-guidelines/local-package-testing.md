# Local Package Testing

How to test NuGet packages locally BEFORE publishing to NuGet.org.

## Why Test Locally?

**🚨 CRITICAL: ALWAYS test new packages locally before publishing!**

| ✅ Test Locally First | ❌ Publish First (DON'T!) |
|----------------------|---------------------------|
| Catch bugs immediately | Wait 5-15 min for NuGet.org indexing |
| Fix without version bump | Broken package published forever |
| Test realistic integration | Find bugs after public release |
| Save CI/CD time | Waste workflow runs |

## Workflow Steps

### 1. Build Package Locally

```bash
cd ~/Olbrasoft/YourPackageRepo

dotnet restore
dotnet build -c Release
dotnet pack -c Release --no-build -o ./artifacts

# Verify package created
ls -lh ./artifacts/*.nupkg
# Should show: Olbrasoft.YourPackage.1.0.5.nupkg
```

### 2. Add Local NuGet Source

```bash
cd ~/Olbrasoft/YourConsumingProject

# Add local package source (one-time setup)
dotnet nuget add source ~/Olbrasoft/YourPackageRepo/artifacts \
  --name "YourPackageLocal"

# Verify source added
dotnet nuget list source
# Should show: nuget.org, YourPackageLocal
```

### 3. Reference Local Package

**Edit:** `YourConsumingProject.csproj`

```xml
<ItemGroup>
  <!-- Use EXACT version from local build -->
  <PackageReference Include="Olbrasoft.YourPackage" Version="1.0.5" />
</ItemGroup>
```

**Important:** Use exact version (not `1.*`) to ensure local package is used.

### 4. Test Consuming Project

```bash
cd ~/Olbrasoft/YourConsumingProject

# Clear cache to force using local package
dotnet nuget locals all --clear

# Restore (gets local package)
dotnet restore

# Build and test
dotnet build
dotnet test
dotnet run  # Or deploy and test

# Verify local package was used
dotnet list package | grep YourPackage
```

### 5. Fix Bugs (if found)

```bash
cd ~/Olbrasoft/YourPackageRepo

# Fix the bug in code
# ... edit files ...

# Rebuild and repack
dotnet build -c Release
dotnet pack -c Release --no-build -o ./artifacts

# Test again in consuming project
cd ~/Olbrasoft/YourConsumingProject
dotnet nuget locals all --clear
dotnet restore
dotnet test
```

**Repeat until all tests pass!**

### 6. Publish to NuGet.org

**Once local testing succeeds:**

```bash
cd ~/Olbrasoft/YourPackageRepo

git add .
git commit -m "feat: Add YourPackage (tested locally)"
git push

# CI/CD workflow automatically publishes to NuGet.org
```

### 7. Switch to NuGet.org Package

**After NuGet.org publish (wait 5-15 minutes for indexing):**

**Edit:** `YourConsumingProject.csproj`

```xml
<ItemGroup>
  <!-- Change to floating version for NuGet.org -->
  <PackageReference Include="Olbrasoft.YourPackage" Version="1.*" />
</ItemGroup>
```

```bash
cd ~/Olbrasoft/YourConsumingProject

# Clear cache
dotnet nuget locals all --clear

# Restore from NuGet.org
dotnet restore
dotnet build
dotnet test

# Optional: Remove local source
dotnet nuget remove source YourPackageLocal
```

## Managing Local Sources

### Add Persistent Local Source

```bash
# Add to global NuGet config (~/.nuget/NuGet/NuGet.Config)
dotnet nuget add source ~/Olbrasoft/Text/artifacts --name "TextLocal"
dotnet nuget add source ~/Olbrasoft/Data/artifacts --name "DataLocal"
```

### List All Sources

```bash
dotnet nuget list source
# Output:
#   1. nuget.org [Enabled]
#   2. TextLocal [Enabled] ~/Olbrasoft/Text/artifacts
#   3. DataLocal [Enabled] ~/Olbrasoft/Data/artifacts
```

### Remove Local Source

```bash
dotnet nuget remove source TextLocal
```

### Clear All Caches

```bash
# Clears: http-cache, temp, global-packages
dotnet nuget locals all --clear
```

## Best Practices

1. **ALWAYS test locally first** - Never publish untested packages
2. **Use exact versions** during local testing (`Version="1.0.5"`)
3. **Clear cache before testing** (`dotnet nuget locals all --clear`)
4. **Test ALL features** in consuming project
5. **Fix bugs before publishing** - iterate locally until perfect
6. **Switch to floating versions** after NuGet.org publish (`Version="1.*"`)
7. **Remove local sources** after testing to avoid confusion

## Complete Example

```bash
# === CREATE PACKAGE ===
cd ~/Olbrasoft/Text
# ... write Translation package code ...
dotnet pack -c Release -o ./artifacts

# === TEST IN VIRTUALASSISTANT ===
cd ~/Olbrasoft/VirtualAssistant

# Add local source
dotnet nuget add source ~/Olbrasoft/Text/artifacts --name "TextLocal"

# Edit .csproj: <PackageReference Include="Olbrasoft.Text.Translation" Version="1.0.10" />

# Test
dotnet nuget locals all --clear
dotnet restore
dotnet build
dotnet test
./deploy/deploy.sh ~/apps/virtual-assistant  # Test deployed app

# === FIX BUG (if found) ===
cd ~/Olbrasoft/Text
# ... fix bug ...
dotnet build -c Release
dotnet pack -c Release --no-build -o ./artifacts

cd ~/Olbrasoft/VirtualAssistant
dotnet nuget locals all --clear
dotnet restore
dotnet test  # Re-test

# === PUBLISH TO NUGET.ORG ===
cd ~/Olbrasoft/Text
git commit -am "feat: Add Translation package"
git push  # CI/CD publishes to NuGet.org

# === SWITCH TO NUGET.ORG ===
# Wait 10 minutes for NuGet.org indexing

cd ~/Olbrasoft/VirtualAssistant
# Edit .csproj: <PackageReference Include="Olbrasoft.Text.Translation" Version="1.*" />
dotnet nuget locals all --clear
dotnet restore  # Gets from NuGet.org
dotnet build
dotnet test

# Clean up
dotnet nuget remove source TextLocal
```

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Package not found | Clear cache: `dotnet nuget locals all --clear` |
| Old version used | Use exact version in `.csproj`: `Version="1.0.5"` |
| NuGet.org version used instead | Clear cache, verify local source in `dotnet nuget list source` |
| Package restore slow | Local source should be fast - check path is correct |

## See Also

- [NuGet Publishing](continuous-deployment/nuget-publish.md) - How to publish after testing
- [Build](continuous-integration/build.md) - How to build packages
- [Package Management](package-management.md) - NuGet package management
