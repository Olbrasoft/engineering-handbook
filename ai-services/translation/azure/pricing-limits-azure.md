## Pricing Tiers

| Tier | Monthly Cost | Characters/Month | Price per Million | Features |
|------|--------------|------------------|-------------------|----------|
| **Free (F0)** | €0 | 2,000,000 | Free | Text translation only |
| **Standard (S1)** | Pay-as-you-go | Unlimited | €8.50 | + Custom models |
| **Standard (S2)** | Pay-as-you-go | Unlimited | €7.00 (volume discount) | + Custom models |
| **Standard (S3)** | Pay-as-you-go | Unlimited | €5.00 (high volume) | + Custom models |
| **Standard (S4)** | Pay-as-you-go | Unlimited | €3.50 (very high volume) | + Custom models |

**Important Notes**:
- Free tier (F0): 2 million characters/month, **hard limit**
- When F0 limit reached, API returns **HTTP 403 (Forbidden)**
- Multiple API keys from same resource **share the same quota**
- Standard tiers have no monthly limit, pay per character
- Character counting uses UTF-8 character count

---

## Usage Limits

### Free Tier (F0)

| Limit Type | Value | Description |
|------------|-------|-------------|
| **Characters/Month** | 2,000,000 | Hard limit, strictly enforced |
| **Characters/Request** | 50,000 | Maximum total characters per API call |
| **Requests/Minute** | ~330 | Rate limit (not officially documented) |
| **Requests/Month** | Unlimited | No request count limit |

**Important**:
- When limit is reached, API returns **HTTP 403 (Forbidden)**
- Character count includes ALL text in request (even if already translated)
- Multiple keys from same resource **share quota** (not multiplied!)

**Critical Note about Multiple Keys**:
```
Resource: olbrasoft-translator (Free F0)
├── KEY 1: 1NW1oPDvnCUVPRv6...  ┐
└── KEY 2: EKLQCeSdPR1PRY0K...  ├─ Both share 2M quota!
                                └─ Total: 2M (NOT 4M!)
```

### Standard Tiers

- No monthly character limit
- Pay per character (see pricing table)
- Higher rate limits
- 99.9% SLA

---

