# Test Workflow

This is a test file to verify the updated GitHub Actions workflow for HandbookSearch embeddings.

**Test run #8**: Testing with correct .NET Configuration variable name (AzureTranslator__ApiKey).

## Purpose

Testing automatic import with:
- Deployed CLI at `/opt/olbrasoft/handbook-search/cli/`
- Czech translation and embeddings
- New qwen3-embedding:0.6b model (1024 dimensions)

## Expected Behavior

When this file is pushed to main branch:
1. tj-actions/changed-files detects this as added file
2. Workflow imports the file with `--translate-cs` flag
3. Both English and Czech embeddings are generated
4. Document is stored in handbook_search database

## Verification

Check database after workflow completes:
```sql
SELECT id, file_path, title, embedding IS NOT NULL as has_en, embedding_cs IS NOT NULL as has_cs
FROM documents
WHERE file_path = 'test-workflow.md';
```

Expected result:
- `has_en`: true (English embedding)
- `has_cs`: true (Czech embedding)
