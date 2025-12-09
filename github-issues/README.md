# GitHub Issues

Guidelines for creating and managing GitHub issues effectively.

## Contents

- [Issue Writing Guide](./issue-writing-guide.md) - How to write clear, actionable issue specifications

## Quick Reference

### The Golden Rule

**Analyst focuses on WHAT and WHY, Programmer decides HOW.**

### Issue Checklist

Before creating any issue, verify:

1. **Clear** - Can be understood without asking questions
2. **Complete** - Has user story, requirements, acceptance criteria
3. **Scoped** - Defines what's included AND what's not
4. **Testable** - Success can be objectively verified

### Minimum Viable Issue

```markdown
## Summary
[What + Why in one sentence]

## User Story
As a [who], I want [what], so that [why].

## Acceptance Criteria
- [ ] Given X, when Y, then Z
```

---

## Sub-Issues: The Correct Way

**Sub-issues MUST be linked via GitHub's sub-issue feature, NOT as text references in the body.**

### The Wrong Way

Writing text references in the issue body:
- "Part of #123"
- "Sub-issue of #123"
- "Parent Issue: #123"

This creates NO actual relationship in GitHub. It's just text that someone has to manually parse and maintain.

### The Correct Way

Use GitHub's native sub-issue linking:

1. **Via UI**: Open parent issue → Click "Add sub-issue" button
2. **Via API**: `POST /repos/{owner}/{repo}/issues/{parent_number}/sub_issues` with `{"sub_issue_id": <child_issue_id>}`

### Why This Matters

| Feature | Text Reference | Native Sub-Issue |
|---------|---------------|------------------|
| Progress tracking | Manual counting | Automatic % complete |
| Navigation | Search/scroll | Direct links both ways |
| Reporting | Not possible | Built-in summaries |
| Automation | Fragile regex | Reliable API |
| Closing parent | Manual check | Blocks if incomplete |
