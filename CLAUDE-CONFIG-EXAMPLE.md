# Global .claude.json Configuration Example

**Purpose:** Example configuration for AI agents to automatically check Engineering Handbook before starting tasks.

**Location:** This is an EXAMPLE. Actual configuration should be in `~/.claude.json` or project-specific `.claude.json`.

---

## Recommended Global Configuration

```json
{
  "instructions": "Before starting any software development task:\n\n1. Check if Engineering Handbook has guidance: ~/GitHub/Olbrasoft/engineering-handbook/AGENTS.md\n2. Navigate to specific area based on task type\n3. Load only the relevant document (don't load entire handbook)\n4. Follow documented standards and workflows\n\nHandbook areas:\n- Repository setup, CI/CD, Git workflow → development-guidelines/AGENTS.md\n- SOLID principles → solid-principles/AGENTS.md\n- Design patterns → design-patterns/AGENTS.md",
  
  "workspaceRules": {
    "engineering-handbook": {
      "path": "~/GitHub/Olbrasoft/engineering-handbook",
      "entryPoint": "AGENTS.md",
      "priority": "high"
    }
  }
}
```

---

## How It Works

### Agent Workflow

```
1. User: "Create new NuGet package repository"
   ↓
2. Agent reads global .claude.json
   ↓
3. Agent: "Check ~/GitHub/Olbrasoft/engineering-handbook/AGENTS.md"
   ↓
4. Root AGENTS.md: "Repository work → development-guidelines/AGENTS.md"
   ↓
5. Development AGENTS.md: "NuGet packages → ci-cd-nuget-packages.md"
   ↓
6. Agent loads ci-cd-nuget-packages.md (~150 lines)
   ↓
7. Agent executes task following handbook guidance
```

**Result:** Agent follows standards automatically, uses minimal tokens.

---

## Project-Specific Configuration

For Olbrasoft projects, add to project `.claude.json`:

```json
{
  "instructions": "This is an Olbrasoft project. Follow Engineering Handbook standards.",
  
  "projectType": "nuget-package",  // or "web-service", "desktop-app"
  
  "handbook": {
    "location": "~/GitHub/Olbrasoft/engineering-handbook",
    "checkBefore": ["repository-setup", "ci-cd", "deployment", "refactoring"],
    "entryPoint": "AGENTS.md"
  },
  
  "standards": {
    "testFramework": "xUnit",
    "mockingLibrary": "Moq",
    "dotnetVersion": "net10.0",
    "commitMessages": "conventional-commits",
    "subIssues": "native-github"  // NOT checkboxes
  }
}
```

---

## Example Scenarios

### Scenario 1: New Repository

**User:** "Create SystemTray repository for NuGet packages"

**Agent workflow:**
1. Reads global .claude.json → "Check handbook"
2. Reads `AGENTS.md` (root) → "Repository → development-guidelines"
3. Reads `development-guidelines/AGENTS.md` → "Setup repo + NuGet CI/CD"
4. Loads:
   - `github-repository-setup.md`
   - `ci-cd-nuget-packages.md`
5. Creates repository following standards
6. Sets up workflows
7. Configures NuGet API key from `~/Dokumenty/Keys/nuget-key.txt`

**Tokens used:** ~500 lines (vs 3000+ without handbook structure)

### Scenario 2: Refactoring

**User:** "Refactor this code, it's doing too much"

**Agent workflow:**
1. Reads global .claude.json → "Check handbook"
2. Reads `AGENTS.md` (root) → "Refactoring → SOLID principles"
3. Reads `solid-principles/AGENTS.md` → "SRP violation → solid-principles.md"
4. Loads relevant section: Single Responsibility Principle
5. Applies SRP guidance
6. Optionally checks `design-patterns/AGENTS.md` for applicable patterns

**Tokens used:** ~300 lines (specific SRP section)

### Scenario 3: Deploy Web Service

**User:** "Deploy VirtualAssistant to production"

**Agent workflow:**
1. Reads global .claude.json → "Check handbook"
2. Reads `AGENTS.md` (root) → "Deployment → development-guidelines"
3. Reads `development-guidelines/AGENTS.md` → "Web services → ci-cd-web-services.md"
4. Loads `ci-cd-web-services.md`
5. Follows deployment checklist:
   - ✅ Tests pass
   - ✅ Deploy to `/opt/olbrasoft/virtual-assistant/`
   - ✅ Secrets in systemd EnvironmentFile
   - ✅ Restart service
   - ✅ Verify ALL features work

**Tokens used:** ~400 lines

---

## Benefits

### 1. **Automatic Standard Compliance**
- Agent checks handbook without being told
- Follows Olbrasoft conventions
- Consistent across all projects

### 2. **Token Efficiency**
- Hierarchical navigation
- Load only what's needed
- 85% token savings vs loading entire handbook

### 3. **Self-Service**
- Agent finds answers independently
- Less back-and-forth with user
- Faster task completion

### 4. **Always Up-to-Date**
- Handbook updated → agents use new standards immediately
- Single source of truth
- No stale documentation in agent memory

---

## Testing the Configuration

### Test 1: Check Handbook Access
```bash
# Agent should be able to read root index
cat ~/GitHub/Olbrasoft/engineering-handbook/AGENTS.md
```

### Test 2: Navigation Works
```bash
# Agent should navigate: root → area → document
cat ~/GitHub/Olbrasoft/engineering-handbook/development-guidelines/AGENTS.md
cat ~/GitHub/Olbrasoft/engineering-handbook/development-guidelines/ci-cd-nuget-packages.md
```

### Test 3: Find Specific Topic
```bash
# Agent should find pattern/principle
grep -A 20 "Observer Pattern" ~/GitHub/Olbrasoft/engineering-handbook/design-patterns/gof-patterns-design-patterns.md
grep -A 20 "Single Responsibility" ~/GitHub/Olbrasoft/engineering-handbook/solid-principles/solid-principles.md
```

---

## Updating Configuration

### When to Update Global .claude.json

1. **New handbook area added** → Add to `workspaceRules`
2. **Standards change** → Update instructions
3. **New project type** → Add to handbook, then config

### Where Configuration Lives

| Scope | File | Purpose |
|-------|------|---------|
| **Global** | `~/.claude.json` | All Olbrasoft work |
| **Project** | `<project>/.claude.json` | Project-specific overrides |
| **Handbook** | `engineering-handbook/AGENTS.md` | Documentation index |

---

## Anti-Patterns

❌ **DON'T:** Put entire handbook in .claude.json instructions  
✅ **DO:** Reference handbook location, let agent navigate

❌ **DON'T:** Load all documents at once  
✅ **DO:** Hierarchical navigation (root → area → document)

❌ **DON'T:** Duplicate handbook content in config  
✅ **DO:** Keep config minimal, handbook has details

---

## Reference

- Root index: `~/GitHub/Olbrasoft/engineering-handbook/AGENTS.md`
- Development: `~/GitHub/Olbrasoft/engineering-handbook/development-guidelines/AGENTS.md`
- SOLID: `~/GitHub/Olbrasoft/engineering-handbook/solid-principles/AGENTS.md`
- Patterns: `~/GitHub/Olbrasoft/engineering-handbook/design-patterns/AGENTS.md`

---

**Note:** This is an EXAMPLE configuration. Adapt to your specific needs and tools.
