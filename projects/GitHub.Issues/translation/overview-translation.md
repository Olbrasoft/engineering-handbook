# Translation System - Overview

Complete guide for implementing multi-provider translation system with automatic fallback and load balancing.

**Project**: GitHub.Issues
**NuGet Packages**: Olbrasoft.Text.Translation.* (Azure, DeepL, Google, Bing)
**Related Issues**: [#301](https://github.com/Olbrasoft/GitHub.Issues/issues/301), [#302](https://github.com/Olbrasoft/GitHub.Issues/issues/302), [#303](https://github.com/Olbrasoft/GitHub.Issues/issues/303)

## System Overview

The translation system uses a **multi-provider pool** with:

- ✅ **Automatic fallback** - If one provider fails, automatically tries next
- ✅ **Load balancing** - Round-robin rotation across providers and API keys
- ✅ **Provider groups** - Strict provider alternation (DeepL → Azure → Google → Bing)
- ✅ **Key rotation** - Distribute load across multiple API keys within same provider
- ✅ **Configurable order** - Control which providers are tried first
- ✅ **Rate limit handling** - Skip exhausted providers automatically

## Key Benefits

**Reliability**: Never fails if at least one provider works
**Cost optimization**: Use free providers first, paid only as fallback
**Performance**: Distribute load across multiple API keys
**Flexibility**: Easy to add/remove providers or change priority

## How It Works

```
User Request
     ↓
TitleTranslationService / SummaryTranslationService
     ↓
RoundRobinTranslator (selects provider + key)
     ↓
TranslatorPoolBuilder (creates provider groups)
     ↓
Provider Groups:
  1. DeepL Group [Key1, Key2]
  2. Azure Group [Key1, Key2]
  3. Google Group [Single instance]
  4. Bing Group [Single instance]
     ↓
Individual Translators:
  - DeepLTranslator
  - AzureTranslator
  - GoogleFreeTranslator
  - BingFreeTranslator
```

## See Also

- [NuGet Packages](nuget-packages-translation.md) - Required packages
- [Providers](providers-translation.md) - Detailed provider comparison
- [Implementation Guide](implementation-guide-translation.md) - Step-by-step setup
