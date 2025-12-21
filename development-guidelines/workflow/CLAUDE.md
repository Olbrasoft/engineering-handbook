# Git Workflow - Claude Code

**You are:** Claude Code  
**Topic:** Git branches, commits, GitHub issues, PRs

---

## Read This First

**Main guide:** [workflow.md](workflow.md)

This file contains:
- GitHub issues workflow
- Branch naming conventions
- Commit message format
- Sub-issues (NOT checkboxes!)
- Pull request workflow
- Testing requirements before closing issues
- Deployment checklist

---

## Key Practices for You

- Each issue = separate branch
- Commit + push after **every step**
- Close issue ONLY after: tests pass + deployed + **user approval**
- Use native GitHub sub-issues (via GitHub MCP)

---

## Slash Commands (commit-commands plugin)

Use these commands to automate the workflow defined in [workflow.md](workflow.md).

### `/commit`
**Use for:** Atomic commits during development.
- **Action:** Analyzes changes, stages files, and creates a commit.
- **Note:** Always review the diff before running this command.
- **Format:** Automatically follows our standard with Claude attribution.

### `/commit-push-pr`
**Use for:** Completing a feature and requesting review.
- **Action:** Commits remaining changes, pushes to origin, and creates a PR.
- **Requirement:** GitHub CLI (`gh`) must be authenticated.
- **Output:** Provides a PR description with a summary and a test plan.

### `/clean_gone`
**Use for:** Periodic repository maintenance.
- **Action:** Removes local branches that are marked as `[gone]` (deleted from remote).
- **Tip:** Run this after your PRs have been merged and remote branches deleted.

---

**Next:** Read [workflow.md](workflow.md) for complete workflow guide.
