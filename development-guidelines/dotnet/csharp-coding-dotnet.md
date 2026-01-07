# C# Coding Best Practices for .NET

Best practices and conventions for writing high-quality C# code in Olbrasoft projects.

## Core Principles

1. **Strong Typing** - Leverage C#'s type system for compile-time safety
2. **Async/Await** - Use asynchronous programming for I/O operations
3. **SOLID** - Follow SOLID principles (see [SOLID Principles](solid-principles/solid-principles.md))
4. **Null Safety** - Use nullable reference types to prevent null reference exceptions
5. **Testability** - Write code that is easy to unit test

## Naming Conventions

### Classes and Interfaces

```csharp
// ✅ GOOD: PascalCase for classes
public class CustomerService { }
public class OrderRepository { }

// ✅ GOOD: Interface with 'I' prefix
public interface ICustomerService { }
public interface IRepository<T> { }

// ❌ WRONG: camelCase or snake_case
public class customerService { }
public class customer_service { }
```

### Methods and Properties

```csharp
// ✅ GOOD: PascalCase for methods and properties
public string GetCustomerName() { }
public int OrderCount { get; set; }

// ✅ GOOD: Async methods with 'Async' suffix
public async Task<Customer> GetCustomerAsync(int id) { }

// ❌ WRONG: camelCase or missing Async suffix
public string getCustomerName() { }
public async Task<Customer> GetCustomer(int id) { }
```

### Variables and Parameters

```csharp
// ✅ GOOD: camelCase for local variables and parameters
public void ProcessOrder(int orderId, string customerName)
{
    var orderTotal = CalculateTotal(orderId);
    var isValid = ValidateOrder(orderId);
}

// ✅ GOOD: Private fields with underscore prefix
private readonly ILogger _logger;
private readonly IRepository<Customer> _customerRepository;

// ❌ WRONG: PascalCase for local variables
public void ProcessOrder(int OrderId, string CustomerName)
{
    var OrderTotal = CalculateTotal(OrderId);
}
```

### Constants and Enums

```csharp
// ✅ GOOD: PascalCase for constants
public const int MaxRetryCount = 3;
public const string DefaultCulture = "en-US";

// ✅ GOOD: PascalCase singular for enum names
public enum OrderStatus
{
    Pending,
    Processing,
    Completed,
    Cancelled
}

// ❌ WRONG: Plural enum names
public enum OrderStatuses { }
```

## Type Usage

### Prefer Strong Typing Over Primitives

```csharp
// ❌ WRONG: Primitive obsession
public void CreateOrder(string customerId, decimal amount, string currency) { }

// ✅ GOOD: Value objects for domain concepts
public record CustomerId(Guid Value);
public record Money(decimal Amount, Currency Currency);

public void CreateOrder(CustomerId customerId, Money total) { }
```

### Use decimal for Financial Values

```csharp
// ✅ GOOD: decimal for money
public decimal CalculateTotal(decimal price, decimal taxRate)
{
    return price * (1 + taxRate);
}

// ❌ WRONG: float or double for money (precision issues)
public float CalculateTotal(float price, float taxRate) { }
```

### Collection Types

```csharp
// ✅ GOOD: IEnumerable<T> for read-only sequences
public IEnumerable<Customer> GetCustomers() { }

// ✅ GOOD: ICollection<T> or IList<T> for modifiable collections
public IList<Order> GetOrders() { }

// ✅ GOOD: Dictionary<TKey, TValue> for key-value pairs
private readonly Dictionary<string, Customer> _customerCache = new();

// ❌ WRONG: Returning concrete types unnecessarily
public List<Customer> GetCustomers() { }
```

## Async/Await Best Practices

### Always Use Async for I/O Operations

```csharp
// ✅ GOOD: Async methods for I/O
public async Task<Customer> GetCustomerAsync(int id)
{
    return await _dbContext.Customers
        .FirstOrDefaultAsync(c => c.Id == id);
}

public async Task<string> ReadFileAsync(string path)
{
    return await File.ReadAllTextAsync(path);
}

// ❌ WRONG: Synchronous I/O blocks threads
public Customer GetCustomer(int id)
{
    return _dbContext.Customers.FirstOrDefault(c => c.Id == id);
}
```

### ConfigureAwait in Libraries

```csharp
// ✅ GOOD: ConfigureAwait(false) in library code
public async Task<Customer> GetCustomerAsync(int id)
{
    var customer = await _repository
        .GetByIdAsync(id)
        .ConfigureAwait(false);
    
    return customer;
}

// ❌ WRONG: Missing ConfigureAwait in library code (performance impact)
public async Task<Customer> GetCustomerAsync(int id)
{
    var customer = await _repository.GetByIdAsync(id);
    return customer;
}
```

### Never Use async void

```csharp
// ✅ GOOD: async Task for methods
public async Task ProcessOrderAsync(int orderId)
{
    await _orderService.ProcessAsync(orderId);
}

// ✅ GOOD: async void ONLY for event handlers
private async void Button_Click(object sender, EventArgs e)
{
    await ProcessOrderAsync(_orderId);
}

// ❌ WRONG: async void for regular methods (unhandled exceptions)
public async void ProcessOrderAsync(int orderId) { }
```

## Null Handling

### Enable Nullable Reference Types

```csharp
// ✅ GOOD: Enable in .csproj
<PropertyGroup>
    <Nullable>enable</Nullable>
</PropertyGroup>

// ✅ GOOD: Explicit nullable types
public Customer? FindCustomer(int id)
{
    return _customers.FirstOrDefault(c => c.Id == id);
}

// ✅ GOOD: Non-nullable return type with guarantee
public Customer GetCustomer(int id)
{
    var customer = _customers.FirstOrDefault(c => c.Id == id);
    return customer ?? throw new CustomerNotFoundException(id);
}
```

### Parameter Validation

```csharp
// ✅ GOOD: Validate parameters at method entry
public void ProcessOrder(Order order, Customer customer)
{
    ArgumentNullException.ThrowIfNull(order);
    ArgumentNullException.ThrowIfNull(customer);
    
    // Process...
}

// ✅ GOOD: Guard clauses for business rules
public void ApplyDiscount(Order order, decimal discountRate)
{
    ArgumentNullException.ThrowIfNull(order);
    
    if (discountRate < 0 || discountRate > 1)
        throw new ArgumentOutOfRangeException(nameof(discountRate), 
            "Discount rate must be between 0 and 1");
    
    // Apply discount...
}

// ❌ WRONG: No validation (null reference exceptions)
public void ProcessOrder(Order order, Customer customer)
{
    var total = order.Total; // May throw if order is null
}
```

## Error Handling

### Use Specific Exceptions

```csharp
// ✅ GOOD: Throw specific exceptions
public Customer GetCustomerById(int id)
{
    var customer = _repository.GetById(id);
    
    if (customer is null)
        throw new CustomerNotFoundException($"Customer {id} not found");
    
    return customer;
}

// ❌ WRONG: Generic exceptions lose context
public Customer GetCustomerById(int id)
{
    var customer = _repository.GetById(id);
    
    if (customer is null)
        throw new Exception("Customer not found");
    
    return customer;
}
```

### Result Pattern for Expected Failures

```csharp
// ✅ GOOD: Result<T> for operations that can fail expectedly
public Result<Order> CreateOrder(CreateOrderRequest request)
{
    if (!ValidateRequest(request))
        return Result<Order>.Failure("Invalid request");
    
    try
    {
        var order = _orderService.Create(request);
        return Result<Order>.Success(order);
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Failed to create order");
        return Result<Order>.Failure("Order creation failed");
    }
}

// ❌ WRONG: Exceptions for expected failures (expensive)
public Order CreateOrder(CreateOrderRequest request)
{
    if (!ValidateRequest(request))
        throw new InvalidOperationException("Invalid request");
    
    return _orderService.Create(request);
}
```

## Dependency Injection

### Constructor Injection Only

```csharp
// ✅ GOOD: Constructor injection with readonly fields
public class OrderService : IOrderService
{
    private readonly IRepository<Order> _orderRepository;
    private readonly ILogger<OrderService> _logger;
    private readonly IEventPublisher _eventPublisher;

    public OrderService(
        IRepository<Order> orderRepository,
        ILogger<OrderService> logger,
        IEventPublisher eventPublisher)
    {
        _orderRepository = orderRepository ?? throw new ArgumentNullException(nameof(orderRepository));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        _eventPublisher = eventPublisher ?? throw new ArgumentNullException(nameof(eventPublisher));
    }
}

// ❌ WRONG: Property injection (hard to test, unclear dependencies)
public class OrderService : IOrderService
{
    public IRepository<Order> OrderRepository { get; set; }
    public ILogger<OrderService> Logger { get; set; }
}
```

### Service Lifetimes

```csharp
// ✅ GOOD: Correct lifetimes in Program.cs
services.AddScoped<DbContext>(); // Scoped - per request
services.AddScoped<IOrderService, OrderService>(); // Scoped - depends on DbContext
services.AddTransient<IEmailSender, EmailSender>(); // Transient - stateless
services.AddSingleton<IMemoryCache, MemoryCache>(); // Singleton - shared state

// ❌ WRONG: DbContext as Singleton (concurrency issues)
services.AddSingleton<DbContext>();

// ❌ WRONG: Stateful service as Singleton (shared mutable state)
services.AddSingleton<OrderProcessor>(); // If OrderProcessor has mutable state
```

## Code Organization

### Keep Methods Small and Focused

```csharp
// ✅ GOOD: Small, focused methods (< 30 lines)
public async Task<Order> ProcessOrderAsync(CreateOrderRequest request)
{
    ValidateRequest(request);
    var customer = await GetCustomerAsync(request.CustomerId);
    var order = CreateOrder(request, customer);
    await SaveOrderAsync(order);
    await PublishOrderCreatedEventAsync(order);
    
    return order;
}

// ❌ WRONG: God method doing everything (> 100 lines)
public async Task<Order> ProcessOrderAsync(CreateOrderRequest request)
{
    // 100+ lines of validation, creation, calculation, saving, notifications...
}
```

### Use Expression-Bodied Members

```csharp
// ✅ GOOD: Expression-bodied members for simple operations
public class Customer
{
    public string FirstName { get; init; }
    public string LastName { get; init; }
    
    public string FullName => $"{FirstName} {LastName}";
    public bool IsActive => Status == CustomerStatus.Active;
}

public decimal CalculateDiscount(decimal total) => 
    total * DiscountRate;

// ❌ WRONG: Unnecessary blocks for simple expressions
public string FullName 
{ 
    get 
    { 
        return $"{FirstName} {LastName}"; 
    } 
}
```

### Modern C# Features

```csharp
// ✅ GOOD: Record types for DTOs and value objects
public record CustomerDto(int Id, string Name, string Email);

public record Money(decimal Amount, string Currency)
{
    public Money Add(Money other)
    {
        if (Currency != other.Currency)
            throw new InvalidOperationException("Cannot add different currencies");
        
        return this with { Amount = Amount + other.Amount };
    }
}

// ✅ GOOD: Pattern matching
public decimal CalculateShipping(Order order) => order.Total switch
{
    < 50 => 10m,
    < 100 => 5m,
    _ => 0m
};

// ✅ GOOD: Target-typed new expressions
private readonly List<Customer> _customers = new();
private readonly Dictionary<int, Order> _orders = new();

// ✅ GOOD: Using declarations (auto-dispose)
public async Task ProcessFileAsync(string path)
{
    using var stream = File.OpenRead(path);
    using var reader = new StreamReader(stream);
    
    var content = await reader.ReadToEndAsync();
    // stream and reader disposed automatically
}
```

## LINQ Best Practices

### Deferred Execution

```csharp
// ✅ GOOD: Deferred execution for flexibility
public IEnumerable<Customer> GetActiveCustomers()
{
    return _dbContext.Customers
        .Where(c => c.Status == CustomerStatus.Active);
    // Query not executed until enumerated
}

// ✅ GOOD: AsNoTracking for read-only queries
public async Task<List<Customer>> GetCustomersAsync()
{
    return await _dbContext.Customers
        .AsNoTracking()
        .ToListAsync();
}

// ❌ WRONG: N+1 query problem
public async Task<List<OrderDto>> GetOrdersAsync()
{
    var orders = await _dbContext.Orders.ToListAsync();
    
    foreach (var order in orders)
    {
        order.Customer = await _dbContext.Customers
            .FirstAsync(c => c.Id == order.CustomerId); // N+1 queries!
    }
    
    return orders;
}

// ✅ GOOD: Eager loading with Include
public async Task<List<Order>> GetOrdersAsync()
{
    return await _dbContext.Orders
        .Include(o => o.Customer)
        .Include(o => o.OrderItems)
        .ToListAsync();
}
```

## Documentation

### XML Documentation

```csharp
/// <summary>
/// Retrieves a customer by their unique identifier.
/// </summary>
/// <param name="customerId">The unique identifier of the customer.</param>
/// <param name="cancellationToken">Token to cancel the operation.</param>
/// <returns>The customer if found; otherwise, null.</returns>
/// <exception cref="ArgumentNullException">Thrown when customerId is null.</exception>
public async Task<Customer?> GetCustomerAsync(
    CustomerId customerId, 
    CancellationToken cancellationToken = default)
{
    ArgumentNullException.ThrowIfNull(customerId);
    
    return await _repository
        .GetByIdAsync(customerId, cancellationToken)
        .ConfigureAwait(false);
}
```

### Code Comments

```csharp
// ✅ GOOD: Comments explain WHY, not WHAT
public decimal CalculateDiscount(decimal total)
{
    // Apply 10% discount for orders over $100 to encourage bulk purchases
    return total > 100 ? total * 0.1m : 0m;
}

// ❌ WRONG: Comments explain obvious code
public decimal CalculateDiscount(decimal total)
{
    // Check if total is greater than 100
    if (total > 100)
    {
        // Multiply total by 0.1
        return total * 0.1m;
    }
    
    // Return 0
    return 0m;
}
```

## Performance Considerations

### String Concatenation

```csharp
// ✅ GOOD: StringBuilder for multiple concatenations
public string BuildReport(List<Order> orders)
{
    var sb = new StringBuilder();
    
    foreach (var order in orders)
    {
        sb.AppendLine($"Order {order.Id}: {order.Total:C}");
    }
    
    return sb.ToString();
}

// ❌ WRONG: String concatenation in loop (creates many objects)
public string BuildReport(List<Order> orders)
{
    var report = "";
    
    foreach (var order in orders)
    {
        report += $"Order {order.Id}: {order.Total:C}\n";
    }
    
    return report;
}
```

### Span<T> for Memory Efficiency

```csharp
// ✅ GOOD: Span<T> for stack-allocated buffers
public void ProcessData(ReadOnlySpan<byte> data)
{
    Span<byte> buffer = stackalloc byte[256];
    
    // Process without heap allocation...
}

// ✅ GOOD: Memory<T> for async operations
public async Task ProcessDataAsync(ReadOnlyMemory<byte> data)
{
    await ProcessChunkAsync(data.Slice(0, 100));
}
```

## Testing Considerations

### Testable Code Design

```csharp
// ✅ GOOD: Testable with dependency injection
public class OrderService : IOrderService
{
    private readonly IRepository<Order> _repository;
    private readonly ITimeProvider _timeProvider;

    public OrderService(
        IRepository<Order> repository,
        ITimeProvider timeProvider)
    {
        _repository = repository;
        _timeProvider = timeProvider;
    }

    public Order CreateOrder(CreateOrderRequest request)
    {
        var order = new Order
        {
            CreatedAt = _timeProvider.UtcNow, // Testable time
            // ...
        };
        
        return _repository.Add(order);
    }
}

// ❌ WRONG: Hard to test (static dependencies)
public class OrderService
{
    public Order CreateOrder(CreateOrderRequest request)
    {
        var order = new Order
        {
            CreatedAt = DateTime.UtcNow, // Can't mock
            // ...
        };
        
        return Database.Orders.Add(order); // Static dependency
    }
}
```

## See Also

- [SOLID Principles](solid-principles/solid-principles.md) - Modern SOLID interpretation
- [Design Patterns](design-patterns/index-design-patterns.md) - GoF, Enterprise, Cloud patterns
- [Testing Guide](testing/index-testing.md) - Unit and integration testing
- [Project Structure](project-structure-dotnet.md) - Project organization
