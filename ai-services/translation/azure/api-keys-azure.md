## API Keys

### Storage Location

**All Olbrasoft projects use SecureStore** for API key storage.

See [Secrets Management](../../../development-guidelines/secrets-management.md#securestore---standard-for-olbrasoft-projects) for setup instructions.

**SecureStore paths:**
```
~/.config/{app-name}/secrets/secrets.json  # Encrypted vault
~/.config/{app-name}/keys/secrets.key      # Encryption key
```

**Example for GitHub.Issues:**
```bash
# Add Azure Translator keys
SecureStore set -s ~/.config/github-issues/secrets/secrets.json \
  -k ~/.config/github-issues/keys/secrets.key \
  "TranslatorPool:AzureApiKey1=YOUR_KEY_HERE"
```

### Resource: olbrasoft-translator

- **Region**: West Europe
- **Tier**: Free F0 (2M chars/month)
- **Resource Group**: olbrasoft-resources

**Keys** (both active, **share same quota**):

| Key Name | SecureStore Key | Status |
|----------|-----------------|--------|
| **KEY 1** | `TranslatorPool:AzureApiKey1` | ✅ Active |
| **KEY 2** | `TranslatorPool:AzureApiKey2` | ✅ Active |

**Total Capacity**: 2,000,000 characters/month (shared between both keys)

**Usage Pattern**:
- Use key rotation for **load balancing**, NOT quota multiplication
- Both keys access the same backend resource
- Useful for zero-downtime key rotation

### Key Format

Azure Translator API keys are **64 characters** long (hexadecimal).

### Required Configuration

**Headers**:
```
Ocp-Apim-Subscription-Key: YOUR_API_KEY
Ocp-Apim-Subscription-Region: westeurope
```

**Region** must match your Azure resource location:
- `westeurope` - West Europe (Ireland)
- `northeurope` - North Europe (Netherlands)
- `eastus` - East US

---

