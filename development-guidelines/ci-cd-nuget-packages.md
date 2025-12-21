# CI/CD for NuGet Packages

Publishing .NET libraries to NuGet.org via GitHub Actions.

## When to Use
- Project type: Class library
- Distribution: NuGet.org
- Examples: TextToSpeech, Mediation, SystemTray

## Quick Setup

### 1. NuGet API Key
```bash
# Read key
cat ~/Dokumenty/Keys/nuget-key.txt

# Add to GitHub repo
# Settings → Secrets → Actions → NUGET_API_KEY
```

### 2. Build Workflow (`.github/workflows/build.yml`)
```yaml
name: Build
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-dotnet@v4
      with:
        dotnet-version: 10.0.x
    - run: dotnet restore
    - run: dotnet build -c Release --no-restore
    - run: dotnet test -c Release --no-build
```

### 3. Publish Workflow (`.github/workflows/publish-nuget.yml`)
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
    - run: dotnet restore
    - run: dotnet build -c Release --no-restore
    - run: dotnet test -c Release --no-build
    - run: dotnet pack -c Release --no-build -o ./artifacts
    - run: |
        dotnet nuget push ./artifacts/*.nupkg \
          --source https://api.nuget.org/v3/index.json \
          --api-key ${{ secrets.NUGET_API_KEY }} \
          --skip-duplicate
      if: success() && (github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/v'))
```

### 4. .csproj Metadata
```xml
<PropertyGroup>
  <PackageId>Olbrasoft.YourProject</PackageId>
  <Version>1.0.0</Version>
  <Authors>Olbrasoft</Authors>
  <PackageLicenseExpression>MIT</PackageLicenseExpression>
  <PackageProjectUrl>https://github.com/Olbrasoft/YourProject</PackageProjectUrl>
</PropertyGroup>
```

## Multi-Package Repositories

**Auto-detection:** `dotnet pack` finds ALL projects with NuGet metadata.

**Example:** TextToSpeech publishes 5 packages simultaneously:
```
src/
  ├─ TextToSpeech.Core/              → .nupkg
  ├─ TextToSpeech.Providers/         → .nupkg
  ├─ TextToSpeech.Providers.EdgeTTS/ → .nupkg
  ├─ TextToSpeech.Providers.Piper/   → .nupkg
  └─ TextToSpeech.Orchestration/     → .nupkg
```

**Exclude projects:**
```xml
<IsPackable>false</IsPackable>
```

**Workflow:**
```yaml
- name: Collect packages
  run: |
    mkdir -p ./artifacts
    find . -name "*.nupkg" -path "*/bin/Release/*" -exec cp {} ./artifacts/ \;

- name: Publish all
  run: dotnet nuget push ./artifacts/*.nupkg --api-key ${{ secrets.NUGET_API_KEY }} --skip-duplicate
```

## Publishing Triggers

Publishes when:
1. ✅ Tests pass (`dotnet test` exit 0)
2. ✅ Push to `main` branch OR tag `v*`

## Versioning Strategies

### 1. Manual (in .csproj)
```xml
<Version>1.0.0</Version>
```

### 2. Auto-increment (TextToSpeech pattern)
```yaml
env:
  VERSION_PREFIX: "1.1"

steps:
- name: Calculate version
  id: version
  run: |
    VERSION="${{ env.VERSION_PREFIX }}.${{ github.run_number }}"
    echo "version=$VERSION" >> $GITHUB_OUTPUT

- name: Build with version
  run: dotnet build -p:Version=${{ steps.version.outputs.version }}
```
Result: `1.1.42`, `1.1.43`, ...

### 3. Git tag-based
```yaml
- name: Extract version from tag
  run: echo "VERSION=${GITHUB_REF#refs/tags/v}" >> $GITHUB_ENV
- run: dotnet pack -p:Version=${{ env.VERSION }}
```

## Checklist

- [ ] `.github/workflows/build.yml` exists
- [ ] `.github/workflows/publish-nuget.yml` exists
- [ ] `NUGET_API_KEY` secret configured
- [ ] `.csproj` has NuGet metadata (`PackageId`, `Version`, etc.)
- [ ] Demo/test projects have `<IsPackable>false</IsPackable>`
- [ ] Tests pass locally: `dotnet test`

## Common Issues

| Problem | Cause | Fix |
|---------|-------|-----|
| 409 Conflict | Version exists | Increment `<Version>` |
| 401 Unauthorized | Invalid API key | Check `NUGET_API_KEY` secret |
| No .nupkg found | Missing metadata | Add `<PackageId>` to .csproj |
| Demo app published | Missing `<IsPackable>false</IsPackable>` | Add to demo .csproj |

## Reference

- [Mediation example](https://github.com/Olbrasoft/Mediation/tree/main/.github/workflows)
- [TextToSpeech example](https://github.com/Olbrasoft/TextToSpeech/blob/main/.github/workflows/publish-nuget.yml)
