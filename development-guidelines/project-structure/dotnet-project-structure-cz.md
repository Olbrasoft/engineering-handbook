# Struktura .NET projektů

Kompletní průvodce strukturováním .NET projektů v Olbrasoft repozitářích.

> **Poznámka:** Tyto konvence platí pro všechny .NET jazyky (C#, F#, VB.NET, C++/CLI), nejen pro C#. Pojmenování namespace následuje [Microsoft Framework Design Guidelines](https://learn.microsoft.com/en-us/dotnet/standard/design-guidelines/names-of-namespaces).

---

## Adresářová struktura

### Rozložení repozitáře

```
NázevRepozitáře/
├── src/                              # Zdrojové projekty
│   ├── {Doména}.{Vrstva}/            # Složky projektů
│   └── ...
├── test/                             # Testovací projekty (některé repo používají "tests/")
│   ├── {Doména}.{Vrstva}.Tests/
│   └── ...
├── .github/
│   └── workflows/                    # CI/CD pipelines
├── deploy/                           # Deployment skripty (volitelné)
├── docs/                             # Dokumentace (volitelné)
├── .gitignore
├── LICENSE
├── README.md
├── AGENTS.md                         # Instrukce pro AI agenty (volitelné)
└── {NázevRepozitáře}.sln             # Solution soubor
```

---

## Konvence pojmenování

### Klíčový princip: Složka vs Namespace

**Názvy složek projektů NEOBSAHUJÍ prefix `Olbrasoft.`, ale namespaces ANO.**

| Aspekt | Příklad (VirtualAssistant) | Příklad (GitHub.Issues) |
|--------|---------------------------|------------------------|
| **Složka** | `VirtualAssistant.Voice/` | `GitHub.Issues.Sync/` |
| **Namespace** | `Olbrasoft.VirtualAssistant.Voice` | `Olbrasoft.GitHub.Issues.Sync` |

### Názvy složek projektů

```
{Doména}.{Vrstva}[.{Podvrstva}]
```

- **Doména:** Business doména (`GitHub.Issues`, `VirtualAssistant`, `Text`)
- **Vrstva:** Architektonická vrstva (`Data`, `Business`, `Sync`, `AspNetCore`, `Voice`)
- **Podvrstva:** Volitelná specifikace (`EntityFrameworkCore`, `RazorPages`, `PostgreSQL`)

**Příklady:**

| Typ vrstvy | Název složky |
|------------|--------------|
| Data/Doména | `VirtualAssistant.Data` |
| Business logika | `GitHub.Issues.Business` |
| EF Core implementace | `VirtualAssistant.Data.EntityFrameworkCore` |
| DB migrace | `GitHub.Issues.Migrations.PostgreSQL` |
| API/Web | `GitHub.Issues.AspNetCore.RazorPages` |
| Voice/Audio | `VirtualAssistant.Voice` |

### Konvence namespace

**Namespace = `Olbrasoft.` + Název složky**

Dosáhne se toho pomocí `<RootNamespace>` v .csproj:

```xml
<PropertyGroup>
  <RootNamespace>Olbrasoft.VirtualAssistant.Voice</RootNamespace>
</PropertyGroup>
```

| Složka | Namespace |
|--------|-----------|
| `VirtualAssistant.Voice` | `Olbrasoft.VirtualAssistant.Voice` |
| `GitHub.Issues.Sync` | `Olbrasoft.GitHub.Issues.Sync` |
| `VirtualAssistant.Data.EntityFrameworkCore` | `Olbrasoft.VirtualAssistant.Data.EntityFrameworkCore` |

**Podsložky se přidávají k namespace:**

| Umístění souboru | Namespace |
|------------------|-----------|
| `src/GitHub.Issues.Sync/Services/GitHubSyncService.cs` | `Olbrasoft.GitHub.Issues.Sync.Services` |
| `src/VirtualAssistant.Voice/Services/TtsService.cs` | `Olbrasoft.VirtualAssistant.Voice.Services` |

### Testovací adresář (`test/` nebo `tests/`)

**KRITICKÉ: Každý zdrojový projekt MUSÍ mít svůj vlastní samostatný testovací projekt.**

| Zdrojový projekt | Testovací projekt |
|------------------|-------------------|
| `VirtualAssistant.Voice` | `VirtualAssistant.Voice.Tests` |
| `GitHub.Issues.Business` | `GitHub.Issues.Business.Tests` |
| `GitHub.Issues.Sync` | `GitHub.Issues.Sync.Tests` |

**NIKDY nevytvářejte jeden sdílený testovací projekt pro všechny testy.**

### Pojmenování testovacích tříd

| Zdrojová třída | Testovací třída |
|----------------|-----------------|
| `GitHubSyncService` | `GitHubSyncServiceTests` |
| `TtsService` | `TtsServiceTests` |

Testovací soubory zrcadlí strukturu zdrojových složek:

```
src/GitHub.Issues.Sync/
  Services/
    GitHubSyncService.cs
    
test/GitHub.Issues.Sync.Tests/
  Services/
    GitHubSyncServiceTests.cs
```

---

## Konfigurace projektu

### Standardní .csproj šablona

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <LangVersion>13</LangVersion>
    <RootNamespace>Olbrasoft.{Doména}.{Vrstva}</RootNamespace>
    <GenerateDocumentationFile>true</GenerateDocumentationFile>
    <NoWarn>$(NoWarn);1591</NoWarn>
  </PropertyGroup>

</Project>
```

### Šablona testovacího projektu

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <IsPackable>false</IsPackable>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="coverlet.collector" Version="6.0.4" />
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.14.1" />
    <PackageReference Include="Moq" Version="4.20.72" />
    <PackageReference Include="xunit" Version="2.9.3" />
    <PackageReference Include="xunit.runner.visualstudio" Version="3.1.4" />
  </ItemGroup>

  <ItemGroup>
    <Using Include="Xunit" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\..\src\{ZdrojovýProjekt}\{ZdrojovýProjekt}.csproj" />
  </ItemGroup>

</Project>
```

---

## Nastavení GitHub Webhooků

Pro aplikace, které potřebují real-time notifikace z GitHubu (jako GitHub.Issues), nastavte webhooky přes ngrok.

### Lokální vývoj s ngrok

1. **Spusťte ngrok tunel** směřující na vaši lokální aplikaci:
   ```bash
   ngrok http 5156
   ```

2. **Poznamenejte si veřejnou URL** (např. `https://plumbaginous-zoe-unexcusedly.ngrok-free.dev`)

### Konfigurace GitHub Webhooku

| Parametr | Hodnota |
|----------|---------|
| **Payload URL** | `https://{ngrok-url}/api/webhooks/github` |
| **Content Type** | `application/json` |
| **Webhook Secret** | Uložen v `~/Dokumenty/guidebooks/github-webhooks.md` |

### Doporučené eventy

Vyberte podle potřeby:
- `issues` - Issue vytvořen, upraven, uzavřen
- `issue_comment` - Komentáře k issues
- `label` - Změny labelů
- `repository` - Změny repozitáře
- `sub_issues` - Sub-issues (pokud používáte)

### Nastavení webhooku pro nový repozitář

1. Jděte do repozitáře **Settings → Webhooks → Add webhook**
2. Zadejte Payload URL s ngrok doménou
3. Nastavte Content type na `application/json`
4. Zadejte sdílený webhook secret
5. Vyberte eventy (nebo "Let me select individual events")
6. Klikněte **Add webhook**

### Port aplikace

| Aplikace | Port | Webhook Endpoint |
|----------|------|------------------|
| GitHub.Issues | 5156 | `/api/webhooks/github` |

---

## Přístupové údaje a secrets

### GitHub Personal Access Token

**Umístění:** `~/Dokumenty/přístupy/api-keys.md`

Token se používá pro:
- Autentizaci GitHub API požadavků při synchronizaci
- Vyhnutí se rate limitům (60 req/hodinu → 5000 req/hodinu s tokenem)

### Struktura adresáře s API klíči

```
~/Dokumenty/přístupy/
├── api-keys.md              # Hlavní soubor s API klíči (GitHub, NuGet)
├── github-issues/           # Klíče specifické pro projekt
│   ├── cerebras.txt
│   ├── cohere.txt
│   └── groq.txt
├── databases.md             # Connection stringy k databázím
└── hosting.md               # Hostingové přístupové údaje
```

### Konfigurace User Secrets

Použijte .NET User Secrets pro lokální vývoj:

```bash
cd src/GitHub.Issues.AspNetCore.RazorPages
dotnet user-secrets init
dotnet user-secrets set "GitHub:Token" "ghp_xxx"
dotnet user-secrets set "GitHubApp:WebhookSecret" "xxx"
```

---

## Architektura vrstev

### Typická struktura vrstev

```
{Doména}.Data              → Entity, DTO, Queries, Commands (rozhraní)
{Doména}.Data.EFCore       → DbContext, Query/Command handlery, Migrace
{Doména}.Business          → Business služby, strategie, modely
{Doména}.Sync              → Klienti externích API, sync služby, webhooky
{Doména}.AspNetCore.X      → Web vrstva (RazorPages, API controllery)
```

### Závislosti vrstev

```
AspNetCore.RazorPages
    ↓
Business ←→ Sync
    ↓
Data.EntityFrameworkCore
    ↓
Data (entity, rozhraní)
```

---

## Příklady

### Struktura repozitáře GitHub.Issues

```
GitHub.Issues/
├── src/
│   ├── GitHub.Issues.AspNetCore.RazorPages/  # Web UI
│   ├── GitHub.Issues.Business/               # Business logika
│   ├── GitHub.Issues.Data/                   # Entity, DTO
│   ├── GitHub.Issues.Data.EntityFrameworkCore/ # EF Core
│   ├── GitHub.Issues.Migrations.PostgreSQL/  # PG migrace
│   ├── GitHub.Issues.Migrations.SqlServer/   # MSSQL migrace
│   └── GitHub.Issues.Sync/                   # GitHub API sync
├── test/
│   ├── GitHub.Issues.AspNetCore.RazorPages.Tests/
│   ├── GitHub.Issues.Business.Tests/
│   ├── GitHub.Issues.Data.EntityFrameworkCore.Tests/
│   ├── GitHub.Issues.Data.Tests/
│   └── GitHub.Issues.Sync.Tests/
└── GitHub.Issues.sln
```

**Namespaces:** Všechny používají `Olbrasoft.GitHub.Issues.{Vrstva}` pomocí RootNamespace.

### Struktura repozitáře VirtualAssistant

```
VirtualAssistant/
├── src/
│   ├── VirtualAssistant.Agent/
│   ├── VirtualAssistant.Core/
│   ├── VirtualAssistant.Data/
│   ├── VirtualAssistant.Data.EntityFrameworkCore/
│   ├── VirtualAssistant.Desktop/
│   ├── VirtualAssistant.GitHub/
│   ├── VirtualAssistant.LlmChain/
│   ├── VirtualAssistant.Service/           # Hlavní web služba
│   ├── VirtualAssistant.Tray/
│   └── VirtualAssistant.Voice/
├── tests/
│   ├── VirtualAssistant.Agent.Tests/
│   ├── VirtualAssistant.Data.EntityFrameworkCore.Tests/
│   ├── VirtualAssistant.GitHub.Tests/
│   └── VirtualAssistant.Voice.Tests/
├── deploy/
├── plugins/
└── VirtualAssistant.sln
```

**Namespaces:** Všechny používají `Olbrasoft.VirtualAssistant.{Vrstva}` pomocí RootNamespace.

---

## Checklist pro nový repozitář

- [ ] Vytvořte adresář `src/` se složkami projektů (BEZ prefixu `Olbrasoft.`)
- [ ] Vytvořte adresář `test/` (nebo `tests/`)
- [ ] Vytvořte samostatný testovací projekt pro každý zdrojový projekt
- [ ] Nastavte `<RootNamespace>Olbrasoft.{Doména}.{Vrstva}</RootNamespace>` v každém .csproj
- [ ] Použijte .NET 10 (`net10.0`)
- [ ] Použijte xUnit + Moq pro testování
- [ ] Nakonfigurujte user secrets pokud je potřeba
- [ ] Přidejte `.gitignore`, `LICENSE`, `README.md`
- [ ] Vytvořte solution soubor `{NázevRepo}.sln`
- [ ] Pokud používáte GitHub webhooky, zdokumentujte v `~/Dokumenty/guidebooks/`

---

## Reference

- [Workflow Guide](./workflow-guide-cz.md) - Git workflow, GitHub issues
- [SOLID principy](../solid-principles/solid-principles-2025-cz.md)
- [Design Patterns](../design-patterns/gof-design-patterns-2025-cz.md)
