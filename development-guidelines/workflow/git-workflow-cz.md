# Průvodce pracovním postupem pro C# .NET aplikace

Kompletní průvodce pro .NET vývoj: issues, Git workflow, testování, deployment a správa hesel.

---

## GitHub Issues

### Vytváření Issues

Když uživatel řekne "vytvoř úkol" → **vytvoř GitHub Issue** (neptej se, prostě to udělej)

Zaměř se na **CO** a **PROČ**, **JAK** nech na programátorovi.

### Šablona Issue

```markdown
## Shrnutí
[Jedna věta: Co je potřeba udělat a proč]

## User Story
Jako [osoba/role] chci [akci/funkci], abych [přínos/hodnota].

## Kontext
- Současný stav: [Co existuje nyní]
- Problém: [Co je špatně nebo chybí]

## Požadavky
### Musí mít
- [ ] Požadavek 1
- [ ] Požadavek 2

### Mělo by mít (pokud zbude čas)
- [ ] Volitelné vylepšení

## Akceptační kritéria
- [ ] Pokud [kontext], když [akce], pak [očekávaný výsledek]

## Mimo rozsah
- Co toto issue NEZAHRNUJE
```

### Štítky Issue

| Štítek | Použití |
|--------|---------|
| `feature` | Nová funkcionalita |
| `bug` | Něco nefunguje |
| `enhancement` | Vylepšení existující funkce |
| `refactor` | Úprava kódu, beze změny chování |
| `docs` | Pouze dokumentace |

---

## Sub-Issues: Kritická pravidla

**NIKDY nepoužívej checkboxy** - použij **sub-issues**.

**Sub-issues MUSÍ být propojeny přes nativní GitHub funkci, NE jako textové reference.**

### Špatný způsob

NEPIŠ toto do těla issue:
- "Part of #123"
- "Sub-issue of #123"
- "Parent Issue: #123"

Toto NEVYTVÁŘÍ skutečný vztah rodič-potomek. Je to jen text.

### Správný způsob

**Možnost 1: Přes GitHub UI**
1. Otevři rodičovský issue
2. Klikni na tlačítko "Add sub-issue" (v postranním panelu)
3. Vyber nebo vytvoř podřízený issue

**Možnost 2: Přes GitHub API**
```bash
curl -X POST \
  -H "Authorization: token VÁŠ_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/OWNER/REPO/issues/ČÍSLO_RODIČE/sub_issues" \
  -d '{"sub_issue_id": ID_POTOMKA}'
```

### Proč jsou nativní sub-issues důležité

| Aspekt | Textová reference | Nativní sub-issue |
|--------|-------------------|-------------------|
| Sledování průběhu | Ruční počítání | Automatické procenta |
| Navigace | Nutné vyhledávání | Přímé obousměrné odkazy |
| Reporting | Není možný | Vestavěné přehledy |
| Dokončení rodiče | Ruční ověření | Automatické blokování |
| Viditelnost | Schované v textu | Výrazné v UI |

---

## Git Workflow

- Každý issue = samostatná větev (`fix/issue-N-popis`, `feature/issue-N-popis`)
- **COMMIT + PUSH po každém kroku**
- Sub-issues: vytvoř pro každý krok, zavři **ihned** po dokončení
- Uzavři issue pouze po: všechny sub-issues zavřené + testy prochází + nasazeno + **SCHVÁLENÍ UŽIVATELEM**

---

## Principy psaní Issues

### DĚLEJ
- Piš z pohledu uživatele
- Piš implementačně neutrální požadavky (CO, ne JAK)
- Zahrň akceptační kritéria
- Prioritizuj požadavky (musí mít / mělo by mít)
- Rozděl velké issues na menší sub-issues
- **PROPOJUJ sub-issues správně pomocí nativní GitHub funkce**

### NEDĚLEJ
- Nespecifikuj databázové schéma nebo strukturu tabulek
- Nevybírej frameworky nebo knihovny
- Nedefinuj cesty API endpointů nebo HTTP metody
- Nedělej architektonická rozhodnutí
- Nepoužívej nejednoznačný jazyk ("mělo by fungovat", "možná bude potřeba")
- **NEPIŠ "Part of #X" místo skutečného propojení sub-issues**

### Checklist před vytvořením Issue

- [ ] Lze pochopit bez dalšího kontextu?
- [ ] Žádné nejednoznačné výrazy?
- [ ] Je jasné KDO má z toho prospěch?
- [ ] Je definováno CO se má udělat?
- [ ] Je vysvětleno PROČ je to potřeba?
- [ ] Jsou akceptační kritéria měřitelná?
- [ ] Je issue dostatečně malý na dokončení v jedné session?
- [ ] Pokud je to sub-issue, je PROPOJEN (ne jen zmíněn) s rodičem?

---

## C# Unit Testování

**Framework:** xUnit + Moq (VŽDY)

**Pojmenování:** `[Metoda]_[Scénář]_[Očekávaný výsledek]`

---

## Deployment

1. Zkontroluj projektový `AGENTS.md` nebo `CLAUDE.md`
2. `dotnet test` (VŠECHNY musí projít)
3. `dotnet publish -c Release -o ~/target`

---

## Správa hesel (Secrets Management)

**🚨 NIKDY neukládej hesla do Gitu!** [Microsoft Docs](https://learn.microsoft.com/en-us/aspnet/core/security/app-secrets)

### Secrets = hesla, API klíče, tokeny
### NEJSOU secrets = URL, porty, názvy DB, uživatelská jména, názvy modelů

### Správný vzor

**appsettings.json** (v Gitu - connection string BEZ hesla):
```json
{
  "ConnectionStrings": { "Default": "Host=localhost;Database=mydb;Username=user" },
  "GitHub": { "Owner": "Olbrasoft" },
  "OpenAI": { "Model": "gpt-4" }
}
```

**User Secrets** (mimo Git - pouze hesla a API klíče):
```bash
dotnet user-secrets init
dotnet user-secrets set "DbPassword" "tajne"
dotnet user-secrets set "GitHub:Token" "ghp_xxx"
dotnet user-secrets set "OpenAI:ApiKey" "sk-xxx"
```

**Program.cs** - spoj za běhu:
```csharp
var connString = builder.Configuration.GetConnectionString("Default");
var password = builder.Configuration["DbPassword"];
var full = $"{connString};Password={password}";
```

### Pořadí načítání konfigurace
appsettings.json → appsettings.Development.json → **User Secrets** → Env vars → CLI args

### Produkce
Konfigurace v publishnuté složce (není v Gitu) NEBO `export DbPassword="prod_secret"`

---

## Reference

- [GitHub Sub-Issues dokumentace](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/adding-sub-issues)
- [Atlassian User Stories průvodce](https://www.atlassian.com/agile/project-management/user-stories)
- [Microsoft App Secrets](https://learn.microsoft.com/en-us/aspnet/core/security/app-secrets)
