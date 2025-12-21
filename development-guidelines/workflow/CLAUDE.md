# Git Workflow - Claude Code Guide

**You are:** Claude Code  
**Topic:** Git branches, commits, GitHub issues, PRs

---

## What You Need

### 🌿 Git Workflow Guide
**Read:** [git-workflow.md](git-workflow.md)

**Contents:**
- GitHub issues workflow
- Branch naming (`feature/issue-N-desc`, `fix/issue-N-desc`)
- Commit message format
- Sub-issues (NOT checkboxes!)
- Pull request workflow
- Testing requirements
- Deployment checklist

**Key practices for Claude Code:**
- Each issue = separate branch
- Commit + push after every step
- Close issue ONLY after: tests pass + deployed + user approval
- Use native GitHub sub-issues (via GitHub MCP)

---

## Quick Reference

**Branch naming:**
```bash
feature/issue-123-add-tts-provider
fix/issue-456-null-reference-bug
```

**Commit after each step:**
```bash
git add .
git commit -m "Add: Azure TTS provider interface"
git push
```

**Create PR:**
```bash
gh pr create --title "Add Azure TTS" --body "Closes #123"
```

---

**Next step:** Read [git-workflow.md](git-workflow.md) for complete workflow.
