## NuGet Packages

All translation providers are distributed as individual NuGet packages from the Olbrasoft organization.

### Core Package

| Package | Version | Description |
|---------|---------|-------------|
| `Olbrasoft.Text.Translation` | Latest | Base interfaces and abstractions |

### Provider Packages

| Package | Version | Type | API Key Required |
|---------|---------|------|------------------|
| `Olbrasoft.Text.Translation.Azure` | 10.0.2 | Official API | ✅ Yes (Free F0: 2M chars/month) |
| `Olbrasoft.Text.Translation.DeepL` | 10.0.2 | Official API | ✅ Yes (Free: 500k chars/month) |
| `Olbrasoft.Text.Translation.Google` | 10.0.2 | Unofficial (web scraping) | ❌ No (Unlimited with soft limits) |
| `Olbrasoft.Text.Translation.Bing` | 10.0.2 | Unofficial (web scraping) | ❌ No (Rate-limited, unreliable) |

**Installation**:

```bash
dotnet add package Olbrasoft.Text.Translation.Azure --version 10.0.2
dotnet add package Olbrasoft.Text.Translation.DeepL --version 10.0.2
dotnet add package Olbrasoft.Text.Translation.Google --version 10.0.2
dotnet add package Olbrasoft.Text.Translation.Bing --version 10.0.2
```

---

