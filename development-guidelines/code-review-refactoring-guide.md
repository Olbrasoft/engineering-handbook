# Code Review and Refactoring Guide for .NET/C#

Complete guide for conducting code reviews and refactoring in .NET/C# projects, aligned with Microsoft recommendations and industry best practices for 2025.

> **Sources:** This guide is based on [Microsoft's Engineering Fundamentals Playbook](https://microsoft.github.io/code-with-engineering-playbook/code-reviews/recipes/csharp/), [Microsoft C# Coding Conventions](https://learn.microsoft.com/dotnet/csharp/fundamentals/coding-style/coding-conventions), and [Framework Design Guidelines](https://learn.microsoft.com/dotnet/standard/design-guidelines/).

---

## Code Review Process

### Purpose of Code Review

1. **Find bugs early** - Catch issues before they cause problems
2. **Improve design** - Identify architectural improvements
3. **Learn and improve** - Each review teaches something new
4. **Documentation** - Create a record of design decisions
5. **Maintain consistency** - Ensure code follows standards

### Self-Review (Solo Development)

When working alone or with AI assistance, you are your own reviewer:

| Before Commit | Ask Yourself |
|---------------|--------------|
| **Read the diff** | Does every change make sense? |
| **Explain it** | Could I explain this to someone else? |
| **Sleep on it** | Does it still look good tomorrow? |
| **Run it** | Did I actually test this works? |

**The "Fresh Eyes" technique:**
- Take a 15-minute break before reviewing your own code
- Read the code as if you didn't write it
- Ask: "What would confuse me if I saw this in 6 months?"

### AI-Assisted Review

When using AI (Claude, Copilot) for code review:

| Good for | Less reliable for |
|----------|-------------------|
| Catching obvious bugs | Business logic correctness |
| Naming suggestions | Architecture decisions |
| Finding code smells | Performance in your specific context |
| Suggesting refactoring | Understanding your domain |
| Security pattern checks | "Does this actually work?" |

**Best practice:** Use AI as a second pair of eyes, but always verify suggestions make sense for your context.

---

## Branch & Commit Guidelines

### When to Use Branches

For solo development, branches are useful for:

| Situation | Use Branch? | Why |
|-----------|-------------|-----|
| Large feature (multi-day) | ✅ Yes | Keep main working while you experiment |
| Risky experiment | ✅ Yes | Easy to abandon if it doesn't work |
| Quick bug fix | ❌ No | Just commit to main |
| Small improvement | ❌ No | Not worth the overhead |
| "I want to save this state" | ✅ Yes | Create branch as a "checkpoint" |

### Practical Branch Strategy

```
main (always working)
  │
  ├── feature/voice-recognition  ← big feature, might break things
  │
  ├── experiment/new-ai-model    ← trying something, might abandon
  │
  └── backup/before-refactor     ← checkpoint before risky change
```

**Simple rules:**
- `main` should always work
- Branch when you're not sure something will work
- Delete branches when merged or abandoned

### Commit Size

Even solo, good commit hygiene helps:

| Commit Type | Size | Example |
|-------------|------|---------|
| **Atomic** | 1 logical change | "Add customer validation" |
| **Too big** | Multiple unrelated changes | "Various fixes and improvements" ❌ |
| **Too small** | Incomplete change | "WIP" ❌ |

**Why it matters for solo dev:**
- Easier to find when bug was introduced (`git bisect`)
- Easier to revert specific changes
- Better history for future reference

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

#### Architecture Impact Assessment

Before committing larger changes, ask:

| Question | Why it matters |
|----------|----------------|
| How will this look in 6 months? | Prevents short-term thinking |
| Does this increase or decrease complexity? | Small complexities add up |
| Can I understand this after a break? | Tests maintainability |
| What breaks if I need to change this? | Identifies coupling |
| Is this the right layer for this logic? | Ensures proper separation |

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

> **Industry Standard:** 80% code coverage is the commonly accepted goal. Going from 80% to 100% requires disproportionate effort that's usually better spent elsewhere.

### Coverage Quality vs Quantity

> ⚠️ **Critical:** 100% coverage does NOT mean bug-free code. An app with 50k lines can have hundreds of bugs even at 100% coverage.

**What coverage number tells you:**
- ✅ Which code paths were executed
- ❌ Whether assertions are meaningful
- ❌ Whether edge cases are covered
- ❌ Whether tests verify correct behavior

**Test review checklist:**
- [ ] Does the test have meaningful assertions (not just `Assert.NotNull`)?
- [ ] Are edge cases covered (null, empty, boundary values)?
- [ ] Does the test name describe the expected behavior?
- [ ] Is the test independent (no reliance on other tests)?
- [ ] Would the test fail if the code was wrong?

### Test Anti-Patterns to Avoid

```csharp
// ❌ No assertion - test always passes
[Fact]
public void ProcessOrder_DoesNotThrow()
{
    var service = new OrderService();
    service.ProcessOrder(new Order()); // No Assert!
}

// ❌ Testing implementation, not behavior
[Fact]
public void GetCustomer_CallsRepository()
{
    _mockRepo.Verify(r => r.GetById(It.IsAny<int>()), Times.Once);
    // Doesn't verify the RESULT is correct
}

// ✅ Good - tests behavior and result
[Fact]
public void GetCustomer_WithValidId_ReturnsCustomerWithCorrectData()
{
    var result = _service.GetCustomer(123);
    
    Assert.NotNull(result);
    Assert.Equal(123, result.Id);
    Assert.Equal("John", result.Name);
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
| Before commit | Clean up while it's fresh in mind |

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
5. **Review your changes** - Read the diff before pushing

### Classic Refactoring Techniques

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

### Modern C# Refactoring Techniques

#### Primary Constructors (C# 12)

```csharp
// Before - 15 lines
public class CustomerService
{
    private readonly IRepository _repository;
    private readonly ILogger _logger;

    public CustomerService(IRepository repository, ILogger logger)
    {
        _repository = repository;
        _logger = logger;
    }
}

// After - 1 line
public class CustomerService(IRepository repository, ILogger logger)
{
    // Use repository and logger directly
}
```

#### Records for Immutable Data

```csharp
// Before - 20+ lines with Equals, GetHashCode, ToString
public class CustomerDto
{
    public int Id { get; init; }
    public string Name { get; init; }
    public string Email { get; init; }
}

// After - 1 line, includes equality, deconstruction, ToString
public record CustomerDto(int Id, string Name, string Email);
```

#### Collection Expressions (C# 12)

```csharp
// Before
var list = new List<int> { 1, 2, 3 };
var array = new int[] { 1, 2, 3 };
var empty = Array.Empty<string>();

// After
List<int> list = [1, 2, 3];
int[] array = [1, 2, 3];
string[] empty = [];
```

#### File-Scoped Namespaces

```csharp
// Before - extra indentation level
namespace MyApp.Services
{
    public class MyService
    {
        // ...
    }
}

// After - cleaner, less nesting
namespace MyApp.Services;

public class MyService
{
    // ...
}
```

#### Pattern Matching

```csharp
// Before
if (obj is Customer)
{
    var customer = (Customer)obj;
    ProcessCustomer(customer);
}

// After
if (obj is Customer customer)
{
    ProcessCustomer(customer);
}

// Switch expressions
var discount = customer.Type switch
{
    CustomerType.Regular => 0.05m,
    CustomerType.Premium => 0.15m,
    CustomerType.VIP => 0.25m,
    _ => 0m
};
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

Use `.editorconfig` to enforce style rules automatically:

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

## Quick Self-Review Checklist

### Before Every Commit

- [ ] Code compiles without warnings
- [ ] All tests pass
- [ ] I've read the diff - every change makes sense
- [ ] No hardcoded secrets or connection strings
- [ ] No `Console.WriteLine` debugging left behind
- [ ] No commented-out code

### For Larger Changes

- [ ] New code has tests (aim for 80%)
- [ ] SOLID principles followed
- [ ] Naming conventions followed
- [ ] No magic numbers/strings
- [ ] Could I understand this in 6 months?
- [ ] Does this increase or decrease overall complexity?

### Before Pushing

- [ ] Did I actually run and test this?
- [ ] Is the commit message clear?
- [ ] Would I be comfortable explaining this change?

---

## References

- [Microsoft C# Coding Conventions](https://learn.microsoft.com/dotnet/csharp/fundamentals/coding-style/coding-conventions)
- [Microsoft C# Naming Conventions](https://learn.microsoft.com/dotnet/csharp/fundamentals/coding-style/identifier-names)
- [Microsoft Unit Testing Best Practices](https://learn.microsoft.com/dotnet/core/testing/unit-testing-best-practices)
- [Microsoft Engineering Fundamentals - C# Code Reviews](https://microsoft.github.io/code-with-engineering-playbook/code-reviews/recipes/csharp/)
- [Framework Design Guidelines](https://learn.microsoft.com/dotnet/standard/design-guidelines/)
- [Google Engineering Practices - Code Review](https://google.github.io/eng-practices/review/)
- [SOLID Principles Guide](../solid-principles/solid-principles-2025.md)
- [Design Patterns Guide](../design-patterns/gof-design-patterns-2025.md)
