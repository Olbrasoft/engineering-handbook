## Sync CLI

### Usage

```bash
cd src/Olbrasoft.GitHub.Issues.Sync
dotnet run -- [command] [options]
```

### Commands

| Command | Description |
|---------|-------------|
| `sync` | Full sync of all configured repositories |
| `sync --smart` | Smart sync using stored `last_synced_at` timestamps |
| `sync --repo Owner/Repo` | Sync specific repository |
| `sync --since TIMESTAMP` | Incremental sync (changes since timestamp) |

### Examples

```bash
# Smart incremental sync (recommended)
dotnet run -- sync --smart

# Sync specific repository
dotnet run -- sync --repo Olbrasoft/VirtualAssistant

# Incremental sync since specific date
dotnet run -- sync --since 2025-12-01T00:00:00Z
```

### Configuration

User secrets for GitHub API token:

```bash
cd src/Olbrasoft.GitHub.Issues.Sync
dotnet user-secrets init
dotnet user-secrets set "GitHub:Token" "ghp_your_token_here"
```

---

