## Technology Stack

### Core Technologies

| Component | Technology | Version |
|-----------|-----------|---------|
| Runtime | .NET | 10.0 |
| Web Framework | ASP.NET Core Razor Pages | 10.0 |
| Database | Microsoft SQL Server | 2025 (Docker) |
| ORM | Entity Framework Core | 10.0 |
| Mediator | MediatR | Latest |
| Testing | xUnit + Moq | Latest |

### External Services

| Service | Purpose | Location | Model/Version |
|---------|---------|----------|---------------|
| Ollama | Embeddings (local) | localhost:11434 | nomic-embed-text (768d) |
| Cohere | Embeddings (cloud) | api.cohere.com | embed-multilingual-v3.0 (1024d) |
| Cerebras | Summarization | api.cerebras.ai | llama-4-scout-17b-16e-instruct |
| Groq | Summarization fallback | api.groq.com | llama-3.3-70b-versatile |
| DeepL | Translation (primary) | api-free.deepl.com | Free API (500k chars/month) |
| Azure Translator | Translation (fallback) | api.cognitive.microsofttranslator.com | Free F0 (2M chars/month) |
| Google Translate | Translation (fallback) | Unofficial API | Unlimited (soft limits) |
| Bing Translator | Translation (last resort) | Unofficial API | Rate-limited |

### Development Tools

- **Docker**: SQL Server 2025 container (`mssql`)
- **ngrok**: Public tunnel to localhost:5156
- **GitHub Actions**: Self-hosted runner for CI/CD
- **SearXNG**: Web search (localhost:8888)

---

