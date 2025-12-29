## Provider Rotation Logic

### Provider Alternation

With provider order `["DeepL", "Azure", "Google"]` and 2 keys each for DeepL and Azure:

| Request # | Provider Used | Key Used | Explanation |
|-----------|---------------|----------|-------------|
| 1 | DeepL | Key 0 | First provider, first key |
| 2 | Azure | Key 0 | Second provider, first key |
| 3 | Google | Key 0 | Third provider, only key |
| 4 | DeepL | Key 1 | Back to first provider, next key |
| 5 | Azure | Key 1 | Second provider, next key |
| 6 | Google | Key 0 | Third provider, only key |
| 7 | DeepL | Key 0 | Cycle repeats |

### Fallback Flow

**Scenario**: Request 1 tries DeepL-Key0, but it fails due to rate limit.

```
Request 1:
  1. DeepL-Key0 → HTTP 456 (quota exceeded) → FAIL
  2. Fallback to Azure-Key0 → SUCCESS ✓
     Result: Translation via "Azure"
```

**Scenario**: All providers fail.

```
Request 1:
  1. DeepL-Key0 → HTTP 456 (quota exceeded) → FAIL
  2. DeepL-Key1 → HTTP 456 (quota exceeded) → FAIL
  3. Azure-Key0 → Timeout → FAIL
  4. Azure-Key1 → Timeout → FAIL
  5. Google → HTTP 429 (rate limit) → FAIL
  6. Bing → HTTP 403 (blocked) → FAIL
     Result: TranslatorResult.Fail("All 6 translators failed. Attempted: DeepL, DeepL, Azure, Azure, Google, Bing")
```

---

## Fallback Mechanism

### How Fallback Works

1. **Primary Attempt**: Use next provider in rotation (e.g., DeepL-Key0)
2. **If Fails**: Try next provider (e.g., Azure-Key0)
3. **If Fails**: Try ALL keys in that provider (e.g., Azure-Key1)
4. **If Fails**: Try next provider (e.g., Google)
5. **If Fails**: Continue until all providers exhausted

### Fallback Configuration

**NO additional configuration needed** - fallback is built into `RoundRobinTranslator`.

Just ensure:
- ✅ Multiple providers enabled in `ProviderOrder`
- ✅ API keys populated for paid providers
- ✅ `GoogleEnabled` and/or `BingEnabled` set to `true` for free fallback

### Best Practices

1. **Always include Google Free** as fallback (unlimited, no API key)
2. **Use Bing only as last resort** (very unreliable)
3. **Monitor fallback usage** (see [Monitoring](#monitoring) section)
4. **Set reasonable provider order**:
   - **Recommended**: `["DeepL", "Azure", "Google", "Bing"]`
   - **Cost-optimized**: `["Google", "DeepL", "Azure", "Bing"]`
   - **Quality-first**: `["DeepL", "Azure", "Google"]` (disable Bing)

---

