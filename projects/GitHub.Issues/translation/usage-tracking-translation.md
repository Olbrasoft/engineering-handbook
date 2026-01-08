## Usage Tracking

### DeepL Usage Tracking (Native API)

DeepL provides native usage tracking via `/v2/usage` endpoint.

**Implementation Example**:

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

        return new DeepLUsage(
            CharacterCount: json.CharacterCount,
            CharacterLimit: json.CharacterLimit,
            CharactersRemaining: json.CharacterLimit - json.CharacterCount,
            PercentageRemaining: (double)(json.CharacterLimit - json.CharacterCount) / json.CharacterLimit * 100
        );
    }
}

public record DeepLUsageResponse(long CharacterCount, long CharacterLimit);
public record DeepLUsage(long CharacterCount, long CharacterLimit, long CharactersRemaining, double PercentageRemaining);
```

**Usage**:

**Note**: Replace `YOUR_DEEPL_API_KEY` with actual key from SecureStore vault

```bash
curl -X GET 'https://api-free.deepl.com/v2/usage' \
  -H "Authorization: DeepL-Auth-Key YOUR_DEEPL_API_KEY:fx"
```

**Response**:
```json
{
  "character_count": 32735,
  "character_limit": 500000
}
```

### Azure Usage Tracking (Client-Side)

Azure does **NOT** provide usage API. Must count characters client-side.

**Implementation Example**:

```csharp
public class AzureUsageTracker
{
    private readonly IProviderUsageRepository _repository;

    public async Task RecordTranslationAsync(string text, CancellationToken ct)
    {
        var charCount = text.Length;

        var usage = await _repository.GetCurrentMonthUsageAsync("Azure", ct);

        if (usage == null)
        {
            usage = new ProviderUsage
            {
                Provider = "Azure",
                CharactersUsed = 0,
                CharacterLimit = 2_000_000,  // 2M for Free F0 tier
                BillingPeriodStart = new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1),
                BillingPeriodEnd = new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1).AddMonths(1).AddDays(-1)
            };
        }

        usage.CharactersUsed += charCount;
        usage.LastUpdated = DateTime.UtcNow;

        await _repository.UpsertAsync(usage, ct);
    }
}
```

### Database Schema for Usage Tracking

**See Issue #303** for complete implementation plan.

**Table**: `ProviderUsage`

```sql
CREATE TABLE ProviderUsage (
    Id BIGINT PRIMARY KEY IDENTITY(1,1),
    Provider NVARCHAR(50) NOT NULL,
    CharactersUsed BIGINT NOT NULL,
    CharacterLimit BIGINT NOT NULL,
    BillingPeriodStart DATE NOT NULL,
    BillingPeriodEnd DATE NOT NULL,
    LastUpdated DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    LastSyncedWithProvider DATETIME2 NULL,

    INDEX IX_Provider_Period (Provider, BillingPeriodStart)
);
```

---

