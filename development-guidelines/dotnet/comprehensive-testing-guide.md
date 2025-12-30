# Comprehensive Testing Guide for .NET Applications

## Table of Contents

1. [Introduction](#introduction)
2. [Testing Fundamentals](#testing-fundamentals)
3. [Unit Testing](#unit-testing)
4. [Integration Testing](#integration-testing)
5. [End-to-End Testing](#end-to-end-testing)
6. [Test-Driven Development](#test-driven-development)
7. [Mocking and Stubbing](#mocking-and-stubbing)
8. [Testing Best Practices](#testing-best-practices)
9. [Code Coverage](#code-coverage)
10. [Continuous Integration](#continuous-integration)

## Introduction

Testing is a critical aspect of software development that ensures code quality, reliability, and maintainability. This comprehensive guide covers all aspects of testing .NET applications using modern frameworks and best practices.

### Why Testing Matters

Testing provides several key benefits:

- **Quality Assurance**: Ensures code works as expected
- **Regression Prevention**: Catches bugs before production
- **Documentation**: Tests serve as living documentation
- **Refactoring Safety**: Enables confident code changes
- **Design Feedback**: Guides better architecture decisions

### Testing Pyramid

The testing pyramid represents the ideal distribution of tests:

```
        /\
       /E2E\      Few, slow, expensive
      /------\
     /  INT   \   Medium number, moderate speed
    /----------\
   /   UNIT     \ Many, fast, cheap
  /--------------\
```

## Testing Fundamentals

### Core Testing Principles

#### Arrange-Act-Assert (AAA)

Every test should follow the AAA pattern:

```csharp
[Fact]
public void CalculateTotal_WithValidItems_ReturnsSumOfPrices()
{
    // Arrange
    var calculator = new OrderCalculator();
    var items = new[] { 10.0m, 20.0m, 30.0m };

    // Act
    var result = calculator.CalculateTotal(items);

    // Assert
    Assert.Equal(60.0m, result);
}
```

#### Test Independence

Tests must be independent and isolated:

```csharp
public class UserServiceTests : IDisposable
{
    private readonly UserService _sut;
    private readonly Mock<IUserRepository> _mockRepo;

    public UserServiceTests()
    {
        _mockRepo = new Mock<IUserRepository>();
        _sut = new UserService(_mockRepo.Object);
    }

    public void Dispose()
    {
        // Clean up resources
    }
}
```

#### Single Responsibility

Each test should verify one behavior:

```csharp
// Good - tests one thing
[Fact]
public void CreateUser_WithValidData_ReturnsUser()
{
    var user = _sut.CreateUser("John", "john@example.com");
    Assert.NotNull(user);
}

// Good - tests another thing separately
[Fact]
public void CreateUser_WithValidData_AssignsUniqueId()
{
    var user = _sut.CreateUser("John", "john@example.com");
    Assert.NotEqual(Guid.Empty, user.Id);
}
```

### Test Naming Conventions

Use descriptive test names that explain:
- What is being tested (Method/Class)
- Under what conditions (Input/State)
- What is expected (Output/Behavior)

```csharp
// Pattern: MethodName_Condition_ExpectedBehavior

[Fact]
public void Add_TwoPositiveNumbers_ReturnsSum() { }

[Fact]
public void Withdraw_InsufficientBalance_ThrowsException() { }

[Fact]
public void Login_ValidCredentials_ReturnsSuccessResult() { }

[Fact]
public void ProcessOrder_CancelledStatus_SkipsPayment() { }
```

## Unit Testing

Unit testing focuses on testing individual components in isolation.

### Setting Up xUnit

Install required packages:

```bash
dotnet add package xUnit
dotnet add package xUnit.runner.visualstudio
dotnet add package Microsoft.NET.Test.Sdk
dotnet add package Moq
dotnet add package FluentAssertions
```

Project structure:

```
MyProject/
├── src/
│   └── MyProject/
│       ├── Services/
│       ├── Models/
│       └── MyProject.csproj
└── tests/
    └── MyProject.Tests/
        ├── Services/
        ├── Models/
        └── MyProject.Tests.csproj
```

### Basic Unit Test Example

```csharp
public class CalculatorTests
{
    [Fact]
    public void Add_TwoNumbers_ReturnsSum()
    {
        // Arrange
        var calculator = new Calculator();

        // Act
        var result = calculator.Add(5, 3);

        // Assert
        Assert.Equal(8, result);
    }

    [Theory]
    [InlineData(2, 3, 5)]
    [InlineData(0, 0, 0)]
    [InlineData(-1, 1, 0)]
    [InlineData(100, 200, 300)]
    public void Add_VariousInputs_ReturnsCorrectSum(int a, int b, int expected)
    {
        var calculator = new Calculator();
        var result = calculator.Add(a, b);
        Assert.Equal(expected, result);
    }
}
```

### Testing Exceptions

```csharp
[Fact]
public void Divide_ByZero_ThrowsArgumentException()
{
    var calculator = new Calculator();

    Assert.Throws<ArgumentException>(() => calculator.Divide(10, 0));
}

[Fact]
public void CreateUser_NullEmail_ThrowsArgumentNullException()
{
    var service = new UserService();

    var exception = Assert.Throws<ArgumentNullException>(
        () => service.CreateUser("John", null));

    Assert.Equal("email", exception.ParamName);
}
```

### Testing Async Methods

```csharp
[Fact]
public async Task GetUserAsync_ExistingId_ReturnsUser()
{
    // Arrange
    var userId = Guid.NewGuid();
    var mockRepo = new Mock<IUserRepository>();
    mockRepo.Setup(r => r.GetByIdAsync(userId))
           .ReturnsAsync(new User { Id = userId, Name = "John" });

    var service = new UserService(mockRepo.Object);

    // Act
    var result = await service.GetUserAsync(userId);

    // Assert
    Assert.NotNull(result);
    Assert.Equal(userId, result.Id);
}
```

### FluentAssertions

FluentAssertions provides more readable assertions:

```csharp
[Fact]
public void CreateOrder_ValidInput_ReturnsCompleteOrder()
{
    var order = _sut.CreateOrder(customerId: 123, items: new[] { 1, 2, 3 });

    order.Should().NotBeNull();
    order.CustomerId.Should().Be(123);
    order.Items.Should().HaveCount(3);
    order.Status.Should().Be(OrderStatus.Pending);
    order.CreatedAt.Should().BeCloseTo(DateTime.UtcNow, TimeSpan.FromSeconds(5));
}

[Fact]
public void GetAllUsers_WhenUsersExist_ReturnsUserCollection()
{
    var users = _sut.GetAllUsers();

    users.Should()
         .NotBeEmpty()
         .And.HaveCountGreaterThan(0)
         .And.OnlyContain(u => !string.IsNullOrEmpty(u.Email));
}
```

## Integration Testing

Integration tests verify that multiple components work together correctly.

### WebApplicationFactory Testing

```csharp
public class ApiIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public ApiIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task GetUsers_ReturnsSuccessStatusCode()
    {
        var response = await _client.GetAsync("/api/users");

        response.EnsureSuccessStatusCode();
        var content = await response.Content.ReadAsStringAsync();
        content.Should().NotBeEmpty();
    }
}
```

### Custom WebApplicationFactory

```csharp
public class CustomWebApplicationFactory : WebApplicationFactory<Program>
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.ConfigureServices(services =>
        {
            // Remove real database
            var descriptor = services.SingleOrDefault(
                d => d.ServiceType == typeof(DbContextOptions<AppDbContext>));
            if (descriptor != null)
                services.Remove(descriptor);

            // Add in-memory database
            services.AddDbContext<AppDbContext>(options =>
            {
                options.UseInMemoryDatabase("InMemoryDbForTesting");
            });

            // Seed test data
            var sp = services.BuildServiceProvider();
            using var scope = sp.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            db.Database.EnsureCreated();
            SeedTestData(db);
        });
    }

    private void SeedTestData(AppDbContext db)
    {
        db.Users.AddRange(
            new User { Id = 1, Name = "Test User 1" },
            new User { Id = 2, Name = "Test User 2" }
        );
        db.SaveChanges();
    }
}
```

### Database Integration Testing

```csharp
public class UserRepositoryTests : IDisposable
{
    private readonly AppDbContext _context;
    private readonly UserRepository _repository;

    public UserRepositoryTests()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        _context = new AppDbContext(options);
        _repository = new UserRepository(_context);
    }

    [Fact]
    public async Task AddUser_ValidUser_SavesToDatabase()
    {
        // Arrange
        var user = new User { Name = "John", Email = "john@test.com" };

        // Act
        await _repository.AddAsync(user);
        await _context.SaveChangesAsync();

        // Assert
        var savedUser = await _context.Users.FirstOrDefaultAsync();
        savedUser.Should().NotBeNull();
        savedUser.Name.Should().Be("John");
    }

    public void Dispose()
    {
        _context.Database.EnsureDeleted();
        _context.Dispose();
    }
}
```

## End-to-End Testing

E2E tests verify complete user workflows.

### Playwright Testing

```csharp
public class E2ETests : PageTest
{
    [Test]
    public async Task UserCanLogin()
    {
        await Page.GotoAsync("https://localhost:5001");

        await Page.ClickAsync("text=Login");
        await Page.FillAsync("input[name='email']", "user@test.com");
        await Page.FillAsync("input[name='password']", "password123");
        await Page.ClickAsync("button[type='submit']");

        await Expect(Page.Locator("text=Dashboard")).ToBeVisibleAsync();
    }

    [Test]
    public async Task UserCanCreateOrder()
    {
        await Page.GotoAsync("https://localhost:5001/orders/new");

        await Page.SelectOptionAsync("select[name='product']", "Product A");
        await Page.FillAsync("input[name='quantity']", "5");
        await Page.ClickAsync("button[type='submit']");

        await Expect(Page.Locator(".success-message"))
            .ToContainTextAsync("Order created successfully");
    }
}
```

## Test-Driven Development

TDD follows the Red-Green-Refactor cycle.

### TDD Workflow

1. **Red**: Write a failing test
2. **Green**: Write minimum code to pass
3. **Refactor**: Improve code while keeping tests green

### TDD Example

```csharp
// Step 1: Red - Write failing test
[Fact]
public void GetDiscount_NewCustomer_Returns0()
{
    var customer = new Customer { IsNew = true };
    var calculator = new DiscountCalculator();

    var discount = calculator.GetDiscount(customer);

    Assert.Equal(0, discount);
}

// Step 2: Green - Minimum implementation
public class DiscountCalculator
{
    public decimal GetDiscount(Customer customer)
    {
        return 0; // Simplest code that passes
    }
}

// Step 3: Add another test
[Fact]
public void GetDiscount_RegularCustomer_Returns10Percent()
{
    var customer = new Customer { IsNew = false, YearsActive = 2 };
    var calculator = new DiscountCalculator();

    var discount = calculator.GetDiscount(customer);

    Assert.Equal(0.10m, discount);
}

// Step 4: Implement
public decimal GetDiscount(Customer customer)
{
    if (customer.IsNew)
        return 0;

    return 0.10m;
}

// Step 5: Refactor if needed
```

## Mocking and Stubbing

### Moq Framework

```csharp
[Fact]
public void ProcessOrder_ValidOrder_CallsRepository()
{
    // Arrange
    var mockRepo = new Mock<IOrderRepository>();
    var service = new OrderService(mockRepo.Object);
    var order = new Order { Id = 1 };

    // Act
    service.ProcessOrder(order);

    // Assert
    mockRepo.Verify(r => r.Save(order), Times.Once);
}

[Fact]
public void GetUser_ExistingId_ReturnsUser()
{
    // Arrange
    var userId = 123;
    var expectedUser = new User { Id = userId, Name = "John" };

    var mockRepo = new Mock<IUserRepository>();
    mockRepo.Setup(r => r.GetById(userId))
           .Returns(expectedUser);

    var service = new UserService(mockRepo.Object);

    // Act
    var result = service.GetUser(userId);

    // Assert
    result.Should().BeEquivalentTo(expectedUser);
}
```

### Advanced Mocking

```csharp
[Fact]
public void SendEmail_WhenCalled_LogsAttempt()
{
    var mockLogger = new Mock<ILogger<EmailService>>();
    var mockSmtpClient = new Mock<ISmtpClient>();
    var service = new EmailService(mockSmtpClient.Object, mockLogger.Object);

    service.SendEmail("test@example.com", "Subject", "Body");

    mockLogger.Verify(
        l => l.Log(
            LogLevel.Information,
            It.IsAny<EventId>(),
            It.Is<It.IsAnyType>((v, t) => v.ToString().Contains("Sending email")),
            It.IsAny<Exception>(),
            It.IsAny<Func<It.IsAnyType, Exception, string>>()),
        Times.Once);
}

[Fact]
public void ProcessPayment_NetworkFailure_RetriesThreeTimes()
{
    var mockGateway = new Mock<IPaymentGateway>();
    mockGateway.SetupSequence(g => g.Charge(It.IsAny<decimal>()))
              .Throws(new NetworkException())
              .Throws(new NetworkException())
              .Returns(new PaymentResult { Success = true });

    var service = new PaymentService(mockGateway.Object);

    var result = service.ProcessPayment(100m);

    result.Success.Should().BeTrue();
    mockGateway.Verify(g => g.Charge(100m), Times.Exactly(3));
}
```

## Testing Best Practices

### Test Organization

```csharp
public class OrderServiceTests
{
    public class CreateOrder
    {
        [Fact]
        public void ValidInput_ReturnsOrder() { }

        [Fact]
        public void NullCustomer_ThrowsException() { }
    }

    public class CancelOrder
    {
        [Fact]
        public void PendingOrder_UpdatesStatus() { }

        [Fact]
        public void CompletedOrder_ThrowsException() { }
    }
}
```

### Test Data Builders

```csharp
public class UserBuilder
{
    private string _name = "Default Name";
    private string _email = "default@test.com";
    private bool _isActive = true;

    public UserBuilder WithName(string name)
    {
        _name = name;
        return this;
    }

    public UserBuilder WithEmail(string email)
    {
        _email = email;
        return this;
    }

    public UserBuilder Inactive()
    {
        _isActive = false;
        return this;
    }

    public User Build()
    {
        return new User
        {
            Name = _name,
            Email = _email,
            IsActive = _isActive
        };
    }
}

// Usage
[Fact]
public void Test()
{
    var user = new UserBuilder()
        .WithName("John")
        .WithEmail("john@test.com")
        .Inactive()
        .Build();
}
```

### Testing Time-Dependent Code

```csharp
public interface ISystemClock
{
    DateTime UtcNow { get; }
}

public class SystemClock : ISystemClock
{
    public DateTime UtcNow => DateTime.UtcNow;
}

[Fact]
public void IsExpired_CurrentDate_ReturnsFalse()
{
    var mockClock = new Mock<ISystemClock>();
    mockClock.Setup(c => c.UtcNow).Returns(new DateTime(2024, 1, 15));

    var subscription = new Subscription
    {
        ExpiryDate = new DateTime(2024, 1, 20),
        Clock = mockClock.Object
    };

    subscription.IsExpired.Should().BeFalse();
}
```

## Code Coverage

### Measuring Coverage

```bash
dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura
```

### Coverage Reports

```bash
dotnet tool install -g dotnet-reportgenerator-globaltool
reportgenerator -reports:coverage.cobertura.xml -targetdir:coveragereport
```

### Coverage Goals

- **Unit Tests**: Aim for 80%+ coverage
- **Critical Paths**: 100% coverage for business logic
- **UI Code**: Lower coverage acceptable (60-70%)
- **Integration Tests**: Focus on workflows, not coverage percentage

### Coverage Limitations

Coverage doesn't guarantee quality:

```csharp
// 100% coverage, but poor test
[Fact]
public void Test()
{
    var result = Calculator.Add(2, 2);
    Assert.True(true); // Always passes!
}
```

## Continuous Integration

### GitHub Actions Workflow

```yaml
name: .NET Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    - name: Setup .NET
      uses: actions/setup-dotnet@v3
      with:
        dotnet-version: '8.0.x'

    - name: Restore dependencies
      run: dotnet restore

    - name: Build
      run: dotnet build --no-restore

    - name: Test
      run: dotnet test --no-build --verbosity normal --collect:"XPlat Code Coverage"

    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        files: '**/coverage.cobertura.xml'
```

### Test Parallelization

```csharp
// Disable parallelization for specific class
[Collection("Database Tests")]
public class UserRepositoryTests { }

// Configure in xunit.runner.json
{
  "parallelizeTestCollections": false,
  "maxParallelThreads": 4
}
```

## Performance Testing

### Benchmarking with BenchmarkDotNet

```csharp
[MemoryDiagnoser]
public class StringBenchmarks
{
    private const int Iterations = 10000;

    [Benchmark]
    public string StringConcatenation()
    {
        string result = "";
        for (int i = 0; i < Iterations; i++)
        {
            result += "test";
        }
        return result;
    }

    [Benchmark]
    public string StringBuilder()
    {
        var sb = new StringBuilder();
        for (int i = 0; i < Iterations; i++)
        {
            sb.Append("test");
        }
        return sb.ToString();
    }
}
```

### Load Testing

```csharp
[Fact]
public async Task ApiEndpoint_UnderLoad_MaintainsPerformance()
{
    var tasks = Enumerable.Range(0, 100)
        .Select(_ => _client.GetAsync("/api/users"))
        .ToArray();

    var stopwatch = Stopwatch.StartNew();
    await Task.WhenAll(tasks);
    stopwatch.Stop();

    stopwatch.ElapsedMilliseconds.Should().BeLessThan(5000);
}
```

## Security Testing

### Input Validation Testing

```csharp
[Theory]
[InlineData("<script>alert('xss')</script>")]
[InlineData("'; DROP TABLE Users; --")]
[InlineData("../../../etc/passwd")]
public void CreateUser_MaliciousInput_RejectsInput(string maliciousInput)
{
    var service = new UserService();

    Assert.Throws<ValidationException>(
        () => service.CreateUser(maliciousInput, "test@example.com"));
}
```

### Authentication Testing

```csharp
[Fact]
public async Task ProtectedEndpoint_WithoutAuth_Returns401()
{
    var response = await _client.GetAsync("/api/admin");
    response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
}

[Fact]
public async Task ProtectedEndpoint_WithValidToken_Returns200()
{
    _client.DefaultRequestHeaders.Authorization =
        new AuthenticationHeaderValue("Bearer", _validToken);

    var response = await _client.GetAsync("/api/admin");
    response.StatusCode.Should().Be(HttpStatusCode.OK);
}
```

## Mutation Testing

Mutation testing verifies test quality by introducing bugs.

### Stryker.NET

```bash
dotnet tool install -g dotnet-stryker
dotnet stryker
```

Configuration:

```json
{
  "stryker-config": {
    "project": "MyProject.csproj",
    "test-projects": ["MyProject.Tests.csproj"],
    "mutation-level": "Complete",
    "threshold-high": 80,
    "threshold-low": 60,
    "threshold-break": 50
  }
}
```

## Snapshot Testing

### Verify Library

```csharp
[Fact]
public Task GenerateReport_ValidData_MatchesSnapshot()
{
    var report = _generator.GenerateReport(testData);
    return Verifier.Verify(report);
}
```

## Contract Testing

### Pact.NET

```csharp
public class ConsumerTests : IDisposable
{
    private readonly IPactBuilderV3 _pact;

    public ConsumerTests()
    {
        _pact = Pact.V3("Consumer", "Provider", new PactConfig());
    }

    [Fact]
    public async Task GetUser_ExistingUser_ReturnsUserData()
    {
        _pact
            .UponReceiving("A request for user 1")
            .WithRequest(HttpMethod.Get, "/api/users/1")
            .WillRespond()
            .WithStatus(HttpStatusCode.OK)
            .WithHeader("Content-Type", "application/json")
            .WithJsonBody(new { id = 1, name = "John Doe" });

        await _pact.VerifyAsync(async ctx =>
        {
            var client = new HttpClient { BaseAddress = ctx.MockServerUri };
            var response = await client.GetAsync("/api/users/1");
            var user = await response.Content.ReadFromJsonAsync<User>();

            user.Should().NotBeNull();
            user.Id.Should().Be(1);
            user.Name.Should().Be("John Doe");
        });
    }
}
```

## Property-Based Testing

### FsCheck

```csharp
[Property]
public Property Add_Commutative()
{
    return Prop.ForAll<int, int>((a, b) =>
    {
        var calculator = new Calculator();
        return calculator.Add(a, b) == calculator.Add(b, a);
    });
}

[Property]
public Property Sort_Idempotent()
{
    return Prop.ForAll<int[]>(array =>
    {
        var sorted1 = array.OrderBy(x => x).ToArray();
        var sorted2 = sorted1.OrderBy(x => x).ToArray();

        return sorted1.SequenceEqual(sorted2);
    });
}
```

## Database Testing Patterns

### Repository Pattern Testing

```csharp
public class UserRepositoryTests
{
    private readonly AppDbContext _context;
    private readonly UserRepository _repository;

    public UserRepositoryTests()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        _context = new AppDbContext(options);
        _repository = new UserRepository(_context);

        SeedDatabase();
    }

    private void SeedDatabase()
    {
        _context.Users.AddRange(
            new User { Id = 1, Name = "User 1", Email = "user1@test.com" },
            new User { Id = 2, Name = "User 2", Email = "user2@test.com" },
            new User { Id = 3, Name = "User 3", Email = "user3@test.com" }
        );
        _context.SaveChanges();
    }

    [Fact]
    public async Task GetByIdAsync_ExistingUser_ReturnsUser()
    {
        var user = await _repository.GetByIdAsync(1);

        user.Should().NotBeNull();
        user.Name.Should().Be("User 1");
    }

    [Fact]
    public async Task GetAllAsync_ReturnsAllUsers()
    {
        var users = await _repository.GetAllAsync();
        users.Should().HaveCount(3);
    }

    [Fact]
    public async Task AddAsync_NewUser_IncreasesCount()
    {
        var newUser = new User { Id = 4, Name = "User 4", Email = "user4@test.com" };

        await _repository.AddAsync(newUser);
        await _context.SaveChangesAsync();

        var users = await _repository.GetAllAsync();
        users.Should().HaveCount(4);
    }

    [Fact]
    public async Task UpdateAsync_ExistingUser_ModifiesData()
    {
        var user = await _repository.GetByIdAsync(1);
        user.Name = "Updated Name";

        await _repository.UpdateAsync(user);
        await _context.SaveChangesAsync();

        var updated = await _repository.GetByIdAsync(1);
        updated.Name.Should().Be("Updated Name");
    }

    [Fact]
    public async Task DeleteAsync_ExistingUser_RemovesFromDatabase()
    {
        await _repository.DeleteAsync(1);
        await _context.SaveChangesAsync();

        var users = await _repository.GetAllAsync();
        users.Should().HaveCount(2);
    }
}
```

### Transaction Testing

```csharp
[Fact]
public async Task TransferMoney_SuccessfulTransfer_UpdatesBothAccounts()
{
    using var transaction = await _context.Database.BeginTransactionAsync();

    try
    {
        var fromAccount = await _repository.GetByIdAsync(1);
        var toAccount = await _repository.GetByIdAsync(2);

        fromAccount.Balance -= 100;
        toAccount.Balance += 100;

        await _repository.UpdateAsync(fromAccount);
        await _repository.UpdateAsync(toAccount);
        await _context.SaveChangesAsync();

        await transaction.CommitAsync();

        var updatedFrom = await _repository.GetByIdAsync(1);
        var updatedTo = await _repository.GetByIdAsync(2);

        updatedFrom.Balance.Should().Be(fromAccount.Balance);
        updatedTo.Balance.Should().Be(toAccount.Balance);
    }
    catch
    {
        await transaction.RollbackAsync();
        throw;
    }
}
```

## Testing Microservices

### Service Communication Testing

```csharp
[Fact]
public async Task OrderService_CreateOrder_NotifiesInventoryService()
{
    var mockInventoryClient = new Mock<IInventoryServiceClient>();
    var orderService = new OrderService(mockInventoryClient.Object);

    var order = new Order { ProductId = 123, Quantity = 5 };
    await orderService.CreateOrderAsync(order);

    mockInventoryClient.Verify(
        c => c.ReserveInventoryAsync(123, 5),
        Times.Once);
}
```

### Message Queue Testing

```csharp
[Fact]
public async Task PublishEvent_ValidEvent_SendsToQueue()
{
    var mockMessageBus = new Mock<IMessageBus>();
    var publisher = new EventPublisher(mockMessageBus.Object);

    var orderEvent = new OrderCreatedEvent { OrderId = 123 };
    await publisher.PublishAsync(orderEvent);

    mockMessageBus.Verify(
        m => m.SendAsync(It.Is<OrderCreatedEvent>(e => e.OrderId == 123)),
        Times.Once);
}
```

## Test Doubles Patterns

### Dummy Objects

```csharp
public class DummyLogger : ILogger<UserService>
{
    public IDisposable BeginScope<TState>(TState state) => null;
    public bool IsEnabled(LogLevel logLevel) => false;
    public void Log<TState>(LogLevel logLevel, EventId eventId, TState state,
        Exception exception, Func<TState, Exception, string> formatter) { }
}

[Fact]
public void Test_WithDummyLogger()
{
    var service = new UserService(new DummyLogger());
    // Logger is required but not used in this test
}
```

### Fake Objects

```csharp
public class FakeUserRepository : IUserRepository
{
    private readonly List<User> _users = new();
    private int _nextId = 1;

    public Task<User> GetByIdAsync(int id)
    {
        return Task.FromResult(_users.FirstOrDefault(u => u.Id == id));
    }

    public Task<IEnumerable<User>> GetAllAsync()
    {
        return Task.FromResult<IEnumerable<User>>(_users);
    }

    public Task AddAsync(User user)
    {
        user.Id = _nextId++;
        _users.Add(user);
        return Task.CompletedTask;
    }
}

[Fact]
public async Task Test_WithFakeRepository()
{
    var fakeRepo = new FakeUserRepository();
    var service = new UserService(fakeRepo);

    await service.CreateUserAsync("John", "john@test.com");
    var users = await fakeRepo.GetAllAsync();

    users.Should().HaveCount(1);
}
```

### Stub Objects

```csharp
[Fact]
public void GetWeatherForecast_ReturnsStubData()
{
    var stubWeatherService = new Mock<IWeatherService>();
    stubWeatherService.Setup(s => s.GetForecast(It.IsAny<string>()))
        .Returns(new WeatherForecast { Temperature = 25, Condition = "Sunny" });

    var controller = new WeatherController(stubWeatherService.Object);
    var result = controller.GetForecast("Prague");

    result.Temperature.Should().Be(25);
}
```

### Spy Objects

```csharp
public class SpyEmailService : IEmailService
{
    public int EmailsSent { get; private set; }
    public List<string> Recipients { get; } = new();

    public void SendEmail(string to, string subject, string body)
    {
        EmailsSent++;
        Recipients.Add(to);
    }
}

[Fact]
public void NotifyUsers_MultipleUsers_SendsMultipleEmails()
{
    var spy = new SpyEmailService();
    var service = new NotificationService(spy);

    service.NotifyUsers(new[] { "user1@test.com", "user2@test.com" });

    spy.EmailsSent.Should().Be(2);
    spy.Recipients.Should().Contain("user1@test.com");
    spy.Recipients.Should().Contain("user2@test.com");
}
```

## Advanced Testing Scenarios

### Testing Background Services

```csharp
public class BackgroundWorkerTests
{
    [Fact]
    public async Task Worker_ProcessesQueuedItems()
    {
        var mockQueue = new Mock<IBackgroundQueue>();
        mockQueue.SetupSequence(q => q.DequeueAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(new WorkItem { Id = 1 })
            .ReturnsAsync(new WorkItem { Id = 2 })
            .ReturnsAsync((WorkItem)null); // End of queue

        var worker = new BackgroundWorker(mockQueue.Object);

        using var cts = new CancellationTokenSource();
        var workerTask = worker.StartAsync(cts.Token);

        await Task.Delay(100);
        cts.Cancel();

        await workerTask;

        mockQueue.Verify(q => q.DequeueAsync(It.IsAny<CancellationToken>()),
            Times.AtLeast(2));
    }
}
```

### Testing Caching

```csharp
[Fact]
public async Task GetUser_CachedUser_DoesNotHitDatabase()
{
    var mockRepo = new Mock<IUserRepository>();
    var mockCache = new Mock<ICache>();

    var cachedUser = new User { Id = 1, Name = "Cached" };
    mockCache.Setup(c => c.GetAsync<User>("user_1"))
            .ReturnsAsync(cachedUser);

    var service = new UserService(mockRepo.Object, mockCache.Object);

    var result = await service.GetUserAsync(1);

    result.Should().Be(cachedUser);
    mockRepo.Verify(r => r.GetByIdAsync(It.IsAny<int>()), Times.Never);
}

[Fact]
public async Task GetUser_NotCached_CachesResult()
{
    var mockRepo = new Mock<IUserRepository>();
    var mockCache = new Mock<ICache>();

    mockCache.Setup(c => c.GetAsync<User>(It.IsAny<string>()))
            .ReturnsAsync((User)null);

    var dbUser = new User { Id = 1, Name = "FromDb" };
    mockRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(dbUser);

    var service = new UserService(mockRepo.Object, mockCache.Object);

    await service.GetUserAsync(1);

    mockCache.Verify(c => c.SetAsync("user_1", dbUser, It.IsAny<TimeSpan>()),
        Times.Once);
}
```

### Testing File Operations

```csharp
[Fact]
public async Task SaveFile_ValidData_WritesToDisk()
{
    var tempPath = Path.GetTempFileName();

    try
    {
        var service = new FileService();
        await service.SaveFileAsync(tempPath, "test content");

        var content = await File.ReadAllTextAsync(tempPath);
        content.Should().Be("test content");
    }
    finally
    {
        File.Delete(tempPath);
    }
}
```

### Testing External API Integration

```csharp
[Fact]
public async Task GetExchangeRate_ValidCurrency_ReturnsRate()
{
    var mockHttp = new Mock<HttpMessageHandler>();
    mockHttp.Protected()
        .Setup<Task<HttpResponseMessage>>(
            "SendAsync",
            ItExpr.IsAny<HttpRequestMessage>(),
            ItExpr.IsAny<CancellationToken>())
        .ReturnsAsync(new HttpResponseMessage
        {
            StatusCode = HttpStatusCode.OK,
            Content = new StringContent("{\"rate\": 1.18}")
        });

    var httpClient = new HttpClient(mockHttp.Object);
    var service = new ExchangeRateService(httpClient);

    var rate = await service.GetRateAsync("USD", "EUR");

    rate.Should().Be(1.18m);
}
```

## Test Maintenance

### Refactoring Tests

```csharp
// Before - duplicated setup
[Fact]
public void Test1()
{
    var options = new DbContextOptionsBuilder<AppDbContext>()
        .UseInMemoryDatabase("Test").Options;
    var context = new AppDbContext(options);
    var repo = new UserRepository(context);
    // ... test code
}

[Fact]
public void Test2()
{
    var options = new DbContextOptionsBuilder<AppDbContext>()
        .UseInMemoryDatabase("Test").Options;
    var context = new AppDbContext(options);
    var repo = new UserRepository(context);
    // ... test code
}

// After - extracted setup
public class UserRepositoryTests : IDisposable
{
    private readonly AppDbContext _context;
    private readonly UserRepository _repository;

    public UserRepositoryTests()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString()).Options;
        _context = new AppDbContext(options);
        _repository = new UserRepository(_context);
    }

    [Fact]
    public void Test1() { /* uses _repository */ }

    [Fact]
    public void Test2() { /* uses _repository */ }

    public void Dispose() => _context.Dispose();
}
```

### Test Smells to Avoid

```csharp
// Smell: Magic Numbers
[Fact]
public void BadTest()
{
    var result = Calculate(42, 17);
    Assert.Equal(59, result);
}

// Better: Named Constants
[Fact]
public void GoodTest()
{
    const int firstNumber = 42;
    const int secondNumber = 17;
    const int expectedSum = 59;

    var result = Calculate(firstNumber, secondNumber);

    Assert.Equal(expectedSum, result);
}

// Smell: Conditional Logic
[Fact]
public void BadTest2()
{
    var users = GetUsers();

    if (users.Any())
    {
        Assert.True(users.First().IsActive);
    }
}

// Better: Explicit Assertion
[Fact]
public void GoodTest2()
{
    var users = GetUsers();

    users.Should().NotBeEmpty();
    users.First().IsActive.Should().BeTrue();
}
```

## Conclusion

Comprehensive testing ensures application quality and reliability. Follow these principles:

1. Write tests first (TDD when possible)
2. Keep tests simple and focused
3. Mock external dependencies appropriately
4. Maintain high coverage of critical code
5. Run tests in CI/CD pipeline
6. Treat tests as first-class code
7. Refactor tests along with production code
8. Use appropriate test doubles (dummy, fake, stub, spy, mock)
9. Test at multiple levels (unit, integration, E2E)
10. Monitor and maintain test quality over time

Remember: **Good tests enable confident refactoring and rapid development.**

## Additional Resources

- [xUnit Documentation](https://xunit.net/)
- [Moq Quickstart](https://github.com/moq/moq4)
- [FluentAssertions](https://fluentassertions.com/)
- [BenchmarkDotNet](https://benchmarkdotnet.org/)
- [Stryker.NET](https://stryker-mutator.io/docs/stryker-net/introduction)
- [Test-Driven Development by Kent Beck](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530)
