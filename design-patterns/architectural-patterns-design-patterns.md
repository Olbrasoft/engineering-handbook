# Architectural Patterns

High-level patterns for organizing system structure: layering, clean architecture, hexagonal architecture, event-driven architecture.

## Overview

Architectural patterns define the fundamental organization of a software system:
- **Structure** - How components are organized
- **Responsibilities** - What each layer/component does
- **Dependencies** - Direction of dependencies between layers

**Key patterns**: Layered, Clean Architecture, Hexagonal (Ports & Adapters), Event-Driven, Microservices.

## Layered Architecture (N-Tier)

Organize system into horizontal layers, each with specific responsibility.

**Classic 3-tier**:
- **Presentation Layer** - UI, controllers
- **Business Logic Layer** - Domain logic, services
- **Data Access Layer** - Repositories, database

**Dependency direction**: Top → Bottom (Presentation depends on Business, Business depends on Data)

**Example (.NET)**:

```
MyApp.Web/               # Presentation Layer
  Controllers/
    OrderController.cs

MyApp.Core/              # Business Logic Layer
  Services/
    OrderService.cs
  Models/
    Order.cs

MyApp.Data/              # Data Access Layer
  Repositories/
    OrderRepository.cs
  DbContext.cs
```

**Code example**:

```csharp
// Presentation Layer
[ApiController]
[Route("api/orders")]
public class OrderController : ControllerBase
{
    private readonly IOrderService _orderService;

    [HttpPost]
    public async Task<IActionResult> CreateOrder(CreateOrderDto dto)
    {
        var order = await _orderService.CreateOrderAsync(dto);
        return Ok(order);
    }
}

// Business Logic Layer
public class OrderService : IOrderService
{
    private readonly IOrderRepository _orderRepository;

    public async Task<Order> CreateOrderAsync(CreateOrderDto dto)
    {
        var order = new Order
        {
            CustomerId = dto.CustomerId,
            // Business logic
        };

        await _orderRepository.AddAsync(order);
        return order;
    }
}

// Data Access Layer
public class OrderRepository : IOrderRepository
{
    private readonly AppDbContext _context;

    public async Task AddAsync(Order order)
    {
        await _context.Orders.AddAsync(order);
        await _context.SaveChangesAsync();
    }
}
```

**Pros**:
- Simple to understand
- Clear separation of concerns
- Easy to test each layer

**Cons**:
- Business logic depends on data layer (coupling)
- Database-driven design (domain model shaped by database)
- Hard to swap infrastructure (e.g., change database)

**Modern usage**: ★★★★☆ - Still common for simple applications, but Clean Architecture preferred for complex systems.

## Clean Architecture (Onion Architecture)

Dependency Inversion - business logic in center, infrastructure on outside.

**Layers (inside → out)**:
1. **Domain/Entities** - Core business objects (no dependencies)
2. **Use Cases/Application** - Application logic, interfaces for infrastructure
3. **Interface Adapters** - Controllers, presenters, gateways
4. **Frameworks & Drivers** - Web, database, external services

**Dependency Rule**: Dependencies point **inward**. Inner layers know nothing about outer layers.

**Example (.NET)**:

```
MyApp.Domain/            # Layer 1: Core domain
  Entities/
    Order.cs
  ValueObjects/
    Money.cs

MyApp.Application/       # Layer 2: Use cases
  UseCases/
    CreateOrder/
      CreateOrderCommand.cs
      CreateOrderHandler.cs
  Interfaces/            # Interfaces for infrastructure
    IOrderRepository.cs
    IEmailService.cs

MyApp.Infrastructure/    # Layer 3-4: Implementations
  Persistence/
    OrderRepository.cs   # Implements IOrderRepository
    AppDbContext.cs
  Email/
    SmtpEmailService.cs  # Implements IEmailService

MyApp.Web/               # Layer 3: API/Controllers
  Controllers/
    OrderController.cs
```

**Dependency direction**:

```
Web → Application → Domain
  ↓
Infrastructure → Application (implements interfaces)
```

**Code example**:

```csharp
// DOMAIN LAYER (no dependencies)
namespace MyApp.Domain.Entities
{
    public class Order
    {
        public int Id { get; private set; }
        public Money Total { get; private set; }
        public List<OrderLine> Lines { get; private set; } = new();

        public void AddLine(Product product, int quantity)
        {
            // Domain logic - no infrastructure dependencies
            Lines.Add(new OrderLine(product, quantity));
            RecalculateTotal();
        }
    }
}

// APPLICATION LAYER (defines interfaces)
namespace MyApp.Application.Interfaces
{
    public interface IOrderRepository
    {
        Task<Order> GetByIdAsync(int id);
        Task AddAsync(Order order);
    }
}

namespace MyApp.Application.UseCases.CreateOrder
{
    public class CreateOrderHandler
    {
        private readonly IOrderRepository _orderRepository; // Interface, not implementation!

        public async Task<int> HandleAsync(CreateOrderCommand command)
        {
            var order = new Order(command.CustomerId);
            // Business logic...
            await _orderRepository.AddAsync(order);
            return order.Id;
        }
    }
}

// INFRASTRUCTURE LAYER (implements interfaces)
namespace MyApp.Infrastructure.Persistence
{
    public class OrderRepository : IOrderRepository // Implements Application interface
    {
        private readonly AppDbContext _context;

        public async Task AddAsync(Order order)
        {
            await _context.Orders.AddAsync(order);
            await _context.SaveChangesAsync();
        }
    }
}

// WEB LAYER (entry point)
namespace MyApp.Web.Controllers
{
    [ApiController]
    public class OrderController : ControllerBase
    {
        private readonly CreateOrderHandler _handler;

        [HttpPost]
        public async Task<IActionResult> CreateOrder(CreateOrderDto dto)
        {
            var command = new CreateOrderCommand { /* ... */ };
            var orderId = await _handler.HandleAsync(command);
            return Ok(orderId);
        }
    }
}
```

**Dependency Injection (Startup)**:

```csharp
// Register infrastructure implementations
services.AddScoped<IOrderRepository, OrderRepository>(); // Infrastructure → Application
services.AddScoped<IEmailService, SmtpEmailService>();
```

**Pros**:
- Business logic independent of infrastructure
- Easy to test (mock interfaces)
- Easy to swap implementations (change database, email provider, etc.)
- Domain-driven design

**Cons**:
- More complex than layered architecture
- More files/projects
- Learning curve

**Modern usage**: ★★★★★ - Recommended for complex applications, DDD.

## Hexagonal Architecture (Ports & Adapters)

Isolate core application from external concerns using ports (interfaces) and adapters (implementations).

**Concept**:
- **Core/Domain** - Business logic (hexagon center)
- **Ports** - Interfaces for input/output
- **Adapters** - Implementations of ports (web, database, messaging)

**Example**:

```
Core Domain
    ↓ (defines port)
IOrderRepository (port - interface)
    ↑ (adapter implements port)
OrderRepository (adapter - implementation)
```

**Very similar to Clean Architecture** - both use Dependency Inversion.

**Modern usage**: ★★★★☆ - Same principles as Clean Architecture, different terminology.

## Event-Driven Architecture (EDA)

Components communicate through asynchronous events.

**Key concepts**:
- **Events** - Something happened (OrderCreated, PaymentProcessed)
- **Publishers** - Emit events
- **Subscribers** - React to events
- **Event Bus/Broker** - RabbitMQ, Kafka, Azure Service Bus

**Example (.NET with MassTransit)**:

```csharp
// Event
public record OrderCreated
{
    public int OrderId { get; init; }
    public int CustomerId { get; init; }
    public decimal Total { get; init; }
}

// Publisher (Order Service)
public class OrderService
{
    private readonly IPublishEndpoint _publishEndpoint;

    public async Task<Order> CreateOrderAsync(CreateOrderRequest request)
    {
        var order = new Order { /* ... */ };
        await _orderRepository.AddAsync(order);

        // Publish event
        await _publishEndpoint.Publish(new OrderCreated
        {
            OrderId = order.Id,
            CustomerId = order.CustomerId,
            Total = order.Total
        });

        return order;
    }
}

// Subscriber (Email Service)
public class OrderCreatedConsumer : IConsumer<OrderCreated>
{
    private readonly IEmailService _emailService;

    public async Task Consume(ConsumeContext<OrderCreated> context)
    {
        var @event = context.Message;

        // React to event
        await _emailService.SendOrderConfirmationAsync(@event.OrderId);
    }
}

// Subscriber (Inventory Service)
public class InventoryConsumer : IConsumer<OrderCreated>
{
    public async Task Consume(ConsumeContext<OrderCreated> context)
    {
        // Reserve inventory
        await _inventoryService.ReserveAsync(context.Message.OrderId);
    }
}
```

**Pros**:
- Loose coupling - services don't know about each other
- Scalability - async processing
- Flexibility - add new subscribers without changing publishers

**Cons**:
- Complexity - distributed system challenges
- Debugging harder - trace events across services
- Eventual consistency

**Modern usage**: ★★★★★ - Standard for microservices, distributed systems.

**Tools**: MassTransit (C#), RabbitMQ, Apache Kafka, Azure Service Bus, AWS SQS/SNS

## Microservices Architecture

Decompose application into small, independent services.

**Characteristics**:
- Each service is independent (own database, deployment)
- Communicate via APIs (REST, gRPC) or events
- Organized around business capabilities
- Decentralized governance

**See**: [Microservices Patterns](microservices-patterns-design-patterns.md) for detailed patterns (Saga, API Gateway, Service Discovery, etc.)

**Example structure**:

```
Order Service         Customer Service      Inventory Service
  ├─ API                ├─ API                ├─ API
  ├─ Domain             ├─ Domain             ├─ Domain
  └─ Database           └─ Database           └─ Database
       (PostgreSQL)          (MongoDB)             (Redis)
```

**Pros**:
- Independent deployment
- Technology diversity (polyglot)
- Scalability - scale services independently
- Team autonomy

**Cons**:
- Complexity - distributed system challenges
- Network latency
- Distributed transactions (Saga pattern needed)
- Testing harder

**Modern usage**: ★★★★★ - Standard for large-scale applications.

## CQRS Architecture

Separate read and write models.

**See**: [CQRS in Microservices Patterns](microservices-patterns-design-patterns.md#cqrs-command-query-responsibility-segregation)

**Modern usage**: ★★★★☆ - Common with Event Sourcing, complex read requirements.

## Comparison

| Pattern | Complexity | Testability | Flexibility | Best For |
|---------|-----------|-------------|-------------|----------|
| **Layered** | Low | Medium | Low | Simple CRUD apps |
| **Clean Architecture** | Medium | High | High | Complex domains, DDD |
| **Hexagonal** | Medium | High | High | Same as Clean (different terminology) |
| **Event-Driven** | High | Medium | High | Async workflows, microservices |
| **Microservices** | Very High | Medium | Very High | Large-scale systems, multiple teams |

## Choosing Architecture

### Simple Application (CRUD, few business rules)

**Choose**: Layered Architecture
- ASP.NET Core MVC/API
- EF Core
- 3 layers: Web, Business, Data

### Complex Domain (Rich business logic)

**Choose**: Clean Architecture
- Domain in center (no infrastructure dependencies)
- Use Cases layer
- DDD principles

### Distributed System (Multiple teams, independent services)

**Choose**: Microservices + Event-Driven
- Each service: Clean Architecture internally
- Communication: Events (RabbitMQ/Kafka) or REST/gRPC
- Patterns: Saga, CQRS, API Gateway

### High-Performance Reads (Complex queries, denormalization needed)

**Choose**: CQRS
- Command side: Domain model
- Query side: Denormalized read model
- Often combined with Event Sourcing

## Modern Trends (2025)

### Dominant Architectures

- **Clean Architecture** (★★★★★) - Standard for complex applications
- **Microservices** (★★★★★) - Large-scale systems
- **Event-Driven** (★★★★★) - Async workflows

### Still Common

- **Layered** (★★★★☆) - Simple applications
- **CQRS** (★★★★☆) - Complex read requirements

### Framework Support

- **ASP.NET Core** - Supports all patterns (DI, middleware, minimal APIs)
- **Kubernetes** - Microservices orchestration
- **MassTransit/NServiceBus** - Event-driven messaging

## See Also

- [Microservices Patterns](microservices-patterns-design-patterns.md) - Saga, CQRS, Service Discovery
- [Cloud Patterns](cloud-patterns-design-patterns.md) - Resilience, scalability
- [Enterprise Patterns](enterprise-patterns-design-patterns.md) - Service Layer, Repository
- [SOLID Principles](../solid-principles/solid-principles.md) - Design principles
- [Architecture Design](../development-guidelines/architecture/architecture-design-architecture.md) - Design decisions

## References

- "Clean Architecture" by Robert C. Martin (Uncle Bob) (2017)
- "Patterns of Enterprise Application Architecture" by Martin Fowler (2002)
- "Building Microservices" by Sam Newman (2021)
- "Domain-Driven Design" by Eric Evans (2003)
- [Microsoft Architecture Guides](https://learn.microsoft.com/en-us/dotnet/architecture/)
