# C# .NET Application Workflow Guide

## Overview

Standard workflow for C# .NET applications covering deployment, testing, issue management, and Git operations.

---

## 🎯 Creating Issues

**CRITICAL - WHEN USER SAYS "CREATE TASK" OR "NEW TASK":**

When user requests task creation, **ALWAYS create GitHub Issue**.

### How to Create Issue:

```bash
gh issue create --repo Olbrasoft/VoiceAssistant \
  --title "Task title" \
  --body "Task description"
```

### User Phrases → Actions:

| User Says | Means |
|-----------|-------|
| "Create task" | → Create GitHub Issue |
| "New task" | → Create GitHub Issue |
| "Add task to project" | → Create GitHub Issue |
| "Make this an issue" | → Create GitHub Issue |

### Main Issue Format:

```markdown
## Problem
Brief problem description.

## Notes
Additional information.
```

**IMPORTANT:** 
- Don't ask "Should I create GitHub issue?" - just create it
- **NEVER use markdown checkboxes** (`- [ ]`) - use **sub-issues** instead

---

## C# Unit Testing Standards

**CRITICAL - WHEN WRITING C# TESTS:**

### Testing Framework: xUnit

```csharp
[Fact]
public void MethodName_Scenario_ExpectedResult()
{
    // Arrange
    // Act  
    // Assert
}

[Theory]
[InlineData("input1", "expected1")]
public void MethodName_MultipleInputs_ReturnsExpected(string input, string expected)
{
    // ...
}
```

### Mocking Framework: Moq

```csharp
using Moq;

var loggerMock = new Mock<ILogger<MyService>>();
var repositoryMock = new Mock<IRepository>();

repositoryMock.Setup(r => r.GetByIdAsync(It.IsAny<int>()))
    .ReturnsAsync(new Entity { Id = 1, Name = "Test" });

repositoryMock.Verify(r => r.SaveAsync(It.IsAny<Entity>()), Times.Once);
```

### Required NuGet Packages

```xml
<ItemGroup>
  <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.*" />
  <PackageReference Include="xunit" Version="2.*" />
  <PackageReference Include="xunit.runner.visualstudio" Version="2.*" />
  <PackageReference Include="Moq" Version="4.*" />
  <PackageReference Include="coverlet.collector" Version="6.*" />
</ItemGroup>
```

### Test Naming Convention

```
[MethodUnderTest]_[Scenario]_[ExpectedResult]
```

Examples:
- `SaveNoteAsync_ValidInput_CreatesFile`
- `ParseCommand_EmptyString_ReturnsNull`

**IMPORTANT:**
- ALWAYS use Moq (NOT NSubstitute, NOT FakeItEasy)
- ALWAYS use xUnit (NOT NUnit, NOT MSTest)
- Each test tests ONE thing
- Tests are isolated - no database, network, filesystem dependencies

---

## Deployment Workflow

### 0. Read Project AGENTS.md

**CRITICAL - BEFORE EVERY DEPLOYMENT:**

Always check `AGENTS.md` in project - may contain specific rules!

```bash
cat /path/to/project/AGENTS.md | head -50
```

Projects may have rules for:
- Which services (not) to restart automatically
- Specific pre/post-deployment steps
- Exceptions to general workflow

**Only then proceed with deployment.**

---

### 1. Compilation

```bash
cd /path/to/project
dotnet publish src/ProjectName/ProjectName.csproj \
  -c Release \
  -o ~/deployment-target \
  --no-self-contained
```

### 2. Testing

**CRITICAL:** Always run tests before deployment!

```bash
dotnet test
```

Requirements:
- All tests MUST pass (exit code 0)
- If ANY test fails, DO NOT deploy
- Fix tests first, then restart workflow

### 3. Deployment

Deploy ONLY if tests pass:

```bash
dotnet publish src/ProjectName/ProjectName.csproj \
  -c Release \
  -o ~/deployment-target \
  --no-self-contained
```

### 4. Service Restart

```bash
systemctl --user restart service-name.service
systemctl --user status service-name.service
```

### Complete Deployment Script

```bash
#!/bin/bash
set -e

PROJECT_PATH="/home/jirka/Olbrasoft/VoiceAssistant"
DEPLOY_TARGET="/home/jirka/voice-assistant/orchestration"
SERVICE_NAME="orchestration.service"

cd "$PROJECT_PATH"
dotnet test
dotnet publish src/Orchestration/Orchestration.csproj -c Release -o "$DEPLOY_TARGET" --no-self-contained
systemctl --user restart "$SERVICE_NAME"
systemctl --user status "$SERVICE_NAME" --no-pager
```

---

## Git Workflow for GitHub Issues

**CRITICAL - WHEN WORKING ON GITHUB ISSUES:**

Each GitHub issue is resolved in separate branch.

### Main Rules - COMMIT AND PUSH

| When | Action |
|------|--------|
| After creating branch | `git push -u origin branch-name` |
| After implementing change | `git commit` + `git push` |
| After adding tests | `git commit` + `git push` |
| After fixing bug | `git commit` + `git push` |
| After merging to main | `git push origin main` |

**NEVER delay push!** Work can be lost anytime.

---

### 1. Creating Sub-Issues for Steps

**CRITICAL - WHEN STARTING WORK ON ISSUE:**

Immediately after reading main issue, create **sub-issue** for each step:

```bash
gh issue create --repo Olbrasoft/VoiceAssistant \
  --title "Create branch for #43" \
  --body "Sub-issue for #43"

gh issue create --repo Olbrasoft/VoiceAssistant \
  --title "Implement main change for #43" \
  --body "Sub-issue for #43"

gh issue create --repo Olbrasoft/VoiceAssistant \
  --title "Write unit tests for #43" \
  --body "Sub-issue for #43"
```

**Why sub-issues instead of checkboxes:**

> **⚠️ RULE: ALWAYS SUB-ISSUES - NO EXCEPTIONS!**
>
> Even for small tasks (1-2 steps) ALWAYS create sub-issues.
> No checkboxes, no "notes in comments".

**Reasons:**
- **Checkboxes can't be "closed"** - unclear progress, can't automate
- **Comments can't be marked complete** - how to mark step done?
- **Consistent workflow** - same process always = fewer errors
- GitHub shows progress in `sub_issues_summary` ("2/5 completed")

**🚨 CRITICAL - CLOSE COMPLETED SUB-ISSUES PROGRESSIVELY:**

**IMMEDIATELY after completing each step** close the sub-issue. **DON'T WAIT until end!**

```bash
gh issue close 44 --repo Olbrasoft/VoiceAssistant
```

**NEVER close all sub-issues at once at the end!**

### 2. Creating Branch

```bash
# Bug fix (issue #3)
git checkout -b fix/issue-3-stop-detection-before-routing

# New feature (issue #2)
git checkout -b feature/issue-2-srp-refactoring

# Enhancement
git checkout -b enhancement/issue-5-config-to-appsettings
```

**Branch naming convention:**
- `fix/issue-N-short-desc` - bug fixes
- `feature/issue-N-short-desc` - new features
- `enhancement/issue-N-short-desc` - improvements
- `refactor/issue-N-short-desc` - refactoring

### 3. Implementation with Progressive Commits

**CRITICAL - COMMIT AND PUSH OFTEN:**

Work can be interrupted anytime. To avoid loss, commit and push after EVERY significant step:

```bash
# After creating branch - first push
git push -u origin fix/issue-3-stop-detection

# After implementing main change
git add .
git commit -m "Implement stop detection before routing"
git push

# After adding tests
git add .
git commit -m "Add unit tests for stop detection"
git push
```

**Workflow step-by-step:**

1. **Create branch** → `git push -u origin branch-name`
2. **Implement change** → commit + push
3. **Add tests** → commit + push
4. **Run tests** → if pass, continue; if fail, fix and commit + push
5. **Final tweaks** → commit + push
6. **Merge to main** → push main

### 4. Running Tests

```bash
cd /path/to/project
dotnet test
```

- All tests MUST pass
- If any test fails, fix it and commit + push the fix
- Only then proceed to merge

### 5. Merging to Main Branch

```bash
git checkout main
git merge fix/issue-3-stop-detection-before-routing
git push origin main
git branch -d fix/issue-3-stop-detection-before-routing  # Optional
```

### 6. Closing Issue

**🚨 CRITICAL - RULES FOR CLOSING ISSUE:**

Issue **CANNOT** be closed until ALL conditions met:

1. **All sub-issues closed** - no open sub-issue can remain
2. **All tests pass** - `dotnet test` returns exit code 0
3. **Code deployed** - new version running in production
4. **Functionality verified** - real test with user
5. **✅ USER APPROVAL** - user (programmer/architect) explicitly confirms:
   - Feature works correctly
   - Satisfied with solution
   - Issue can be closed

**NEVER close issue automatically!**

```
❌ WRONG:
- "All tests pass, closing issue" → NO! Missing real test and approval
- "Deploy done, issue complete" → NO! User hasn't verified functionality

✅ CORRECT:
- Implement → Tests → Deploy → Real test → User confirms → Then close
```

**Closing workflow:**

1. **Ask user:** "Can you test that [feature] works correctly?"
2. **Wait for response:** User tests and says if satisfied
3. **If YES:** "Thanks for confirmation, closing Issue #N"
4. **If NO:** Fix problem, redeploy, retest

---

**Other important rules:**

- Never commit directly to `main` branch
- Each issue = separate branch
- Always run tests before merge
- Use `Fix #N` or `Closes #N` in commit message for automatic issue closing
