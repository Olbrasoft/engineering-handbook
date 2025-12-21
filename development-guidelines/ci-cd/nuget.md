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

⚠️ **REQUIRED: Use automatic versioning for all NuGet packages**

Manual versioning leads to:
- ❌ Forgotten version bumps
- ❌ Build failures on NuGet (409 Conflict)
- ❌ Wasted CI/CD time
- ❌ Human error

**Choose one automatic strategy:**

### 1. Auto-increment (RECOMMENDED) ✅
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
- name: Pack with version
  run: dotnet pack -p:Version=${{ steps.version.outputs.version }}
```

**.csproj fallback for local builds:**
```xml
<!-- Version is auto-calculated in CI/CD as 1.1.${{ github.run_number }} -->
<!-- This is fallback for local builds only -->
<Version>1.1.0-local</Version>
```

Result: `1.1.11`, `1.1.12`, `1.1.13`, ... (auto-increments on every CI run)

Examples: [SystemTray](https://github.com/Olbrasoft/SystemTray), [TextToSpeech](https://github.com/Olbrasoft/TextToSpeech)

### 2. Git tag-based (Alternative) ✅
```yaml
- name: Extract version from tag
  run: echo "VERSION=${GITHUB_REF#refs/tags/v}" >> $GITHUB_ENV
- run: dotnet pack -p:Version=${{ env.VERSION }}
```

Publish only when pushing tags: `git tag v1.2.3 && git push --tags`

### 3. Manual (DEPRECATED) ❌
```xml
<Version>1.0.0</Version>
```

**DO NOT USE** - requires manual editing, causes build failures.

## Checklist

- [ ] `.github/workflows/build.yml` exists
- [ ] `.github/workflows/publish-nuget.yml` exists
- [ ] `NUGET_API_KEY` secret configured
- [ ] ⚠️ **REQUIRED:** Automatic versioning configured (auto-increment or git tag-based)
- [ ] `.csproj` has fallback version for local builds (e.g., `1.1.0-local`)
- [ ] `.csproj` has NuGet metadata (`PackageId`, `Authors`, `Description`, etc.)
- [ ] Demo/test projects have `<IsPackable>false</IsPackable>`
- [ ] Tests pass locally: `dotnet test`

## Common Issues

| Problem | Cause | Fix |
|---------|-------|-----|
| 409 Conflict | Version exists | Increment `<Version>` |
| 401 Unauthorized | Invalid API key | Check `NUGET_API_KEY` secret |
| No .nupkg found | Missing metadata | Add `<PackageId>` to .csproj |
| Demo app published | Missing `<IsPackable>false</IsPackable>` | Add to demo .csproj |

## Consuming Olbrasoft Packages

⚠️ **REQUIRED: Always use floating versions for Olbrasoft packages**

When referencing Olbrasoft NuGet packages in your projects, **ALWAYS** use floating version patterns to automatically get the latest compatible version.

### Why Floating Versions?

- ✅ Automatic updates on every build
- ✅ No manual version bumps needed
- ✅ Always use latest bug fixes
- ✅ Prevents version drift across projects
- ❌ Eliminates forgotten version updates

### How to Use Floating Versions

**CORRECT ✅**
```xml
<PackageReference Include="Olbrasoft.SystemTray.Linux" Version="1.*" />
<PackageReference Include="Olbrasoft.Data.Cqrs.Common" Version="1.*" />
<PackageReference Include="Olbrasoft.TextToSpeech.Core" Version="1.*" />
```

**INCORRECT ❌**
```xml
<PackageReference Include="Olbrasoft.SystemTray.Linux" Version="1.1.2" />
<PackageReference Include="Olbrasoft.Data.Cqrs.Common" Version="1.7.0" />
```

### Version Patterns

| Pattern | Meaning | Use Case |
|---------|---------|----------|
| `1.*` | Latest 1.x version | **RECOMMENDED** - Major version lock |
| `*` | Latest version | ⚠️ Use with caution - may break on major updates |

### When to Pin Versions

Only pin to specific versions for:
- **External packages** (Microsoft.*, Npgsql.*, etc.)
- **Breaking dependency** (known incompatibility)
- **Temporary workaround** (document reason in comment)

**Example with comment:**
```xml
<!-- Pinned to 1.5.0 due to breaking change in 1.6.0 - TODO: upgrade after fix -->
<PackageReference Include="Olbrasoft.SomePackage" Version="1.5.0" />
```

### Build Behavior

With `Version="1.*"`:
- Local: `dotnet restore` downloads latest 1.x
- CI/CD: Fresh restore gets latest published version
- Result: Always synchronized across team

### Examples

See how VirtualAssistant uses floating versions:
```bash
~/Olbrasoft/VirtualAssistant/src/VirtualAssistant.Service/VirtualAssistant.Service.csproj
~/Olbrasoft/VirtualAssistant/src/VirtualAssistant.Voice/VirtualAssistant.Voice.csproj
```

## Reference

- [Mediation example](https://github.com/Olbrasoft/Mediation/tree/main/.github/workflows)
- [TextToSpeech example](https://github.com/Olbrasoft/TextToSpeech/blob/main/.github/workflows/publish-nuget.yml)
