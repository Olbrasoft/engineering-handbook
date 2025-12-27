# Contributing to Engineering Handbook

How to write, structure, and maintain the engineering handbook.

## Purpose

This directory contains **meta-documentation** - guides for creating the handbook itself.

**Read this when:**
- Adding new documentation to handbook
- Restructuring existing content
- Ensuring consistency across handbook
- Learning handbook standards

## Quick Navigation

| Topic | File | What You'll Learn |
|-------|------|-------------------|
| **File Naming** | [file-naming-contributing-engineering-handbook.md](file-naming-contributing-engineering-handbook.md) | How to name files and directories |
| **Content Structure** | [structure-contributing-engineering-handbook.md](structure-contributing-engineering-handbook.md) | How to organize content within files |
| **Writing Style** | [style-guide-contributing-engineering-handbook.md](style-guide-contributing-engineering-handbook.md) | Writing style, formatting, examples |

## Decision Tree

```
What do I need to know?
│
├─ "How should I name this file/directory?"
│  └─ Read: file-naming-contributing-engineering-handbook.md
│
├─ "How should I structure the content?"
│  └─ Read: structure-contributing-engineering-handbook.md
│
├─ "What writing style should I use?"
│  └─ Read: style-guide-contributing-engineering-handbook.md
│
└─ "General overview of handbook standards"
   └─ Read this file (index)
```

## Core Principles

### 1. Self-Descriptive Names

Files and directories must clearly communicate their content through their names alone.

**Example:**
- ✅ `continuous-integration-index.md`
- ❌ `ci-index.md`

**Why:** No mental translation needed, instantly clear.

### 2. Short and Focused Files

Each file should cover ONE specific topic in 80-250 lines.

**Example:**
- ✅ `build.md` (82 lines) - Only build process
- ❌ `ci-cd-nuget.md` (617 lines) - Mixed build, test, publish

**Why:** Easier to read, faster to load, simpler to maintain.

### 3. Examples First

Show working code first, explain after.

**Pattern:**
```markdown
## GitHub Actions Workflow

**File:** `.github/workflows/build.yml`

\```yaml
name: Build
on: [push]
\```

**What this does:**
1. Triggers on every push
2. Runs build process
```

**Why:** Developers want working code, not theory.

### 4. Actionable Content

Focus on HOW to do things, not just what they are.

**Good headings:**
- "How to Publish NuGet Packages"
- "Deployment Steps"
- "Verification Checklist"

**Bad headings:**
- "Overview"
- "Introduction"
- "Background"

### 5. Consistent Structure

Follow standard patterns across all docs.

**Standard sections:**
1. Title and purpose
2. When to Use
3. Prerequisites
4. Main content (how-to)
5. Verification/Testing
6. Troubleshooting
7. See Also

## File Naming Convention

All files in `contributing/` directory follow this pattern:

```
{topic}-contributing-engineering-handbook.md
```

**Examples:**
- `file-naming-contributing-engineering-handbook.md`
- `structure-contributing-engineering-handbook.md`
- `style-guide-contributing-engineering-handbook.md`
- `index-contributing-engineering-handbook.md` (this file)

**Why this pattern:**
- Postfix matches directory name
- Consistent with handbook pattern: `{directory}-index.md`
- Clear what the file belongs to when searching

## Directory Structure Pattern

Handbook uses this structure:

```
engineering-handbook/
├── README.md                           # Root index
├── development-guidelines/
│   ├── development-guidelines-index.md # Directory index
│   ├── workflow.md                     # Single topic files
│   ├── testing.md
│   ├── continuous-integration/
│   │   ├── continuous-integration-index.md
│   │   ├── build.md
│   │   └── test.md
│   └── continuous-deployment/
│       ├── continuous-deployment-index.md
│       └── nuget-publish.md
├── contributing/
│   ├── index-contributing-engineering-handbook.md
│   ├── file-naming-contributing-engineering-handbook.md
│   ├── structure-contributing-engineering-handbook.md
│   └── style-guide-contributing-engineering-handbook.md
└── solid-principles/
    └── solid-principles.md
```

**Pattern rules:**
1. **Index files** include directory name: `{directory}-index.md`
2. **Single topic files** use simple names: `workflow.md`, `testing.md`
3. **Subtopic files** in directories use descriptive names: `nuget-publish.md`
4. **Contributing files** use postfix: `{topic}-contributing-engineering-handbook.md`

## When to Create New Files

### Create Single File When:

- Topic is self-contained (< 250 lines)
- No distinct subtopics
- All content relates to one task

**Example:** `workflow.md` - Git workflow guide

### Create Directory When:

- Topic has multiple distinct subtopics (3+)
- Each subtopic deserves focused file (>100 lines)
- Different audiences or use cases

**Example:** `continuous-deployment/` - 4 deployment types, each 150+ lines

## Common Mistakes to Avoid

### ❌ Using Abbreviations

**Wrong:** `ci-cd-overview.md`
**Right:** `continuous-integration-index.md`

**Why:** Abbreviations require mental translation.

### ❌ Creating Long Mixed Files

**Wrong:** `ci-cd-nuget.md` (617 lines covering build, test, publish, local testing)
**Right:** Split into 4 focused files (build.md, test.md, nuget-publish.md, local-package-testing.md)

**Why:** Long files are hard to scan and maintain.

### ❌ Vague Filenames

**Wrong:** `setup.md`, `overview.md`, `guide.md`
**Right:** `repository-setup.md`, `continuous-integration-index.md`, `workflow.md`

**Why:** Vague names don't communicate purpose.

### ❌ Deep Directory Nesting

**Wrong:**
```
development-guidelines/
  deployment/
    continuous-deployment/
      types/
        nuget/
          publish.md
```

**Right:**
```
development-guidelines/
  continuous-deployment/
    nuget-publish.md
```

**Why:** Flat structure is easier to navigate.

## Workflow for Adding New Content

### 1. Determine Scope

- Is this a new topic or extending existing?
- Is it self-contained or part of larger topic?
- How many lines of content?

### 2. Choose Structure

- **< 250 lines, single topic** → Single file
- **Multiple subtopics, 3+ files** → Create directory

### 3. Follow Naming Pattern

- Full words, no abbreviations
- Action verbs for procedures (publish, deploy, build)
- Include directory name in index files

### 4. Use Standard Template

See [structure-contributing-engineering-handbook.md](structure-contributing-engineering-handbook.md) for templates.

### 5. Write Following Style Guide

See [style-guide-contributing-engineering-handbook.md](style-guide-contributing-engineering-handbook.md) for writing guidelines.

### 6. Update Navigation

- Add to parent index file
- Update README.md if top-level
- Add to decision trees

### 7. Verify Consistency

- Check file naming matches pattern
- Ensure links work
- Verify structure follows standards

## Handbook Maintenance

### Regular Tasks

- **Update outdated content** - Remove version numbers, keep current
- **Split large files** - If file exceeds ~300 lines, consider splitting
- **Consolidate duplicates** - Link instead of copying content
- **Fix broken links** - After restructuring
- **Update examples** - Use real project examples

### Quality Checks

Before committing new content:

- [ ] File name follows naming conventions
- [ ] Content is focused (single topic)
- [ ] Examples are working code (tested)
- [ ] Links are relative and working
- [ ] Style follows guide
- [ ] Structure follows template
- [ ] Navigation updated

## Files in This Directory

| File | Lines | Description |
|------|-------|-------------|
| index-contributing-engineering-handbook.md | ~250 | This file - overview |
| file-naming-contributing-engineering-handbook.md | ~250 | Naming conventions |
| structure-contributing-engineering-handbook.md | ~350 | Content organization |
| style-guide-contributing-engineering-handbook.md | ~350 | Writing style |

## See Also

### Handbook Content

- [Development Guidelines Index](../development-guidelines/development-guidelines-index.md) - Main development docs
- [README](../README.md) - Root handbook index

### Contributing Files

- [File Naming](file-naming-contributing-engineering-handbook.md) - How to name files
- [Structure](structure-contributing-engineering-handbook.md) - How to organize content
- [Style Guide](style-guide-contributing-engineering-handbook.md) - How to write

## Questions?

If you're unsure about:
- **Naming** → Read file-naming guide
- **Structure** → Read structure guide
- **Writing** → Read style guide
- **Everything** → Start with this index

**Remember:** Self-descriptive names, focused files, examples first, actionable content!
