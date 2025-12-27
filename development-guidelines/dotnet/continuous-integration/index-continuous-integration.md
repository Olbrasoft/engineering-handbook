# Continuous Integration

Automated build and testing for .NET projects.

## What is Continuous Integration?

**Continuous Integration (CI)** = Automatically **build** and **test** code every time you push to GitHub.

**Goal:** Verify code **works** and is **quality**.

**NOT for deployment** - see [../continuous-deployment/](../continuous-deployment/) for that.

## Quick Navigation

| Task | File |
|------|------|
| Build .NET project | [build-continuous-integration.md](build-continuous-integration.md) |
| Run automated tests | [test-continuous-integration.md](test-continuous-integration.md) |

## Basic CI Workflow

```yaml
# .github/workflows/build.yml
name: Build
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-dotnet@v4

      - run: dotnet restore
      - run: dotnet build -c Release --no-restore
      - run: dotnet test -c Release --no-build
```

**What happens:**
1. Code pushed to GitHub
2. GitHub Actions automatically:
   - Restores dependencies
   - Builds project (compiles code)
   - Runs tests
3. If ANY step fails → workflow fails → you get notification

## CI Pipeline Steps

```
Push to GitHub
    ↓
Restore (dotnet restore)
    ↓
Build (dotnet build)
    ↓
Test (dotnet test)
    ↓
✅ Success → Ready for deployment
❌ Failure → Fix code and push again
```

## When to Use CI

- ✅ Every project (NuGet, web, desktop, local apps)
- ✅ Run on every push and pull request
- ✅ Catch bugs early before deployment

## Next Steps

**After CI succeeds:**
- Merge pull request
- Deploy to production - see [../continuous-deployment/](../continuous-deployment/)

## Files in This Directory

- **[build-continuous-integration.md](build-continuous-integration.md)** - How to build .NET projects in CI
- **[test-continuous-integration.md](test-continuous-integration.md)** - How to run tests in CI

## See Also

- [Testing Guide](../testing/index-testing.md) - Full testing documentation
- [Unit Tests](../testing/unit-tests-testing.md) - Isolated tests with mocking
- [Integration Tests](../testing/integration-tests-testing.md) - Tests with real services
- [Continuous Deployment](../continuous-deployment/) - Deploy after CI succeeds
- [Workflow Guide](../../workflow/index-workflow.md) - Git workflow with CI
