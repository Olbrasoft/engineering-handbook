# GitHub.Issues - Engineering Documentation

Semantic search for GitHub issues using vector embeddings with AI-powered summarization and translation.

**Production:** https://plumbaginous-zoe-unexcusedly.ngrok-free.dev
**Repository:** https://github.com/Olbrasoft/GitHub.Issues

## Overview

GitHub.Issues is an ASP.NET Core Razor Pages application that enables **semantic search** across GitHub issues using vector embeddings. Unlike traditional keyword search, semantic search understands the **meaning** of queries, finding relevant issues even when they don't contain exact keywords.

### Key Features

- **Semantic Search**: Find issues by meaning, not just keywords
- **Dual Embedding Providers**: Cohere (cloud, 1024d) or Ollama (local, 768d)
- **AI Summarization**: Automatic issue summaries using Cerebras/Groq with provider rotation
- **Multi-Language Translation**: Czech translations via DeepL/Azure/Google/Bing with fallback
- **Clean Architecture**: CQRS pattern with MediatR
- **PostgreSQL with pgvector**: Efficient vector similarity search

## Quick Navigation

| Topic | File | Description |
|-------|------|-------------|
| Architecture | [architecture-GitHub.Issues.md](architecture-GitHub.Issues.md) | Clean Architecture, CQRS, component diagram |
| Technology Stack | [technology-stack-GitHub.Issues.md](technology-stack-GitHub.Issues.md) | .NET 10, PostgreSQL, external services |
| Project Structure | [project-structure-GitHub.Issues.md](project-structure-GitHub.Issues.md) | Directory layout, layers, files |
| Configuration | [configuration-GitHub.Issues.md](configuration-GitHub.Issues.md) | appsettings.json, secrets management |
| Translation System | [translation/index-translation.md](translation/index-translation.md) | Multi-provider translation with fallback |
| Deployment | [deployment-GitHub.Issues.md](deployment-GitHub.Issues.md) | Production deployment guide |
| Database | [database-GitHub.Issues.md](database-GitHub.Issues.md) | Schema, migrations, vector search |
| Sync CLI | [sync-cli-GitHub.Issues.md](sync-cli-GitHub.Issues.md) | GitHub synchronization tool |
| Testing | [testing-GitHub.Issues.md](testing-GitHub.Issues.md) | Test projects, coverage, running tests |
| Known Issues | [known-issues-GitHub.Issues.md](known-issues-GitHub.Issues.md) | Current issues and workarounds |
| Quick Reference | [quick-reference-GitHub.Issues.md](quick-reference-GitHub.Issues.md) | Common commands and tasks |

## Decision Tree

```
What do you need?
│
├─ Understand the architecture?
│  └─ Read architecture-GitHub.Issues.md
│
├─ Deploy to production?
│  └─ Read deployment-GitHub.Issues.md
│
├─ Configure translation?
│  └─ Read translation/index-translation.md
│
├─ Work with database?
│  └─ Read database-GitHub.Issues.md
│
└─ Run tests?
   └─ Read testing-GitHub.Issues.md
```

## Quick Start

```bash
# Build
cd ~/Olbrasoft/GitHub.Issues
dotnet build

# Test
dotnet test --verbosity minimal

# Deploy
sudo ./deploy/deploy.sh /opt/olbrasoft/github-issues
```

## Additional Resources

- **Repository**: https://github.com/Olbrasoft/GitHub.Issues
- **Production**: https://plumbaginous-zoe-unexcusedly.ngrok-free.dev
- **CLAUDE.md**: `/home/jirka/Olbrasoft/GitHub.Issues/CLAUDE.md` (project-specific instructions)
- **API Keys**: `~/Dokumenty/přístupy/api-keys.md` (NOT in Git!)

---

**Last Updated**: 2025-12-29
**Maintainer**: Olbrasoft
