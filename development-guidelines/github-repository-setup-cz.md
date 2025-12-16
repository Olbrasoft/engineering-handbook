# Průvodce nastavením GitHub repozitáře

Kompletní průvodce pro nastavení GitHub repozitářů se správnou konfigurací, zabezpečením a automatizací.

## Rychlý checklist

- [ ] Vytvořit repozitář s README
- [ ] Přidat `.gitignore` (použít šablonu)
- [ ] Přidat LICENSE soubor
- [ ] Nastavit ochranu větví
- [ ] Nastavit webhooky (volitelné)
- [ ] Přidat AGENTS.md pro AI agenty
- [ ] Nastavit secrets

## Vytvoření nového repozitáře

### Přes GitHub Web UI

1. Jdi na https://github.com/new
2. Vyplň:
   - **Repository name:** Malá písmena, pomlčky (např. `muj-projekt`)
   - **Description:** Jednořádkový popis
   - **Visibility:** Public nebo Private
   - **Initialize:** Zaškrtni "Add a README file"
   - **Add .gitignore:** Vyber šablonu (např. "VisualStudio" pro .NET)
   - **Choose a license:** MIT pro open source

### Přes GitHub CLI

```bash
gh repo create muj-projekt --public --clone --gitignore VisualStudio --license MIT
```

## Základní soubory

### .gitignore

Použij GitHub šablony. Pro .NET projekty:

```bash
# Stáhni .NET gitignore
curl -o .gitignore https://raw.githubusercontent.com/github/gitignore/main/VisualStudio.gitignore
```

**Vždy přidej:**
```gitignore
# User secrets
appsettings.*.local.json
*.local.json

# IDE
.idea/
*.user
*.suo

# Build artifacts
/publish/
/artifacts/
```

### README.md

Minimální struktura:

```markdown
# Název projektu

Krátký popis toho, co projekt dělá.

## Začínáme

### Požadavky
- .NET 10 SDK
- PostgreSQL (volitelné)

### Instalace
\`\`\`bash
git clone https://github.com/Olbrasoft/nazev-projektu.git
cd nazev-projektu
dotnet build
\`\`\`

### Spuštění testů
\`\`\`bash
dotnet test
\`\`\`

## Licence

MIT License - viz soubor [LICENSE](LICENSE).
```

### AGENTS.md

Instrukce pro AI agenty (Claude Code, GitHub Copilot, atd.):

```markdown
# AGENTS.md

Instrukce pro AI agenty pracující s tímto repozitářem.

## Přehled projektu
[Krátký popis účelu a architektury projektu]

## Build příkazy
\`\`\`bash
dotnet build
dotnet test
dotnet publish -c Release -o ./publish
\`\`\`

## Styl kódu
- Dodržuj Microsoft C# naming conventions
- Používej xUnit + Moq pro testování
- Cílová platforma .NET 10

## Důležité cesty
- Zdrojový kód: `src/`
- Testy: `tests/`
- Konfigurace: `appsettings.json`

## Secrets
Nikdy necommituj secrets. Používej:
- `dotnet user-secrets` pro lokální vývoj
- GitHub Secrets pro CI/CD
- Environment variables pro produkci
```

## Ochrana větví (Branch Protection)

### Nastavení přes Web UI

1. Jdi do **Settings** → **Branches** → **Add branch protection rule**
2. Branch name pattern: `main`
3. Doporučené nastavení:

| Nastavení | Hodnota | Proč |
|-----------|---------|------|
| Require pull request | Ano | Code review |
| Required approvals | 1+ | Pro týmy |
| Require status checks | Ano | CI musí projít |
| Require up-to-date | Ano | Žádné merge konflikty |
| Include administrators | Volitelné | Vynutit pro všechny |

### Nastavení přes GitHub CLI

```bash
gh api repos/Olbrasoft/muj-projekt/branches/main/protection \
  --method PUT \
  -f required_status_checks='{"strict":true,"contexts":["build"]}' \
  -f enforce_admins=false \
  -f required_pull_request_reviews='{"required_approving_review_count":1}'
```

## Konfigurace webhooků

Webhooky notifikují externí služby o událostech v repozitáři (issues, PR, push).

### Nastavení webhooku

1. Jdi do **Settings** → **Webhooks** → **Add webhook**
2. Nastav:

| Pole | Popis |
|------|-------|
| Payload URL | Tvůj endpoint (např. `https://example.com/api/webhooks/github`) |
| Content type | `application/json` |
| Secret | HMAC klíč pro ověření podpisu |
| Events | Vyber potřebné události |

### Doporučené události

| Událost | Použití |
|---------|---------|
| `push` | CI/CD triggery |
| `pull_request` | PR automatizace |
| `issues` | Synchronizace issue trackeru |
| `issue_comment` | Notifikace komentářů |
| `release` | Release automatizace |

### Zabezpečení webhooků

**Vždy používej secret** pro ověření webhooků:

```csharp
// Ověření podpisu webhooku v ASP.NET Core
var signature = Request.Headers["X-Hub-Signature-256"].FirstOrDefault();
var payload = await new StreamReader(Request.Body).ReadToEndAsync();
var hash = ComputeHmacSha256(payload, webhookSecret);
var expected = $"sha256={hash}";

if (!CryptographicOperations.FixedTimeEquals(
    Encoding.UTF8.GetBytes(signature ?? ""),
    Encoding.UTF8.GetBytes(expected)))
{
    return Unauthorized();
}
```

### Umístění credentials

Webhook secrets a všechny API klíče jsou uloženy lokálně v:

```
~/Dokumenty/přístupy/api-keys.md
```

**Nikdy necommituj secrets do Gitu.**

## Správa secrets

### Kde jsou secrets uloženy

| Typ | Umístění | Přístup |
|-----|----------|---------|
| API klíče | `~/Dokumenty/přístupy/api-keys.md` | Pouze lokálně |
| Webhook secrets | `~/Dokumenty/přístupy/api-keys.md` | Pouze lokálně |
| DB hesla | `dotnet user-secrets` | Per-projekt |
| CI/CD secrets | GitHub Settings → Secrets | Repozitář |

### GitHub Repository Secrets

Pro CI/CD pipelines:

1. Jdi do **Settings** → **Secrets and variables** → **Actions**
2. Klikni **New repository secret**
3. Přidej secrets jako:
   - `NUGET_API_KEY` - Pro publikování balíčků
   - `AZURE_CREDENTIALS` - Pro Azure deployments

### Použití secrets v GitHub Actions

```yaml
jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - name: Publish to NuGet
        run: dotnet nuget push *.nupkg --api-key ${{ secrets.NUGET_API_KEY }}
```

### Secrets pro lokální vývoj

Používej .NET User Secrets (nikdy se necommitují do Gitu):

```bash
# Inicializace user secrets
dotnet user-secrets init

# Nastavení secrets
dotnet user-secrets set "GitHub:Token" "tvuj-token"
dotnet user-secrets set "ConnectionStrings:DefaultPassword" "tvoje-heslo"
```

Přístup v kódu:
```csharp
var token = configuration["GitHub:Token"];
```

## GitHub Actions (CI/CD)

### Základní .NET Workflow

Vytvoř `.github/workflows/build.yml`:

```yaml
name: Build and Test

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: '10.0.x'
    
    - name: Restore dependencies
      run: dotnet restore
    
    - name: Build
      run: dotnet build --no-restore --configuration Release
    
    - name: Test
      run: dotnet test --no-build --configuration Release --verbosity normal
```

### NuGet Publishing Workflow

Vytvoř `.github/workflows/publish.yml`:

```yaml
name: Publish NuGet Package

on:
  release:
    types: [published]

jobs:
  publish:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: '10.0.x'
    
    - name: Build
      run: dotnet build --configuration Release
    
    - name: Pack
      run: dotnet pack --configuration Release --no-build --output ./nupkg
    
    - name: Publish to NuGet
      run: dotnet nuget push ./nupkg/*.nupkg --api-key ${{ secrets.NUGET_API_KEY }} --source https://api.nuget.org/v3/index.json
```

## Šablony repozitářů

Pro konzistentní nastavení projektů vytvoř template repozitář:

1. Vytvoř repozitář se všemi standardními soubory
2. Jdi do **Settings** → Zaškrtni "Template repository"
3. Při vytváření nových repozitářů vyber "Repository template"

### Doporučený obsah šablony

```
template-dotnet/
├── .github/
│   └── workflows/
│       └── build.yml
├── src/
│   └── .gitkeep
├── tests/
│   └── .gitkeep
├── .gitignore
├── AGENTS.md
├── LICENSE
└── README.md
```

## Checklist pro nové repozitáře

### Minimální nastavení
- [ ] Repozitář vytvořen s README
- [ ] `.gitignore` přidán
- [ ] LICENSE soubor přidán

### Doporučené nastavení
- [ ] AGENTS.md pro AI agenty
- [ ] Ochrana větve `main`
- [ ] Základní CI workflow (build + test)

### Kompletní nastavení (produkční projekty)
- [ ] Vše výše uvedené
- [ ] Webhooky nakonfigurovány
- [ ] GitHub Secrets nastaveny
- [ ] NuGet publishing workflow
- [ ] Code owners soubor (`.github/CODEOWNERS`)
- [ ] Issue šablony (`.github/ISSUE_TEMPLATE/`)
- [ ] PR šablona (`.github/pull_request_template.md`)

## Řešení problémů

| Problém | Řešení |
|---------|--------|
| Webhook nepřijímá | Zkontroluj Payload URL, ověř secret, zkontroluj firewall |
| CI selhává na secrets | Ověř, že název secretu odpovídá workflow |
| Push odmítnut | Zkontroluj pravidla ochrany větve |
| Permission denied | Ověř, že PAT má požadované scopes |

## Související dokumentace

- [Workflow Guide](workflow-guide-cz.md) - Git workflow, commity, větve
- [CI/CD Pipeline Setup](ci-cd-pipeline-setup-cz.md) - Detailní CI/CD konfigurace
- [Code Review Guide](code-review-refactoring-guide-cz.md) - Praktiky code review
