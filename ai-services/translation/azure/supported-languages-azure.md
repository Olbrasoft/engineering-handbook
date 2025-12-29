## Supported Languages

Azure Translator supports **100+ languages** (as of 2025).

**Popular Languages**:

| Code | Language | Code | Language |
|------|----------|------|----------|
| `cs` | Czech | `pl` | Polish |
| `de` | German | `pt` | Portuguese |
| `en` | English | `ru` | Russian |
| `es` | Spanish | `sk` | Slovak |
| `fr` | French | `sv` | Swedish |
| `it` | Italian | `tr` | Turkish |
| `ja` | Japanese | `uk` | Ukrainian |
| `ko` | Korean | `zh-Hans` | Chinese (Simplified) |
| `nl` | Dutch | `zh-Hant` | Chinese (Traditional) |
| `ar` | Arabic | `hi` | Hindi |

**Get full list**:
```bash
curl -X GET 'https://api.cognitive.microsofttranslator.com/languages?api-version=3.0&scope=translation' | jq
```

**Note**: Language codes are **lowercase** (unlike DeepL which uses uppercase).

---

