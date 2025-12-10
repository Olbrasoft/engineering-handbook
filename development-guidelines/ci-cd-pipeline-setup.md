# CI/CD Pipeline Setup for NuGet Packages

## When to Check

For **every .NET project** publishing NuGet packages, verify:
- [ ] `.github/workflows/build.yml` exists
- [ ] `.github/workflows/publish-nuget.yml` exists
- [ ] GitHub Secret `NUGET_API_KEY` configured

---

## How It Works

- `dotnet pack` finds ALL packable projects automatically
- Publishes to NuGet.org **only when**: tests pass AND (push to `main` OR tag `v*`)

---

## Setup

### 1. NuGet API Key
```bash
cat ~/Dokumenty/Keys/nuget-key.txt
```
Add to: `Settings` → `Secrets` → `Actions` → `NUGET_API_KEY`

### 2. Build Workflow (`.github/workflows/build.yml`)
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
    - uses: actions/setup-dotnet@v4
      with:
        dotnet-version: |
          6.0.x
          8.0.x
          9.0.x
    - run: dotnet restore
    - run: dotnet build -c Release --no-restore
    - run: dotnet test -c Release --no-build
```

### 3. Publish Workflow (`.github/workflows/publish-nuget.yml`)
```yaml
name: Publish NuGet
on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-dotnet@v4
      with:
        dotnet-version: |
          6.0.x
          8.0.x
          9.0.x
    - run: dotnet restore
    - run: dotnet build -c Release --no-restore
    - run: dotnet test -c Release --no-build
    - run: dotnet pack -c Release --no-build -o ./artifacts
    - name: Publish
      if: success() && (github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/v'))
      run: dotnet nuget push ./artifacts/*.nupkg --source https://api.nuget.org/v3/index.json --api-key ${{ secrets.NUGET_API_KEY }} --skip-duplicate
```

### 4. .csproj Metadata
```xml
<PropertyGroup>
  <PackageId>Olbrasoft.YourProject</PackageId>
  <Version>1.0.0</Version>
  <Authors>Olbrasoft</Authors>
  <PackageLicenseExpression>MIT</PackageLicenseExpression>
</PropertyGroup>
```

---

## Common Issues

| Error | Solution |
|-------|----------|
| 403 Permission | Add `permissions:` block |
| 409 Version exists | Increase version or use `--skip-duplicate` |
| API key error | Check `NUGET_API_KEY` secret |
