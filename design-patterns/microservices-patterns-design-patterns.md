# Microservices Patterns

Patterns for building distributed systems with microservices architecture: distributed transactions, data management, and service communication.

## Overview

Microservices architecture brings unique challenges:
- **Distributed transactions** - How to maintain consistency across services?
- **Data management** - Each service has its own database
- **Service communication** - Synchronous vs asynchronous
- **Resilience** - Handle failures gracefully

**Key patterns**: Saga, CQRS, Event Sourcing, API Gateway, Service Discovery, Circuit Breaker, Database per Service.

**Source**: [Microservices.io](https://microservices.io/patterns/index.html) by Chris Richardson

## Distributed Transaction Patterns

### Saga Pattern

Implement distributed transactions as a sequence of local transactions coordinated by events or orchestration.

**Problem**: Need to maintain data consistency across multiple services without distributed (2PC) transactions.

**Solution**: Break transaction into steps, each updating one service. If a step fails, execute compensating transactions to undo previous steps.

**Two coordination styles**:

#### 1. Choreography-based Saga

Each service publishes events that trigger next steps.

**Example: Order Creation**

```
Order Service → creates order (PENDING)
              → publishes OrderCreated event
                ↓
Customer Service → receives event
                 → reserves credit
                 → publishes CreditReserved or CreditReserveFailed event
                   ↓
Order Service → receives event
              → approves order (if CreditReserved)
              → rejects order (if CreditReserveFailed)
```

**C# Example**:
```csharp
// Order Service
public class OrderService
{
    public async Task<Order> CreateOrderAsync(CreateOrderRequest request)
    {
        var order = new Order { Status = OrderStatus.Pending };
        await _orderRepository.AddAsync(order);

        // Publish event
        await _eventBus.PublishAsync(new OrderCreated
        {
            OrderId = order.Id,
            CustomerId = request.CustomerId,
            Amount = request.Amount
        });

        return order;
    }
}

// Customer Service (event handler)
public class CreditReservationHandler : IEventHandler<OrderCreated>
{
    public async Task HandleAsync(OrderCreated @event)
    {
        var customer = await _customerRepository.GetByIdAsync(@event.CustomerId);

        if (customer.CanReserveCredit(@event.Amount))
        {
            customer.ReserveCredit(@event.Amount);
            await _customerRepository.UpdateAsync(customer);

            await _eventBus.PublishAsync(new CreditReserved
            {
                OrderId = @event.OrderId,
                CustomerId = @event.CustomerId
            });
        }
        else
        {
            await _eventBus.PublishAsync(new CreditReserveFailed
            {
                OrderId = @event.OrderId,
                Reason = "Insufficient credit"
            });
        }
    }
}

// Order Service (event handler)
public class OrderApprovalHandler : IEventHandler<CreditReserved>
{
    public async Task HandleAsync(CreditReserved @event)
    {
        var order = await _orderRepository.GetByIdAsync(@event.OrderId);
        order.Approve();
        await _orderRepository.UpdateAsync(order);
    }
}
```

**Pros**: Simple, loose coupling, no central coordinator
**Cons**: Hard to understand flow, difficult to debug

#### 2. Orchestration-based Saga

Central orchestrator tells participants what to do.

**Example: Order Creation Saga Orchestrator**

```csharp
public class CreateOrderSaga
{
    private readonly IOrderRepository _orderRepository;
    private readonly ICustomerServiceClient _customerService;
    private readonly IInventoryServiceClient _inventoryService;

    public async Task<SagaResult> ExecuteAsync(CreateOrderRequest request)
    {
        var order = new Order { Status = OrderStatus.Pending };
        await _orderRepository.AddAsync(order);

        try
        {
            // Step 1: Reserve credit
            var creditReserved = await _customerService.ReserveCreditAsync(
                request.CustomerId, order.Total);

            if (!creditReserved.Success)
            {
                await CompensateAsync(order);
                return SagaResult.Failed("Credit reservation failed");
            }

            // Step 2: Reserve inventory
            var inventoryReserved = await _inventoryService.ReserveItemsAsync(
                order.Items);

            if (!inventoryReserved.Success)
            {
                // Compensate: Release credit
                await _customerService.ReleaseCreditAsync(request.CustomerId, order.Total);
                await CompensateAsync(order);
                return SagaResult.Failed("Inventory reservation failed");
            }

            // Step 3: Approve order
            order.Approve();
            await _orderRepository.UpdateAsync(order);

            return SagaResult.Success(order.Id);
        }
        catch (Exception ex)
        {
            await CompensateAsync(order);
            throw;
        }
    }

    private async Task CompensateAsync(Order order)
    {
        order.Reject();
        await _orderRepository.UpdateAsync(order);
    }
}
```

**Pros**: Clear flow, easier to debug, centralized logic
**Cons**: Orchestrator is single point of failure, tight coupling

**Modern usage**: ★★★★★ - Essential for microservices with distributed transactions.

**Frameworks**: MassTransit (C#), Eventuate Tram Sagas, Axon Framework (Java)

## Data Management Patterns

### CQRS (Command Query Responsibility Segregation)

Separate read and write operations into different models.

**Problem**:
- Complex queries across multiple aggregates
- Different performance requirements for reads vs writes
- Read model needs denormalized data

**Solution**:
- **Command side**: Domain model optimized for writes
- **Query side**: Denormalized read model optimized for queries

**Example (.NET)**:

```csharp
// COMMAND SIDE

public class CreateOrderCommand
{
    public int CustomerId { get; set; }
    public List<OrderItem> Items { get; set; }
}

public class CreateOrderCommandHandler : ICommandHandler<CreateOrderCommand>
{
    private readonly IOrderRepository _orderRepository;
    private readonly IEventBus _eventBus;

    public async Task HandleAsync(CreateOrderCommand command)
    {
        var order = new Order(command.CustomerId);
        foreach (var item in command.Items)
        {
            order.AddItem(item.ProductId, item.Quantity);
        }

        await _orderRepository.AddAsync(order);

        // Publish event for query side
        await _eventBus.PublishAsync(new OrderCreated
        {
            OrderId = order.Id,
            CustomerId = order.CustomerId,
            Items = order.Items,
            Total = order.Total
        });
    }
}

// QUERY SIDE

public class OrderSummaryView
{
    public int OrderId { get; set; }
    public string CustomerName { get; set; }
    public int ItemCount { get; set; }
    public decimal Total { get; set; }
    public DateTime OrderDate { get; set; }
}

public class OrderCreatedEventHandler : IEventHandler<OrderCreated>
{
    private readonly IOrderViewRepository _viewRepository;

    public async Task HandleAsync(OrderCreated @event)
    {
        var customer = await _customerRepository.GetByIdAsync(@event.CustomerId);

        // Update denormalized read model
        var view = new OrderSummaryView
        {
            OrderId = @event.OrderId,
            CustomerName = customer.Name, // Denormalized!
            ItemCount = @event.Items.Count,
            Total = @event.Total,
            OrderDate = DateTime.UtcNow
        };

        await _viewRepository.AddAsync(view);
    }
}

// Query
public class GetOrderSummariesQuery
{
    public int CustomerId { get; set; }
}

public class GetOrderSummariesQueryHandler : IQueryHandler<GetOrderSummariesQuery, List<OrderSummaryView>>
{
    public async Task<List<OrderSummaryView>> HandleAsync(GetOrderSummariesQuery query)
    {
        // Fast query on denormalized read model
        return await _viewRepository.GetByCustomerIdAsync(query.CustomerId);
    }
}
```

**Pros**:
- Optimized read and write models
- Scalability - separate scaling for reads/writes
- Flexibility - different databases for read/write

**Cons**:
- Complexity
- Eventual consistency between command and query sides
- Code duplication

**Modern usage**: ★★★★☆ - Common in complex domains, event-sourced systems.

**Frameworks**: MediatR (C#), Axon Framework (Java)

### Event Sourcing

Store state changes as sequence of events instead of current state.

**Problem**:
- Need audit trail of all changes
- Want to rebuild state at any point in time
- Need to replay events

**Solution**: Store events, rebuild state by replaying them.

**Example (.NET)**:

```csharp
// Events
public class OrderCreated : IEvent
{
    public int OrderId { get; set; }
    public int CustomerId { get; set; }
}

public class ItemAdded : IEvent
{
    public int OrderId { get; set; }
    public int ProductId { get; set; }
    public int Quantity { get; set; }
}

public class OrderApproved : IEvent
{
    public int OrderId { get; set; }
}

// Aggregate that applies events
public class Order
{
    public int Id { get; private set; }
    public int CustomerId { get; private set; }
    public List<OrderLine> Lines { get; private set; } = new();
    public OrderStatus Status { get; private set; }

    // Replay events to rebuild state
    public void Apply(OrderCreated @event)
    {
        Id = @event.OrderId;
        CustomerId = @event.CustomerId;
        Status = OrderStatus.Pending;
    }

    public void Apply(ItemAdded @event)
    {
        Lines.Add(new OrderLine(@event.ProductId, @event.Quantity));
    }

    public void Apply(OrderApproved @event)
    {
        Status = OrderStatus.Approved;
    }
}

// Event store
public class EventStore
{
    public async Task SaveEventsAsync(int aggregateId, IEnumerable<IEvent> events)
    {
        foreach (var @event in events)
        {
            await _dbContext.Events.AddAsync(new EventRecord
            {
                AggregateId = aggregateId,
                EventType = @event.GetType().Name,
                EventData = JsonSerializer.Serialize(@event),
                Timestamp = DateTime.UtcNow
            });
        }
        await _dbContext.SaveChangesAsync();
    }

    public async Task<T> LoadAggregateAsync<T>(int aggregateId) where T : new()
    {
        var events = await _dbContext.Events
            .Where(e => e.AggregateId == aggregateId)
            .OrderBy(e => e.Timestamp)
            .ToListAsync();

        var aggregate = new T();
        foreach (var eventRecord in events)
        {
            var @event = DeserializeEvent(eventRecord);
            ((dynamic)aggregate).Apply((dynamic)@event);
        }

        return aggregate;
    }
}
```

**Pros**:
- Complete audit trail
- Time travel - rebuild state at any point
- Event replay for debugging
- Natural fit with CQRS

**Cons**:
- Complexity
- Event schema evolution is hard
- Querying current state requires rebuilding

**Modern usage**: ★★★☆☆ - Used in financial systems, audit-critical applications.

**Frameworks**: EventStore, Marten (C#), Axon Framework (Java)

### Database per Service

Each microservice has its own private database.

**Pros**: Loose coupling, independent scaling, technology choice per service
**Cons**: Distributed transactions needed (Saga), data duplication

**Modern usage**: ★★★★★ - Core principle of microservices.

## Communication Patterns

### API Gateway

Single entry point for clients that routes requests to appropriate microservices.

**Responsibilities**:
- Request routing
- Authentication/Authorization
- Rate limiting
- Request aggregation
- Protocol translation

**Example (ASP.NET with Ocelot)**:

```json
{
  "Routes": [
    {
      "DownstreamPathTemplate": "/api/orders/{everything}",
      "DownstreamScheme": "http",
      "DownstreamHostAndPorts": [
        { "Host": "order-service", "Port": 5001 }
      ],
      "UpstreamPathTemplate": "/orders/{everything}",
      "UpstreamHttpMethod": [ "GET", "POST" ]
    },
    {
      "DownstreamPathTemplate": "/api/customers/{everything}",
      "DownstreamScheme": "http",
      "DownstreamHostAndPorts": [
        { "Host": "customer-service", "Port": 5002 }
      ],
      "UpstreamPathTemplate": "/customers/{everything}",
      "UpstreamHttpMethod": [ "GET", "POST" ]
    }
  ]
}
```

**Modern usage**: ★★★★★ - Essential for microservices.

**Tools**: Ocelot (C#), Kong, NGINX, AWS API Gateway, Azure API Management

### Service Discovery

Automatically detect network locations of service instances.

**Client-side discovery**: Client queries service registry and load balances.
**Server-side discovery**: Load balancer queries registry.

**Modern usage**: ★★★★☆ - Built into Kubernetes, Consul, Eureka.

### API Composition

Compose data from multiple services for a single query.

**Example**:
```csharp
public class OrderSummaryComposer
{
    public async Task<OrderSummaryDto> GetOrderSummaryAsync(int orderId)
    {
        // Call multiple services
        var orderTask = _orderService.GetOrderAsync(orderId);
        var customerTask = _customerService.GetCustomerAsync(orderId);
        var itemsTask = _inventoryService.GetItemsAsync(orderId);

        await Task.WhenAll(orderTask, customerTask, itemsTask);

        // Compose response
        return new OrderSummaryDto
        {
            Order = orderTask.Result,
            Customer = customerTask.Result,
            Items = itemsTask.Result
        };
    }
}
```

**Alternative**: GraphQL (client specifies what data to fetch)

**Modern usage**: ★★★★☆ - Common in BFF (Backend for Frontend) pattern.

## Resilience Patterns

See [Cloud Patterns](cloud-patterns-design-patterns.md) for detailed resilience patterns:
- Circuit Breaker
- Retry
- Bulkhead
- Timeout

## Modern Relevance (2025)

### Essential Patterns

- **Saga** (★★★★★) - Distributed transactions
- **API Gateway** (★★★★★) - Single entry point
- **Database per Service** (★★★★★) - Core microservices principle
- **Circuit Breaker** (★★★★★) - Resilience (see Cloud Patterns)

### Common Patterns

- **CQRS** (★★★★☆) - Complex queries
- **Service Discovery** (★★★★☆) - Built into Kubernetes
- **API Composition** (★★★★☆) - Data aggregation

### Advanced Patterns

- **Event Sourcing** (★★★☆☆) - Audit-critical systems
- **Saga Orchestration** (★★★★☆) - Complex workflows

## See Also

- [Cloud Patterns](cloud-patterns-design-patterns.md) - Resilience patterns (Circuit Breaker, Retry)
- [Enterprise Patterns](enterprise-patterns-design-patterns.md) - Service Layer, Repository, DTO
- [Architectural Patterns](architectural-patterns-design-patterns.md) - Microservices Architecture
- [SOLID Principles](../solid-principles/solid-principles.md) - Design principles

## References

- [Microservices.io Patterns](https://microservices.io/patterns/index.html) by Chris Richardson
- "Microservices Patterns" by Chris Richardson (2018)
- [Building Microservices](https://samnewman.io/books/building_microservices_2nd_edition/) by Sam Newman (2021)
