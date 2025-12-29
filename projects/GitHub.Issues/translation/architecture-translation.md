## Architecture

### Component Diagram

```
User Request
     ↓
TitleTranslationService / SummaryTranslationService
     ↓
RoundRobinTranslator (selects provider + key)
     ↓
TranslatorPoolBuilder (creates provider groups)
     ↓
Provider Groups:
  1. DeepL Group [Key1, Key2]
  2. Azure Group [Key1, Key2]
  3. Google Group [Single instance]
  4. Bing Group [Single instance]
     ↓
Individual Translators:
  - DeepLTranslator
  - AzureTranslator
  - GoogleFreeTranslator
  - BingFreeTranslator
```

### Key Classes

#### 1. `ITranslator` Interface

**Location**: `Olbrasoft.Text.Translation` package

```csharp
public interface ITranslator
{
    Task<TranslatorResult> TranslateAsync(
        string text,
        string targetLanguage,
        string? sourceLanguage = null,
        CancellationToken cancellationToken = default);
}

public record TranslatorResult(
    bool Success,
    string? Translation,
    string? Error,
    string Provider);
```

#### 2. `TranslatorPoolBuilder`

**Location**: `src/Olbrasoft.GitHub.Issues.Business/Services/TranslatorPoolBuilder.cs`

**Responsibility**: Creates **provider groups** for strict provider alternation.

**Example**:

With 2 DeepL keys and 2 Azure keys, creates:
- DeepL group: `[DeepL-Key1, DeepL-Key2]`
- Azure group: `[Azure-Key1, Azure-Key2]`
- Google group: `[GoogleFreeTranslator]`
- Bing group: `[BingFreeTranslator]`

**Key Method**:

```csharp
public IReadOnlyList<ProviderGroup> BuildProviderGroups()
{
    var providerGroups = new Dictionary<string, ProviderGroup>();

    // Create Azure provider group
    if (azureKeys.Count > 0)
    {
        var azureTranslators = azureKeys
            .Select((key, index) => CreateAzureTranslator(key, index))
            .ToList();
        providerGroups["Azure"] = new ProviderGroup("Azure", azureTranslators);
    }

    // Create DeepL provider group
    if (deepLKeys.Count > 0)
    {
        var deepLTranslators = deepLKeys
            .Select((key, index) => CreateDeepLTranslator(key, index))
            .ToList();
        providerGroups["DeepL"] = new ProviderGroup("DeepL", deepLTranslators);
    }

    // Create Google provider group (no API key required)
    if (_settings.GoogleEnabled)
    {
        var googleTranslator = CreateGoogleTranslator();
        providerGroups["Google"] = new ProviderGroup("Google", new List<ITranslator> { googleTranslator });
    }

    // Create Bing provider group (no API key required)
    if (_settings.BingEnabled)
    {
        var bingTranslator = CreateBingTranslator();
        providerGroups["Bing"] = new ProviderGroup("Bing", new List<ITranslator> { bingTranslator });
    }

    // Arrange according to ProviderOrder setting
    return ArrangeByConfiguredOrder(providerGroups);
}
```

#### 3. `RoundRobinTranslator`

**Location**: `src/Olbrasoft.GitHub.Issues.Business/Services/RoundRobinTranslator.cs`

**Responsibility**: Implements **strict provider alternation** with key rotation and fallback.

**Rotation Example**:

With provider order `["DeepL", "Azure", "Google", "Bing"]`:

```
Request 1: DeepL-Key1
Request 2: Azure-Key1
Request 3: Google
Request 4: Bing
Request 5: DeepL-Key2 (next key in DeepL group)
Request 6: Azure-Key2 (next key in Azure group)
Request 7: Google
Request 8: Bing
Request 9: DeepL-Key1 (cycle repeats)
```

**Fallback Logic**:

If a provider fails, tries next provider and **all its keys**:

```
Request 1: DeepL-Key1 → FAILS (rate limit)
           Azure-Key1 → FAILS (network error)
           Azure-Key2 → SUCCESS ✓
```

**Key Method**:

```csharp
public async Task<TranslatorResult> TranslateAsync(
    string text,
    string targetLanguage,
    string? sourceLanguage = null,
    CancellationToken cancellationToken = default)
{
    // Get next provider (strict alternation)
    var startProviderIndex = (int)(Interlocked.Increment(ref _providerIndex) % _providers.Count);

    // Try all providers and all their keys
    for (int providerOffset = 0; providerOffset < _providers.Count; providerOffset++)
    {
        var providerIndex = (startProviderIndex + providerOffset) % _providers.Count;
        var provider = _providers[providerIndex];

        // Get next key for this provider (rotate within provider)
        var keyIndex = provider.GetNextKeyIndex();

        // On first provider, use its selected key
        // On fallback providers, try all their keys
        var keysToTry = providerOffset == 0 ? 1 : provider.Translators.Count;

        for (int keyOffset = 0; keyOffset < keysToTry; keyOffset++)
        {
            var actualKeyIndex = (keyIndex + keyOffset) % provider.Translators.Count;
            var translator = provider.Translators[actualKeyIndex];

            try
            {
                var result = await translator.TranslateAsync(text, targetLanguage, sourceLanguage, cancellationToken);

                if (result.Success && !string.IsNullOrWhiteSpace(result.Translation))
                {
                    return result; // SUCCESS
                }

                _logger.LogWarning("{Provider} failed: {Error}. Trying next...", provider.Name, result.Error);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "{Provider}[{KeyIndex}] threw exception. Trying next...", provider.Name, actualKeyIndex);
            }
        }
    }

    // All translators failed
    return TranslatorResult.Fail("All translators failed", "RoundRobin");
}
```

#### 4. `ProviderGroup`

**Location**: `src/Olbrasoft.GitHub.Issues.Business/Services/RoundRobinTranslator.cs` (bottom of file)

**Responsibility**: Represents a group of translators for a single provider with key rotation.

```csharp
public class ProviderGroup
{
    private long _keyIndex = -1; // Will be incremented to 0 on first call

    public string Name { get; }
    public IReadOnlyList<ITranslator> Translators { get; }

    public ProviderGroup(string name, IReadOnlyList<ITranslator> translators)
    {
        Name = name;
        Translators = translators;
    }

    /// <summary>
    /// Gets the next key index for this provider (atomic, thread-safe).
    /// </summary>
    public int GetNextKeyIndex()
    {
        return (int)(Interlocked.Increment(ref _keyIndex) % Translators.Count);
    }
}
```

---

