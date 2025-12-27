# File Naming Conventions

How to name files and directories in the engineering handbook.

## Core Principle: Self-Descriptive Names

**Goal:** File names should clearly communicate their content WITHOUT needing to read them.

**Why:**
- Users/AI can find information quickly
- No need for separate navigation files (AGENTS.md, GEMINI.md)
- Reduces cognitive load

## File Naming Rules

### 1. Use Full Words, NOT Abbreviations

❌ **WRONG:**
```
ci-cd-overview.md
ci-cd-nuget.md
```

✅ **CORRECT:**
```
continuous-integration-index.md
continuous-deployment-index.md
nuget-publish.md
```

**Rationale:** Abbreviations require mental translation. "ci-cd" forces you to think "what does this mean?" Full words are instantly clear.

### 2. Use Descriptive Action Words

❌ **WRONG:**
```
nuget.md              # Too vague - what about NuGet?
web.md                # What web?
desktop.md            # Desktop what?
```

✅ **CORRECT:**
```
nuget-publish.md      # Publishing NuGet packages
web-deploy.md         # Deploying web services
desktop-release.md    # Creating desktop releases
```

**Rationale:** Action words (publish, deploy, release) clarify the PURPOSE of the document.

### 3. Index Files Should Include Parent Directory Name

❌ **WRONG:**
```
development-guidelines/INDEX.md
continuous-integration/index.md
```

✅ **CORRECT:**
```
development-guidelines/development-guidelines-index.md
continuous-integration/continuous-integration-index.md
```

**Rationale:** When searching or listing files, you can see what the index is for without checking its path.

### 4. Files in Directory MUST Have Directory Name as Postfix

**CRITICAL RULE:** When files are in a named directory, they MUST include the directory name as postfix.

❌ **WRONG:**
```
contributing/
├── file-naming.md
├── structure.md
└── style-guide.md
```

✅ **CORRECT:**
```
contributing/
├── file-naming-contributing-engineering-handbook.md
├── structure-contributing-engineering-handbook.md
└── style-guide-contributing-engineering-handbook.md
```

**Pattern:** `{topic}-{directory-name}.md`

**Rationale:**
- When searching globally, you instantly see which directory the file belongs to
- No ambiguity: `file-naming.md` vs `file-naming-contributing-engineering-handbook.md`
- Consistent with index file pattern: `{directory}-index.md`
- Self-descriptive even outside directory context

**Examples from handbook:**

```
development-guidelines/
├── development-guidelines-index.md                    ← Index
├── workflow.md                                        ← Top-level single topic
├── continuous-integration/
│   ├── continuous-integration-index.md                ← Index with directory postfix
│   ├── build-continuous-integration.md                ← Topic with directory postfix
│   └── test-continuous-integration.md                 ← Topic with directory postfix
└── continuous-deployment/
    ├── continuous-deployment-index.md                 ← Index with directory postfix
    ├── nuget-publish-continuous-deployment.md         ← Topic with directory postfix
    ├── web-deploy-continuous-deployment.md            ← Topic with directory postfix
    ├── local-apps-deploy-continuous-deployment.md     ← Topic with directory postfix
    └── desktop-release-continuous-deployment.md       ← Topic with directory postfix

contributing/
├── contributing-engineering-handbook-index.md         ← Index
├── file-naming-contributing-engineering-handbook.md   ← Topic with directory postfix
├── structure-contributing-engineering-handbook.md     ← Topic with directory postfix
└── style-guide-contributing-engineering-handbook.md   ← Topic with directory postfix
```

**When to use postfix:**
- ✅ **ALWAYS** for ALL files in directories: `{topic}-{directory-name}.md`
- ✅ **ALWAYS** for index files: `{directory}-index.md`

**No exceptions!** Every file in a directory must have the directory name as postfix for consistency and searchability.

**Why ALWAYS:**
- Instant context when searching globally
- No ambiguity: `build-continuous-integration.md` vs `build-something-else.md`
- Consistent pattern across entire handbook
- Self-descriptive even outside directory context

### 5. Prefer Single Files with Descriptive Names

**Default approach:** One file with clear name

✅ **GOOD:**
```
workflow.md
testing.md
secrets-management.md
```

**Exception:** Only create directory when needed (see "When to Create Directories" below)

### 6. No Language or Year Suffixes in Primary Files

❌ **WRONG:**
```
workflow-guide-2025.md
solid-principles-2025.md
gof-design-patterns-2025.md
```

✅ **CORRECT:**
```
workflow.md
solid-principles.md
gof-design-patterns.md
```

**Rationale:**
- Year suffixes become outdated immediately (it's always "current year")
- Updates should be in-place, not versioned files
- Exception: If you need historical versions, use separate `archive/` directory

### 7. Czech Translations Get `-cz` Suffix

**Pattern:**
```
filename.md       # English version (default for AI)
filename-cz.md    # Czech version (for humans)
```

**Example:**
```
workflow.md
workflow-cz.md
```

## When to Create Directories

### Default: Single File

Most topics should be a single file:
```
workflow.md
testing.md
repository-setup.md
```

### Exception: Tool-Specific Capabilities

Create directory when a specific tool has unique capabilities others don't:

**Example:** `code-review/`
```
code-review/
├── code-review.md           # General guidelines (all tools)
├── CLAUDE.md                # Claude Code: /code-review command
└── manual-review.md         # Manual review checklist
```

**Rationale:** Claude Code can run parallel background agents for code review - other tools can't.

### Exception: Multiple Related Subtopics

Create directory when topic has distinct subtopics:

**Example:** `continuous-deployment/`
```
continuous-deployment/
├── continuous-deployment-index.md
├── nuget-publish.md
├── web-deploy.md
├── local-apps-deploy.md
└── desktop-release.md
```

**Rationale:** Each deployment type is a complete topic deserving its own focused file.

## Directory Naming Rules

### 1. Use Full Words

❌ **WRONG:**
```
ci-cd/
dev-guidelines/
```

✅ **CORRECT:**
```
continuous-integration/
continuous-deployment/
development-guidelines/
```

### 2. Use Plural for Collections, Singular for Topics

**Collections (plural):**
```
solid-principles/
design-patterns/
```

**Single topics (singular):**
```
continuous-integration/
continuous-deployment/
```

### 3. Directory Names Match File Prefixes

✅ **GOOD PATTERN:**
```
continuous-integration/
├── continuous-integration-index.md
├── build.md
└── test.md
```

## Examples from This Handbook

### ✅ Good Structure

**Before restructure:**
```
development-guidelines/
├── ci-cd-overview.md
├── ci-cd-nuget.md
├── ci-cd-web.md
├── ci-cd-desktop.md
└── ci-cd-local-apps.md
```

**After restructure:**
```
development-guidelines/
├── continuous-integration/
│   ├── continuous-integration-index.md
│   ├── build.md
│   └── test.md
├── continuous-deployment/
│   ├── continuous-deployment-index.md
│   ├── nuget-publish.md
│   ├── web-deploy.md
│   ├── local-apps-deploy.md
│   └── desktop-release.md
└── local-package-testing.md
```

**Improvements:**
- Separated CI from CD conceptually
- Full words instead of abbreviations
- Action verbs (publish, deploy, release)
- Self-descriptive index names
- Local package testing as standalone topic

## Quick Reference

| Principle | Example |
|-----------|---------|
| Full words, no abbreviations | `continuous-integration` NOT `ci` |
| Action verbs | `nuget-publish.md` NOT `nuget.md` |
| Self-descriptive index | `continuous-integration-index.md` NOT `index.md` |
| Single file default | `workflow.md` NOT `workflow/overview.md` |
| Czech suffix | `workflow-cz.md` |
| Directory = multiple subtopics | `continuous-deployment/` with 4+ files |

## Testing Your Names

Ask yourself:

1. **Can I understand what this file contains from its name alone?**
   - ✅ `nuget-publish.md` - Yes, it's about publishing NuGet packages
   - ❌ `nuget.md` - No, could be about anything NuGet-related

2. **Do I need to mentally translate abbreviations?**
   - ✅ `continuous-integration` - No translation needed
   - ❌ `ci-cd` - Have to think "oh, that's continuous integration/deployment"

3. **Is the purpose clear from action words?**
   - ✅ `web-deploy.md` - Deploying web services
   - ❌ `web.md` - Web what?

If you answer "no" to any question, improve the name.

## See Also

- [Structure Guide](structure-contributing-engineering-handbook.md) - How to organize content within files
- [Style Guide](style-guide-contributing-engineering-handbook.md) - Writing style and formatting
- [Contributing Index](contributing-engineering-handbook-index.md) - Overview of all contributing guides
