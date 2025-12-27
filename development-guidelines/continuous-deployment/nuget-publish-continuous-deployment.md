# NuGet Publishing

How to automatically publish .NET libraries to NuGet.org after successful build and tests.

## Prerequisites

Before publishing:
- ✅ Tests pass (see [../continuous-integration/test-continuous-integration.md](../continuous-integration/test-continuous-integration.md))
- ✅ Package tested locally (see [../package-management/local-testing-package-management.md](../package-management/local-testing-package-management.md))
- ✅ NuGet API key configured in GitHub secrets

## Setup NuGet API Key

**1. Get API key:**
```bash
cat ~/Dokumenty/Keys/nuget-key.txt
```

**2. Add to GitHub:**
- Go to: Repository → Settings → Secrets → Actions
- Name: `NUGET_API_KEY`
- Value: [paste key from step 1]

## GitHub Actions Workflow

**File:** `.github/workflows/publish-nuget.yml`

```yaml
name: Publish NuGet
on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - uses: actions/setup-dotnet@v4
      with:
        dotnet-version: 10.0.x

    # Build and test first (continuous integration)
    - run: dotnet restore
    - run: dotnet build -c Release --no-restore
    - run: dotnet test -c Release --no-build

    # Package (continuous deployment)
    - run: dotnet pack -c Release --no-build -o ./artifacts

    # Publish to NuGet.org
    - name: Publish to NuGet
      if: success() && (github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/v'))
      run: |
        dotnet nuget push ./artifacts/*.nupkg \
          --source https://api.nuget.org/v3/index.json \
          --api-key ${{ secrets.NUGET_API_KEY }} \
          --skip-duplicate
```

## Package Metadata

**File:** `YourProject.csproj`

```xml
<PropertyGroup>
  <PackageId>Olbrasoft.YourProject</PackageId>
  <Version>1.0.0</Version>
  <Authors>Olbrasoft</Authors>
  <PackageLicenseExpression>MIT</PackageLicenseExpression>
  <PackageProjectUrl>https://github.com/Olbrasoft/YourProject</PackageProjectUrl>
  <Description>Your package description</Description>
  <TargetFrameworks>netstandard2.1;net8.0;net10.0</TargetFrameworks>
</PropertyGroup>
```

## Versioning Strategy

| Trigger | Version | When |
|---------|---------|------|
| Push to `main` | 1.0.`${{github.run_number}}` | Every commit |
| Tag `v1.2.3` | 1.2.3 | Manual releases |

**Auto-versioning example:**
```xml
<!-- Use GitHub run number for automatic versioning -->
<Version>1.0.${{ github.run_number }}</Version>
```

## Publishing Rules

**Publishes when:**
- ✅ All tests pass
- ✅ Branch is `main` OR tag starts with `v`

**Does NOT publish when:**
- ❌ Tests fail
- ❌ Branch is NOT `main` (e.g., `develop`, `feature/*`)
- ❌ Pull request (only builds/tests)

## Multi-Package Repositories

**Example:** TextToSpeech repository

```
src/
  ├─ TextToSpeech.Core/           → Olbrasoft.TextToSpeech.Core
  ├─ TextToSpeech.Providers/      → Olbrasoft.TextToSpeech.Providers
  └─ TextToSpeech.Orchestration/  → Olbrasoft.TextToSpeech.Orchestration

examples/
  └─ Demo/                        → NOT published (IsPackable=false)
```

**Workflow publishes ALL packages at once:**
```yaml
- run: dotnet pack -c Release --no-build -o ./artifacts
- run: dotnet nuget push ./artifacts/*.nupkg --source https://api.nuget.org/v3/index.json ...
```

**Exclude demo apps:**
```xml
<!-- examples/Demo/Demo.csproj -->
<IsPackable>false</IsPackable>
```

## Common Errors

| Error | Fix |
|-------|-----|
| `403 Forbidden` | Check `NUGET_API_KEY` secret is correct |
| `409 Conflict` | Version already exists - increment version |
| `401 Unauthorized` | API key expired - generate new key |
| `404 Not Found` | Wrong NuGet source URL |

## Verification

After publish workflow succeeds:

**1. Check NuGet.org (5-15 minutes delay):**
```
https://www.nuget.org/packages/Olbrasoft.YourProject
```

**2. Install in test project:**
```bash
dotnet add package Olbrasoft.YourProject
dotnet restore
```

## Best Practices

1. **Always test locally first** - see [local-package-testing.md](../package-management/local-testing-package-management.md)
2. **Use semantic versioning** - MAJOR.MINOR.PATCH
3. **Write release notes** - in GitHub releases for tags
4. **Don't rush** - wait for NuGet.org indexing before using package

## See Also

- [Build](../continuous-integration/build-continuous-integration.md) - Build packages
- [Test](../continuous-integration/test-continuous-integration.md) - Test before publishing
- [Local Package Testing](../package-management/local-testing-package-management.md) - Test before CI/CD
