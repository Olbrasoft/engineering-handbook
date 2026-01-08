# Package Management

Managing NuGet packages, dependencies, and configuration in .NET projects.

## Olbrasoft Package Versioning

**CRITICAL:** Olbrasoft packages ALWAYS use **floating/wildcard versions** to automatically get the latest version.

```xml
<!-- ✅ CORRECT: Olbrasoft packages use wildcard -->
<PackageReference Include="Olbrasoft.Data" Version="10.*" />
<PackageReference Include="Olbrasoft.Testing.Xunit.Attributes" Version="1.*" />

<!-- ❌ WRONG: Never use exact versions for Olbrasoft packages -->
<PackageReference Include="Olbrasoft.Data" Version="10.0.2" />
```

**Exception:** During local testing of unpublished packages, use exact versions temporarily.

See: [Package Versioning](overview-package-management.md#olbrasoft-package-versioning) for complete guide.

## Overview

This section covers NuGet package management workflow:

- **Local Package Testing** - Test packages locally before publishing
- **Package Overview** - Configuration, versioning, dependencies, deployment

## Quick Start

### Test Package Locally Before Publishing

```bash
# 1. Pack package locally
cd ~/Olbrasoft/MyPackage
dotnet pack -c Release -o ./artifacts

# 2. Add local NuGet source
cd ~/Olbrasoft/TestProject
dotnet nuget add source ~/Olbrasoft/MyPackage/artifacts --name "LocalSource"

# 3. Install local package
dotnet add package MyPackage --version 1.0.0

# 4. Test thoroughly
dotnet build
dotnet test

# 5. Publish when ready
cd ~/Olbrasoft/MyPackage
dotnet nuget push artifacts/MyPackage.1.0.0.nupkg -s nuget.org -k $NUGET_API_KEY
```

See: [Local Testing](local-testing-package-management.md) for complete guide.

## File Index

- **[local-testing-package-management.md](local-testing-package-management.md)** - Test NuGet packages locally before publishing
- **[overview-package-management.md](overview-package-management.md)** - Complete package management guide: configuration, versioning, deployment

## Common Scenarios

### Test New Package Version Locally

```bash
# Pack latest version
dotnet pack -c Release -o ./artifacts

# Clear NuGet cache
dotnet nuget locals all --clear

# Restore with local source
dotnet restore --verbosity detailed

# Verify correct version loaded
dotnet list package
```

### Publish Package to NuGet.org

```bash
# Pack release version
dotnet pack -c Release

# Push to NuGet.org
dotnet nuget push bin/Release/MyPackage.1.0.0.nupkg \
  -s nuget.org \
  -k $NUGET_API_KEY
```

### Update Package in Consumer Project

```bash
# Update to latest version
dotnet add package MyPackage

# Update to specific version
dotnet add package MyPackage --version 2.0.0

# Update all packages
dotnet list package --outdated
dotnet add package PackageName # Repeat for each
```

## Best Practices

### Package Versioning

✅ **DO:**
- Use floating versions for Olbrasoft packages (`10.*`, `1.*`)
- Use exact versions for third-party packages
- Use exact versions ONLY during local testing of unpublished packages

❌ **DON'T:**
- Use exact versions for Olbrasoft packages in production
- Use floating versions for third-party packages

### Local Testing

✅ **DO:**
- ALWAYS test locally before publishing
- Use exact versions during local testing (`10.0.2`)
- Clear NuGet cache before testing
- Test in real consumer project
- Verify configuration works

❌ **DON'T:**
- Publish without local testing
- Use floating versions locally (`10.*`)
- Skip cache clearing
- Test only in package project

### Version Management

✅ **DO:**
- Use semantic versioning (Major.Minor.Patch)
- Update version before publishing
- Document breaking changes
- Test version upgrades

❌ **DON'T:**
- Reuse version numbers
- Skip version bumps
- Publish breaking changes as patches

## Integration with CI/CD

After local testing passes:

1. **Commit and push changes**
   ```bash
   git add .
   git commit -m "Update package to v1.0.1"
   git push
   ```

2. **CI builds and publishes**
   - See: [NuGet Publish CI/CD](../continuous-deployment/nuget-publish-continuous-deployment.md)

## Troubleshooting

### Package Not Found

**Problem:** `dotnet restore` can't find local package

**Solution:**
```bash
# 1. Verify local source exists
dotnet nuget list source

# 2. Clear cache
dotnet nuget locals all --clear

# 3. Restore with verbosity
dotnet restore --verbosity detailed
```

### Wrong Version Loaded

**Problem:** Old package version loaded instead of new one

**Solution:**
```bash
# 1. Clear ALL caches
dotnet nuget locals all --clear

# 2. Remove bin/ and obj/
rm -rf bin/ obj/

# 3. Restore
dotnet restore

# 4. Verify version
dotnet list package
```

### Configuration Not Working

**Problem:** Settings work locally but fail in production

**Solution:**
- Check `appsettings.json` vs `appsettings.Production.json`
- Verify environment variables in production
- See: [Overview](overview-package-management.md#configuration-differences-local-vs-production)

## Next Steps

- **[Local Testing →](local-testing-package-management.md)** - Test packages locally step-by-step
- **[Overview →](overview-package-management.md)** - Complete package management guide

## See Also

- [Continuous Deployment - NuGet](../continuous-deployment/nuget-publish-continuous-deployment.md) - Publish packages in CI/CD
- [Project Structure](../project-structure-dotnet.md) - Organize package projects
- [Workflow Guide](../../workflow/index-workflow.md) - Git workflow for packages
