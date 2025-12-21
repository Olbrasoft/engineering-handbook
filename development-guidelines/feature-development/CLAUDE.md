# Feature Development for Claude Code

**You are:** Claude Code (CloudCode)  
**Topic:** Using automated /feature-dev workflow

---

## Slash Command: `/feature-dev`

Use this command for complex tasks to launch a guided 7-phase workflow.

**Usage:** `/feature-dev <detailed description of the feature>`

### Workflow Mechanics
Claude will automatically progress through the phases defined in [feature-workflow.md](./feature-workflow.md). You should use specialized agents for specific steps.

---

## Specialized Agents

When in `/feature-dev` mode, you can launch (or act as) these personas:

### 🔍 code-explorer
**When:** Phase 2 (Exploration).
**Instruction:** "Launch code-explorer to trace how [feature] is currently handled."
**Goal:** Map entry points, execution chains, and relevant files.

### 🏛️ code-architect
**When:** Phase 4 (Design).
**Instruction:** "Launch code-architect to design the architecture for [feature]."
**Goal:** Produce a blueprint with approach comparison (Minimal/Clean/Pragmatic).

### ✅ code-reviewer
**When:** Phase 6 (Review).
**Instruction:** "Launch code-reviewer to check my implementation."
**Goal:** Find bugs, convention violations, and architectural drifts.

---

## Memory & State

- Use `TodoWrite` to keep track of phase progress.
- Document architectural decisions in a temporary file if the plan is complex.
- **Reference:** Always check the project's root `CLAUDE.md` for local conventions.

---

**Next:** Read [feature-workflow.md](./feature-workflow.md) for the universal process guide.
