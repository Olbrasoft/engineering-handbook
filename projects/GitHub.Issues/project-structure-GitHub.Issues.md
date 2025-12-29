## Project Structure

```
GitHub.Issues/
├── src/
│   ├── Olbrasoft.GitHub.Issues.Data/                     # Domain Layer
│   │   ├── Entities/                    # Domain entities
│   │   │   ├── Issue.cs                 # Issue with embedding
│   │   │   ├── Label.cs                 # Repository label
│   │   │   ├── Repository.cs            # GitHub repository
│   │   │   ├── EventType.cs             # Event type enum
│   │   │   └── IssueEvent.cs            # Issue event
│   │   ├── Commands/                    # CQRS Commands
│   │   │   ├── IssueCommands/           # IssueSave, IssueUpdateEmbedding, etc.
│   │   │   ├── LabelCommands/           # LabelSave
│   │   │   ├── RepositoryCommands/      # RepositorySave, UpdateLastSynced
│   │   │   └── EventCommands/           # IssueEventsSaveBatch
│   │   └── Queries/                     # CQRS Queries
│   │       ├── IssueQueries/            # IssueByRepoAndNumber, IssuesByRepository
│   │       ├── LabelQueries/            # LabelByRepoAndName, LabelsByRepository
│   │       ├── RepositoryQueries/       # RepositoryByFullName
│   │       └── EventQueries/            # EventTypesAll, IssueEventIdsByRepository
│   │
│   ├── Olbrasoft.GitHub.Issues.Data.EntityFrameworkCore/ # Infrastructure
│   │   ├── GitHubDbContext.cs           # EF Core DbContext (ONLY here!)
│   │   ├── QueryHandlers/               # Query implementations
│   │   ├── CommandHandlers/             # Command implementations
│   │   └── Services/
│   │       ├── OllamaEmbeddingService.cs   # Embedding generation
│   │       └── SystemdServiceManager.cs    # Service management
│   │
│   ├── Olbrasoft.GitHub.Issues.Migrations.PostgreSQL/    # PostgreSQL Migrations
│   ├── Olbrasoft.GitHub.Issues.Migrations.SqlServer/     # SQL Server Migrations
│   │
│   ├── Olbrasoft.GitHub.Issues.Business/                 # Business Layer
│   │   ├── Services/
│   │   │   ├── IssueSearchService.cs       # Semantic search
│   │   │   ├── IssueDetailService.cs       # Issue detail with AI summary
│   │   │   ├── IssueSyncBusinessService.cs # Issue sync operations
│   │   │   ├── TranslatorPoolBuilder.cs    # Translation provider pool
│   │   │   ├── RoundRobinTranslator.cs     # Provider rotation with fallback
│   │   │   └── AiSummarizationService.cs   # AI summaries (OpenRouter/Ollama)
│   │   └── Models/OpenAi/                  # DTO models (SRP extraction)
│   │
│   ├── Olbrasoft.GitHub.Issues.Sync/                     # CLI Sync Tool
│   │   ├── Program.cs                      # Entry point
│   │   ├── ApiClients/                     # GitHub API HTTP clients
│   │   └── Services/                       # Sync orchestrators
│   │
│   └── Olbrasoft.GitHub.Issues.AspNetCore.RazorPages/    # Web UI
│       ├── Pages/                          # Razor Pages
│       ├── Extensions/                     # DI extension methods (SRP)
│       ├── Endpoints/                      # Minimal API endpoints (SRP)
│       └── Program.cs                      # Entry point (51 lines)
│
├── test/                                    # 393+ Unit Tests
│   ├── Olbrasoft.GitHub.Issues.Data.Tests/
│   ├── Olbrasoft.GitHub.Issues.Data.EntityFrameworkCore.Tests/
│   ├── Olbrasoft.GitHub.Issues.Business.Tests/
│   └── Olbrasoft.GitHub.Issues.AspNetCore.RazorPages.Tests/
│
├── deploy/
│   └── deploy.sh                           # Production deployment script
│
├── .github/
│   └── workflows/
│       └── deploy-local.yml                # Self-hosted CI/CD pipeline
│
└── GitHub.Issues.sln
```

### Project Dependencies

```
                    ┌───────────────────┐
                    │      Data         │  ← No dependencies (core)
                    │   (Entities,      │
                    │  Commands/Queries)│
                    └─────────┬─────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
┌─────────────────┐  ┌────────────────┐  ┌─────────────────┐
│ Data.EFCore     │  │   Business     │  │   Sync CLI      │
│ (DbContext,     │  │  (Services,    │  │   (Worker)      │
│  Handlers)      │  │   IMediator)   │  │                 │
└────────┬────────┘  └───────┬────────┘  └─────────────────┘
         │                   │
         └───────────────────┤
                             ▼
              ┌──────────────────────────┐
              │    RazorPages (Web UI)   │
              │    (Presentation)        │
              └──────────────────────────┘
```

---

