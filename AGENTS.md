# AGENTS.md - Engineering Handbook

Instructions for AI coding agents working in Olbrasoft .NET repositories.

## Quick Reference

```bash
# Build
dotnet build -c Release

# Run all tests
dotnet test

# Run single test by name
dotnet test --filter "FullyQualifiedName~MyTestMethod"

# Run tests in specific project
dotnet test tests/MyProject.Tests

# Run unit tests only (exclude integration tests - for CI)
dotnet test --filter "FullyQualifiedName!~IntegrationTests"
```

## Project Standards

| Standard            | Value                              |
|---------------------|------------------------------------|
| Target Framework    | .NET 10 (`net10.0`)                |
| Root Namespace      | `Olbrasoft.{Domain}.{Layer}`       |
| Testing Framework   | xUnit + Moq                        |
| Nullable            | Enabled                            |
| Implicit Usings     | Enabled                            |

## Code Style Guidelines

### Naming Conventions

| Element             | Convention        | Example                           |
|---------------------|-------------------|-----------------------------------|
| Classes/Interfaces  | PascalCase        | `CustomerService`, `IRepository`  |
| Interface prefix    | `I`               | `ICustomerService`                |
| Methods/Properties  | PascalCase        | `GetCustomerName()`, `OrderCount` |
| Async methods       | Suffix `Async`    | `GetCustomerAsync()`              |
| Local variables     | camelCase         | `orderTotal`, `isValid`           |
| Private fields      | `_camelCase`      | `_logger`, `_repository`          |
| Constants           | PascalCase        | `MaxRetryCount`                   |
| Enums               | PascalCase (singular) | `OrderStatus`                 |

### Folder vs Namespace

**Folders:** NO `Olbrasoft.` prefix. **Namespaces:** YES `Olbrasoft.` prefix.

```
Folder: VirtualAssistant.Voice/
Namespace: Olbrasoft.VirtualAssistant.Voice
```

Set in `.csproj`:
```xml
<RootNamespace>Olbrasoft.{Domain}.{Layer}</RootNamespace>
```

### Type Usage

- Use `decimal` for financial values (never `float`/`double`)
- Return `IEnumerable<T>` for read-only, `IList<T>` for modifiable
- Prefer value objects over primitives: `CustomerId` instead of `string`
- Enable nullable reference types: `<Nullable>enable</Nullable>`

### Async/Await

- Always use async for I/O operations
- Use `ConfigureAwait(false)` in library code
- Never use `async void` (except event handlers)
- Always suffix async methods with `Async`

### Error Handling

- Throw specific exceptions: `CustomerNotFoundException`, not `Exception`
- Use `Result<T>` pattern for expected failures
- Validate parameters: `ArgumentNullException.ThrowIfNull()`
- Never suppress errors with empty catch blocks

### Dependency Injection

- Constructor injection only (no property injection)
- All dependencies readonly and non-null validated
- Correct lifetimes: Scoped for DbContext, Singleton for caches

## Testing

### Project Structure

```
src/
  ProjectName.Core/
  ProjectName.Service/
tests/
  ProjectName.Core.Tests/
  ProjectName.Service.Tests/
```

**Rule:** Each source project = separate test project. Never shared test projects.

### Test Naming

Pattern: `MethodName_Scenario_ExpectedBehavior`

```csharp
[Fact]
public async Task GetAsync_WithExistingId_ReturnsEntity()

[Fact]
public async Task GetAsync_WithNonExistentId_ReturnsNull()
```

### Test Class Template

```csharp
public class MyServiceTests : IDisposable
{
    private readonly MyDbContext _dbContext;
    private readonly MyService _service;

    public MyServiceTests()
    {
        var options = new DbContextOptionsBuilder<MyDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        _dbContext = new MyDbContext(options);
        _service = new MyService(_dbContext);
    }

    public void Dispose() => _dbContext?.Dispose();
}
```

### Mocking with Moq

```csharp
var mockService = new Mock<IMyService>();
mockService.Setup(s => s.GetAsync(It.IsAny<int>())).ReturnsAsync(entity);
mockService.Verify(s => s.SaveAsync(), Times.Once);
```

### Skip Tests on CI

Use `[SkipOnCIFact]` for tests requiring local resources:

```csharp
using Olbrasoft.Testing.Xunit.Attributes;

[SkipOnCIFact]
public void Test_RequiringDBus_Works() { }
```

## Git Workflow

### Branch Naming

| Type       | Pattern                    |
|------------|----------------------------|
| Feature    | `feature/issue-N-desc`     |
| Fix        | `fix/issue-N-desc`         |
| Experiment | `experiment/desc`          |

### Commit Messages

```
[Type]: Short description (50 chars)

Co-Authored-By: Claude <noreply@anthropic.com>
```

Types: `Add`, `Fix`, `Update`, `Refactor`, `Remove`, `Docs`

### Before Commit Checklist

- [ ] Compiles without warnings
- [ ] Tests pass (`dotnet test`)
- [ ] No secrets or connection strings
- [ ] No debug output (`Console.WriteLine`)
- [ ] No commented-out code

## Project Templates

### Source .csproj

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <RootNamespace>Olbrasoft.{Domain}.{Layer}</RootNamespace>
  </PropertyGroup>
</Project>
```

### Test .csproj

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <IsPackable>false</IsPackable>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.14.1" />
    <PackageReference Include="Moq" Version="4.20.72" />
    <PackageReference Include="xunit" Version="2.9.3" />
    <PackageReference Include="xunit.runner.visualstudio" Version="3.1.4" />
  </ItemGroup>
  <ItemGroup>
    <Using Include="Xunit" />
    <ProjectReference Include="..\..\src\{Source}\{Source}.csproj" />
  </ItemGroup>
</Project>
```

## Common Patterns

### Modern C# Features

```csharp
// Records for DTOs
public record CustomerDto(int Id, string Name, string Email);

// Pattern matching
public decimal CalculateShipping(Order order) => order.Total switch
{
    < 50 => 10m,
    < 100 => 5m,
    _ => 0m
};

// Target-typed new
private readonly List<Customer> _customers = new();

// Using declarations
using var stream = File.OpenRead(path);
```

### LINQ Best Practices

```csharp
// Use AsNoTracking for read-only queries
await _dbContext.Customers.AsNoTracking().ToListAsync();

// Include to prevent N+1
await _dbContext.Orders.Include(o => o.Customer).ToListAsync();
```

## NuGet Package Versioning

### Olbrasoft Packages: Always Use Floating Versions

**CRITICAL:** Olbrasoft packages (packages we create and maintain) are ALWAYS referenced with wildcard versions to automatically get the latest version.

```xml
<!-- ✅ CORRECT: Olbrasoft packages use wildcard -->
<PackageReference Include="Olbrasoft.Data" Version="10.*" />
<PackageReference Include="Olbrasoft.Extensions" Version="1.*" />
<PackageReference Include="Olbrasoft.Testing.Xunit.Attributes" Version="1.*" />

<!-- ❌ WRONG: Never use exact versions for Olbrasoft packages -->
<PackageReference Include="Olbrasoft.Data" Version="10.0.2" />
```

**Exception:** During local testing of unpublished packages, use exact versions temporarily.

### Third-Party Packages: Use Exact Versions

```xml
<!-- Third-party packages use exact versions -->
<PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.14.1" />
<PackageReference Include="Moq" Version="4.20.72" />
<PackageReference Include="xunit" Version="2.9.3" />
```

## Anti-Patterns (NEVER Do)

| Anti-Pattern                         | Correct Approach                    |
|--------------------------------------|-------------------------------------|
| `as any`, `@ts-ignore`               | Fix the type error properly         |
| Empty catch blocks `catch(e) {}`     | Log or rethrow with context         |
| `DateTime.Now` in business logic     | Inject `ITimeProvider`              |
| Static database access               | Use dependency injection            |
| `async void` methods                 | Use `async Task`                    |
| Exact versions for Olbrasoft packages| Use floating versions (`10.*`)      |

## CI/CD

### GitHub Actions Build

```yaml
- run: dotnet restore
- run: dotnet build -c Release --no-restore
- run: dotnet test -c Release --no-build --filter "FullyQualifiedName!~IntegrationTests"
```

## See Also

- [README.md](README.md) - Handbook overview and navigation
- [C# Coding](development-guidelines/dotnet/csharp-coding-dotnet.md) - Full coding guide
- [Testing Index](development-guidelines/dotnet/testing/index-testing.md) - Test decision tree
- [SOLID Principles](development-guidelines/dotnet/solid-principles/solid-principles.md) - Modern SOLID
