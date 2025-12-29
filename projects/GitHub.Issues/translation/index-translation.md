# Translation System

Multi-provider translation system with automatic fallback and load balancing.

## What is Translation System?

**Goal:** Reliable translation with automatic fallback across multiple providers (DeepL, Azure, Google, Bing).

**Key Features:**
- ✅ Automatic fallback - Never fails if at least one provider works
- ✅ Load balancing - Round-robin rotation across providers and API keys
- ✅ Provider groups - Strict provider alternation (DeepL → Azure → Google → Bing)
- ✅ Key rotation - Distribute load across multiple API keys within same provider

## Quick Navigation

| Topic | File | Description |
|-------|------|-------------|
| System overview | [overview-translation.md](overview-translation.md) | Architecture, benefits, how it works |
| NuGet packages | [nuget-packages-translation.md](nuget-packages-translation.md) | Required packages for each provider |
| Provider details | [providers-translation.md](providers-translation.md) | Comparison and features of all providers |
| API keys setup | [api-keys-translation.md](api-keys-translation.md) | Where to store and configure API keys |
| Architecture | [architecture-translation.md](architecture-translation.md) | Classes, interfaces, component diagram |
| Configuration | [configuration-translation.md](configuration-translation.md) | appsettings.json structure |
| Implementation | [implementation-guide-translation.md](implementation-guide-translation.md) | Step-by-step setup guide |
| Provider rotation | [provider-rotation-fallback-translation.md](provider-rotation-fallback-translation.md) | How rotation and fallback works |
| Usage tracking | [usage-tracking-translation.md](usage-tracking-translation.md) | Monitor API usage and quotas |
| Monitoring | [monitoring-translation.md](monitoring-translation.md) | Logging and metrics |
| Troubleshooting | [troubleshooting-translation.md](troubleshooting-translation.md) | Common issues and solutions |

## Provider Selection Decision Tree

```
What's your priority?
│
├─ Best Translation Quality
│  └─ Use DeepL first → providers-translation.md
│
├─ Cost Optimization (Free tiers)
│  └─ Use Google first → providers-translation.md
│
├─ Reliability (Paid with SLA)
│  └─ Use Azure first → providers-translation.md
│
└─ Setup Translation System
   └─ Start here → implementation-guide-translation.md
```

## Translation Flow

```
Request Translation
    ↓
RoundRobinTranslator (select next provider)
    ↓
Try DeepL-Key1
    ↓ (fails)
Try Azure-Key1
    ↓ (success)
✅ Return translation
```

## Related GitHub Issues

- [#301](https://github.com/Olbrasoft/GitHub.Issues/issues/301) - Translation failure: Missing API keys
- [#302](https://github.com/Olbrasoft/GitHub.Issues/issues/302) - Translation monitoring and logging
- [#303](https://github.com/Olbrasoft/GitHub.Issues/issues/303) - API Usage Tracking

## See Also

- [Implementation Guide](implementation-guide-translation.md) - Complete setup walkthrough
- [Troubleshooting](troubleshooting-translation.md) - Common issues and solutions
