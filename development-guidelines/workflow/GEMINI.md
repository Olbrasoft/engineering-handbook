# Git Workflow - Gemini CLI

**You are:** Gemini (Interactive CLI Agent)  
**Topic:** Git workflow execution without slash commands

---

## 🛠 Your Workflow Implementation

Since you do not have access to Claude's slash commands, you must perform the workflows manually using standard tools.

### 1. Committing Changes
Instead of `/commit`:
1. **Stage:** `git add .` (or specific files)
2. **Review:** `git diff --staged`
3. **Commit:** `git commit -m "[Type]: Description"`
   - *Note:* Do not add Claude attribution unless specifically requested.

### 2. Pushing & PRs
Instead of `/commit-push-pr`:
1. **Push:** `git push origin branch-name`
2. **PR:** `gh pr create --title "Title" --body "Summary..."`
   - *Note:* Use GitHub CLI (`gh`) just like the plugin does.

### 3. Branch Cleanup
Instead of `/clean_gone`:
1. **Fetch:** `git fetch --prune`
2. **Identify:** `git branch -vv | grep ': gone]'`
3. **Delete:** `git branch -d <branch_name>`

---

## 📖 Reference

Always adhere to the core principles in [workflow.md](workflow.md).