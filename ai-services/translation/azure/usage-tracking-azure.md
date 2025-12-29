## Usage Tracking

### ❌ No Native Usage API

**CRITICAL**: Azure Translator **does NOT provide a usage tracking API**.

Unlike DeepL (which has `/v2/usage`), Azure requires **client-side character counting**.

**Official Microsoft Response**:
> "Character counting must be done on the client side before sending requests. Usage can be monitored via Azure Portal Metrics (delayed, not real-time)."

**Source**: [Azure Translator Service Limits](https://learn.microsoft.com/en-us/azure/ai-services/translator/service-limits)

### Client-Side Tracking (Required)

**Implementation Example**:

```csharp
public class AzureUsageTracker
{
    private readonly IProviderUsageRepository _repository;
    private readonly ILogger<AzureUsageTracker> _logger;

    public async Task RecordTranslationAsync(string text, CancellationToken ct)
    {
        // Count characters (UTF-8 length)
        var charCount = text.Length;

        // Get current month usage
        var usage = await _repository.GetCurrentMonthUsageAsync("Azure", ct);

        if (usage == null)
        {
            // Initialize for current month
            usage = new ProviderUsage
            {
                Provider = "Azure",
                CharactersUsed = 0,
                CharacterLimit = 2_000_000,  // Free F0 tier
                BillingPeriodStart = new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1),
                BillingPeriodEnd = new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1)
                    .AddMonths(1).AddDays(-1)
            };
        }

        // Increment usage
        usage.CharactersUsed += charCount;
        usage.LastUpdated = DateTime.UtcNow;

        await _repository.UpsertAsync(usage, ct);

        // Log warning if approaching limit
        var remaining = usage.CharacterLimit - usage.CharactersUsed;
        var percentageRemaining = (double)remaining / usage.CharacterLimit * 100;

        if (percentageRemaining < 10)
        {
            _logger.LogWarning(
                "Azure Translator quota low! {Percentage:F1}% remaining ({Remaining:N0} chars)",
                percentageRemaining, remaining);
        }
    }

    public async Task<bool> HasSufficientQuotaAsync(int requiredChars, CancellationToken ct)
    {
        var usage = await _repository.GetCurrentMonthUsageAsync("Azure", ct);

        if (usage == null)
            return true; // No usage yet this month

        var remaining = usage.CharacterLimit - usage.CharactersUsed;
        return remaining >= requiredChars;
    }
}
```

### Database Schema

**Table**: `ProviderUsage`

```sql
CREATE TABLE ProviderUsage (
    Id BIGINT PRIMARY KEY IDENTITY(1,1),
    Provider NVARCHAR(50) NOT NULL,              -- 'Azure'
    CharactersUsed BIGINT NOT NULL,              -- Client-side count
    CharacterLimit BIGINT NOT NULL,              -- 2,000,000 for F0
    BillingPeriodStart DATE NOT NULL,            -- First day of month
    BillingPeriodEnd DATE NOT NULL,              -- Last day of month
    LastUpdated DATETIME2 NOT NULL DEFAULT GETUTCDATE(),

    INDEX IX_Provider_Period (Provider, BillingPeriodStart)
);
```

**Example Data**:

| Provider | CharactersUsed | CharacterLimit | BillingPeriodStart | BillingPeriodEnd | LastUpdated |
|----------|----------------|----------------|-------------------|------------------|-------------|
| Azure | 1,500,000 | 2,000,000 | 2025-12-01 | 2025-12-31 | 2025-12-29 14:30:00 |

**Remaining**: `2,000,000 - 1,500,000 = 500,000` (25% remaining)

### Azure Portal Metrics (Alternative)

**Non-realtime** usage monitoring via Azure Portal:

1. Go to https://portal.azure.com
2. Navigate to your Translator resource
3. Click "Metrics" in left menu
4. Select metric: **"Characters Translated"**
5. Set time range (e.g., last 30 days)

**Limitations**:
- ❌ **Delayed** (can be hours behind real-time)
- ❌ Not accessible via API (manual portal access only)
- ❌ Cannot be used for automated quota checks
- ✅ Useful for historical analysis and billing verification

### Cost Management API (Advanced)

Azure provides **Cost Management API** for consumption data, but it's complex:

**API**: https://learn.microsoft.com/en-us/rest/api/cost-management/

**Limitations**:
- Requires Azure subscription access
- Complex authentication (Azure AD)
- Delayed data (not real-time)
- Returns costs, not character counts
- Overkill for simple quota tracking

**Recommendation**: Use client-side tracking instead.

---

