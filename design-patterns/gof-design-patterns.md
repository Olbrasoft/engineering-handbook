# Gang of Four (GoF) Design Patterns – 2025 Cheat Sheet

All 23 classic design patterns with modern usage, real-world examples, and current relevance.

## 1. Creational Patterns

| Pattern             | Intent                                                                 | Key Participants                              | Modern Alternative / Note 2025                              | Real-World Example 2025                          | Usage Today (1–5) |
|---------------------|------------------------------------------------------------------------|-----------------------------------------------|-------------------------------------------------------------|--------------------------------------------------|-------------------|
| **Abstract Factory**| Provide an interface for creating families of related objects          | AbstractFactory, ConcreteFactory, Products    | Often replaced by DI containers (Spring, CDI, Guice)        | C# DI configuration for multiple environments    | ★★★☆☆ |
| **Builder** | Separate the construction of a complex object from its representation  | Builder, ConcreteBuilder, Director (optional) | Lombok `@Builder`, Fluent APIs, Record Component construction | C# `HttpClient.Builder`, Python data science pipelines | ★★★★★ |
| **Factory Method** | Define an interface for creating an object, let subclasses decide class| Creator, ConcreteCreator, Product             | DI + `@Qualifier`, functional `Supplier<T>` interfaces      | TypeScript factory functions for UI components   | ★★★★☆ |
| **Prototype** | Create new objects by copying an existing instance (cloning)           | Prototype with `clone()`                      | C# deep copy implementations, Python copy module, immutability | Configuration snapshotting (Dev → Prod copy)     | ★★☆☆☆ |
| **Singleton** | Ensure a class has only one instance and provide global access         | Private constructor + `getInstance()`         | Considered anti-pattern if manual → use DI `@Scope("singleton")` or `enum` | C# DI `AddSingleton`, Python module-level singletons | ★★★★☆ (via DI) |

## 2. Structural Patterns

| Pattern             | Intent                                                                           | Key Participants                              | Modern Alternative / Note 2025                              | Real-World Example 2025                          | Usage Today |
|---------------------|----------------------------------------------------------------------------------|-----------------------------------------------|-------------------------------------------------------------|--------------------------------------------------|-------------|
| **Adapter** | Convert the interface of a class into another interface clients expect           | Target, Adapter, Adaptee                      | MapStruct, Ports & Adapters Arch (Hexagonal), Wrapper Classes | C# SOAP → REST wrapper, Python data format conversion| ★★★★★ |
| **Bridge** | Decouple abstraction from implementation so both can vary independently          | Abstraction, Implementor                      | Still used in low-level drivers (Graphics APIs, File Systems)| JDBC API vs specific DB drivers                  | ★★☆☆☆ |
| **Composite** | Compose objects into tree structures; treat individual and compositions uniformly| Component, Leaf, Composite                    | Fundamental to all UI frameworks and XML/JSON parsing       | TypeScript/JavaScript DOM tree, React Component Trees| ★★★★★ |
| **Decorator** | Attach additional responsibilities to an object dynamically                      | Component, Decorator                          | Python/TypeScript decorators, C# attributes/middleware, AOP | ASP.NET Core Middleware, Python `@property` wrappers | ★★★★★ |
| **Facade** | Provide a unified, simpler interface to a complex subsystem                      | Facade, Subsystem classes                     | API Gateways, Service Layer encapsulating Repositories      | TypeScript API clients, Python SDK Wrappers      | ★★★★★ |
| **Flyweight** | Share large numbers of fine-grained objects efficiently                          | Flyweight, FlyweightFactory                   | Interning strings, Object Pools, caching immutable data     | C# `string.Intern()`, Python String Pool         | ★★★☆☆ |
| **Proxy** | Provide a surrogate or placeholder for another object                            | Subject, RealSubject, Proxy                   | C# lazy loading (EF Core), TypeScript gRPC stubs, AOP       | Database transaction proxies, Security wrappers  | ★★★★★ |

## 3. Behavioral Patterns

| Pattern             | Intent                                                                         | Key Participants                              | Modern Alternative / Note 2025                              | Real-World Example 2025                              | Usage Today |
|---------------------|--------------------------------------------------------------------------------|-----------------------------------------------|-------------------------------------------------------------|------------------------------------------------------|-------------|
| **Chain of Responsibility**| Pass request along a chain of handlers                                  | Handler, ConcreteHandler                      | Middleware pipelines, Interceptors, Filters                 | ASP.NET Core Middleware, Express.js (JS) pipeline    | ★★★★★ |
| **Command** | Encapsulate a request as an object (queues, undo, logging)                     | Command, Invoker, Receiver                    | Lambdas `() => {}`, CQRS, Job Queues (Kafka/RabbitMQ consumers)| TypeScript Redux Actions, C# `ICommand` (WPF/MVVM)   | ★★★★☆ |
| **Interpreter** | Define a grammar and interpreter for a simple language                         | AbstractExpression, Terminal/Nonterminal      | Replaced by RegEx, ANTLR, or standard expression languages  | C# Roslyn/Expression Trees, Python SpEL parsers      | ★☆☆☆☆ |
| **Iterator** | Provide sequential access without exposing underlying representation           | Iterator, Aggregate                           | Built-in: C# `yield return`, TypeScript iterators, Python Generators | C# `IEnumerable`, Python `for item in list`           | ★★★★★ |
| **Mediator** | Centralise communication between objects to reduce coupling                    | Mediator, Colleague                           | Event Bus, Message Brokers, State Management Stores         | TypeScript Redux store, C# MediatR library           | ★★★☆☆ |
| **Memento** | Capture and restore an object’s internal state without violating encapsulation | Originator, Memento, Caretaker                | Event Sourcing, Serialization snapshots                     | Editor Undo/Redo (JS), C# object serialization       | ★★★☆☆ |
| **Observer** | Define 1-to-many dependency – notify observers on state change                 | Subject, Observer                             | Reactive Streams (RxJS, Rx.NET), Kotlin Flow, Signals       | TypeScript/JavaScript DOM events, C# Rx.NET          | ★★★★★ |
| **State** | Allow object to alter behaviour when its internal state changes                | Context, State, ConcreteState                 | Finite State Machines (Spring Statemachine), Enums with logic| C# State Machine libraries, Python state management  | ★★★★☆ |
| **Strategy** | Define a family of algorithms, encapsulate each one, make them interchangeable | Context, Strategy                             | Functional Interfaces, Lambdas, Dependency Injection        | C# payment processing strategies, Python sorting keys| ★★★★★ |
| **Template Method** | Define skeleton of an algorithm, let subclasses override steps                 | AbstractClass, ConcreteClass                  | Lifecycle hooks, Default Interface Methods                  | ASP.NET Core `IHostedService` lifecycle, Python abstract classes | ★★★★☆ |
| **Visitor** | Separate algorithm from object structure (double dispatch)                     | Visitor, Element                              | **Pattern Matching** (C# 11+, TypeScript discriminated unions), functional decomposition| AST analysis, C# Roslyn traversals                   | ★★☆☆☆ |

## Current Trends 2025
- **Dominant Patterns**: Builder, Strategy, Observer (Reactive), Decorator, Facade, Adapter, Chain of Responsibility.
- **Decline of Manual Implementation**: Patterns like Singleton, Factory, and Proxy are now largely handled by Frameworks (C#/.NET Core DI) or Language Features (Records, Enums).
- **Functional Paradigm Shift**: Many behavioral patterns (Command, Strategy, Template) are now implemented using Lambdas and Higher-Order Functions, which is highly prevalent in **JavaScript**, **TypeScript**, and **Python**.
- **Pattern Matching Replacement**: The classic Visitor pattern is rapidly being replaced by modern Pattern Matching features in **C#**, **Python**, and other languages.

---

## 📦 Examples from Olbrasoft Projects

### Strategy Pattern
**Project:** `VirtualAssistant.PushToTalk`  
**What it demonstrates:** Runtime selection of mouse button monitoring strategy.
- **Context:** Different X11 event codes for left/middle/right mouse buttons.
- **Implementation:** `IMouseButtonMonitor` interface with concrete strategies for each button. A factory chooses the right strategy based on configuration.

### Factory Pattern (via DI)
**Project:** `NotificationAudio`  
**What it demonstrates:** Decoupling the player from specific audio tools.
- **Context:** Using `Paplay` or `Ffplay` depending on availability.
- **Implementation:** Providers are registered in the DI container. The `NotificationPlayer` receives a collection of `IPlaybackProvider` and picks the best one at runtime.

### Decorator Pattern (Middleware)
**Project:** `VirtualAssistant` (Web API part)  
**What it demonstrates:** Adding cross-cutting concerns without modifying controllers.
- **Implementation:** Using ASP.NET Core Middleware for logging, authentication, and exception handling.

---

## ✅ Before You Start - Design Patterns

- [ ] I've identified the core problem I'm trying to solve (e.g., "I need interchangeable algorithms").
- [ ] I've checked if a built-in language feature (like Lambdas or Pattern Matching) can solve it more simply.
- [ ] I've looked at `VirtualAssistant` or `TextToSpeech` to see if we've already used this pattern.
- [ ] I understand the trade-off (e.g., a pattern might introduce more classes but reduce coupling).
- [ ] I've verified that my pattern choice aligns with the project's architecture (check `CLAUDE.md`).

---

## Related Topics

- 🏗️ [Architecture Design](../development-guidelines/architecture-design.md) - Choosing the right pattern for the approach
- 🧱 [SOLID Principles](../solid-principles/solid-principles.md) - The foundation for clean patterns
- 🔍 [Code Review](../development-guidelines/code-review-refactoring-guide.md) - Evaluating pattern implementation
