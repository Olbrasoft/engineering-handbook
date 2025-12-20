# Průvodce Deploymentem .NET Aplikací na Linuxu

Kompletní best practices pro deployment .NET aplikací na Linux - kde ukládat base directory, jak strukturovat deploy skripty a jak správně separovat runtime od deployment.

---

## Základní Principy

### Klíčová pravidla

| Pravidlo | Důvod |
|----------|-------|
| **Deploy script NIKDY nezjišťuje base directory - DOSTÁVÁ ji** | Deploy musí být deterministický a automatizovatelný |
| **Base directory není konfigurace** | Je to vlastnost běžícího procesu |
| **Deploy definuje realitu, Runtime ji čte** | Oddělení zodpovědností |
| **Jeden zdroj pravdy pro každou fázi** | Vyhýbá se konfliktům a nekonzistenci |

---

## Kde Ukládat Base Directory

### ❌ **KDE NEUKLÁDAT**

| Místo | Proč NE |
|-------|---------|
| `appsettings.json` | Runtime záležitost, deploy je před runtime |
| Environment proměnná jako primární zdroj | Implicitní, může chybět, není deterministická |
| README.md | Dokumentace, ne vstup |
| Natvrdo v kódu | Deploy ≠ runtime, nelze změnit bez rekompilace |

### ✅ **DVĚ FÁZE, JEDEN ŘETĚZEC**

```
OPERATOR / CI / SCRIPT
        ↓
deploy.sh --base-dir /opt/olbrasoft/myapp
        ↓
dotnet publish → $BASE_DIR/app
        ↓
runtime → AppContext.BaseDirectory
```

| Fáze | Odkud je base directory | Jak |
|------|------------------------|-----|
| **Deploy** | Argument scriptu | `./deploy.sh /opt/olbrasoft/myapp` |
| **Runtime** | `AppContext.BaseDirectory` | Automaticky od .NET runtime |

**To nejsou dvě místa - to jsou dvě fáze jednoho řetězce.**

---

## Struktura Adresářů na Linuxu

### Produkční Aplikace (Linux FHS)

```
/opt/<vendor>/<app>/          ← Root instalace
├── app/                      ← Binárky (AppContext.BaseDirectory při běhu)
│   ├── MyApp.dll
│   ├── MyApp.runtimeconfig.json
│   └── MyApp.deps.json
├── config/                   ← Konfigurace
│   └── appsettings.json
├── certs/                    ← TLS certifikáty
│   └── server.pfx
├── data/                     ← Runtime data
│   └── db.sqlite
└── logs/                     ← Logy (volitelně)
```

**Příklad:**
```
/opt/olbrasoft/virtual-assistant/
```

### Uživatelská / Vývojová Instance

```
~/.local/share/myapp/         ← Root instalace
├── app/                      ← Binárky
├── config/                   ← Konfigurace
└── data/                     ← Data
```

nebo

```
~/apps/myapp/                 ← Alternativa pro dev
```

### ⚠️ **Base Directory ≠ Data Directory**

| Typ | Cesta | Účel |
|-----|-------|------|
| **Binárky** | `/opt/olbrasoft/myapp/app/` | Publikované DLL, exe |
| **Konfigurace** | `/etc/myapp/` nebo `$BASE/config/` | appsettings.json, *.config |
| **Runtime data** | `/var/lib/myapp/` nebo `$BASE/data/` | Databáze, cache |
| **Logy** | `/var/log/myapp/` nebo `$BASE/logs/` | Aplikační logy |
| **Certifikáty** | `/etc/myapp/certs/` nebo `$BASE/certs/` | SSL/TLS certifikáty |

**Důležité:** Na Linuxu **NIKDY** neukládej data do složky s binárkami!

---

## Sdílené AI Modely a Read-Only Data

### Kde Ukládat AI/ML Modely (Whisper, Ollama, atd.)

AI modely jsou **read-only, architecture-independent data** → patří do `/usr/share` nebo `~/.local/share`.

| Typ instalace | Cesta | Použití |
|---------------|-------|---------|
| **Systémové** (sdílené) | `/usr/share/whisper-models/` | Více uživatelů, vyžaduje sudo |
| **Uživatelské** | `~/.local/share/whisper-models/` | Jeden uživatel, bez sudo |

### Příklady z Reálného Světa

#### Ollama (AI modely)
```bash
# Linux default
/usr/share/ollama/.ollama/models/

# Přesun (environment variable)
export OLLAMA_MODELS=/path/to/models
```

#### Whisper Modely
```bash
# Systémové (doporučeno pro servery)
/usr/share/whisper-models/
├── ggml-tiny.bin          # 75 MB
├── ggml-medium.bin        # 1.5 GB
└── ggml-large-v3.bin      # 2.9 GB

# Uživatelské (doporučeno pro desktop/dev)
~/.local/share/whisper-models/
├── ggml-tiny.bin
├── ggml-medium.bin
└── ggml-large-v3.bin
```

### Linux FHS & XDG Zdůvodnění

Podle **Filesystem Hierarchy Standard (FHS)**:

| Adresář | Účel | AI modely? |
|---------|------|-----------|
| `/usr/share/` | Read-only architecture-independent data | ✅ **ANO** |
| `/var/lib/` | Variable state information (mění se za běhu) | ❌ NE |
| `/opt/` | Add-on application software packages | ❌ NE |
| `~/.local/share/` | Per-user data files (XDG) | ✅ **ANO** |

**Důvod:**
- AI modely jsou **binární soubory**
- Stáhnete **jednou**, nikdy se **nemění**
- **Architecture-independent** (stejné pro x86, ARM)
- → Podle FHS patří do `/usr/share` nebo `~/.local/share`

### Použití v C# Kódu

```csharp
public class WhisperModelLocator
{
    public static string GetModelsPath()
    {
        // 1. Zkus uživatelský adresář (XDG)
        var userModels = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "whisper-models"
        );
        // Na Linuxu: ~/.local/share/whisper-models
        
        if (Directory.Exists(userModels))
            return userModels;
        
        // 2. Zkus systémový adresář
        var systemModels = "/usr/share/whisper-models";
        if (Directory.Exists(systemModels))
            return systemModels;
        
        // 3. Fallback - vytvoř uživatelský
        Directory.CreateDirectory(userModels);
        return userModels;
    }
    
    public static string GetModelPath(string modelName)
    {
        var modelsDir = GetModelsPath();
        return Path.Combine(modelsDir, modelName);
    }
}

// Použití
var modelPath = WhisperModelLocator.GetModelPath("ggml-large-v3.bin");
// Vrátí: ~/.local/share/whisper-models/ggml-large-v3.bin
```

### Instalace Modelů

#### Systémová Instalace (sudo required)
```bash
#!/usr/bin/env bash
# install-whisper-models.sh

MODELS_DIR="/usr/share/whisper-models"
sudo mkdir -p "$MODELS_DIR"

# Stáhni modely
cd /tmp
wget https://huggingface.co/.../ggml-large-v3.bin

# Přesuň do systémového adresáře
sudo mv ggml-large-v3.bin "$MODELS_DIR/"
sudo chmod 644 "$MODELS_DIR/ggml-large-v3.bin"

echo "✅ Model installed to $MODELS_DIR"
```

#### Uživatelská Instalace (bez sudo)
```bash
#!/usr/bin/env bash
# install-whisper-models-user.sh

MODELS_DIR="$HOME/.local/share/whisper-models"
mkdir -p "$MODELS_DIR"

# Stáhni modely
cd /tmp
wget https://huggingface.co/.../ggml-large-v3.bin

# Přesuň do uživatelského adresáře
mv ggml-large-v3.bin "$MODELS_DIR/"
chmod 644 "$MODELS_DIR/ggml-large-v3.bin"

echo "✅ Model installed to $MODELS_DIR"
```

### ⚠️ **CO NEDĚLAT**

| ❌ Špatně | ✅ Správně |
|----------|-----------|
| `~/apps/asr-models/` | `~/.local/share/whisper-models/` |
| `~/.whisper/` | `~/.local/share/whisper-models/` |
| `/opt/myapp/models/` | `/usr/share/whisper-models/` |
| `/var/lib/myapp/models/` | `/usr/share/whisper-models/` |

**Důvody:**
- `~/apps/` není Linux standard (pouze dočasné dev řešení)
- `~/.whisper/` porušuje XDG specifikaci (dotfiles jsou pro config)
- `/opt/` je pro aplikační balíčky, ne data
- `/var/lib/` je pro data která se **MĚNÍ** (modely jsou read-only)

### Reference

- **Linux FHS:** [https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch04s11.html](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch04s11.html) (`/usr/share`)
- **XDG Base Directory:** [https://specifications.freedesktop.org/basedir-spec/latest/](https://specifications.freedesktop.org/basedir-spec/latest/)
- **Ollama FAQ:** [https://docs.ollama.com/faq](https://docs.ollama.com/faq) (příklad AI modelů)

---

## Deploy Script Pattern

### Minimální Deploy Script

```bash
#!/usr/bin/env bash
set -e

# Deploy script DOSTÁVÁ base directory jako argument
BASE_DIR="$1"

if [ -z "$BASE_DIR" ]; then
  echo "❌ Usage: deploy.sh <base-directory>"
  echo "Example: ./deploy.sh /opt/olbrasoft/myapp"
  exit 1
fi

echo "📦 Deploying to: $BASE_DIR"

# Publikuj do $BASE_DIR/app
dotnet publish src/MyApp/MyApp.csproj \
  -c Release \
  -o "$BASE_DIR/app" \
  --no-self-contained

echo "✅ Deployment complete!"
```

**Použití:**
```bash
./deploy.sh /opt/olbrasoft/myapp
```

### Pokročilý Deploy Script (s testy a systemd)

```bash
#!/usr/bin/env bash
set -e

BASE_DIR="$1"

if [ -z "$BASE_DIR" ]; then
  echo "❌ Usage: deploy.sh <base-directory>"
  exit 1
fi

echo "╔══════════════════════════════════════╗"
echo "║       MyApp Deploy Script            ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "Target: $BASE_DIR"
echo ""

# 1. Spusť testy
echo "📋 Running tests..."
dotnet test --verbosity minimal
if [ $? -ne 0 ]; then
    echo "❌ Tests failed! Aborting deployment."
    exit 1
fi
echo "✅ All tests passed"
echo ""

# 2. Publikuj
echo "🔨 Publishing..."
dotnet publish src/MyApp/MyApp.csproj \
  -c Release \
  -o "$BASE_DIR/app" \
  --no-self-contained

echo "✅ Published to $BASE_DIR/app"
echo ""

# 3. Restart systemd služby (pokud existuje)
SERVICE_NAME="myapp.service"
if systemctl --user is-active --quiet "$SERVICE_NAME"; then
    echo "🔄 Restarting service..."
    systemctl --user restart "$SERVICE_NAME"
    echo "✅ Service restarted"
else
    echo "ℹ️  Service not running (skipped restart)"
fi

echo ""
echo "╔══════════════════════════════════════╗"
echo "║   ✅ Deployment completed!           ║"
echo "╚══════════════════════════════════════╝"
```

---

## Runtime: AppContext.BaseDirectory

### V C# Kódu

```csharp
// ✅ JEDINÝ SPRÁVNÝ ZDROJ base directory v runtime
var baseDir = AppContext.BaseDirectory;

// Vrátí např.: /opt/olbrasoft/myapp/app/
```

### Co to je?

- **Vlastnost běžícího procesu**
- Nastavuje **automaticky .NET runtime**
- Je **deterministický**
- Vždy dostupný
- Nemůže se "rozjet" mezi stroji

### ❌ **NEPOUŽÍVEJ**

```csharp
// ŠPATNĚ - pracovní adresář může být jiný než base directory
Directory.GetCurrentDirectory()

// ŠPATNĚ - environment proměnná může chybět
Environment.GetEnvironmentVariable("MYAPP_BASE")

// ŠPATNĚ - natvrdo zakódovaná cesta
var baseDir = "/opt/olbrasoft/myapp/";
```

### ✅ **POUŽIJ**

```csharp
// Vždy použij AppContext.BaseDirectory jako základ
var baseDir = AppContext.BaseDirectory;

// Relativní cesty od base directory
var configPath = Path.Combine(baseDir, "../config/appsettings.json");
var dataPath = Path.Combine(baseDir, "../data/mydata.db");
var certsPath = Path.Combine(baseDir, "../certs/server.pfx");
```

---

## Správný Mentální Model

```
Base Directory NENÍ konfigurace
Base Directory JE vlastnost běžícího procesu

Deploy DEFINUJE realitu
Runtime ji ČTE
Runtime ji NIKDY nekonfiguruje
Deploy ji NIKDY nezjišťuje
```

### Workflow

```
1. Operator spustí:
   ./deploy.sh /opt/olbrasoft/myapp
   
2. Deploy script:
   - Publikuje do $BASE_DIR/app/
   - Vytvoří $BASE_DIR/config/, data/, certs/ (pokud neexistují)
   - Restartuje systemd službu
   
3. Systemd spustí:
   /opt/olbrasoft/myapp/app/MyApp.dll
   
4. .NET runtime nastaví:
   AppContext.BaseDirectory = "/opt/olbrasoft/myapp/app/"
   
5. Aplikace používá:
   var configPath = Path.Combine(AppContext.BaseDirectory, "../config/appsettings.json");
```

---

## Příklad: Kompletní Projekt

### Struktura Projektu (repo)

```
~/dev/Olbrasoft/MyApp/
├── src/
│   ├── MyApp.Service/
│   │   ├── MyApp.Service.csproj
│   │   └── Program.cs
│   └── MyApp.Core/
│       └── MyApp.Core.csproj
├── tests/
│   └── MyApp.Service.Tests/
├── deploy/
│   ├── deploy.sh              ← Deploy script
│   └── myapp.service          ← Systemd service
├── README.md
└── MyApp.sln
```

### Deploy Script

**`deploy/deploy.sh`:**
```bash
#!/usr/bin/env bash
set -e

BASE_DIR="$1"
if [ -z "$BASE_DIR" ]; then
  echo "Usage: deploy.sh <base-directory>"
  exit 1
fi

# Testy
dotnet test --verbosity minimal || exit 1

# Publikace
dotnet publish src/MyApp.Service/MyApp.Service.csproj \
  -c Release \
  -o "$BASE_DIR/app" \
  --no-self-contained

# Vytvoř adresáře pro data (pokud neexistují)
mkdir -p "$BASE_DIR/config"
mkdir -p "$BASE_DIR/data"
mkdir -p "$BASE_DIR/certs"

echo "✅ Deployed to $BASE_DIR"
```

### Systemd Service

**`deploy/myapp.service`:**
```ini
[Unit]
Description=MyApp Service
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/olbrasoft/myapp/app
ExecStart=/usr/bin/dotnet /opt/olbrasoft/myapp/app/MyApp.Service.dll
Restart=always
RestartSec=5
Environment="DOTNET_ENVIRONMENT=Production"

[Install]
WantedBy=multi-user.target
```

### C# Kód

**`src/MyApp.Service/Program.cs`:**
```csharp
var builder = WebApplication.CreateBuilder(args);

// Base directory z runtime
var baseDir = AppContext.BaseDirectory;
Console.WriteLine($"Base directory: {baseDir}");

// Cesty relativně od base directory
var configPath = Path.Combine(baseDir, "../config");
var dataPath = Path.Combine(baseDir, "../data");

// Přidej konfiguraci
builder.Configuration
    .AddJsonFile(Path.Combine(configPath, "appsettings.json"), optional: true)
    .AddEnvironmentVariables();

var app = builder.Build();

app.MapGet("/", () => new 
{
    BaseDirectory = baseDir,
    ConfigPath = configPath,
    DataPath = dataPath
});

app.Run();
```

### Použití

```bash
# 1. Deploy
cd ~/dev/Olbrasoft/MyApp
./deploy/deploy.sh /opt/olbrasoft/myapp

# 2. Instalace systemd service
sudo cp deploy/myapp.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable myapp.service
sudo systemctl start myapp.service

# 3. Kontrola
sudo systemctl status myapp.service
curl http://localhost:5000/
```

---

## Dokumentace v README

### README Template

```markdown
# MyApp

## Deployment

**Target base directory:** Definováno jako argument deploy scriptu.

**Doporučená cesta:**
- Produkce: `/opt/olbrasoft/myapp`
- Vývoj: `~/apps/myapp`

### Deploy

```bash
# Základní deploy
./deploy/deploy.sh /opt/olbrasoft/myapp

# Nebo pro dev
./deploy/deploy.sh ~/apps/myapp
```

### Struktura

```
/opt/olbrasoft/myapp/       ← Base directory (argument scriptu)
├── app/                    ← Binárky (.NET runtime používá jako AppContext.BaseDirectory)
├── config/                 ← Konfigurace
├── data/                   ← Runtime data
└── certs/                  ← Certifikáty
```

### Systemd Service

1. Edit `deploy/myapp.service` - nastav správnou cestu v `WorkingDirectory`
2. Install:
```bash
sudo cp deploy/myapp.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable myapp.service
sudo systemctl start myapp.service
```
```

---

## Secrets a Environment Variables

### Kde Najít Secrets v Našich Projektech

**🔍 Development (User Secrets):**
```bash
# Zobraz všechny secrets pro daný projekt
cd ~/Olbrasoft/<ProjectName>
dotnet user-secrets list --project src/<ProjectName>/

# Příklad výstupu:
# GitHub:Token = ghp_xxx...
# ConnectionStrings:DefaultConnection:Password = xxx...
# AiProviders:Cohere:Keys:0 = xxx...
```

**🔍 Production (Startup Scripts):**
```bash
# Secrets jsou v startup scriptech jako environment variables
cat ~/.local/bin/<app>-start.sh

# Příklad:
# GITHUB_TOKEN="ghp_xxx..."
# CONNECTION_STRING="Server=...;Password=xxx;"
```

**📝 Typické Secrets:**
- `GitHub:Token` - GitHub Personal Access Token (pro načítání issue bodies přes GraphQL)
- `GitHub:ClientSecret` - GitHub OAuth Client Secret (pro přihlášení uživatelů)
- `ConnectionStrings:*:Password` - Hesla k databázím
- `AiProviders:*:Keys:*` - API keys pro AI služby (Cohere, Cerebras, Groq)

**⚠️ DŮLEŽITÉ:**
1. **NIKDY** necommituj secrets do Gitu
2. User Secrets jsou **POUZE pro development** (ignorují se v Production)
3. Pro Production přidej secrets do startup scriptu jako environment variables

---

### Pravidlo: Connection Strings a Hesla

**✅ SPRÁVNĚ:**
- `appsettings.json` - connection string **BEZ hesla** (může do Gitu)
- **Environment variable** - **CELÝ** connection string s heslem (nesmí do Gitu)

**❌ ŠPATNĚ:**
- Heslo v `appsettings.json` nebo `appsettings.Production.json`
- Heslo v kódu
- Heslo commitnuté do Gitu

### Environment Variables v .NET Core

**.NET Core formát (double underscore):**
```bash
# SPRÁVNĚ - dvojité underscore "__"
ConnectionStrings__DefaultConnection="Server=localhost;Database=mydb;User Id=sa;Password=secret;"

# ŠPATNĚ - jedno underscore (nefunguje!)
ConnectionStrings_DefaultConnection="..."
```

**Proč dvojité underscore?**
- .NET Core používá `__` pro zanořené konfigurace
- `ConnectionStrings__DefaultConnection` = `ConnectionStrings:DefaultConnection` v JSON

### Pořadí Načítání Konfigurace (.NET Core)

```
1. appsettings.json                    (základní)
2. appsettings.{Environment}.json      (override podle prostředí)
3. User Secrets                        (development only)
4. Environment Variables               ← NEJVYŠŠÍ PRIORITA (produkce)
5. Command-line arguments              (ruční override)
```

**Environment variables PŘEBIJÍ všechno ostatní!**

### Praktický Příklad

**appsettings.Production.json** (BEZ hesla, může do Gitu):
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=mydb;User Id=sa;"
  }
}
```

**Startup script** (S heslem, NESMÍ do Gitu):
```bash
#!/bin/bash
# github-start.sh

cd /opt/olbrasoft/myapp/app

# Environment variable PŘEBIJE appsettings.json
ConnectionStrings__DefaultConnection="Server=localhost;Database=mydb;User Id=sa;Password=TajneHeslo123!" \
ASPNETCORE_ENVIRONMENT=Production \
dotnet MyApp.dll
```

**Systemd service** (alternativa):
```ini
[Service]
Environment="ConnectionStrings__DefaultConnection=Server=localhost;Database=mydb;User Id=sa;Password=TajneHeslo123!"
Environment="ASPNETCORE_ENVIRONMENT=Production"
ExecStart=/usr/bin/dotnet /opt/olbrasoft/myapp/app/MyApp.dll
```

### Ověření

Toto bylo ověřeno z oficiální dokumentace a Stack Overflow:
- [Configuration in ASP.NET Core | Microsoft Learn](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/configuration/)
- [Stack Overflow: How to correctly store connection strings in environment variables](https://stackoverflow.com/questions/44931613/)
- Datum ověření: 2025-12-20

---

## GitHub Actions Self-Hosted Runners

### Nutnost Kontroly před Automatickým Deploymentem

**⚠️ KRITICKÉ:** Pokud používáš GitHub Actions workflow s `runs-on: self-hosted`, **MUSÍŠ** mít pro daný repozitář zaregistrovaný self-hosted runner!

### Kontrola Existence Runneru

**Před vytvořením GitHub Actions workflow:**

```bash
# 1. Zkontroluj existující runnery
ls -d ~/actions-runner* 2>/dev/null

# 2. Zkontroluj jejich konfiguraci
cat ~/actions-runner/.runner | grep -E "agentName|gitHubUrl"
cat ~/actions-runner-va/.runner | grep -E "agentName|gitHubUrl"

# 3. Ověř aktivní runnery
systemctl --user list-units | grep actions.runner
# nebo
sudo systemctl list-units | grep actions.runner
```

### Příklad Výstupu

```json
// ~/actions-runner/.runner
{
  "agentName": "debian",
  "gitHubUrl": "https://github.com/Olbrasoft/SpeechToText"
}

// ~/actions-runner-va/.runner
{
  "agentName": "debian-va",
  "gitHubUrl": "https://github.com/Olbrasoft/VirtualAssistant"
}
```

**Problém:** Pokud vytvoříš workflow pro `Olbrasoft/GitHub.Issues`, ale žádný runner není pro tento repozitář zaregistrovaný, workflow bude **trvale ve stavu "Queued"** (hnědá tečka).

### Řešení

**Možnost 1: Vytvořit nový repository-level runner**
```bash
# Stáhni GitHub Actions Runner
mkdir ~/actions-runner-github-issues
cd ~/actions-runner-github-issues
wget https://github.com/actions/runner/releases/download/v2.x.x/actions-runner-linux-x64-2.x.x.tar.gz
tar xzf actions-runner-linux-x64-2.x.x.tar.gz

# Registruj runner pro konkrétní repozitář
./config.sh --url https://github.com/Olbrasoft/GitHub.Issues --token <TOKEN>

# Spusť jako systemd service
sudo ./svc.sh install
sudo systemctl enable actions.runner.Olbrasoft-GitHub.Issues.debian.service
sudo systemctl start actions.runner.Olbrasoft-GitHub.Issues.debian.service
```

**Možnost 2: Organization-level runner (vyžaduje GitHub Organization)**
```bash
# Pokud máš GitHub Organization (např. Olbrasoft-org)
./config.sh --url https://github.com/Olbrasoft-org --token <TOKEN>

# Tento runner bude dostupný pro VŠECHNY repozitáře v organizaci
```

**Poznámka:** Repository-level runner funguje **pouze pro jeden repozitář**. Pokud máš více repozitářů, potřebuješ buď:
- Více runnerů (jeden pro každý repo)
- Organization-level runner (jeden pro všechny repo v organizaci)

### GitHub Actions Workflow Pattern

**`.github/workflows/deploy-local.yml`:**
```yaml
name: Deploy App (Local)

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: self-hosted  # ← VYŽADUJE runner!

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Run tests
        run: dotnet test --configuration Release

      - name: Deploy
        run: |
          # Base directory z argumentu (SINGLE SOURCE OF TRUTH)
          sudo ./deploy/deploy.sh /opt/olbrasoft/myapp

      - name: Restart service
        run: systemctl --user restart myapp.service
```

### Diagnostika Problémů

**Workflow je "Queued" (hnědá tečka) a nespouští se:**

```bash
# 1. Zkontroluj, jestli máš runner pro tento repozitář
gh api repos/Olbrasoft/GitHub.Issues/actions/runners

# 2. Zkontroluj aktivní runnery na stroji
systemctl --user list-units | grep actions.runner

# 3. Zkontroluj logy runneru
journalctl --user -u actions.runner.Olbrasoft-MyRepo.debian.service -f
```

**Pokud žádný runner není zaregistrovaný, workflow NIKDY nezačne běžet!**

### ⚠️ KRITICKÉ: PATH a .NET SDK Verze

**Problém:** Runner může používat špatnou verzi .NET SDK!

Pokud máš .NET 10 SDK nainstalované v `~/.dotnet/`, ale systemd service runneru nemá správný PATH, runner použije system-wide .NET SDK (obvykle starší verze v `/usr/share/dotnet/`).

**Symptom:**
```
error NETSDK1045: Aktuální sada .NET SDK nepodporuje cílení .NET 10.0.
Buď zacilte .NET 8.0 nebo nižší, nebo použijte verzi sady .NET SDK, která podporuje .NET 10.0.
```

**Řešení:** Systemd service MUSÍ mít správný PATH s `~/.dotnet` NA ZAČÁTKU!

**Správná konfigurace:**
```ini
[Unit]
Description=GitHub Actions Runner (...)
After=network.target

[Service]
ExecStart=/home/user/actions-runner-xxx/runsvc.sh
User=user
WorkingDirectory=/home/user/actions-runner-xxx
Environment="PATH=/home/user/.dotnet:/home/user/.local/bin:/usr/local/bin:/usr/bin:/bin"
KillMode=process
KillSignal=SIGTERM
TimeoutStopSec=5min

[Install]
WantedBy=multi-user.target
```

**Důležité:**
- `~/.dotnet` MUSÍ být PRVNÍ v PATH
- Používej absolutní cesty (ne `~`, ale `/home/user/`)
- Po změně: `sudo systemctl daemon-reload && sudo systemctl restart <service>`

**Ověření:**
```bash
# 1. Zkontroluj PATH v service
sudo systemctl cat actions.runner.XXX.service | grep Environment

# 2. Zkontroluj, kterou verzi dotnet používá runner
sudo journalctl -u actions.runner.XXX.service | grep "dotnet --version"
```

**⚠️ BEZ tohoto PATH nastavení bude workflow padat s NETSDK1045 chybou!**

### Best Practices

| Pravidlo | Důvod |
|----------|-------|
| **Před vytvořením workflow zkontroluj runnery** | Předejdeš "Queued" stavu |
| **Pojmenuj runnery podle repozitáře** | Snadnější identifikace (např. `debian-va`, `debian-github-issues`) |
| **Používej systemd pro automatický start** | Runner se spustí po restartu systému |
| **Organization-level runner pro více repozitářů** | Efektivnější než desítky repository-level runnerů |
| **⚠️ VŽDY nastav PATH s .NET SDK** | Prevent NETSDK1045 chyby |
| **⚠️ PO KAŽDÉM PUSH zkontroluj výsledek workflow** | Ověř, že deploy skutečně proběhl (ne pouze assume) |

### Reference

- [GitHub Actions Self-Hosted Runners Documentation](https://docs.github.com/en/actions/hosting-your-own-runners)
- [Adding Self-Hosted Runners](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners)
- Datum ověření: 2025-12-20

---

## Checklist před Deploymentem

- [ ] Všechny testy prochází (`dotnet test`)
- [ ] Deploy script dostává base directory jako argument
- [ ] Deploy script NEPŘEDPOKLÁDÁ cestu (nemá ji natvrdo)
- [ ] Systemd service má správný `WorkingDirectory`
- [ ] C# kód používá `AppContext.BaseDirectory` (ne natvrdo cestu)
- [ ] Dokumentace (README) vysvětluje strukturu adresářů
- [ ] Data nejsou ukládána do složky s binárkami
- [ ] **Pokud používáš GitHub Actions: Self-hosted runner je zaregistrovaný pro tento repozitář**
- [ ] **Po push na main: Zkontroluj výsledek workflow na GitHubu** (`gh run watch` nebo GitHub web UI)

---

## Verifikace po Deployu

**⚠️ KRITICKÉ:** Po každém deployu MUSÍŠ ověřit, že aplikace skutečně běží a je funkční!

### 1. Ověř, že proces běží

```bash
# Zjisti, jestli aplikace běží
ps aux | grep <název-dll> | grep -v grep

# Pro systemd služby
systemctl --user status <název-služby>
# nebo
sudo systemctl status <název-služby>
```

### 2. Ověř HTTP response (webové aplikace)

```bash
# Základní test - vrací HTTP 200?
curl -s -o /dev/null -w "%{http_code}" http://localhost:<port>

# Pokud vrací 500 nebo jinou chybu, podívej se na response
curl -s http://localhost:<port> | head -50
```

### 3. Ověř vizuálně pomocí Playwright (doporučeno pro webové aplikace)

```bash
# V Claude Code použij Playwright MCP
mcp__playwright__browser_navigate(url: "http://localhost:<port>")
mcp__playwright__browser_take_screenshot(filename: "verify-deploy.png")
```

### 4. Zkontroluj logy

```bash
# Pro systemd služby
journalctl --user -u <název-služby> -n 50

# Pro manuálně spuštěné aplikace
tail -100 /path/to/logfile.log
```

### Co kontrolovat v lozích:

- ✅ **"Application started"** - aplikace se úspěšně spustila
- ✅ **"Now listening on: http://localhost:XXXX"** - port je správný
- ❌ **Configuration errors** - chybná konfigurace (např. špatný connection string)
- ❌ **Missing dependencies** - chybějící Ollama, databáze, atd.
- ❌ **Port conflicts** - port už používá jiná aplikace

### Příklad kompletní verifikace:

```bash
# 1. Proces běží?
ps aux | grep MyApp.dll | grep -v grep
# ✅ Výstup: jirka  123456  ... dotnet MyApp.dll

# 2. HTTP response?
curl -s -o /dev/null -w "%{http_code}" http://localhost:5000
# ✅ Výstup: 200 (OK) nebo 500 (běží, ale má chybu v konfiguraci)
# ❌ Výstup: 000 (neběží vůbec)

# 3. Logy?
journalctl --user -u myapp.service -n 20
# ✅ Hledej: "Now listening on: http://localhost:5000"
# ❌ Hledej: "Failed to...", "Error", "Exception"
```

### ⚠️ Časté chyby při verifikaci:

| Problém | Příčina | Řešení |
|---------|---------|--------|
| Proces neběží | Deploy skončil, ale restart selhal | Zkontroluj systemd logy, spusť manuálně |
| HTTP 000 (no response) | Aplikace neběží nebo běží na jiném portu | Ověř port pomocí `ss -tulpn \| grep <port>` |
| HTTP 500 (server error) | Konfigurace chyba (connection string, secrets) | Zkontroluj logy, oprav konfiguraci |
| Špatný port | `ASPNETCORE_URLS` není nastavený | Nastav environment variable v startup scriptu |

### ⚠️ DŮLEŽITÉ: Co dělat když verifikace selže?

**Pokud aplikace neběží nebo má chyby:**

1. **Oprav problém** v kódu nebo konfiguraci
2. **Commit + push** (spustí se workflow znova)
3. **Sleduj workflow** (`gh run watch`) - ověř, že tentokrát proběhlo úspěšně
4. **Verifikuj ZNOVA** - proces, HTTP response, logy, Playwright
5. **Opakuj dokud verifikace neprojde** ✅

**NIKDY neoznač deploy jako hotový, pokud verifikace selhává!**

Deployment není dokončený dokud aplikace:
- ✅ Běží (proces existuje)
- ✅ Odpovídá na HTTP požadavky (ne 000, ne connection refused)
- ✅ **Nemá ŽÁDNÉ chyby v response ani lozích**

⚠️ **KRITICKÁ CHYBA:** Neříkej, že deployment je úspěšný, když:
- ❌ HTTP response vrací 500 (i když proces běží!)
- ❌ V lozích jsou "Failed to...", "Error", "Exception", "InvalidOperationException"
- ❌ Aplikace hlásí chybějící konfiguraci, connection string, nebo dependencies
- ❌ V Playwright vidíš "Internal Server Error" stránku

**To jsou STÁLE CHYBY a deployment NENÍ dokončený!**

I když workflow prošel ✅ a proces běží ✅, pokud aplikace hlásí chyby → **NENÍ TO ÚSPĚŠNÝ DEPLOYMENT!**

---

## Funkční Testování Webových Aplikací

**⚠️ KRITICKÉ:** Pro webové aplikace NESTAČÍ ověřit, že proces běží a vrací HTTP 200!

### Povinný Workflow pro Webové Aplikace

1. **Vytvoř Test Plán**
   - Seznam všech kritických funkcí aplikace
   - Pro každou funkci specifikuj, co testuje (autentizace, API volání, databáze, AI služby, atd.)
   - Zapiš test plán do CLAUDE.md v repozitáři projektu

2. **Proveď Funkční Testování pomocí Playwright**
   - Otevři aplikaci v Playwright (`mcp__playwright__browser_navigate`)
   - Systematicky projdi VŠECHNY body z test plánu
   - Testuj každou kritickou funkci (tlačítka, formuláře, načítání dat, API calls)
   - Pořiď screenshoty úspěšných testů

3. **Zaznamenej Výsledky**
   - ✅ Test prošel - pokračuj dalším
   - ❌ Test selhal - oprav problém, redeploy, testuj ZNOVA od začátku

### Příklad Test Plánu

Pro typickou webovou aplikaci testuj minimálně:

```markdown
### 1. Autentizace
- Klikni na přihlašovací tlačítko
- Ověř OAuth/login flow
- **Testuje:** Authentication handler

### 2. Hlavní Funkcionalita
- Vyplň formulář
- Klikni na submit
- Ověř, že se zobrazí výsledky
- **Testuje:** Business logic, database, API calls

### 3. Detail View
- Klikni na položku v seznamu
- Ověř, že se zobrazí detail
- **Testuje:** Routing, data fetching

### 4. Filtrování/Vyhledávání
- Použij filtry
- Ověř, že filtrování funguje
- **Testuje:** Query logic, database

### 5. AI/External Services (pokud aplikace používá)
- Ověř, že se zobrazují AI generované výsledky
- **Testuje:** External API integrace
```

### ⚠️ NIKDY nehlásej deployment jako úspěšný dokud:

- ❌ Nevytvořil jsi test plán
- ❌ Neprovedl jsi VŠECHNY testy z plánu
- ❌ Jakýkoliv test selhává

**Deployment je dokončený = workflow ✅ + proces běží ✅ + HTTP 200 ✅ + VŠECHNY funkční testy prošly ✅**

---

## Reference

- [Workflow Guide](./workflow-guide-cz.md) - Git workflow, GitHub issues
- [Code Review & Refactoring](./code-review-refactoring-guide-cz.md) - BaseDirectory pravidlo
- [.NET Project Structure](./dotnet-project-structure-cz.md) - Struktura projektů
- [Linux FHS](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html) - Filesystem Hierarchy Standard
