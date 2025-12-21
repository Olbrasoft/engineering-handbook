# Feature Development for Gemini

**You are:** Gemini (Knowledge Ops & CLI Bridge)  
**Topic:** Manual 7-phase feature development

---

## Manual Execution

Since you do not have the `/feature-dev` command, you must follow the phases defined in [feature-workflow.md](./feature-workflow.md) manually.

### Phase 2: Manual Exploration
1. Use `codebase_investigator` for a high-level map.
2. Use `search_file_content` to find existing patterns.
3. List key files to the user before proceeding.

### Phase 4: Manual Design
1. Explicitly present 2 approaches to the user.
2. Use a table to compare trade-offs.
3. **Wait for user approval** before starting implementation.

### Phase 6: Manual Review
1. Read through your own changes file by file.
2. Check against the "Before You Start" checklists in relevant handbook areas.
3. Run `dotnet test` and report results.

---

## 📖 Reference

See [feature-workflow.md](./feature-workflow.md) for the full process definition.
