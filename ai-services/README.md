# AI Services - External API Documentation

> Comprehensive documentation for external AI services used across Olbrasoft projects

**Location**: `~/GitHub/Olbrasoft/engineering-handbook/ai-services/`

---

## Table of Contents

1. [Overview](#overview)
2. [Translation Services](#translation-services)
3. [Speech Services](#speech-services)
4. [Quick Comparison](#quick-comparison)
5. [API Keys Management](#api-keys-management)
6. [Usage Tracking Summary](#usage-tracking-summary)
7. [Related Documentation](#related-documentation)

---

## Overview

This directory contains detailed documentation for **external AI services** (APIs) used in Olbrasoft projects.

**Key Information in Each Service**:
- ✅ Pricing tiers and monthly quotas
- ✅ API endpoints and authentication
- ✅ Usage tracking methods (native API or client-side)
- ✅ Rate limits and restrictions
- ✅ Billing cycles and reset dates
- ✅ Code examples and troubleshooting

**Purpose**:
- Understand how many requests/characters/minutes we can send
- Learn how to track remaining credits
- Compare services and choose the right one
- Implement usage tracking in new projects

---

## Translation Services

### [DeepL Translation API](./translation/deepl.md)

**Provider**: DeepL SE
**Type**: Official API
**Free Tier**: 500,000 characters/month per key
**Usage Tracking**: ✅ Native API (`/v2/usage`)

**Key Features**:
- Best translation quality (especially European languages)
- Real-time usage tracking via API
- Multiple keys can be used for 1M+ capacity

**When to Use**:
- Need highest quality translations
- Want to monitor usage programmatically
- Translating European languages

**Limitations**:
- Strict character limits (HTTP 456 when exceeded)
- Fewer languages than Azure/Google (31 vs 100+)
- Reset date based on account creation date

---

### [Azure Translator](./translation/azure/index-azure.md)

**Provider**: Microsoft Azure
**Type**: Official API
**Free Tier**: 2,000,000 characters/month (shared across all keys)
**Usage Tracking**: ❌ Client-side counting required

**Key Features**:
- Very reliable (99.9% SLA for paid tiers)
- Supports 100+ languages
- Integration with Azure ecosystem

**When to Use**:
- Need reliability and SLA
- Already using Azure services
- Need many languages
- Want predictable monthly resets (1st of each month)

**Limitations**:
- **No usage tracking API** - must count characters yourself
- Requires Azure subscription (even for free tier)
- Multiple keys share same quota (not multiplied)

---

## Speech Services

### [Azure Speech-to-Text](./speech/azure-speech-to-text.md)

**Provider**: Microsoft Azure
**Type**: Official API
**Free Tier**: 5 hours (300 minutes) audio per month
**Usage Tracking**: ❌ Client-side counting required

**Key Features**:
- High accuracy speech recognition
- Real-time and batch processing
- Support for 100+ languages
- Custom speech models

**When to Use**:
- Need speech-to-text conversion
- Building voice-controlled applications
- Transcribing audio files

**Limitations**:
- **No usage tracking API** - must count audio duration yourself
- Free tier: only 1 concurrent request
- Reset on 1st of each month

---

## Quick Comparison

### Translation Services

| Service | Free Quota | Usage API | Quality | Languages | Reset Date |
|---------|------------|-----------|---------|-----------|------------|
| **DeepL** | 500k chars/key | ✅ Yes | ⭐⭐⭐⭐⭐ Best | 31 | Account-specific |
| **Azure Translator** | 2M chars/month | ❌ No | ⭐⭐⭐⭐⭐ Excellent | 100+ | 1st of month |
| **Google Free** | Unlimited (soft) | ❌ No | ⭐⭐⭐⭐ Very Good | 100+ | None |
| **Bing Free** | Rate-limited | ❌ No | ⭐⭐⭐ Good | Many | None |

**Recommendation**: Use **DeepL + Azure** combo:
- DeepL primary (best quality + usage tracking)
- Azure fallback (reliable + large quota)
- Google Free as last resort

**Special Case: Markdown Documents**:

For translating markdown files (`.md`), use **Azure-first** configuration:

| Priority | Provider | Reason |
|----------|----------|--------|
| 1️⃣ **Primary** | Azure Translator (KEY 1) | ✅ Native markdown support via Document API |
| 2️⃣ **Secondary** | Azure Translator (KEY 2) | ✅ Same quota, key rotation |
| 3️⃣ **Fallback** | DeepL | ⚠️ Requires custom markdown parsing |

**Why Azure-first for markdown**:
- ✅ **Native markdown support** - preserves `#`, `**`, `*`, `` ` ``, `[]()`, code blocks automatically
- ✅ **Document Translation API** - supports `.md`, `.markdown`, `.mdown`, etc.
- ✅ **Larger quota** - 2M chars/month vs DeepL's 500k/key
- ✅ **No preprocessing needed** - direct file upload
- ❌ DeepL requires custom parsing (markdown not natively supported in Document API)

**Configuration Example**:
```csharp
// For markdown files, prioritize Azure
var translatorPool = new TranslatorPoolBuilder()
    .AddProviderGroup("Azure", priority: 1)
        .AddProvider(new AzureTranslator(key1))
        .AddProvider(new AzureTranslator(key2))
    .AddProviderGroup("DeepL", priority: 2)  // Fallback only
        .AddProvider(new DeepLTranslator(key1, new MarkdownParser()))
    .Build();
```

**See Also**:
- [Azure Translator - Markdown Support](./translation/azure/index-azure.md#markdown-support)
- [DeepL - Markdown Limitations](./translation/deepl.md#markdown-limitations)
- [Translation System Guide](../projects/GitHub.Issues/translation/index-translation.md)

---

### Speech Services

| Service | Free Quota | Usage API | Quality | Languages | Concurrent |
|---------|------------|-----------|---------|-----------|------------|
| **Azure Speech** | 5 hours/month | ❌ No | ⭐⭐⭐⭐⭐ Excellent | 100+ | 1 (F0) |

**Note**: For speech services, Azure is the primary option. Alternative: Google Cloud Speech-to-Text (not documented yet).

---

## API Keys Management

### Where Keys Are Stored

**CRITICAL SECURITY RULE**: API keys are **NEVER committed to Git**.

| Location | Purpose | Security |
|----------|---------|----------|
| SecureStore vault | Encrypted key storage | ✅ AES + HMAC encrypted |
| `~/.config/{app}/secrets/secrets.json` | Production runtime | ✅ Encrypted vault |
| `~/.config/{app}/keys/secrets.key` | Encryption key | ⚠️ chmod 600 only! |
| `src/*/appsettings.json` | Source code template | ⚠️ NO keys, only config |

See [Secrets Management](../development-guidelines/secrets-management.md#securestore---standard-for-olbrasoft-projects) for setup.

### Current API Keys Summary

**DeepL** (3 keys, 1.5M total capacity):
- Main: `83a8...ce2a:fx` - ❌ EXHAUSTED (500k/500k)
- Crow: `c236...f18:fx` - ✅ 100% available (0/500k)
- OpenCode: `9647...4cd:fx` - ✅ 93.5% available (32k/500k)

**Azure Translator** (2 keys, 2M shared capacity):
- KEY 1: `1NW1...64qa` - ✅ Active
- KEY 2: `EKLQ...VPa` - ✅ Active

**Azure Speech** (if configured):
- KEY 1: [Check SecureStore vault]
- KEY 2: [Check SecureStore vault]

**Total Translation Capacity** (as of 2025-12-29):
- DeepL: 1M chars/month (2 active keys)
- Azure: 2M chars/month
- Google: Unlimited (soft limits)
- **Total Guaranteed**: ~3M chars/month + unlimited Google

---

## Usage Tracking Summary

### Services with Native Tracking API

| Service | Endpoint | Method | Response |
|---------|----------|--------|----------|
| **DeepL** | `/v2/usage` | GET | `{"character_count": 180118, "character_limit": 500000}` |

**Advantage**: Real-time, accurate, official

**Example**:
```bash
curl -X GET 'https://api-free.deepl.com/v2/usage' \
  -H "Authorization: DeepL-Auth-Key YOUR_DEEPL_KEY_2:fx"
```

---

### Services Requiring Client-Side Tracking

| Service | What to Count | Billing Unit |
|---------|---------------|--------------|
| **Azure Translator** | Characters (text length) | Characters |
| **Azure Speech** | Audio duration | Seconds/Minutes |

**Implementation Required**:
1. Count before sending request (text length or audio duration)
2. Store in database (table: `ProviderUsage`)
3. Check quota before each request
4. Reset on 1st of each month (Azure) or account date (DeepL)

**Database Schema**:
```sql
CREATE TABLE ProviderUsage (
    Id BIGINT PRIMARY KEY IDENTITY(1,1),
    Provider NVARCHAR(50) NOT NULL,              -- 'Azure', 'DeepL-Key1', 'AzureSpeech'
    CharactersUsed BIGINT NULL,                  -- For translation
    CharacterLimit BIGINT NULL,                  -- For translation
    SecondsUsed BIGINT NULL,                     -- For speech
    SecondsLimit BIGINT NULL,                    -- For speech (18000 = 5 hours)
    BillingPeriodStart DATE NOT NULL,
    BillingPeriodEnd DATE NOT NULL,
    LastUpdated DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    LastSyncedWithProvider DATETIME2 NULL,       -- For DeepL sync

    INDEX IX_Provider_Period (Provider, BillingPeriodStart)
);
```

**See**:
- [GitHub Issue #303](https://github.com/Olbrasoft/GitHub.Issues/issues/303) - Full implementation plan
- [Translation System](../projects/GitHub.Issues/translation/index-translation.md) - Multi-provider setup

---

## Billing and Reset Schedules

### Calendar Month Reset (Azure)

**Services**: Azure Translator, Azure Speech

| Month | Reset Date | Time |
|-------|------------|------|
| January | 2026-01-01 | 00:00 UTC |
| February | 2026-02-01 | 00:00 UTC |
| March | 2026-03-01 | 00:00 UTC |

**Predictable**: Always resets on 1st of month at midnight UTC

---

### Account Creation Date Reset (DeepL)

**Service**: DeepL Free API

**Note**: Account details and keys stored in SecureStore encrypted vault

Each DeepL Free account resets based on its creation date (not calendar month). Each account has:
- Associated email address
- Account creation date
- Monthly reset date (based on creation date)
- Current quota usage

**Unpredictable**: Each account resets on different date based on when it was created

**How to Find**:
1. Log in to https://www.deepl.com/pro-account
2. Go to Account → Usage
3. Look for "Your usage resets on [DATE]"

---

## Rate Limits Summary

| Service | Free Tier Limit | Paid Tier Limit |
|---------|-----------------|-----------------|
| **DeepL** | Not disclosed (generous) | Higher |
| **Azure Translator** | ~330 req/min | Higher |
| **Azure Speech** | 1 concurrent request | 100 concurrent |
| **Google Free** | Soft limits (dynamic) | N/A |
| **Bing Free** | Very aggressive (unreliable) | N/A |

**Best Practice**: Implement exponential backoff on all services for HTTP 429 errors.

---

## Common Error Codes

| Code | Meaning | Services | Solution |
|------|---------|----------|----------|
| **HTTP 403** | Forbidden / Quota exceeded | Azure (quota), All (invalid key) | Check quota or verify API key |
| **HTTP 429** | Too Many Requests | All | Implement exponential backoff |
| **HTTP 456** | Quota Exceeded | DeepL | Wait for reset or use another key |

---

## Related Documentation

### Project-Specific

- [GitHub.Issues - Translation System](../projects/GitHub.Issues/translation/index-translation.md) - Multi-provider implementation guide
- [GitHub.Issues - Main README](../projects/GitHub.Issues/index-GitHub.Issues.md) - Project architecture

### GitHub Issues

- [#301 - Translation failure: Missing API keys](https://github.com/Olbrasoft/GitHub.Issues/issues/301)
- [#302 - Translation monitoring and logging](https://github.com/Olbrasoft/GitHub.Issues/issues/302)
- [#303 - API Usage Tracking implementation](https://github.com/Olbrasoft/GitHub.Issues/issues/303)

---

## How to Use This Documentation

### For New Projects

1. **Choose services** based on requirements (quality, quota, languages)
2. **Read individual service docs** (DeepL.md, Azure-Translator.md, etc.)
3. **Set up API keys** in SecureStore vault (see [Secrets Management](../development-guidelines/secrets-management.md))
4. **Implement usage tracking** (see [Issue #303](https://github.com/Olbrasoft/GitHub.Issues/issues/303))
5. **Set up multi-provider fallback** (see [Translation System](../projects/GitHub.Issues/translation/index-translation.md))

### For Existing Projects

1. **Check current usage** in database (`SELECT * FROM ProviderUsage`)
2. **Verify API keys** are valid and not exhausted
3. **Monitor quota** regularly (especially end of month)
4. **Update keys** if approaching limits

---

**Directory Structure**:
```
ai-services/
├── README.md                           # This file
├── translation/
│   ├── deepl.md                        # DeepL API documentation
│   └── azure-translator.md             # Azure Translator documentation
└── speech/
    └── azure-speech-to-text.md         # Azure Speech-to-Text documentation
```

---

**Last Updated**: 2025-12-29
**Maintainer**: Olbrasoft
