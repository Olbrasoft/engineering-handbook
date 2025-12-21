# Design Patterns - Agent Index

**Area:** Gang of Four (GoF) design patterns  
**Parent:** [../AGENTS.md](../AGENTS.md)

---

## What's Here

Modern .NET implementations of 23 Gang of Four design patterns (2025 update).

---

## Quick Reference

### Pattern Categories

| Category | Purpose | Patterns |
|----------|---------|----------|
| **Creational** | Object creation | Singleton, Factory, Builder, Prototype, Abstract Factory |
| **Structural** | Object composition | Adapter, Bridge, Composite, Decorator, Facade, Flyweight, Proxy |
| **Behavioral** | Object interaction | Observer, Strategy, Command, Iterator, Mediator, Memento, State, Template Method, Visitor, Chain of Responsibility, Interpreter |

---

## Documents

### 1. `gof-design-patterns-2025.md` (English - AI agents)
**Read when:**
- Implementing specific pattern
- Refactoring to pattern-based solution
- Need pattern quick reference
- Code review suggests pattern usage

**Length:** ~800 lines  
**Format:** Concise catalog, C# examples, when to use

### 2. `gof-design-patterns-2025-cz.md` (Czech - humans)
**Read when:** Same as above, but detailed explanation needed

**Length:** ~1500 lines  
**Format:** Detailed, Czech, comprehensive examples

### 3. `README.md` / `README-cz.md`
**Read when:** Overview of this directory

---

## Pattern Finder

### "I need to..."

#### Create Objects
- **One instance only** → Singleton
- **Create similar objects** → Factory Method
- **Complex object step-by-step** → Builder
- **Copy existing object** → Prototype
- **Family of related objects** → Abstract Factory

#### Structure Code
- **Incompatible interfaces** → Adapter
- **Separate abstraction/implementation** → Bridge
- **Tree structures** → Composite
- **Add behavior dynamically** → Decorator
- **Simplify complex subsystem** → Facade
- **Share objects efficiently** → Flyweight
- **Control access to object** → Proxy

#### Manage Behavior
- **Notify multiple objects of changes** → Observer
- **Swap algorithms** → Strategy
- **Encapsulate requests** → Command
- **Traverse collection** → Iterator
- **Mediate object interactions** → Mediator
- **Save/restore state** → Memento
- **State-dependent behavior** → State
- **Define algorithm skeleton** → Template Method
- **Operate on object structure** → Visitor
- **Chain of handlers** → Chain of Responsibility

---

## Common Scenarios

### "I have multiple notification subscribers"
→ Read: **Observer pattern**  
→ Implement: Event-driven architecture

### "I need different payment methods"
→ Read: **Strategy pattern**  
→ Inject: `IPaymentStrategy` interface

### "I'm building complex API requests"
→ Read: **Builder pattern**  
→ Fluent API: `request.WithAuth().WithRetry().Build()`

### "I need to add logging without modifying classes"
→ Read: **Decorator pattern**  
→ Wrap: `new LoggingService(new DataService())`

### "I want one configuration manager"
→ Read: **Singleton pattern**  
→ Use: DI container with `.AddSingleton<IConfig, Config>()`

---

## Modern .NET Considerations

### Built-in Pattern Support

| Pattern | .NET Feature |
|---------|--------------|
| **Singleton** | `services.AddSingleton<T>()` |
| **Factory** | `services.AddTransient<T>()` |
| **Observer** | `IObservable<T>`, `IObserver<T>`, events |
| **Iterator** | `IEnumerable<T>`, `yield return` |
| **Decorator** | Middleware pipeline (ASP.NET) |
| **Strategy** | Dependency injection |
| **Command** | `MediatR` library |

### When NOT to Use Patterns

- **Over-engineering** - Simple problem doesn't need complex pattern
- **Performance** - Pattern adds overhead (measure first!)
- **Team unfamiliarity** - Prefer simpler, known solutions

---

## Integration with SOLID

Patterns often implement SOLID principles:

| Pattern | SOLID Principle |
|---------|----------------|
| Strategy | OCP (Open/Closed) |
| Decorator | OCP (Open/Closed) |
| Adapter | ISP (Interface Segregation) |
| Factory | DIP (Dependency Inversion) |
| Template Method | OCP (Open/Closed) |

**Workflow:**
1. Read: **../solid-principles/AGENTS.md** (understand principles)
2. Read: **gof-design-patterns-2025.md** (find pattern)
3. Apply: Pattern implements principle

---

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Better Approach |
|--------------|---------|----------------|
| **Pattern for pattern's sake** | Complexity without benefit | Use only when needed |
| **Wrong pattern** | Doesn't fit problem | Understand problem first |
| **Multiple patterns at once** | Confusion | One pattern at a time |
| **Ignoring .NET features** | Reinventing wheel | Use built-in support |

---

## Quick Examples

### Factory Pattern (Modern .NET)
```csharp
// Bad: New everywhere
var service = new EmailService(config);

// Good: Factory via DI
services.AddTransient<INotificationService, EmailService>();
var service = provider.GetRequiredService<INotificationService>();
```

### Observer Pattern (Modern .NET)
```csharp
// Bad: Manual list management
List<IObserver> observers = new();

// Good: Events or IObservable<T>
public event EventHandler<DataChangedArgs> DataChanged;
// OR
IObservable<Data> observable = Observable.Create<Data>(...);
```

### Strategy Pattern (DI)
```csharp
// Define strategies
public interface IPaymentStrategy { void Pay(decimal amount); }
public class CreditCardPayment : IPaymentStrategy { }
public class PayPalPayment : IPaymentStrategy { }

// Inject
public class CheckoutService
{
    private readonly IPaymentStrategy _payment;
    public CheckoutService(IPaymentStrategy payment) => _payment = payment;
}
```

---

## Document Structure

Both documents contain:
1. Overview of 23 GoF patterns
2. Category breakdown (Creational/Structural/Behavioral)
3. Per-pattern:
   - Intent
   - When to use
   - C# implementation
   - Modern .NET approach
   - Example code

**Difference:** English version is catalog-style, Czech version is tutorial-style.

---

## Token Optimization

**For AI agents:**
```
Don't load: Entire document (800+ lines)
Do load: Only relevant pattern section

Example: Need Observer pattern
→ grep -A 30 "Observer Pattern" gof-design-patterns-2025.md

Savings: 95% tokens (30 lines vs 800 lines)
```

---

## Checklist for Pattern Usage

- [ ] Problem clearly understood?
- [ ] Pattern fits problem domain?
- [ ] Team familiar with pattern?
- [ ] Simpler solution doesn't exist?
- [ ] .NET doesn't already provide this? (check first!)

---

## Quick Commands

```bash
# Navigate here
cd ~/GitHub/Olbrasoft/engineering-handbook/design-patterns

# Read index (this file)
cat AGENTS.md

# Find specific pattern
grep -A 20 "Singleton" gof-design-patterns-2025.md

# List all patterns
grep "^### " gof-design-patterns-2025.md

# Search by category
grep -A 50 "Creational Patterns" gof-design-patterns-2025.md
```

---

## Reference Links

- [Gang of Four Book](https://en.wikipedia.org/wiki/Design_Patterns)
- [Refactoring.Guru Patterns](https://refactoring.guru/design-patterns)
- [Microsoft: Design Patterns](https://learn.microsoft.com/en-us/azure/architecture/patterns/)

---

**Navigation:**  
⬆️ [Back to root](../AGENTS.md)  
➡️ [Development Guidelines](../development-guidelines/AGENTS.md)  
➡️ [SOLID Principles](../solid-principles/AGENTS.md)
