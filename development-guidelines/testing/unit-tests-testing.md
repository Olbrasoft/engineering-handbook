# Unit Tests

How to write isolated unit tests for .NET projects using xUnit and Moq.

## What are Unit Tests?

**Unit test** = Test of a single unit (class/method) in **complete isolation** from external dependencies.

**Key principles:**
- ✅ **ALWAYS** use mocked dependencies (Moq)
- ✅ **ALWAYS** use in-memory database (NOT real database)
- ✅ Tests must run **fast** (< 100ms per test)
- ✅ Tests must be **isolated** (no shared state)
- ✅ Tests must be **deterministic** (same input = same output)

## When to Write Unit Tests

| Scenario | Unit Tests Required? |
|----------|---------------------|
| **Application uses database** | ✅ **YES - MANDATORY** |
| Service with business logic | ✅ YES |
| Data access layer (repositories) | ✅ YES |
| CQRS handlers | ✅ YES |
| Extension methods | ✅ YES |
| Simple DTOs/models | ⚠️ Optional |

## Testing Stack

**Framework:** xUnit 2.9+
**Mocking:** Moq 4.20+
**Database:** Microsoft.EntityFrameworkCore.InMemory 10.0+

**DO NOT use:**
- ❌ NUnit (use xUnit)
- ❌ NSubstitute (use Moq)
- ❌ Real database (use in-memory)

### Package References

```xml
<ItemGroup>
  <PackageReference Include="xunit" Version="2.9.3" />
  <PackageReference Include="xunit.runner.visualstudio" Version="3.1.4" />
  <PackageReference Include="Moq" Version="4.20.72" />
  <PackageReference Include="Microsoft.EntityFrameworkCore.InMemory" Version="10.0.1" />
  <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.14.1" />
</ItemGroup>

<ItemGroup>
  <Using Include="Xunit" />
</ItemGroup>
```

## Test Project Structure

### Naming Conventions

**Rule:** Each source project MUST have its own separate test project.

| Source Project | Test Project |
|----------------|--------------|
| `ProjectName.Core` | `ProjectName.Core.Tests` |
| `ProjectName.Service` | `ProjectName.Service.Tests` |
| `ProjectName.Data` | `ProjectName.Data.Tests` |

**Test class naming:** `{SourceClass}Tests`

### Directory Structure

```
src/
  PushToTalk.Core/
    Models/
      ButtonMonitor.cs
    Services/
      LlmCorrectionService.cs

tests/
  PushToTalk.Core.Tests/
    Models/
      ButtonMonitorTests.cs
    Services/
      LlmCorrectionServiceTests.cs
```

### Test Method Naming

**Pattern:** `MethodName_Scenario_ExpectedBehavior`

**Examples:**
```csharp
[Fact]
public void Constructor_WithValidDependencies_Initializes()

[Fact]
public async Task GetAsync_WithExistingId_ReturnsEntity()

[Fact]
public async Task GetAsync_WithNonExistentId_ReturnsNull()

[Theory]
[InlineData("valid@email.com")]
[InlineData("another@domain.org")]
public void IsValid_WithValidEmail_ReturnsTrue(string email)
```

## Database Testing with In-Memory

### When to Use In-Memory Database

**Rule:** ANY application that uses Entity Framework Core MUST test with in-memory database.

**Why?**
- ✅ Tests run fast (no I/O)
- ✅ No database setup required
- ✅ Tests are isolated
- ✅ Tests are deterministic
- ✅ Can run in CI/CD without database

### Setup Pattern

Each test class gets its own isolated database:

```csharp
using Microsoft.EntityFrameworkCore;
using PushToTalk.Data.EntityFrameworkCore;

public class LlmCorrectionServiceTests : IDisposable
{
    private readonly PushToTalkDbContext _dbContext;
    private readonly LlmCorrectionService _service;

    public LlmCorrectionServiceTests()
    {
        // Unique database per test class instance
        var options = new DbContextOptionsBuilder<PushToTalkDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        _dbContext = new PushToTalkDbContext(options);
        _service = new LlmCorrectionService(_dbContext);
    }

    [Fact]
    public async Task GetCorrectionAsync_WithExistingId_ReturnsCorrection()
    {
        // Arrange - Add test data
        var correction = new LlmCorrection
        {
            Id = 1,
            OriginalText = "Test",
            CorrectedText = "Corrected"
        };
        _dbContext.LlmCorrections.Add(correction);
        await _dbContext.SaveChangesAsync();

        // Act
        var result = await _service.GetCorrectionAsync(1);

        // Assert
        Assert.NotNull(result);
        Assert.Equal("Corrected", result.CorrectedText);
    }

    public void Dispose()
    {
        _dbContext?.Dispose();
    }
}
```

**CRITICAL:** Use `Guid.NewGuid().ToString()` for database name to ensure isolation!

## Mocking with Moq

### What to Mock

✅ **ALWAYS mock:**
- External services (HTTP clients, APIs)
- File system operations
- Database repositories
- Logging (ILogger)
- Time providers (ISystemClock)

❌ **NEVER mock:**
- Classes under test
- Simple DTOs/models
- Value objects

### Basic Mocking Pattern

```csharp
using Moq;

public class EmailNotificationServiceTests
{
    private readonly Mock<IEmailSender> _mockEmailSender;
    private readonly EmailNotificationService _service;

    public EmailNotificationServiceTests()
    {
        _mockEmailSender = new Mock<IEmailSender>();
        _service = new EmailNotificationService(_mockEmailSender.Object);
    }

    [Fact]
    public async Task SendNotification_WithValidEmail_CallsEmailSender()
    {
        // Arrange
        var notification = new Notification { Email = "test@example.com" };

        _mockEmailSender
            .Setup(s => s.SendAsync(It.IsAny<string>(), It.IsAny<string>()))
            .ReturnsAsync(true);

        // Act
        await _service.SendNotificationAsync(notification);

        // Assert
        _mockEmailSender.Verify(
            s => s.SendAsync("test@example.com", It.IsAny<string>()),
            Times.Once
        );
    }
}
```

### Mocking ILogger

```csharp
using Microsoft.Extensions.Logging;
using Moq;

public class MyServiceTests
{
    private readonly Mock<ILogger<MyService>> _mockLogger;
    private readonly MyService _service;

    public MyServiceTests()
    {
        _mockLogger = new Mock<ILogger<MyService>>();
        _service = new MyService(_mockLogger.Object);
    }

    [Fact]
    public void ProcessData_WithError_LogsError()
    {
        // Act
        _service.ProcessData(null);

        // Assert
        _mockLogger.Verify(
            x => x.Log(
                LogLevel.Error,
                It.IsAny<EventId>(),
                It.Is<It.IsAnyType>((v, t) => v.ToString().Contains("error")),
                It.IsAny<Exception>(),
                It.IsAny<Func<It.IsAnyType, Exception?, string>>()),
            Times.Once
        );
    }
}
```

## Running Unit Tests

### Command Line

```bash
# Run all tests
dotnet test

# Run tests in specific project
dotnet test tests/MyProject.Tests

# Run with verbosity
dotnet test --verbosity normal

# Run specific test
dotnet test --filter "FullyQualifiedName~GetAsync_WithExistingId"
```

### CI Integration

See [Test CI](../continuous-integration/test-continuous-integration.md) for running tests in GitHub Actions.

**Unit tests run on every push** - they're fast and isolated!

## Common Pitfalls

### ❌ Pitfall 1: Shared Database State

**WRONG:**
```csharp
// Static database - SHARED across all tests!
private static DbContext _dbContext;
```

**CORRECT:**
```csharp
// Instance database - ISOLATED per test class
private readonly DbContext _dbContext;

public MyTests()
{
    _dbContext = new DbContext(
        new DbContextOptionsBuilder()
            .UseInMemoryDatabase(Guid.NewGuid().ToString()) // ← Unique!
            .Options
    );
}
```

### ❌ Pitfall 2: Testing Implementation Details

**WRONG:**
```csharp
// Testing private method behavior
[Fact]
public void PrivateMethod_CallsHelper()
{
    // Don't test private methods!
}
```

**CORRECT:**
```csharp
// Test public API behavior
[Fact]
public void PublicMethod_WithInput_ReturnsExpectedOutput()
{
    // Test what the class DOES, not HOW it does it
}
```

### ❌ Pitfall 3: Not Cleaning Up Resources

**WRONG:**
```csharp
public class MyTests
{
    private DbContext _dbContext;
    // No Dispose! Memory leak!
}
```

**CORRECT:**
```csharp
public class MyTests : IDisposable
{
    private readonly DbContext _dbContext;

    public void Dispose()
    {
        _dbContext?.Dispose();
    }
}
```

## Checklist Before Committing

- [ ] All unit tests pass locally
- [ ] Each test class has unique in-memory database
- [ ] All external dependencies are mocked
- [ ] Tests are isolated (no shared state)
- [ ] Tests run fast (< 100ms each)
- [ ] Test names are descriptive
- [ ] Resources are disposed properly

## See Also

- [Integration Tests](integration-tests-testing.md) - Testing with real services
- [Testing Index](index-testing.md) - Overview of all testing guides
- [CI Testing](../continuous-integration/test-continuous-integration.md) - Running tests in GitHub Actions
