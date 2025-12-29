## Implementation Guide

### Step 1: Install NuGet Packages

```bash
dotnet add package Olbrasoft.Text.Translation.Azure --version 10.0.2
dotnet add package Olbrasoft.Text.Translation.DeepL --version 10.0.2
dotnet add package Olbrasoft.Text.Translation.Google --version 10.0.2
dotnet add package Olbrasoft.Text.Translation.Bing --version 10.0.2
```

### Step 2: Add Configuration

Add to `appsettings.json`:

```json
{
  "TranslatorPool": {
    "ProviderOrder": ["DeepL", "Azure", "Google", "Bing"],
    "GoogleEnabled": true,
    "GoogleTimeoutSeconds": 10,
    "BingEnabled": true,
    "BingTimeoutSeconds": 10,
    "AzureApiKeys": [],
    "AzureRegion": "westeurope",
    "AzureEndpoint": "https://api.cognitive.microsofttranslator.com/",
    "DeepLApiKeys": [],
    "DeepLEndpoint": "https://api.deepl.com/v2/",
    "DeepLFreeEndpoint": "https://api-free.deepl.com/v2/"
  }
}
```

### Step 3: Create Settings Class

```csharp
public class TranslatorPoolSettings
{
    public List<string> ProviderOrder { get; set; } = new();
    public bool GoogleEnabled { get; set; }
    public int GoogleTimeoutSeconds { get; set; } = 10;
    public bool BingEnabled { get; set; }
    public int BingTimeoutSeconds { get; set; } = 10;
    public List<string> AzureApiKeys { get; set; } = new();
    public string AzureRegion { get; set; } = "westeurope";
    public string AzureEndpoint { get; set; } = "https://api.cognitive.microsofttranslator.com/";
    public List<string> DeepLApiKeys { get; set; } = new();
    public string DeepLEndpoint { get; set; } = "https://api.deepl.com/v2/";
    public string DeepLFreeEndpoint { get; set; } = "https://api-free.deepl.com/v2/";

    public string GetDeepLEndpointForKey(string apiKey)
    {
        return apiKey.EndsWith(":fx") ? DeepLFreeEndpoint : DeepLEndpoint;
    }
}
```

### Step 4: Copy TranslatorPoolBuilder and RoundRobinTranslator

Copy these files from GitHub.Issues project:

1. `TranslatorPoolBuilder.cs` → `YourProject.Business/Services/`
2. `RoundRobinTranslator.cs` → `YourProject.Business/Services/`
3. `ProviderGroup.cs` (in same file as RoundRobinTranslator)

**Source**: `src/Olbrasoft.GitHub.Issues.Business/Services/`

### Step 5: Register Services in DI Container

```csharp
// Configure settings
services.Configure<TranslatorPoolSettings>(configuration.GetSection("TranslatorPool"));

// Register HttpClientFactory
services.AddHttpClient();

// Register TranslatorPoolBuilder
services.AddSingleton<TranslatorPoolBuilder>();

// Register RoundRobinTranslator as ITranslator
services.AddSingleton<ITranslator>(sp =>
{
    var builder = sp.GetRequiredService<TranslatorPoolBuilder>();
    var providerGroups = builder.BuildProviderGroups();

    var logger = sp.GetRequiredService<ILogger<RoundRobinTranslator>>();
    return new RoundRobinTranslator(providerGroups, logger);
});
```

### Step 6: Use in Your Service

```csharp
public class MyTranslationService
{
    private readonly ITranslator _translator;
    private readonly ILogger<MyTranslationService> _logger;

    public MyTranslationService(ITranslator translator, ILogger<MyTranslationService> logger)
    {
        _translator = translator;
        _logger = logger;
    }

    public async Task<string> TranslateTextAsync(string text, string targetLanguage, CancellationToken ct)
    {
        var result = await _translator.TranslateAsync(text, targetLanguage, sourceLanguage: null, ct);

        if (result.Success && !string.IsNullOrWhiteSpace(result.Translation))
        {
            _logger.LogInformation("Translation succeeded via {Provider}", result.Provider);
            return result.Translation;
        }

        _logger.LogWarning("Translation failed: {Error}", result.Error);
        return text; // Return original text if translation fails
    }
}
```

### Step 7: Configure API Keys in Production

**Option A**: Populate `config/appsettings.json` (production runtime config)

```json
{
  "TranslatorPool": {
    "AzureApiKeys": [
      "YOUR_AZURE_KEY_1",
      "YOUR_AZURE_KEY_2"
    ],
    "DeepLApiKeys": [
      "YOUR_DEEPL_KEY_1:fx",
      "YOUR_DEEPL_KEY_2:fx"
    ]
  }
}
```

**Option B**: Use environment variables (recommended for Docker/systemd)

```bash
TranslatorPool__AzureApiKeys__0=YOUR_AZURE_KEY_1
TranslatorPool__AzureApiKeys__1=YOUR_AZURE_KEY_2
TranslatorPool__DeepLApiKeys__0=YOUR_DEEPL_KEY_1:fx
TranslatorPool__DeepLApiKeys__1=YOUR_DEEPL_KEY_2:fx
```

---

