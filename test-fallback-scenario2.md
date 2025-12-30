# Azure Translator Fallback - Scenario 2 Test

**Test Type:** Production verification - Fallback activation
**Test Date:** 2025-12-30
**Scenario:** Primary account failure → Fallback activation

## Test Objective

Verify that when primary Azure Translator account fails (401 Unauthorized), the fallback account automatically activates and translation succeeds.

## Expected Behavior

1. Primary account fails with 401 error (invalid API key)
2. Fallback mechanism detects eligible error
3. Automatically retries with fallback account
4. Translation succeeds using fallback
5. Czech embedding created in database

## Test Configuration

- Primary API key: Temporarily invalidated
- Fallback API key: Valid
- File size: ~350 characters (minimal quota usage)
- Expected workflow: Update Handbook Embeddings

## Success Criteria

- ✅ Primary account fails as expected
- ✅ Fallback activates automatically
- ✅ Translation completes successfully
- ✅ Logs show clear fallback sequence
- ✅ Czech embedding created

**Character count:** ~300 chars for minimal API quota usage
