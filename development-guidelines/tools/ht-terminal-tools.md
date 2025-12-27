# ht-mcp Terminal Guide

**Index:** [INDEX.md](INDEX.md)

---

## Why ht-mcp?

- **Bash hangs OpenCode** - causes freezes
- Live web preview capability
- Better for long-running commands
- User can see progress in real-time

## Basic Workflow

```
1. Check existing sessions:
   ht_list_sessions

2. Create new (if none exists):
   ht_create_session(enableWebServer: true)

3. Execute commands:
   ht_execute_command(sessionId, command)
```

## When to Use

### ✅ Use ht-mcp:
- `dotnet run`, `dotnet test`, `dotnet build`
- `npm test`, `npm run`
- Long-running scripts (>5 seconds)
- Commands with progress output
- User wants to see live progress
- Any command that might hang

### ❌ Use bash (exceptions only):
- Quick checks: `docker ps | grep searxng`
- Environment variables
- Simple file operations
- Very short commands (<1 second)

## Session Management

**Reuse existing sessions** - saves resources

```
# List sessions
ht_list_sessions

# Execute in existing session
ht_execute_command(sessionId, "dotnet test")

# Close when done
ht_close_session(sessionId)
```

**Web preview:** URL returned from `ht_create_session`

## Common Commands

```bash
# Build .NET project
ht_execute_command(sessionId, "dotnet build")

# Run tests
ht_execute_command(sessionId, "dotnet test")

# npm operations
ht_execute_command(sessionId, "npm test")

# Git operations
ht_execute_command(sessionId, "git status")

# Long scripts
ht_execute_command(sessionId, "./deploy.sh")
```

## Decision Tree

```
Need to run command?
│
├─ Quick check (<1 sec)?
│  └─ Use bash (exception)
│
├─ Long-running or might hang?
│  └─ Use ht-mcp
│
└─ User wants to see progress?
   └─ Use ht-mcp
```

---

**Remember:** When in doubt, use ht-mcp. Bash can hang OpenCode.
