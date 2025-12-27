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

### 3. Every Directory MUST Have Index File

**CRITICAL RULE:** Every directory MUST have an index file that starts with "index".

❌ **WRONG:**
```
development-guidelines/INDEX.md                     # Not lowercase
continuous-integration/continuous-integration-index.md  # Wrong order
testing/                                            # Missing index!
```

✅ **CORRECT:**
```
development-guidelines/index-development-guidelines.md
continuous-integration/index-continuous-integration.md
testing/index-testing.md
```

**Pattern:** `index-{directory-name}.md`

**Rationale:**
- "index" prefix makes it clear it's navigation file
- Directory postfix shows which directory it indexes
- Alphabetically sorts first in directory listings
- Consistent with general postfix rule
- **Every directory needs navigation** - users should know what's inside

**When creating directory:** ALWAYS create index file FIRST, then add content files.

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
├── file-naming-contributing.md
├── structure-contributing.md
└── style-guide-contributing.md
```

**Pattern:** `{topic}-{directory-name}.md`

**Rationale:**
- When searching globally, you instantly see which directory the file belongs to
- No ambiguity: `file-naming.md` vs `file-naming-contributing.md`
- Consistent with index file pattern: `index-{directory-name}.md`
- Self-descriptive even outside directory context

**Examples from handbook:**

```
development-guidelines/
├── index-development-guidelines.md                    ← Index (starts with "index")
├── workflow.md                                        ← Top-level single topic
├── continuous-integration/
│   ├── index-continuous-integration.md                ← Index (starts with "index")
│   ├── build-continuous-integration.md                ← Topic with directory postfix
│   └── test-continuous-integration.md                 ← Topic with directory postfix
└── continuous-deployment/
    ├── index-continuous-deployment.md                 ← Index (starts with "index")
    ├── nuget-publish-continuous-deployment.md         ← Topic with directory postfix
    ├── web-deploy-continuous-deployment.md            ← Topic with directory postfix
    ├── local-apps-deploy-continuous-deployment.md     ← Topic with directory postfix
    └── desktop-release-continuous-deployment.md       ← Topic with directory postfix

contributing/
├── index-contributing.md         ← Index (starts with "index")
├── file-naming-contributing.md   ← Topic with directory postfix
├── structure-contributing.md     ← Topic with directory postfix
└── style-guide-contributing.md   ← Topic with directory postfix
```

**When to use postfix:**
- ✅ **ALWAYS** for ALL files in directories: `{topic}-{directory-name}.md`
- ✅ **ALWAYS** for index files: `index-{directory-name}.md`

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
gof-patterns-design-patterns.md
```

**Rationale:**
- Year suffixes become outdated immediately (it's always "current year")
- Updates should be in-place, not versioned files
- Exception: If you need historical versions, use separate `archive/` directory

### 7. Tool-Specific Configuration Files (EXCEPTION)

**ONLY exception to postfix rule:** Tool-specific configuration files

**Pattern:** `UPPERCASE.md` (no postfix, uppercase)

**Files:**
- `CLAUDE.md` - Claude Code configuration
- `AGENTS.md` - General AI agents configuration
- `GEMINI.md` - Gemini configuration

**Example in handbook:**
```
code-review/
├── index-code-review.md              ← Index (follows postfix rule)
├── general-code-review.md            ← Topic (follows postfix rule)
├── manual-review-code-review.md      ← Topic (follows postfix rule)
└── CLAUDE.md                         ← Tool-specific (EXCEPTION - no postfix)
```

**Rationale:**
- These are standard conventions for specific tools
- UPPERCASE signals "tool configuration, not documentation"
- Tools expect exact filenames (e.g., Claude Code looks for `CLAUDE.md`)
- Currently only 1 such file in handbook: `code-review/CLAUDE.md`

**CRITICAL:** This is the ONLY exception to the postfix rule!

### 8. Czech Translations Get `-cz` Suffix

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

### Core Principle: Break Down Into Smallest Parts

**CRITICAL RULE:** Always divide topics into the smallest possible focused parts.

**Why:**
- Each file = ONE specific task
- Easier to find exactly what you need
- Easier to update specific information
- Better for learning and reference

**Pattern:**
1. Identify distinct subtasks/topics
2. Create ONE file per subtask
3. If 2+ files → create directory
4. Each file precisely solves ONE task

### Rule: 2+ Files = Directory Required

**If you have 2 or more related files → MUST create directory**

❌ **WRONG:** Files at same level
```
development-guidelines/
├── unit-tests.md
├── integration-tests.md
├── test-ci.md
```

✅ **CORRECT:** Directory with focused files
```
development-guidelines/
└── testing/
    ├── index-testing.md                 # Overview
    ├── unit-tests-testing.md            # Unit tests only
    └── integration-tests-testing.md     # Integration tests only
```

**Each file:**
- Describes ONE specific task
- 80-250 lines (focused content)
- Clear, actionable instructions

### Example: Testing Directory

**Bad approach (single large file):**
```
testing.md  (829 lines - too much!)
```

**Good approach (focused files):**
```
testing/
├── index-testing.md                 # What is testing, decision tree
├── unit-tests-testing.md            # Unit tests with Moq, in-memory DB
└── integration-tests-testing.md     # Integration tests with [SkipOnCIFact]
```

Each file solves ONE task:
- Need unit tests? → Read unit-tests-testing.md
- Need integration tests? → Read integration-tests-testing.md
- Not sure? → Start with index-testing.md

### Example: Continuous Integration

```
continuous-integration/
├── index-continuous-integration.md  # Overview of CI
├── build-continuous-integration.md  # Build process only
└── test-continuous-integration.md   # Running tests in CI only
```

NOT one huge "ci-guide.md" file!

### Single File Exception

**ONLY use single file when:**
- Topic is truly atomic (cannot be subdivided)
- Content is < 250 lines
- No related subtopics

**Example:**
```
workflow.md  # Git workflow - single focused topic
```

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

- [Structure Guide](structure-contributing.md) - How to organize content within files
- [Style Guide](style-guide-contributing.md) - Writing style and formatting
- [Contributing Index](index-contributing.md) - Overview of all contributing guides
