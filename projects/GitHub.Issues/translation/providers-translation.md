## Translation Providers

### Comparison Table

| Provider | Keys | Capacity (chars/month) | Cost | Reliability | Speed | Quality |
|----------|------|----------------------|------|-------------|-------|---------|
| **DeepL Free** | 2 | 1M (2 × 500k) | Free | ⭐⭐⭐⭐⭐ Excellent | Fast | Best |
| **Azure Translator F0** | 2 | 2M (2 × 1M) | Free | ⭐⭐⭐⭐⭐ Excellent | Fast | Excellent |
| **Google Free** | 1 | Unlimited | Free | ⭐⭐⭐⭐ Good (soft limits) | Fast | Very Good |
| **Bing Free** | 1 | Rate-limited | Free | ⭐⭐ Poor (HTTP 429 frequent) | Varies | Good |

### Detailed Provider Information

#### 1. DeepL API (Recommended Primary)

**Type**: Official API
**Endpoint**: `https://api-free.deepl.com/v2/translate` (Free) or `https://api.deepl.com/v2/translate` (Pro)
**Documentation**: https://developers.deepl.com/docs/api-reference/translate

**Features**:
- ✅ Best translation quality (especially for European languages)
- ✅ Native usage tracking API (`/v2/usage`)
- ✅ Reliable and fast
- ✅ Free tier: 500,000 characters/month per key
- ✅ Supports 31 languages

**Limitations**:
- ❌ Character limit enforced strictly (returns 456 error when exceeded)
- ❌ No automatic rollover to next month

**API Key Format**: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx:fx` (Free tier has `:fx` suffix)

**Usage Tracking**:
```bash
curl -X GET 'https://api-free.deepl.com/v2/usage' \
  -H "Authorization: DeepL-Auth-Key YOUR_KEY_HERE"
```

**Response**:
```json
{
  "character_count": 180118,
  "character_limit": 500000
}
```

---

#### 2. Azure Translator (Recommended Secondary)

**Type**: Official API
**Endpoint**: `https://api.cognitive.microsofttranslator.com/translate?api-version=3.0`
**Documentation**: https://learn.microsoft.com/en-us/azure/ai-services/translator/

**Features**:
- ✅ Free tier: 2 million characters/month (F0 pricing tier)
- ✅ Very reliable
- ✅ Supports 100+ languages
- ✅ Good quality translations

**Limitations**:
- ❌ No usage tracking API (must count client-side)
- ❌ Requires Azure subscription (even for free tier)
- ⚠️ Character counting must be done before translation

**API Key Format**: `YOUR_AZURE_TRANSLATOR_KEY_1` (64 chars)

**Required Headers**:
```
Ocp-Apim-Subscription-Key: YOUR_KEY
Ocp-Apim-Subscription-Region: westeurope
```

---

#### 3. Google Free Translator (Recommended Tertiary)

**Type**: Unofficial (web scraping)
**Endpoint**: https://translate.google.com (via web interface parsing)
**Documentation**: None (unofficial)

**Features**:
- ✅ No API key required
- ✅ Unlimited characters (soft limits apply)
- ✅ Good translation quality
- ✅ Supports 100+ languages
- ✅ Fast and generally reliable

**Limitations**:
- ⚠️ Unofficial API (can break if Google changes website)
- ⚠️ Soft rate limits (may temporarily block if overused)
- ❌ No SLA or reliability guarantees

**NuGet Package**: `Olbrasoft.Text.Translation.Google`

---

#### 4. Bing Free Translator (Last Resort Only)

**Type**: Unofficial (web scraping)
**Endpoint**: https://www.bing.com/translator (via web interface parsing)
**Documentation**: None (unofficial)

**Features**:
- ✅ No API key required
- ✅ Supports many languages

**Limitations**:
- ❌ Frequently rate-limited (HTTP 429 Too Many Requests)
- ❌ Very unreliable (often fails)
- ❌ Unofficial API (can break anytime)
- ❌ No SLA or guarantees

**Recommendation**: **Use only as absolute last resort** when all other providers fail.

**NuGet Package**: `Olbrasoft.Text.Translation.Bing`

---

