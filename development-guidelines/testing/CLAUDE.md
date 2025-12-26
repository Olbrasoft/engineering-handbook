# Testing - Claude Code

**You are:** Claude Code
**Topic:** Unit testing, integration testing, testing best practices

---

## Read This First

**Main guide:** [unit-testing-guide.md](unit-testing-guide.md)

This file contains:
- Database testing with in-memory databases
- Mocking dependencies (repositories, CQRS handlers, services)
- Test project structure and naming conventions
- Testing patterns used in Olbrasoft projects
- When to use different testing strategies

---

## Key Practices for You

**CRITICAL:** Never claim work is "completed" or "done" without passing tests.

- Applications using databases **MUST** have unit tests with in-memory databases
- Mock repositories, CQRS handlers, or services based on architecture
- Each source project has separate test project (`ProjectName.Tests`)
- All tests must pass before deployment
- Use xUnit + Moq + EF Core InMemory

---

**Next:** Read [unit-testing-guide.md](unit-testing-guide.md) for comprehensive testing guide.
