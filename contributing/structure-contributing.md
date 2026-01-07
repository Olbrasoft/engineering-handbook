# Content Structure Guide

How to organize and structure content within handbook files.

## Core Principles

1. **Short and Focused** - Each file should cover ONE specific topic
2. **Actionable** - Focus on HOW to do things, not just theory
3. **Examples First** - Show code/commands, then explain
4. **Decision Trees** - Help users choose the right approach quickly

## File Length Guidelines

**Target length:** 80-250 lines per file
**Maximum file size:** 30 KB (30,000 bytes)

**Why:**
- Easier to read and scan
- Faster to load (token efficiency for AI)
- Forces focus on single topic
- Easier to maintain and update
- **CRITICAL**: Translation APIs have character limits (Azure Translator: ~33,300 chars/minute)

**If file exceeds ~300 lines OR 30 KB:**
- **MUST** split into multiple focused files
- Create a directory with subtopic files
- Keep index file short (~80-100 lines)
- Ensure each file stays under 30 KB

**Example:**

❌ **TOO LONG:** `ci-cd-nuget.md` (617 lines)
- Mixed build, test, publish, local testing

✅ **SPLIT INTO:**
- `continuous-integration/build.md` (82 lines)
- `continuous-integration/test.md` (95 lines)
- `continuous-deployment/nuget-publish.md` (149 lines)
- `local-package-testing.md` (213 lines)

## Standard File Structure

### 1. Title and Purpose

Start with H1 title and one-sentence purpose:

```markdown
# NuGet Package Publishing

How to publish .NET libraries to NuGet.org using GitHub Actions.
```

### 2. "When to Use" Section (for deployment/workflow docs)

Help users quickly determine if this doc is relevant:

```markdown
## When to Use

- **Project type:** Class library
- **Target:** NuGet.org (public package registry)
- **Examples:** TextToSpeech, Mediation
- **NOT for:** Web apps, desktop apps
```

### 3. Prerequisites Section

List what must be done BEFORE this doc:

```markdown
## Prerequisites

- ✅ Build succeeds (see `build.md`)
- ✅ Tests pass (see `test.md`)
- ✅ NuGet API key configured
```

### 4. Main Content with Examples

Use this pattern:

```markdown
## GitHub Actions Workflow

**File:** `.github/workflows/publish-nuget.yml`

```yaml
name: Publish NuGet
# ... actual code example ...
```

**What this does:**
1. Triggers on push to main or tag v*
2. Packs all projects in Release mode
3. Publishes to NuGet.org
```

**Pattern:**
1. Show file path or command
2. Provide code example
3. Explain what it does

### 5. Decision Trees for Index Files

Use ASCII tree for navigation:

```markdown
## Decision Tree

\```
What type of project?
│
├─ Class Library
│  └─ Publish to NuGet.org → nuget-publish.md
│
├─ Web Service (ASP.NET Core)
│  └─ Deploy to server → web-deploy.md
│
└─ Desktop Application (GUI)
   └─ Release to GitHub → desktop-release.md
\```
```

### 6. Tables for Comparisons

Use tables for side-by-side comparisons:

```markdown
| ❌ WRONG | ✅ CORRECT |
|----------|------------|
| `ci-cd-overview.md` | `continuous-integration-index.md` |
| Abbreviations unclear | Full words self-descriptive |
```

### 7. Critical Warnings

Use emoji and formatting for critical info:

```markdown
**🚨 CRITICAL:** Deployment is NOT complete until ALL features work!

| ❌ WRONG | ✅ CORRECT |
|----------|------------|
| "App returns HTTP 200 so it's deployed" | "ALL features tested and working" |
```

### 8. Troubleshooting Section

Table format for quick reference:

```markdown
## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| Package not found | Cache not cleared | `dotnet nuget locals all --clear` |
| Wrong version used | Not using exact version | Use `Version="1.0.5"` in .csproj |
```

### 9. See Also Links

End with related documents:

```markdown
## See Also

- Build (`continuous-integration/build.md`) - Build before deploying
- Test (`continuous-integration/test.md`) - Test before deploying
- Workflow (`workflow.md`) - Git workflow
```

## Content Organization Patterns

### Pattern 1: Sequential Steps

For procedures with specific order:

```markdown
## Workflow Steps

### 1. Build Package Locally

\```bash
dotnet pack -c Release -o ./artifacts
\```

### 2. Add Local NuGet Source

\```bash
dotnet nuget add source ./artifacts --name "LocalTest"
\```

### 3. Test in Consuming Project

\```bash
dotnet restore
dotnet test
\```
```

### Pattern 2: Parallel Options

For choosing between alternatives:

```markdown
## Deployment Options

### Option 1: Automatic (Recommended)

**Trigger:** Push to main branch

\```yaml
on:
  push:
    branches: [main]
\```

### Option 2: Manual

**Trigger:** Tag with `v*`

\```yaml
on:
  push:
    tags:
      - 'v*'
\```
```

### Pattern 3: Reference Sections

For quick command reference:

```markdown
## Commands Reference

| Task | Command |
|------|---------|
| Build | `dotnet build -c Release` |
| Test | `dotnet test --no-build` |
| Pack | `dotnet pack -o ./artifacts` |
```

## Splitting Large Files

### When to Split

Split when file has:
- Multiple distinct subtopics (>3)
- Each subtopic has substantial content (>100 lines)
- Different audiences or use cases
- Content length exceeds ~300 lines

### How to Split

**Example: `ci-cd-nuget.md` (617 lines)**

**Analyze content:**
1. Build process (CI)
2. Testing (CI)
3. Publishing to NuGet.org (CD)
4. Local package testing (Development workflow)

**Create new structure:**
```
continuous-integration/
├── build.md              # Build process only
└── test.md               # Testing only

continuous-deployment/
└── nuget-publish.md      # Publishing to NuGet.org

local-package-testing.md  # Development workflow
```

**Create index files:**
```
continuous-integration/continuous-integration-index.md
continuous-deployment/continuous-deployment-index.md
```

## Index File Structure

Index files should be SHORT (~80-100 lines) and provide:

1. **One-sentence description**
2. **Decision tree** (what to read when)
3. **Quick navigation table**
4. **Pipeline/workflow diagram** (optional)
5. **Links to all files in directory**

**Example:**

```markdown
# Continuous Integration

Automated build and testing for .NET projects.

## What is Continuous Integration?

**CI** = Automatically **build** and **test** code every time you push.

**Goal:** Verify code **works** and is **quality**.

## Quick Navigation

| Task | File |
|------|------|
| Build .NET project | `build.md` |
| Run automated tests | `test.md` |

## CI Pipeline Steps

\```
Push to GitHub
    ↓
Restore (dotnet restore)
    ↓
Build (dotnet build)
    ↓
Test (dotnet test)
    ↓
✅ Success → Ready for deployment
\```
```

## Best Practices

### ✅ DO:

1. **Start with examples** - Show working code first, explain after
2. **Use code blocks** - Always specify language (```yaml, ```bash, ```csharp)
3. **Include file paths** - `.github/workflows/build.yml` helps users locate files
4. **Use tables** - Better than prose for comparisons and reference
5. **Add warnings** - Use 🚨 emoji for critical information
6. **Link between docs** - Help users navigate related content
7. **Keep files focused** - One topic per file
8. **Use decision trees** - Help users choose quickly

### ❌ DON'T:

1. **Don't mix topics** - Build and deploy are separate files
2. **Don't write walls of text** - Use lists, code blocks, tables
3. **Don't assume knowledge** - Link to prerequisites
4. **Don't skip examples** - Theory without practice is useless
5. **Don't create deep nesting** - Max 2 directory levels
6. **Don't duplicate content** - Link instead of copy/paste
7. **Don't use vague headings** - "Setup" vs "GitHub Actions Workflow Setup"
8. **Don't skip troubleshooting** - Always include common issues

## Content Length Examples

From actual handbook restructure:

| File | Lines | Status |
|------|-------|--------|
| continuous-integration-index.md | 67 | ✅ Perfect - concise overview |
| build.md | 82 | ✅ Perfect - focused on build |
| test.md | 95 | ✅ Perfect - focused on testing |
| nuget-publish.md | 149 | ✅ Good - single deployment type |
| web-deploy.md | 195 | ✅ Good - comprehensive but focused |
| local-package-testing.md | 213 | ✅ Good - complete workflow |
| **OLD: ci-cd-nuget.md** | **617** | ❌ **TOO LONG - mixed topics** |

## Template for New Documents

```markdown
# [Topic Name]

[One-sentence description of what this doc covers]

## When to Use

- **Project type:** [Type]
- **Target:** [What you're deploying/building to]
- **Examples:** [Real project examples]
- **NOT for:** [What this doesn't cover]

## Prerequisites

- ✅ [Requirement 1 with link]
- ✅ [Requirement 2 with link]

## [Main Section - How To]

**File:** `path/to/file`

\```language
# Code example
\```

**What this does:**
1. Step one
2. Step two

## [Additional Sections as needed]

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Issue | Solution |

## See Also

- Related Doc (`link.md`) - Description
```

## See Also

- [File Naming](file-naming-contributing.md) - How to name files and directories
- [Style Guide](style-guide-contributing.md) - Writing style and formatting
- [Contributing Index](index-contributing.md) - Overview
