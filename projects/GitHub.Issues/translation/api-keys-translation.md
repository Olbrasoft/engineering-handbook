## API Keys Management

### Storage with SecureStore

**CRITICAL SECURITY RULE**: API keys are **NEVER committed to Git**.

GitHub.Issues uses **NeoSmart.SecureStore** for encrypted API key storage.

**Storage Location:**
```
~/.config/github-issues/
├── secrets/
│   └── secrets.json      # Encrypted vault (AES + HMAC)
└── keys/
    └── secrets.key       # Encryption key (chmod 600!)
```

See [Secrets Management](../../../development-guidelines/secrets-management.md#securestore---standard-for-olbrasoft-projects) for complete setup guide.

### Managing API Keys

```bash
# Define paths
SECRETS_PATH=~/.config/github-issues/secrets/secrets.json
KEY_PATH=~/.config/github-issues/keys/secrets.key

# List all secrets
SecureStore get -s $SECRETS_PATH -k $KEY_PATH --all

# Add/update a key
SecureStore set -s $SECRETS_PATH -k $KEY_PATH "TranslatorPool:DeepLApiKey1=YOUR_KEY:fx"
```

### Translation API Keys

| Provider | SecureStore Key | Tier | Monthly Quota |
|----------|-----------------|------|---------------|
| DeepL #1 | `TranslatorPool:DeepLApiKey1` | Free | 500k chars |
| DeepL #2 | `TranslatorPool:DeepLApiKey2` | Free | 500k chars |
| Azure #1 | `TranslatorPool:AzureApiKey1` | Free F0 | 2M chars (shared) |
| Azure #2 | `TranslatorPool:AzureApiKey2` | Free F0 | 2M chars (shared) |

**Notes:**
- DeepL Free keys have `:fx` suffix
- Azure keys share quota (2M total, NOT 4M)
- DeepL resets on account creation date, Azure on 1st of month

### Current Production Configuration

**Active Providers** (priority order):

1. **DeepL** - 2 keys = 1M chars/month
2. **Azure** - 2 keys = 2M chars/month total
3. **Google** - No key = Unlimited (soft limits)
4. **Bing** - No key = Rate-limited (last resort)

**Total Guaranteed Capacity**: ~3M chars/month + unlimited Google

---

