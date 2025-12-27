# Cloud Design Patterns

Patterns for building resilient, scalable, and performant applications in cloud environments (Azure, AWS, GCP).

## Overview

Cloud applications face unique challenges:
- **Transient failures** - Network hiccups, timeouts, temporary unavailability
- **Scalability** - Handle varying loads
- **Distributed systems** - Multiple services, databases, caches
- **Cost optimization** - Pay per use

**Key patterns**: Retry, Circuit Breaker, Bulkhead, Cache-Aside, Compensating Transaction, Gateway Aggregation.

**Sources**:
- [Azure Architecture Center - Cloud Design Patterns](https://learn.microsoft.com/en-us/azure/architecture/patterns/)
- AWS Well-Architected Framework
- Google Cloud Architecture Framework

## Resilience Patterns

### Retry Pattern

Automatically retry failed operations that might succeed on subsequent attempts.

**Problem**: Transient failures (network timeouts, temporary service unavailability) cause operations to fail.

**Solution**: Retry the operation with exponential backoff and jitter.

**Example (.NET with Polly)**:

```csharp
using Polly;
using Polly.Retry;

public class OrderService
{
    private readonly HttpClient _httpClient;
    private readonly AsyncRetryPolicy<HttpResponseMessage> _retryPolicy;

    public OrderService(HttpClient httpClient)
    {
        _httpClient = httpClient;

        // Retry up to 3 times with exponential backoff
        _retryPolicy = Policy
            .HandleResult<HttpResponseMessage>(r => !r.IsSuccessStatusCode)
            .Or<HttpRequestException>()
            .WaitAndRetryAsync(
                retryCount: 3,
                sleepDurationProvider: retryAttempt =>
                    TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)) // 2, 4, 8 seconds
                    + TimeSpan.FromMilliseconds(Random.Shared.Next(0, 1000)), // jitter
                onRetry: (outcome, timespan, retryCount, context) =>
                {
                    _logger.LogWarning(
                        "Request failed (attempt {RetryCount}). Retrying in {Delay}s...",
                        retryCount, timespan.TotalSeconds);
                });
    }

    public async Task<Order> GetOrderAsync(int orderId)
    {
        var response = await _retryPolicy.ExecuteAsync(() =>
            _httpClient.GetAsync($"/api/orders/{orderId}"));

        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<Order>();
    }
}
```

**Best practices**:
- Use exponential backoff (avoid retry storms)
- Add jitter (randomize retry timing)
- Set max retry count
- Only retry transient errors (not 4xx client errors)
- Consider idempotency

**Modern usage**: ★★★★★ - Essential for all distributed systems.

**Tools**: Polly (C#), resilience4j (Java), Spring Retry

### Circuit Breaker Pattern

Prevent cascading failures by stopping requests to failing services.

**Problem**: Calling a failing service wastes resources and can cascade failures.

**Solution**: Monitor failures. After threshold, "open circuit" and fail fast. Periodically test if service recovered.

**States**:
- **Closed**: Normal operation, requests pass through
- **Open**: Service failing, fail fast without calling service
- **Half-Open**: Test if service recovered

**Example (.NET with Polly)**:

```csharp
public class PaymentService
{
    private readonly HttpClient _httpClient;
    private readonly AsyncCircuitBreakerPolicy _circuitBreakerPolicy;

    public PaymentService(HttpClient httpClient)
    {
        _httpClient = httpClient;

        _circuitBreakerPolicy = Policy
            .Handle<HttpRequestException>()
            .CircuitBreakerAsync(
                handledEventsAllowedBeforeBreaking: 3, // Open after 3 failures
                durationOfBreak: TimeSpan.FromSeconds(30), // Stay open for 30s
                onBreak: (exception, duration) =>
                {
                    _logger.LogError("Circuit breaker opened for {Duration}s", duration.TotalSeconds);
                },
                onReset: () =>
                {
                    _logger.LogInformation("Circuit breaker reset (closed)");
                },
                onHalfOpen: () =>
                {
                    _logger.LogInformation("Circuit breaker half-open (testing)");
                });
    }

    public async Task<PaymentResult> ProcessPaymentAsync(PaymentRequest request)
    {
        try
        {
            return await _circuitBreakerPolicy.ExecuteAsync(async () =>
            {
                var response = await _httpClient.PostAsJsonAsync("/api/payments", request);
                response.EnsureSuccessStatusCode();
                return await response.Content.ReadFromJsonAsync<PaymentResult>();
            });
        }
        catch (BrokenCircuitException)
        {
            _logger.LogWarning("Payment service unavailable (circuit open)");
            return PaymentResult.ServiceUnavailable();
        }
    }
}
```

**Combining Retry + Circuit Breaker**:

```csharp
var retryPolicy = Policy
    .Handle<HttpRequestException>()
    .WaitAndRetryAsync(3, retryAttempt => TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)));

var circuitBreakerPolicy = Policy
    .Handle<HttpRequestException>()
    .CircuitBreakerAsync(5, TimeSpan.FromSeconds(30));

// Wrap retry inside circuit breaker
var combinedPolicy = Policy.WrapAsync(circuitBreakerPolicy, retryPolicy);

await combinedPolicy.ExecuteAsync(() => _httpClient.GetAsync(url));
```

**Modern usage**: ★★★★★ - Critical for microservices resilience.

**Tools**: Polly (C#), Hystrix (Netflix, deprecated → Resilience4j), Istio service mesh

### Bulkhead Pattern

Isolate resources to prevent cascading failures.

**Problem**: One failing component can exhaust all resources (threads, connections), affecting entire system.

**Solution**: Partition resources into pools. If one pool exhausted, others unaffected.

**Analogy**: Ship bulkheads - if one compartment floods, others stay dry.

**Example (.NET with Polly)**:

```csharp
public class ServiceClients
{
    private readonly AsyncBulkheadPolicy _criticalServiceBulkhead;
    private readonly AsyncBulkheadPolicy _nonCriticalServiceBulkhead;

    public ServiceClients()
    {
        // Critical service: 10 concurrent calls, queue 5
        _criticalServiceBulkhead = Policy.BulkheadAsync(
            maxParallelization: 10,
            maxQueuingActions: 5,
            onBulkheadRejectedAsync: context =>
            {
                _logger.LogWarning("Critical service bulkhead full - request rejected");
                return Task.CompletedTask;
            });

        // Non-critical service: 5 concurrent calls, queue 2
        _nonCriticalServiceBulkhead = Policy.BulkheadAsync(
            maxParallelization: 5,
            maxQueuingActions: 2);
    }

    public async Task<PaymentResult> ProcessPaymentAsync(PaymentRequest request)
    {
        // Critical - uses dedicated bulkhead
        return await _criticalServiceBulkhead.ExecuteAsync(async () =>
        {
            return await _paymentClient.ProcessAsync(request);
        });
    }

    public async Task<Recommendation> GetRecommendationsAsync(int userId)
    {
        // Non-critical - uses separate bulkhead
        return await _nonCriticalServiceBulkhead.ExecuteAsync(async () =>
        {
            return await _recommendationClient.GetAsync(userId);
        });
    }
}
```

**Modern usage**: ★★★★☆ - Important for preventing resource exhaustion.

**Tools**: Polly (C#), Resilience4j (Java), ThreadPoolExecutor limits

### Timeout Pattern

Set time limits for operations to prevent hanging.

**Example (.NET)**:

```csharp
var timeoutPolicy = Policy.TimeoutAsync(
    seconds: 5,
    onTimeoutAsync: (context, timespan, task) =>
    {
        _logger.LogWarning("Operation timed out after {Timeout}s", timespan.TotalSeconds);
        return Task.CompletedTask;
    });

await timeoutPolicy.ExecuteAsync(async ct =>
{
    return await _httpClient.GetAsync(url, ct);
}, CancellationToken.None);
```

**Modern usage**: ★★★★★ - Always set timeouts for external calls.

## Caching Patterns

### Cache-Aside Pattern

Application manages cache explicitly.

**Flow**:
1. Check cache
2. If miss, load from database
3. Store in cache
4. Return data

**Example (.NET with IMemoryCache)**:

```csharp
public class ProductService
{
    private readonly IMemoryCache _cache;
    private readonly IProductRepository _repository;

    public async Task<Product> GetProductAsync(int productId)
    {
        var cacheKey = $"product:{productId}";

        // 1. Try cache
        if (_cache.TryGetValue(cacheKey, out Product cachedProduct))
        {
            return cachedProduct;
        }

        // 2. Cache miss - load from DB
        var product = await _repository.GetByIdAsync(productId);

        if (product != null)
        {
            // 3. Store in cache
            var cacheOptions = new MemoryCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(10),
                SlidingExpiration = TimeSpan.FromMinutes(2)
            };

            _cache.Set(cacheKey, product, cacheOptions);
        }

        // 4. Return data
        return product;
    }

    public async Task UpdateProductAsync(Product product)
    {
        await _repository.UpdateAsync(product);

        // Invalidate cache
        _cache.Remove($"product:{product.Id}");
    }
}
```

**Distributed cache (Redis)**:

```csharp
public class ProductService
{
    private readonly IDistributedCache _cache; // Redis

    public async Task<Product> GetProductAsync(int productId)
    {
        var cacheKey = $"product:{productId}";

        // Try cache
        var cachedData = await _cache.GetStringAsync(cacheKey);
        if (cachedData != null)
        {
            return JsonSerializer.Deserialize<Product>(cachedData);
        }

        // Load from DB
        var product = await _repository.GetByIdAsync(productId);

        if (product != null)
        {
            // Store in cache
            var options = new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(10)
            };

            await _cache.SetStringAsync(
                cacheKey,
                JsonSerializer.Serialize(product),
                options);
        }

        return product;
    }
}
```

**Modern usage**: ★★★★★ - Standard caching pattern.

**Tools**: IMemoryCache (in-process), Redis, Memcached

## Data Consistency Patterns

### Compensating Transaction Pattern

Undo changes when distributed transaction fails.

**Problem**: Distributed operations across services - some succeed, some fail.

**Solution**: Execute compensating actions to undo successful steps.

**Example**: See [Saga pattern](microservices-patterns-design-patterns.md#saga-pattern) in Microservices Patterns.

**Modern usage**: ★★★★☆ - Core of Saga pattern.

## Communication Patterns

### Gateway Aggregation Pattern

Aggregate multiple service calls into single request.

**Problem**: Client needs data from multiple microservices → multiple network calls.

**Solution**: API Gateway aggregates calls.

**Example**:

```csharp
public class OrderAggregationGateway
{
    public async Task<OrderDetailsDto> GetOrderDetailsAsync(int orderId)
    {
        // Call multiple services in parallel
        var orderTask = _orderService.GetOrderAsync(orderId);
        var customerTask = _customerService.GetCustomerAsync(orderId);
        var shippingTask = _shippingService.GetShippingStatusAsync(orderId);

        await Task.WhenAll(orderTask, customerTask, shippingTask);

        // Aggregate into single response
        return new OrderDetailsDto
        {
            Order = orderTask.Result,
            Customer = customerTask.Result,
            ShippingStatus = shippingTask.Result
        };
    }
}
```

**Modern usage**: ★★★★★ - Standard in BFF (Backend for Frontend).

### Gateway Offloading Pattern

Offload cross-cutting concerns to gateway.

**Offload to gateway**:
- Authentication/Authorization
- SSL termination
- Rate limiting
- Logging
- Request/Response transformation

**Modern usage**: ★★★★★ - Built into API Gateways (Kong, NGINX, Azure API Management).

## Monitoring Patterns

### Health Endpoint Pattern

Expose health check endpoint for monitoring.

**Example (ASP.NET Core)**:

```csharp
// Startup.cs
public void ConfigureServices(IServiceCollection services)
{
    services.AddHealthChecks()
        .AddDbContextCheck<AppDbContext>() // Database health
        .AddRedis(Configuration["Redis:ConnectionString"]) // Redis health
        .AddUrlGroup(new Uri("https://api.external.com/health"), "External API"); // Dependency health
}

public void Configure(IApplicationBuilder app)
{
    app.UseHealthChecks("/health");
}
```

**Response**: 200 OK (healthy) or 503 Service Unavailable (unhealthy)

**Modern usage**: ★★★★★ - Required for Kubernetes liveness/readiness probes.

## Modern Relevance (2025)

### Essential Patterns

- **Retry** (★★★★★) - All distributed calls
- **Circuit Breaker** (★★★★★) - Prevent cascading failures
- **Cache-Aside** (★★★★★) - Performance optimization
- **Health Endpoint** (★★★★★) - Required for orchestrators
- **Gateway Aggregation** (★★★★★) - Reduce client calls

### Important Patterns

- **Bulkhead** (★★★★☆) - Resource isolation
- **Timeout** (★★★★★) - Prevent hanging
- **Compensating Transaction** (★★★★☆) - Part of Saga

### Framework-Implemented

Many patterns built into platforms:
- **Kubernetes**: Health checks, load balancing
- **Service meshes** (Istio, Linkerd): Circuit breaker, retry, timeout
- **API Gateways**: Rate limiting, auth, aggregation

## See Also

- [Microservices Patterns](microservices-patterns-design-patterns.md) - Saga, CQRS, Service Discovery
- [Enterprise Patterns](enterprise-patterns-design-patterns.md) - Service Layer, Repository
- [Architectural Patterns](architectural-patterns-design-patterns.md) - Microservices Architecture
- [Testing Guide](../development-guidelines/testing/index-testing.md) - Testing resilience patterns

## References

- [Azure Cloud Design Patterns](https://learn.microsoft.com/en-us/azure/architecture/patterns/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- "Release It!" by Michael Nygard (2018) - Stability patterns
- [Polly documentation](https://github.com/App-vNext/Polly) - .NET resilience library
