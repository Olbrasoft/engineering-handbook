# Task Assignment Framework

A practical guide for preparing well-defined tasks for developers. Focus on **WHAT** and **WHY**, leave **HOW** to the programmer.

## Role Division

| Role | Analyst | Programmer |
|------|---------|------------|
| **Responsibility** | Analyzes, proposes, creates issues, reviews, tests | Implements, debugs, deploys |
| **Focus** | WHAT & WHY | HOW |
| **Output** | Well-defined tasks with acceptance criteria | Working code |

### What Analyst Does
- Understands and describes the problem
- Defines requirements from user perspective
- Sets measurable acceptance criteria
- Tests the result (API calls, UI verification)
- Reports bugs with expected vs actual behavior

### What Analyst Does NOT Do
- Make implementation decisions (database schema, architecture)
- Debug code
- Choose specific technologies or libraries

---

## Task Template

```markdown
## Summary
[One sentence: What needs to be done and why]

## User Story
As a [persona/role], I want to [action/feature], so that [benefit/value].

## Context
- Current state: [What exists now]
- Problem: [What's wrong or missing]
- Related: #issue_number (if applicable)

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
- What this task does NOT include
```

---

## Checklist Before Assigning Task

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
- [ ] Task is small enough to complete in one session?
- [ ] No hidden dependencies?
- [ ] Out of scope is defined?

### Testability
- [ ] Can be verified independently?
- [ ] Success criteria are objective?

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

4. ASSIGN
   - Create GitHub issue
   - Tag appropriately
   - Reference parent issues if applicable

5. VERIFY
   - Test functionality (API/CLI/UI)
   - Works → Close issue
   - Fails → Comment with: "Tested X, expected Y, got Z"
```

---

## Examples

### Good Task Description
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

### Bad Task Description (Too Technical)
> Create an endpoint `GET /api/users/{id}/profile` using the UserRepository pattern. Use a DTO with AutoMapper. Store avatar in Azure Blob Storage with CDN caching.

**Why it's bad:** Dictates implementation details. The programmer should decide the endpoint structure, patterns, and storage solutions.

### Bad Task Description (Too Vague)
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
- Break large tasks into smaller pieces

### DON'T
- Specify database schema or table structure
- Choose frameworks or libraries
- Define API endpoint paths or HTTP methods
- Make architectural decisions
- Use ambiguous language ("should work", "might need")

---

## References

- [Atlassian User Stories Guide](https://www.atlassian.com/agile/project-management/user-stories)
- [Mountain Goat Software - User Stories](https://www.mountaingoatsoftware.com/agile/user-stories)
