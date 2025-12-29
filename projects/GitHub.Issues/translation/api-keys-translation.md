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

**Location**: `~/Dokumenty/přístupy/api-keys.md` (lines 661-746)

DeepL API keys are stored securely in the local access credentials file. Each key includes:
- Key value (with `:fx` suffix for Free tier)
- Associated email account
- Tier information (Free: 500k chars/month)
- Current status and usage
- Reset date (based on account creation date)
- Designated usage (Primary/Secondary for GitHub.Issues)

**To access keys**: See `~/Dokumenty/přístupy/api-keys.md`

**Important Notes**:
- DeepL Free keys have `:fx` suffix
- Reset date is based on **account creation date**, NOT calendar month
- Each key is tied to specific email account

#### Azure Translator Keys

**Location**: `~/Dokumenty/přístupy/api-keys.md` (lines 103-110)

Azure Translator API keys are stored securely in the local access credentials file. Configuration includes:
- Resource name and region
- Tier information (Free F0: 2M chars/month)
- Two active keys (KEY 1 and KEY 2)

**To access keys**: See `~/Dokumenty/přístupy/api-keys.md`

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

