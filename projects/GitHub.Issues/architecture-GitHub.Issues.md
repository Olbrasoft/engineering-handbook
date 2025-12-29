## Architecture

The project follows **Clean Architecture** principles with **CQRS (Command Query Responsibility Segregation)** pattern:

```
┌─────────────────────────────────────────────────────────────────────┐
│  PRESENTATION LAYER                                                 │
│  ┌─────────────────────┐  ┌─────────────────────┐                  │
│  │ AspNetCore.RazorPages│  │ Sync (CLI Worker)   │                  │
│  │ (Web UI + Search)   │  │ (GitHub → Database) │                  │
│  └──────────┬──────────┘  └──────────┬──────────┘                  │
│             └──────────────┬─────────┘                             │
│                            ▼                                        │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  BUSINESS LAYER (Olbrasoft.GitHub.Issues.Business)          │   │
│  │  ┌─────────────────┐  ┌─────────────────────────────────┐   │   │
│  │  │ IssueSearchSvc  │  │ IssueSyncBusinessService        │   │   │
│  │  │ (IMediator)     │  │ LabelSyncBusinessService        │   │   │
│  │  │                 │  │ RepositorySyncBusinessService   │   │   │
│  │  │                 │  │ EventSyncBusinessService        │   │   │
│  │  └────────┬────────┘  └────────────────┬────────────────┘   │   │
│  │           └──────────────┬─────────────┘                    │   │
│  └──────────────────────────┼──────────────────────────────────┘   │
│                             ▼                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  DATA LAYER (Olbrasoft.GitHub.Issues.Data)                  │   │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────────────────┐ │   │
│  │  │ Entities   │  │ Commands   │  │ Queries                │ │   │
│  │  │ Issue      │  │ IssueSave  │  │ IssueByRepoAndNumber   │ │   │
│  │  │ Label      │  │ LabelSave  │  │ IssuesByRepository     │ │   │
│  │  │ Repository │  │ ...        │  │ ...                    │ │   │
│  │  └────────────┘  └────────────┘  └────────────────────────┘ │   │
│  │  NO database access - just definitions (abstractions)       │   │
│  └─────────────────────────┬───────────────────────────────────┘   │
│                            ▼                                        │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  INFRASTRUCTURE (Data.EntityFrameworkCore)                  │   │
│  │  ┌─────────────────┐  ┌─────────────────────────────────┐   │   │
│  │  │ GitHubDbContext │  │ QueryHandlers                   │   │   │
│  │  │ (ONLY here!)    │  │ CommandHandlers                 │   │   │
│  │  │                 │  │ (Implement CQRS)                │   │   │
│  │  └─────────────────┘  └─────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

### Key Architectural Principles

1. **Separation of Concerns**: Each layer has a distinct responsibility
2. **Dependency Rule**: Dependencies point inward (Presentation → Business → Data → Infrastructure)
3. **DbContext Isolation**: `GitHubDbContext` exists ONLY in `Data.EntityFrameworkCore` project
4. **CQRS Pattern**: Commands (write operations) separated from Queries (read operations)
5. **Mediator Pattern**: `IMediator` routes commands/queries to their handlers

### Data Flow

```
User Request → Business Service → Command/Query → Handler → DbContext → SQL Server
                     ↓
              Uses IMediator.Send()
                     ↓
            Auto-routes to Handler
```

---

