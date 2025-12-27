# Testing

How to test .NET applications with unit tests and integration tests.

## What is Testing?

**Testing** = Automated verification that code works as expected.

**Why test?**
- ✅ Catch bugs early (before production)
- ✅ Prevent regressions (old bugs coming back)
- ✅ Document behavior (tests show how code should work)
- ✅ Enable refactoring (tests protect against breaking changes)
- ✅ Faster development (less manual testing)

## Types of Tests

We use two types of tests in .NET projects:

| Type | What It Tests | Dependencies | Speed | Runs on CI? |
|------|--------------|--------------|-------|-------------|
| **Unit Tests** | Single class/method in isolation | Mocked (Moq) + in-memory DB | Fast (<100ms) | ✅ Always |
| **Integration Tests** | Real service integration | Real APIs, real databases | Slow (seconds) | ❌ Skipped ([SkipOnCIFact]) |

## Decision Tree: Which Test Type?

```
Are you testing business logic or data access?
│
├─ YES → Unit Test
│   ├─ Mock external dependencies with Moq
│   ├─ Use in-memory database for data access
│   └─ See: unit-tests-testing.md
│
└─ NO → Are you testing real API/service integration?
    │
    ├─ YES → Integration Test
    │   ├─ Call real external services
    │   ├─ Use [SkipOnCIFact] attribute
    │   └─ See: integration-tests-testing.md
    │
    └─ NO → You probably don't need a test
        (e.g., simple DTOs, configuration)
```

## Quick Start Guide

### 1. Unit Tests (Most Common)

**When:** Testing business logic, data access, CQRS handlers, services

**Example:**
```csharp
using Moq;
using Microsoft.EntityFrameworkCore;

public class MyServiceTests
{
    private readonly Mock<ILogger<MyService>> _mockLogger;
    private readonly DbContext _dbContext;
    private readonly MyService _service;

    public MyServiceTests()
    {
        _mockLogger = new Mock<ILogger<MyService>>();

        // In-memory database - unique per test class
        var options = new DbContextOptionsBuilder<MyDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        _dbContext = new MyDbContext(options);

        _service = new MyService(_mockLogger.Object, _dbContext);
    }

    [Fact]
    public async Task GetAsync_WithExistingId_ReturnsEntity()
    {
        // Arrange - Add test data
        var entity = new MyEntity { Id = 1, Name = "Test" };
        _dbContext.MyEntities.Add(entity);
        await _dbContext.SaveChangesAsync();

        // Act
        var result = await _service.GetAsync(1);

        // Assert
        Assert.NotNull(result);
        Assert.Equal("Test", result.Name);
    }
}
```

**See:** [Unit Tests Guide](unit-tests-testing.md) for complete documentation.

### 2. Integration Tests (Run Manually)

**When:** Testing real LLM APIs, external payment APIs, email services

**Example:**
```csharp
using Olbrasoft.Testing.Xunit.Attributes;

public class LlmChainIntegrationTests
{
    [SkipOnCIFact] // ← CRITICAL: Skips on CI to save API costs
    public async Task CompleteAsync_WithRealAPI_ReturnsResponse()
    {
        // Arrange
        var request = new LlmChainRequest
        {
            SystemPrompt = "You are a helpful assistant.",
            UserMessage = "Say hello",
            Temperature = 0.3f
        };

        // Act - CALLS REAL API!
        var result = await _client.CompleteAsync(request);

        // Assert
        Assert.True(result.Success);
        Assert.NotEmpty(result.Content);
    }
}
```

**See:** [Integration Tests Guide](integration-tests-testing.md) for complete documentation.

## Testing in CI/CD Pipeline

Tests run automatically in GitHub Actions:

- **Unit tests** → Run on every push (fast, no costs)
- **Integration tests** → Skipped on CI (slow, costs money)

**See:** [Test Continuous Integration](../continuous-integration/test-continuous-integration.md) for CI configuration.

## Common Scenarios

### Scenario 1: Testing Service with Database

→ **Use Unit Tests**
- Use in-memory database (`Microsoft.EntityFrameworkCore.InMemory`)
- Mock other dependencies (ILogger, IHttpClientFactory)
- See: [Unit Tests - Database Testing](unit-tests-testing.md#database-testing-with-in-memory)

### Scenario 2: Testing LLM API Call

→ **Use Integration Tests**
- Call real LLM API (OpenAI, Mistral, etc.)
- Use `[SkipOnCIFact]` to skip on CI
- Run manually before committing
- See: [Integration Tests - LLM Example](integration-tests-testing.md#example-llm-api-integration-test)

### Scenario 3: Testing Business Logic

→ **Use Unit Tests**
- Mock all dependencies
- Test public methods only
- Fast, isolated tests
- See: [Unit Tests - Mocking](unit-tests-testing.md#mocking-with-moq)

### Scenario 4: Testing CQRS Handler

→ **Use Unit Tests**
- Use in-memory database for DbContext
- Mock ILogger
- Test handler behavior
- See: [Unit Tests - Database Testing](unit-tests-testing.md#database-testing-with-in-memory)

## Required Packages

### Unit Tests
```xml
<ItemGroup>
  <PackageReference Include="xunit" Version="2.9.3" />
  <PackageReference Include="xunit.runner.visualstudio" Version="3.1.4" />
  <PackageReference Include="Moq" Version="4.20.72" />
  <PackageReference Include="Microsoft.EntityFrameworkCore.InMemory" Version="10.0.1" />
  <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.14.1" />
</ItemGroup>
```

### Integration Tests
```xml
<ItemGroup>
  <!-- All unit test packages PLUS: -->
  <PackageReference Include="Olbrasoft.Testing.Xunit.Attributes" Version="1.*" />
</ItemGroup>
```

## Project Structure

**Pattern:** Each source project MUST have its own test project.

### When Project Has ONLY Unit Tests

```
src/
  MyProject.Core/
    Services/
      MyService.cs

tests/
  MyProject.Core.Tests/
    Services/
      MyServiceTests.cs
```

### When Project Has BOTH Unit Tests AND Integration Tests

```
src/
  MyProject.Core/
    Services/
      MyService.cs
  MyProject.Data/
    Repositories/
      MyRepository.cs

tests/
  UnitTests/
    MyProject.Core.Tests/
      Services/
        MyServiceTests.cs
    MyProject.Data.Tests/
      Repositories/
        MyRepositoryTests.cs
  IntegrationTests/
    MyProject.Core.IntegrationTests/
      Services/
        MyServiceIntegrationTests.cs
```

**CRITICAL:** When application has BOTH types of tests, use `UnitTests/` and `IntegrationTests/` directories to separate them!

**Naming:**
- Test project: `{SourceProject}.Tests` or `{SourceProject}.IntegrationTests`
- Test class: `{SourceClass}Tests`
- Test method: `MethodName_Scenario_ExpectedBehavior`

## Running Tests

```bash
# Run ALL tests (unit + integration)
dotnet test

# Run ONLY unit tests (exclude integration tests)
dotnet test --filter "FullyQualifiedName!~IntegrationTests"

# Run specific test
dotnet test --filter "FullyQualifiedName~GetAsync_WithExistingId"

# Run tests with verbosity
dotnet test --verbosity normal
```

## Best Practices

### ✅ DO

- ✅ Write unit tests for ALL business logic
- ✅ Use in-memory database for data access tests
- ✅ Mock external dependencies (APIs, file system)
- ✅ Keep tests isolated (no shared state)
- ✅ Use descriptive test names
- ✅ Run tests before committing
- ✅ Use `[SkipOnCIFact]` for integration tests

### ❌ DON'T

- ❌ Test private methods (test public API only)
- ❌ Share database instances between tests
- ❌ Call real APIs in unit tests
- ❌ Run integration tests on CI (costs money)
- ❌ Mock classes under test
- ❌ Write tests for simple DTOs

## Troubleshooting

### Tests Fail Locally

**Check:**
1. Database state - use unique `Guid.NewGuid().ToString()` for in-memory DB
2. Mock setup - verify `.Setup()` and `.Returns()` are correct
3. Test isolation - ensure no shared state between tests
4. Resources - dispose DbContext in `Dispose()` method

### Integration Tests Run on CI (Should Be Skipped)

**Fix:**
1. Missing `[SkipOnCIFact]` attribute
2. Package `Olbrasoft.Testing.Xunit.Attributes` not installed
3. Wrong test filter in GitHub Actions workflow

## Next Steps

Choose your test type:

- **[Unit Tests →](unit-tests-testing.md)** - Testing with mocks and in-memory database
- **[Integration Tests →](integration-tests-testing.md)** - Testing with real services
- **[CI Testing →](../continuous-integration/test-continuous-integration.md)** - Running tests in GitHub Actions

## See Also

- [Build Continuous Integration](../continuous-integration/build-continuous-integration.md) - Building projects
- [Test Continuous Integration](../continuous-integration/test-continuous-integration.md) - Running tests in CI
- [Unit Tests](unit-tests-testing.md) - Detailed unit testing guide
- [Integration Tests](integration-tests-testing.md) - Detailed integration testing guide
