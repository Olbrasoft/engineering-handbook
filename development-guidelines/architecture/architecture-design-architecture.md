# Architecture Design & Trade-offs

During Phase 4 of the [Feature Development Workflow](../workflow/feature-development-workflow.md), you must evaluate different technical approaches. Use this framework to compare trade-offs.

---

## 🏛️ The Three Approaches

### 1. Minimal Changes (Pragmatic/Fast)
**Focus:** Solving the problem with the least amount of code.
- **Pros:** Fast implementation, minimal surface area for new bugs.
- **Cons:** May lead to technical debt, might violate some abstractions.
- **Use when:** Quick fixes, experimental features, or when the existing code is already well-structured.

### 2. Clean Architecture (Future-proof)
**Focus:** Perfect adherence to SOLID and project patterns.
- **Pros:** Highly maintainable, testable, and scalable.
- **Cons:** Takes longer to build, may introduce "boilerplate" for simple tasks.
- **Use when:** Core business logic, features that will be expanded, or when refactoring a "God class".

### 3. Pragmatic Balance (Recommended)
**Focus:** Clean design for core logic, minimal changes for the "plumbing".
- **Pros:** Best of both worlds.
- **Cons:** Requires experience to find the right balance.

---

## 📊 Trade-off Analysis Framework

When proposing an architecture, evaluate these factors:

| Factor | High Cleanliness | High Speed |
|--------|------------------|------------|
| **Maintainability** | ✅ High | ❌ Low |
| **Testability** | ✅ High | ⚠️ Moderate |
| **Development Speed** | ⚠️ Low | ✅ High |
| **Complexity** | ⚠️ Higher | ✅ Lower |

---

## 📦 Examples from Olbrasoft Projects

### Strategy Pattern for Monitors

**Project:** VirtualAssistant  
**Location:** `VirtualAssistant.PushToTalk/Monitors/`  
**What it demonstrates:** Choosing Strategy pattern over a large `if/else` block.

**Context:** We needed to support different mouse buttons (Left/Middle/Right) for PTT.
- **Minimal approach (Rejected):** A single class with a large switch statement.
- **Clean approach (Chosen):** `IMouseButtonMonitor` interface with separate classes for each button.

**Why:** It allowed us to add support for new buttons (or different OS backends) without touching existing logic.

---

## ✅ Before You Start - Architecture Design

- [ ] I have considered at least two different approaches.
- [ ] I can explain the trade-offs between my chosen approach and the alternative.
- [ ] My design follows existing project patterns (check `CLAUDE.md` in the project).
- [ ] I've identified which files will be created vs. modified.
