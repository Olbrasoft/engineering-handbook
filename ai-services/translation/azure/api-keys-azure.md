## API Keys

### Our API Keys

**Location**: `~/Dokumenty/přístupy/api-keys.md` (lines 103-110)

#### Resource: olbrasoft-translator
- **Region**: West Europe
- **Tier**: Free F0 (2M chars/month)
- **Resource Group**: olbrasoft-resources (or similar)

**Keys** (both active, **share same quota**):

| Key Name | API Key | Status |
|----------|---------|--------|
| **KEY 1** | `YOUR_AZURE_TRANSLATOR_KEY_1` | ✅ Active |
| **KEY 2** | `YOUR_AZURE_TRANSLATOR_KEY_2` | ✅ Active |

**Total Capacity**: 2,000,000 characters/month (shared between both keys)

**Usage Pattern**:
- Use key rotation for **load balancing**, NOT quota multiplication
- Both keys access the same backend resource
- Useful for zero-downtime key rotation

### Key Format

Azure Translator API keys are **64 characters** long:
```
YOUR_AZURE_TRANSLATOR_KEY_HERE (64 characters)
```

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
- etc.

---

