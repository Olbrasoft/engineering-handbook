# HandbookSearch

Semantic search engine for engineering-handbook using AI embeddings and PostgreSQL pgvector.

## Overview

HandbookSearch enables intelligent search across engineering documentation using vector embeddings. Unlike traditional keyword search, it understands semantic meaning and context.

## Key Features

- **Semantic Search**: Find relevant documents even without exact keyword matches
- **Multilingual Support**: Search in both English and Czech
- **Vector Embeddings**: Uses Ollama with qwen3-embedding model (1024 dimensions)
- **PostgreSQL pgvector**: Fast approximate nearest neighbor search with HNSW indexes
- **Automatic Import**: GitHub Actions workflow auto-imports changes
- **Web UI**: Simple browser-based search interface

## Architecture

### Components

| Component | Technology | Purpose |
|-----------|-----------|---------|
| CLI | .NET 10 | Import and manage documents |
| API | ASP.NET Core | REST endpoints for search |
| Database | PostgreSQL + pgvector | Vector storage and search |
| Embeddings | Ollama (qwen3) | Generate semantic vectors |
| Translation | Azure Translator | Czech translations |
| Web UI | HTML + JavaScript | User interface |

### Data Flow

```
Markdown file → CLI import → Embedding generation → PostgreSQL → API → Web UI
```

## Usage

### Search via Web UI

```bash
cd ~/Olbrasoft/HandbookSearch/src/HandbookSearch.Web
python3 -m http.server 3000
# Open http://localhost:3000
```

### Search via API

```bash
curl "http://localhost:5170/api/search?q=SOLID%20principles&limit=5"
```

### Import Documents

```bash
/opt/olbrasoft/handbook-search/cli/HandbookSearch.Cli import-files \
  --files "/path/to/file.md" \
  --handbook-path "/repo/root" \
  --translate-cs
```

## Configuration

### Application Settings

Located in `/opt/olbrasoft/handbook-search/cli/appsettings.json`:

- **Database**: PostgreSQL connection string (without password)
- **Ollama**: Model and dimensions
- **Azure Translator**: Region only (key in SecureStore)

### Secrets (SecureStore)

All secrets are stored in encrypted SecureStore vault:

```
~/.config/handbook-search/
├── secrets/secrets.json    # Encrypted vault
└── keys/secrets.key        # Encryption key (chmod 600!)
```

**Required secrets:**
- `Database:Password` - PostgreSQL password
- `AzureTranslator:SubscriptionKey` - Azure API key
- `GitHub:Token` - GitHub personal access token

See [Secrets Management](../../development-guidelines/secrets-management.md#securestore---standard-for-olbrasoft-projects) for setup instructions.

## GitHub Actions Integration

Changes to markdown files automatically trigger import:

1. Push to main branch
2. GitHub Actions detects changed files
3. Workflow imports with both EN + CS embeddings
4. Documents appear in search results

## Performance

- Single file import: ~4-5 seconds
- Embedding generation (EN): ~1.2s
- Translation to Czech: ~0.2s
- Embedding generation (CS): ~1.2s
- Search query: <100ms for top 10 results

## Dependencies

- .NET 10 SDK
- PostgreSQL 16+ with pgvector extension
- Ollama with qwen3-embedding:0.6b model
- Azure Translator API (for Czech embeddings)

## Development

```bash
cd ~/Olbrasoft/HandbookSearch
dotnet build
dotnet test
./deploy/deploy.sh
```

## Related Documentation

- [Git Workflow](../../development-guidelines/workflow/git-workflow-workflow.md)
- [Testing Guidelines](../../development-guidelines/dotnet/testing/index-testing.md)
- [CI/CD Setup](../../development-guidelines/dotnet/continuous-integration/index-continuous-integration.md)
