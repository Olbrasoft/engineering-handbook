## Code Examples

### Basic Translation

```csharp
using System.Net.Http;
using System.Text;
using System.Text.Json;

public class AzureTranslator
{
    private readonly HttpClient _httpClient;
    private readonly string _apiKey;
    private readonly string _region;

    public AzureTranslator(string apiKey, string region = "westeurope")
    {
        _httpClient = new HttpClient();
        _apiKey = apiKey;
        _region = region;
    }

    public async Task<string> TranslateAsync(string text, string targetLang)
    {
        var endpoint = $"https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&to={targetLang}";

        var request = new HttpRequestMessage(HttpMethod.Post, endpoint);
        request.Headers.Add("Ocp-Apim-Subscription-Key", _apiKey);
        request.Headers.Add("Ocp-Apim-Subscription-Region", _region);

        var body = new[] { new { Text = text } };
        var json = JsonSerializer.Serialize(body);
        request.Content = new StringContent(json, Encoding.UTF8, "application/json");

        var response = await _httpClient.SendAsync(request);
        response.EnsureSuccessStatusCode();

        var responseJson = await response.Content.ReadAsStringAsync();
        var result = JsonSerializer.Deserialize<AzureTranslateResponse[]>(responseJson);

        return result[0].Translations[0].Text;
    }
}

public class AzureTranslateResponse
{
    public Translation[] Translations { get; set; }
}

public class Translation
{
    public string Text { get; set; }
    public string To { get; set; }
}
```

### Translation with Usage Tracking

```csharp
public async Task<string> SafeTranslateAsync(string text, string targetLang)
{
    var requiredChars = text.Length;

    // Check quota before translation
    if (!await _usageTracker.HasSufficientQuotaAsync(requiredChars, CancellationToken.None))
    {
        throw new InvalidOperationException(
            $"Insufficient Azure Translator quota. Required: {requiredChars} chars");
    }

    // Translate
    var translation = await TranslateAsync(text, targetLang);

    // Record usage (client-side)
    await _usageTracker.RecordTranslationAsync(text, CancellationToken.None);

    return translation;
}
```

### Batch Translation

```csharp
public async Task<string[]> TranslateBatchAsync(string[] texts, string targetLang)
{
    var endpoint = $"https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&to={targetLang}";

    var request = new HttpRequestMessage(HttpMethod.Post, endpoint);
    request.Headers.Add("Ocp-Apim-Subscription-Key", _apiKey);
    request.Headers.Add("Ocp-Apim-Subscription-Region", _region);

    var body = texts.Select(t => new { Text = t }).ToArray();
    var json = JsonSerializer.Serialize(body);
    request.Content = new StringContent(json, Encoding.UTF8, "application/json");

    var response = await _httpClient.SendAsync(request);
    response.EnsureSuccessStatusCode();

    var responseJson = await response.Content.ReadAsStringAsync();
    var results = JsonSerializer.Deserialize<AzureTranslateResponse[]>(responseJson);

    return results.Select(r => r.Translations[0].Text).ToArray();
}
```

---

