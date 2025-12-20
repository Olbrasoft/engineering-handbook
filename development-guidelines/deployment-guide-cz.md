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
/opt/olbrasoft/virtualassistant/
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

## Checklist před Deploymentem

- [ ] Všechny testy prochází (`dotnet test`)
- [ ] Deploy script dostává base directory jako argument
- [ ] Deploy script NEPŘEDPOKLÁDÁ cestu (nemá ji natvrdo)
- [ ] Systemd service má správný `WorkingDirectory`
- [ ] C# kód používá `AppContext.BaseDirectory` (ne natvrdo cestu)
- [ ] Dokumentace (README) vysvětluje strukturu adresářů
- [ ] Data nejsou ukládána do složky s binárkami

---

## Reference

- [Workflow Guide](./workflow-guide-cz.md) - Git workflow, GitHub issues
- [Code Review & Refactoring](./code-review-refactoring-guide-cz.md) - BaseDirectory pravidlo
- [.NET Project Structure](./dotnet-project-structure-cz.md) - Struktura projektů
- [Linux FHS](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html) - Filesystem Hierarchy Standard
