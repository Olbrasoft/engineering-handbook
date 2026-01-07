# Build - .NET Projects

How to build .NET projects using `dotnet build` in CI/CD pipelines.

## Basic Build

```bash
dotnet restore
dotnet build -c Release --no-restore
```

**Why `--no-restore`?** Already done in previous step, saves time.

## GitHub Actions Workflow

**File:** `.github/workflows/build.yml`

```yaml
name: Build
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - uses: actions/setup-dotnet@v4
      with:
        dotnet-version: |
          8.0.x
          10.0.x

    - name: Restore dependencies
      run: dotnet restore

    - name: Build
      run: dotnet build -c Release --no-restore
```

## Multi-Target Frameworks

For libraries targeting multiple frameworks:

```xml
<!-- .csproj -->
<TargetFrameworks>netstandard2.1;net8.0;net10.0</TargetFrameworks>
```

Build command stays the same - builds all targets:
```bash
dotnet build -c Release
```

## Build Configurations

| Config | When | Output |
|--------|------|--------|
| `Debug` | Development | Includes symbols, no optimization |
| `Release` | CI/CD, Production | Optimized, trimmed |

**CI/CD always uses Release:**
```bash
dotnet build -c Release
```

## Common Build Errors

| Error | Fix |
|-------|-----|
| `NU1*** Package not found` | Run `dotnet restore` first |
| `CS**** Syntax error` | Fix code, commit |
| `Target framework not found` | Install SDK: `dotnet-version: 10.0.x` |

## Build Output

```
/bin/Release/net10.0/
  ├── YourApp.dll
  ├── YourApp.pdb
  └── YourApp.deps.json
```

## Next Steps

After build succeeds:
- Run tests: [test-continuous-integration.md](test-continuous-integration.md)
- Package for deployment: See [../continuous-deployment/](../continuous-deployment/index-continuous-deployment.md)

## See Also

- [Testing](test-continuous-integration.md) - Run tests after build
- [NuGet Publishing](../continuous-deployment/nuget-publish-continuous-deployment.md) - Package and publish
