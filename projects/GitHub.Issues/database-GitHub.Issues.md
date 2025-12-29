## Database

### Schema

| Entity | Description | Key Columns |
|--------|-------------|-------------|
| `Repository` | GitHub repository | `Id`, `FullName`, `Owner`, `Name`, `Url`, `LastSyncedAt` |
| `Issue` | Issue with embedding | `Id`, `RepositoryId`, `Number`, `Title`, `State`, `Embedding` (varbinary/vector), `Url` |
| `Label` | Repository labels | `Id`, `RepositoryId`, `Name`, `Color` |
| `IssueLabel` | Many-to-many: Issue ↔ Label | `IssueId`, `LabelId` |
| `EventType` | Event types | `Id`, `Name` (opened, closed, labeled, etc.) |
| `IssueEvent` | Issue events | `Id`, `IssueId`, `EventTypeId`, `Actor`, `CreatedAt` |
| `CachedText` | Cached translations | `Id`, `EntityType`, `EntityId`, `Language`, `TextType` (Title/Summary), `Text` |

**Vector Dimensions**:
- **1024** (Cohere `embed-multilingual-v3.0`)
- **768** (Ollama `nomic-embed-text`)

### Multi-Provider Support

| Provider | Use Case | Vector Storage | Migration Project |
|----------|----------|----------------|-------------------|
| SQL Server | Production (Docker) | `varbinary(max)` | `Migrations.SqlServer` |
| PostgreSQL | Optional | `vector(768)` (pgvector) | `Migrations.PostgreSQL` |

### Migrations

#### Adding a New Migration

```bash
# SQL Server
dotnet ef migrations add MigrationName \
  --startup-project ./src/Olbrasoft.GitHub.Issues.AspNetCore.RazorPages \
  --project ./src/Olbrasoft.GitHub.Issues.Migrations.SqlServer \
  -- --provider SqlServer

# PostgreSQL
dotnet ef migrations add MigrationName \
  --startup-project ./src/Olbrasoft.GitHub.Issues.AspNetCore.RazorPages \
  --project ./src/Olbrasoft.GitHub.Issues.Migrations.PostgreSQL \
  -- --provider PostgreSQL
```

#### Applying Migrations

**Production**: Migrations are applied **automatically on startup** by `GitHubDbContext`.

**Manual** (development):
```bash
dotnet ef database update \
  --startup-project ./src/Olbrasoft.GitHub.Issues.AspNetCore.RazorPages \
  --project ./src/Olbrasoft.GitHub.Issues.Migrations.SqlServer \
  -- --provider SqlServer
```

---

