# Code Review - Claude Code Guide

**You are:** Claude Code  
**Command available:** `/code-review` or `/code-review --comment`

---

## What Do You Need?

### ✅ I need to review code NOW
**Action:** Run `/code-review` in your terminal (must be on PR branch)

**How it works:**
- 4 parallel agents analyze your changes
- 2x Sonnet: CLAUDE.md compliance
- 2x Opus: Bug detection
- Confidence threshold: 80
- Output: Terminal or GitHub PR

### 📝 I need to create CLAUDE.md for a project
**Read:** [claude-review.md](claude-review.md) lines 30-175 (template)

**Quick steps:**
1. Copy template from `claude-review.md`
2. Customize for your project (.NET standards, architecture, testing)
3. Save as `CLAUDE.md` in project root
4. Reference engineering handbook documents

### 🧠 I need to understand how `/code-review` works
**Read:** [claude-review.md](claude-review.md) (full document, 439 lines)

**Key sections:**
- Lines 30-175: .NET CLAUDE.md template
- Lines 213-233: Agent behavior explained  
- Lines 270-285: Engineering handbook integration
- Lines 376-420: Configuration and troubleshooting

### 🔧 I need to do manual review (no automation)
**Wrong tool!** You want OpenCode's manual guide.  
**Read:** [manual-guide.md](manual-guide.md) instead.

---

## Files in This Directory

| File | Purpose | For |
|------|---------|-----|
| `CLAUDE.md` | This index | Claude Code navigation |
| `claude-review.md` | `/code-review` automation guide | Claude Code |
| `manual-guide.md` | Manual review checklist | OpenCode, Gemini, humans |
| `AGENTS.md` | OpenCode index | OpenCode |
| `GEMINI.md` | Gemini index | Gemini |

---

## Quick Commands

```bash
# Local review (terminal output)
/code-review

# Post to GitHub PR
/code-review --comment

# Review specific PR
gh pr checkout 123
/code-review --comment
```

---

**Next step:** Choose what you need above and read the corresponding file.
