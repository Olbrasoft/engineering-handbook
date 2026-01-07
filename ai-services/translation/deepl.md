# DeepL Translation API

> Official translation API with excellent quality, especially for European languages

**Provider**: DeepL SE
**Website**: https://www.deepl.com/pro-api
**Documentation**: https://developers.deepl.com/docs/api-reference

---

## Table of Contents

1. [Overview](#overview)
2. [Pricing Tiers](#pricing-tiers)
3. [API Endpoints](#api-endpoints)
4. [Usage Limits](#usage-limits)
5. [API Keys](#api-keys)
6. [Usage Tracking](#usage-tracking)
7. [Rate Limits](#rate-limits)
8. [Billing and Reset](#billing-and-reset)
9. [Supported Languages](#supported-languages)
10. [Code Examples](#code-examples)
11. [Troubleshooting](#troubleshooting)

---

## Overview

DeepL provides one of the **best quality** machine translation services, especially for European languages. The API is straightforward, reliable, and includes native usage tracking.

**Key Features**:
- ✅ Excellent translation quality (often better than Google/Azure)
- ✅ Native usage tracking API (`/v2/usage`)
- ✅ Free tier available (500k chars/month)
- ✅ Supports 31 languages (as of 2025)
- ✅ Fast and reliable
- ✅ Document translation support

**Limitations**:
- ❌ Strict character limits (returns HTTP 456 when exceeded)
- ❌ No automatic rollover to next month
- ❌ Fewer languages than Google/Azure (31 vs 100+)

---

## Pricing Tiers

| Tier | Monthly Cost | Characters/Month | API Key Format | Endpoint |
|------|--------------|------------------|----------------|----------|
| **Free** | €0 | 500,000 | `xxxxxx:fx` | `https://api-free.deepl.com` |
| **Starter** | €5.49 | + €4.99/1M chars | `xxxxxx` (no :fx) | `https://api.deepl.com` |
| **Advanced** | €24.99 | + €14.99/1M chars | `xxxxxx` | `https://api.deepl.com` |
| **Ultimate** | €49.99 | + €9.99/1M chars | `xxxxxx` | `https://api.deepl.com` |

**Important Notes**:
- Free tier keys have `:fx` suffix (e.g., `xxxxxx:fx`)
- Free tier has **hard limit** of 500k chars/month - no overages allowed
- Paid tiers have base characters + pay-as-you-go for additional usage
- Character counting uses Unicode code points (not bytes)

---

## API Endpoints

### Translation

```
POST https://api-free.deepl.com/v2/translate  (Free tier)
POST https://api.deepl.com/v2/translate        (Paid tiers)
```

**Parameters**:
- `text` (required) - Text to translate (max 50,000 chars per request for Free)
- `target_lang` (required) - Target language code (e.g., `CS`, `DE`, `EN-US`)
- `source_lang` (optional) - Source language (auto-detected if omitted)
- `formality` (optional) - `default`, `more`, `less` (for some language pairs)
- `preserve_formatting` (optional) - Boolean to preserve formatting

**Example Request**:
```bash
curl -X POST 'https://api-free.deepl.com/v2/translate' \
  -H 'Authorization: DeepL-Auth-Key YOUR_API_KEY:fx' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'text=Hello world&target_lang=CS'
```

**Example Response**:
```json
{
  "translations": [
    {
      "detected_source_language": "EN",
      "text": "Ahoj světe"
    }
  ]
}
```

### Usage Tracking

```
GET https://api-free.deepl.com/v2/usage  (Free tier)
GET https://api.deepl.com/v2/usage        (Paid tiers)
```

**No parameters needed** - just API key in header.

**Example Request**:
```bash
curl -X GET 'https://api-free.deepl.com/v2/usage' \
  -H 'Authorization: DeepL-Auth-Key YOUR_API_KEY:fx'
```

**Example Response**:
```json
{
  "character_count": 180118,
  "character_limit": 500000
}
```

**Interpretation**:
- `character_count`: Characters used in current billing period
- `character_limit`: Total characters allowed per billing period
- **Remaining**: `500000 - 180118 = 319882` (64% remaining)

---

## Usage Limits

### Free Tier

| Limit Type | Value | Description |
|------------|-------|-------------|
| **Characters/Month** | 500,000 | Hard limit, strictly enforced |
| **Characters/Request** | 50,000 | Maximum text length per API call |
| **Requests/Month** | Unlimited | No request count limit |
| **Rate Limit** | Not publicly disclosed | Generous for normal use |

**Important**:
- When limit is reached, API returns **HTTP 456** (Quota Exceeded)
- No overages allowed - must wait until next billing period reset
- Multiple API keys can be used to increase capacity (500k per key)

### Paid Tiers

- Higher base characters + pay-as-you-go
- No hard monthly limit (pay for what you use)
- Higher rate limits
- Priority support

---

## API Keys

### Our API Keys

**Location**: `~/Dokumenty/přístupy/api-keys.md` (lines 661-746)

DeepL API keys are stored securely in the local access credentials file. Each key entry includes:
- API key value (Free tier format: `xxxxxx:fx`)
- Associated email account
- Tier information (Free: 500k chars/month)
- Current status (Active/Exhausted)
- Reset date (based on account creation date)
- Designated usage (Primary/Secondary for GitHub.Issues)

**To access keys**: See `~/Dokumenty/přístupy/api-keys.md`

**Current Setup**: Multiple Free tier keys (500k chars/month each) for load distribution

### Key Format

Free tier keys always end with `:fx`:
```
xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx:fx
```

Paid tier keys have no suffix:
```
xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

### Identifying Key Tier

```bash
# Free tier key
if [[ "$API_KEY" =~ :fx$ ]]; then
  ENDPOINT="https://api-free.deepl.com"
else
  ENDPOINT="https://api.deepl.com"
fi
```

---

## Usage Tracking

### Native API Method

DeepL provides **native usage tracking** via `/v2/usage` endpoint.

**Advantages**:
- ✅ Real-time usage data
- ✅ Official API (reliable)
- ✅ No client-side counting needed
- ✅ Works for all account types

**C# Example**:

```csharp
public class DeepLUsageService
{
    private readonly HttpClient _httpClient;

    public async Task<DeepLUsage> GetUsageAsync(string apiKey, CancellationToken ct)
    {
        var endpoint = apiKey.EndsWith(":fx")
            ? "https://api-free.deepl.com/v2/usage"
            : "https://api.deepl.com/v2/usage";

        var request = new HttpRequestMessage(HttpMethod.Get, endpoint);
        request.Headers.Add("Authorization", $"DeepL-Auth-Key {apiKey}");

        var response = await _httpClient.SendAsync(request, ct);
        response.EnsureSuccessStatusCode();

        var json = await response.Content.ReadFromJsonAsync<DeepLUsageResponse>(ct);

        var remaining = json.CharacterLimit - json.CharacterCount;
        var percentage = (double)remaining / json.CharacterLimit * 100;

        return new DeepLUsage(
            CharacterCount: json.CharacterCount,
            CharacterLimit: json.CharacterLimit,
            CharactersRemaining: remaining,
            PercentageRemaining: percentage
        );
    }
}

public record DeepLUsageResponse(long CharacterCount, long CharacterLimit);
public record DeepLUsage(
    long CharacterCount,
    long CharacterLimit,
    long CharactersRemaining,
    double PercentageRemaining);
```

**Bash Example**:

**Note**: Get API key from `~/Dokumenty/přístupy/api-keys.md`

```bash
#!/bin/bash

# Replace with your actual API key from ~/Dokumenty/přístupy/api-keys.md
API_KEY="YOUR_DEEPL_API_KEY:fx"

# Get usage
RESPONSE=$(curl -s -X GET 'https://api-free.deepl.com/v2/usage' \
  -H "Authorization: DeepL-Auth-Key $API_KEY")

# Parse JSON
CHARACTER_COUNT=$(echo "$RESPONSE" | jq -r '.character_count')
CHARACTER_LIMIT=$(echo "$RESPONSE" | jq -r '.character_limit')

# Calculate remaining
REMAINING=$((CHARACTER_LIMIT - CHARACTER_COUNT))
PERCENTAGE=$(echo "scale=2; $REMAINING * 100 / $CHARACTER_LIMIT" | bc)

echo "DeepL Usage:"
echo "  Used: $CHARACTER_COUNT / $CHARACTER_LIMIT"
echo "  Remaining: $REMAINING ($PERCENTAGE%)"
```

**Output**:
```
DeepL Usage:
  Used: 32735 / 500000
  Remaining: 467265 (93.45%)
```

### Background Sync Job

For production applications, sync usage hourly:

```csharp
public class DeepLUsageSyncJob : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                foreach (var apiKey in _settings.DeepLApiKeys)
                {
                    var usage = await _usageService.GetUsageAsync(apiKey, stoppingToken);

                    // Store in database
                    await _repository.UpsertAsync(new ProviderUsage
                    {
                        Provider = $"DeepL-{GetKeyIndex(apiKey)}",
                        CharactersUsed = usage.CharacterCount,
                        CharacterLimit = usage.CharacterLimit,
                        LastSyncedWithProvider = DateTime.UtcNow
                    }, stoppingToken);

                    _logger.LogInformation(
                        "DeepL usage synced: {Used}/{Limit} ({Percentage:F1}% remaining)",
                        usage.CharacterCount, usage.CharacterLimit, usage.PercentageRemaining);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to sync DeepL usage");
            }

            await Task.Delay(TimeSpan.FromHours(1), stoppingToken);
        }
    }
}
```

---

## Rate Limits

### Official Limits

DeepL **does not publicly disclose specific rate limits** for requests per second or concurrent requests in their [official documentation](https://developers.deepl.com/docs/resources/usage-limits).

**Documented limits**:
- ❌ No published requests/second limit
- ❌ No published requests/minute limit
- ❌ No published concurrent request limit
- ✅ Header size: 16 KiB max
- ✅ Total request size: 128 KiB max
- ✅ Max 50 texts per request

**Error Code**:
- **HTTP 429** - "Too many requests. Please wait and resend your request"

### Observed Behavior

Based on community feedback and testing:
- ✅ No strict requests/second limit for normal use (appears generous)
- ✅ Can handle bursts of translations
- ⚠️ Very high request rates trigger HTTP 429 (temporary throttling)
- ✅ Generally more generous than Google/Bing unofficial APIs
- ⚠️ Concurrent requests work but may hit undocumented limits

### Recommended Delays for Batch Processing

**When translating multiple documents sequentially**:

| Scenario | Recommended Delay | Reason |
|----------|-------------------|--------|
| **Small texts** (< 1000 chars) | 100-200ms between requests | Avoid triggering rate limit |
| **Medium texts** (1000-10k chars) | 200-500ms between requests | Safe for most use cases |
| **Large texts** (10k-50k chars) | 500ms-1s between requests | Allow server processing time |
| **Batch operations** (100+ requests) | 1-2s between requests | Conservative approach |

**Example implementation**:

```csharp
public async Task<List<string>> TranslateBatchAsync(List<string> texts)
{
    var results = new List<string>();

    foreach (var text in texts)
    {
        // Translate
        var translation = await TranslateAsync(text, "cs");
        results.Add(translation);

        // Wait before next request (based on text length)
        var delay = text.Length < 1000 ? 200 : 500;
        await Task.Delay(delay);
    }

    return results;
}
```

### Error Handling & Exponential Backoff

When HTTP 429 is received, implement exponential backoff:

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

            _logger.LogWarning("Rate limit hit, waiting {Delay}ms before retry {Attempt}/{Max}",
                delay.TotalMilliseconds, i + 1, maxRetries);

            await Task.Delay(delay);
            delay *= 2; // Exponential backoff: 1s, 2s, 4s, 8s, 16s
        }
    }

    throw new InvalidOperationException("Max retries exceeded");
}
```

### Best Practices

1. **Monitor HTTP 429 responses** - Adjust delays if seeing frequent rate limiting
2. **Don't send thousands of requests per second** - No one needs that fast translation
3. **Use reasonable delays** - 200-500ms is safe for most use cases
4. **Implement exponential backoff** - Required for robust systems
5. **Consider parallelism carefully** - Sequential is safer than concurrent for DeepL

**Sources**:
- [DeepL Usage Limits Documentation](https://developers.deepl.com/docs/resources/usage-limits)
- [DeepL API Plans](https://support.deepl.com/hc/en-us/articles/360021200939-DeepL-API-plans)

---

## Billing and Reset

### Reset Schedule

**CRITICAL**: DeepL Free tier resets based on **account creation date**, NOT calendar month!

| Account Email | Created Date | Reset Date | Billing Cycle |
|---------------|--------------|------------|---------------|
| github.issues@email.cz | 2025-01-12 | 12th of each month | 12th to 11th |
| tuma.rsrobot@gmail.com | Unknown | Check dashboard | Account-specific |
| opencode@seznam.cz | Unknown | Check dashboard | Account-specific |

**How to find reset date**:
1. Log in to https://www.deepl.com/pro-account
2. Go to "Account" → "Usage"
3. Look for "Your usage resets on [DATE]"

**Example**:
- Account created: January 12, 2025
- Reset dates: Feb 12, Mar 12, Apr 12, etc.
- Character limit resets to 500,000 on 12th of each month

**Important Notes**:
- ❌ No prorated refunds or early resets
- ❌ Unused characters do NOT carry over
- ✅ Reset happens at midnight UTC on reset date

---

## Supported Languages

DeepL supports **31 languages** (as of 2025):

| Code | Language | Code | Language |
|------|----------|------|----------|
| `BG` | Bulgarian | `LV` | Latvian |
| `CS` | Czech | `LT` | Lithuanian |
| `DA` | Danish | `HU` | Hungarian |
| `DE` | German | `NL` | Dutch |
| `EL` | Greek | `PL` | Polish |
| `EN` | English | `PT` | Portuguese |
| `ES` | Spanish | `RO` | Romanian |
| `ET` | Estonian | `RU` | Russian |
| `FI` | Finnish | `SK` | Slovak |
| `FR` | French | `SL` | Slovenian |
| `IT` | Italian | `SV` | Swedish |
| `JA` | Japanese | `TR` | Turkish |
| `KO` | Korean | `UK` | Ukrainian |
| `ZH` | Chinese | `ID` | Indonesian |
| `NB` | Norwegian | `AR` | Arabic |

**English variants**:
- `EN-US` - American English
- `EN-GB` - British English

**Portuguese variants**:
- `PT-PT` - European Portuguese
- `PT-BR` - Brazilian Portuguese

---

## Code Examples

### Basic Translation

**Note**: Replace `YOUR_DEEPL_API_KEY` with actual key from `~/Dokumenty/přístupy/api-keys.md`

```csharp
using System.Net.Http;
using System.Text.Json;

public async Task<string> TranslateAsync(string text, string targetLang)
{
    var apiKey = "YOUR_DEEPL_API_KEY:fx";
    var endpoint = "https://api-free.deepl.com/v2/translate";

    using var client = new HttpClient();
    client.DefaultRequestHeaders.Add("Authorization", $"DeepL-Auth-Key {apiKey}");

    var content = new FormUrlEncodedContent(new Dictionary<string, string>
    {
        { "text", text },
        { "target_lang", targetLang }
    });

    var response = await client.PostAsync(endpoint, content);
    response.EnsureSuccessStatusCode();

    var json = await response.Content.ReadFromJsonAsync<DeepLResponse>();
    return json.Translations[0].Text;
}

public class DeepLResponse
{
    public List<Translation> Translations { get; set; }
}

public class Translation
{
    public string Text { get; set; }
    public string Detected_Source_Language { get; set; }
}
```

### Check Usage Before Translation

```csharp
public async Task<string> SafeTranslateAsync(string text, string targetLang)
{
    var apiKey = "YOUR_DEEPL_API_KEY:fx";

    // Check usage first
    var usage = await GetUsageAsync(apiKey);

    var requiredChars = text.Length;
    if (usage.CharactersRemaining < requiredChars)
    {
        throw new InvalidOperationException(
            $"Insufficient DeepL quota. Required: {requiredChars}, Remaining: {usage.CharactersRemaining}");
    }

    // Proceed with translation
    return await TranslateAsync(text, targetLang);
}
```

---

## Troubleshooting

### HTTP 456 - Quota Exceeded

**Error**:
```
Response status code does not indicate success: 456 (Quota Exceeded).
```

**Cause**: Monthly character limit (500k) reached.

**Solution**:
1. Check usage:
   ```bash
   curl -X GET 'https://api-free.deepl.com/v2/usage' \
     -H "Authorization: DeepL-Auth-Key YOUR_KEY:fx"
   ```

2. **If exhausted**:
   - ✅ Wait until reset date (check account creation date)
   - ✅ Use another API key
   - ✅ Upgrade to paid tier

3. **Temporary workaround**:
   - Switch to Azure Translator or Google Translate
   - Implement automatic failover in application

---

### HTTP 403 - Forbidden

**Error**:
```
Response status code does not indicate success: 403 (Forbidden).
```

**Cause**: Invalid API key or wrong endpoint.

**Solution**:
1. Verify key format:
   - Free keys must have `:fx` suffix
   - Use `https://api-free.deepl.com` for free keys
   - Use `https://api.deepl.com` for paid keys

2. Test key:
   ```bash
   curl -X POST 'https://api-free.deepl.com/v2/translate' \
     -H "Authorization: DeepL-Auth-Key YOUR_KEY:fx" \
     -d "text=Hello&target_lang=CS"
   ```

---

### HTTP 400 - Bad Request

**Common causes**:

1. **Invalid target language**:
   ```json
   {"message": "Value for 'target_lang' not supported."}
   ```
   Solution: Use uppercase language codes (e.g., `CS`, not `cs`)

2. **Text too long**:
   ```json
   {"message": "Text too long. Max 50000 characters per request."}
   ```
   Solution: Split text into chunks of max 50k characters

3. **Missing required parameter**:
   ```json
   {"message": "Parameter 'target_lang' not specified."}
   ```
   Solution: Ensure `target_lang` is provided

---

## Markdown Limitations

### ❌ No Native Markdown Support

DeepL **does NOT natively support markdown** translation in its Document Translation API.

**Supported Document Formats** (Document API):
- ✅ PDF (`.pdf`)
- ✅ Microsoft Word (`.docx`, `.doc`)
- ✅ PowerPoint (`.pptx`, `.ppt`)
- ✅ HTML (`.html`, `.htm`)
- ✅ Plain text (`.txt`)
- ❌ **Markdown NOT supported** (`.md`)

**Official Source**: [DeepL Document Translation](https://www.deepl.com/en/pro-api#document-translation)

---

### Why DeepL is Not Ideal for Markdown

**Issues**:

1. **No Document API support**:
   - Document Translation API doesn't accept `.md` files
   - Would return error: "Unsupported file format"

2. **Text API has formatting issues**:
   - `preserve_formatting` parameter **only exists for Text API**, not Document API
   - Even with `preserve_formatting`, markdown syntax gets mistranslated
   - Examples of errors:
     - `**bold**` → `**tučné**` (bold markers translated)
     - `` `code` `` → `` `kód` `` (backticks preserved but content translated)
     - `[link](url)` → `[odkaz](url)` (square brackets preserved but text translated)

3. **Community-reported problems**:
   - [GitHub Issue #26](https://github.com/DeepLcom/deepl-node/issues/26) - "Markdown Handling" feature request
   - [GitHub Issue #107](https://github.com/DeepLcom/deepl-python/issues/107) - `preserve_formatting` missing in document translation
   - Users report markdown checkboxes, bolded text, and other elements get corrupted

**Comparison**:

| Feature | DeepL | Azure Translator |
|---------|-------|------------------|
| **Markdown Document API** | ❌ No | ✅ Yes |
| **Native support** | ❌ No | ✅ Yes (9 extensions) |
| **Formatting preservation** | ⚠️ Manual only | ✅ Automatic |
| **Translation quality** | ⭐⭐⭐⭐⭐ Best | ⭐⭐⭐⭐⭐ Excellent |

---

### Workaround: Custom Markdown Parser

If you **must use DeepL** for markdown (e.g., for quality reasons), you need custom parsing:

**Approach**:
1. Parse markdown → extract translatable text
2. Translate text-only parts via DeepL Text API
3. Rebuild markdown structure with translated text

**Example Implementation**:

```csharp
public class DeepLMarkdownTranslator
{
    private readonly DeepLTextTranslator _deepL;
    private readonly MarkdownParser _parser;

    public async Task<string> TranslateMarkdownAsync(string markdownContent, string targetLang)
    {
        // 1. Parse markdown into blocks
        var blocks = _parser.Parse(markdownContent);

        // 2. Identify translatable vs non-translatable blocks
        var translatableBlocks = blocks
            .Where(b => b.Type == BlockType.Text || b.Type == BlockType.Heading)
            .ToList();

        // 3. Translate only text content (preserve markdown syntax)
        foreach (var block in translatableBlocks)
        {
            // Extract pure text (without markdown markers)
            var textOnly = ExtractText(block.Content);

            // Translate via DeepL Text API
            var translated = await _deepL.TranslateAsync(textOnly, targetLang);

            // Rebuild with original markdown markers
            block.TranslatedContent = RebuildWithMarkers(block.Content, translated);
        }

        // 4. Reassemble markdown
        return _parser.Rebuild(blocks);
    }

    private string ExtractText(string markdownBlock)
    {
        // Example: "## **Title**" → "Title"
        // Remove: #, **, *, `, [], (), etc.

        var text = markdownBlock;
        text = Regex.Replace(text, @"^#+\s*", "");     // Remove headings
        text = Regex.Replace(text, @"\*\*(.*?)\*\*", "$1");  // Remove bold
        text = Regex.Replace(text, @"\*(.*?)\*", "$1");      // Remove italic
        text = Regex.Replace(text, @"`(.*?)`", "$1");        // Remove code
        text = Regex.Replace(text, @"\[(.*?)\]\(.*?\)", "$1"); // Remove links

        return text.Trim();
    }

    private string RebuildWithMarkers(string original, string translated)
    {
        // Example:
        // original: "## **Title**"
        // translated: "Nadpis"
        // result: "## **Nadpis**"

        var markers = ExtractMarkers(original);
        return ApplyMarkers(translated, markers);
    }
}
```

**Libraries for Parsing**:
- [Markdig](https://github.com/xoofx/markdig) - .NET markdown processor
- [CommonMark.NET](https://github.com/Knagis/CommonMark.NET) - CommonMark parser

---

### Recommended Alternative: Azure for Markdown

**For markdown files**, use **Azure Translator** instead:

```csharp
// Recommended configuration for markdown
var translatorPool = new TranslatorPoolBuilder()
    .AddProviderGroup("Azure", priority: 1)  // Primary for markdown
        .AddProvider(new AzureDocumentTranslator(azureKey1, "westeurope"))
        .AddProvider(new AzureDocumentTranslator(azureKey2, "westeurope"))
    .AddProviderGroup("DeepL", priority: 2)  // Fallback (custom parser)
        .AddProvider(new DeepLMarkdownTranslator(deeplKey1, new MarkdownParser()))
    .Build();
```

**Why Azure first for markdown**:
1. ✅ Native markdown support (no parsing needed)
2. ✅ Larger free quota (2M vs 500k)
3. ✅ Automatic formatting preservation
4. ✅ Less error-prone

**Use DeepL for**:
- ✅ Plain text translation (best quality)
- ✅ Documents in supported formats (PDF, DOCX, HTML)
- ✅ Critical translations where quality > convenience

**See Also**:
- [Azure Translator - Markdown Support](./azure/index-azure.md#markdown-support)
- [Main README - Markdown Recommendation](../README.md#special-case-markdown-documents)

---

## Related Documentation

- [Azure Translator](./azure/index-azure.md) - Alternative translation service
- [Translation System Implementation](../../projects/GitHub.Issues/translation/index-translation.md) - Multi-provider setup
- [GitHub Issue #303](https://github.com/Olbrasoft/GitHub.Issues/issues/303) - Usage tracking implementation

---

**Last Updated**: 2025-12-29
**Maintainer**: Olbrasoft
