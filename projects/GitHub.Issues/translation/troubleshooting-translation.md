## Troubleshooting

### Issue: Translations Always Return Original Text

**Symptom**: Translations not working, always returns original English text.

**Causes**:
1. ❌ All API keys missing or empty (`AzureApiKeys: []`, `DeepLApiKeys: []`)
2. ❌ Google and Bing both disabled (`GoogleEnabled: false`, `BingEnabled: false`)
3. ❌ All providers rate-limited or quota exceeded

**Solution**:

Check configuration:

```bash
# Check production config
cat /opt/olbrasoft/github-issues/config/appsettings.json | grep -A 10 "TranslatorPool"

# Verify API keys are populated
cat /opt/olbrasoft/github-issues/config/appsettings.json | grep "ApiKeys"

# Check if Google/Bing enabled
cat /opt/olbrasoft/github-issues/config/appsettings.json | grep "Enabled"
```

Expected:
- ✅ At least one provider has API keys OR Google/Bing enabled
- ✅ `ProviderOrder` contains enabled providers

**Related**: [Issue #301](https://github.com/Olbrasoft/GitHub.Issues/issues/301)

---

### Issue: DeepL Returns HTTP 456 (Quota Exceeded)

**Symptom**: DeepL translations fail with error: `HTTP 456: Quota exceeded`

**Cause**: DeepL Free tier quota (500k chars/month) exhausted for that key.

**Solution**:

1. **Check DeepL usage**:

```bash
curl -X GET 'https://api-free.deepl.com/v2/usage' \
  -H "Authorization: DeepL-Auth-Key YOUR_KEY_HERE:fx"
```

2. **If exhausted**:
   - ✅ Add another DeepL key to `DeepLApiKeys` array
   - ✅ OR wait until reset date (check account creation date)
   - ✅ OR remove exhausted key from config

3. **Update config**:

**Note**: Get actual API keys from `~/Dokumenty/přístupy/api-keys.md`

```json
{
  "TranslatorPool": {
    "DeepLApiKeys": [
      "YOUR_DEEPL_API_KEY_1:fx",  // Active key 1
      "YOUR_DEEPL_API_KEY_2:fx"   // Active key 2
      // Remove exhausted keys from array
    ]
  }
}
```

**Related**: [Issue #303](https://github.com/Olbrasoft/GitHub.Issues/issues/303)

---

### Issue: Bing Returns HTTP 429 (Too Many Requests)

**Symptom**: Bing translations fail frequently with: `Response status code does not indicate success: 429 (Too Many Requests)`

**Cause**: Bing Free Translator has very aggressive rate limiting (unofficial API).

**Solution**:

1. **Move Bing to last position** in `ProviderOrder`:

```json
{
  "TranslatorPool": {
    "ProviderOrder": ["DeepL", "Azure", "Google", "Bing"]
  }
}
```

2. **OR disable Bing entirely**:

```json
{
  "TranslatorPool": {
    "BingEnabled": false
  }
}
```

**Recommendation**: Use Bing only as absolute last resort.

**Related**: [Issue #301](https://github.com/Olbrasoft/GitHub.Issues/issues/301)

---

### Issue: All Providers Fail

**Symptom**: Translation fails with error: `All translators failed. Attempted: DeepL, Azure, Google, Bing`

**Causes**:
1. ❌ Network connectivity issue
2. ❌ All API keys exhausted/invalid
3. ❌ All free providers rate-limited simultaneously

**Solution**:

1. **Check logs** for specific errors:

```bash
journalctl --user -u github-issues.service -n 100 | grep Translation
```

2. **Verify API keys**:

```bash
# Test DeepL
curl -X POST 'https://api-free.deepl.com/v2/translate' \
  -H "Authorization: DeepL-Auth-Key YOUR_KEY:fx" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "text=Hello&target_lang=CS"

# Test Azure
curl -X POST 'https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&to=cs' \
  -H "Ocp-Apim-Subscription-Key: YOUR_KEY" \
  -H "Ocp-Apim-Subscription-Region: westeurope" \
  -H "Content-Type: application/json" \
  -d '[{"Text":"Hello"}]'
```

3. **Check network**:

```bash
ping api.deepl.com
ping api.cognitive.microsofttranslator.com
```

---

### Issue: Fallback Not Working

**Symptom**: When primary provider fails, no fallback occurs.

**Causes**:
1. ❌ Only one provider enabled in `ProviderOrder`
2. ❌ Fallback providers also have no API keys
3. ❌ Exception in `RoundRobinTranslator` preventing fallback

**Solution**:

1. **Verify ProviderOrder has multiple providers**:

```json
{
  "TranslatorPool": {
    "ProviderOrder": ["DeepL", "Azure", "Google"],  // ✓ Multiple providers
    "GoogleEnabled": true,  // ✓ At least one enabled
    "DeepLApiKeys": ["key1:fx"]  // ✓ At least one key
  }
}
```

2. **Check logs for exceptions**:

```bash
grep -i "roundrobin\|fallback" /opt/olbrasoft/github-issues/logs/*.log
```

3. **Enable detailed logging**:

```json
{
  "Logging": {
    "LogLevel": {
      "Olbrasoft.GitHub.Issues.Business.Services.RoundRobinTranslator": "Debug"
    }
  }
}
```

---

### Issue: Azure Keys Not Working

**Symptom**: Azure translations fail with `401 Unauthorized` or `403 Forbidden`.

**Causes**:
1. ❌ Invalid API key
2. ❌ Wrong region specified
3. ❌ Free tier quota exhausted (2M chars/month)

**Solution**:

1. **Verify key format** (should be 64 characters):

```bash
echo "YOUR_AZURE_TRANSLATOR_KEY_1" | wc -c
# Should output: 65 (64 chars + newline)
```

2. **Test key directly**:

```bash
curl -X POST 'https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&to=cs' \
  -H "Ocp-Apim-Subscription-Key: YOUR_KEY_HERE" \
  -H "Ocp-Apim-Subscription-Region: westeurope" \
  -H "Content-Type: application/json" \
  -d '[{"Text":"Hello"}]'
```

3. **Check quota in Azure Portal**:
   - Go to Azure Portal → Cognitive Services → Translator resource
   - Check "Metrics" → "Characters Translated"

---

