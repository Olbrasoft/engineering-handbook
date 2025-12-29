# Azure Translator (Cognitive Services)

Official Microsoft translation API with excellent reliability and support for 100+ languages.

**Provider**: Microsoft Azure
**Service**: Azure Cognitive Services - Translator
**Website**: https://azure.microsoft.com/en-us/products/ai-services/ai-translator
**Documentation**: https://learn.microsoft.com/en-us/azure/ai-services/translator/

## What is Azure Translator?

Azure Translator is Microsoft's official translation API offering excellent reliability, extensive language support, and integration with Azure ecosystem.

**Key Features**:
- ✅ Excellent translation quality
- ✅ Very reliable (99.9% SLA for paid tiers)
- ✅ Supports 100+ languages
- ✅ Free tier available (2M chars/month)
- ✅ Custom translation models support
- ✅ Document translation
- ✅ Integration with Azure ecosystem

**Limitations**:
- ❌ **No usage tracking API** - must count characters client-side
- ❌ Requires Azure subscription (even for free tier)
- ⚠️ Character counting responsibility is on client

## Quick Navigation

| Topic | File | Description |
|-------|------|-------------|
| Pricing & limits | [pricing-limits-azure.md](pricing-limits-azure.md) | Free tier, pricing, usage limits |
| API endpoints | [api-endpoints-azure.md](api-endpoints-azure.md) | Text translation, document translation |
| API keys setup | [api-keys-azure.md](api-keys-azure.md) | Where to find and configure keys |
| Usage tracking | [usage-tracking-azure.md](usage-tracking-azure.md) | Client-side character counting |
| Rate limits & billing | [rate-limits-billing-azure.md](rate-limits-billing-azure.md) | Rate limits, billing cycle |
| Supported languages | [supported-languages-azure.md](supported-languages-azure.md) | List of 100+ languages |
| Code examples | [code-examples-azure.md](code-examples-azure.md) | C# translation examples |
| Troubleshooting | [troubleshooting-azure.md](troubleshooting-azure.md) | Common issues and solutions |

## When to Use Azure Translator

```
Your priority?
│
├─ Need reliability and SLA
│  └─ Azure Translator is best choice
│
├─ Need more free characters
│  └─ Consider DeepL (500k) or Google (unlimited)
│
└─ Need usage tracking API
   └─ Use DeepL instead (has /usage endpoint)
```

## See Also

- [DeepL API](../deepl.md) - Alternative with native usage tracking
- [Translation System](../../../projects/GitHub.Issues/translation/index-translation.md) - Multi-provider setup
