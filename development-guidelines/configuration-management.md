# Configuration Management

Best practices for managing configuration data, prompts, templates, and external content in .NET projects.

---

## Core Principle: Separation of Code and Configuration

**CRITICAL:** Configuration data, prompts, templates, and content MUST be separate from code.

### What Belongs Outside Code

❌ **NEVER hardcode these in C# strings:**
- LLM prompts and system messages
- Markdown templates
- Email templates
- Configuration text
- User-facing messages (use resources for localization)
- Large text blocks
- JSON/XML schemas

✅ **Always externalize:**
- Store in configuration files
- Embed as resources
- Load from external files
- Use configuration providers

---

## Why Separate Configuration from Code

### 1. **Maintainability**
```csharp
// ❌ BAD: 100+ line prompt hardcoded in C#
private const string SystemPrompt = @"You are an expert...
[100 lines of markdown]
...";
```

**Problems:**
- Difficult to read and maintain
- No syntax highlighting for markdown
- Git diffs are messy
- Cannot reuse in other projects
- No validation for markdown syntax

```csharp
// ✅ GOOD: Load from embedded resource
var prompt = await _promptLoader.LoadAsync("Prompts.MistralSystemPrompt.md");
```

**Benefits:**
- Edit in dedicated markdown file with syntax highlighting
- Version control shows clear diffs
- Can test/validate markdown separately
- Reusable across projects

### 2. **Separation of Concerns**
- **Code** = logic, algorithms, control flow
- **Configuration** = data, parameters, content
- **SOLID principle:** Configuration changes shouldn't require code changes

### 3. **Testability**
```csharp
// ✅ GOOD: Test with different prompts
[Fact]
public async Task CorrectText_WithCustomPrompt_UsesProvidedPrompt()
{
    var testPrompt = "Test prompt";
    var service = new MistralProvider(_mockPromptLoader.Object);

    _mockPromptLoader
        .Setup(l => l.LoadAsync("Prompts.MistralSystemPrompt.md"))
        .ReturnsAsync(testPrompt);

    // Can now test with different prompts without changing code
}
```

### 4. **Reusability**
- Share prompts between projects
- Version prompts independently
- A/B test different prompts without code changes

---

## Where to Store Configuration

### Decision Tree

```
Is it a SECRET (API key, password)?
├─ YES → Use secrets management (see secrets-management.md)
└─ NO → Continue...

Is it user-configurable at runtime?
├─ YES → appsettings.json or database
└─ NO → Continue...

Is it large text content (>50 lines)?
├─ YES → Embedded resource (.md, .txt)
└─ NO → appsettings.json or constants
```

### Option 1: appsettings.json (Simple Configuration)

**Use for:**
- Simple key-value pairs
- Runtime-configurable settings
- Environment-specific config

**Example:**
```json
{
  "Mistral": {
    "Model": "mistral-large-latest",
    "Temperature": 0.7,
    "MaxTokens": 1000,
    "TimeoutSeconds": 30
  }
}
```

```csharp
// Configuration class
public class MistralOptions
{
    public string Model { get; set; } = string.Empty;
    public double Temperature { get; set; }
    public int MaxTokens { get; set; }
    public int TimeoutSeconds { get; set; }
}

// Registration in Program.cs
services.Configure<MistralOptions>(
    builder.Configuration.GetSection("Mistral"));

// Usage via dependency injection
public class MistralProvider
{
    private readonly MistralOptions _options;

    public MistralProvider(IOptions<MistralOptions> options)
    {
        _options = options.Value;
    }
}
```

**✅ Good for:** Numbers, booleans, short strings, URLs
**❌ Bad for:** Large text blocks, markdown, templates

### Option 2: Embedded Resources (Large Text Content)

**Use for:**
- LLM prompts
- Markdown templates
- Email templates
- Large text blocks
- JSON/XML schemas

**Structure:**
```
src/ProjectName.Core/
├── Prompts/
│   ├── MistralSystemPrompt.md
│   ├── GeminiSystemPrompt.md
│   └── PromptLoader.cs
├── Templates/
│   ├── EmailWelcome.html
│   └── ReportTemplate.md
```

**Step 1: Add files to .csproj**
```xml
<ItemGroup>
  <EmbeddedResource Include="Prompts\*.md" />
  <EmbeddedResource Include="Templates\*.html" />
</ItemGroup>
```

**Step 2: Create loader service**
```csharp
public interface IPromptLoader
{
    Task<string> LoadAsync(string resourceName);
}

public class EmbeddedPromptLoader : IPromptLoader
{
    private readonly Assembly _assembly;

    public EmbeddedPromptLoader()
    {
        _assembly = typeof(EmbeddedPromptLoader).Assembly;
    }

    public async Task<string> LoadAsync(string resourceName)
    {
        var fullName = $"{_assembly.GetName().Name}.{resourceName}";

        await using var stream = _assembly.GetManifestResourceStream(fullName)
            ?? throw new FileNotFoundException(
                $"Embedded resource not found: {fullName}");

        using var reader = new StreamReader(stream);
        return await reader.ReadToEndAsync();
    }
}
```

**Step 3: Register service**
```csharp
// Program.cs
services.AddSingleton<IPromptLoader, EmbeddedPromptLoader>();
```

**Step 4: Use in your code**
```csharp
public class MistralProvider
{
    private readonly IPromptLoader _promptLoader;
    private string? _systemPrompt;

    public MistralProvider(IPromptLoader promptLoader)
    {
        _promptLoader = promptLoader;
    }

    private async Task<string> GetSystemPromptAsync()
    {
        _systemPrompt ??= await _promptLoader.LoadAsync(
            "Prompts.MistralSystemPrompt.md");
        return _systemPrompt;
    }

    public async Task<string> CorrectTextAsync(string text)
    {
        var systemPrompt = await GetSystemPromptAsync();

        var request = new
        {
            messages = new[]
            {
                new { role = "system", content = systemPrompt },
                new { role = "user", content = text }
            }
        };

        // ... rest of implementation
    }
}
```

**✅ Good for:** Large text, markdown, templates, reusable content
**❌ Bad for:** Frequently changing config, user-editable content

### Option 3: External Files (User-Editable Content)

**Use for:**
- User-customizable prompts
- Templates that users can edit
- Content that changes frequently

**Structure:**
```
/opt/olbrasoft/myapp/
├── app/
│   └── myapp
├── config/
│   ├── appsettings.json
│   └── prompts/
│       ├── system-prompt.md
│       └── user-prompt-template.md
```

**Implementation:**
```csharp
public class FilePromptLoader : IPromptLoader
{
    private readonly string _promptsDirectory;

    public FilePromptLoader(IConfiguration config)
    {
        _promptsDirectory = config["PromptsDirectory"]
            ?? Path.Combine(AppContext.BaseDirectory, "prompts");
    }

    public async Task<string> LoadAsync(string fileName)
    {
        var path = Path.Combine(_promptsDirectory, fileName);

        if (!File.Exists(path))
            throw new FileNotFoundException(
                $"Prompt file not found: {path}");

        return await File.ReadAllTextAsync(path);
    }
}
```

**✅ Good for:** User-editable content, frequently changing config
**❌ Bad for:** Deployment complexity, requires external file management

### Option 4: Database (Dynamic Configuration)

**Use for:**
- Multi-tenant configurations
- A/B testing different prompts
- User-specific customizations
- Configuration versioning

**Example from PushToTalk:**
```csharp
public class DatabaseMistralOptionsSetup : IConfigureOptions<MistralOptions>
{
    private readonly IServiceProvider _serviceProvider;

    public void Configure(MistralOptions options)
    {
        using var scope = _serviceProvider.CreateScope();
        var dbContext = scope.ServiceProvider
            .GetRequiredService<PushToTalkDbContext>();

        var config = dbContext.MistralConfigs
            .Where(c => c.IsActive)
            .OrderByDescending(c => c.CreatedAt)
            .FirstOrDefault();

        if (config == null)
            throw new InvalidOperationException(
                "No active Mistral configuration found");

        options.ApiKey = config.ApiKey;
        options.Model = config.Model;
        options.BaseUrl = config.BaseUrl;
    }
}
```

**✅ Good for:** Multi-tenant, A/B testing, versioning
**❌ Bad for:** Simple single-instance apps, static content

---

## Best Practices

### 1. LLM Prompts

**Structure:**
```
src/ProjectName.Core/
├── Prompts/
│   ├── README.md                    # Document prompt purpose
│   ├── MistralSystemPrompt.md       # Actual prompt
│   └── MistralSystemPrompt.Tests.md # Test cases
```

**Prompt file example:**
```markdown
<!-- Prompts/MistralSystemPrompt.md -->
# Mistral System Prompt for Czech ASR Correction

**Purpose:** Correct Czech transcriptions from Whisper ASR

**Version:** 2.0
**Last updated:** 2025-12-27

---

You are an expert on correcting Czech ASR transcriptions...

## Rules

1. Fix common phonetic errors
2. Correct grammar
3. Maintain original meaning

## Examples

**Input:** "máme bash soubory v lokálu llomenobin"
**Output:** "máme bashové soubory v `~/.local/bin/`"

---

[Actual prompt content here]
```

**Testing:**
```csharp
[Fact]
public async Task SystemPrompt_LoadsSuccessfully()
{
    // Verify prompt can be loaded
    var prompt = await _promptLoader.LoadAsync(
        "Prompts.MistralSystemPrompt.md");

    Assert.NotEmpty(prompt);
    Assert.Contains("Czech ASR", prompt);
}

[Fact]
public async Task SystemPrompt_ContainsRequiredSections()
{
    var prompt = await _promptLoader.LoadAsync(
        "Prompts.MistralSystemPrompt.md");

    Assert.Contains("## Rules", prompt);
    Assert.Contains("## Examples", prompt);
}
```

### 2. Version Control

**Track prompt changes:**
```bash
git log --follow -- src/ProjectName.Core/Prompts/MistralSystemPrompt.md
```

**Document changes:**
```markdown
<!-- Prompts/MistralSystemPrompt.md -->
# Changelog

## [2.0] - 2025-12-27
- Added rules for code formatting (backticks)
- Improved examples for paths

## [1.0] - 2025-12-20
- Initial version
```

### 3. Validation

**Validate prompts on startup:**
```csharp
public class PromptValidationService : IHostedService
{
    private readonly IPromptLoader _promptLoader;

    public async Task StartAsync(CancellationToken ct)
    {
        // Validate all prompts exist and are valid
        var requiredPrompts = new[]
        {
            "Prompts.MistralSystemPrompt.md",
            "Prompts.GeminiSystemPrompt.md"
        };

        foreach (var prompt in requiredPrompts)
        {
            var content = await _promptLoader.LoadAsync(prompt);

            if (string.IsNullOrWhiteSpace(content))
                throw new InvalidOperationException(
                    $"Prompt is empty: {prompt}");
        }
    }

    public Task StopAsync(CancellationToken ct) => Task.CompletedTask;
}
```

### 4. Caching

**Cache loaded prompts:**
```csharp
public class CachedPromptLoader : IPromptLoader
{
    private readonly IPromptLoader _inner;
    private readonly ConcurrentDictionary<string, string> _cache = new();

    public async Task<string> LoadAsync(string resourceName)
    {
        return await _cache.GetOrAdd(resourceName,
            async key => await _inner.LoadAsync(key));
    }
}
```

---

## Migration Guide

### From Hardcoded Strings to Embedded Resources

**Step 1: Extract to file**
```csharp
// Before: Hardcoded in MistralProvider.cs
private const string SystemPrompt = @"You are an expert...";
```

Create `src/ProjectName.Core/Prompts/MistralSystemPrompt.md`:
```markdown
You are an expert...
```

**Step 2: Add to .csproj**
```xml
<ItemGroup>
  <EmbeddedResource Include="Prompts\*.md" />
</ItemGroup>
```

**Step 3: Create loader**
```csharp
public interface IPromptLoader
{
    Task<string> LoadAsync(string resourceName);
}

public class EmbeddedPromptLoader : IPromptLoader
{
    // ... (see example above)
}
```

**Step 4: Update service**
```csharp
public class MistralProvider
{
    private readonly IPromptLoader _promptLoader;
    private string? _systemPrompt;

    public MistralProvider(IPromptLoader promptLoader)
    {
        _promptLoader = promptLoader;
    }

    private async Task<string> GetSystemPromptAsync()
    {
        _systemPrompt ??= await _promptLoader.LoadAsync(
            "Prompts.MistralSystemPrompt.md");
        return _systemPrompt;
    }
}
```

**Step 5: Register in DI**
```csharp
services.AddSingleton<IPromptLoader, EmbeddedPromptLoader>();
```

**Step 6: Update tests**
```csharp
[Fact]
public async Task CorrectText_LoadsPromptFromResource()
{
    var mockLoader = new Mock<IPromptLoader>();
    mockLoader
        .Setup(l => l.LoadAsync("Prompts.MistralSystemPrompt.md"))
        .ReturnsAsync("Test prompt");

    var provider = new MistralProvider(mockLoader.Object);

    // Test with mocked prompt
}
```

---

## Examples from Olbrasoft Projects

### PushToTalk (BEFORE - Hardcoded)

```csharp
// ❌ BAD: 135 lines hardcoded in MistralProvider.cs
private const string SystemPrompt = @"Jsi expert na opravu...
[135 lines]
...";
```

### PushToTalk (AFTER - Embedded Resource)

```
src/PushToTalk.Core/
├── Prompts/
│   ├── README.md
│   ├── MistralSystemPrompt.md           # 135 lines of markdown
│   └── MistralSystemPrompt.Tests.md     # Test cases
├── Services/
│   ├── MistralProvider.cs               # Clean code
│   └── EmbeddedPromptLoader.cs          # Reusable loader
```

```csharp
// ✅ GOOD: Load from embedded resource
public class MistralProvider
{
    private readonly IPromptLoader _promptLoader;
    private string? _systemPrompt;

    private async Task<string> GetSystemPromptAsync()
    {
        _systemPrompt ??= await _promptLoader.LoadAsync(
            "Prompts.MistralSystemPrompt.md");
        return _systemPrompt;
    }
}
```

---

## Related Documentation

- [Secrets Management](secrets-management.md) - API keys, passwords
- [Project Structure](project-setup/project-structure-project-setup.md) - Where to place files
- [Testing Guide](testing/index-testing.md) - Testing configuration loading

---

## Quick Reference

| Content Type | Storage | Loading |
|--------------|---------|---------|
| API keys, passwords | Secrets (user-secrets, env file) | IConfiguration |
| Simple config (numbers, bools) | appsettings.json | IOptions<T> |
| LLM prompts (>50 lines) | Embedded resource (.md) | IPromptLoader |
| Email templates | Embedded resource (.html) | ITemplateLoader |
| User-editable content | External files | File.ReadAllTextAsync |
| Multi-tenant config | Database | IConfigureOptions<T> + DbContext |

---

**Last updated:** 2025-12-27
**Version:** 1.0
