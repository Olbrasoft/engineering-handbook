## Testing

### Test Statistics

- **Total Tests**: 393+
- **Framework**: xUnit
- **Mocking**: Moq
- **Coverage**: Business logic, CQRS handlers, services

### Test Projects

```
test/
├── Olbrasoft.GitHub.Issues.Data.Tests/
├── Olbrasoft.GitHub.Issues.Data.EntityFrameworkCore.Tests/
├── Olbrasoft.GitHub.Issues.Business.Tests/
├── Olbrasoft.GitHub.Issues.Sync.Tests/
└── Olbrasoft.GitHub.Issues.AspNetCore.RazorPages.Tests/
```

### Running Tests

```bash
# Run all tests (integration tests skip automatically on CI)
dotnet test --verbosity minimal

# Run specific test project
dotnet test test/Olbrasoft.GitHub.Issues.Business.Tests
```

### Integration Tests

Integration tests use `[SkipOnCIFact]` attribute from NuGet package `Olbrasoft.Testing.Xunit.Attributes`.

**How it works**:
- Attribute **automatically detects CI environment** (GitHub Actions, Azure DevOps)
- On CI: Integration tests **skip automatically**
- Locally: Integration tests **run normally**

**Why**: Integration tests call external APIs (GitHub, Cohere) → cannot run on CI without API keys.

**More info**: https://github.com/Olbrasoft/Testing

---

