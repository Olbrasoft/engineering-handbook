# Design Patterns

Software design patterns catalog: classic GoF patterns, enterprise patterns, microservices patterns, and architectural patterns.

## Overview

Design patterns are proven solutions to common software design problems. This section covers multiple pattern catalogs:

- **GoF Patterns** - 23 classic object-oriented design patterns
- **Enterprise Patterns** - Martin Fowler's patterns for enterprise applications
- **Microservices Patterns** - Patterns for distributed systems (Saga, CQRS, Event Sourcing)
- **Cloud Patterns** - Resilience and scalability patterns for cloud applications
- **Architectural Patterns** - High-level system organization patterns

## Decision Tree

```
What problem are you solving?
│
├─ Object creation, structure, or behavior?
│  └─ GoF Patterns → gof-patterns-design-patterns.md
│
├─ Enterprise application (web, data access, domain logic)?
│  └─ Enterprise Patterns → enterprise-patterns-design-patterns.md
│
├─ Distributed transactions or microservices communication?
│  └─ Microservices Patterns → microservices-patterns-design-patterns.md
│
├─ Cloud resilience (retry, circuit breaker, bulkhead)?
│  └─ Cloud Patterns → cloud-patterns-design-patterns.md
│
└─ System architecture (layers, hexagonal, clean architecture)?
   └─ Architectural Patterns → architectural-patterns-design-patterns.md
```

## Quick Navigation

| Pattern Category | When to Use | File |
|------------------|-------------|------|
| **GoF Patterns** | Object-oriented design (creation, structure, behavior) | [gof-patterns-design-patterns.md](gof-patterns-design-patterns.md) |
| **Enterprise Patterns** | Web apps, domain logic, data access, ORM | [enterprise-patterns-design-patterns.md](enterprise-patterns-design-patterns.md) |
| **Microservices Patterns** | Distributed transactions, event-driven systems, CQRS | [microservices-patterns-design-patterns.md](microservices-patterns-design-patterns.md) |
| **Cloud Patterns** | Resilience, scalability, retry logic, fault tolerance | [cloud-patterns-design-patterns.md](cloud-patterns-design-patterns.md) |
| **Architectural Patterns** | System organization, layering, clean architecture | [architectural-patterns-design-patterns.md](architectural-patterns-design-patterns.md) |

## File Index

- **[gof-patterns-design-patterns.md](gof-patterns-design-patterns.md)** - 23 classic Gang of Four patterns (Creational, Structural, Behavioral)
- **[enterprise-patterns-design-patterns.md](enterprise-patterns-design-patterns.md)** - Martin Fowler's 50+ enterprise application patterns
- **[microservices-patterns-design-patterns.md](microservices-patterns-design-patterns.md)** - Saga, CQRS, Event Sourcing, API Gateway, Service Discovery
- **[cloud-patterns-design-patterns.md](cloud-patterns-design-patterns.md)** - Retry, Circuit Breaker, Bulkhead, Cache-Aside, Compensating Transaction
- **[architectural-patterns-design-patterns.md](architectural-patterns-design-patterns.md)** - Clean Architecture, Hexagonal, Layered, Event-Driven

## Common Scenarios

### Building a Web Application

1. **System architecture**: Start with [Architectural Patterns](architectural-patterns-design-patterns.md) - Layered or Clean Architecture
2. **Domain logic**: Use [Enterprise Patterns](enterprise-patterns-design-patterns.md) - Domain Model, Service Layer, Repository
3. **Object design**: Apply [GoF Patterns](gof-patterns-design-patterns.md) - Strategy, Factory, Decorator as needed

### Building Microservices

1. **Distributed transactions**: Use [Microservices Patterns](microservices-patterns-design-patterns.md) - Saga pattern
2. **Resilience**: Apply [Cloud Patterns](cloud-patterns-design-patterns.md) - Circuit Breaker, Retry
3. **Data management**: Use [Microservices Patterns](microservices-patterns-design-patterns.md) - CQRS, Event Sourcing

### Improving Existing Code

1. **Check**: [GoF Patterns](gof-patterns-design-patterns.md) for refactoring opportunities
2. **Domain complexity**: Consider [Enterprise Patterns](enterprise-patterns-design-patterns.md) - Domain Model, Service Layer
3. **Architecture**: Review [Architectural Patterns](architectural-patterns-design-patterns.md) for system-level improvements

## Pattern Categories Explained

### GoF Patterns (1994)

The original 23 design patterns from "Design Patterns: Elements of Reusable Object-Oriented Software" by Gang of Four (Gamma, Helm, Johnson, Vlissides).

- **Creational**: Object creation mechanisms (Singleton, Factory, Builder, Prototype, Abstract Factory)
- **Structural**: Object composition (Adapter, Bridge, Composite, Decorator, Facade, Flyweight, Proxy)
- **Behavioral**: Object interaction and responsibility (Observer, Strategy, Command, State, Chain of Responsibility, Iterator, Mediator, Memento, Template Method, Visitor, Interpreter)

### Enterprise Patterns (2002)

Martin Fowler's "Patterns of Enterprise Application Architecture" - 50+ patterns for building enterprise applications.

Key categories:
- Domain Logic Patterns
- Data Source Patterns
- Object-Relational Patterns
- Web Presentation Patterns
- Distribution Patterns
- Concurrency Patterns

### Microservices Patterns (2015+)

Patterns for distributed systems and microservices architecture.

Key patterns:
- Saga (distributed transactions)
- CQRS (command-query separation)
- Event Sourcing
- API Gateway
- Database per Service

### Cloud Patterns (2015+)

Patterns for building resilient, scalable cloud applications (Azure, AWS, GCP).

Key patterns:
- Retry (transient fault handling)
- Circuit Breaker (prevent cascading failures)
- Bulkhead (resource isolation)
- Cache-Aside (caching strategy)

### Architectural Patterns

High-level patterns for organizing entire systems.

Key patterns:
- Layered Architecture (classic n-tier)
- Clean Architecture (Uncle Bob)
- Hexagonal Architecture (Ports & Adapters)
- Event-Driven Architecture
- Microservices Architecture

## See Also

- [SOLID Principles](../solid-principles/solid-principles.md) - Design principles that complement patterns
- [Architecture Guide](../../architecture/index-architecture.md) - Architecture design and decisions
- [Feature Development](../../workflow/feature-development-workflow.md) - Applying patterns in feature development
