# CI/CD Pipeline Setup for NuGet Packages

## Overview

Automated CI/CD pipeline setup for building, testing, and publishing .NET NuGet packages using GitHub Actions.

---

## 🎯 When to Check CI/CD Setup

**CRITICAL - FOR EVERY PROJECT:**

When starting work on **any .NET project** that publishes NuGet packages, **ALWAYS verify** proper CI/CD configuration exists:

### Checklist:

- [ ] `.github/workflows/build.yml` exists
- [ ] `.github/workflows/publish-nuget.yml` exists
- [ ] GitHub Secret `NUGET_API_KEY` configured
- [ ] Workflows include all supported .NET versions
- [ ] README.md includes CI/CD status badges

**If ANYTHING is missing → implement according to this guide!**

---

## 📦 How Package Publishing Works

### Repository-Specific Configuration

**IMPORTANT:** CI/CD pipeline is **repository-specific**, NOT global.

For **each project** you must:
1. Create workflow files (`.github/workflows/*.yml`)
2. Set GitHub Secret with NuGet API key
3. Configure metadata in `.csproj` files

### Automatic Package Detection

Pipeline automatically finds **ALL** packages in solution using `dotnet pack`:

```bash
dotnet pack --configuration Release --no-build --output ./artifacts
```

Creates `.nupkg` files for:
- All projects with `<IsPackable>true</IsPackable>` (or not disabled)
- All projects with NuGet metadata (`<PackageId>`, `<Version>`, etc.)

**Example:** Mediation project publishes **2 packages simultaneously**:
- `Olbrasoft.Mediation.X.X.X.nupkg`
- `Olbrasoft.Mediation.Abstractions.X.X.X.nupkg`

### When Publishing Occurs

Publishes to NuGet.org **only when**:

1. ✅ All tests pass (`dotnet test` exit code 0)
2. ✅ **AND** push to `main` branch **OR** push tag `v*` (e.g., `v10.0.0`)

```yaml
if: success() && (github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/v'))
```

---

## 🔧 Implementation in New Project

### Step 1: NuGet API Key

**Key location:**
```
~/Dokumenty/Keys/nuget-key.txt
```

**Add to GitHub Secrets:**

1. Read key from file:
   ```bash
   cat ~/Dokumenty/Keys/nuget-key.txt
   ```

2. Add to GitHub repository:
   - Navigate: `Settings` → `Secrets and variables` → `Actions`
   - Click: `New repository secret`
   - Name: `NUGET_API_KEY`
   - Value: *[content of nuget-key.txt]*
   - Save

**⚠️ NOTE:** Same NuGet API key can be used for all Olbrasoft projects.

---

### Step 2: Build Workflow

Create `.github/workflows/build.yml`:

```yaml
name: Build

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: |
          6.0.x
          7.0.x
          8.0.x
          9.0.x
          10.0.x
    
    - name: Restore
      run: dotnet restore
    
    - name: Build
      run: dotnet build --configuration Release --no-restore
    
    - name: Test
      run: dotnet test --configuration Release --no-build --verbosity normal
```

**Function:**
- Triggers on push to `main`/`develop` or pull requests
- Installs all supported .NET SDK versions
- Restore → Build → Test
- **Does NOT publish** to NuGet

---

### Step 3: Publish Workflow

Create `.github/workflows/publish-nuget.yml`:

```yaml
name: Build, Test & Publish NuGet Package

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

permissions:
  contents: read
  checks: write
  pull-requests: write

env:
  DOTNET_SKIP_FIRST_TIME_EXPERIENCE: true
  DOTNET_CLI_TELEMETRY_OPTOUT: true

jobs:
  build-test-publish:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      with:
        fetch-depth: 0
    
    - name: Setup .NET SDK
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: |
          6.0.x
          7.0.x
          8.0.x
          9.0.x
          10.0.x

    - name: Display .NET info
      run: dotnet --info
    
    - name: Restore dependencies
      run: dotnet restore
    
    - name: Build solution
      run: dotnet build --configuration Release --no-restore
    
    - name: Run tests
      run: dotnet test --configuration Release --no-build --verbosity normal
    
    - name: Pack NuGet packages
      if: success()
      run: dotnet pack --configuration Release --no-build --output ./artifacts
    
    - name: List artifacts
      if: success()
      run: ls -lh ./artifacts/
    
    - name: Publish to NuGet.org
      if: success() && (github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/v'))
      run: |
        dotnet nuget push ./artifacts/*.nupkg \
          --source https://api.nuget.org/v3/index.json \
          --api-key ${{ secrets.NUGET_API_KEY }} \
          --skip-duplicate
    
    - name: Upload artifacts
      if: success()
      uses: actions/upload-artifact@v4
      with:
        name: nuget-packages
        path: ./artifacts/*.nupkg
        retention-days: 30
```

**Key parameters:**
- `permissions:` - GitHub Actions permissions
- `NUGET_API_KEY` - GitHub Secret with API key
- `--skip-duplicate` - Prevents error when version exists

---

### Step 4: NuGet Metadata in .csproj

Each project to publish requires metadata:

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFrameworks>netstandard2.1;net6.0;net7.0;net8.0;net9.0;net10.0</TargetFrameworks>
    
    <PackageId>Olbrasoft.YourProject</PackageId>
    <Version>1.0.0</Version>
    <Authors>Olbrasoft</Authors>
    <Company>Olbrasoft</Company>
    <Description>Your package description</Description>
    <Copyright>© Olbrasoft 2025</Copyright>
    
    <PackageLicenseExpression>MIT</PackageLicenseExpression>
    <PackageProjectUrl>https://github.com/Olbrasoft/YourProject</PackageProjectUrl>
    <PackageTags>Tag1;Tag2;NET10</PackageTags>
    <PackageReleaseNotes>Version 1.0.0: Initial release</PackageReleaseNotes>
  </PropertyGroup>

</Project>
```

**Important properties:**
- `<Version>` - Semantic versioning
- `<PackageId>` - Unique identifier on NuGet.org
- `<IsPackable>false</IsPackable>` - Disable publishing (for test projects)

---

### Step 5: README Badges

Add status badges to `README.md`:

```markdown
[![Build](https://github.com/Olbrasoft/YourProject/actions/workflows/build.yml/badge.svg)](https://github.com/Olbrasoft/YourProject/actions/workflows/build.yml)
[![Publish NuGet](https://github.com/Olbrasoft/YourProject/actions/workflows/publish-nuget.yml/badge.svg)](https://github.com/Olbrasoft/YourProject/actions/workflows/publish-nuget.yml)
[![NuGet](https://img.shields.io/nuget/v/Olbrasoft.YourProject.svg)](https://www.nuget.org/packages/Olbrasoft.YourProject/)
```

---

## 🔄 Development Workflow

### Regular Development (feature branch)

```bash
git checkout -b feature/new-feature
# develop + tests
git add .
git commit -m "feat: Add new feature"
git push origin feature/new-feature
```

**Result:** Only **Build workflow** runs (no publishing).

### Release (merge to main)

```bash
git checkout main
git merge feature/new-feature
git push origin main
```

**Result:**
1. **Build workflow** runs
2. **Publish workflow** runs
3. If tests pass → **Published to NuGet.org**

### Tagged Release

```bash
git tag v1.0.0
git push origin v1.0.0
```

**Result:** Same as merge to main + Git tag in history.

---

## 🚨 Common Issues

### 1. Workflow Permission Denied

**Error:** `Resource not accessible by integration: 403`

**Solution:** Add `permissions:` block to workflow.

### 2. Package Already Exists

**Error:** `409 Conflict - Package version 'X.X.X' already exists`

**Solution:** Increase version in `.csproj` or use `--skip-duplicate` (already in workflow).

### 3. NuGet API Key Not Set

**Error:** `Unable to load service index for https://api.nuget.org/v3/index.json`

**Solution:** Verify GitHub Secret `NUGET_API_KEY` exists.

### 4. Tests Fail in CI, Pass Locally

**Causes:** Different .NET versions, missing dependencies, timing-dependent tests

**Solution:** Run tests locally with all .NET versions:
```bash
dotnet test --framework net6.0
dotnet test --framework net8.0
dotnet test --framework net10.0
```

---

## 📚 References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [NuGet CLI Reference](https://docs.microsoft.com/en-us/nuget/reference/cli-reference/cli-ref-push)
- [Mediation CI/CD Example](https://github.com/Olbrasoft/Mediation/tree/main/.github/workflows)

---

## ✅ New Project Checklist

Before development:

- [ ] `.github/workflows/build.yml` exists
- [ ] `.github/workflows/publish-nuget.yml` exists
- [ ] GitHub Secret `NUGET_API_KEY` set
- [ ] `.csproj` contains NuGet metadata
- [ ] `README.md` includes CI/CD badges
- [ ] Workflows include all supported .NET versions
- [ ] `permissions:` block in publish workflow
- [ ] Local tests pass: `dotnet test`

**If anything missing → implement per this guide!**
