## Configuration

### appsettings.json Structure

Configuration is split across multiple files:

1. **appsettings.json** (source code) - Public configuration, **NO secrets**
2. **appsettings.Production.json** (deployed) - Production overrides
3. **config/appsettings.json** (production) - Runtime configuration with API keys

### Database Configuration

```json
{
  "Database": {
    "Provider": "SqlServer"  // or "PostgreSQL"
  },
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost,1433;Database=GitHubIssues;User Id=sa;TrustServerCertificate=True;Encrypt=True;"
  }
}
```

**CRITICAL**: Password is stored in environment variable `ConnectionStrings__DefaultConnection`, **NOT in JSON files**.

### Embedding Providers

```json
{
  "TextTransformation": {
    "Embeddings": {
      "Provider": "Cohere",  // or "Ollama"
      "Model": "embed-multilingual-v3.0",
      "Dimensions": 1024,
      "Ollama": {
        "BaseUrl": "http://localhost:11434",
        "Dimensions": 768,
        "MaxStartupRetries": 30,
        "StartupRetryDelayMs": 1000
      },
      "Cohere": {
        "Model": "embed-multilingual-v3.0",
        "Dimensions": 1024
      }
    }
  }
}
```

### Summarization Configuration

```json
{
  "TextTransformation": {
    "Summarization": {
      "Provider": "OpenAICompatible",
      "Model": "llama-4-scout-17b-16e-instruct",
      "MaxTokens": 500,
      "Temperature": 0.3,
      "SystemPrompt": "You are a helpful assistant that summarizes GitHub issues concisely. Provide a 2-3 sentence summary in English that captures the key points. Start directly with the summary content - do NOT prefix with 'Summary:', 'Summary', or any similar label. Do NOT use <think> tags.",
      "OpenAICompatible": {
        "BaseUrl": "https://api.cerebras.ai/v1",
        "MaxTokens": 500,
        "Temperature": 0.3
      }
    }
  }
}
```

### Translation Configuration

```json
{
  "TextTransformation": {
    "Translation": {
      "Provider": "Cohere",
      "Model": "command-a-03-2025",
      "TargetLanguage": "Czech",
      "Fallback": {
        "Provider": "OpenAICompatible",
        "Model": "llama-3.3-70b-versatile",
        "OpenAICompatible": {
          "BaseUrl": "https://api.groq.com/openai/v1"
        }
      }
    }
  },
  "TranslatorPool": {
    "ProviderOrder": ["DeepL", "Azure", "Google", "Bing"],
    "GoogleEnabled": true,
    "GoogleTimeoutSeconds": 10,
    "BingEnabled": true,
    "BingTimeoutSeconds": 10,
    "AzureApiKeys": [],  // Loaded from production config
    "AzureRegion": "westeurope",
    "AzureEndpoint": "https://api.cognitive.microsofttranslator.com/",
    "DeepLApiKeys": [],  // Loaded from production config
    "DeepLEndpoint": "https://api.deepl.com/v2/",
    "DeepLFreeEndpoint": "https://api-free.deepl.com/v2/"
  }
}
```

**Security Note**: API keys are stored in `~/Dokumenty/přístupy/api-keys.md` (NOT committed to Git) and populated in production config.

---

