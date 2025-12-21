# Code Review - Claude Code

**You are:** Claude Code  
**Task:** Automated code review with `/code-review` command

---

## Read This First

**Main guide:** [code-review.md](code-review.md)

This file contains:
- How `/code-review` command works (4 parallel agents)
- CLAUDE.md template for .NET projects (lines 30-175)
- Usage: `/code-review` (local) or `/code-review --comment` (PR)
- Agent behavior and confidence scoring
- Configuration and troubleshooting

---

## Quick Start

### Running Code Review
```bash
/code-review              # Local review
/code-review --comment    # Post to GitHub PR
```

### Creating Project CLAUDE.md
1. Read `code-review.md` lines 30-175
2. Copy template
3. Customize for your project
4. Save as `CLAUDE.md` in project root

---

**Next:** Read [code-review.md](code-review.md) for full documentation.
