## API Keys Management

### Where API Keys Are Stored

**CRITICAL SECURITY RULE**: API keys are **NEVER committed to Git**.

| Location | Purpose | Contains |
|----------|---------|----------|
| `~/Dokumenty/přístupy/api-keys.md` | Master key storage (local only) | All API keys with metadata |
| `/opt/olbrasoft/github-issues/config/appsettings.json` | Production runtime config | Actual keys used by app |
| `src/*/appsettings.json` | Source code template | Empty arrays `[]` - NO keys! |
| Environment variables | Runtime injection | Connection strings, sensitive data |

### API Keys Structure

**File**: `~/Dokumenty/přístupy/api-keys.md` (NEVER commit to Git!)

#### DeepL API Keys

Located at lines 661-746 in `api-keys.md`:

```markdown
## DeepL API Keys

### 1. Main (github.issues@email.cz)
- **Key**: `83a8506c-4a9b-4ca5-ad45-9bdcd858ce2a:fx`
- **Tier**: Free (500k chars/month)
- **Status**: EXHAUSTED (500k/500k used)
- **Reset Date**: 2026-01-12 (account creation date)
- **Usage**: Primary for GitHub.Issues (currently disabled due to exhaustion)

### 2. Crow (tuma.rsrobot@gmail.com)
- **Key**: `c236f93a-7fd9-4225-beb3-cfacc1f32f18:fx`
- **Tier**: Free (500k chars/month)
- **Status**: ACTIVE - 100% available (0/500k used)
- **Reset Date**: Account-specific (check DeepL dashboard)
- **Usage**: Primary replacement for GitHub.Issues

### 3. OpenCode (opencode@seznam.cz)
- **Key**: `96470ca9-c69b-4f13-99d6-3f49b76af4cd:fx`
- **Tier**: Free (500k chars/month)
- **Status**: ACTIVE - 93.5% available (32,735/500k used)
- **Reset Date**: Account-specific (check DeepL dashboard)
- **Usage**: Secondary for GitHub.Issues
```

**Important Notes**:
- DeepL Free keys have `:fx` suffix
- Reset date is based on **account creation date**, NOT calendar month
- Each key is tied to specific email account

#### Azure Translator Keys

Located at lines 103-110 in `api-keys.md`:

```markdown
## Azure Translator API Keys

### Resource: olbrasoft-translator
- **Region**: West Europe
- **Tier**: Free F0 (2M chars/month)

### Keys (both active)
- **KEY 1**: `YOUR_AZURE_TRANSLATOR_KEY_1`
- **KEY 2**: `YOUR_AZURE_TRANSLATOR_KEY_2`

**Usage**: Both keys share the same 2M character quota (not 2M each!)
```

**Important Notes**:
- Both keys share the **same quota** (2M total, NOT 4M)
- Use key rotation for load balancing, not quota multiplication
- Reset date is calendar month (1st of each month)

### Current Production Configuration (2025-12-29)

**Active Providers** (in order):

1. **DeepL** - 2 keys (Crow + OpenCode) = 1M chars/month available
2. **Azure** - 2 keys = 2M chars/month total
3. **Google** - No key = Unlimited (soft limits)
4. **Bing** - No key = Rate-limited (last resort)

**Total Guaranteed Capacity**: ~3M chars/month + unlimited Google

---

