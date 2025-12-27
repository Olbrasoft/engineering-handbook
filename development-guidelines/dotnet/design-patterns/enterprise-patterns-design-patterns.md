# Enterprise Application Patterns

Martin Fowler's patterns for building enterprise applications: domain logic, data access, web presentation, and distribution.

## Overview

**Source**: "Patterns of Enterprise Application Architecture" by Martin Fowler (2002)

Enterprise applications handle complex business logic, data persistence, web interfaces, and distributed communication. These patterns address common challenges in building such systems.

**Catalog**: 50+ patterns organized by category:
- Domain Logic Patterns
- Data Source Patterns
- Object-Relational Behavioral Patterns
- Object-Relational Structural Patterns
- Web Presentation Patterns
- Distribution Patterns
- Concurrency Patterns
- Session State Patterns
- Base Patterns

**Source**: [Martin Fowler's Catalog](https://martinfowler.com/eaaCatalog/)

## Domain Logic Patterns

### Transaction Script

Organizes business logic by procedures where each procedure handles a single request.

**When to use**:
- Simple domain logic
- CRUD operations
- Rapid prototyping

**Example (.NET)**:
```csharp
public class OrderService
{
    public void PlaceOrder(int customerId, List<OrderItem> items)
    {
        // 1. Validate customer
        var customer = _customerRepository.GetById(customerId);
        if (customer == null) throw new Exception("Customer not found");

        // 2. Calculate total
        decimal total = items.Sum(i => i.Price * i.Quantity);

        // 3. Check credit limit
        if (customer.CreditLimit < total) throw new Exception("Credit limit exceeded");

        // 4. Create order
        var order = new Order { CustomerId = customerId, Total = total };
        _orderRepository.Insert(order);

        // 5. Reserve inventory
        foreach (var item in items)
        {
            _inventoryService.ReserveStock(item.ProductId, item.Quantity);
        }
    }
}
```

**Modern usage**: Still common in simple applications, microservices with focused responsibilities.

### Domain Model

An object model of the domain that incorporates both behavior and data.

**When to use**:
- Complex business logic
- Rich domain with many business rules
- Long-term maintainability is critical

**Example (.NET)**:
```csharp
public class Order
{
    public int Id { get; private set; }
    public Customer Customer { get; private set; }
    public List<OrderLine> Lines { get; private set; } = new();
    public OrderStatus Status { get; private set; }

    public void AddLine(Product product, int quantity)
    {
        if (Status != OrderStatus.Draft)
            throw new InvalidOperationException("Cannot modify submitted order");

        var line = new OrderLine(product, quantity);
        Lines.Add(line);
    }

    public void Submit()
    {
        if (!Lines.Any())
            throw new InvalidOperationException("Cannot submit empty order");

        if (!Customer.CanAfford(GetTotal()))
            throw new InvalidOperationException("Customer credit limit exceeded");

        Status = OrderStatus.Submitted;
    }

    public decimal GetTotal() => Lines.Sum(l => l.GetSubtotal());
}
```

**Modern usage**: ★★★★★ - Core of Domain-Driven Design (DDD), recommended for complex domains.

### Service Layer

Defines an application's boundary with a layer of services that establishes available operations and coordinates responses.

**When to use**:
- Need clear API boundary
- Multiple clients (web, mobile, API)
- Transaction management

**Example (.NET)**:
```csharp
public interface IOrderService
{
    Task<OrderDto> CreateOrderAsync(CreateOrderRequest request);
    Task<OrderDto> GetOrderAsync(int orderId);
    Task CancelOrderAsync(int orderId);
}

public class OrderService : IOrderService
{
    private readonly IOrderRepository _orderRepository;
    private readonly IUnitOfWork _unitOfWork;

    public async Task<OrderDto> CreateOrderAsync(CreateOrderRequest request)
    {
        var order = new Order(request.CustomerId);
        foreach (var item in request.Items)
        {
            var product = await _productRepository.GetByIdAsync(item.ProductId);
            order.AddLine(product, item.Quantity);
        }

        order.Submit();
        await _orderRepository.AddAsync(order);
        await _unitOfWork.CommitAsync();

        return _mapper.Map<OrderDto>(order);
    }
}
```

**Modern usage**: ★★★★★ - Standard in ASP.NET Core, Spring Boot, and most web frameworks.

## Data Source Architectural Patterns

### Repository

Mediates between domain and data mapping layers using a collection-like interface.

**When to use**:
- Domain Model pattern
- Need to abstract data access
- Want to test domain logic without database

**Example (.NET)**:
```csharp
public interface IOrderRepository
{
    Task<Order> GetByIdAsync(int id);
    Task<List<Order>> GetByCustomerAsync(int customerId);
    Task AddAsync(Order order);
    Task UpdateAsync(Order order);
    Task DeleteAsync(int id);
}

public class OrderRepository : IOrderRepository
{
    private readonly DbContext _context;

    public async Task<Order> GetByIdAsync(int id)
    {
        return await _context.Orders
            .Include(o => o.Lines)
            .ThenInclude(l => l.Product)
            .FirstOrDefaultAsync(o => o.Id == id);
    }
}
```

**Modern usage**: ★★★★★ - Standard pattern with EF Core, widely adopted.

### Data Mapper

A layer of mappers that moves data between objects and database while keeping them independent.

**When to use**:
- Domain model independent from database schema
- Complex object-relational mapping
- Database schema differs from domain model

**Example (.NET with EF Core)**:
```csharp
public class OrderConfiguration : IEntityTypeConfiguration<Order>
{
    public void Configure(EntityTypeBuilder<Order> builder)
    {
        builder.ToTable("Orders");
        builder.HasKey(o => o.Id);

        builder.Property(o => o.Total)
            .HasColumnType("decimal(18,2)")
            .IsRequired();

        builder.HasMany(o => o.Lines)
            .WithOne()
            .HasForeignKey("OrderId")
            .OnDelete(DeleteBehavior.Cascade);
    }
}
```

**Modern usage**: ★★★★★ - EF Core, Hibernate, Dapper all implement this pattern.

### Active Record

An object that wraps a database row, encapsulates database access, and adds domain logic.

**When to use**:
- Simple domain logic
- One-to-one mapping between objects and tables
- Rapid development (Rails-style)

**Example (Rails-like in C#)**:
```csharp
public class Customer : ActiveRecordBase<Customer>
{
    public int Id { get; set; }
    public string Name { get; set; }
    public decimal CreditLimit { get; set; }

    public void UpdateCreditLimit(decimal newLimit)
    {
        CreditLimit = newLimit;
        this.Save(); // Built-in persistence method
    }

    public static Customer FindByEmail(string email)
    {
        return Query().Where(c => c.Email == email).FirstOrDefault();
    }
}
```

**Modern usage**: ★★☆☆☆ - Less common in C#/.NET, popular in Ruby on Rails.

## Object-Relational Behavioral Patterns

### Unit of Work

Maintains a list of objects affected by a business transaction and coordinates writing changes.

**When to use**:
- Need transactional consistency
- Multiple repository operations in one transaction
- Want to batch database updates

**Example (.NET)**:
```csharp
public interface IUnitOfWork : IDisposable
{
    IOrderRepository Orders { get; }
    ICustomerRepository Customers { get; }
    Task<int> CommitAsync();
    Task RollbackAsync();
}

public class UnitOfWork : IUnitOfWork
{
    private readonly DbContext _context;

    public IOrderRepository Orders { get; }
    public ICustomerRepository Customers { get; }

    public async Task<int> CommitAsync()
    {
        return await _context.SaveChangesAsync();
    }
}
```

**Modern usage**: ★★★★★ - Built into EF Core's DbContext, widely used.

### Identity Map

Ensures each object gets loaded only once by keeping every loaded object in a map.

**When to use**:
- Prevent duplicate object instances
- Maintain object identity within transaction
- Improve performance with caching

**Modern usage**: ★★★★☆ - Built into EF Core change tracker, Hibernate session cache.

### Lazy Load

An object that doesn't contain all data but knows how to get it when needed.

**Example (.NET with EF Core)**:
```csharp
public class Order
{
    public int Id { get; set; }
    public virtual List<OrderLine> Lines { get; set; } // virtual enables lazy loading
}

// Usage
var order = await context.Orders.FindAsync(orderId);
// Lines not loaded yet
var total = order.Lines.Sum(l => l.Total); // NOW Lines are loaded
```

**Modern usage**: ★★★★★ - Standard in ORMs (EF Core, Hibernate), but beware N+1 queries.

## Web Presentation Patterns

### Model View Controller (MVC)

Splits user interface into three distinct roles: Model, View, Controller.

**Modern usage**: ★★★★★ - ASP.NET Core MVC, Spring MVC, Angular/React (frontend MV*)

### Front Controller

A controller that handles all requests for a website.

**Example (ASP.NET Core)**:
```csharp
public class Startup
{
    public void Configure(IApplicationBuilder app)
    {
        app.UseRouting();
        app.UseEndpoints(endpoints =>
        {
            endpoints.MapControllers(); // Front controller routing
        });
    }
}
```

**Modern usage**: ★★★★★ - Standard in ASP.NET Core, Spring Boot.

## Distribution Patterns

### Remote Facade

Provides coarse-grained facade on fine-grained objects to improve efficiency over network.

**When to use**:
- Microservices communication
- Need to reduce network round-trips
- API Gateway pattern

**Example (.NET)**:
```csharp
// Fine-grained domain objects
public class Order { /* many properties and methods */ }
public class Customer { /* many properties and methods */ }

// Coarse-grained facade for remote clients
public class OrderFacade
{
    public OrderSummaryDto GetOrderSummary(int orderId)
    {
        var order = _orderService.GetOrder(orderId);
        var customer = _customerService.GetCustomer(order.CustomerId);
        var items = _orderService.GetOrderItems(orderId);

        // Single DTO with all data - one network call instead of three
        return new OrderSummaryDto
        {
            OrderId = order.Id,
            OrderDate = order.Date,
            CustomerName = customer.Name,
            Items = items.Select(i => new ItemDto { /* ... */ }).ToList(),
            Total = order.Total
        };
    }
}
```

**Modern usage**: ★★★★★ - Essential for microservices, GraphQL APIs.

### Data Transfer Object (DTO)

An object that carries data between processes to reduce method calls.

**Example (.NET)**:
```csharp
public class CreateOrderDto
{
    public int CustomerId { get; set; }
    public List<OrderItemDto> Items { get; set; }
}

public class OrderItemDto
{
    public int ProductId { get; set; }
    public int Quantity { get; set; }
}
```

**Modern usage**: ★★★★★ - Standard in ASP.NET Core APIs, REST/gRPC services.

## Concurrency Patterns

### Optimistic Offline Lock

Prevents conflicts by detecting conflict and rolling back transaction.

**Example (.NET with EF Core)**:
```csharp
public class Order
{
    public int Id { get; set; }
    [Timestamp] // Optimistic concurrency token
    public byte[] RowVersion { get; set; }
}

// On update
try
{
    await context.SaveChangesAsync();
}
catch (DbUpdateConcurrencyException)
{
    // Someone else modified the order - handle conflict
}
```

**Modern usage**: ★★★★☆ - Standard in distributed systems, EF Core `[Timestamp]`.

### Pessimistic Offline Lock

Prevents conflicts by allowing only one business transaction at a time to access data.

**Modern usage**: ★★★☆☆ - Used in critical sections, database row-level locks.

## Modern Relevance (2025)

### Still Highly Relevant

- **Service Layer** (★★★★★) - Core of ASP.NET Core, Spring Boot
- **Repository** (★★★★★) - Standard with EF Core
- **Unit of Work** (★★★★★) - Built into EF Core DbContext
- **Domain Model** (★★★★★) - Foundation of DDD
- **DTO** (★★★★★) - Essential for APIs
- **MVC** (★★★★★) - Web framework standard

### Framework-Implemented

- **Data Mapper** - EF Core configurations
- **Identity Map** - EF Core change tracker
- **Lazy Load** - EF Core virtual properties

### Less Common Today

- **Active Record** - Prefer Repository + Domain Model
- **Transaction Script** - Only for simple CRUD
- **Table Module** - Rarely used in modern .NET

## See Also

- [GoF Patterns](gof-patterns-design-patterns.md) - Object-oriented design patterns
- [Microservices Patterns](microservices-patterns-design-patterns.md) - Distributed systems patterns
- [Architecture Patterns](architectural-patterns-design-patterns.md) - System organization patterns
- [SOLID Principles](../solid-principles/solid-principles.md) - Design principles

## References

- [Martin Fowler's Catalog](https://martinfowler.com/eaaCatalog/) - Official pattern catalog
- "Patterns of Enterprise Application Architecture" by Martin Fowler (2002)
