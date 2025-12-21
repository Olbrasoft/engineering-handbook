# Engineering Handbook - Root Index

**Purpose:** Top-level index for AI agents. Start here to find what you need.

---

## What is This Handbook?

Comprehensive guide for .NET development at Olbrasoft covering:
- Repository setup
- CI/CD strategies
- Code standards
- SOLID principles
- Design patterns

---

## Quick Navigation

**ALWAYS start here. Then navigate to specific area.**

### I'm starting a task...

```
What am I doing?
│
├─ Repository/CI/CD work (setup, deployment, workflows)
│  └─ Read: development-guidelines/AGENTS.md
│     ├─ GitHub operations → github-operations/AGENTS.md
│     ├─ Internet research → research-guide/AGENTS.md
│     └─ Terminal (OpenCode) → ht-mcp-terminal/AGENTS.md
│
├─ Learning/applying SOLID principles
│  └─ Read: solid-principles/AGENTS.md
│
└─ Implementing design patterns
   └─ Read: design-patterns/AGENTS.md
```

---

## Directory Index

### 1. `development-guidelines/`
**Topics:** Repository setup, CI/CD, Git workflow, project structure, feature development

**Read when:**
- Creating GitHub repository
- Setting up CI/CD (NuGet/Web/Desktop)
- Structuring .NET project
- **Implementing complex features (7-phase workflow)**
- Git workflow (branches, commits, issues)

**Index:** [development-guidelines/AGENTS.md](development-guidelines/AGENTS.md)

**Key documents:**
- `feature-development/AGENTS.md` - 7-phase feature workflow
- `github-operations/AGENTS.md` - GitHub CLI, issues, sub-issues, API
- `research-guide/AGENTS.md` - Internet search, SearXNG, research workflow
- `ht-mcp-terminal/AGENTS.md` - Terminal for OpenCode (bash disabled)
- `github-repository-setup.md` - Repo configuration
- `ci-cd-overview.md` - Which CI/CD type?
- `ci-cd-nuget-packages.md` - NuGet publishing
- `dotnet-project-structure.md` - Folder/naming conventions
- `workflow/workflow.md` - Git workflow, issues, branches

---

### 2. `solid-principles/`
**Topics:** Single Responsibility, Open/Closed, Liskov, Interface Segregation, Dependency Inversion

**Read when:**
- Designing new classes/interfaces
- Refactoring for testability
- Code review feedback about design
- Learning modern SOLID interpretation

**Index:** [solid-principles/AGENTS.md](solid-principles/AGENTS.md)

**Key documents:**
- `solid-principles-2025.md` - Modern SOLID (2025 update)
- `solid-principles-2025-cz.md` - Czech version (detailed)

---

### 3. `design-patterns/`
**Topics:** Gang of Four patterns, modern usage, .NET implementations

**Read when:**
- Implementing specific pattern
- Refactoring to patterns
- Learning pattern catalog

**Index:** [design-patterns/AGENTS.md](design-patterns/AGENTS.md)

**Key documents:**
- `gof-design-patterns-2025.md` - GoF patterns (2025 update)
- `gof-design-patterns-2025-cz.md` - Czech version (detailed)

---

## Common Scenarios

### "Create new NuGet package repository"
1. Read: **development-guidelines/AGENTS.md**
2. Navigate to: Repository setup + CI/CD NuGet docs
3. Apply: SOLID principles while coding
4. Apply: Design patterns where appropriate

### "Deploy web service to production"
1. Read: **development-guidelines/AGENTS.md**
2. Navigate to: `ci-cd-web-services.md`
3. Follow: Deployment checklist

### "Refactor code for better design"
1. Read: **solid-principles/AGENTS.md**
2. Read: **design-patterns/AGENTS.md**
3. Apply principles and patterns

---

## Token Optimization Strategy

### For AI Agents

**DON'T:** Load entire handbook (thousands of lines)

**DO:**
```
Step 1: Read THIS file (AGENTS.md in root) - ~100 lines
Step 2: Read area-specific AGENTS.md - ~200 lines
Step 3: Read ONE specific document - ~150 lines

Total: ~450 lines instead of 3000+
Savings: 85% tokens
```

### File Naming Convention

| Pattern | Audience | Characteristics |
|---------|----------|----------------|
| `*.md` | AI agents | English, terse, token-efficient |
| `*-cz.md` | Human developers | Czech, detailed, well-formatted |

**AI agents:** Use English `.md` files.

---

## Document Status Overview

| Area | Status | Documents | Notes |
|------|--------|-----------|-------|
| Development Guidelines | ✅ Complete | 15+ docs | CI/CD by type, workflows |
| SOLID Principles | ✅ Complete | 4 docs | 2025 modern interpretation |
| Design Patterns | ✅ Complete | 4 docs | 2025 GoF patterns |

---

## How to Add New Content

1. **Create document** in appropriate directory
2. **Update area AGENTS.md** (e.g., `development-guidelines/AGENTS.md`)
3. **Update this file** (root AGENTS.md) if new category
4. **Create both versions:** English (`.md`) + Czech (`-cz.md`)

---

## Global Configuration Reference

**For global .claude.json or workspace settings:**

```json
{
  "instructions": "Before starting any task, check Engineering Handbook at ~/GitHub/Olbrasoft/engineering-handbook/AGENTS.md to see if there's guidance. Navigate to specific area based on task type."
}
```

**Workflow:**
```
1. Task assigned
2. Check: ~/GitHub/Olbrasoft/engineering-handbook/AGENTS.md
3. Navigate to area-specific AGENTS.md
4. Load only relevant document
5. Execute task
```

---

## Critical Locations

| Resource | Path |
|----------|------|
| **This index** | `~/GitHub/Olbrasoft/engineering-handbook/AGENTS.md` |
| **Development** | `~/GitHub/Olbrasoft/engineering-handbook/development-guidelines/AGENTS.md` |
| **SOLID** | `~/GitHub/Olbrasoft/engineering-handbook/solid-principles/AGENTS.md` |
| **Patterns** | `~/GitHub/Olbrasoft/engineering-handbook/design-patterns/AGENTS.md` |
| **Secrets** | `~/Dokumenty/přístupy/api-keys.md` (NOT in handbook!) |

---

## Quick Commands

```bash
# Navigate to handbook
cd ~/GitHub/Olbrasoft/engineering-handbook

# Read root index (START HERE)
cat AGENTS.md

# List all areas
ls -d */

# Find specific topic
grep -r "topic" . --include="*.md"

# Check document size (token count)
wc -l **/*.md
```

---

## Remember

1. **Start here** (root AGENTS.md) - orient yourself
2. **Navigate** to area-specific AGENTS.md
3. **Load** only the document you need
4. **Stay efficient** - don't load entire handbook

**Goal:** Maximum guidance, minimum tokens.

---

**Last updated:** 2025-01-21
**Status:** Active, maintained
**License:** MIT
