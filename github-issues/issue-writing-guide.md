# Issue Writing Guide

A practical guide for preparing well-defined GitHub issues. Focus on **WHAT** and **WHY**, leave **HOW** to the programmer.

> **Note:** Role division (Analyst vs Programmer) is defined in `~/.config/opencode/AGENTS.md`

## Issue Template

```markdown
## Summary
[One sentence: What needs to be done and why]

## User Story
As a [persona/role], I want to [action/feature], so that [benefit/value].

## Context
- Current state: [What exists now]
- Problem: [What's wrong or missing]

## Requirements
### Must Have
- [ ] Requirement 1
- [ ] Requirement 2

### Should Have (if time permits)
- [ ] Optional enhancement

## Acceptance Criteria
- [ ] Given [context], when [action], then [expected result]
- [ ] Given [context], when [action], then [expected result]

## Out of Scope
- What this issue does NOT include
```

---

## Sub-Issues: The Critical Rule

**Sub-issues MUST be linked via GitHub's native sub-issue feature, NOT as text references.**

### The Wrong Way

Do NOT write these in issue body:
- "Part of #123"
- "Sub-issue of #123"  
- "Parent Issue: #123"
- "## Parent Issue\n#123"

This creates NO actual parent-child relationship. It's just text.

### The Correct Way

**Option 1: Via GitHub UI**
1. Open the parent issue
2. Click "Add sub-issue" button (or find it in the sidebar)
3. Select or create the child issue

**Option 2: Via GitHub API**
```bash
curl -X POST \
  -H "Authorization: token YOUR_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/OWNER/REPO/issues/PARENT_NUMBER/sub_issues" \
  -d '{"sub_issue_id": CHILD_ISSUE_ID}'
```

### Why Native Sub-Issues Matter

| Aspect | Text Reference | Native Sub-Issue |
|--------|---------------|------------------|
| Progress tracking | Manual counting | Automatic percentage |
| Navigation | Search required | Direct bidirectional links |
| Reporting | Not possible | Built-in summaries |
| Automation | Fragile regex parsing | Reliable API access |
| Parent completion | Manual verification | Automatic blocking |
| Visibility | Hidden in body text | Prominent in UI |

---

## Checklist Before Creating Issue

### Clarity
- [ ] Can be understood without additional context?
- [ ] No ambiguous terms (avoid "should", "might", "probably")?
- [ ] Written in user's language, not technical jargon?

### Completeness
- [ ] WHO benefits is clear?
- [ ] WHAT needs to be done is defined?
- [ ] WHY it's needed is explained?
- [ ] Acceptance criteria are measurable?

### Scope
- [ ] Issue is small enough to complete in one session?
- [ ] No hidden dependencies?
- [ ] Out of scope is defined?

### Testability
- [ ] Can be verified independently?
- [ ] Success criteria are objective?

### Relationships
- [ ] If this is a sub-issue, is it LINKED (not just referenced) to parent?
- [ ] Related issues are mentioned in Context section?

---

## Workflow

```
1. ANALYZE
   - Understand the problem
   - Research if needed
   - Identify who benefits

2. DEFINE
   - Write user story
   - List requirements (WHAT, not HOW)
   - Set acceptance criteria

3. VALIDATE
   - Review with checklist
   - Remove implementation details
   - Check for ambiguity

4. CREATE
   - Create GitHub issue with proper template
   - Tag appropriately
   - LINK to parent issue if sub-issue (don't just reference!)

5. VERIFY
   - Test functionality (API/CLI/UI)
   - Works → Close issue
   - Fails → Comment with: "Tested X, expected Y, got Z"
```

---

## Examples

### Good Issue Description
> **Summary:** Users need to see their profile information.
>
> **User Story:** As a logged-in user, I want to view my profile, so that I can verify my account details.
>
> **Requirements:**
> - Display user's name, email, and avatar
> - Show registration date
> - Return appropriate error if user not found
>
> **Acceptance Criteria:**
> - Given a valid user ID, when I request the profile, then I receive name, email, avatar URL, and registration date
> - Given an invalid user ID, when I request the profile, then I receive a 404 error

### Bad Issue Description (Too Technical)
> Create an endpoint `GET /api/users/{id}/profile` using the UserRepository pattern. Use a DTO with AutoMapper. Store avatar in Azure Blob Storage with CDN caching.

**Why it's bad:** Dictates implementation details. The programmer should decide the endpoint structure, patterns, and storage solutions.

### Bad Issue Description (Too Vague)
> Fix the user profile thing

**Why it's bad:** No context, no expected behavior, no way to verify success.

---

### Good Bug Report
> **Tested:** User profile for ID 123
> **Expected:** 200 OK with profile JSON
> **Got:** 500 Internal Server Error
> **Notes:** Happens only for users created before 2024

### Bad Bug Report
> Profile doesn't work, please fix

---

## Issue Labels

| Label | Use For |
|-------|---------|
| `feature` | New functionality |
| `bug` | Something broken |
| `enhancement` | Improvement to existing feature |
| `refactor` | Code cleanup, no behavior change |
| `docs` | Documentation only |

---

## Key Principles

### DO
- Write from user's perspective
- Write implementation-neutral requirements (WHAT, not HOW)
- Include acceptance criteria
- Prioritize requirements (must have / should have)
- Break large issues into smaller sub-issues
- **LINK sub-issues properly using GitHub's feature**

### DON'T
- Specify database schema or table structure
- Choose frameworks or libraries
- Define API endpoint paths or HTTP methods
- Make architectural decisions
- Use ambiguous language ("should work", "might need")
- **Write "Part of #X" instead of actually linking sub-issues**

---

## References

- [GitHub Sub-Issues Documentation](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/adding-sub-issues)
- [Atlassian User Stories Guide](https://www.atlassian.com/agile/project-management/user-stories)
- [Mountain Goat Software - User Stories](https://www.mountaingoatsoftware.com/agile/user-stories)
