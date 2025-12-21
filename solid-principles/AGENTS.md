# SOLID Principles - Agent Index

**Area:** Object-oriented design principles  
**Parent:** [../AGENTS.md](../AGENTS.md)

---

## What's Here

Modern interpretation of SOLID principles for .NET development (2025 update).

---

## Quick Reference

### The Five Principles

| Principle | Abbreviation | Focus |
|-----------|--------------|-------|
| **Single Responsibility** | SRP | One class, one reason to change |
| **Open/Closed** | OCP | Open for extension, closed for modification |
| **Liskov Substitution** | LSP | Subtypes must be substitutable |
| **Interface Segregation** | ISP | Many small interfaces > one large |
| **Dependency Inversion** | DIP | Depend on abstractions, not concretions |

---

## Documents

### 1. `solid-principles-2025.md` (English - AI agents)
**Read when:**
- Designing new classes/interfaces
- Refactoring existing code
- Code review mentions design issues
- Need quick SOLID reference

**Length:** ~300 lines  
**Format:** Concise, examples, anti-patterns

### 2. `solid-principles-2025-cz.md` (Czech - humans)
**Read when:** Same as above, but detailed explanation needed

**Length:** ~600 lines  
**Format:** Detailed, Czech, well-formatted

### 3. `README.md` / `README-cz.md`
**Read when:** Overview of this directory

---

## When to Apply SOLID

### ✅ Good Use Cases

- **New feature development** - design from scratch
- **Refactoring** - improving existing code
- **High complexity** - managing dependencies
- **Testing** - making code testable
- **Team collaboration** - clear interfaces

### ⚠️ Don't Overthink

- **Simple scripts** - overkill for 50-line utility
- **Prototypes** - iterate first, refine later
- **Performance-critical** - pragmatism > purity

---

## Common Scenarios

### "My class is doing too much"
→ Read: **SRP section** in `solid-principles-2025.md`  
→ Split into focused classes

### "I need to modify code every time I add a feature"
→ Read: **OCP section**  
→ Use abstraction + composition

### "My unit tests are hard to write"
→ Read: **DIP section**  
→ Inject dependencies via interfaces

### "My interface has 20 methods"
→ Read: **ISP section**  
→ Split into role-based interfaces

### "I'm breaking tests when refactoring"
→ Read: **LSP section**  
→ Ensure substitutability

---

## Quick Examples

### Bad (Violates SRP)
```csharp
public class User
{
    public void SaveToDatabase() { }
    public void SendEmail() { }
    public void GenerateReport() { }
}
```

### Good (Follows SRP)
```csharp
public class User { } // Data only
public class UserRepository { void Save(User user); }
public class EmailService { void SendWelcome(User user); }
public class ReportGenerator { Report Generate(User user); }
```

---

### Bad (Violates DIP)
```csharp
public class OrderProcessor
{
    private SqlDatabase _db = new SqlDatabase(); // Concrete!
}
```

### Good (Follows DIP)
```csharp
public class OrderProcessor
{
    private readonly IDatabase _db; // Abstraction!
    public OrderProcessor(IDatabase db) => _db = db;
}
```

---

## Integration with Other Areas

### Using SOLID with Design Patterns
1. Read: **solid-principles-2025.md** (understand principles)
2. Read: **../design-patterns/AGENTS.md** (find applicable patterns)
3. Combine: Principles guide WHEN, Patterns guide HOW

### Using SOLID in Project Structure
1. Read: **../development-guidelines/dotnet-project-structure.md**
2. Apply: SOLID principles to organize code
3. Result: Clean architecture with clear boundaries

---

## Anti-Patterns to Avoid

| Anti-Pattern | SOLID Violation | Fix |
|--------------|----------------|-----|
| God Class | SRP | Split responsibilities |
| Tight Coupling | DIP | Inject abstractions |
| Fat Interface | ISP | Role-based interfaces |
| Fragile Base Class | LSP, OCP | Composition over inheritance |

---

## Checklist for Code Review

- [ ] Each class has single responsibility?
- [ ] New features added via extension (not modification)?
- [ ] Derived classes substitutable without breaking?
- [ ] Interfaces focused on single role?
- [ ] Dependencies on abstractions (not concrete types)?

---

## Document Structure

Both documents (`*.md` and `*-cz.md`) contain:
1. Overview of all 5 principles
2. Detailed explanation per principle
3. C# code examples
4. Anti-patterns
5. Modern interpretation (2025)
6. Practical guidance

**Difference:** English version is terse, Czech version is detailed.

---

## Token Optimization

**For AI agents:**
```
Don't load: Both *.md AND *-cz.md (duplicate content)
Do load: ONLY solid-principles-2025.md (English)

Savings: 50% tokens (300 lines vs 600 lines)
```

---

## Quick Commands

```bash
# Navigate here
cd ~/GitHub/Olbrasoft/engineering-handbook/solid-principles

# Read index (this file)
cat AGENTS.md

# Read main document
cat solid-principles-2025.md

# Search specific principle
grep -A 10 "Single Responsibility" solid-principles-2025.md
```

---

## Reference Links

- [SOLID Wikipedia](https://en.wikipedia.org/wiki/SOLID)
- [Martin Fowler on OCP](https://martinfowler.com/bliki/OpenClosedPrinciple.html)
- [Uncle Bob on SRP](https://blog.cleancoder.com/uncle-bob/2014/05/08/SingleReponsibilityPrinciple.html)

---

**Navigation:**  
⬆️ [Back to root](../AGENTS.md)  
➡️ [Development Guidelines](../development-guidelines/AGENTS.md)  
➡️ [Design Patterns](../design-patterns/AGENTS.md)
