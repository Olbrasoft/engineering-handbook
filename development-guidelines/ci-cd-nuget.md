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

## Testing Packages Locally Before Publishing

⚠️ **CRITICAL: Always test new packages locally before publishing to NuGet.org**

### Why Test Locally First?

When creating new NuGet packages, **ALWAYS** test them locally in your consuming project **BEFORE** publishing to NuGet.org:

- ✅ Catch bugs immediately without waiting for NuGet.org indexing (5-15 minutes)
- ✅ Avoid publishing broken packages that require version bumps to fix
- ✅ Test integration with consuming projects in realistic conditions
- ✅ Save CI/CD time and avoid wasted workflow runs
- ❌ If you publish first and find a bug, you must wait for new NuGet.org publish cycle

### Workflow: Local Testing → NuGet Publishing

**1. Create and pack packages locally:**
```bash
cd ~/Olbrasoft/YourPackageRepo
dotnet restore
dotnet build -c Release
dotnet pack -c Release --no-build -o ./artifacts

# Verify packages created
ls -lh ./artifacts/*.nupkg
```

**2. Add local NuGet source to consuming project:**
```bash
cd ~/Olbrasoft/YourConsumingProject

# Add local package source (one-time setup)
dotnet nuget add source ~/Olbrasoft/YourPackageRepo/artifacts \
  --name "LocalPackages"

# Verify source added
dotnet nuget list source
```

**3. Reference local packages in consuming project:**
```xml
<!-- YourConsumingProject.csproj -->
<ItemGroup>
  <!-- Use exact version from local build -->
  <PackageReference Include="Olbrasoft.YourPackage" Version="1.0.5" />
</ItemGroup>
```

**4. Test the consuming project:**
```bash
# Clear NuGet cache to force using local packages
dotnet nuget locals all --clear

# Restore from local source
dotnet restore

# Build and test
dotnet build
dotnet test
dotnet run  # Or deploy and test

# Verify local package was used
dotnet list package | grep YourPackage
```

**5. If bugs found - fix and rebuild:**
```bash
cd ~/Olbrasoft/YourPackageRepo
# Fix the bug
dotnet build -c Release
dotnet pack -c Release --no-build -o ./artifacts

cd ~/Olbrasoft/YourConsumingProject
dotnet nuget locals all --clear
dotnet restore  # Gets updated local package
dotnet test     # Re-test
```

**6. Once local testing passes - publish to NuGet.org:**
```bash
cd ~/Olbrasoft/YourPackageRepo
git add .
git commit -m "feat: Add YourPackage (tested locally)"
git push  # Triggers workflow → publishes to NuGet.org
```

**7. Switch consuming project to NuGet.org packages:**
```xml
<!-- YourConsumingProject.csproj -->
<ItemGroup>
  <!-- Change to floating version for NuGet.org -->
  <PackageReference Include="Olbrasoft.YourPackage" Version="1.*" />
</ItemGroup>
```

```bash
cd ~/Olbrasoft/YourConsumingProject
dotnet nuget locals all --clear
dotnet restore  # Now uses NuGet.org
dotnet build
dotnet test

# Optional: Remove local source after testing
dotnet nuget remove source LocalPackages
```

### Local Package Source Management

**Add local source (persistent):**
```bash
# Add to global NuGet config (~/.nuget/NuGet/NuGet.Config)
dotnet nuget add source ~/Olbrasoft/Text/artifacts --name "TextLocal"
dotnet nuget add source ~/Olbrasoft/Data/artifacts --name "DataLocal"
```

**List all sources:**
```bash
dotnet nuget list source
# Shows: nuget.org, TextLocal, DataLocal, etc.
```

**Remove local source:**
```bash
dotnet nuget remove source TextLocal
```

**Clear all cached packages:**
```bash
# Clear all NuGet caches (http-cache, temp, global-packages)
dotnet nuget locals all --clear
```

### Best Practices

1. **Always test locally first** - Never publish untested packages
2. **Use exact versions** during local testing (e.g., `Version="1.0.5"`)
3. **Clear NuGet cache** before testing (`dotnet nuget locals all --clear`)
4. **Switch to floating versions** after NuGet.org publish (`Version="1.*"`)
5. **Remove local sources** after testing to avoid confusion
6. **Verify package source** using `dotnet list package` or restore logs

### Example: Complete Local Testing Workflow

```bash
# 1. Create new translation package
cd ~/Olbrasoft/Text
# ... write code ...
dotnet pack -c Release -o ./artifacts

# 2. Test in VirtualAssistant locally
cd ~/Olbrasoft/VirtualAssistant
dotnet nuget add source ~/Olbrasoft/Text/artifacts --name "TextLocal"

# Edit VirtualAssistant.csproj:
# <PackageReference Include="Olbrasoft.Text.Translation.Bing" Version="10.0.3" />

dotnet nuget locals all --clear
dotnet restore
dotnet build
dotnet test
./deploy/deploy.sh  # Test deployed app

# 3. Found bug? Fix it immediately
cd ~/Olbrasoft/Text
# ... fix bug ...
dotnet pack -c Release -o ./artifacts

cd ~/Olbrasoft/VirtualAssistant
dotnet nuget locals all --clear
dotnet restore  # Gets updated package
dotnet test     # Re-test

# 4. All tests pass? Publish to NuGet.org
cd ~/Olbrasoft/Text
git add .
git commit -m "feat: Add Bing translator (tested locally in VirtualAssistant)"
git push  # → GitHub Actions → NuGet.org

# 5. Switch VirtualAssistant to NuGet.org
cd ~/Olbrasoft/VirtualAssistant
# Edit VirtualAssistant.csproj:
# <PackageReference Include="Olbrasoft.Text.Translation.Bing" Version="10.*" />

dotnet nuget remove source TextLocal
dotnet nuget locals all --clear
dotnet restore  # Now uses NuGet.org
```

### Troubleshooting

| Problem | Solution |
|---------|----------|
| Old package version used | `dotnet nuget locals all --clear` |
| Can't find local package | Check source: `dotnet nuget list source` |
| Wrong version installed | Use exact version during testing: `Version="1.0.5"` |
| Mixed local/remote packages | Clear cache and verify sources |

## Multi-Package Repositories

⚠️ **CRITICAL: Use automatic project discovery to avoid missing new packages**

### ❌ WRONG: Hardcoded list of projects

**Problem:** When you add a new project, it won't be published until you manually update the workflow.

```yaml
# ❌ DO NOT DO THIS - requires manual updates for every new project
- name: Pack all packages
  run: |
    mkdir -p ./artifacts
    dotnet pack src/Project1/Project1.csproj -c Release --no-build -o ./artifacts
    dotnet pack src/Project2/Project2.csproj -c Release --no-build -o ./artifacts
    dotnet pack src/Project3/Project3.csproj -c Release --no-build -o ./artifacts
    # ❌ Forgot to add new Project4! It won't be published.
```

**Real-world mistake (Text repository, 2025-12-25):**
- Added `Olbrasoft.Text.Translation.Google` and `Olbrasoft.Text.Translation.Bing` projects
- Workflow had hardcoded list of 8 projects
- New projects were NOT published to NuGet.org
- Auto-version bump changed all versions, but only 8 old packages were published
- **Result:** Version mismatch, wasted CI time, broken deployment

### ✅ CORRECT: Automatic project discovery

**Use a loop to pack ALL projects in src/ directory:**

```yaml
- name: Pack all packages
  run: |
    mkdir -p ./artifacts
    # Automatically pack all projects in src/ directory
    for csproj in src/*/*.csproj; do
      if [ -f "$csproj" ]; then
        echo "Packing $csproj..."
        dotnet pack "$csproj" --configuration Release --no-build --output ./artifacts
      fi
    done

    # List generated packages for verification
    echo "Generated packages:"
    ls -lh ./artifacts/*.nupkg

- name: Publish to NuGet.org
  run: |
    dotnet nuget push ./artifacts/*.nupkg \
      --source https://api.nuget.org/v3/index.json \
      --api-key ${{ secrets.NUGET_API_KEY }} \
      --skip-duplicate
```

### How It Works

1. **Loop through all `.csproj` files** in `src/*/`
2. **Pack each project** automatically
3. **No manual updates needed** when adding new projects
4. **Verification step** lists all generated packages

### Exclude Projects from Publishing

**For test/demo projects:**
```xml
<PropertyGroup>
  <IsPackable>false</IsPackable>
</PropertyGroup>
```

**Example structure:**
```
src/
  ├─ YourLibrary.Core/          → ✅ Publishes (has NuGet metadata)
  ├─ YourLibrary.Providers/     → ✅ Publishes (has NuGet metadata)
  └─ YourLibrary.Tests/         → ❌ Excluded (IsPackable=false)
```

### Benefits

✅ **Scalable** - Add projects without touching workflow
✅ **No forgotten packages** - Everything in src/ is packed
✅ **Verification** - Logs show what was packaged
✅ **Maintainable** - One workflow rule for all projects

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

## Verifying Version After Publish

⚠️ **CRITICAL:** After pushing to GitHub, always verify the published version is correct.

### Post-Publish Verification Steps

1. **Check GitHub Actions:**
   - Go to repository → Actions tab
   - Find the latest "Publish NuGet" workflow run
   - Check the logs for "Publishing version: X.Y.Z"
   - Note the version number that was published

2. **Check NuGet.org:**
   - Go to https://www.nuget.org/packages/YourPackageName/
   - Look at "Latest version" shown on the page
   - **CRITICAL:** If the version on NuGet.org is HIGHER than what GitHub Actions just published, your versioning is BROKEN

3. **If NuGet version > Published version:**
   ```
   Example:
   - GitHub Actions published: 1.0.5
   - NuGet.org shows: 1.1.0 (HIGHER!)
   ❌ PROBLEM: Floating versions (1.*) will download 1.1.0, NOT your new 1.0.5
   ```

   **Fix:**
   - Update `VERSION_PREFIX` in `.github/workflows/publish-nuget.yml`
   - Set it HIGHER than the existing NuGet.org version
   - Example: If NuGet has 1.1.0, set `VERSION_PREFIX: "1.2"`
   - Push the change to trigger new publish
   - Next version will be 1.2.X (higher than 1.1.0) ✅

### Why This Matters

With floating versions (`Version="1.*"`), NuGet always downloads the **highest** version in the 1.x range:
- If NuGet has 1.1.0 and you publish 1.0.5, consumers get 1.1.0 (wrong!)
- If NuGet has 1.1.0 and you publish 1.2.6, consumers get 1.2.6 (correct!)

### Example Verification

```bash
# 1. Check published version in GitHub Actions logs
gh run view <run-id> --log | grep "Publishing version"
# Output: Publishing version: 1.2.6

# 2. Check NuGet.org (wait 5-10 minutes for indexing)
# Visit: https://www.nuget.org/packages/Olbrasoft.YourPackage/
# Latest version: 1.2.6 ✅ (matches or is new highest version)
```

## Adding New Projects to Solution

⚠️ **CRITICAL: Always add new projects to .sln file immediately after creation**

### Real-world mistake (Text repository, 2025-12-25)

**What happened:**
- Created `Olbrasoft.Text.Translation.Bing` project
- Created `Olbrasoft.Text.Translation.Bing.Tests` project
- **Forgot to add them to Olbrasoft.Text.sln**
- Workflow failed with `NETSDK1004: Assets file 'project.assets.json' not found`

**Why it failed:**
```yaml
# Workflow steps:
- dotnet restore          # ✅ Restores ONLY projects in .sln (Bing NOT included)
- dotnet build           # ✅ Builds ONLY projects in .sln
- dotnet pack src/*/*.csproj  # ❌ Tries to pack ALL .csproj (including Bing)
# Result: Bing has NO project.assets.json → ERROR
```

**Root cause:** Workflow's automatic project discovery (loop) packs ALL .csproj files, but `dotnet restore` only restores projects listed in .sln.

### ✅ CORRECT: Always add to solution immediately

**After creating ANY new project:**

```bash
# 1. Create project
dotnet new classlib -n Olbrasoft.YourProject -o src/Olbrasoft.YourProject

# 2. IMMEDIATELY add to solution
dotnet sln add src/Olbrasoft.YourProject/Olbrasoft.YourProject.csproj

# 3. Verify it's in solution
dotnet sln list | grep YourProject

# 4. Test locally
dotnet restore
dotnet build
dotnet test
```

### Checklist: Creating New Projects

- [ ] Create .csproj file (`dotnet new classlib` or manually)
- [ ] ⚠️ **IMMEDIATELY run:** `dotnet sln add <path-to-csproj>`
- [ ] Verify: `dotnet sln list` shows the new project
- [ ] Test locally: `dotnet build && dotnet test` (all pass)
- [ ] Commit solution file (.sln) along with new project
- [ ] Push and verify workflow succeeds

### Why This Matters

- `dotnet restore` only restores projects in .sln
- Workflow loops pack **all** .csproj files (not just .sln)
- Missing from .sln = no restore = no build artifacts = pack fails
- **Always add to .sln immediately** to avoid workflow failures

## Common Issues

| Problem | Cause | Fix |
|---------|-------|-----|
| 409 Conflict | Version exists | Increment `<Version>` |
| 401 Unauthorized | Invalid API key | Check `NUGET_API_KEY` secret |
| No .nupkg found | Missing metadata | Add `<PackageId>` to .csproj |
| Demo app published | Missing `<IsPackable>false</IsPackable>` | Add to demo .csproj |
| NETSDK1004 Assets file not found | Project not in .sln | `dotnet sln add <project.csproj>` |

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
