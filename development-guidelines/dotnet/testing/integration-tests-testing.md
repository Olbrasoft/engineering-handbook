# Integration Tests

How to write integration tests that call real services and are skipped on CI.

## What are Integration Tests?

**Integration test** = Test that calls **real external services** (APIs, databases, file system).

**Key differences from unit tests:**
- ❌ **NO mocking** - uses real services
- ❌ **NO in-memory database** - uses real database
- ✅ **MUST use** `[SkipOnCIFact]` attribute
- ⚠️ **Slower** - calls real services over network
- ⚠️ **Requires** external dependencies running

## When to Write Integration Tests

| Scenario | Integration Tests? |
|----------|-------------------|
| **LLM API calls** (OpenAI, Mistral, etc.) | ✅ YES - expensive, skip on CI |
| **External APIs** (payment, email, etc.) | ✅ YES - real endpoints |
| **Real database** operations | ✅ YES (for final verification) |
| **File system** operations | ⚠️ Optional |
| Business logic | ❌ NO - use unit tests |

**Rule:** Use integration tests to verify **real service integration**, not business logic.

## Required Package

### Olbrasoft.Testing.Xunit.Attributes

**Package:** `Olbrasoft.Testing.Xunit.Attributes`

```xml
<ItemGroup>
  <PackageReference Include="Olbrasoft.Testing.Xunit.Attributes" Version="1.*" />
</ItemGroup>
```

**What it provides:**
- `[SkipOnCIFact]` - Skip `[Fact]` tests on CI
- `[SkipOnCITheory]` - Skip `[Theory]` tests on CI

### How It Works

The attribute automatically detects CI environments and skips tests:

```csharp
using Olbrasoft.Testing.Xunit.Attributes;

public class LlmChainIntegrationTests
{
    [SkipOnCIFact] // ← Automatically skipped on GitHub Actions, Azure DevOps, etc.
    public async Task CompleteAsync_WithRealAPI_ReturnsResponse()
    {
        // This test calls real LLM API
        // Runs locally, skipped on CI to save costs
    }
}
```

**Detects these CI environments:**
- GitHub Actions
- Azure DevOps
- GitLab CI
- Jenkins
- Travis CI
- AppVeyor
- And more

## Integration Test Structure

### Project Naming

**Pattern:** `{Project}.IntegrationTests`

**Example:**
```
tests/
├── VirtualAssistant.LlmChain.Tests/              # Unit tests
└── VirtualAssistant.LlmChain.IntegrationTests/   # Integration tests
```

**CRITICAL:** Separate projects! Integration tests have different dependencies.

### Configuration File

**File:** `appsettings.integrationtests.json`

```json
{
  "LlmChain": {
    "Providers": [
      {
        "Name": "Mistral",
        "Type": "Mistral",
        "Endpoint": "https://api.mistral.ai/v1/chat/completions",
        "ApiKey": "loaded-from-secrets"
      }
    ]
  }
}
```

**NEVER commit real API keys!** Load from environment or user secrets.

## Example: LLM API Integration Test

```csharp
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Olbrasoft.Testing.Xunit.Attributes;
using VirtualAssistant.LlmChain;
using Xunit.Abstractions;

namespace VirtualAssistant.LlmChain.IntegrationTests;

/// <summary>
/// Integration tests for LlmChainClient.
/// These tests call real LLM APIs and are skipped on CI environments.
/// </summary>
public class LlmChainIntegrationTests
{
    private readonly ITestOutputHelper _output;
    private readonly ILlmChainClient _client;

    public LlmChainIntegrationTests(ITestOutputHelper output)
    {
        _output = output;

        // Load configuration from appsettings.integrationtests.json
        var configuration = new ConfigurationBuilder()
            .SetBasePath(GetProjectRoot())
            .AddJsonFile("appsettings.integrationtests.json", optional: false)
            .Build();

        var services = new ServiceCollection();
        services.AddLogging(builder => builder.AddXUnit(output));
        services.AddLlmChain(configuration);

        var provider = services.BuildServiceProvider();
        _client = provider.GetRequiredService<ILlmChainClient>();
    }

    [SkipOnCIFact] // ← CRITICAL: Skips on CI to save API costs
    public async Task CompleteAsync_WithValidRequest_ReturnsSuccess()
    {
        // Arrange
        var request = new LlmChainRequest
        {
            SystemPrompt = "You are a helpful assistant. Respond in one short sentence.",
            UserMessage = "Say hello in Czech.",
            Temperature = 0.3f,
            MaxTokens = 50
        };

        // Act - CALLS REAL API!
        var result = await _client.CompleteAsync(request);

        // Assert
        Assert.True(result.Success, $"Expected success but got: {result.Error}");
        Assert.NotNull(result.Content);
        Assert.NotEmpty(result.Content);
        Assert.NotNull(result.ProviderName);

        _output.WriteLine($"Provider: {result.ProviderName}");
        _output.WriteLine($"Key: {result.KeyIdentifier}");
        _output.WriteLine($"Response time: {result.ResponseTimeMs}ms");
        _output.WriteLine($"Content: {result.Content}");
    }

    private static string GetProjectRoot()
    {
        var dir = Directory.GetCurrentDirectory();
        while (dir != null && !File.Exists(Path.Combine(dir, "appsettings.integrationtests.json")))
        {
            dir = Directory.GetParent(dir)?.FullName;
        }
        return dir ?? Directory.GetCurrentDirectory();
    }
}
```

## Running Integration Tests

### Locally (Manual)

```bash
# Run ALL tests (including integration tests)
dotnet test

# Run ONLY integration tests
dotnet test --filter "FullyQualifiedName~IntegrationTests"

# Run specific integration test
dotnet test --filter "FullyQualifiedName~CompleteAsync_WithValidRequest"
```

**Why run manually?**
- Costs money (API calls)
- Requires real services running
- Slower than unit tests

### On CI (Automatically Skipped)

```bash
# On GitHub Actions - integration tests are SKIPPED
dotnet test --filter "FullyQualifiedName!~IntegrationTests"
```

**See:** [CI Testing](../continuous-integration/test-continuous-integration.md) for CI configuration.

## Filtering Tests in CI

### GitHub Actions Workflow

**File:** `.github/workflows/build.yml`

```yaml
- name: Run Tests
  run: |
    # Exclude integration tests from CI runs
    dotnet test --filter "FullyQualifiedName!~IntegrationTests"
```

**Why filter?**
- Integration tests are already skipped by `[SkipOnCIFact]`
- Filtering is extra safety
- Faster CI runs (doesn't even load integration test assemblies)

### VirtualAssistant CLAUDE.md Example

From `/home/jirka/Olbrasoft/VirtualAssistant/CLAUDE.md`:

```bash
# Test (MUST pass before deployment)
dotnet test --filter "FullyQualifiedName!~IntegrationTests"
```

This ensures integration tests NEVER run in CI/CD pipelines.

## Best Practices

### ✅ DO

- ✅ **Use `[SkipOnCIFact]`** on ALL integration tests
- ✅ **Separate project** for integration tests
- ✅ **Configuration file** for test settings
- ✅ **Run manually** before committing
- ✅ **Document** what external services are needed

### ❌ DON'T

- ❌ **Run in CI** - wastes money and time
- ❌ **Commit API keys** - use secrets
- ❌ **Test business logic** - use unit tests instead
- ❌ **Mix with unit tests** - separate projects

## When Integration Tests Fail

### Local Failure

**Possible causes:**
- External service is down
- API key expired/invalid
- Network issues
- Service rate limit hit

**Solution:**
1. Check service status
2. Verify API keys
3. Check network connectivity
4. Wait and retry (rate limits)

### CI "Failure" (Expected)

**Integration tests should be SKIPPED on CI, not failed!**

If integration test runs on CI:
1. Missing `[SkipOnCIFact]` attribute
2. Wrong test filter in workflow
3. Package `Olbrasoft.Testing.Xunit.Attributes` not installed

## Checklist

Before committing integration tests:

- [ ] Test project name ends with `.IntegrationTests`
- [ ] `Olbrasoft.Testing.Xunit.Attributes` package installed
- [ ] ALL integration tests have `[SkipOnCIFact]` or `[SkipOnCITheory]`
- [ ] Configuration file `appsettings.integrationtests.json` exists
- [ ] No real API keys committed to repo
- [ ] Tests pass locally (manually run)
- [ ] CI workflow filters out integration tests

## See Also

- [Unit Tests](unit-tests-testing.md) - Isolated tests with mocking
- [Testing Index](index-testing.md) - Overview of all testing guides
- [CI Testing](../continuous-integration/test-continuous-integration.md) - Running tests in GitHub Actions
