## Rate Limits

### Official Limits (F0 Free Tier)

Azure Translator uses **character-based rate limiting**, not request-based limiting.

**Source**: [Azure Translator Service Limits](https://learn.microsoft.com/en-us/azure/ai-services/translator/service-limits)

| Limit Type | Value | Description |
|------------|-------|-------------|
| **Characters/Hour** | 2,000,000 | Hard limit (F0 tier) |
| **Characters/Minute** | ~33,300 | Sliding window (2M / 60 minutes) |
| **Characters/Request** | 50,000 | Maximum per single request |
| **Concurrent Requests** | Unlimited | No concurrency limit |

**CRITICAL**:
- ✅ **No limit on number of requests** - only character count matters
- ⚠️ Character limit enforced using **sliding window** (per-minute average)
- ⚠️ Single request > 33,300 chars → **rejected immediately**
- ⚠️ Burst usage triggers HTTP 429 if exceeding ~33,300 chars/minute

**Error Code**:
- **HTTP 429** - Too Many Requests (character quota exceeded)

### Recommended Delays for Batch Processing

**When translating multiple documents sequentially**:

| Text Length | Chars Used | Recommended Delay | Requests/Minute Limit |
|-------------|------------|-------------------|----------------------|
| **Tiny** (< 100 chars) | 100 | 200ms | ~300 requests |
| **Small** (100-500 chars) | 500 | 1s | ~60 requests |
| **Medium** (500-2000 chars) | 2,000 | 4s | ~15 requests |
| **Large** (2000-10k chars) | 10,000 | 20s | ~3 requests |
| **Very Large** (10k-50k chars) | 50,000 | 90s (1.5 min) | 1 request |

**Formula to calculate delay**:

```csharp
// Azure limit: 33,300 chars/minute = 555 chars/second
private const int CHARS_PER_SECOND = 555;

public TimeSpan CalculateDelay(int characterCount)
{
    // Calculate minimum delay to stay under 555 chars/second
    var seconds = (double)characterCount / CHARS_PER_SECOND;

    // Add 20% safety margin
    seconds *= 1.2;

    return TimeSpan.FromSeconds(Math.Max(0.2, seconds)); // Min 200ms
}
```

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

        // Calculate delay based on character count
        var delay = CalculateDelay(text.Length);

        _logger.LogDebug("Translated {Chars} chars, waiting {Delay}ms before next request",
            text.Length, delay.TotalMilliseconds);

        await Task.Delay(delay);
    }

    return results;
}
```

### Parallel Processing (Use with Caution)

Azure allows **unlimited concurrent requests**, but character quota still applies:

```csharp
// BAD: Can easily exceed 33,300 chars/minute
var tasks = texts.Select(t => TranslateAsync(t, "cs")).ToArray();
await Task.WhenAll(tasks); // May trigger HTTP 429!

// BETTER: Use SemaphoreSlim to limit concurrency
var semaphore = new SemaphoreSlim(5, 5); // Max 5 concurrent

var tasks = texts.Select(async text =>
{
    await semaphore.WaitAsync();
    try
    {
        return await TranslateAsync(text, "cs");
    }
    finally
    {
        semaphore.Release();
    }
});

await Task.WhenAll(tasks);
```

**Warning**: Even with limited concurrency, total characters/minute can exceed limit. Monitor character usage!

### Error Handling & Exponential Backoff

When HTTP 429 is received:

```csharp
public async Task<string> TranslateWithRetryAsync(string text, string targetLang)
{
    var delay = TimeSpan.FromSeconds(2);
    var maxRetries = 5;

    for (int i = 0; i < maxRetries; i++)
    {
        try
        {
            return await TranslateAsync(text, targetLang);
        }
        catch (HttpRequestException ex) when (ex.StatusCode == HttpStatusCode.TooManyRequests)
        {
            if (i == maxRetries - 1) throw;

            _logger.LogWarning(
                "Azure rate limit hit ({Chars} chars), waiting {Delay}s before retry {Attempt}/{Max}",
                text.Length, delay.TotalSeconds, i + 1, maxRetries);

            await Task.Delay(delay);
            delay *= 2; // Exponential backoff: 2s, 4s, 8s, 16s, 32s
        }
    }

    throw new InvalidOperationException("Max retries exceeded");
}
```

### Best Practices

1. **Track character usage** - Use client-side counting (see [Usage Tracking](#usage-tracking))
2. **Calculate delays dynamically** - Based on text length (555 chars/second safe rate)
3. **Sequential processing preferred** - Safer than parallel for large texts
4. **Monitor HTTP 429 errors** - Adjust delays if seeing frequent rate limiting
5. **Add safety margin** - Use 80% of limit (26,640 chars/minute instead of 33,300)

### Standard Tier (S0)

- **No character-based rate limits** (pay-as-you-go)
- Higher request throughput
- 99.9% SLA

**Sources**:
- [Azure Translator Service Limits](https://learn.microsoft.com/en-us/azure/ai-services/translator/service-limits)
- [Microsoft Q&A - Rate Limits](https://learn.microsoft.com/en-us/answers/questions/297266/rate-limit-for-cognitive-services-translations)

---

## Billing and Reset

### Reset Schedule

Azure Free (F0) tier resets on **calendar month** basis:

| Billing Period | Start Date | End Date | Reset Date |
|----------------|------------|----------|------------|
| January | Jan 1, 00:00 UTC | Jan 31, 23:59 UTC | Feb 1, 00:00 UTC |
| February | Feb 1, 00:00 UTC | Feb 28/29, 23:59 UTC | Mar 1, 00:00 UTC |
| March | Mar 1, 00:00 UTC | Mar 31, 23:59 UTC | Apr 1, 00:00 UTC |

**Reset Time**: Midnight UTC on the 1st of each month

**Important Notes**:
- ✅ Predictable reset schedule (always 1st of month)
- ❌ Unused characters do NOT carry over
- ✅ Quota immediately resets to 2M at midnight UTC

**Example**:
```
Dec 29, 2025 - Used: 1,900,000 / 2,000,000 (5% remaining)
Dec 31, 2025 23:59 - Used: 1,999,999 / 2,000,000
Jan 1, 2026 00:00 - Used: 0 / 2,000,000 (reset!)
```

### Billing

**Free Tier (F0)**:
- €0/month
- 2M characters included
- No overages allowed (hard limit)

**Standard Tiers**:
- Pay-as-you-go
- Billed per 1M characters
- Monthly Azure invoice
- No upfront costs

---

