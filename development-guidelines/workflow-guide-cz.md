# C# .NET Application Deployment Guide

## Overview

This document describes the standard deployment workflow for C# .NET applications, including compilation, testing, and service deployment.

---

## 🎯 Vytváření úkolů (Issues)

**KRITICKÉ - KDYŽ UŽIVATEL ŘEKNE "VYTVOŘ ÚKOL" NEBO "NOVÝ ÚKOL":**

Když uživatel požádá o vytvoření úkolu, nového tasku, nebo řekne že chce něco udělat jako nový úkol na projektu, **VŽDY to znamená vytvoření GitHub Issue**.

### Jak vytvořit issue:

```bash
# Pomocí GitHub CLI
gh issue create --repo Olbrasoft/VoiceAssistant \
  --title "Název úkolu" \
  --body "Popis úkolu a požadavků"
```

### Příklady frází uživatele → akce:

| Uživatel řekne | Co to znamená |
|----------------|---------------|
| "Vytvoř úkol" | → Vytvoř GitHub Issue |
| "Nový úkol" | → Vytvoř GitHub Issue |
| "Přidej úkol na projekt" | → Vytvoř GitHub Issue |
| "Zapiš to jako úkol" | → Vytvoř GitHub Issue |
| "Udělej z toho issue" | → Vytvoř GitHub Issue |
| "To bude nová feature" | → Vytvoř GitHub Issue |

### Formát hlavního issue:

```markdown
## Problém
Krátký popis problému nebo požadavku.

## Poznámky
Další relevantní informace.
```

**DŮLEŽITÉ:** 
- Neptat se uživatele "Mám vytvořit GitHub issue?" - prostě ho vytvoř, když uživatel řekne že chce úkol.
- **NEPOUŽÍVEJ markdown checkboxy** (`- [ ]`) pro kroky! Místo toho vytvoř **sub-issues** (viz sekce níže).

---

## C# Unit Testing Standards

**KRITICKÉ - PŘI PSANÍ TESTŮ V C#:**

Pro všechny C# projekty používej následující testovací stack:

### Testovací framework: xUnit

```csharp
// Použij xUnit atributy
[Fact]
public void MethodName_Scenario_ExpectedResult()
{
    // Arrange
    // Act  
    // Assert
}

[Theory]
[InlineData("input1", "expected1")]
[InlineData("input2", "expected2")]
public void MethodName_MultipleInputs_ReturnsExpected(string input, string expected)
{
    // ...
}
```

### Mocking framework: Moq

```csharp
using Moq;

// Vytvoření mocku
var loggerMock = new Mock<ILogger<MyService>>();
var repositoryMock = new Mock<IRepository>();

// Setup chování
repositoryMock.Setup(r => r.GetByIdAsync(It.IsAny<int>()))
    .ReturnsAsync(new Entity { Id = 1, Name = "Test" });

// Verifikace volání
repositoryMock.Verify(r => r.SaveAsync(It.IsAny<Entity>()), Times.Once);
```

### Struktura testovacího projektu

```
tests/
  ProjectName.Tests/
    ProjectName.Tests.csproj
    Services/
      MyServiceTests.cs
    Handlers/
      MyHandlerTests.cs
```

### Povinné NuGet balíčky

```xml
<ItemGroup>
  <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.*" />
  <PackageReference Include="xunit" Version="2.*" />
  <PackageReference Include="xunit.runner.visualstudio" Version="2.*" />
  <PackageReference Include="Moq" Version="4.*" />
  <PackageReference Include="coverlet.collector" Version="6.*" />
</ItemGroup>
```

### Konvence pojmenování testů

```
[MethodUnderTest]_[Scenario]_[ExpectedResult]
```

Příklady:
- `SaveNoteAsync_ValidInput_CreatesFile`
- `ParseCommand_EmptyString_ReturnsNull`
- `Calculate_NegativeNumber_ThrowsException`

### AAA Pattern (Arrange-Act-Assert)

```csharp
[Fact]
public async Task SaveNoteAsync_ValidInput_ReturnsSuccess()
{
    // Arrange
    var service = new NoteService(_loggerMock.Object, _config);
    var title = "Test";
    var content = "Content";

    // Act
    var result = await service.SaveNoteAsync(title, content);

    // Assert
    Assert.True(result.Success);
    Assert.NotNull(result.FilePath);
}
```

**DŮLEŽITÉ:**
- VŽDY používej Moq pro mockování závislostí (NE NSubstitute, NE FakeItEasy)
- VŽDY používej xUnit (NE NUnit, NE MSTest)
- Každý test testuje JEDNU věc
- Testy jsou izolované - žádná závislost na databázi, síti, souborovém systému (kromě temp složek)

---

## Deployment Workflow

### 0. Přečti projektový AGENTS.md

**KRITICKÉ - PŘED KAŽDÝM DEPLOYEM:**

Před deployem VŽDY zkontroluj `AGENTS.md` v projektu - může obsahovat specifická pravidla!

```bash
# Přečti AGENTS.md v projektu
cat /path/to/project/AGENTS.md | head -50
```

Projekty mohou mít vlastní pravidla pro:
- Které služby (ne)restartovat automaticky
- Specifické kroky před/po deployi
- Výjimky z obecného workflow

**Teprve potom pokračuj s deployem.**

---

### 1. Compilation

Compile the application using `dotnet publish`:

```bash
cd /path/to/project
dotnet publish src/ProjectName/ProjectName.csproj \
  -c Release \
  -o ~/deployment-target \
  --no-self-contained
```

**Parameters:**
- `-c Release` - Build in Release configuration (optimized)
- `-o ~/deployment-target` - Output directory for compiled binaries
- `--no-self-contained` - Use system-installed .NET runtime (smaller deployment)

**Alternative:** Use `--self-contained` if you need a standalone executable with embedded runtime.

### 2. Testing

**CRITICAL:** Always run tests before deployment!

```bash
cd /path/to/project
dotnet test
```

**Requirements:**
- All tests MUST pass (exit code 0)
- If ANY test fails, DO NOT proceed with deployment
- Fix failing tests first, then restart the workflow

**Test output example:**
```
Passed!  - Failed:     0, Passed:    42, Skipped:     0, Total:    42
```

### 3. Deployment

Deploy ONLY if all tests pass:

```bash
# Only execute if: dotnet test exited with code 0
dotnet publish src/ProjectName/ProjectName.csproj \
  -c Release \
  -o ~/deployment-target \
  --no-self-contained
```

### 4. Service Restart

After successful deployment, restart the running service:

```bash
# For systemd user service
systemctl --user restart service-name.service

# Verify service is running
systemctl --user status service-name.service
```

## Complete Deployment Script Example

```bash
#!/bin/bash
set -e  # Exit on any error

PROJECT_PATH="/home/jirka/Olbrasoft/VoiceAssistant"
DEPLOY_TARGET="/home/jirka/voice-assistant/orchestration"
SERVICE_NAME="orchestration.service"

cd "$PROJECT_PATH"

# Step 1: Run tests
echo "Running tests..."
dotnet test
if [ $? -ne 0 ]; then
    echo "❌ Tests failed! Aborting deployment."
    exit 1
fi

# Step 2: Build and deploy
echo "Building and deploying..."
dotnet publish src/Orchestration/Orchestration.csproj \
  -c Release \
  -o "$DEPLOY_TARGET" \
  --no-self-contained

# Step 3: Restart service
echo "Restarting service..."
systemctl --user restart "$SERVICE_NAME"

# Step 4: Verify
sleep 2
systemctl --user status "$SERVICE_NAME" --no-pager

echo "✅ Deployment completed successfully"
```

---

## Správa hesel a tajných údajů (Secrets Management)

**KRITICKÉ - NIKDY NEUKLÁDEJ HESLA DO GITU!**

Zdroj: [Microsoft Docs - Safe storage of app secrets](https://learn.microsoft.com/en-us/aspnet/core/security/app-secrets)

### 🚨 Co je Secret (tajný údaj)?
- Hesla k databázi
- API klíče (GitHub, OpenAI, Azure, Ollama...)
- Hesla v connection stringech
- Tokeny

### Co NENÍ Secret (může být v appsettings.json)?
- URL adresy serverů, porty
- Názvy databází, uživatelská jména (bez hesel)
- Názvy modelů, timeouty
- Feature flags

### Správný vzor - Odděl heslo od connection stringu

**appsettings.json** (v Gitu - BEZ hesel):
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=mydb;Username=myuser"
  },
  "GitHub": { "Owner": "Olbrasoft" },
  "OpenAI": { "Model": "gpt-4" }
}
```

**User Secrets** (mimo Git):
```bash
dotnet user-secrets init
dotnet user-secrets set "DbPassword" "tajne_heslo"
dotnet user-secrets set "GitHub:Token" "ghp_xxxxxxxxxxxx"
dotnet user-secrets set "OpenAI:ApiKey" "sk-xxxxxxxxxxxx"
```

**Program.cs** - spoj za běhu:
```csharp
// Pro PostgreSQL (Npgsql)
var connString = builder.Configuration.GetConnectionString("DefaultConnection");
var password = builder.Configuration["DbPassword"];
var fullConnString = $"{connString};Password={password}";

// Pro SQL Server
var conStrBuilder = new SqlConnectionStringBuilder(
    builder.Configuration.GetConnectionString("DefaultConnection"));
conStrBuilder.Password = builder.Configuration["DbPassword"];
```

### Kde se User Secrets ukládají
- **Linux/Mac:** `~/.microsoft/usersecrets/<UserSecretsId>/secrets.json`
- **Windows:** `%APPDATA%\Microsoft\UserSecrets\<UserSecretsId>\secrets.json`

### Příkazy pro User Secrets
```bash
dotnet user-secrets init                              # Inicializace
dotnet user-secrets set "DbPassword" "heslo"          # Nastavení
dotnet user-secrets list                              # Zobrazení
dotnet user-secrets remove "DbPassword"               # Smazání jednoho
dotnet user-secrets clear                             # Smazání všech
```

### Jak funguje konfigurace v .NET

Konfigurace se načítá v tomto pořadí (pozdější přepisuje dřívější):

1. `appsettings.json` (výchozí hodnoty)
2. `appsettings.Development.json` (přepisy pro prostředí)
3. **User Secrets** ← hesla se berou odsud! (jen v Development)
4. Environment variables
5. Command line arguments

### Strategie pro produkční nasazení

**Možnost 1: Konfigurace v publishnuté složce**

Publishnutá složka (např. `/home/user/Apps/myapp/`) NENÍ v Gitu:

```bash
dotnet publish -c Release -o /home/user/Apps/myapp
nano /home/user/Apps/myapp/appsettings.json  # Přidej hesla
```

**Možnost 2: Environment variables**

```bash
export DbPassword="PROD_HESLO"
export GitHub__Token="ghp_production_token"
```

### Rychlý checklist

- [ ] `appsettings.json` neobsahuje ŽÁDNÁ hesla
- [ ] Connection string je BEZ hesla (heslo zvlášť v User Secrets)
- [ ] API klíče jsou v User Secrets, ne v konfiguraci
- [ ] V kódu se heslo přidává k connection stringu za běhu
- [ ] Produkční hesla jsou v deploy složce NEBO v environment variables

---

## Service Configuration

Services are typically configured in `~/.config/systemd/user/`:

```ini
[Unit]
Description=Voice Assistant Orchestration Service
After=network.target

[Service]
Type=simple
WorkingDirectory=/home/jirka/voice-assistant/orchestration
ExecStart=/home/jirka/.dotnet/dotnet /home/jirka/voice-assistant/orchestration/Orchestration.dll
Restart=always
RestartSec=5
Environment="ASPNETCORE_ENVIRONMENT=Production"
Environment="PATH=/usr/local/bin:/usr/bin:/bin"

[Install]
WantedBy=default.target
```

## Important Notes

1. **Never skip tests** - Tests verify code correctness and prevent broken deployments
2. **Always restart services** - C# is compiled, not interpreted. Changes require restart
3. **Verify deployment** - Check service status and logs after restart
4. **Environment variables** - Ensure systemd service has correct PATH and environment

## Common Mistakes

❌ **Deploying without testing**
```bash
dotnet publish  # Wrong! No tests run
```

✅ **Correct approach**
```bash
dotnet test && dotnet publish  # Tests first!
```

❌ **Forgetting to restart service**
```bash
dotnet publish  # Compiled, but old version still running
```

✅ **Correct approach**
```bash
dotnet publish && systemctl --user restart service.service
```

❌ **Not verifying deployment**
```bash
systemctl --user restart service.service  # Did it work?
```

✅ **Correct approach**
```bash
systemctl --user restart service.service
systemctl --user status service.service  # Check!
```

## Troubleshooting

**Service fails to start after deployment:**
1. Check logs: `journalctl --user -u service-name.service -n 50`
2. Verify binaries exist in deployment directory
3. Check file permissions
4. Verify .NET runtime is installed

**Tests fail:**
1. Read test output carefully
2. Fix failing tests
3. DO NOT deploy until all tests pass
4. Consider running specific test: `dotnet test --filter TestName`

**Old code still running:**
1. Verify you restarted the service
2. Check service status: `systemctl --user status service-name.service`
3. Check process: `ps aux | grep dotnet`
4. Force restart: `systemctl --user restart service-name.service`

---

## Git Workflow for GitHub Issues

**CRITICAL - WHEN WORKING ON GITHUB ISSUES:**

Každý issue z GitHubu se řeší v samostatné větvi.

### 🖥️ Workflow s okny při vývoji

**KOMPLETNÍ POSTUP PŘI PRÁCI NA GITHUB ISSUE:**

#### 1. Zahájení práce na issue

1. **Otevři repozitář ve VS Code:**
   ```bash
   code /cesta/k/repozitari
   ```

2. **Přesuň VS Code doprava:**
   ```bash
   ~/.local/bin/move-window-right.sh
   ```

3. **Otevři GitHub issue v Playwright prohlížeči:**
   ```
   playwright_browser_navigate → URL issue na GitHubu
   ```

4. **Prohlížeč nech v jedné záložce** - GitHub issue tam zůstane po celou dobu práce

5. **Vrať fokus do terminálu:**
   ```bash
   ~/focus-back.sh
   ```

**Výsledek:** Uživatel vidí VS Code vpravo, pracuješ v něm, a v prohlížeči má otevřený GitHub issue.

#### 2. Během vývoje (editace kódu)

- Pracuješ ve VS Code (uživatel vidí změny v reálném čase)
- Po každé významné změně: `git add . && git commit -m "popis"`

#### 3. Po git push (přepnutí na prohlížeč)

1. **Udělej push:**
   ```bash
   git push
   ```

2. **Přepni na prohlížeč** (aby uživatel viděl změny na GitHubu):
   ```bash
   # Najdi ID okna prohlížeče
   gdbus call --session --dest org.gnome.Shell \
     --object-path /org/gnome/Shell/Extensions/Windows \
     --method org.gnome.Shell.Extensions.Windows.Activate <BROWSER_WINDOW_ID>
   ```

3. **Aktualizuj stránku v Playwright:**
   ```
   playwright_browser_press_key → F5
   ```

4. **Zavři dokončený sub-issue:**
   ```bash
   gh issue close <číslo> --repo Olbrasoft/VoiceAssistant
   ```

5. **Přepni zpět na VS Code:**
   ```bash
   gdbus call --session --dest org.gnome.Shell \
     --object-path /org/gnome/Shell/Extensions/Windows \
     --method org.gnome.Shell.Extensions.Windows.Activate <VSCODE_WINDOW_ID>
   ```

6. **Vrať fokus do terminálu:**
   ```bash
   ~/focus-back.sh
   ```

#### 4. Identifikace oken

**WM_CLASS pro rozpoznání oken:**
| Aplikace | WM_CLASS |
|----------|----------|
| Prohlížeč (Edge) | `microsoft-edge` |
| VS Code | `Code` |
| Terminál (Kitty) | `kitty` |

**Zjištění ID oken:**
```bash
gdbus call --session --dest org.gnome.Shell \
  --object-path /org/gnome/Shell/Extensions/Windows \
  --method org.gnome.Shell.Extensions.Windows.List 2>/dev/null | \
  python3 -c "
import sys, json
d = sys.stdin.read()
s = d.find('[')
e = d.rfind(']') + 1
for w in json.loads(d[s:e]):
    print(f\"ID: {w.get('id')}, Class: {w.get('wm_class')}, Title: {w.get('title')}\")"
```

---

### ⚡ HLAVNÍ PRAVIDLA - COMMIT A PUSH

| Kdy | Akce |
|-----|------|
| Po vytvoření větve | `git push -u origin branch-name` |
| Po implementaci změny | `git commit` + `git push` |
| Po přidání testů | `git commit` + `git push` |
| Po opravě chyby | `git commit` + `git push` |
| Po merge do main | `git push origin main` |

**NIKDY nečekej s pushem!** Práce se může kdykoli ztratit.

---

### 1. Vytvoření sub-issues pro kroky

**KRITICKÉ - PŘI ZAHÁJENÍ PRÁCE NA ISSUE:**

Ihned po přečtení hlavního issue vytvoř pro každý krok samostatný **sub-issue**:

```bash
# Vytvoření sub-issue propojeného s hlavním issue #43
gh issue create --repo Olbrasoft/VoiceAssistant \
  --title "Vytvořit větev pro #43" \
  --body "Sub-issue pro #43"

gh issue create --repo Olbrasoft/VoiceAssistant \
  --title "Implementovat hlavní změnu pro #43" \
  --body "Sub-issue pro #43"

gh issue create --repo Olbrasoft/VoiceAssistant \
  --title "Napsat unit testy pro #43" \
  --body "Sub-issue pro #43"
```

**Proč sub-issues místo markdown checkboxů nebo komentářů:**

> **⚠️ PRAVIDLO: VŽDY SUB-ISSUES - BEZ VÝJIMEK!**
>
> I pro malé úkoly (1-2 kroky) VŽDY vytvoř sub-issues.
> Žádné checkboxy, žádné "poznámky v komentáři".

**Důvody:**
- **Checkboxy nelze "zavřít"** - není jasný progress, nelze automatizovat
- **Komentáře nelze označit jako hotové** - jak bys označil že krok v komentáři je dokončený?
- **Konzistentní workflow** - vždy stejný postup bez výjimek = méně chyb
- Každý krok má vlastní historii a diskuzi
- Lze je přiřadit různým lidem
- GitHub ukazuje progress v `sub_issues_summary` (např. "2/5 completed")
- Při příštím otevření okamžitě vidíš stav každého kroku

**🚨 KRITICKÉ - PRŮBĚŽNĚ ZAVÍREJ DOKONČENÉ SUB-ISSUES:**

**IHNED po dokončení každého kroku** zavři příslušný sub-issue. **NEČEKEJ na konec!**

```bash
# Zavření sub-issue po dokončení kroku
gh issue close 44 --repo Olbrasoft/VoiceAssistant
```

**Workflow při práci na issue:**
1. Dokončíš krok (např. "Implementovat endpoint")
2. **IHNED** zavři sub-issue: `gh issue close <číslo>`
3. Pokračuj na další krok
4. Opakuj

**Proč je to kritické:**
- Když se práce přeruší, je jasné co už je hotové
- Uživatel vidí průběh v reálném čase
- GitHub ukazuje progress (např. "2/5 completed" v sub_issues_summary)
- Příště víš, kde jsi skončil

**NIKDY nezavírej všechny sub-issues najednou na konci!**

**NEPOUŽÍVEJ markdown checkboxy (`- [ ]`) v body issue!**

### 2. Vytvoření větve
Před začátkem práce na issue vytvoř novou větev s logickým názvem:

```bash
# Pro bug fix (issue #3)
git checkout -b fix/issue-3-stop-detection-before-routing

# Pro novou funkci (issue #2)
git checkout -b feature/issue-2-srp-refactoring

# Pro vylepšení
git checkout -b enhancement/issue-5-config-to-appsettings
```

**Konvence pojmenování větví:**
- `fix/issue-N-krátký-popis` - pro opravy chyb
- `feature/issue-N-krátký-popis` - pro nové funkce
- `enhancement/issue-N-krátký-popis` - pro vylepšení
- `refactor/issue-N-krátký-popis` - pro refaktoring

### 3. Implementace s průběžnými commity

**KRITICKÉ - COMMITUJ A PUSHUJ ČASTO:**

Práce může být kdykoli přerušena. Aby se nic neztratilo, commituj a pushuj po KAŽDÉM významném kroku:

```bash
# Po vytvoření větve - první push
git push -u origin fix/issue-3-stop-detection

# Po implementaci hlavní změny
git add .
git commit -m "Implement stop detection before routing"
git push

# Po přidání testů
git add .
git commit -m "Add unit tests for stop detection"
git push

# Po opravě code review nebo dalších změnách
git add .
git commit -m "Address review: refactor IsStopCommand method"
git push
```

**Workflow krok za krokem:**

1. **Vytvoř větev** → `git push -u origin branch-name`
2. **Implementuj změnu** → commit + push
3. **Přidej testy** → commit + push
4. **Spusť testy** → pokud prochází, pokračuj; pokud ne, oprav a commit + push
5. **Finální úpravy** → commit + push
6. **Merge do main** → push main

**Pravidla pro commit messages:**
- První commit může být WIP (Work in Progress)
- Průběžné commity popisují, co bylo uděláno
- Finální commit před mergem obsahuje `Fix #N` nebo `Closes #N`

**Příklad sekvence commitů:**
```
1. "WIP: Start implementing stop detection fix"
2. "Implement stop detection before routing logic"
3. "Add InternalsVisibleTo for testing"
4. "Add unit tests for IsStopCommand method"
5. "Fix #3: Complete stop detection before routing"
```

### 4. Spuštění testů

```bash
cd /path/to/project
dotnet test
```

- Všechny testy MUSÍ projít
- Pokud nějaký test selže, oprav ho a commitni + pushni opravu
- Teprve pak pokračuj k merge

### 5. Sloučení s hlavní větví
Po dokončení a otestování:

```bash
# Přepni na hlavní větev
git checkout main

# Slouč feature větev
git merge fix/issue-3-stop-detection-before-routing

# Push změny
git push origin main

# Smaž feature větev (volitelně)
git branch -d fix/issue-3-stop-detection-before-routing
```

### 6. Uzavření issue

**🚨 KRITICKÉ - PRAVIDLA PRO UZAVŘENÍ ISSUE:**

Issue **NELZE** uzavřít, dokud nejsou splněny VŠECHNY následující podmínky:

1. **Všechny sub-issues jsou zavřené** - žádný otevřený sub-issue nesmí zůstat
2. **Všechny testy prochází** - `dotnet test` vrací exit code 0
3. **Kód je deploynutý** - nová verze běží v produkci
4. **Funkčnost je ověřena** - reálný test s uživatelem
5. **✅ SCHVÁLENÍ UŽIVATELEM** - uživatel (programátor/architekt) explicitně potvrdí, že:
   - Funkce funguje správně
   - Je spokojený s řešením
   - Issue může být uzavřen

**NIKDY neuzavírej issue automaticky!**

```
❌ ŠPATNĚ:
- "Všechny testy prochází, uzavírám issue" → NE! Chybí reálný test a schválení
- "Deploy proběhl, issue je hotový" → NE! Uživatel neověřil funkčnost
- "Kód je napsaný a commitnutý" → NE! Nebylo otestováno v reálném prostředí

✅ SPRÁVNĚ:
- Implementuj → Testy → Deploy → Reálný test → Uživatel potvrdí → Teprve pak uzavři
```

**Workflow uzavření:**

1. **Zeptej se uživatele:** "Můžeš prosím otestovat, že [funkce] funguje správně?"
2. **Počkej na odpověď:** Uživatel otestuje a řekne, zda je spokojený
3. **Pokud ANO:** "Díky za potvrzení, uzavírám Issue #N"
4. **Pokud NE:** Oprav problém, znovu deploy, znovu testuj

**Příklad dialogu:**
```
Agent: "Deploy je hotový. Můžeš prosím otestovat, že otázky jdou do Plan módu?"
Uživatel: "Ano, funguje to správně."
Agent: "Výborně, uzavírám Issue #6."
```

```
Agent: "Deploy je hotový. Můžeš prosím otestovat?"
Uživatel: "Ne, pořád to posílá jako Build."
Agent: "Rozumím, podívám se na to..." [NEUZAVÍREJ ISSUE!]
```

---

**Další důležitá pravidla:**

- Nikdy necommituj přímo do `main` větve
- Každý issue = samostatná větev
- Před mergem vždy spusť testy
- V commit message používej `Fix #N` nebo `Closes #N` pro automatické uzavření issue
