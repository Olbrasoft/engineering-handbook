# Web Search & Research Guide

**Index:** [INDEX.md](index-tools.md)

---

## SearXNG Setup

Check Docker: `docker ps | grep searxng`

**Tool:** `searxng_web_search(query, language?)`

**Language options:**
- `"en"` - English results
- `"cs-CZ"` - Czech results
- `"all"` - All languages (default)

## URL Reading

**Primary:** `web_url_read(url, maxLength?, section?)`
- Cached Markdown output
- Good for documentation/articles

**Fallback chain:**
1. `web_url_read` - try first
2. `webfetch` - if web_url_read fails
3. `curl` - last resort, custom headers

## Research Methodology

**ALWAYS follow this sequence:**

1. **Check Engineering Handbook first**
   - May already have solution documented

2. **Search internet (SearXNG)**
   - General queries
   - Recent solutions

3. **Search Stack Overflow**
   - Known patterns
   - Community solutions

4. **DON'T reinvent existing solutions**
   - Use existing libraries
   - Follow established patterns

5. **Verify from multiple sources**
   - Cross-reference information
   - Check official documentation

## Tool Decision Table

| Task | Tool | Fallback | When |
|------|------|----------|------|
| Search | `searxng_web_search` | - | General queries |
| Read docs | `web_url_read` | `webfetch` → `curl` | Articles, docs |
| API calls | `curl` | - | Custom headers |
| Downloads | `curl`/`wget` | - | Files |

## Examples

```python
# Search for .NET solution
searxng_web_search("dotnet dependency injection best practices", language="en")

# Read documentation
web_url_read("https://docs.microsoft.com/...", maxLength=5000)

# Search Czech content
searxng_web_search("ASP.NET Core návod", language="cs-CZ")
```

---

**Remember:** Research first, implement second.
