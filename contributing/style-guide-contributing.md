# Writing Style Guide

How to write clear, actionable, and consistent documentation for the engineering handbook.

## Core Writing Principles

1. **Action-Oriented** - Focus on HOW to do things
2. **Examples First** - Show, then explain
3. **Concise** - No fluff, get to the point
4. **Scannable** - Use headings, lists, tables
5. **Consistent** - Follow patterns throughout handbook

## Tone and Voice

### Technical and Direct

✅ **GOOD:**
```markdown
## NuGet Package Publishing

Publish .NET libraries to NuGet.org using GitHub Actions.
```

❌ **TOO VERBOSE:**
```markdown
## Understanding the Complexities of NuGet Package Publishing

In this comprehensive guide, we will explore the intricate details of how one might go about publishing their .NET libraries...
```

### Imperative Mood for Instructions

✅ **GOOD:**
```markdown
1. Build the project
2. Run tests
3. Publish package
```

❌ **PASSIVE:**
```markdown
1. The project should be built
2. Tests are to be run
3. The package can be published
```

### Professional but Approachable

✅ **GOOD:**
```markdown
**🚨 CRITICAL:** Always test packages locally before publishing to NuGet.org!
```

❌ **TOO CASUAL:**
```markdown
Hey! So like, you really should probably test your packages first, ya know? 😅
```

## Content Structure

### Start with Purpose

Every file starts with one-sentence purpose:

```markdown
# Topic Name

[One clear sentence describing what this document covers.]
```

### Use Clear Headings

**Hierarchy:**
- H1 (`#`) - Document title only
- H2 (`##`) - Main sections
- H3 (`###`) - Subsections
- Rarely use H4+

**Heading style:**

✅ **GOOD:**
```markdown
## GitHub Actions Workflow
## Deployment Verification
## Troubleshooting
```

❌ **VAGUE:**
```markdown
## Setup
## More Info
## Other Stuff
```

### Lists Over Paragraphs

✅ **GOOD:**
```markdown
## Prerequisites

- ✅ Build succeeds
- ✅ Tests pass
- ✅ Secrets configured
```

❌ **WALL OF TEXT:**
```markdown
## Prerequisites

Before you proceed with deployment, you need to ensure that your build succeeds, all tests pass, and you have properly configured all necessary secrets.
```

## Code Examples

### Always Specify Language

✅ **GOOD:**
````markdown
```yaml
name: Build
on: [push]
```
````

❌ **NO LANGUAGE:**
````markdown
```
name: Build
on: [push]
```
````

### Include File Paths

✅ **GOOD:**
```markdown
**File:** `.github/workflows/build.yml`

\```yaml
name: Build
\```
```

❌ **NO CONTEXT:**
```markdown
\```yaml
name: Build
\```
```

### Commands with Comments

✅ **GOOD:**
```bash
# Build in Release mode
dotnet build -c Release

# Run tests without rebuilding
dotnet test --no-build
```

❌ **NO EXPLANATION:**
```bash
dotnet build -c Release
dotnet test --no-build
```

### Show Expected Output

✅ **GOOD:**
```bash
dotnet --version
# Output: 10.0.100
```

❌ **NO OUTPUT:**
```bash
dotnet --version
```

## Tables

### Use Tables for Comparisons

✅ **GOOD:**
```markdown
| ❌ WRONG | ✅ CORRECT |
|----------|------------|
| `ci-cd.md` | `continuous-integration.md` |
| Abbreviation | Full descriptive name |
```

### Use Tables for Reference

✅ **GOOD:**
```markdown
| Command | Description |
|---------|-------------|
| `dotnet build` | Compile project |
| `dotnet test` | Run tests |
```

### Keep Tables Aligned

Use consistent column widths:

```markdown
| Short | Description |
|-------|-------------|
| A     | Item A      |
| B     | Item B      |
```

## Formatting

### Bold for Emphasis

Use bold for:
- File paths: **File:** `.github/workflows/build.yml`
- Important terms: **CRITICAL**
- Commands: **Usage:** `dotnet build`

### Code Blocks vs Inline Code

**Inline code** for:
- Commands: `dotnet build`
- File names: `appsettings.json`
- Variables: `ASPNETCORE_ENVIRONMENT`

**Code blocks** for:
- Multiple lines
- Complete file contents
- Script examples

### Emoji Usage

Use sparingly and consistently:

- ✅ - Correct approach
- ❌ - Wrong approach
- 🚨 - Critical warning
- 📝 - Note/tip
- ⚠️ - Warning

**Don't overuse!** Only where it adds clarity.

## Links

### Use Descriptive Link Text

✅ **GOOD:**
```markdown
See [Build Guide](continuous-integration/build.md) for details.
```

❌ **VAGUE:**
```markdown
Click [here](continuous-integration/build.md) for more info.
```

### Relative Paths

Use relative paths from current file:

```markdown
[Build](../continuous-integration/build.md)
[Test](./test.md)
```

### Link to Specific Sections

When possible:

```markdown
[Prerequisites](web-deploy.md#prerequisites)
```

## Decision Trees

### Use ASCII Art

```markdown
\```
What type of project?
│
├─ Class Library
│  └─ Read: nuget-publish.md
│
└─ Web Service
   └─ Read: web-deploy.md
\```
```

### Keep Trees Simple

- Max 3 levels deep
- Clear choices at each level
- Link to specific files

## Warnings and Callouts

### Critical Warnings

```markdown
**🚨 CRITICAL:** Deployment is NOT complete until ALL features work!
```

### Important Notes

```markdown
**IMPORTANT:** Use exact version during local testing.
```

### Tips

```markdown
**TIP:** Clear cache with `dotnet nuget locals all --clear`
```

## Examples and Code

### Real Project Examples

✅ **GOOD:**
```markdown
**Examples:** VirtualAssistant, TextToSpeech, GitHub.Issues
```

❌ **GENERIC:**
```markdown
**Examples:** MyApp, SampleProject
```

### Working Code Only

- All code examples must be tested and working
- No placeholder code like `// TODO`
- Use realistic values, not `foo`, `bar`, `example.com`

### Complete vs Snippet

**Complete file:**
```markdown
**File:** `deploy.sh`

\```bash
#!/usr/bin/env bash
set -e
# ... complete working script ...
\```
```

**Snippet:**
```markdown
\```yaml
# ... snippet from larger file ...
on:
  push:
    branches: [main]
# ...
\```
```

Use `# ...` to indicate omitted code in snippets.

## Versioning and Dates

### No Version Numbers in Content

❌ **WRONG:**
```markdown
As of version 8.0, .NET supports...
```

✅ **CORRECT:**
```markdown
.NET supports...
```

**Rationale:** Versions change, content should be current.

### No Dates in Text

❌ **WRONG:**
```markdown
In 2024, the best practice is...
```

✅ **CORRECT:**
```markdown
The best practice is...
```

### Exception: Breaking Changes

When documenting breaking changes:

```markdown
**Breaking change in .NET 9:** `IConfiguration` no longer...
```

## Language and Grammar

### Use American English

- Color (not colour)
- Initialize (not initialise)
- Organize (not organise)

### Technical Terms

Use correct capitalization:
- NuGet (not Nuget or nuget)
- GitHub (not Github)
- .NET (not dotnet in prose, but `dotnet` for CLI)
- ASP.NET Core (not AspNetCore)

### Acronyms First Use

First use: Continuous Integration (CI)
Subsequent: CI

### Avoid Jargon

✅ **CLEAR:**
```markdown
Restart the systemd service
```

❌ **JARGON:**
```markdown
Bounce the daemon
```

## Error Messages and Output

### Show Full Error

```markdown
## Troubleshooting

**Error:** `NETSDK1045: The current .NET SDK does not support...`

**Cause:** PATH missing .dotnet directory

**Fix:**
\```yaml
Environment="PATH=/home/user/.dotnet:/usr/bin:/bin"
\```
```

### Include Context

- What command was run
- What the error message says
- Why it happens
- How to fix it

## Checklist Style

### Use Checkboxes

```markdown
## Pre-Deployment Checklist

- [ ] Build succeeds
- [ ] All tests pass
- [ ] Secrets configured
- [ ] Service running
```

### Use ✅ for Completed States

```markdown
## Prerequisites

- ✅ Build succeeds
- ✅ Tests pass
```

## File Organization

### Sections Order

Standard order for deployment docs:

1. Title and purpose
2. When to Use
3. Prerequisites
4. Main content (how-to)
5. Verification
6. Troubleshooting
7. See Also

### Keep Related Content Together

Group related commands/configs in same section:

```markdown
## GitHub Actions Setup

**File:** `.github/workflows/build.yml`

\```yaml
# ... workflow ...
\```

**File:** `.github/workflows/deploy.yml`

\```yaml
# ... workflow ...
\```
```

## Documentation Debt

### Mark TODOs Clearly

```markdown
**Note:** This doc is incomplete (TODO: AppImage, .deb creation).
```

### Update Status Tables

```markdown
| Document | Status |
|----------|--------|
| build.md | ✅ Complete |
| desktop-release.md | ⚠️ Incomplete - TODO: AppImage |
```

## Quick Reference

| Element | Style |
|---------|-------|
| Headings | Clear, specific (not "Setup") |
| Code | Always specify language |
| Lists | Preferred over paragraphs |
| Links | Descriptive text (not "click here") |
| Paths | Bold: **File:** `.github/...` |
| Commands | Inline code: `dotnet build` |
| Warnings | 🚨 emoji + bold |
| Examples | Real projects (not foo/bar) |
| Tone | Direct, action-oriented |

## See Also

- [File Naming](file-naming-contributing.md) - Naming conventions
- [Structure](structure-contributing.md) - Content organization
- [Contributing Index](index-contributing.md) - Overview
