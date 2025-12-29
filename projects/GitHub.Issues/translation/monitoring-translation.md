## Monitoring

### Translation Attempt Logging

**See Issue #302** for complete monitoring system design.

**Table**: `TranslationAttempts`

```sql
CREATE TABLE TranslationAttempts (
    Id BIGINT PRIMARY KEY IDENTITY(1,1),
    IssueId INT NOT NULL,
    TextType NVARCHAR(20) NOT NULL,  -- 'Title', 'Summary', 'Body'
    TargetLanguage NVARCHAR(5) NOT NULL,
    Provider NVARCHAR(50) NOT NULL,
    AttemptNumber INT NOT NULL,  -- 1 = primary, 2+ = fallback
    Success BIT NOT NULL,
    ErrorMessage NVARCHAR(MAX) NULL,
    HttpStatusCode INT NULL,
    DurationMs INT NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),

    INDEX IX_Provider_Success (Provider, Success),
    INDEX IX_CreatedAt (CreatedAt)
);
```

### Metrics Queries

**Success Rate by Provider** (last 7 days):

```sql
SELECT
    Provider,
    COUNT(*) AS TotalAttempts,
    SUM(CASE WHEN Success = 1 THEN 1 ELSE 0 END) AS Successful,
    CAST(SUM(CASE WHEN Success = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS SuccessRate
FROM TranslationAttempts
WHERE CreatedAt >= DATEADD(DAY, -7, GETUTCDATE())
GROUP BY Provider
ORDER BY SuccessRate DESC;
```

**Fallback Usage**:

```sql
SELECT
    CASE
        WHEN AttemptNumber = 1 THEN 'Primary'
        WHEN AttemptNumber = 2 THEN 'First Fallback'
        ELSE 'Multiple Fallbacks'
    END AS AttemptType,
    COUNT(*) AS Count
FROM TranslationAttempts
WHERE CreatedAt >= DATEADD(DAY, -7, GETUTCDATE())
GROUP BY CASE WHEN AttemptNumber = 1 THEN 'Primary' WHEN AttemptNumber = 2 THEN 'First Fallback' ELSE 'Multiple Fallbacks' END;
```

---

