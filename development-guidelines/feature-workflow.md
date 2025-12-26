# Feature Development Workflow

This guide describes the systematic 7-phase process for building new features. For complex tasks, following this structure prevents ambiguity bugs and over-engineering.

---

## 🧭 The 7-Phase Process

### 1. Discovery
**Goal:** Clarify the "What" and "Why".
- Identify stakeholders and end-users.
- Define core requirements and success metrics.
- Identify constraints (performance, security, compatibility).

### 2. Codebase Exploration
**Goal:** Understand the "Where".
- Locate entry points and related existing features.
- Trace execution flows and data structures.
- Identify patterns to mimic (or refactor).

### 3. Clarifying Questions
**Goal:** Resolve ambiguities BEFORE design.
- List all unknowns.
- Confirm assumptions with the user/stakeholder.
- **Rule:** Do not proceed to Architecture Design until all critical questions are answered.

### 4. Architecture Design
**Goal:** Define the "How".
- Propose 2-3 approaches (Minimal / Clean / Pragmatic).
- Compare trade-offs (Maintenance vs. Speed vs. Flexibility).
- Create an implementation map (files to create/modify).

### 5. Implementation
**Goal:** Build the feature.
- Follow the chosen architecture.
- Write tests alongside code.
- Commit atomically after each logical step.

### 6. Quality Review
**Goal:** Verify the "Is it good?".
- Self-review from multiple perspectives (Simplicity, DRY, Bugs, Conventions).
- Run the full test suite.
- Ensure 100% functionality of the new feature.

### 7. Summary
**Goal:** Close the loop.
- Document what was built and how to use it.
- Update relevant handbook sections if new patterns were established.
- Close the issue after user approval.

---

## ⚖️ Systematic vs. Ad-hoc

| Approach | When to use | Benefits |
|----------|-------------|----------|
| **Systematic (7-phase)** | New complex features, major refactorings | High quality, low regression risk, better architecture |
| **Ad-hoc (Quick fix)** | Simple bugs, minor text changes, documentation fixes | Speed, low overhead |

---

## ✅ Before You Start - Feature Workflow

- [ ] I understand all 7 phases of the workflow.
- [ ] I've decided if this task requires a Systematic or Ad-hoc approach.
- [ ] I've checked for existing similar features to explore.

---

## Related Topics

- 🏗️ [Architecture Design](./architecture-design.md) - Deep dive into Phase 4
- 🔍 [Code Exploration](./code-exploration.md) - Techniques for Phase 2
- 🌿 [Git Workflow](../workflow/workflow.md) - Committing and PRs
