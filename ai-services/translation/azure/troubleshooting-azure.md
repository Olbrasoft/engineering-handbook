## Troubleshooting

### HTTP 403 - Forbidden

**Error**:
```
Response status code does not indicate success: 403 (Forbidden).
```

**Possible Causes**:

1. **Invalid API key**:
   ```
   Solution: Verify key in Azure Portal → Translator → Keys and Endpoint
   ```

2. **Wrong region**:
   ```
   Error: "Access denied due to invalid subscription key or wrong API endpoint."
   Solution: Check region matches resource location (e.g., westeurope)
   ```

3. **Quota exceeded** (F0 tier):
   ```
   Solution: Wait until 1st of next month for quota reset
   ```

**Test key**:
```bash
curl -X POST 'https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&to=cs' \
  -H "Ocp-Apim-Subscription-Key: YOUR_KEY" \
  -H "Ocp-Apim-Subscription-Region: westeurope" \
  -H "Content-Type: application/json" \
  -d '[{"Text":"Hello"}]'
```

---

### HTTP 429 - Too Many Requests

**Error**:
```
Response status code does not indicate success: 429 (Too Many Requests).
```

**Cause**: Exceeded rate limit (~330 requests/minute for F0).

**Solution**:

1. **Implement exponential backoff**:
   ```csharp
   public async Task<string> TranslateWithRetryAsync(string text, string targetLang)
   {
       var delay = TimeSpan.FromSeconds(1);
       var maxRetries = 5;

       for (int i = 0; i < maxRetries; i++)
       {
           try
           {
               return await TranslateAsync(text, targetLang);
           }
           catch (HttpRequestException ex) when (ex.Message.Contains("429"))
           {
               if (i == maxRetries - 1) throw;

               await Task.Delay(delay);
               delay *= 2; // Exponential backoff
           }
       }

       throw new InvalidOperationException("Max retries exceeded");
   }
   ```

2. **Reduce request frequency**:
   - Batch multiple texts into single request
   - Add delay between requests
   - Upgrade to Standard tier for higher limits

---

### HTTP 400 - Bad Request

**Common Causes**:

1. **Invalid target language**:
   ```json
   {"error":{"code":"400000","message":"One of the request inputs is not valid."}}
   ```
   Solution: Use valid language code (e.g., `cs`, not `CS` or `cz`)

2. **Text too long**:
   ```json
   {"error":{"code":"400036","message":"Text is too long."}}
   ```
   Solution: Split text into chunks of max 50,000 characters

3. **Invalid JSON**:
   ```json
   {"error":{"code":"400000","message":"The request body is not valid JSON."}}
   ```
   Solution: Ensure JSON is properly formatted

---

### Client-Side Tracking Inaccurate

**Problem**: Client-side character count doesn't match Azure billing.

**Causes**:
- Different character counting methods (UTF-8 vs UTF-16)
- Missed translations (not recorded)
- Concurrent requests race conditions

**Solution**:

1. **Use UTF-8 length** (matches Azure):
   ```csharp
   var charCount = Encoding.UTF8.GetByteCount(text); // More accurate
   // OR
   var charCount = text.Length; // Simpler, usually close enough
   ```

2. **Record ALL translations**:
   ```csharp
   try
   {
       var result = await TranslateAsync(text, targetLang);
       await _usageTracker.RecordTranslationAsync(text, ct); // Record after success
       return result;
   }
   catch
   {
       // Don't record failed translations
       throw;
   }
   ```

3. **Use database transactions**:
   ```csharp
   await using var transaction = await _dbContext.Database.BeginTransactionAsync(ct);

   var usage = await GetCurrentUsageAsync(ct);
   usage.CharactersUsed += text.Length;
   await _dbContext.SaveChangesAsync(ct);

   await transaction.CommitAsync(ct);
   ```

4. **Periodic verification**:
   - Check Azure Portal Metrics monthly
   - Compare client-side count with Azure billing
   - Adjust tracking if discrepancies found

---

## Markdown Support

### ✅ Native Markdown Translation

Azure Translator **fully supports markdown** via the **Document Translation API**.

**Supported Formats**:
- File extensions: `.md`, `.markdown`, `.mdown`, `.mkdn`, `.mkd`, `.mdwn`, `.mdtxt`, `.mdtext`, `.rmd`
- Content types: `text/markdown`, `text/x-markdown`, `text/plain`
- **Preserves structure**: Headers, bold, italic, code blocks, links, etc.

**Official Source**: [Azure Translator - Supported Document Formats](https://learn.microsoft.com/en-us/azure/ai-services/translator/document-translation/reference/get-supported-document-formats)

---

### Why Azure is Best for Markdown

**Comparison with other providers**:

| Feature | Azure Translator | DeepL |
|---------|------------------|-------|
| **Native markdown support** | ✅ Yes (Document API) | ❌ No (manual parsing needed) |
| **Preserves formatting** | ✅ Automatic | ⚠️ Requires custom implementation |
| **Supported extensions** | ✅ 9 extensions | ❌ None |
| **Preprocessing needed** | ❌ No | ✅ Yes (extract text, rebuild) |
| **Free quota** | ✅ 2M chars/month | ⚠️ 500k chars/key |

**Recommendation**: For markdown files, use **Azure as primary provider**, DeepL as fallback.

---

### Document Translation API for Markdown

**Endpoint**:
```
POST https://{region}.cognitiveservices.azure.com/translator/document/batches?api-version=2024-05-01
```

**Example Request**:
```csharp
public class AzureDocumentTranslator
{
    private readonly HttpClient _httpClient;
    private readonly string _apiKey;
    private readonly string _region;

    public async Task<string> TranslateMarkdownAsync(
        string sourceUrl,
        string targetLanguage,
        string targetUrl)
    {
        var endpoint = $"https://{_region}.cognitiveservices.azure.com/translator/document/batches?api-version=2024-05-01";

        var requestBody = new
        {
            inputs = new[]
            {
                new
                {
                    source = new
                    {
                        sourceUrl = sourceUrl,  // Azure Blob Storage URL
                        language = "en"
                    },
                    targets = new[]
                    {
                        new
                        {
                            targetUrl = targetUrl,  // Azure Blob Storage URL
                            language = targetLanguage
                        }
                    }
                }
            }
        };

        var request = new HttpRequestMessage(HttpMethod.Post, endpoint);
        request.Headers.Add("Ocp-Apim-Subscription-Key", _apiKey);
        request.Content = new StringContent(
            JsonSerializer.Serialize(requestBody),
            Encoding.UTF8,
            "application/json"
        );

        var response = await _httpClient.SendAsync(request);
        response.EnsureSuccessStatusCode();

        // Response contains operation ID for tracking
        var operationLocation = response.Headers.GetValues("Operation-Location").First();
        return operationLocation;
    }

    public async Task<DocumentTranslationStatus> GetStatusAsync(string operationId)
    {
        var endpoint = $"https://{_region}.cognitiveservices.azure.com/translator/document/batches/{operationId}?api-version=2024-05-01";

        var request = new HttpRequestMessage(HttpMethod.Get, endpoint);
        request.Headers.Add("Ocp-Apim-Subscription-Key", _apiKey);

        var response = await _httpClient.SendAsync(request);
        response.EnsureSuccessStatusCode();

        var json = await response.Content.ReadAsStringAsync();
        return JsonSerializer.Deserialize<DocumentTranslationStatus>(json);
    }
}
```

**Features**:
- ✅ Automatic markdown structure preservation
- ✅ Batch translation (multiple files at once)
- ✅ Asynchronous processing (for large files)
- ✅ Progress tracking via operation ID

---

### Text Translation API with Markdown

If you don't want to use Document API (e.g., small snippets), you can use **Text Translation API** with `textType=html`:

```csharp
public async Task<string> TranslateMarkdownTextAsync(string markdownText, string targetLang)
{
    var endpoint = $"https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&to={targetLang}&textType=html";

    var request = new HttpRequestMessage(HttpMethod.Post, endpoint);
    request.Headers.Add("Ocp-Apim-Subscription-Key", _apiKey);
    request.Headers.Add("Ocp-Apim-Subscription-Region", _region);

    // Protect markdown syntax with notranslate class
    var protectedMarkdown = ProtectMarkdownSyntax(markdownText);

    var body = new[] { new { Text = protectedMarkdown } };
    var json = JsonSerializer.Serialize(body);
    request.Content = new StringContent(json, Encoding.UTF8, "application/json");

    var response = await _httpClient.SendAsync(request);
    response.EnsureSuccessStatusCode();

    var responseJson = await response.Content.ReadAsStringAsync();
    var result = JsonSerializer.Deserialize<AzureTranslateResponse[]>(responseJson);

    return result[0].Translations[0].Text;
}

private string ProtectMarkdownSyntax(string markdown)
{
    // Wrap markdown syntax in notranslate spans
    // Example: **bold** → <span class="notranslate">**</span>bold<span class="notranslate">**</span>

    // This is a simple example - production code needs robust parsing
    var protected = markdown
        .Replace("**", "<span class='notranslate'>**</span>")
        .Replace("`", "<span class='notranslate'>`</span>");

    return protected;
}
```

**Limitations**:
- ⚠️ Requires manual protection of markdown syntax
- ⚠️ Error-prone for complex markdown
- ✅ **Document API is recommended** for markdown files

---

### Configuration for Markdown Files

**Recommended provider order** for markdown documents:

```csharp
// Configure TranslatorPool for markdown files
var markdownTranslatorPool = new TranslatorPoolBuilder()
    .AddProviderGroup("Azure", priority: 1)  // Primary for markdown
        .AddProvider(new AzureDocumentTranslator(key1, region))
        .AddProvider(new AzureDocumentTranslator(key2, region))
    .AddProviderGroup("DeepL", priority: 2)  // Fallback (requires parsing)
        .AddProvider(new DeepLTranslatorWithMarkdownParser(key1))
    .Build();

// Use for engineering-handbook translation
var handbook = new HandbookTranslator(markdownTranslatorPool);
await handbook.TranslateAllFilesAsync("~/GitHub/Olbrasoft/engineering-handbook/", targetLang: "cs");
```

**Why Azure first**:
1. ✅ Native markdown support (no preprocessing)
2. ✅ Larger free quota (2M vs 500k)
3. ✅ Automatic structure preservation
4. ✅ Fewer errors with complex markdown

**See Also**:
- [Main README - Markdown Recommendation](../../README.md#special-case-markdown-documents)
- [Translation System Guide](../../../projects/GitHub.Issues/translation/index-translation.md)

---

