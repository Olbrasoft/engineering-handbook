# Code Review - OpenCode/Manual Guide

**You are:** OpenCode, Gemini, or human doing manual code review  
**Tool:** Manual checklist, no automation

---

## What You Need

### 📋 Manual Code Review Checklist
**Read:** [manual-guide.md](manual-guide.md)

**Contents:**
- SOLID principles checklist
- Code smells and solutions
- Naming conventions (Microsoft style)
- Async/await patterns
- Security checklist
- Test coverage guidelines
- Refactoring examples
- Modern C# features (12+)

**Use when:**
- Reviewing code without `/code-review` command
- Teaching code quality principles
- Planning refactoring work
- Analyzing existing codebase

### ✅ Output: Create GitHub Issues
**After review, create issues for:**
- Critical problems (red flags)
- Code smells
- Refactoring opportunities

**Issue template in:** [manual-guide.md](manual-guide.md) lines 203-223

---

## Files in This Directory

| File | Purpose | For |
|------|---------|-----|
| `AGENTS.md` | This index | OpenCode, Gemini |
| `manual-guide.md` | Manual review checklist | All agents |
| `claude-review.md` | `/code-review` automation | Claude Code only |
| `CLAUDE.md` | Claude Code index | Claude Code only |
| `GEMINI.md` | Gemini index | Gemini only |

---

**Next step:** Read [manual-guide.md](manual-guide.md) for detailed checklist.
