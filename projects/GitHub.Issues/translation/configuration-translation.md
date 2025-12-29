## Configuration

### appsettings.json Structure

**Source Code** (`src/Olbrasoft.GitHub.Issues.AspNetCore.RazorPages/appsettings.json`):

```json
{
  "TranslatorPool": {
    "ProviderOrder": ["DeepL", "Azure", "Google", "Bing"],
    "GoogleEnabled": true,
    "GoogleTimeoutSeconds": 10,
    "BingEnabled": true,
    "BingTimeoutSeconds": 10,
    "AzureApiKeys": [],  // Empty in Git - loaded from production config
    "AzureRegion": "westeurope",
    "AzureEndpoint": "https://api.cognitive.microsofttranslator.com/",
    "DeepLApiKeys": [],  // Empty in Git - loaded from production config
    "DeepLEndpoint": "https://api.deepl.com/v2/",
    "DeepLFreeEndpoint": "https://api-free.deepl.com/v2/"
  }
}
```

**Production Runtime** (`/opt/olbrasoft/github-issues/config/appsettings.json`):

**Note**: Actual API keys are stored in `~/Dokumenty/přístupy/api-keys.md` and loaded into production config.

```json
{
  "TranslatorPool": {
    "ProviderOrder": ["DeepL", "Azure", "Google", "Bing"],
    "GoogleEnabled": true,
    "GoogleTimeoutSeconds": 10,
    "BingEnabled": true,
    "BingTimeoutSeconds": 10,
    "AzureApiKeys": [
      "YOUR_AZURE_TRANSLATOR_KEY_1",
      "YOUR_AZURE_TRANSLATOR_KEY_2"
    ],
    "AzureRegion": "westeurope",
    "AzureEndpoint": "https://api.cognitive.microsofttranslator.com/",
    "DeepLApiKeys": [
      "YOUR_DEEPL_API_KEY_1:fx",
      "YOUR_DEEPL_API_KEY_2:fx"
    ],
    "DeepLEndpoint": "https://api.deepl.com/v2/",
    "DeepLFreeEndpoint": "https://api-free.deepl.com/v2/"
  }
}
```

### Configuration Options

| Setting | Type | Description | Example |
|---------|------|-------------|---------|
| `ProviderOrder` | `string[]` | Order in which providers are tried | `["DeepL", "Azure", "Google", "Bing"]` |
| `GoogleEnabled` | `bool` | Enable Google Free Translator | `true` |
| `GoogleTimeoutSeconds` | `int` | Timeout for Google API calls | `10` |
| `BingEnabled` | `bool` | Enable Bing Free Translator | `true` |
| `BingTimeoutSeconds` | `int` | Timeout for Bing API calls | `10` |
| `AzureApiKeys` | `string[]` | List of Azure Translator API keys | `["key1", "key2"]` |
| `AzureRegion` | `string` | Azure resource region | `"westeurope"` |
| `AzureEndpoint` | `string` | Azure Translator endpoint | `"https://api.cognitive.microsofttranslator.com/"` |
| `DeepLApiKeys` | `string[]` | List of DeepL API keys | `["key1:fx", "key2:fx"]` |
| `DeepLEndpoint` | `string` | DeepL Pro endpoint | `"https://api.deepl.com/v2/"` |
| `DeepLFreeEndpoint` | `string` | DeepL Free endpoint | `"https://api-free.deepl.com/v2/"` |

---

