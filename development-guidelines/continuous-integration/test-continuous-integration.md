# Test - .NET Projects

How to run automated tests in CI/CD pipelines using xUnit.

## What Tests Run in CI?

**CI runs ONLY unit tests** - integration tests are skipped.

```bash
# Run unit tests (exclude integration tests)
dotnet test -c Release --no-build --filter "FullyQualifiedName!~IntegrationTests"
```

**Why filter?**
- Integration tests call real APIs (costs money)
- Integration tests are slow (seconds vs milliseconds)
- Integration tests use `[SkipOnCIFact]` attribute to auto-skip on CI

**See:** [Testing Guide](../testing/index-testing.md) for unit vs integration tests.

## GitHub Actions Workflow

**File:** `.github/workflows/build.yml`

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

    # Run ONLY unit tests (exclude integration tests)
    - run: dotnet test -c Release --no-build --verbosity normal --filter "FullyQualifiedName!~IntegrationTests"
```

**CRITICAL:** Always use `--filter "FullyQualifiedName!~IntegrationTests"` to skip integration tests in CI!

## Test Output

```
Starting test execution, please wait...
A total of 1 test files matched the specified pattern.

Passed!  - Failed:     0, Passed:    42, Skipped:     0, Total:    42
```

**CI fails if ANY test fails.**

## Test Project Structure

```
tests/
  └─ YourProject.Tests/
      ├─ YourProject.Tests.csproj
      └─ SomeClassTests.cs
```

**Each source project MUST have its own test project:**
- `YourProject.Core` → `YourProject.Core.Tests`
- `YourProject.Providers` → `YourProject.Providers.Tests`

See: [Testing Guide](../testing/index-testing.md) for project structure details.

## Test Naming Convention

```csharp
// Test class: {SourceClass}Tests
public class TtsResultTests
{
    // Test method: {Method}_{Scenario}_{ExpectedResult}
    [Fact]
    public void Ok_WithAudioData_ReturnsSuccessResult()
    {
        // Arrange
        var audioData = new byte[] { 1, 2, 3 };

        // Act
        var result = TtsResult.Ok(audioData);

        // Assert
        Assert.True(result.IsSuccess);
        Assert.Equal(audioData, result.Data);
    }
}
```

## Test Coverage

**We use:** xUnit + Moq

```csharp
// xUnit - test framework
[Fact]
public void MyTest() { }

// Moq - mocking dependencies
var mockService = new Mock<IMyService>();
mockService.Setup(x => x.GetData()).Returns("test");
```

## Common Test Errors

| Error | Fix |
|-------|-----|
| `No tests found` | Check test project `<IsPackable>false</IsPackable>` |
| `Test failed: Assert.Equal` | Fix implementation or test expectation |
| `Cannot find test adapter` | Add `<PackageReference Include="xunit.runner.visualstudio" />` |

## Continuous Integration Rule

**Tests MUST pass before:**
- Merging pull request
- Deploying to production
- Publishing NuGet package

**Never skip tests in CI/CD!**

## Next Steps

After tests pass:
- Merge PR
- Deploy: See [../continuous-deployment/](../continuous-deployment/)

## See Also

- [Build](build-continuous-integration.md) - Build before testing
- [Testing Guide](../testing/index-testing.md) - Full testing documentation
- [Unit Tests](../testing/unit-tests-testing.md) - Isolated tests with mocking
- [Integration Tests](../testing/integration-tests-testing.md) - Tests with real services
- [Workflow](../workflow.md) - Git workflow with tests
