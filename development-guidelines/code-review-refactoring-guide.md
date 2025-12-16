# Code Review and Refactoring Guide for .NET/C#

Complete guide for conducting code reviews and refactoring in .NET/C# projects, aligned with Microsoft recommendations and industry best practices for 2025.

> **Sources:** This guide is based on [Microsoft's Engineering Fundamentals Playbook](https://microsoft.github.io/code-with-engineering-playbook/code-reviews/recipes/csharp/), [Microsoft C# Coding Conventions](https://learn.microsoft.com/dotnet/csharp/fundamentals/coding-style/coding-conventions), and [Framework Design Guidelines](https://learn.microsoft.com/dotnet/standard/design-guidelines/).

---

## Code Review Process

### Purpose of Code Review

1. **Find bugs early** - Catch issues before they reach production
2. **Knowledge sharing** - Spread understanding of the codebase
3. **Maintain consistency** - Ensure code follows team standards
4. **Improve design** - Identify architectural improvements
5. **Documentation** - Create a record of design decisions

### Review Mindset

| Role | Focus |
|------|-------|
| **Author** | Be open to feedback, explain context, respond promptly |
| **Reviewer** | Be constructive, ask questions, focus on issues not style |

---

## Code Review Checklist

### 1. SOLID Principles

| Principle | What to Check |
|-----------|---------------|
| **Single Responsibility (SRP)** | Does the class/method have only ONE reason to change? |
| **Open/Closed (OCP)** | Can behavior be extended without modifying existing code? |
| **Liskov Substitution (LSP)** | Can derived classes be used in place of base classes? |
| **Interface Segregation (ISP)** | Are interfaces small and focused? No "fat" interfaces? |
| **Dependency Inversion (DIP)** | Does code depend on abstractions, not concrete implementations? |

**Red Flags:**
- Class with 500+ lines of code
- Method with 50+ lines of code
- Class name contains "Manager", "Helper", "Utility", "Common"
- Method with 5+ parameters
- Constructor with 5+ dependencies

### 2. Naming Conventions (Microsoft Style)

| Element | Convention | Example |
|---------|------------|---------|
| Classes, Structs, Interfaces | PascalCase | `CustomerService`, `IOrderRepository` |
| Methods | PascalCase | `GetCustomerById()` |
| Public Properties | PascalCase | `FirstName`, `IsActive` |
| Private Fields | _camelCase | `_customerRepository` |
| Local Variables | camelCase | `orderTotal`, `isValid` |
| Parameters | camelCase | `customerId`, `orderDate` |
| Constants | PascalCase | `MaxRetryCount`, `DefaultTimeout` |
| Interfaces | I + PascalCase | `IDisposable`, `IUserService` |
| Async Methods | Suffix "Async" | `GetDataAsync()`, `SaveAsync()` |

**Naming Quality:**
- Names should reveal intent: `GetActiveCustomers()` not `GetData()`
- Avoid abbreviations: `customer` not `cust`
- Be consistent: Don't mix `Get`, `Fetch`, `Retrieve` for same concept

### 3. Code Quality

#### Async/Await
- [ ] Is `await` used correctly (not `.Result` or `.Wait()`)?
- [ ] Are `CancellationToken` parameters provided where needed?
- [ ] Is `Task.WhenAll` used for parallel operations?
- [ ] Does async method name end with `Async` suffix?

#### Exception Handling
- [ ] Are specific exceptions caught (not `catch (Exception)`)?
- [ ] Is exception information preserved when re-throwing?
- [ ] Are exceptions logged with sufficient context?
- [ ] Is the `using` pattern used for `IDisposable` objects?

#### Dependency Injection
- [ ] Is DI used instead of `new` for dependencies?
- [ ] Are services registered with correct lifetime (Singleton/Scoped/Transient)?
- [ ] Are interfaces used for dependencies, not concrete classes?

#### Performance
- [ ] Is LINQ used appropriately (not for simple loops)?
- [ ] Are there potential memory allocation issues (boxing, short-lived objects)?
- [ ] Are database queries optimized (N+1 problem, missing indexes)?
- [ ] Is `StringBuilder` used for string concatenation in loops?

### 4. Architecture & Design

| Aspect | Questions to Ask |
|--------|------------------|
| **Coupling** | Is code loosely coupled? Can components be replaced? |
| **Cohesion** | Do related things stay together? |
| **Testability** | Can this code be unit tested easily? |
| **Extensibility** | Can new features be added without modifying existing code? |

#### Design Patterns to Look For

**Creational:**
- Factory Pattern for object creation
- Builder for complex object construction

**Structural:**
- Adapter for integrating external APIs
- Decorator for adding behavior

**Behavioral:**
- Strategy for interchangeable algorithms
- Observer for event-driven communication

### 5. Security

- [ ] Is input validated and sanitized?
- [ ] Are SQL queries parameterized (no string concatenation)?
- [ ] Are secrets stored securely (User Secrets, Key Vault)?
- [ ] Is sensitive data logged appropriately?
- [ ] Are authentication/authorization checks in place?

---

## Unit Test Coverage

### Recommended Coverage Targets

| Project Type | Minimum Coverage | Target Coverage |
|--------------|------------------|-----------------|
| Business Logic | 80% | 90%+ |
| Data Access | 70% | 80% |
| Controllers/API | 60% | 70% |
| UI Components | 50% | 60% |

> **Industry Standard:** 80% code coverage is the commonly accepted goal for corporate projects. Microsoft's own documentation mentions maintaining 90% coverage as an example.

### Coverage Quality vs Quantity

**Important:** High coverage doesn't guarantee quality tests!

```
BAD (100% coverage, 0% value):
[Fact]
public void Test()
{
    var service = new MyService();
    service.DoSomething(); // No assertions!
}

GOOD (meaningful test):
[Fact]
public void CalculateTotal_WithDiscount_ReturnsReducedPrice()
{
    var calculator = new PriceCalculator();
    
    var result = calculator.CalculateTotal(100, discount: 0.1m);
    
    Assert.Equal(90, result);
}
```

### Test Naming Convention

```
[Method]_[Scenario]_[ExpectedResult]
```

**Examples:**
- `GetCustomer_WithValidId_ReturnsCustomer`
- `CreateOrder_WithEmptyCart_ThrowsException`
- `CalculateDiscount_ForPremiumMember_Returns20Percent`

### Arrange-Act-Assert Pattern

```csharp
[Fact]
public void Add_TwoNumbers_ReturnsSum()
{
    // Arrange
    var calculator = new Calculator();
    
    // Act
    var result = calculator.Add(2, 3);
    
    // Assert
    Assert.Equal(5, result);
}
```

---

## Refactoring Guidelines

### When to Refactor

| Trigger | Action |
|---------|--------|
| Code smell detected | Refactor immediately |
| Adding new feature | Refactor first, then add feature |
| Fixing bug | Refactor to prevent similar bugs |
| Code review feedback | Refactor before merging |

### Common Code Smells

| Smell | Solution |
|-------|----------|
| **Long Method** (50+ lines) | Extract methods |
| **Large Class** (500+ lines) | Split into smaller classes |
| **Duplicate Code** | Extract to shared method/class |
| **Magic Numbers** | Replace with named constants |
| **Deep Nesting** (3+ levels) | Early returns, extract methods |
| **God Class** | Apply Single Responsibility |
| **Feature Envy** | Move method to the class it uses most |
| **Primitive Obsession** | Create value objects |

### Safe Refactoring Steps

1. **Ensure tests exist** - Never refactor without test coverage
2. **Make small changes** - One refactoring at a time
3. **Run tests frequently** - After each small change
4. **Commit often** - Small, focused commits
5. **Review your own changes** - Before submitting for review

### Refactoring Techniques

#### Extract Method
```csharp
// Before
public void ProcessOrder(Order order)
{
    // Validate
    if (order == null) throw new ArgumentNullException(nameof(order));
    if (order.Items.Count == 0) throw new InvalidOperationException("Empty order");
    
    // Calculate
    var total = order.Items.Sum(i => i.Price * i.Quantity);
    var tax = total * 0.21m;
    
    // Save
    _repository.Save(order);
}

// After
public void ProcessOrder(Order order)
{
    ValidateOrder(order);
    var total = CalculateTotal(order);
    _repository.Save(order);
}

private void ValidateOrder(Order order) { ... }
private decimal CalculateTotal(Order order) { ... }
```

#### Replace Conditional with Polymorphism
```csharp
// Before
public decimal CalculateDiscount(Customer customer)
{
    switch (customer.Type)
    {
        case CustomerType.Regular: return 0.05m;
        case CustomerType.Premium: return 0.15m;
        case CustomerType.VIP: return 0.25m;
        default: return 0;
    }
}

// After
public interface IDiscountStrategy
{
    decimal GetDiscount();
}

public class RegularDiscount : IDiscountStrategy
{
    public decimal GetDiscount() => 0.05m;
}
```

---

## Code Analysis Tools

### Required Analyzers

Add to your projects via `common.props`:

```xml
<ItemGroup>
    <PackageReference Include="Microsoft.CodeAnalysis.NetAnalyzers" Version="9.0.0">
        <PrivateAssets>all</PrivateAssets>
        <IncludeAssets>runtime; build; native; contentfiles; analyzers</IncludeAssets>
    </PackageReference>
    <PackageReference Include="StyleCop.Analyzers" Version="1.2.0-beta.556">
        <PrivateAssets>all</PrivateAssets>
        <IncludeAssets>runtime; build; native; contentfiles; analyzers</IncludeAssets>
    </PackageReference>
</ItemGroup>

<PropertyGroup>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <EnforceCodeStyleInBuild>true</EnforceCodeStyleInBuild>
</PropertyGroup>
```

### EditorConfig

Use `.editorconfig` to enforce style rules across the team:

```ini
[*.cs]
# Naming
dotnet_naming_rule.private_fields_should_be_camel_case.severity = error
dotnet_naming_style.camel_case_underscore.required_prefix = _
dotnet_naming_style.camel_case_underscore.capitalization = camel_case

# Code style
csharp_style_var_for_built_in_types = false:warning
csharp_prefer_braces = true:error
```

---

## Review Checklist Summary

### Before Submitting for Review

- [ ] Code compiles without warnings
- [ ] All tests pass
- [ ] New code has tests (80%+ coverage)
- [ ] No hardcoded secrets or connection strings
- [ ] SOLID principles followed
- [ ] Naming conventions followed
- [ ] No magic numbers/strings
- [ ] Async methods named correctly
- [ ] Exception handling is specific
- [ ] Resources are disposed properly

### During Review

- [ ] Does the code do what it claims?
- [ ] Is the logic correct?
- [ ] Are edge cases handled?
- [ ] Is the code readable?
- [ ] Could this be simpler?
- [ ] Are there security concerns?
- [ ] Are there performance concerns?

---

## References

- [Microsoft C# Coding Conventions](https://learn.microsoft.com/dotnet/csharp/fundamentals/coding-style/coding-conventions)
- [Microsoft C# Naming Conventions](https://learn.microsoft.com/dotnet/csharp/fundamentals/coding-style/identifier-names)
- [Microsoft Unit Testing Best Practices](https://learn.microsoft.com/dotnet/core/testing/unit-testing-best-practices)
- [Microsoft Engineering Fundamentals - C# Code Reviews](https://microsoft.github.io/code-with-engineering-playbook/code-reviews/recipes/csharp/)
- [Framework Design Guidelines](https://learn.microsoft.com/dotnet/standard/design-guidelines/)
- [SOLID Principles Guide](../solid-principles/solid-principles-2025.md)
- [Design Patterns Guide](../design-patterns/gof-design-patterns-2025.md)
