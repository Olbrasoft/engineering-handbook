# Unit Testing Guide

Comprehensive guide for testing .NET applications in Olbrasoft projects.

---

## Table of Contents

- [Core Principles](#core-principles)
- [Testing Framework](#testing-framework)
- [Test Project Structure](#test-project-structure)
- [Database Testing](#database-testing)
- [Mocking Strategies](#mocking-strategies)
- [Design Patterns in Tests](#design-patterns-in-tests)
- [Examples](#examples)
- [Common Pitfalls](#common-pitfalls)

---

## Core Principles

### 🚨 CRITICAL RULE

**NEVER claim work is "completed" or "done" without passing tests.**

If functionality doesn't work, integration is missing, or tests fail - the work is NOT done. Period.

### When Tests Are Required

| Scenario | Tests Required? |
|----------|----------------|
| **Application uses database** | ✅ **YES - MANDATORY** |
| Service with business logic | ✅ YES |
| Data access layer (repositories) | ✅ YES |
| CQRS handlers | ✅ YES |
| Configuration loading from DB | ✅ YES |
| Simple DTOs/models | ⚠️ Optional |
| Extension methods | ✅ YES |

### Quality Standards

- **All tests must pass** before deployment
- **100% of critical paths** must be tested
- Tests must be **fast** (< 100ms per test)
- Tests must be **isolated** (no shared state)
- Tests must be **deterministic** (same input = same output)

---

## Testing Framework

### Stack

**Framework:** xUnit 2.9+
**Mocking:** Moq 4.20+
**Database:** Microsoft.EntityFrameworkCore.InMemory 10.0+

**DO NOT use:**
- ❌ NUnit (use xUnit)
- ❌ NSubstitute (use Moq)
- ❌ MSTest (use xUnit)

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

---

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
      TtsResult.cs
    Services/
      MistralProvider.cs
  PushToTalk.Service/
    Services/
      LlmCorrectionService.cs
      EmailNotificationService.cs
    Configuration/
      DatabaseMistralOptionsSetup.cs

tests/
  PushToTalk.Core.Tests/
    Models/
      TtsResultTests.cs
    Services/
      MistralProviderTests.cs
  PushToTalk.Service.Tests/
    Services/
      LlmCorrectionServiceTests.cs
      EmailNotificationServiceTests.cs
    Configuration/
      DatabaseMistralOptionsSetupTests.cs
```

**❌ NEVER create a single shared test project** like `ProjectName.Tests` for all source projects.

### Test Method Naming

**Pattern:** `[Method]_[Scenario]_[Expected]`

```csharp
public class LlmCorrectionServiceTests
{
    [Fact]
    public async Task CorrectTranscriptionAsync_WhenSuccessful_SavesToLlmCorrections()
    {
        // Arrange
        // Act
        // Assert
    }

    [Fact]
    public async Task CorrectTranscriptionAsync_WhenFails_SavesToLlmErrors()
    {
        // Arrange
        // Act
        // Assert
    }
}
```

---

## Database Testing

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
        _service = new LlmCorrectionService(_dbContext, /* other deps */);
    }

    [Fact]
    public async Task SomeTest_DoesWork()
    {
        // Arrange - Add test data
        var entity = new LlmCorrection { /* ... */ };
        _dbContext.LlmCorrections.Add(entity);
        await _dbContext.SaveChangesAsync();

        // Act
        var result = await _service.SomeMethod();

        // Assert
        var saved = await _dbContext.LlmCorrections.FirstOrDefaultAsync();
        Assert.NotNull(saved);
    }

    public void Dispose()
    {
        _dbContext?.Dispose();
    }
}
```

### Shared Database with Separate Instances

For tests that need shared database (e.g., testing IOptions configuration):

```csharp
public class DatabaseMistralOptionsSetupTests : IDisposable
{
    private readonly ServiceProvider _serviceProvider;
    private readonly string _databaseName;

    public DatabaseMistralOptionsSetupTests()
    {
        // Shared database name for all operations in this test class
        _databaseName = Guid.NewGuid().ToString();

        var services = new ServiceCollection();
        services.AddDbContext<PushToTalkDbContext>(options =>
            options.UseInMemoryDatabase(_databaseName));
        services.ConfigureOptions<DatabaseMistralOptionsSetup>();

        _serviceProvider = services.BuildServiceProvider();
    }

    private PushToTalkDbContext CreateDbContext()
    {
        // Create new DbContext instance using same database name
        var options = new DbContextOptionsBuilder<PushToTalkDbContext>()
            .UseInMemoryDatabase(_databaseName)
            .Options;
        return new PushToTalkDbContext(options);
    }

    [Fact]
    public void Configure_WithActiveConfig_LoadsOptionsFromDatabase()
    {
        // Arrange - Use separate DbContext instance for setup
        using (var dbContext = CreateDbContext())
        {
            var config = new MistralConfig
            {
                ApiKey = "test-api-key",
                IsActive = true
            };
            dbContext.MistralConfigs.Add(config);
            dbContext.SaveChanges();
        }

        // Act - Service uses its own DbContext instance
        var options = _serviceProvider.GetRequiredService<IOptions<MistralOptions>>().Value;

        // Assert
        Assert.Equal("test-api-key", options.ApiKey);
    }

    public void Dispose()
    {
        _serviceProvider?.Dispose();
    }
}
```

**Key Point:** Multiple `DbContext` instances can share the same in-memory database by using the same database name.

---

## Mocking Strategies

### What to Mock

| Component | Mock? | Reason |
|-----------|-------|--------|
| External APIs | ✅ YES | Avoid network calls, control responses |
| ILogger | ✅ YES | Verify logging behavior |
| HTTP clients | ✅ YES | Fast, deterministic tests |
| Email/SMS services | ✅ YES | Avoid sending real messages |
| File system | ✅ YES | Avoid I/O |
| DbContext (EF Core) | ❌ NO | Use in-memory database instead |
| Repositories | ⚠️ DEPENDS | See below |
| CQRS handlers | ⚠️ DEPENDS | See below |

### Repository Pattern

**When testing services that use repositories:**

```csharp
public class CustomerServiceTests
{
    private readonly Mock<ICustomerRepository> _mockRepository;
    private readonly CustomerService _service;

    public CustomerServiceTests()
    {
        _mockRepository = new Mock<ICustomerRepository>();
        _service = new CustomerService(_mockRepository.Object);
    }

    [Fact]
    public async Task GetCustomer_ValidId_ReturnsCustomer()
    {
        // Arrange
        var expectedCustomer = new Customer { Id = 1, Name = "John" };
        _mockRepository
            .Setup(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()))
            .ReturnsAsync(expectedCustomer);

        // Act
        var result = await _service.GetCustomerAsync(1);

        // Assert
        Assert.NotNull(result);
        Assert.Equal("John", result.Name);
        _mockRepository.Verify(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()), Times.Once);
    }
}
```

**When testing repositories themselves:**

```csharp
public class CustomerRepositoryTests : IDisposable
{
    private readonly AppDbContext _dbContext;
    private readonly CustomerRepository _repository;

    public CustomerRepositoryTests()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        _dbContext = new AppDbContext(options);
        _repository = new CustomerRepository(_dbContext);
    }

    [Fact]
    public async Task GetByIdAsync_ExistingCustomer_ReturnsCustomer()
    {
        // Arrange
        var customer = new Customer { Id = 1, Name = "John" };
        _dbContext.Customers.Add(customer);
        await _dbContext.SaveChangesAsync();

        // Act
        var result = await _repository.GetByIdAsync(1);

        // Assert
        Assert.NotNull(result);
        Assert.Equal("John", result.Name);
    }

    public void Dispose()
    {
        _dbContext?.Dispose();
    }
}
```

### CQRS Pattern

**When testing command/query handlers:**

```csharp
public class CreateCustomerCommandHandlerTests : IDisposable
{
    private readonly AppDbContext _dbContext;
    private readonly CreateCustomerCommandHandler _handler;

    public CreateCustomerCommandHandlerTests()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        _dbContext = new AppDbContext(options);
        _handler = new CreateCustomerCommandHandler(_dbContext);
    }

    [Fact]
    public async Task Handle_ValidCommand_CreatesCustomer()
    {
        // Arrange
        var command = new CreateCustomerCommand { Name = "John", Email = "john@example.com" };

        // Act
        var result = await _handler.Handle(command, CancellationToken.None);

        // Assert
        Assert.NotEqual(0, result.CustomerId);
        var saved = await _dbContext.Customers.FindAsync(result.CustomerId);
        Assert.NotNull(saved);
        Assert.Equal("John", saved.Name);
    }

    public void Dispose()
    {
        _dbContext?.Dispose();
    }
}
```

**When testing services that use CQRS:**

```csharp
public class CustomerServiceTests
{
    private readonly Mock<IMediator> _mockMediator;
    private readonly CustomerService _service;

    public CustomerServiceTests()
    {
        _mockMediator = new Mock<IMediator>();
        _service = new CustomerService(_mockMediator.Object);
    }

    [Fact]
    public async Task CreateCustomer_ValidData_SendsCommand()
    {
        // Arrange
        var expectedResult = new CreateCustomerResult { CustomerId = 1 };
        _mockMediator
            .Setup(m => m.Send(It.IsAny<CreateCustomerCommand>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(expectedResult);

        // Act
        var result = await _service.CreateCustomerAsync("John", "john@example.com");

        // Assert
        Assert.Equal(1, result.CustomerId);
        _mockMediator.Verify(
            m => m.Send(It.Is<CreateCustomerCommand>(c => c.Name == "John"), It.IsAny<CancellationToken>()),
            Times.Once);
    }
}
```

### Mocking ILogger

**Verify logging behavior:**

```csharp
using Microsoft.Extensions.Logging;
using Moq;

public class EmailNotificationServiceTests
{
    private readonly Mock<ILogger<EmailNotificationService>> _mockLogger;
    private readonly EmailNotificationService _service;

    public EmailNotificationServiceTests()
    {
        _mockLogger = new Mock<ILogger<EmailNotificationService>>();
        _service = new EmailNotificationService(/* deps */, _mockLogger.Object);
    }

    [Fact]
    public async Task SendEmail_NoConfig_LogsWarning()
    {
        // Arrange - No email config in database

        // Act
        await _service.SendCircuitOpenedNotificationAsync("mistral", 3, "Error");

        // Assert - Verify warning was logged
        _mockLogger.Verify(
            x => x.Log(
                LogLevel.Warning,
                It.IsAny<EventId>(),
                It.Is<It.IsAnyType>((v, t) => v.ToString()!.Contains("No active email configuration")),
                It.IsAny<Exception>(),
                It.IsAny<Func<It.IsAnyType, Exception?, string>>()),
            Times.Once);
    }
}
```

---

## Design Patterns in Tests

### Strategy Pattern

When testing services that use Strategy pattern:

```csharp
public class MouseMonitoringServiceTests
{
    [Fact]
    public void CreateMonitor_LibevdevStrategy_ReturnsLibevdevMonitor()
    {
        // Arrange
        var service = new MouseMonitoringService();

        // Act
        var monitor = service.CreateMonitor(MouseMonitorStrategy.Libevdev);

        // Assert
        Assert.IsType<LibevdevMouseMonitor>(monitor);
    }
}
```

### Factory Pattern

When testing factories:

```csharp
public class LlmProviderFactoryTests
{
    [Theory]
    [InlineData("mistral", typeof(MistralProvider))]
    [InlineData("openai", typeof(OpenAIProvider))]
    public void Create_ValidProvider_ReturnsCorrectInstance(string providerName, Type expectedType)
    {
        // Arrange
        var factory = new LlmProviderFactory(/* deps */);

        // Act
        var provider = factory.Create(providerName);

        // Assert
        Assert.IsType(expectedType, provider);
    }
}
```

### Circuit Breaker Pattern

Testing circuit breaker behavior:

```csharp
public class LlmCorrectionServiceTests : IDisposable
{
    private readonly PushToTalkDbContext _dbContext;
    private readonly Mock<ILlmProvider> _mockLlmProvider;
    private readonly LlmCorrectionService _service;

    [Fact]
    public async Task CorrectTranscriptionAsync_CircuitBreaker_OpensAfter3Failures()
    {
        // Arrange
        _mockLlmProvider
            .Setup(p => p.CorrectTextAsync(It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new HttpRequestException("Connection timeout"));

        var longText = "This is a long enough text to trigger LLM correction attempts";

        // Act - Trigger 3 failures
        await _service.CorrectTranscriptionAsync(1, longText);
        await _service.CorrectTranscriptionAsync(2, longText);
        await _service.CorrectTranscriptionAsync(3, longText);

        // Assert - Circuit should be open
        var circuitState = await _dbContext.CircuitBreakerStates.FirstAsync();
        Assert.True(circuitState.IsOpen);
        Assert.Equal(3, circuitState.ConsecutiveFailures);
        Assert.NotNull(circuitState.OpenedAt);
    }

    [Fact]
    public async Task CorrectTranscriptionAsync_CircuitBreaker_SkipsWhenOpen()
    {
        // Arrange - Open circuit first (3 failures)
        // ... (same as above)

        _mockLlmProvider.Invocations.Clear();

        // Act - Try correction while circuit is open
        var result = await _service.CorrectTranscriptionAsync(4, longText);

        // Assert - Should skip and return original text
        Assert.Equal(longText, result);
        _mockLlmProvider.Verify(
            p => p.CorrectTextAsync(It.IsAny<string>(), It.IsAny<CancellationToken>()),
            Times.Never);
    }

    public void Dispose()
    {
        _dbContext?.Dispose();
    }
}
```

---

## Examples

### Real-World Example: LlmCorrectionService

**Source:** `PushToTalk.Service/Services/LlmCorrectionService.cs`
**Tests:** `PushToTalk.Service.Tests/Services/LlmCorrectionServiceTests.cs`

**What it tests:**
- ✅ Success path - saves correction to `llm_corrections` table
- ✅ Error path - saves error to `llm_errors` table with exception details
- ✅ Business logic - skips texts < 30 characters
- ✅ Circuit breaker - opens after 3 failures
- ✅ Circuit breaker - skips when open
- ✅ Circuit breaker - closes on success after retry timeout

**Key techniques used:**
- In-memory database for `PushToTalkDbContext`
- Mocking `ILlmProvider` for API calls
- Mocking `IEmailNotificationService` for notifications
- Mocking `ILogger` to verify logging
- Testing async methods
- Testing exception handling

**Test count:** 6 tests, all passing

### Real-World Example: DatabaseMistralOptionsSetup

**Source:** `PushToTalk.Service/Configuration/DatabaseMistralOptionsSetup.cs`
**Tests:** `PushToTalk.Service.Tests/Configuration/DatabaseMistralOptionsSetupTests.cs`

**What it tests:**
- ✅ Loads active Mistral configuration from database
- ✅ Loads most recent config when multiple exist
- ✅ Skips inactive configurations
- ✅ Throws exception when no active config found
- ✅ Throws exception when database is empty

**Key techniques used:**
- In-memory database with shared database name
- Separate `DbContext` instances for setup vs. testing
- Testing `IOptions<T>` configuration
- Testing with `ServiceCollection` and DI
- Testing ordering logic (`OrderByDescending`)

**Test count:** 5 tests, all passing

### Real-World Example: EmailNotificationService

**Source:** `PushToTalk.Service/Services/EmailNotificationService.cs`
**Tests:** `PushToTalk.Service.Tests/Services/EmailNotificationServiceTests.cs`

**What it tests:**
- ✅ Logs warning when no email config exists
- ✅ Loads most recent active email config
- ✅ Skips inactive email configs
- ✅ Logs error on SMTP failure

**Key techniques used:**
- In-memory database for email configuration
- Mocking `ILogger` to verify logging
- Testing SMTP error handling (without actual SMTP)
- Testing filtering logic (`IsActive`)

**Test count:** 5 tests, all passing

---

## Common Pitfalls

### ❌ Pitfall 1: Shared Database State

**Problem:** Tests affect each other because they share database.

```csharp
// ❌ WRONG - All tests share same database
private static readonly DbContextOptions<AppDbContext> _options =
    new DbContextOptionsBuilder<AppDbContext>()
        .UseInMemoryDatabase(databaseName: "TestDb")  // Same name for all tests!
        .Options;
```

**Solution:** Unique database per test class.

```csharp
// ✅ CORRECT - Each test class gets unique database
public CustomerServiceTests()
{
    var options = new DbContextOptionsBuilder<AppDbContext>()
        .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
        .Options;
    _dbContext = new AppDbContext(options);
}
```

### ❌ Pitfall 2: Testing Implementation Details

**Problem:** Test breaks when implementation changes, even though behavior is correct.

```csharp
// ❌ WRONG - Testing private method details
[Fact]
public void ValidateEmail_UsesRegex()
{
    // Checking internal implementation
    var field = typeof(CustomerService).GetField("_emailRegex", BindingFlags.NonPublic);
    Assert.NotNull(field);
}
```

**Solution:** Test public API and observable behavior.

```csharp
// ✅ CORRECT - Testing public behavior
[Theory]
[InlineData("john@example.com", true)]
[InlineData("invalid-email", false)]
public void CreateCustomer_EmailValidation_WorksCorrectly(string email, bool shouldSucceed)
{
    // Test public method behavior, not internal implementation
}
```

### ❌ Pitfall 3: Not Cleaning Up Resources

**Problem:** Tests leak resources (DbContext, HttpClient, etc.).

```csharp
// ❌ WRONG - No cleanup
public class CustomerServiceTests
{
    private readonly AppDbContext _dbContext;

    // No IDisposable implementation
}
```

**Solution:** Implement `IDisposable`.

```csharp
// ✅ CORRECT - Proper cleanup
public class CustomerServiceTests : IDisposable
{
    private readonly AppDbContext _dbContext;

    public void Dispose()
    {
        _dbContext?.Dispose();
    }
}
```

### ❌ Pitfall 4: Asserting on Duration/Time

**Problem:** Tests fail intermittently based on machine speed.

```csharp
// ❌ WRONG - Assumes operation takes time
[Fact]
public async Task CorrectTranscriptionAsync_TracksDuration()
{
    var result = await _service.CorrectTextAsync("test");
    var correction = await _dbContext.LlmCorrections.FirstAsync();
    Assert.True(correction.DurationMs > 0);  // ❌ Can be 0 with mocks!
}
```

**Solution:** Check for >= 0 or don't test timing with mocks.

```csharp
// ✅ CORRECT - Accepts instant mock operations
Assert.True(correction.DurationMs >= 0);
```

### ❌ Pitfall 5: Text Too Short for LLM

**Problem:** Test text doesn't meet business logic requirements.

```csharp
// ❌ WRONG - Text too short (< 30 chars)
[Fact]
public async Task CorrectTranscriptionAsync_WhenFails_SavesToErrors()
{
    var result = await _service.CorrectTextAsync("test text");  // Only 9 chars!

    // Test will fail - service skips texts < 30 chars
    var error = await _dbContext.LlmErrors.FirstOrDefaultAsync();
    Assert.NotNull(error);  // ❌ Will be null!
}
```

**Solution:** Use text that meets business requirements.

```csharp
// ✅ CORRECT - Text long enough to trigger LLM
var longText = "This is a long enough text to trigger LLM correction attempts";  // > 30 chars
var result = await _service.CorrectTextAsync(longText);
```

---

## Checklist Before Committing

Before claiming work is "done" or "completed":

- [ ] All new code has corresponding unit tests
- [ ] All tests pass locally (`dotnet test`)
- [ ] Tests cover success paths
- [ ] Tests cover error paths
- [ ] Tests cover edge cases
- [ ] No tests are marked `Skip`
- [ ] Tests use in-memory database (if applicable)
- [ ] Tests properly dispose resources
- [ ] Tests are deterministic (no random data, no time dependencies)
- [ ] Test names follow `[Method]_[Scenario]_[Expected]` pattern

**Remember:** If functionality doesn't work in tests, it's NOT done. Never skip this step.

---

## References

- **xUnit Documentation:** https://xunit.net/
- **Moq Documentation:** https://github.com/moq/moq4
- **EF Core InMemory Provider:** https://learn.microsoft.com/en-us/ef/core/testing/

---

**Related Files:**
- [workflow.md](../workflow/workflow.md) - Git workflow and testing requirements
- [SOLID Principles](../../solid-principles/solid-principles-2025.md) - Design principles
- [Design Patterns](../../design-patterns/gof-design-patterns-2025.md) - Pattern implementations
